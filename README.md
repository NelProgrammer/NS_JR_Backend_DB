# NeltzSocial JobReady - Standalone PostgreSQL Database Engine (`NS_JR_Backend_DB`)

This project houses the standalone PostgreSQL database container definitions, environment configuration, and DDL schema initialization scripts for JobReady applications.

It is completely decoupled from any specific middleware API stack (Python, Node.js, Go, etc.).

---

## 🚀 Quick Start

### 1. Build and Launch the Database Container

Run the following command inside this directory (`NS_JR_Backend_DB`):

```bash
docker compose up --build -d
```

This will:
1. Build the custom PostgreSQL image (`jobready_postgres_db:latest`) based on `postgres:15-alpine`.
2. Automatically execute `init.sql` on first startup to initialize application tables and demo seed rows.
3. Expose PostgreSQL on `localhost:5432`.

---

## 🛠️ Environment Credentials

Default configuration (customizable in `.env`):

| Variable | Default Value |
| :--- | :--- |
| **`POSTGRES_USER`** | `postgres` |
| **`POSTGRES_PASSWORD`** | `postgrespassword` |
| **`POSTGRES_DB`** | `jobready_db` |
| **`POSTGRES_PORT`** | `5432` |

Connection String:
```text
postgresql://postgres:postgrespassword@localhost:5432/jobready_db
```

---

## 📋 Database Tables

- `users`: Authentication credentials
- `profiles`: User profiles & social OAuth links
- `resumes`: Master CV (includes `disability`, `addresses_json`)
- `resume_work_experiences`: Employment history items
- `resume_education_tertiary`: Tertiary academic qualifications (`date_obtained`)
- `resume_education_professional_certifications`: Professional credentials
- `resume_references`: Professional & character references
- `targeted_resume`: Targeted derivative CV visibility overlays
- `candidate_index`: Recruiter query search index
- `resume_ui_settings`: Section-partitioned UI preferences
- `resume_timestamps`: Field-level sync clocks
- `recruitment_shares`: Privacy & recruiter sharing controls

Existing volumes (init.sql already ran) can apply `migrate_live.sql` with:

```bash
docker exec -i jobready_postgres_db psql -U postgres -d jobready_db < migrate_live.sql
```

---

## 🔍 Useful Management Commands

### Check Container Status
```bash
docker ps --filter "name=jobready_postgres_db"
```

### Inspect Database Tables via CLI
```bash
docker exec -it jobready_postgres_db psql -U postgres -d jobready_db -c "\dt"
```

### Stop Database Service
```bash
docker compose down
```
