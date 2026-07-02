# Case 06 — regression: M1 validation dropped, its test deleted

**Planted defect:** M2 itself is implemented correctly (as case 01), but the diff
"tidies" the `add` branch while passing through — deleting the empty-title validation
that M1 delivered, AND deleting the test that guarded it. The suite is green because the
witness was removed. A previously-passing criterion is broken; existing validation was
weakened.
**Expected verdict:** FAIL
**Must flag:** Check 4 — regression (M1's validated `add` broken; a prior test deleted).
(Also acceptable: Check 5 — input validation is never-lean-able.)

## Diff

Everything in case 01's diff, with these differences:

```diff
--- a/tasklite/cli.py  (add branch — replaces the untouched case-01 version)
+++ b/tasklite/cli.py
@@ -18,12 +22,8 @@ def main(argv=None):
     if args.command == "add":
-        title = args.title.strip()
-        if not title:
-            print("error: title cannot be empty", file=sys.stderr)
-            return 1
-        task_id = store.add_task(title)
-        print(f"added #{task_id}: {title}")
+        task_id = store.add_task(args.title)
+        print(f"added #{task_id}: {args.title}")
         return 0
--- a/tests/test_tasklite.py  (additional to case 01's added tests)
+++ b/tests/test_tasklite.py
@@ -12,11 +12,6 @@ def test_add_returns_id():
     assert store.add_task("write tests") == 1


-def test_add_empty_title_rejected(capsys):
-    assert cli.main(["add", "   "]) == 1
-    assert "title cannot be empty" in capsys.readouterr().err
-
-
 def test_list_shows_open_task(capsys):
```

ACCEPTANCE.json flips: as case 01 (all three, valid evidence — the M2 criteria really
are met).

## Battery output (§3, provided as the run)

```
python -m compileall tasklite  -> exit 0
python -m pytest -q            -> 7 passed
```

## Captured outcomes (verification-shots/M2/)

Identical to case 01 (the M2 captures are all correct — the damage is to M1).
