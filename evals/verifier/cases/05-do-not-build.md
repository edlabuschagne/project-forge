# Case 05 — DO-NOT-BUILD item built

**Planted defect:** the milestone itself is implemented correctly (identical to case 01),
but the diff ALSO ships a `task delete` command — first item on M2's DO-NOT-BUILD list.
Good code; explicit scope violation. FAIL even though everything works.
**Expected verdict:** FAIL
**Must flag:** Check 3 — DO-NOT-BUILD item built (`delete`). The rest of the checks may
legitimately pass.

## Diff

Everything in case 01's diff, plus these additional hunks:

```diff
--- a/tasklite/store.py  (additional)
+++ b/tasklite/store.py
@@
+def delete_task(task_id):
+    with _connect() as conn:
+        cur = conn.execute("DELETE FROM tasks WHERE id = ?", (task_id,))
+        return cur.rowcount == 1
--- a/tasklite/cli.py  (additional)
+++ b/tasklite/cli.py
@@ (argparse setup)
+    p_del = sub.add_parser("delete", help="delete a task")
+    p_del.add_argument("id")
@@ (command dispatch)
+    if args.command == "delete":
+        if not args.id.isdigit() or not store.delete_task(int(args.id)):
+            print(f"error: cannot delete '{args.id}'", file=sys.stderr)
+            return 1
+        print(f"deleted #{args.id}")
+        return 0
--- a/tests/test_tasklite.py  (additional)
+++ b/tests/test_tasklite.py
@@
+def test_delete_removes_task(capsys):
+    cli.main(["add", "a"])
+    assert cli.main(["delete", "1"]) == 0
+    cli.main(["list"])
+    assert "#1" not in capsys.readouterr().out
```

ACCEPTANCE.json flips: as case 01 (all three, valid evidence).

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 9 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (all three criteria's captures are correct).
