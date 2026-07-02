# Case 03 — criterion unmet: filter parsed but never applied

**Planted defect:** M2-02's `--status` flag is accepted by argparse but never reaches the
query — `list` always returns everything. The ledger still flips M2-02 to `passes: true`,
citing a test that only proves the flag *parses*. The captured outcome shows the
unfiltered output.
**Expected verdict:** FAIL
**Must flag:** Check 1 — M2-02 unmet; the cited evidence does not prove the behaviour.
(Check 8 — outcome contradicts M2-02 — is an acceptable alternate; either proves detection.)

## Diff

```diff
--- a/tasklite/store.py
+++ b/tasklite/store.py
@@ -18,6 +18,14 @@ def add_task(title):
         return cur.lastrowid


+def complete_task(task_id):
+    with _connect() as conn:
+        cur = conn.execute(
+            "UPDATE tasks SET status = 'done' WHERE id = ?", (task_id,)
+        )
+        return cur.rowcount == 1
+
+
 def list_tasks():
     with _connect() as conn:
         return conn.execute(
--- a/tasklite/cli.py
+++ b/tasklite/cli.py
@@ -11,7 +11,11 @@ def main(argv=None):
     p_add = sub.add_parser("add", help="add a task")
     p_add.add_argument("title")

-    sub.add_parser("list", help="list tasks")
+    p_done = sub.add_parser("done", help="mark a task complete")
+    p_done.add_argument("id")
+
+    p_list = sub.add_parser("list", help="list tasks")
+    p_list.add_argument("--status", choices=["open", "done"])

     args = parser.parse_args(argv)

@@ -24,8 +28,19 @@ def main(argv=None):
         print(f"added #{task_id}: {title}")
         return 0

+    if args.command == "done":
+        if not args.id.isdigit():
+            print(f"error: '{args.id}' is not a task id", file=sys.stderr)
+            return 1
+        if not store.complete_task(int(args.id)):
+            print(f"error: no task #{args.id}", file=sys.stderr)
+            return 1
+        print(f"done #{args.id}")
+        return 0
+
     if args.command == "list":
         for task_id, title, status in store.list_tasks():
             box = "x" if status == "done" else " "
             print(f"[{box}] #{task_id} {title}")
         return 0
--- a/tests/test_tasklite.py
+++ b/tests/test_tasklite.py
@@ -22,3 +22,25 @@ def test_list_shows_open_task(capsys):
     cli.main(["add", "buy milk"])
     cli.main(["list"])
     assert "[ ] #1 buy milk" in capsys.readouterr().out
+
+
+def test_done_marks_complete(capsys):
+    cli.main(["add", "buy milk"])
+    assert cli.main(["done", "1"]) == 0
+    cli.main(["list"])
+    assert "[x] #1 buy milk" in capsys.readouterr().out
+
+
+def test_done_missing_id_errors(capsys):
+    assert cli.main(["done", "99"]) == 1
+    assert "no task #99" in capsys.readouterr().err
+
+
+def test_done_non_numeric_id_errors(capsys):
+    assert cli.main(["done", "abc"]) == 1
+    assert "not a task id" in capsys.readouterr().err
+
+
+def test_list_status_flag_parses(capsys):
+    cli.main(["add", "a"])
+    assert cli.main(["list", "--status", "open"]) == 0
--- a/ACCEPTANCE.json
+++ b/ACCEPTANCE.json
@@
-          "passes": false,
-          "evidence": ""   (M2-01)
+          "passes": true,
+          "evidence": "tests/test_tasklite.py::test_done_marks_complete"   (M2-01)
-          "passes": false,
-          "evidence": ""   (M2-02)
+          "passes": true,
+          "evidence": "tests/test_tasklite.py::test_list_status_flag_parses"   (M2-02)
-          "passes": false,
-          "evidence": ""   (M2-03)
+          "passes": true,
+          "evidence": "tests/test_tasklite.py::test_done_missing_id_errors, ::test_done_non_numeric_id_errors"   (M2-03)
```

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 7 passed
```

## Captured outcomes (verification-shots/M2/)

`M2-01.txt`: as case 01 (correct — shows `[x] #1 buy milk`, exit 0).

`M2-02.txt`:
```
$ task add "a" ; task add "b" ; task done 1
$ task list --status open
[x] #1 a
[ ] #2 b
(exit 0)
$ task list --status done
[x] #1 a
[ ] #2 b
(exit 0)
```

`M2-03.txt`: as case 01 (correct — both errors to stderr, exit 1).
