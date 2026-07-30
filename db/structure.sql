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
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


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
-- Name: chunks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chunks (
    id bigint NOT NULL,
    chunkable_type character varying NOT NULL,
    chunkable_id bigint NOT NULL,
    chunk_type character varying NOT NULL,
    source_github_id integer,
    title character varying,
    parent_url character varying NOT NULL,
    parent_number integer NOT NULL,
    content text NOT NULL,
    embedding_text text NOT NULL,
    repository character varying,
    project character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    embedding public.vector(1024),
    search_vector tsvector
);


--
-- Name: chunks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chunks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chunks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chunks_id_seq OWNED BY public.chunks.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    commentable_type character varying NOT NULL,
    commentable_id bigint NOT NULL,
    github_id integer NOT NULL,
    body text NOT NULL,
    author character varying NOT NULL,
    url character varying NOT NULL,
    comment_type character varying NOT NULL,
    github_created_at timestamp(6) without time zone NOT NULL,
    github_updated_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: github_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_projects (
    id bigint NOT NULL,
    title character varying NOT NULL,
    number integer NOT NULL,
    owner character varying NOT NULL,
    github_node_id character varying NOT NULL,
    last_synced_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: github_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.github_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.github_projects_id_seq OWNED BY public.github_projects.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    id bigint NOT NULL,
    github_project_id bigint NOT NULL,
    number integer NOT NULL,
    github_id integer NOT NULL,
    title character varying NOT NULL,
    body text,
    state character varying NOT NULL,
    labels text[] DEFAULT '{}'::text[] NOT NULL,
    url character varying NOT NULL,
    github_updated_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests (
    id bigint NOT NULL,
    repository_id bigint NOT NULL,
    number integer NOT NULL,
    github_id integer NOT NULL,
    title character varying NOT NULL,
    body text,
    state character varying NOT NULL,
    labels text[] DEFAULT '{}'::text[] NOT NULL,
    url character varying NOT NULL,
    merged_at timestamp(6) without time zone,
    github_updated_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pull_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_id_seq OWNED BY public.pull_requests.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    full_name character varying NOT NULL,
    github_id integer NOT NULL,
    last_synced_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sync_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_logs (
    id bigint NOT NULL,
    syncable_type character varying NOT NULL,
    syncable_id bigint NOT NULL,
    started_at timestamp(6) without time zone NOT NULL,
    finished_at timestamp(6) without time zone,
    status character varying NOT NULL,
    items_fetched integer DEFAULT 0,
    items_created integer DEFAULT 0,
    items_updated integer DEFAULT 0,
    error_message text,
    created_at timestamp(6) without time zone NOT NULL,
    failed_items jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: sync_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sync_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sync_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sync_logs_id_seq OWNED BY public.sync_logs.id;


--
-- Name: chunks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chunks ALTER COLUMN id SET DEFAULT nextval('public.chunks_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: github_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_projects ALTER COLUMN id SET DEFAULT nextval('public.github_projects_id_seq'::regclass);


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: sync_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_logs ALTER COLUMN id SET DEFAULT nextval('public.sync_logs_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: chunks chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chunks
    ADD CONSTRAINT chunks_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: github_projects github_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_projects
    ADD CONSTRAINT github_projects_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: pull_requests pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests
    ADD CONSTRAINT pull_requests_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sync_logs sync_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_logs
    ADD CONSTRAINT sync_logs_pkey PRIMARY KEY (id);


--
-- Name: index_chunks_on_chunkable_type_and_chunkable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chunks_on_chunkable_type_and_chunkable_id ON public.chunks USING btree (chunkable_type, chunkable_id);


--
-- Name: index_chunks_on_parent_and_source; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_chunks_on_parent_and_source ON public.chunks USING btree (chunkable_type, chunkable_id, chunk_type, source_github_id);


--
-- Name: index_chunks_on_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chunks_on_project ON public.chunks USING btree (project);


--
-- Name: index_chunks_on_repository; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chunks_on_repository ON public.chunks USING btree (repository);


--
-- Name: index_chunks_on_search_vector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chunks_on_search_vector ON public.chunks USING gin (search_vector);


--
-- Name: index_comments_on_commentable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable ON public.comments USING btree (commentable_type, commentable_id);


--
-- Name: index_comments_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comments_on_github_id ON public.comments USING btree (github_id);


--
-- Name: index_github_projects_on_github_node_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_github_projects_on_github_node_id ON public.github_projects USING btree (github_node_id);


--
-- Name: index_issues_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_github_id ON public.issues USING btree (github_id);


--
-- Name: index_issues_on_github_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_github_project_id ON public.issues USING btree (github_project_id);


--
-- Name: index_issues_on_github_project_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_github_project_id_and_number ON public.issues USING btree (github_project_id, number);


--
-- Name: index_issues_on_github_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_github_updated_at ON public.issues USING btree (github_updated_at);


--
-- Name: index_pull_requests_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_github_id ON public.pull_requests USING btree (github_id);


--
-- Name: index_pull_requests_on_github_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_github_updated_at ON public.pull_requests USING btree (github_updated_at);


--
-- Name: index_pull_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_repository_id ON public.pull_requests USING btree (repository_id);


--
-- Name: index_pull_requests_on_repository_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_repository_id_and_number ON public.pull_requests USING btree (repository_id, number);


--
-- Name: index_repositories_on_full_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_full_name ON public.repositories USING btree (full_name);


--
-- Name: index_repositories_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_github_id ON public.repositories USING btree (github_id);


--
-- Name: index_sync_logs_on_syncable_type_and_syncable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sync_logs_on_syncable_type_and_syncable_id ON public.sync_logs USING btree (syncable_type, syncable_id);


--
-- Name: issues fk_rails_5e157d96c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_rails_5e157d96c7 FOREIGN KEY (github_project_id) REFERENCES public.github_projects(id);


--
-- Name: pull_requests fk_rails_8fa503b550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests
    ADD CONSTRAINT fk_rails_8fa503b550 FOREIGN KEY (repository_id) REFERENCES public.repositories(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260729142620'),
('20260729142618'),
('20260728160244'),
('20260728154051'),
('20260728152317'),
('20260728104557'),
('20260728103204'),
('20260728100655');

