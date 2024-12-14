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
-- Name: follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.follows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    follower_id uuid,
    followed_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    unfollowed_at timestamp(6) without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sleep_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sleep_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    bed_time timestamp(6) without time zone NOT NULL,
    wake_time timestamp(6) without time zone,
    duration_minutes integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: weekly_sleep_records_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.weekly_sleep_records_summary AS
 SELECT sr.id,
    sr.user_id,
    f.follower_id,
    sr.bed_time,
    sr.wake_time,
    sr.duration_minutes
   FROM (public.sleep_records sr
     JOIN public.follows f ON ((sr.user_id = f.followed_id)))
  WHERE ((sr.bed_time >= (now() - '7 days'::interval)) AND (sr.wake_time IS NOT NULL) AND (f.unfollowed_at IS NULL))
  ORDER BY sr.duration_minutes DESC
  WITH NO DATA;


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sleep_records sleep_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sleep_records
    ADD CONSTRAINT sleep_records_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_follows_on_follower_id_and_followed_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_follows_on_follower_id_and_followed_id ON public.follows USING btree (follower_id, followed_id);


--
-- Name: index_follows_on_unfollowed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_follows_on_unfollowed_at ON public.follows USING btree (unfollowed_at);


--
-- Name: index_sleep_records_on_bed_time_and_duration_minutes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sleep_records_on_bed_time_and_duration_minutes ON public.sleep_records USING btree (bed_time, duration_minutes);


--
-- Name: index_weekly_sleep_records_summary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weekly_sleep_records_summary ON public.weekly_sleep_records_summary USING btree (follower_id, user_id);


--
-- Name: sleep_records fk_rails_0f78b0de7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sleep_records
    ADD CONSTRAINT fk_rails_0f78b0de7b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: follows fk_rails_5ef72a3867; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_rails_5ef72a3867 FOREIGN KEY (followed_id) REFERENCES public.users(id);


--
-- Name: follows fk_rails_622d34a301; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_rails_622d34a301 FOREIGN KEY (follower_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20241214102649'),
('20241214071116'),
('20241213184653'),
('20241212184714'),
('20241212165532'),
('20241212164619'),
('20241212164350');

