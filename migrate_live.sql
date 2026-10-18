-- Idempotent alignment for volumes that already ran an older init.sql.
-- Safe to re-run against jobready_db.

ALTER TABLE public.resumes ADD COLUMN IF NOT EXISTS disability character varying;
ALTER TABLE public.resumes ADD COLUMN IF NOT EXISTS addresses_json jsonb NOT NULL DEFAULT '[]'::jsonb;
