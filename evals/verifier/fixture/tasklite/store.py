import sqlite3

DB_PATH = "tasklite.db"


def _connect():
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "CREATE TABLE IF NOT EXISTS tasks ("
        " id INTEGER PRIMARY KEY,"
        " title TEXT NOT NULL,"
        " status TEXT NOT NULL DEFAULT 'open'"
        " CHECK (status IN ('open', 'done')))"
    )
    return conn


def add_task(title):
    with _connect() as conn:
        cur = conn.execute("INSERT INTO tasks (title) VALUES (?)", (title,))
        return cur.lastrowid


def list_tasks():
    with _connect() as conn:
        return conn.execute(
            "SELECT id, title, status FROM tasks ORDER BY id"
        ).fetchall()
