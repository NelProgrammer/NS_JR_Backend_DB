import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const CSV_DIR = join(dirname(fileURLToPath(import.meta.url)), "csv");
const PASSWORD = "SeedPass1!";
const LAST_MODIFIED = 1710000000000;

function aliceMaster() {
  return {
    "personal details": {
      names: { firstName: "Alice", Surname: "Mokoena" },
      contact: { Email: "alice.seed@jobready.dev", Cell: "0820000001" },
      address: { city: "Cape Town" },
      licensing: { Drivers: "C1" },
      languages: [
        { id: "lang_a1", Language: "English", proficiency: "Native", visible: true },
        { id: "lang_a2", Language: "isiXhosa", proficiency: "Fluent", visible: true },
      ],
    },
    "professional summary": "Seeded through Job 2, not init.sql.",
    Skills: { Tech: [{ id: "sk_a1", name: "Python", visible: true }] },
    experience: [
      {
        id: "exp_a1",
        Organization: "Acme Solutions",
        Role: "Lead Architect",
        "Start Date": "2020-01-01",
        "End Date": "2021-12-31",
        "Key Responsibilities": "Designed cloud backend architecture.",
      },
    ],
    education: {
      highschool: { "Highest Grade Passed": "Grade 12", visible: true },
      tertiary: [
        {
          id: "edu_a1",
          Institution: "University of Cape Town",
          "Qualification Name": "B.Sc. Computer Science",
          Year: "2018-12-01",
          Completed: true,
          "Key Modules": ["Data Structures"],
        },
      ],
    },
    References: [
      {
        id: "ref_a1",
        name: "John Doe",
        org: "Acme Solutions",
        relation: "VP of Engineering",
        email: "john.doe@example.com",
      },
    ],
    "Document Settings": { Layout: "professional", ExportFormat: "pdf" },
  };
}

function aliceTargeted() {
  const payload = aliceMaster() as ReturnType<typeof aliceMaster> & { is_primary?: boolean };
  payload.is_primary = false;
  payload.experience[0] = { ...payload.experience[0], visible: true };
  payload.References[0] = { ...payload.References[0], visible: false };
  payload.education.tertiary[0] = { ...payload.education.tertiary[0], visible: true };
  return payload;
}

function bobSparse() {
  return {
    "personal details": {
      names: { firstName: "Bob", Surname: "Naidoo" },
      contact: { Email: "bob.seed@jobready.dev" },
    },
    "professional summary": "",
    Skills: {},
    experience: [],
    education: { highschool: {}, tertiary: [] },
    References: [],
    "Document Settings": { Layout: "modern", ExportFormat: "pdf" },
  };
}

function csvEscape(value: string): string {
  if (/[",\n]/.test(value)) return `"${value.replaceAll('"', '""')}"`;
  return value;
}

function writeCsv(path: string, fieldnames: string[], rows: Array<Record<string, string>>): void {
  mkdirSync(CSV_DIR, { recursive: true });
  const lines = [
    fieldnames.join(","),
    ...rows.map((row) => fieldnames.map((name) => csvEscape(row[name] ?? "")).join(",")),
  ];
  writeFileSync(path, `${lines.join("\n")}\n`, "utf8");
}

export function generate(): string {
  writeCsv(join(CSV_DIR, "accounts.csv"), ["email", "password", "name"], [
    { email: "alice.seed@jobready.dev", password: PASSWORD, name: "Alice Seed" },
    { email: "bob.seed@jobready.dev", password: PASSWORD, name: "Bob Seed" },
  ]);
  writeCsv(join(CSV_DIR, "resumes.csv"), ["email", "id", "name", "is_primary", "last_modified", "data_json"], [
    {
      email: "alice.seed@jobready.dev",
      id: "resume_alice_seed",
      name: "Alice Master CV",
      is_primary: "true",
      last_modified: String(LAST_MODIFIED),
      data_json: JSON.stringify(aliceMaster()),
    },
    {
      email: "alice.seed@jobready.dev",
      id: "resume_alice_target",
      name: "Alice Targeted CV",
      is_primary: "false",
      last_modified: String(LAST_MODIFIED + 50),
      data_json: JSON.stringify(aliceTargeted()),
    },
    {
      email: "bob.seed@jobready.dev",
      id: "resume_bob_seed",
      name: "Bob Sparse CV",
      is_primary: "true",
      last_modified: String(LAST_MODIFIED + 10),
      data_json: JSON.stringify(bobSparse()),
    },
  ]);
  writeCsv(join(CSV_DIR, "ui_settings.csv"), ["email", "resume_id", "last_modified", "payload_json"], [
    {
      email: "alice.seed@jobready.dev",
      resume_id: "resume_alice_seed",
      last_modified: String(LAST_MODIFIED + 20),
      payload_json: JSON.stringify({
        layout: "professional",
        personal_details_settings: { address_format: "bullet" },
        skills_settings: { tech_format: "bullet" },
        experience_settings: { format: "bullet" },
        education_settings: { format: "bullet" },
        tertiary_education_settings: { format: "bullet" },
        references_settings: { format: "bullet" },
        languages_settings: { format: "bullet" },
        placeholders: {},
      }),
    },
  ]);
  console.log(`[seed] wrote CSVs in ${CSV_DIR}`);
  return CSV_DIR;
}

if (process.argv[1]?.replaceAll("\\", "/").endsWith("generate.ts")) {
  generate();
}
