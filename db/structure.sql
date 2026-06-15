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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    emoji character varying NOT NULL,
    normalized_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: country_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_aliases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    country_id uuid NOT NULL,
    source character varying NOT NULL,
    name character varying NOT NULL,
    normalized_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fixtures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fixtures (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    match_number integer NOT NULL,
    round_number text NOT NULL,
    match_date timestamp(6) without time zone NOT NULL,
    location text NOT NULL,
    home_team text NOT NULL,
    away_team text NOT NULL,
    group_name text,
    home_score integer,
    away_score integer,
    regular_home_score integer,
    regular_away_score integer,
    penalty_home_score integer,
    penalty_away_score integer,
    duration character varying,
    CONSTRAINT fixtures_away_score_non_negative CHECK ((away_score >= 0)),
    CONSTRAINT fixtures_home_score_non_negative CHECK ((home_score >= 0)),
    CONSTRAINT fixtures_penalty_away_score_non_negative CHECK ((penalty_away_score >= 0)),
    CONSTRAINT fixtures_penalty_home_score_non_negative CHECK ((penalty_home_score >= 0)),
    CONSTRAINT fixtures_regular_away_score_non_negative CHECK ((regular_away_score >= 0)),
    CONSTRAINT fixtures_regular_home_score_non_negative CHECK ((regular_home_score >= 0))
);


--
-- Name: leaderboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leaderboards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug character varying NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    outcome_points integer DEFAULT 1 NOT NULL,
    goal_difference_points integer DEFAULT 2 NOT NULL,
    exact_score_points integer DEFAULT 2 NOT NULL,
    outcome_description text NOT NULL,
    goal_difference_description text NOT NULL,
    exact_score_description text NOT NULL,
    goal_difference_rule character varying DEFAULT 'exact_goal_difference'::character varying NOT NULL,
    exact_score_rule character varying DEFAULT 'exact_score'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    outcome_rule character varying DEFAULT 'exact_outcome'::character varying NOT NULL,
    CONSTRAINT leaderboards_exact_score_points_non_negative CHECK ((exact_score_points >= 0)),
    CONSTRAINT leaderboards_goal_difference_points_non_negative CHECK ((goal_difference_points >= 0)),
    CONSTRAINT leaderboards_outcome_points_non_negative CHECK ((outcome_points >= 0))
);


--
-- Name: predictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.predictions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    fixture_id uuid NOT NULL,
    home_score integer NOT NULL,
    away_score integer NOT NULL,
    penalty_winner character varying,
    CONSTRAINT predictions_away_score_non_negative CHECK ((away_score >= 0)),
    CONSTRAINT predictions_home_score_non_negative CHECK ((home_score >= 0)),
    CONSTRAINT predictions_penalty_winner_valid CHECK (((penalty_winner)::text = ANY ((ARRAY['home'::character varying, 'away'::character varying])::text[])))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying NOT NULL,
    password_digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    admin boolean DEFAULT false NOT NULL
);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: country_aliases country_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_aliases
    ADD CONSTRAINT country_aliases_pkey PRIMARY KEY (id);


--
-- Name: fixtures fixtures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fixtures
    ADD CONSTRAINT fixtures_pkey PRIMARY KEY (id);


--
-- Name: leaderboards leaderboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaderboards
    ADD CONSTRAINT leaderboards_pkey PRIMARY KEY (id);


--
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_countries_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_countries_on_name ON public.countries USING btree (name);


--
-- Name: index_countries_on_normalized_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_countries_on_normalized_name ON public.countries USING btree (normalized_name);


--
-- Name: index_country_aliases_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_country_aliases_on_country_id ON public.country_aliases USING btree (country_id);


--
-- Name: index_country_aliases_on_source_and_normalized_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_country_aliases_on_source_and_normalized_name ON public.country_aliases USING btree (source, normalized_name);


--
-- Name: index_fixtures_on_match_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fixtures_on_match_number ON public.fixtures USING btree (match_number);


--
-- Name: index_leaderboards_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_leaderboards_on_slug ON public.leaderboards USING btree (slug);


--
-- Name: index_predictions_on_user_id_and_fixture_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_predictions_on_user_id_and_fixture_id ON public.predictions USING btree (user_id, fixture_id);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: predictions fk_rails_55d5ed1978; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT fk_rails_55d5ed1978 FOREIGN KEY (fixture_id) REFERENCES public.fixtures(id) ON DELETE CASCADE;


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: country_aliases fk_rails_77cb276bcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_aliases
    ADD CONSTRAINT fk_rails_77cb276bcf FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: predictions fk_rails_7eed2ccc94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT fk_rails_7eed2ccc94 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260604000800'),
('20260604000700'),
('20260604000600'),
('20260604000500'),
('20260604000400'),
('20260604000300'),
('20260604000200'),
('20260604000100'),
('20260603232247'),
('20260603224400'),
('20260603200526'),
('20260603195901'),
('20260603195900'),
('20260603195240');

