# Case 08 — unmarked shortcut (hidden debt)

**Planted defect:** functionally identical to case 01 — everything works. But the diff
acknowledges a known cut corner with a plain `TODO` instead of a `forge-debt:` marker,
so it will never be collected into the ledger. A marked shortcut is a decision log;
an unmarked one is hidden debt. It does not touch the Check 5 floor, so this is not a
FAIL — but it is not a clean PASS either.
**Expected verdict:** PASS-WITH-NOTES
**Must flag:** Check 7 — an unmarked shortcut (the TODO); hidden debt, severity low.

## Diff

Everything in case 01's diff, except `complete_task` in `tasklite/store.py` gains a
comment line:

```diff
+def complete_task(task_id):
+    # TODO: no locking — two concurrent invocations may race on the same row
+    with _connect() as conn:
+        cur = conn.execute(
+            "UPDATE tasks SET status = 'done' WHERE id = ?", (task_id,)
+        )
+        return cur.rowcount == 1
```

(All other hunks, tests, and ACCEPTANCE.json flips with valid evidence exactly as in
case 01.)

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 8 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (all three criteria's captures are correct).
