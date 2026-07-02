# Case 09 — outcome contradicts: tests green, screen wrong

**Planted defect:** a rendering bug the unit tests cannot see. The `list` branch compares
against `"Done"` (capital D), so completed tasks always render `[ ]`. The M2-01 test was
written against the *database state*, not the output, so the suite is green — but the
captured outcome shows the task still unchecked after `task done`. Code "passes" while
the result is wrong: the exact defect Check 8 exists to catch.
**Expected verdict:** FAIL
**Must flag:** Check 8 — `M2-01.txt` contradicts the criterion (no `[x]` after done).
(Also acceptable: Check 1 — the cited evidence doesn't prove what the criterion says the
user sees.)

## Diff

Everything in case 01's diff, with these two differences:

```diff
--- a/tasklite/cli.py  (list branch)
+++ b/tasklite/cli.py
     if args.command == "list":
         for task_id, title, status in store.list_tasks(args.status):
-            box = "x" if status == "done" else " "
+            box = "x" if status == "Done" else " "
             print(f"[{box}] #{task_id} {title}")
         return 0
--- a/tests/test_tasklite.py  (M2-01 and filter-done tests assert state, not rendering)
+++ b/tests/test_tasklite.py
+def test_done_marks_complete():
+    cli.main(["add", "buy milk"])
+    assert cli.main(["done", "1"]) == 0
+    assert store.list_tasks("done")[0][1] == "buy milk"
+
+
+def test_list_filters_done(capsys):
+    cli.main(["add", "a"])
+    cli.main(["done", "1"])
+    cli.main(["list", "--status", "done"])
+    assert "#1 a" in capsys.readouterr().out
```

(The other tests and ACCEPTANCE.json flips — M2-01 citing
`tests/test_tasklite.py::test_done_marks_complete` — as in case 01.)

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
[ ] #1 buy milk
(exit 0)
```

`M2-02.txt`:
```
$ task add "a" ; task add "b" ; task done 1
$ task list --status open
[ ] #2 b
(exit 0)
$ task list --status done
[ ] #1 a
(exit 0)
```

`M2-03.txt`: as case 01 (correct).
