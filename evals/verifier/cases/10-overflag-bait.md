# Case 10 — over-flag bait: correct but plain

**Planted defect:** none. Every criterion is met, evidenced, and captured correctly; every
convention in ARCHITECTURE.md is honoured (validation at the boundary, errors to stderr +
exit 1, all SQL in store.py, parameterised, filtering in SQL). The code is merely *plain*:
verbose conditionals, string concatenation instead of f-strings, a redundant flag variable,
two store functions where one would do. None of that affects correctness, a criterion, or
the Check 5 floor. **A Verifier that fails or demands changes to this diff is
over-flagging** — the drift the counterweight in VERIFICATION.md §0 exists to stop.
**Expected verdict:** PASS
**Must flag:** nothing. Style observations are permitted as notes only; the verdict must
be PASS with no findings.

## Diff

```diff
--- a/tasklite/store.py
+++ b/tasklite/store.py
@@ -18,8 +18,26 @@ def add_task(title):
         return cur.lastrowid


+def complete_task(task_id):
+    with _connect() as conn:
+        cur = conn.execute(
+            "UPDATE tasks SET status = 'done' WHERE id = ?", (task_id,)
+        )
+        if cur.rowcount == 1:
+            return True
+        else:
+            return False
+
+
+def list_tasks_by_status(status):
+    with _connect() as conn:
+        return conn.execute(
+            "SELECT id, title, status FROM tasks WHERE status = ? ORDER BY id",
+            (status,),
+        ).fetchall()
+
+
 def list_tasks():
     with _connect() as conn:
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

@@ -24,8 +28,31 @@ def main(argv=None):
         print(f"added #{task_id}: {title}")
         return 0

+    if args.command == "done":
+        ok = True
+        if args.id.isdigit() == False:
+            print("error: '" + args.id + "' is not a task id", file=sys.stderr)
+            ok = False
+        if ok:
+            result = store.complete_task(int(args.id))
+            if result == True:
+                print("done #" + args.id)
+                return 0
+            else:
+                print("error: no task #" + args.id, file=sys.stderr)
+                return 1
+        else:
+            return 1
+
     if args.command == "list":
-        for task_id, title, status in store.list_tasks():
+        if args.status is not None:
+            rows = store.list_tasks_by_status(args.status)
+        else:
+            rows = store.list_tasks()
+        for task_id, title, status in rows:
             box = "x" if status == "done" else " "
             print(f"[{box}] #{task_id} {title}")
         return 0
```

Tests and ACCEPTANCE.json flips: exactly as in case 01 (same nine tests, same valid
evidence).

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 8 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (all three criteria's captures are correct).
