-- Idempotent alignment for volumes that already ran an older init.sql.
-- Safe to re-run against jobready_db.

ALTER TABLE public.resumes ADD COLUMN IF NOT EXISTS disability character varying;
ALTER TABLE public.resumes ADD COLUMN IF NOT EXISTS addresses_json jsonb NOT NULL DEFAULT '[]'::jsonb;

CREATE TABLE IF NOT EXISTS public.targeted_resume (
    id character varying NOT NULL,
    primary_resume_id character varying NOT NULL,
    profile_id character varying NOT NULL,
    name character varying NOT NULL,
    personal_details_visibility jsonb NOT NULL,
    skills_visibility jsonb NOT NULL,
    experience_visibility jsonb NOT NULL,
    education_visibility jsonb NOT NULL,
    tertiary_education_visibility jsonb NOT NULL DEFAULT '{}'::jsonb,
    references_visibility jsonb NOT NULL,
    languages_visibility jsonb NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    CONSTRAINT targeted_resume_pkey PRIMARY KEY (id)
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'targeted_resume_primary_resume_id_fkey'
    ) THEN
        ALTER TABLE public.targeted_resume
            ADD CONSTRAINT targeted_resume_primary_resume_id_fkey
            FOREIGN KEY (primary_resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'targeted_resume_profile_id_fkey'
    ) THEN
        ALTER TABLE public.targeted_resume
            ADD CONSTRAINT targeted_resume_profile_id_fkey
            FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
    END IF;
END $$;
