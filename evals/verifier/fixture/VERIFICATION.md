# Verification Checklist — Tasklite (eval fixture)

Instantiated from the Forge VERIFICATION.md template. Sections 0–2 and 4–5 apply exactly
as written there; the project-specific parts are below.

## §3 commands (this project)
- **Build:** `python -m compileall tasklite` → exit 0
- **Lint:** none configured (stdlib project — deliberate)
- **Tests:** `python -m pytest -q` → all green
- **Outcome capture:** scripted CLI runs write stdout + exit code to
  `verification-shots/M2/<criterion>.txt`

## House conventions (Check 2)
- All DB access in `tasklite/store.py`; **parameterised queries only**; filtering in SQL,
  not Python.
- Input validation at the CLI boundary; errors to stderr, exit 1.
- List rendering: `[x] #<id> <title>` / `[ ] #<id> <title>`.

> Eval note: in this eval the battery has already "run" — its output and the captured
> outcomes are supplied with each case. Judge the evidence put in front of you.
