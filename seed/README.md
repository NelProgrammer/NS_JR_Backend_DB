# Dev/test seed (Job 2 only)

This folder does not own the warehouse and is not part of API boot.

1. Generate CSVs (no database):
   - `python generate.py`
   - or from Node: `npm run seed:generate` in `NS_JR_Backend_Node`
2. Load through the live middleware (`POST /auth/signup` or login, `POST /sync/push`, `POST /sync/ui_settings/push`):
   - `python load_http.py`
   - or `npm run seed:load`

Point `JOBREADY_API` at whichever backend is up (`http://127.0.0.1:3000` for Node, `http://127.0.0.1:8000` for Python). If unset, the loader probes both and uses the first `/health` that reports `database_connected` (warehouse tables present, not only `SELECT 1`).

`init.sql` must not insert demo rows. Schema is Job 1; rows are Job 2.
