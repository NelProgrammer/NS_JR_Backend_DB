"""Build demo CSVs. Does not open Postgres."""

from __future__ import annotations

import csv
import json
from pathlib import Path

CSV_DIR = Path(__file__).resolve().parent / "csv"
PASSWORD = "SeedPass1!"
LAST_MODIFIED = 1710000000000


def alice_master() -> dict:
    return {
        "personal details": {
            "names": {"firstName": "Alice", "Surname": "Mokoena"},
            "contact": {"Email": "alice.seed@jobready.dev", "Cell": "0820000001"},
            "address": {"city": "Cape Town"},
            "licensing": {"Drivers": "C1"},
            "languages": [
                {"id": "lang_a1", "Language": "English", "proficiency": "Native", "visible": True},
                {"id": "lang_a2", "Language": "isiXhosa", "proficiency": "Fluent", "visible": True},
            ],
        },
        "professional summary": "Seeded through Job 2, not init.sql.",
        "Skills": {"Tech": [{"id": "sk_a1", "name": "Python", "visible": True}]},
        "experience": [
            {
                "id": "exp_a1",
                "Organization": "Acme Solutions",
                "Role": "Lead Architect",
                "Start Date": "2020-01-01",
                "End Date": "2021-12-31",
                "Key Responsibilities": "Designed cloud backend architecture.",
            }
        ],
        "education": {
            "highschool": {"Highest Grade Passed": "Grade 12", "visible": True},
            "tertiary": [
                {
                    "id": "edu_a1",
                    "Institution": "University of Cape Town",
                    "Qualification Name": "B.Sc. Computer Science",
                    "Year": "2018-12-01",
                    "Completed": True,
                    "Key Modules": ["Data Structures"],
                }
            ],
        },
        "References": [
            {
                "id": "ref_a1",
                "name": "John Doe",
                "org": "Acme Solutions",
                "relation": "VP of Engineering",
                "email": "john.doe@example.com",
            }
        ],
        "Document Settings": {"Layout": "professional", "ExportFormat": "pdf"},
    }


def alice_targeted() -> dict:
    payload = alice_master()
    payload["is_primary"] = False
    payload["experience"][0]["visible"] = True
    payload["References"][0]["visible"] = False
    payload["education"]["tertiary"][0]["visible"] = True
    return payload


def bob_sparse() -> dict:
    return {
        "personal details": {
            "names": {"firstName": "Bob", "Surname": "Naidoo"},
            "contact": {"Email": "bob.seed@jobready.dev"},
        },
        "professional summary": "",
        "Skills": {},
        "experience": [],
        "education": {"highschool": {}, "tertiary": []},
        "References": [],
        "Document Settings": {"Layout": "modern", "ExportFormat": "pdf"},
    }


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    CSV_DIR.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def generate() -> Path:
    write_csv(
        CSV_DIR / "accounts.csv",
        ["email", "password", "name"],
        [
            {"email": "alice.seed@jobready.dev", "password": PASSWORD, "name": "Alice Seed"},
            {"email": "bob.seed@jobready.dev", "password": PASSWORD, "name": "Bob Seed"},
        ],
    )
    write_csv(
        CSV_DIR / "resumes.csv",
        ["email", "id", "name", "is_primary", "last_modified", "data_json"],
        [
            {
                "email": "alice.seed@jobready.dev",
                "id": "resume_alice_seed",
                "name": "Alice Master CV",
                "is_primary": "true",
                "last_modified": str(LAST_MODIFIED),
                "data_json": json.dumps(alice_master()),
            },
            {
                "email": "alice.seed@jobready.dev",
                "id": "resume_alice_target",
                "name": "Alice Targeted CV",
                "is_primary": "false",
                "last_modified": str(LAST_MODIFIED + 50),
                "data_json": json.dumps(alice_targeted()),
            },
            {
                "email": "bob.seed@jobready.dev",
                "id": "resume_bob_seed",
                "name": "Bob Sparse CV",
                "is_primary": "true",
                "last_modified": str(LAST_MODIFIED + 10),
                "data_json": json.dumps(bob_sparse()),
            },
        ],
    )
    write_csv(
        CSV_DIR / "ui_settings.csv",
        ["email", "resume_id", "last_modified", "payload_json"],
        [
            {
                "email": "alice.seed@jobready.dev",
                "resume_id": "resume_alice_seed",
                "last_modified": str(LAST_MODIFIED + 20),
                "payload_json": json.dumps(
                    {
                        "layout": "professional",
                        "personal_details_settings": {"address_format": "bullet"},
                        "skills_settings": {"tech_format": "bullet"},
                        "experience_settings": {"format": "bullet"},
                        "education_settings": {"format": "bullet"},
                        "tertiary_education_settings": {"format": "bullet"},
                        "references_settings": {"format": "bullet"},
                        "languages_settings": {"format": "bullet"},
                        "placeholders": {},
                    }
                ),
            }
        ],
    )
    print(f"[seed] wrote CSVs in {CSV_DIR}")
    return CSV_DIR


if __name__ == "__main__":
    generate()
