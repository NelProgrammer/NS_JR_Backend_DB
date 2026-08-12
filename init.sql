--
-- PostgreSQL database dump
--


-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: candidate_index; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidate_index (
    id character varying NOT NULL,
    profile_id character varying NOT NULL,
    resume_id character varying NOT NULL,
    primary_skill text,
    city character varying,
    license_codes character varying,
    last_modified double precision NOT NULL
);


ALTER TABLE public.candidate_index OWNER TO postgres;

--
-- Name: COLUMN candidate_index.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.id IS 'Unique index entry ID';


--
-- Name: COLUMN candidate_index.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.profile_id IS 'Associated profile UUID';


--
-- Name: COLUMN candidate_index.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.resume_id IS 'Associated resume UUID';


--
-- Name: COLUMN candidate_index.primary_skill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.primary_skill IS 'Extracted technical & soft skills summary';


--
-- Name: COLUMN candidate_index.city; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.city IS 'Extracted candidate municipality / city';


--
-- Name: COLUMN candidate_index.license_codes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.license_codes IS 'Extracted driver''s license codes (e.g. ''C1'')';


--
-- Name: COLUMN candidate_index.last_modified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.candidate_index.last_modified IS 'Sync timestamp';


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id character varying NOT NULL,
    email character varying,
    user_id character varying,
    social_id character varying NOT NULL,
    provider character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: COLUMN profiles.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.id IS 'Unique internal profile UUID';


--
-- Name: COLUMN profiles.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.email IS 'User email address';


--
-- Name: COLUMN profiles.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.user_id IS 'FK to User for email/password auth';


--
-- Name: COLUMN profiles.social_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.social_id IS 'Unique provider ID (e.g. Google sub)';


--
-- Name: COLUMN profiles.provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.provider IS 'Social OAuth provider (google/linkedin/facebook)';


--
-- Name: COLUMN profiles.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.created_at IS 'Timestamp of account creation';


--
-- Name: recruitment_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recruitment_shares (
    id character varying NOT NULL PRIMARY KEY,
    resume_id character varying NOT NULL REFERENCES public.resumes(id) ON DELETE CASCADE,
    profile_id character varying NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    allow_all boolean NOT NULL DEFAULT false,
    recruiter_ids jsonb DEFAULT '[]'::jsonb,
    personal_details_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    skills_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    experience_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    education_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    tertiary_education_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    references_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    languages_share jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_modified timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.recruitment_shares OWNER TO postgres;

--
-- Name: COLUMN recruitment_shares.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.id IS 'Unique sharing rule UUID';


--
-- Name: COLUMN recruitment_shares.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.resume_id IS 'Resume being shared';


--
-- Name: COLUMN recruitment_shares.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.profile_id IS 'Owner profile';


--
-- Name: COLUMN recruitment_shares.allow_all; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.allow_all IS 'Allow sharing with all recruiters (true/false)';


--
-- Name: COLUMN recruitment_shares.recruiter_ids; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.recruiter_ids IS 'Array of recruiter IDs allowed if allow_all is false';


--
-- Name: COLUMN recruitment_shares.section_shares; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.section_shares IS 'Map of section names to boolean indicating shareability';


--
-- Name: COLUMN recruitment_shares.last_modified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.recruitment_shares.last_modified IS 'Sync timestamp (Unix epoch)';


--
-- Name: resume_education_tertiary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resume_education_tertiary (
    id character varying NOT NULL,
    resume_id character varying NOT NULL,
    institution character varying,
    qualification_name character varying,
    nqf_level character varying,
    year integer,
    completed boolean NOT NULL,
    key_modules jsonb NOT NULL
);


ALTER TABLE public.resume_education_tertiary OWNER TO postgres;

--
-- Name: COLUMN resume_education_tertiary.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.id IS 'Unique education qualification UUID';


--
-- Name: COLUMN resume_education_tertiary.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.resume_id IS 'Foreign key to parent Resume';


--
-- Name: COLUMN resume_education_tertiary.institution; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.institution IS 'Academic institution name';


--
-- Name: COLUMN resume_education_tertiary.qualification_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.qualification_name IS 'Academic degree / credential name';


--
-- Name: COLUMN resume_education_tertiary.nqf_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.nqf_level IS 'South African NQF Level (e.g. ''Level 7'')';


--
-- Name: COLUMN resume_education_tertiary.year; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.year IS 'Graduation or completion year';


--
-- Name: COLUMN resume_education_tertiary.completed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.completed IS 'Completion status (true/false)';


--
-- Name: COLUMN resume_education_tertiary.key_modules; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_education_tertiary.key_modules IS 'Modules or courses studied';


--
-- Name: resume_references; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resume_references (
    id character varying NOT NULL,
    resume_id character varying NOT NULL,
    name character varying,
    org character varying,
    relation character varying,
    phone character varying,
    email character varying,
    sort_order integer NOT NULL
);


ALTER TABLE public.resume_references OWNER TO postgres;

--
-- Name: COLUMN resume_references.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.id IS 'Unique reference contact UUID';


--
-- Name: COLUMN resume_references.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.resume_id IS 'Foreign key to parent Resume';


--
-- Name: COLUMN resume_references.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.name IS 'Reference contact person name';


--
-- Name: COLUMN resume_references.org; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.org IS 'Reference employer organization';


--
-- Name: COLUMN resume_references.relation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.relation IS 'Professional relationship (e.g. ''Line Manager'')';


--
-- Name: COLUMN resume_references.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.phone IS 'Reference contact cell/telephone number';


--
-- Name: COLUMN resume_references.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.email IS 'Reference email address';


--
-- Name: COLUMN resume_references.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_references.sort_order IS 'Sorting priority';


--
-- Name: resume_ui_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resume_ui_settings (
    resume_id character varying NOT NULL PRIMARY KEY REFERENCES public.resumes(id) ON DELETE CASCADE,
    profile_id character varying NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    layout character varying(50) NOT NULL DEFAULT 'professional',
    personal_details_settings jsonb NOT NULL DEFAULT '{"address_format":"bullet"}'::jsonb,
    skills_settings jsonb NOT NULL DEFAULT '{"tech_format":"bullet","soft_format":"bullet","certs_format":"bullet","systems_used_format":"bullet"}'::jsonb,
    experience_settings jsonb NOT NULL DEFAULT '{"format":"bullet"}'::jsonb,
    education_settings jsonb NOT NULL DEFAULT '{"format":"bullet"}'::jsonb,
    tertiary_education_settings jsonb NOT NULL DEFAULT '{"format":"bullet"}'::jsonb,
    references_settings jsonb NOT NULL DEFAULT '{"format":"bullet"}'::jsonb,
    languages_settings jsonb NOT NULL DEFAULT '{"format":"bullet"}'::jsonb,
    placeholders jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_modified timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.resume_timestamps (
    id character varying NOT NULL,
    resume_id character varying NOT NULL,
    profile_id character varying NOT NULL,
    field_name character varying NOT NULL,
    last_modified timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at_ms bigint NOT NULL
);


ALTER TABLE public.resume_ui_settings OWNER TO postgres;

--
-- Name: COLUMN resume_ui_settings.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_ui_settings.resume_id IS 'Unique resume link';


--
-- Name: COLUMN resume_ui_settings.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_ui_settings.profile_id IS 'Owner profile link';


--
-- Name: COLUMN resume_ui_settings.settings_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_ui_settings.settings_json IS 'Client UI settings preferences';


--
-- Name: COLUMN resume_ui_settings.last_modified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_ui_settings.last_modified IS 'Sync timestamp (Unix epoch)';


--
-- Name: resume_work_experiences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resume_work_experiences (
    id character varying NOT NULL,
    resume_id character varying NOT NULL,
    start_date character varying,
    end_date character varying,
    organization character varying,
    department character varying,
    role character varying,
    key_responsibilities text,
    systems_used character varying,
    achievements text,
    sort_order integer NOT NULL
);


ALTER TABLE public.resume_work_experiences OWNER TO postgres;

--
-- Name: COLUMN resume_work_experiences.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.id IS 'Unique work experience UUID';


--
-- Name: COLUMN resume_work_experiences.resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.resume_id IS 'Foreign key to parent Resume';


--
-- Name: COLUMN resume_work_experiences.start_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.start_date IS 'Start date (e.g. ''Jan 2020'')';


--
-- Name: COLUMN resume_work_experiences.end_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.end_date IS 'End date (or ''Present'')';


--
-- Name: COLUMN resume_work_experiences.organization; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.organization IS 'Employer organization name';


--
-- Name: COLUMN resume_work_experiences.department; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.department IS 'Department or division';


--
-- Name: COLUMN resume_work_experiences.role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.role IS 'Job title or role';


--
-- Name: COLUMN resume_work_experiences.key_responsibilities; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.key_responsibilities IS 'Responsibilities markdown / summary';


--
-- Name: COLUMN resume_work_experiences.systems_used; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.systems_used IS 'Comma-separated lists of tools/software used';


--
-- Name: COLUMN resume_work_experiences.achievements; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.achievements IS 'Job accomplishments text';


--
-- Name: COLUMN resume_work_experiences.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resume_work_experiences.sort_order IS 'Relative sorting priority';


--
-- Name: resumes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resumes (
    id character varying NOT NULL,
    profile_id character varying NOT NULL,
    name character varying NOT NULL,
    last_modified timestamp without time zone NOT NULL,
    first_name character varying,
    middle_name character varying,
    maiden_name character varying,
    surname character varying,
    prefix character varying,
    id_number character varying,
    phone_cell character varying,
    phone_home character varying,
    email_contact character varying,
    linkedin character varying,
    website character varying,
    home_address text,
    drivers_license character varying,
    motorcycle_license character varying,
    gender character varying,
    race character varying,
    nationality character varying,
    criminal_record boolean NOT NULL,
    criminal_details text,
    professional_summary text,
    languages_json jsonb NOT NULL,
    skills_json jsonb NOT NULL,
    education_highschool_json jsonb NOT NULL,
    layout character varying NOT NULL,
    export_format character varying NOT NULL
);


ALTER TABLE public.resumes OWNER TO postgres;

--
-- Name: COLUMN resumes.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.id IS 'Unique resume document UUID';


--
-- Name: COLUMN resumes.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.profile_id IS 'Owner profile link';


--
-- Name: COLUMN resumes.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.name IS 'User-assigned resume name (e.g. ''Software Resume'')';


--
-- Name: COLUMN resumes.last_modified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.last_modified IS 'Client/Server sync timestamp (DateTime)';


--
-- Name: COLUMN resumes.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.first_name IS 'First name';


--
-- Name: COLUMN resumes.middle_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.middle_name IS 'Middle name';


--
-- Name: COLUMN resumes.maiden_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.maiden_name IS 'Maiden name';


--
-- Name: COLUMN resumes.surname; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.surname IS 'Surname';


--
-- Name: COLUMN resumes.prefix; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.prefix IS 'Prefix (e.g. Mr, Ms)';


--
-- Name: COLUMN resumes.id_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.id_number IS '13-digit ID number';


--
-- Name: COLUMN resumes.phone_cell; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.phone_cell IS 'Cell phone';


--
-- Name: COLUMN resumes.phone_home; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.phone_home IS 'Home phone';


--
-- Name: COLUMN resumes.email_contact; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.email_contact IS 'Contact email';


--
-- Name: COLUMN resumes.linkedin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.linkedin IS 'LinkedIn URL/Handle';


--
-- Name: COLUMN resumes.website; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.website IS 'Personal website';


--
-- Name: COLUMN resumes.home_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.home_address IS 'Home physical address';


--
-- Name: COLUMN resumes.drivers_license; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.drivers_license IS 'Driver''s license codes';


--
-- Name: COLUMN resumes.motorcycle_license; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.motorcycle_license IS 'Motorcycle license codes';


--
-- Name: COLUMN resumes.gender; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.gender IS 'Employment Equity gender';


--
-- Name: COLUMN resumes.race; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.race IS 'Employment Equity race';


--
-- Name: COLUMN resumes.nationality; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.nationality IS 'Nationality';


--
-- Name: COLUMN resumes.criminal_record; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.criminal_record IS 'Criminal record check';


--
-- Name: COLUMN resumes.criminal_details; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.criminal_details IS 'Criminal record details context';


--
-- Name: COLUMN resumes.professional_summary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.professional_summary IS 'Professional profile summary';


--
-- Name: COLUMN resumes.languages_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.languages_json IS 'Languages and proficiency array';


--
-- Name: COLUMN resumes.skills_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.skills_json IS 'Technical & soft skills CSV, certifications';


--
-- Name: COLUMN resumes.education_highschool_json; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.education_highschool_json IS 'Highschool details';


--
-- Name: COLUMN resumes.layout; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.layout IS 'Active resume print layout template';


--
-- Name: COLUMN resumes.export_format; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.resumes.export_format IS 'Active resume print output format';


--
-- Name: targeted_resume; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.targeted_resume (
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
    last_modified timestamp without time zone NOT NULL
);


ALTER TABLE public.targeted_resume OWNER TO postgres;

--
-- Name: COLUMN targeted_resume.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.id IS 'Unique targeted resume UUID';


--
-- Name: COLUMN targeted_resume.primary_resume_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.primary_resume_id IS 'Link to primary/master Resume';


--
-- Name: COLUMN targeted_resume.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.profile_id IS 'Associated profile link';


--
-- Name: COLUMN targeted_resume.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.name IS 'Targeted CV title (e.g. ''Driver Application CV'')';


--
-- Name: COLUMN targeted_resume.personal_details_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.personal_details_visibility IS 'JSONB mapping visibility on personal details';


--
-- Name: COLUMN targeted_resume.skills_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.skills_visibility IS 'JSONB mapping visibility on skills';


--
-- Name: COLUMN targeted_resume.experience_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.experience_visibility IS 'JSONB mapping visibility on work experience items';


--
-- Name: COLUMN targeted_resume.education_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.education_visibility IS 'JSONB mapping visibility on education modules';


--
-- Name: COLUMN targeted_resume.references_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.references_visibility IS 'JSONB mapping visibility on references';


--
-- Name: COLUMN targeted_resume.languages_visibility; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.languages_visibility IS 'JSONB mapping visibility on language options';


--
-- Name: COLUMN targeted_resume.last_modified; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.targeted_resume.last_modified IS 'Client/Server synchronization timestamp';


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying NOT NULL,
    email character varying NOT NULL,
    hashed_password character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.id IS 'Unique user UUID';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.email IS 'User email address';


--
-- Name: COLUMN users.hashed_password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.hashed_password IS 'bcrypt password hash';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.created_at IS 'Account creation timestamp';


--
-- Name: candidate_index candidate_index_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidate_index
    ADD CONSTRAINT candidate_index_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: recruitment_shares recruitment_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recruitment_shares
    ADD CONSTRAINT recruitment_shares_pkey PRIMARY KEY (id);


--
-- Name: resume_education_tertiary resume_education_tertiary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_education_tertiary
    ADD CONSTRAINT resume_education_tertiary_pkey PRIMARY KEY (id);


--
-- Name: resume_references resume_references_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_references
    ADD CONSTRAINT resume_references_pkey PRIMARY KEY (id);


--
-- Name: resume_ui_settings resume_ui_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_ui_settings
    ADD CONSTRAINT resume_ui_settings_pkey PRIMARY KEY (resume_id);


--
-- Name: resume_work_experiences resume_work_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_work_experiences
    ADD CONSTRAINT resume_work_experiences_pkey PRIMARY KEY (id);


--
-- Name: resumes resumes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resumes
    ADD CONSTRAINT resumes_pkey PRIMARY KEY (id);


--
-- Name: targeted_resume targeted_resume_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.targeted_resume
    ADD CONSTRAINT targeted_resume_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_candidate_index_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_candidate_index_city ON public.candidate_index USING btree (city);


--
-- Name: ix_candidate_index_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_candidate_index_id ON public.candidate_index USING btree (id);


--
-- Name: ix_candidate_index_primary_skill; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_candidate_index_primary_skill ON public.candidate_index USING btree (primary_skill);


--
-- Name: ix_candidate_index_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_candidate_index_profile_id ON public.candidate_index USING btree (profile_id);


--
-- Name: ix_candidate_index_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_candidate_index_resume_id ON public.candidate_index USING btree (resume_id);


--
-- Name: ix_profiles_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_email ON public.profiles USING btree (email);


--
-- Name: ix_profiles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_id ON public.profiles USING btree (id);


--
-- Name: ix_profiles_social_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_profiles_social_id ON public.profiles USING btree (social_id);


--
-- Name: ix_recruitment_shares_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_recruitment_shares_id ON public.recruitment_shares USING btree (id);


--
-- Name: ix_recruitment_shares_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_recruitment_shares_profile_id ON public.recruitment_shares USING btree (profile_id);


--
-- Name: ix_recruitment_shares_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_recruitment_shares_resume_id ON public.recruitment_shares USING btree (resume_id);


--
-- Name: ix_resume_education_tertiary_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_education_tertiary_id ON public.resume_education_tertiary USING btree (id);


--
-- Name: ix_resume_education_tertiary_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_education_tertiary_resume_id ON public.resume_education_tertiary USING btree (resume_id);


--
-- Name: ix_resume_references_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_references_id ON public.resume_references USING btree (id);


--
-- Name: ix_resume_references_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_references_resume_id ON public.resume_references USING btree (resume_id);


--
-- Name: ix_resume_ui_settings_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_ui_settings_profile_id ON public.resume_ui_settings USING btree (profile_id);


--
-- Name: ix_resume_ui_settings_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_ui_settings_resume_id ON public.resume_ui_settings USING btree (resume_id);


--
-- Name: ix_resume_work_experiences_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_work_experiences_id ON public.resume_work_experiences USING btree (id);


--
-- Name: ix_resume_work_experiences_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resume_work_experiences_resume_id ON public.resume_work_experiences USING btree (resume_id);


--
-- Name: ix_resumes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_resumes_id ON public.resumes USING btree (id);


--
-- Name: ix_resumes_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_resumes_profile_id ON public.resumes USING btree (profile_id);


--
-- Name: ix_targeted_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_targeted_resume_id ON public.targeted_resume USING btree (id);


--
-- Name: ix_targeted_resume_primary_resume_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_targeted_resume_primary_resume_id ON public.targeted_resume USING btree (primary_resume_id);


--
-- Name: ix_targeted_resume_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_targeted_resume_profile_id ON public.targeted_resume USING btree (profile_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: recruitment_shares recruitment_shares_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recruitment_shares
    ADD CONSTRAINT recruitment_shares_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id);


--
-- Name: recruitment_shares recruitment_shares_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recruitment_shares
    ADD CONSTRAINT recruitment_shares_resume_id_fkey FOREIGN KEY (resume_id) REFERENCES public.resumes(id);


--
-- Name: resume_education_tertiary resume_education_tertiary_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_education_tertiary
    ADD CONSTRAINT resume_education_tertiary_resume_id_fkey FOREIGN KEY (resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;


--
-- Name: resume_references resume_references_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_references
    ADD CONSTRAINT resume_references_resume_id_fkey FOREIGN KEY (resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;


--
-- Name: resume_ui_settings resume_ui_settings_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_ui_settings
    ADD CONSTRAINT resume_ui_settings_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: resume_ui_settings resume_ui_settings_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_ui_settings
    ADD CONSTRAINT resume_ui_settings_resume_id_fkey FOREIGN KEY (resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;


--
-- Name: resume_work_experiences resume_work_experiences_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resume_work_experiences
    ADD CONSTRAINT resume_work_experiences_resume_id_fkey FOREIGN KEY (resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;


--
-- Name: resumes resumes_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resumes
    ADD CONSTRAINT resumes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: targeted_resume targeted_resume_primary_resume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.targeted_resume
    ADD CONSTRAINT targeted_resume_primary_resume_id_fkey FOREIGN KEY (primary_resume_id) REFERENCES public.resumes(id) ON DELETE CASCADE;


--
-- Name: targeted_resume targeted_resume_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.targeted_resume
    ADD CONSTRAINT targeted_resume_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

--
-- SEED DATA: 3 to 4 items per multi-value section and midway supporting tables
--

INSERT INTO public.users (id, email, hashed_password)
VALUES ('user_demo_101', 'candidate@jobready.com', '$2b$12$eImiTXuWVxfM37uY4JANjO5E.yvH3zJ2E5A8e0F7K6L9M0N1O2P3Q')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, user_id, social_id, provider)
VALUES ('prof_demo_101', 'candidate@jobready.com', 'user_demo_101', 'social_google_101', 'google')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resumes (id, profile_id, name, first_name, surname, email_contact, professional_summary, layout, export_format, languages_json, skills_json, education_highschool_json, last_modified)
VALUES (
    'res_master_101',
    'prof_demo_101',
    'Primary Master CV',
    'Alexander',
    'Vance',
    'alexander.vance@jobready.com',
    'Senior Full-Stack Engineer with 8+ years experience building mobile & web platforms.',
    'professional',
    'pdf',
    '[{"id":"lang_501","language":"English","proficiency":"Native"},{"id":"lang_502","language":"Afrikaans","proficiency":"Fluent"},{"id":"lang_503","language":"isiZulu","proficiency":"Basic"}]'::jsonb,
    '[{"id":"sk_201","name":"React Native","category":"Technical"},{"id":"sk_202","name":"Python FastAPI","category":"Technical"},{"id":"sk_203","name":"PostgreSQL SQL","category":"Technical"},{"id":"sk_204","name":"Docker CI/CD","category":"Technical"}]'::jsonb,
    '{"school":"Pretoria High School","matricYear":2014,"subjects":["Mathematics","Physical Sciences","IT"]}'::jsonb,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resume_work_experiences (id, resume_id, company, job_title, start_date, end_date, is_current, description, sort_order)
VALUES 
('exp_101', 'res_master_101', 'Apex Tech Solutions', 'Lead React Native Architect', '2022-01-01', 'Present', true, 'Architected cross-platform mobile suite serving 500k active users.', 1),
('exp_102', 'res_master_101', 'CloudScale Global', 'Senior Systems Engineer', '2019-03-01', '2021-12-31', false, 'Designed distributed microservices handling 10k req/sec.', 2),
('exp_103', 'res_master_101', 'DevCore Agency', 'Full-Stack Developer', '2017-06-01', '2019-02-28', false, 'Delivered 15 client web applications on Next.js & Python.', 3),
('exp_104', 'res_master_101', 'InnoLab Incubator', 'Junior Software Analyst', '2015-01-15', '2017-05-30', false, 'Automated CI/CD deployment scripts and regression suites.', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resume_education_tertiary (id, resume_id, institution, qualification_name, nqf_level, year, completed, key_modules)
VALUES 
('edu_301', 'res_master_101', 'University of Pretoria', 'BSc Computer Science', 'Level 7', 2018, true, '["Data Structures","Algorithms","Database Systems"]'::jsonb),
('edu_302', 'res_master_101', 'University of Witwatersrand', 'PostGrad Cert in Software Architecture', 'Level 8', 2020, true, '["Distributed Systems","Cloud Security"]'::jsonb),
('edu_303', 'res_master_101', 'AWS Certification Authority', 'AWS Solutions Architect Associate', 'Level 7', 2022, true, '["Serverless","IAM","CloudFormation"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resume_references (id, resume_id, name, org, relation, phone, email, sort_order)
VALUES 
('ref_401', 'res_master_101', 'Sarah Jenkins', 'Apex Tech Solutions', 'VP of Engineering', '+27821112222', 'sjenkins@apextech.co.za', 1),
('ref_402', 'res_master_101', 'Marcus Brody', 'CloudScale Global', 'Engineering Manager', '+27833334444', 'mbrody@cloudscale.com', 2),
('ref_403', 'res_master_101', 'Dr. David Ross', 'University of Pretoria', 'Academic Supervisor', '+27124201111', 'dross@cs.up.ac.za', 3),
('ref_404', 'res_master_101', 'Elena Rostova', 'DevCore Agency', 'Lead Architect', '+27845556666', 'elena@devcore.io', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.targeted_resume (id, primary_resume_id, profile_id, name, personal_details_visibility, skills_visibility, experience_visibility, education_visibility, tertiary_education_visibility, references_visibility, languages_visibility, last_modified)
VALUES 
(
    'target_101',
    'res_master_101',
    'prof_demo_101',
    'Senior Mobile Architect Targeted CV',
    '{"idNumber":false,"demographics":true}'::jsonb,
    '{"sk_201":true,"sk_202":true,"sk_203":true,"sk_204":false}'::jsonb,
    '{"exp_101":true,"exp_102":true,"exp_103":false,"exp_104":true}'::jsonb,
    '{"edu_hs_1":true}'::jsonb,
    '{"edu_301":true,"edu_302":true,"edu_303":false}'::jsonb,
    '{"ref_401":true,"ref_402":false,"ref_403":true,"ref_404":true}'::jsonb,
    '{"lang_501":true,"lang_502":true,"lang_503":false}'::jsonb,
    CURRENT_TIMESTAMP
),
(
    'target_102',
    'res_master_101',
    'prof_demo_101',
    'DevOps & Cloud Specialist Targeted CV',
    '{"idNumber":true,"demographics":true}'::jsonb,
    '{"sk_201":false,"sk_202":true,"sk_203":true,"sk_204":true}'::jsonb,
    '{"exp_101":false,"exp_102":true,"exp_103":false,"exp_104":true}'::jsonb,
    '{"edu_hs_1":true}'::jsonb,
    '{"edu_301":true,"edu_302":false,"edu_303":true}'::jsonb,
    '{"ref_401":false,"ref_402":true,"ref_403":true,"ref_404":false}'::jsonb,
    '{"lang_501":true,"lang_502":false,"lang_503":true}'::jsonb,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resume_ui_settings (resume_id, profile_id, layout, personal_details_settings, skills_settings, experience_settings, education_settings, tertiary_education_settings, references_settings, languages_settings, placeholders, last_modified)
VALUES (
    'res_master_101',
    'prof_demo_101',
    'professional',
    '{"address_format":"bullet"}'::jsonb,
    '{"tech_format":"bullet","soft_format":"bullet","certs_format":"bullet","systems_used_format":"bullet"}'::jsonb,
    '{"format":"bullet"}'::jsonb,
    '{"format":"bullet"}'::jsonb,
    '{"format":"bullet"}'::jsonb,
    '{"format":"bullet"}'::jsonb,
    '{"format":"bullet"}'::jsonb,
    '{"tech":"- {SkillName} ({Proficiency})","soft":"- {SkillName}","certs":"- {CertName} ({Year})"}'::jsonb,
    CURRENT_TIMESTAMP
)
ON CONFLICT (resume_id) DO NOTHING;

INSERT INTO public.recruitment_shares (id, resume_id, profile_id, allow_all, recruiter_ids, personal_details_share, skills_share, experience_share, education_share, tertiary_education_share, references_share, languages_share, last_modified)
VALUES (
    'share_101',
    'res_master_101',
    'prof_demo_101',
    true,
    '["rec_901","rec_902"]'::jsonb,
    '{"address":true}'::jsonb,
    '{"sk_201":true,"sk_202":true,"sk_203":true,"sk_204":false}'::jsonb,
    '{"exp_101":true,"exp_102":true,"exp_103":false,"exp_104":true}'::jsonb,
    '{"edu_hs_1":true}'::jsonb,
    '{"edu_301":true,"edu_302":true,"edu_303":false}'::jsonb,
    '{"ref_401":false,"ref_402":false,"ref_403":false,"ref_404":false}'::jsonb,
    '{"lang_501":true,"lang_502":true,"lang_503":false}'::jsonb,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.resume_timestamps (id, resume_id, profile_id, field_name, last_modified, updated_at_ms)
VALUES 
('ts_101', 'res_master_101', 'prof_demo_101', 'experience.exp_101', CURRENT_TIMESTAMP, 1786476000000),
('ts_102', 'res_master_101', 'prof_demo_101', 'experience.exp_102', CURRENT_TIMESTAMP, 1786476000000),
('ts_103', 'res_master_101', 'prof_demo_101', 'skills.sk_201', CURRENT_TIMESTAMP, 1786476000000),
('ts_104', 'res_master_101', 'prof_demo_101', 'education.edu_301', CURRENT_TIMESTAMP, 1786476000000)
ON CONFLICT (id) DO NOTHING;


