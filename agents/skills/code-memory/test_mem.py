import json, os, subprocess, sys, tempfile, unittest, hashlib
from pathlib import Path
import importlib.util

HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location("mem", HERE / "mem.py")
mem = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mem)


def _git(root, *args):
    subprocess.run(["git", *args], cwd=root, check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


class RepoAndPaths(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name

    def tearDown(self):
        self.tmp.cleanup()
        self.cache.cleanup()

    def test_mem_root_uses_xdg(self):
        self.assertEqual(mem.mem_root(),
                         Path(self.cache.name) / "agent-memory")

    def test_resolve_repo_git(self):
        root = self.tmp.name
        _git(root, "init")
        _git(root, "-c", "user.email=a@b.c", "-c", "user.name=t",
             "commit", "--allow-empty", "-m", "root")
        repo_id, repo_root = mem.resolve_repo(root)
        self.assertTrue(repo_id.startswith(Path(root).name + "-"))
        self.assertEqual(len(repo_id.split("-")[-1]), 8)
        self.assertEqual(Path(repo_root).resolve(), Path(root).resolve())

    def test_resolve_repo_local_fallback(self):
        repo_id, repo_root = mem.resolve_repo(self.tmp.name)
        self.assertEqual(repo_id, "local-" + Path(self.tmp.name).name)
        self.assertEqual(Path(repo_root), Path(self.tmp.name))

    def test_sha256_and_paths(self):
        f = Path(self.tmp.name) / "sub" / "a.py"
        f.parent.mkdir(parents=True)
        f.write_text("print(1)\n")
        want = hashlib.sha256(b"print(1)\n").hexdigest()
        self.assertEqual(mem.sha256_of(str(f)), want)
        self.assertEqual(mem.rel_path(self.tmp.name, str(f)), "sub/a.py")
        self.assertEqual(mem.md_path("repo-x", "sub/a.py"),
                         mem.mem_root() / "repo-x" / "sub" / "a.py.md")


class SaveAndParse(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        self.f = Path(self.tmp.name) / "vim" / "config.lua"
        self.f.parent.mkdir(parents=True)
        self.f.write_text("return {}\n")

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()

    def test_save_writes_md_and_roundtrips(self):
        payload = json.dumps({"role": "editor config",
                              "symbols": ["setup() L1"],
                              "findings": ["loads lazily"]})
        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=payload.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True).stdout.decode().strip()
        md = Path(out)
        self.assertTrue(md.exists())
        parsed = mem.parse_md(md)
        self.assertEqual(parsed["meta"]["path"], "vim/config.lua")
        self.assertEqual(parsed["meta"]["sha256"], mem.sha256_of(str(self.f)))
        self.assertEqual(parsed["role"], "editor config")
        self.assertIn("loads lazily", parsed["findings"])

    def test_save_without_findings_preserves_prior_findings(self):
        first = json.dumps({"role": "R1", "symbols": ["s1"],
                             "findings": ["f1"]})
        subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=first.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True)

        second = json.dumps({"findings": ["f2"]})
        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=second.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True).stdout.decode().strip()

        parsed = mem.parse_md(Path(out))
        self.assertEqual(parsed["role"], "R1")
        self.assertIn("s1", parsed["symbols"])
        self.assertEqual(parsed["findings"], ["f1", "f2"])

    def test_save_with_no_findings_key_keeps_prior_findings(self):
        first = json.dumps({"role": "R1", "symbols": ["s1"],
                             "findings": ["f1"]})
        subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=first.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True)

        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=b"{}", cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True).stdout.decode().strip()

        parsed = mem.parse_md(Path(out))
        self.assertEqual(parsed["role"], "R1")
        self.assertIn("s1", parsed["symbols"])
        self.assertEqual(parsed["findings"], ["f1"])


class CheckForget(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        self.f = Path(self.tmp.name) / "a.py"
        self.f.write_text("x=1\n")

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()

    def _run(self, *a, code=None):
        r = subprocess.run([sys.executable, str(HERE / "mem.py"), *a],
                           cwd=self.tmp.name, input=code)
        return r.returncode

    def _save(self):
        self._run_in = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            cwd=self.tmp.name, input=b'{"role":"r"}', check=True)

    def test_check_unrecorded(self):
        self.assertEqual(self._run("check", str(self.f)), 2)

    def test_check_match_then_mismatch(self):
        self._save()
        self.assertEqual(self._run("check", str(self.f)), 0)
        self.f.write_text("x=2\n")
        self.assertEqual(self._run("check", str(self.f)), 1)

    def test_forget_removes(self):
        self._save()
        self.assertEqual(self._run("forget", str(self.f)), 0)
        self.assertEqual(self._run("check", str(self.f)), 2)


if __name__ == "__main__":
    unittest.main()
