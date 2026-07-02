# Case 02 — marked debt

**Planted defect:** none functional — identical to case 01, plus one deliberate,
`forge-debt:`-marked shortcut. A marked shortcut is a decision log entry, not hidden debt.
**Expected verdict:** PASS-WITH-NOTES
**Must flag:** Check 7 — the one `forge-debt:` marker collected into the ledger
(severity low). Not a FAIL; not silence either.

## Diff

Identical to case 01's diff in every hunk, except the `list` branch in `tasklite/cli.py`
gains a marker line:

```diff
     if args.command == "list":
+        # forge-debt: list loads every row; no pagination — fine for personal task volumes
         for task_id, title, status in store.list_tasks(args.status):
             box = "x" if status == "done" else " "
             print(f"[{box}] #{task_id} {title}")
         return 0
```

All other hunks (store.py, tests, ACCEPTANCE.json flips with evidence) are exactly as in
case 01. The runner supplies case 01's diff with this hunk substituted.

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 8 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (all three match their criteria).
