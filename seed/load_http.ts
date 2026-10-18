import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const CSV_DIR = join(dirname(fileURLToPath(import.meta.url)), "csv");
const DEFAULTS = [process.env.JOBREADY_API?.replace(/\/$/, "") || "", "http://127.0.0.1:3000", "http://127.0.0.1:8000"].filter(
  Boolean,
);

type Json = Record<string, unknown>;

async function request(url: string, method: string, body?: unknown, token?: string): Promise<{ status: number; payload: unknown }> {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (token) headers.Authorization = `Bearer ${token}`;
  const resp = await fetch(url, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const raw = await resp.text();
  let payload: unknown = raw;
  try {
    payload = raw ? JSON.parse(raw) : {};
  } catch {
    payload = raw;
  }
  return { status: resp.status, payload };
}

function readCsv(name: string): Array<Record<string, string>> {
  const path = join(CSV_DIR, name);
  const text = readFileSync(path, "utf8").trim();
  const [headerLine, ...lines] = text.split(/\r?\n/);
  const headers = parseCsvLine(headerLine);
  return lines.filter(Boolean).map((line) => {
    const values = parseCsvLine(line);
    const row: Record<string, string> = {};
    headers.forEach((key, index) => {
      row[key] = values[index] ?? "";
    });
    return row;
  });
}

function parseCsvLine(line: string): string[] {
  const out: string[] = [];
  let current = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"' && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else if (ch === '"') {
        inQuotes = false;
      } else {
        current += ch;
      }
    } else if (ch === '"') {
      inQuotes = true;
    } else if (ch === ",") {
      out.push(current);
      current = "";
    } else {
      current += ch;
    }
  }
  out.push(current);
  return out;
}

async function pickApi(): Promise<string> {
  const tried: string[] = [];
  for (const base of DEFAULTS) {
    tried.push(base);
    try {
      const { status, payload } = await request(`${base}/health`, "GET");
      if (status === 200 && payload && typeof payload === "object" && (payload as Json).database_connected) {
        const runtime = (payload as Json).runtime || (payload as Json).version;
        console.log(`[seed] using Job 2 at ${base} (${runtime})`);
        return base;
      }
    } catch {
      // try next
    }
  }
  throw new Error(`No Job 2 API with a live warehouse. Tried: ${tried.join(", ")}`);
}

async function ensureAccount(api: string, email: string, password: string, name: string): Promise<Json> {
  let { status, payload } = await request(`${api}/auth/signup`, "POST", { email, password, name });
  if (status === 200 && payload && typeof payload === "object" && (payload as Json).access_token) {
    return payload as Json;
  }
  ({ status, payload } = await request(`${api}/auth/login`, "POST", { email, password }));
  if (status === 200 && payload && typeof payload === "object" && (payload as Json).access_token) {
    return payload as Json;
  }
  throw new Error(`Could not sign up or log in ${email}: ${status} ${JSON.stringify(payload)}`);
}

export async function load(apiUrl?: string): Promise<void> {
  const api = apiUrl || (await pickApi());
  const accounts: Record<string, Json> = {};
  for (const row of readCsv("accounts.csv")) {
    accounts[row.email] = await ensureAccount(api, row.email, row.password, row.name);
  }

  const grouped = new Map<string, Json[]>();
  for (const row of readCsv("resumes.csv")) {
    const account = accounts[row.email];
    const item = {
      id: row.id,
      profile_id: account.profile_id,
      name: row.name,
      is_primary: row.is_primary.trim().toLowerCase() === "true",
      last_modified: Number(row.last_modified),
      data_json: JSON.parse(row.data_json),
    };
    const list = grouped.get(row.email) || [];
    list.push(item);
    grouped.set(row.email, list);
  }

  for (const [email, items] of grouped) {
    items.sort((a, b) => Number(Boolean(b.is_primary)) - Number(Boolean(a.is_primary)));
    const token = String(accounts[email].access_token);
    const { status, payload } = await request(`${api}/sync/push`, "POST", { items }, token);
    if (status !== 200) throw new Error(`/sync/push failed for ${email}: ${status} ${JSON.stringify(payload)}`);
    console.log(`[seed] resumes ${email}:`, payload);
  }

  for (const row of readCsv("ui_settings.csv")) {
    const account = accounts[row.email];
    const body = {
      ...(JSON.parse(row.payload_json) as Json),
      resume_id: row.resume_id,
      profile_id: account.profile_id,
      last_modified: Number(row.last_modified),
    };
    const { status, payload } = await request(
      `${api}/sync/ui_settings/push`,
      "POST",
      { items: [body] },
      String(account.access_token),
    );
    if (status !== 200) {
      throw new Error(`/sync/ui_settings/push failed for ${row.email}: ${status} ${JSON.stringify(payload)}`);
    }
    console.log(`[seed] ui_settings ${row.email}:`, payload);
  }
}

const invoked = process.argv[1]?.replaceAll("\\", "/").endsWith("load_http.ts");
if (invoked) {
  load(process.argv[2]).catch((err) => {
    console.error(err instanceof Error ? err.message : err);
    process.exit(1);
  });
}
