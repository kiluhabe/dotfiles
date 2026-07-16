#!/usr/bin/env python3
"""code-memory: deterministic store for per-source-file code notes."""
import argparse, hashlib, json, os, subprocess, sys
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


def main(argv=None):
    p = argparse.ArgumentParser(prog="mem")
    p.add_subparsers(dest="cmd")
    args = p.parse_args(argv)
    p.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
