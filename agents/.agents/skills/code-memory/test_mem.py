import json, os, shutil, sqlite3, subprocess, sys, tempfile, unittest, hashlib
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

    def test_worktree_shares_repo_id(self):
        root = Path(self.tmp.name) / "repo"
        wt = Path(self.tmp.name) / "repo-wt"
        root.mkdir()
        _git(root, "init")
        _git(root, "-c", "user.email=a@b.c", "-c", "user.name=t",
             "commit", "--allow-empty", "-m", "root")
        _git(root, "worktree", "add", "-b", "wt", str(wt))

        repo_id, _ = mem.resolve_repo(str(root))
        wt_repo_id, _ = mem.resolve_repo(str(wt))

        self.assertEqual(wt_repo_id, repo_id)

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

    def test_save_deduplicates_exact_findings(self):
        first = json.dumps({"role": "R1", "findings": ["f1", "f2"]})
        subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=first.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True)

        second = json.dumps({"findings": ["f2", "f3", "f1"]})
        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=second.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True).stdout.decode().strip()

        parsed = mem.parse_md(Path(out))
        self.assertEqual(parsed["findings"], ["f1", "f2", "f3"])

    def test_save_ignores_empty_findings(self):
        payload = json.dumps({"role": "R1",
                              "findings": ["", "   ", "\t", "useful"]})
        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            input=payload.encode(), cwd=self.tmp.name,
            stdout=subprocess.PIPE, check=True).stdout.decode().strip()

        parsed = mem.parse_md(Path(out))
        self.assertEqual(parsed["findings"], ["useful"])


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

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_forget_deindexes_fts_row(self):
        self._save()
        repo_id, _ = mem.resolve_repo(self.tmp.name)
        mem.reindex(repo_id)
        con = mem._connect()
        rows = con.execute(
            "SELECT path FROM notes WHERE repo = ?", (repo_id,)).fetchall()
        con.close()
        self.assertEqual(len(rows), 1)

        self.assertEqual(self._run("forget", str(self.f)), 0)

        con = mem._connect()
        rows = con.execute(
            "SELECT path FROM notes WHERE repo = ?", (repo_id,)).fetchall()
        con.close()
        self.assertEqual(rows, [])


class Query(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        os.environ["MEM_NO_SQLITE"] = "1"   # grep 経路を強制
        self.f = Path(self.tmp.name) / "webhooks.py"
        self.f.write_text("def stripe(): pass\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(self.f)], cwd=self.tmp.name,
                       input=b'{"role":"handles stripe webhook signature"}',
                       check=True)

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()
        os.environ.pop("MEM_NO_SQLITE", None)

    def _query(self, text):
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", text], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        return [json.loads(l) for l in out.decode().splitlines() if l.strip()]

    def test_query_hit_not_stale(self):
        rows = self._query("stripe webhook")
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["path"], "webhooks.py")
        self.assertFalse(rows[0]["stale"])

    def test_query_marks_stale_after_edit(self):
        self.f.write_text("def stripe(): return 1\n")
        rows = self._query("stripe")
        self.assertTrue(rows[0]["stale"])


class Sqlite(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        os.environ.pop("MEM_NO_SQLITE", None)
        self.f = Path(self.tmp.name) / "auth.py"
        self.f.write_text("def login(): pass\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(self.f)], cwd=self.tmp.name,
                       input=b'{"role":"session login and jwt issuance"}',
                       check=True)

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_reindex_then_query_via_fts(self):
        n = subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                           cwd=self.tmp.name, stdout=subprocess.PIPE,
                           check=True).stdout.decode()
        self.assertIn("1", n)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_save_indexes_memory_for_query(self):
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_manual_markdown_edit_requires_reindex(self):
        repo_id, _ = mem.resolve_repo(self.tmp.name)
        md = mem.md_path(repo_id, "auth.py")
        text = md.read_text()
        md.write_text(text + "\n- manual-only-token\n")

        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "manual-only-token"],
                             cwd=self.tmp.name, stdout=subprocess.PIPE,
                             check=True).stdout
        self.assertEqual(out.decode().strip(), "")

        subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                       cwd=self.tmp.name, stdout=subprocess.PIPE, check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "manual-only-token"],
                             cwd=self.tmp.name, stdout=subprocess.PIPE,
                             check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_forget_removes_memory_from_query(self):
        subprocess.run([sys.executable, str(HERE / "mem.py"), "forget",
                        str(self.f)], cwd=self.tmp.name, check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        self.assertEqual(out.decode().strip(), "")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_reindex_rebuilds_deleted_db_from_markdown(self):
        mem._db_path().unlink()
        subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                       cwd=self.tmp.name, stdout=subprocess.PIPE, check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_reindex_rebuilds_corrupt_db(self):
        mem._db_path().write_bytes(b"not a sqlite database")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                       cwd=self.tmp.name, stdout=subprocess.PIPE, check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_reindex_rebuilds_old_non_fts_schema(self):
        mem._db_path().unlink()
        con = sqlite3.connect(mem._db_path())
        con.execute("CREATE TABLE notes(repo TEXT, path TEXT)")
        con.commit(); con.close()

        subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                       cwd=self.tmp.name, stdout=subprocess.PIPE, check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "jwt login"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "auth.py")

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_dotted_filename_query_matches(self):
        f = Path(self.tmp.name) / "pay.py"
        f.write_text("def charge(): pass\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(f)], cwd=self.tmp.name,
                       input=b'{"role":"entry point for charging a '
                             b'customer via the gateway"}', check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "pay.py"], cwd=self.tmp.name,
                             stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertIn("pay.py", [r["path"] for r in rows])

    @unittest.skipUnless(mem.sqlite_ok(), "sqlite3/FTS5 unavailable")
    def test_query_matches_symbol_and_finding(self):
        f = Path(self.tmp.name) / "billing.py"
        f.write_text("def charge_customer(): pass\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(f)], cwd=self.tmp.name,
                       input=(b'{"role":"customer billing",'
                              b'"symbols":["charge_customer"],'
                              b'"findings":["uses idempotency keys"]}'),
                       check=True)
        out = subprocess.run([sys.executable, str(HERE / "mem.py"),
                              "query", "charge_customer idempotency"],
                             cwd=self.tmp.name, stdout=subprocess.PIPE,
                             check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(rows[0]["path"], "billing.py")


class SkillDoc(unittest.TestCase):
    def test_skill_frontmatter_is_valid_yaml(self):
        if not shutil.which("ruby"):
            self.skipTest("ruby YAML parser unavailable")
        text = (HERE / "SKILL.md").read_text()
        self.assertTrue(text.startswith("---\n"))
        end = text.index("\n---", 4)
        frontmatter = text[4:end]
        r = subprocess.run(
            ["ruby", "-ryaml", "-e", "YAML.safe_load(STDIN.read)"],
            input=frontmatter.encode(), stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        self.assertEqual(r.returncode, 0, r.stderr.decode())

    def test_skill_doc_is_ascii(self):
        text = (HERE / "SKILL.md").read_text()
        self.assertTrue(text.isascii())


class ReindexNoSqlite(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        os.environ["MEM_NO_SQLITE"] = "1"
        self.f = Path(self.tmp.name) / "webhooks.py"
        self.f.write_text("def stripe(): pass\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(self.f)], cwd=self.tmp.name,
                       input=b'{"role":"handles stripe webhook signature"}',
                       check=True)

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()
        os.environ.pop("MEM_NO_SQLITE", None)

    def test_reindex_skipped_without_sqlite(self):
        r = subprocess.run([sys.executable, str(HERE / "mem.py"), "reindex"],
                           cwd=self.tmp.name, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
        self.assertEqual(r.returncode, 1)
        self.assertIn("reindex skipped", r.stderr.decode())


class Prune(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        os.environ["MEM_NO_SQLITE"] = "1"
        self.f = Path(self.tmp.name) / "gone.py"
        self.f.write_text("y=1\n")
        subprocess.run([sys.executable, str(HERE / "mem.py"), "save",
                        str(self.f)], cwd=self.tmp.name,
                       input=b'{"role":"temp"}', check=True)

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()
        os.environ.pop("MEM_NO_SQLITE", None)

    def test_prune_deletes_when_source_removed(self):
        self.f.unlink()
        out = subprocess.run([sys.executable, str(HERE / "mem.py"), "prune"],
                             cwd=self.tmp.name, stdout=subprocess.PIPE,
                             check=True).stdout.decode()
        self.assertIn("1", out)
        r = subprocess.run([sys.executable, str(HERE / "mem.py"), "check",
                            str(self.f)], cwd=self.tmp.name)
        self.assertEqual(r.returncode, 2)

    def test_prune_deletes_when_source_stale(self):
        self.f.write_text("y=2\n")
        out = subprocess.run([sys.executable, str(HERE / "mem.py"), "prune"],
                             cwd=self.tmp.name, stdout=subprocess.PIPE,
                             check=True).stdout.decode()
        self.assertIn("1", out)
        r = subprocess.run([sys.executable, str(HERE / "mem.py"), "check",
                            str(self.f)], cwd=self.tmp.name)
        self.assertEqual(r.returncode, 2)


class GitEndToEnd(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.cache = tempfile.TemporaryDirectory()
        os.environ["XDG_CACHE_HOME"] = self.cache.name
        os.environ["MEM_NO_SQLITE"] = "1"
        _git(self.tmp.name, "init")
        _git(self.tmp.name, "-c", "user.email=a@b.c", "-c", "user.name=t",
             "commit", "--allow-empty", "-m", "root")
        self.f = Path(self.tmp.name) / "billing.py"
        self.f.write_text("def charge_customer(): pass\n")
        subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "save", str(self.f)],
            cwd=self.tmp.name,
            input=b'{"role":"handles customer billing and invoices"}',
            check=True)

    def tearDown(self):
        self.tmp.cleanup(); self.cache.cleanup()
        os.environ.pop("MEM_NO_SQLITE", None)

    def test_save_then_query_in_git_repo(self):
        out = subprocess.run(
            [sys.executable, str(HERE / "mem.py"), "query", "billing"],
            cwd=self.tmp.name, stdout=subprocess.PIPE, check=True).stdout
        rows = [json.loads(l) for l in out.decode().splitlines() if l.strip()]
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["path"], "billing.py")
        self.assertFalse(rows[0]["stale"])


if __name__ == "__main__":
    unittest.main()
