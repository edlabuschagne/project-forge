import argparse
import sys

from tasklite import store


def main(argv=None):
    parser = argparse.ArgumentParser(prog="task")
    sub = parser.add_subparsers(dest="command", required=True)

    p_add = sub.add_parser("add", help="add a task")
    p_add.add_argument("title")

    sub.add_parser("list", help="list tasks")

    args = parser.parse_args(argv)

    if args.command == "add":
        title = args.title.strip()
        if not title:
            print("error: title cannot be empty", file=sys.stderr)
            return 1
        task_id = store.add_task(title)
        print(f"added #{task_id}: {title}")
        return 0

    if args.command == "list":
        for task_id, title, status in store.list_tasks():
            box = "x" if status == "done" else " "
            print(f"[{box}] #{task_id} {title}")
        return 0


if __name__ == "__main__":
    sys.exit(main())
