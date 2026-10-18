"""Load seed CSVs through whichever Job 2 API is running. Does not open Postgres."""

from __future__ import annotations

import csv
import json
import os
import sys
import urllib.error
import urllib.request
from collections import defaultdict
from pathlib import Path

CSV_DIR = Path(__file__).resolve().parent / "csv"
DEFAULTS = [
    os.getenv("JOBREADY_API", "").rstrip("/"),
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
]


def _request(url: str, method: str, body: dict | None = None, token: str | None = None) -> tuple[int, dict | list | str]:
    data = None if body is None else json.dumps(body).encode("utf-8")
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            raw = resp.read().decode("utf-8")
            return resp.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as err:
        raw = err.read().decode("utf-8")
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = raw
        return err.code, parsed


def _read_csv(name: str) -> list[dict[str, str]]:
    path = CSV_DIR / name
    if not path.exists():
        raise SystemExit(f"Missing {path}. Run generate.py first.")
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def pick_api() -> str:
    tried = []
    for base in DEFAULTS:
        if not base:
            continue
        tried.append(base)
        status, payload = _request(f"{base}/health", "GET")
        if status == 200 and isinstance(payload, dict) and payload.get("database_connected"):
            runtime = payload.get("runtime") or payload.get("version")
            print(f"[seed] using Job 2 at {base} ({runtime})")
            return base
    raise SystemExit(
        "No Job 2 API with a live database. Start Python (:8000) or Node (:3000), then retry. Tried: "
        + ", ".join(tried)
    )


def ensure_account(api: str, email: str, password: str, name: str) -> dict:
    status, payload = _request(
        f"{api}/auth/signup",
        "POST",
        {"email": email, "password": password, "name": name},
    )
    if status == 200 and isinstance(payload, dict) and payload.get("access_token"):
        return payload
    status, payload = _request(f"{api}/auth/login", "POST", {"email": email, "password": password})
    if status == 200 and isinstance(payload, dict) and payload.get("access_token"):
        return payload
    raise SystemExit(f"Could not sign up or log in {email}: {status} {payload}")


def load(api: str | None = None) -> None:
    api = api or pick_api()
    accounts = {row["email"]: ensure_account(api, row["email"], row["password"], row["name"]) for row in _read_csv("accounts.csv")}

    grouped: dict[str, list[dict]] = defaultdict(list)
    for row in _read_csv("resumes.csv"):
        account = accounts[row["email"]]
        item = {
            "id": row["id"],
            "profile_id": account["profile_id"],
            "name": row["name"],
            "is_primary": row["is_primary"].strip().lower() == "true",
            "last_modified": float(row["last_modified"]),
            "data_json": json.loads(row["data_json"]),
        }
        grouped[row["email"]].append(item)

    for email, items in grouped.items():
        token = accounts[email]["access_token"]
        items.sort(key=lambda item: (not item["is_primary"], item["id"]))
        status, payload = _request(f"{api}/sync/push", "POST", {"items": items}, token=token)
        if status != 200:
            raise SystemExit(f"/sync/push failed for {email}: {status} {payload}")
        print(f"[seed] resumes {email}: {payload}")

    for row in _read_csv("ui_settings.csv"):
        account = accounts[row["email"]]
        body = json.loads(row["payload_json"])
        body.update(
            {
                "resume_id": row["resume_id"],
                "profile_id": account["profile_id"],
                "last_modified": float(row["last_modified"]),
            }
        )
        status, payload = _request(
            f"{api}/sync/ui_settings/push",
            "POST",
            {"items": [body]},
            token=account["access_token"],
        )
        if status != 200:
            raise SystemExit(f"/sync/ui_settings/push failed for {row['email']}: {status} {payload}")
        print(f"[seed] ui_settings {row['email']}: {payload}")


if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else None
    load(url)
