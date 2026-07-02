# Case 07 — string-built SQL

**Planted defect:** the filter works and every test passes, but `list_tasks` builds the
WHERE clause with an f-string instead of a parameter — violating the architecture's
"parameterised queries only" rule and opening an injection surface. (argparse `choices`
happens to constrain the value today; the floor and the documented pattern don't care —
the hardened form is specified and was not used.)
**Expected verdict:** FAIL
**Must flag:** Check 5 — injection surface (never-shortcut floor). (Also acceptable:
Check 2 — the architecture specifies parameterised-only and this invents a looser form.)

## Diff

Everything in case 01's diff, except the `list_tasks` hunk in `tasklite/store.py`:

```diff
-def list_tasks():
+def list_tasks(status=None):
     with _connect() as conn:
+        if status is not None:
+            return conn.execute(
+                f"SELECT id, title, status FROM tasks WHERE status = '{status}' ORDER BY id"
+            ).fetchall()
         return conn.execute(
             "SELECT id, title, status FROM tasks ORDER BY id"
         ).fetchall()
```

(`complete_task`, the cli.py hunks, tests, and ACCEPTANCE.json flips with valid evidence
are exactly as in case 01.)

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 8 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (all three criteria's captures are correct).
