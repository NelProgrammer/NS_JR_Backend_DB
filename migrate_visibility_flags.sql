-- ============================================================================
-- MIGRATION: mod6-visibility-flags-schema
-- Adds config_type column to targeted_resume and updates JSONB column defaults.
-- Safe to run on a live database (all changes are additive / non-destructive).
-- ============================================================================

-- 1. Add config_type column (defaults to 'targeted' for all existing rows)
ALTER TABLE public.targeted_resume
    ADD COLUMN IF NOT EXISTS config_type character varying(16) NOT NULL DEFAULT 'targeted';

COMMENT ON COLUMN public.targeted_resume.config_type IS
    'Config type: ''main'' (POPIA toggles active, standard toggles locked ON server-side) or ''targeted'' (all toggles fully active)';

-- 2. Set safe defaults for visibility JSONB columns (make them non-null with empty object default)
ALTER TABLE public.targeted_resume
    ALTER COLUMN personal_details_visibility SET DEFAULT '{}'::jsonb,
    ALTER COLUMN skills_visibility           SET DEFAULT '{}'::jsonb,
    ALTER COLUMN experience_visibility       SET DEFAULT '{}'::jsonb,
    ALTER COLUMN education_visibility        SET DEFAULT '{}'::jsonb,
    ALTER COLUMN tertiary_education_visibility SET DEFAULT '{}'::jsonb,
    ALTER COLUMN references_visibility       SET DEFAULT '{}'::jsonb,
    ALTER COLUMN languages_visibility        SET DEFAULT '{}'::jsonb;

-- 3. Update column comments to document canonical POPIA keys
COMMENT ON COLUMN public.targeted_resume.personal_details_visibility IS
    'JSONB visibility flags for personal details. '
    'Standard fields (Targeted only - locked ON for Main): pd_first_name, pd_middle_name, pd_maiden_name, pd_surname, pd_prefix, pd_email, pd_phone_cell, pd_phone_home, pd_linkedin, pd_website, pd_professional_summary, pd_licensing, pd_demographics, pd_criminal. '
    'Language rows (Targeted only): lang_<id> -> bool. '
    'POPIA masks (ALWAYS editable on BOTH Main and Targeted): idMask -> bool; addr_mask_street_number_<addr_id> -> bool; addr_mask_street_name_<addr_id> -> bool.';

COMMENT ON COLUMN public.targeted_resume.skills_visibility IS
    'JSONB visibility flags for skills. '
    'Category toggles: skills_tech, skills_soft, skills_non_acad_certs, skills_systems_used -> bool. '
    'Item toggles: tech_<id>, soft_<id>, ncert_<id>, sys_skill_<id> -> bool.';

COMMENT ON COLUMN public.targeted_resume.experience_visibility IS
    'JSONB visibility flags for work experience. '
    'Job rows: exp_<id> -> bool. '
    'Sub-items: resp_<id> (responsibility), sys_<id> (system used), ach_<id> (achievement) -> bool.';

COMMENT ON COLUMN public.targeted_resume.education_visibility IS
    'JSONB visibility flags for education. '
    'High school: edu_highschool, highschool_name -> bool. '
    'Certification rows: cert_<id> -> bool. '
    'Sensitive cert fields: cert_number_<id>, cert_date_<id> -> bool.';

COMMENT ON COLUMN public.targeted_resume.tertiary_education_visibility IS
    'JSONB visibility flags for tertiary education. '
    'Qualification rows: tert_<id> -> bool. '
    'Section-wide: tert_date -> bool; tert_key_modules -> bool.';

COMMENT ON COLUMN public.targeted_resume.references_visibility IS
    'JSONB visibility flags for references. '
    'Referee rows: ref_<id> -> bool. '
    'Sub-fields: ref_surname_<id> -> bool; ref_contact_<id> -> bool.';

COMMENT ON COLUMN public.targeted_resume.languages_visibility IS
    'JSONB visibility flags for languages. '
    'Language rows: lang_<id> -> bool.';

-- 4. Verify the migration
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'targeted_resume'
ORDER BY ordinal_position;
