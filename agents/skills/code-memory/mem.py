#!/usr/bin/env python3
"""code-memory: deterministic store for per-source-file code notes."""
import argparse, datetime, hashlib, json, os, subprocess, sys
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


def main(argv=None):
    p = argparse.ArgumentParser(prog="mem")
    sub = p.add_subparsers(dest="cmd")
    sp = sub.add_parser("save"); sp.add_argument("file")
    args = p.parse_args(argv)
    if args.cmd == "save":
        return cmd_save(args)
    p.print_help(); return 0


if __name__ == "__main__":
    sys.exit(main())
