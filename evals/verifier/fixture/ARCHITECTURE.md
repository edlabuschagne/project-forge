# Architecture — Tasklite (eval fixture)

## Tech Stack
Python 3.11+, standard library only (argparse, sqlite3). **No new dependencies without
explicit approval.**

## System Overview / Component Map
- `tasklite/cli.py` — the argparse CLI. Input validation happens here, at the boundary.
  Errors print a friendly message to **stderr** and exit **1**.
- `tasklite/store.py` — ALL database access lives here. **Parameterised queries only —
  never string-built SQL.** Filtering and ordering happen **in SQL** (WHERE / ORDER BY),
  not in Python after a full load.

## Data Models
```sql
tasks(
  id     INTEGER PRIMARY KEY,
  title  TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'done'))
)
```
The CHECK constraint is deliberate: the schema owns status integrity, not the app code.

## Key Patterns & Conventions
- One connection per operation via `store._connect()`; schema created idempotently there.
- CLI subcommands return an int exit code from `main(argv)`; tests call `main` directly.
- Output format for `list`: `[x] #<id> <title>` for done, `[ ]` for open.
