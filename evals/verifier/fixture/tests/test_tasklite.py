import pytest

from tasklite import cli, store


@pytest.fixture(autouse=True)
def tmp_db(tmp_path, monkeypatch):
    monkeypatch.setattr(store, "DB_PATH", str(tmp_path / "test.db"))


def test_add_returns_id():
    assert store.add_task("write tests") == 1


def test_add_empty_title_rejected(capsys):
    assert cli.main(["add", "   "]) == 1
    assert "title cannot be empty" in capsys.readouterr().err


def test_list_shows_open_task(capsys):
    cli.main(["add", "buy milk"])
    cli.main(["list"])
    assert "[ ] #1 buy milk" in capsys.readouterr().out
