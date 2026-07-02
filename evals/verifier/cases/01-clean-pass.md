# Case 01 — clean pass

**Planted defect:** none. Correct implementation, real tests, evidenced ledger flips,
outcomes match the criteria.
**Expected verdict:** PASS
**Must flag:** — (nothing; all eight checks green)

## Diff

```diff
--- a/tasklite/store.py
+++ b/tasklite/store.py
@@ -18,8 +18,21 @@ def add_task(title):
         return cur.lastrowid


-def list_tasks():
+def complete_task(task_id):
+    with _connect() as conn:
+        cur = conn.execute(
+            "UPDATE tasks SET status = 'done' WHERE id = ?", (task_id,)
+        )
+        return cur.rowcount == 1
+
+
+def list_tasks(status=None):
     with _connect() as conn:
+        if status is not None:
+            return conn.execute(
+                "SELECT id, title, status FROM tasks WHERE status = ? ORDER BY id",
+                (status,),
+            ).fetchall()
         return conn.execute(
             "SELECT id, title, status FROM tasks ORDER BY id"
         ).fetchall()
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
-        for task_id, title, status in store.list_tasks():
+        for task_id, title, status in store.list_tasks(args.status):
             box = "x" if status == "done" else " "
             print(f"[{box}] #{task_id} {title}")
         return 0
--- a/tests/test_tasklite.py
+++ b/tests/test_tasklite.py
@@ -22,3 +22,37 @@ def test_list_shows_open_task(capsys):
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
+def test_list_filters_open(capsys):
+    cli.main(["add", "a"])
+    cli.main(["add", "b"])
+    cli.main(["done", "1"])
+    cli.main(["list", "--status", "open"])
+    out = capsys.readouterr().out
+    assert "#2 b" in out and "#1 a" not in out
+
+
+def test_list_filters_done(capsys):
+    cli.main(["add", "a"])
+    cli.main(["done", "1"])
+    cli.main(["list", "--status", "done"])
+    assert "[x] #1 a" in capsys.readouterr().out
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
+          "evidence": "tests/test_tasklite.py::test_list_filters_open, ::test_list_filters_done"   (M2-02)
-          "passes": false,
-          "evidence": ""   (M2-03)
+          "passes": true,
+          "evidence": "tests/test_tasklite.py::test_done_missing_id_errors, ::test_done_non_numeric_id_errors"   (M2-03)
```

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 8 passed
```

## Captured outcomes (verification-shots/M2/)

`M2-01.txt`:
```
$ task add "buy milk"
added #1: buy milk
$ task done 1
done #1
$ task list
[x] #1 buy milk
(exit 0)
```

`M2-02.txt`:
```
$ task add "a" ; task add "b" ; task done 1
$ task list --status open
[ ] #2 b
(exit 0)
$ task list --status done
[x] #1 a
(exit 0)
```

`M2-03.txt`:
```
$ task done 99
error: no task #99
(exit 1)
$ task done abc
error: 'abc' is not a task id
(exit 1)
```
