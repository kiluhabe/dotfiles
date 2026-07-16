#!/usr/bin/env python3
"""code-memory: deterministic store for per-source-file code notes."""
import argparse, datetime, hashlib, json, os, sqlite3, subprocess, sys
from pathlib import Path


def mem_root() -> Path:
    base = os.environ.get("XDG_CACHE_HOME") or str(Path.home() / ".cache")
    return Path(base) / "agent-memory"


def _git_out(cwd, *args):
    try:
        r = subprocess.run(["git", *args], cwd=cwd, check=True,
                           stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        return r.stdout.decode().strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def resolve_repo(cwd: str):
    top = _git_out(cwd, "rev-parse", "--show-toplevel")
    if not top:
        return "local-" + Path(cwd).name, cwd
    roots = _git_out(top, "rev-list", "--max-parents=0", "HEAD")
    if not roots:
        return "local-" + Path(top).name, top
    root8 = sorted(roots.split("\n"))[0][:8]
    return f"{Path(top).name}-{root8}", top


def rel_path(repo_root: str, file: str) -> str:
    return str(Path(file).resolve().relative_to(Path(repo_root).resolve()))


def md_path(repo_id: str, rel: str) -> Path:
    return mem_root() / repo_id / (rel + ".md")


def sha256_of(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _fmt_md(repo_id, rel, sha, payload):
    at = datetime.datetime.now(datetime.timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%SZ")
    lines = ["---", "mem: 1", f"repo: {repo_id}", f"path: {rel}",
             f"sha256: {sha}", f"at: {at}", "---", "",
             f"# {rel}", "", "## Role", payload.get("role", "").strip(), "",
             "## Key symbols"]
    for s in payload.get("symbols", []):
        lines.append(f"- {s}")
    lines += ["", "## Findings"]
    for fi in payload.get("findings", []):
        lines.append(f"- {fi}")
    return "\n".join(lines) + "\n"


def write_md(repo_id, rel, sha, payload):
    path = md_path(repo_id, rel)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(_fmt_md(repo_id, rel, sha, payload))
    return path


def parse_md(path):
    text = Path(path).read_text()
    meta, body = {}, text
    if text.startswith("---\n"):
        end = text.index("\n---", 4)
        for line in text[4:end].splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
        body = text[end + 4:]
    role, symbols, findings, section = "", [], [], None
    for line in body.splitlines():
        if line.startswith("## "):
            section = line[3:].strip().lower()
            continue
        if section == "role" and line.strip():
            role = (role + " " + line.strip()).strip()
        elif section == "key symbols" and line.startswith("- "):
            symbols.append(line[2:])
        elif section == "findings" and line.startswith("- "):
            findings.append(line[2:])
    return {"meta": meta, "role": role, "symbols": symbols,
            "findings": findings}


def cmd_save(args):
    repo_id, repo_root = resolve_repo(os.getcwd())
    rel = rel_path(repo_root, args.file)
    payload = json.loads(sys.stdin.read() or "{}")
    existing = md_path(repo_id, rel)
    if existing.exists():
        prev = parse_md(existing)
        payload.setdefault("role", prev["role"])
        payload["symbols"] = payload.get("symbols") or prev["symbols"]
        payload["findings"] = prev["findings"] + payload.get("findings", [])
    path = write_md(repo_id, rel, sha256_of(args.file), payload)
    print(path)
    return 0


def _resolve(file):
    repo_id, repo_root = resolve_repo(os.getcwd())
    return repo_id, rel_path(repo_root, file)


def cmd_check(args):
    repo_id, rel = _resolve(args.file)
    path = md_path(repo_id, rel)
    if not path.exists():
        return 2
    recorded = parse_md(path)["meta"].get("sha256")
    return 0 if recorded == sha256_of(args.file) else 1


def cmd_forget(args):
    repo_id, rel = _resolve(args.file)
    path = md_path(repo_id, rel)
    if path.exists():
        path.unlink()
    return 0


def iter_md(repo_id):
    base = mem_root() / repo_id
    if base.exists():
        yield from base.rglob("*.md")


def grep_search(repo_id, terms):
    hits = []
    for md in iter_md(repo_id):
        low = md.read_text().lower()
        score = sum(low.count(t.lower()) for t in terms)
        if score:
            hits.append((score, md))
    return [m for _, m in sorted(hits, key=lambda x: -x[0])]


def _row_for(repo_id, repo_root, md):
    parsed = parse_md(md)
    rel = parsed["meta"].get("path")
    src = Path(repo_root) / rel
    current = sha256_of(str(src)) if src.exists() else None
    recorded = parsed["meta"].get("sha256")
    return {"path": rel, "role_excerpt": parsed["role"][:200],
            "recorded_sha": recorded, "current_sha": current,
            "stale": current != recorded}


def _db_path():
    return mem_root() / "index.sqlite"


def sqlite_ok():
    if os.environ.get("MEM_NO_SQLITE"):
        return False
    try:
        con = sqlite3.connect(":memory:")
        con.execute("CREATE VIRTUAL TABLE t USING fts5(x)")
        con.close()
        return True
    except sqlite3.OperationalError:
        return False


def _connect():
    mem_root().mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(_db_path())
    con.execute("CREATE VIRTUAL TABLE IF NOT EXISTS notes "
                "USING fts5(repo, path, role, body)")
    return con


def reindex(repo_id):
    con = _connect()
    con.execute("DELETE FROM notes WHERE repo = ?", (repo_id,))
    n = 0
    for md in iter_md(repo_id):
        p = parse_md(md)
        con.execute("INSERT INTO notes(repo, path, role, body) "
                    "VALUES(?,?,?,?)",
                    (repo_id, p["meta"].get("path", ""), p["role"],
                     " ".join(p["symbols"] + p["findings"])))
        n += 1
    con.commit(); con.close()
    return n


def fts_search(repo_id, text):
    con = _connect()
    q = " OR ".join(t for t in text.split() if t) or text
    try:
        rows = con.execute(
            "SELECT path FROM notes WHERE repo = ? AND notes MATCH ? "
            "ORDER BY rank", (repo_id, q)).fetchall()
    except sqlite3.OperationalError:
        rows = []
    con.close()
    return [md_path(repo_id, r[0]) for r in rows]


def cmd_reindex(args):
    repo_id, _ = resolve_repo(os.getcwd())
    if not sqlite_ok():
        sys.stderr.write(
            "[code-memory] sqlite3/FTS5 unavailable; reindex skipped. "
            "Install a Python3 with sqlite3 to enable FTS.\n")
        return 1
    print(reindex(repo_id))
    return 0


def cmd_query(args):
    repo_id, repo_root = resolve_repo(os.getcwd())
    if sqlite_ok():
        reindex(repo_id)
        mds = fts_search(repo_id, args.text)
    else:
        sys.stderr.write(
            "[code-memory] sqlite3/FTS5 unavailable; using grep. "
            "Install a Python3 with sqlite3 for faster search.\n")
        mds = grep_search(repo_id, [t for t in args.text.split() if t])
    for md in mds:
        print(json.dumps(_row_for(repo_id, repo_root, md)))
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(prog="mem")
    sub = p.add_subparsers(dest="cmd")
    sp = sub.add_parser("save"); sp.add_argument("file")
    cp = sub.add_parser("check"); cp.add_argument("file")
    fp = sub.add_parser("forget"); fp.add_argument("file")
    qp = sub.add_parser("query"); qp.add_argument("text")
    sub.add_parser("reindex")
    args = p.parse_args(argv)
    if args.cmd == "save":
        return cmd_save(args)
    if args.cmd == "check":
        return cmd_check(args)
    if args.cmd == "forget":
        return cmd_forget(args)
    if args.cmd == "query":
        return cmd_query(args)
    if args.cmd == "reindex":
        return cmd_reindex(args)
    p.print_help(); return 0


if __name__ == "__main__":
    sys.exit(main())
