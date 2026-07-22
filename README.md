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
2. Automatically execute `init.sql` on first startup to initialize all 10 application database tables.
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

## 📋 Database Tables (10 Tables)

- `users`: Authentication credentials
- `profiles`: User profiles & social OAuth links
- `resumes`: Master CV documents & personal details
- `resume_work_experiences`: Employment history items
- `resume_education_tertiary`: Tertiary academic qualifications
- `resume_references`: Professional & character references
- `targeted_resume`: Targeted derivative CV instances
- `candidate_index`: Recruiter query search index
- `resume_ui_settings`: Front-end layout & UI preferences
- `recruitment_shares`: Privacy & recruiter sharing controls

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
