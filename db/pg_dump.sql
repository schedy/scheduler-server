--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: update_stats_counter(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_stats_counter() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF (TG_OP = 'INSERT') AND NEW.current IS TRUE THEN
  INSERT INTO stats_counter (status_table,status_name,status_counter) VALUES (TG_TABLE_NAME,NEW.status, 1) ON CONFLICT (status_table,status_name) DO UPDATE SET status_counter = stats_counter.status_counter + 1;
 ELSIF NEW.current IS NOT TRUE AND OLD.current IS TRUE THEN
  INSERT INTO stats_counter (status_table,status_name,status_counter) VALUES (TG_TABLE_NAME,NEW.status, 0) ON CONFLICT (status_table,status_name) DO UPDATE SET status_counter = stats_counter.status_counter - 1;
 END IF;

 RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artifacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artifacts (
    id integer NOT NULL,
    execution_id integer,
    task_id integer,
    size integer,
    mimetype text,
    name text,
    storage_handler text,
    storage_handler_data jsonb,
    external_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artifacts_id_seq OWNED BY public.artifacts.id;


--
-- Name: broken_artifacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.broken_artifacts (
    id integer,
    min timestamp without time zone,
    ct bigint
);


--
-- Name: broken_artifacts2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.broken_artifacts2 (
    id integer,
    min timestamp without time zone
);


--
-- Name: broken_artifacts3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.broken_artifacts3 (
    id integer,
    max timestamp without time zone
);


--
-- Name: execution_hooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.execution_hooks (
    id integer NOT NULL,
    execution_id integer,
    status text,
    hook text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: execution_hooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.execution_hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.execution_hooks_id_seq OWNED BY public.execution_hooks.id;


--
-- Name: execution_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.execution_statuses (
    id integer NOT NULL,
    execution_id integer,
    status text,
    current boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: execution_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.execution_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.execution_statuses_id_seq OWNED BY public.execution_statuses.id;


--
-- Name: execution_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.execution_values (
    id integer NOT NULL,
    execution_id integer,
    value_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    property_id integer
);


--
-- Name: execution_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.execution_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.execution_values_id_seq OWNED BY public.execution_values.id;


--
-- Name: executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.executions (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data jsonb
);


--
-- Name: executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.executions_id_seq OWNED BY public.executions.id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.properties (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.properties_id_seq OWNED BY public.properties.id;


--
-- Name: requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requirements (
    id integer NOT NULL,
    uuid uuid,
    description jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requirements_id_seq OWNED BY public.requirements.id;


--
-- Name: resource_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_statuses (
    id integer NOT NULL,
    task_id integer,
    description jsonb,
    resource_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    current boolean,
    role text
);


--
-- Name: resource_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_statuses_id_seq OWNED BY public.resource_statuses.id;


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources (
    id integer NOT NULL,
    worker_id integer,
    remote_id integer,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resources_id_seq OWNED BY public.resources.id;


--
-- Name: resources_task_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources_task_statuses (
    id integer NOT NULL,
    resource_id integer,
    task_status_id integer
);


--
-- Name: resources_task_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resources_task_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_task_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resources_task_statuses_id_seq OWNED BY public.resources_task_statuses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seapig_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seapig_dependencies (
    id integer NOT NULL,
    name text,
    current_version bigint,
    reported_version bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: seapig_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seapig_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seapig_dependencies_id_seq OWNED BY public.seapig_dependencies.id;


--
-- Name: seapig_dependency_version_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seapig_dependency_version_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_dependency_version_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seapig_dependency_version_seq OWNED BY public.seapig_dependencies.current_version;


--
-- Name: seapig_router_session_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seapig_router_session_states (
    id integer NOT NULL,
    seapig_router_session_id integer,
    state_id integer,
    state jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: seapig_router_session_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seapig_router_session_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_router_session_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seapig_router_session_states_id_seq OWNED BY public.seapig_router_session_states.id;


--
-- Name: seapig_router_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seapig_router_sessions (
    id integer NOT NULL,
    key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    token text
);


--
-- Name: seapig_router_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seapig_router_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_router_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seapig_router_sessions_id_seq OWNED BY public.seapig_router_sessions.id;


--
-- Name: stats_counter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stats_counter (
    status_table character varying NOT NULL,
    status_name character varying NOT NULL,
    status_counter integer NOT NULL
);


--
-- Name: task_hooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_hooks (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hook text,
    status text,
    execution_id integer,
    task_id integer
);


--
-- Name: task_hooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_hooks_id_seq OWNED BY public.task_hooks.id;


--
-- Name: task_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_statuses (
    id integer NOT NULL,
    task_id integer,
    status text,
    current boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    worker_id integer
);


--
-- Name: task_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_statuses_id_seq OWNED BY public.task_statuses.id;


--
-- Name: task_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_values (
    id integer NOT NULL,
    task_id integer,
    value_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    property_id integer
);


--
-- Name: task_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_values_id_seq OWNED BY public.task_values.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    execution_id integer,
    description jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    requirement_id integer NOT NULL,
    retry smallint
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    nickname text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."values" (
    id integer NOT NULL,
    property_id integer,
    value text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.values_id_seq OWNED BY public."values".id;


--
-- Name: worker_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_statuses (
    id integer NOT NULL,
    worker_id integer,
    current boolean,
    data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: worker_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_statuses_id_seq OWNED BY public.worker_statuses.id;


--
-- Name: workers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workers (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workers_id_seq OWNED BY public.workers.id;


--
-- Name: artifacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifacts ALTER COLUMN id SET DEFAULT nextval('public.artifacts_id_seq'::regclass);


--
-- Name: execution_hooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_hooks ALTER COLUMN id SET DEFAULT nextval('public.execution_hooks_id_seq'::regclass);


--
-- Name: execution_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_statuses ALTER COLUMN id SET DEFAULT nextval('public.execution_statuses_id_seq'::regclass);


--
-- Name: execution_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_values ALTER COLUMN id SET DEFAULT nextval('public.execution_values_id_seq'::regclass);


--
-- Name: executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.executions ALTER COLUMN id SET DEFAULT nextval('public.executions_id_seq'::regclass);


--
-- Name: properties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties ALTER COLUMN id SET DEFAULT nextval('public.properties_id_seq'::regclass);


--
-- Name: requirements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requirements ALTER COLUMN id SET DEFAULT nextval('public.requirements_id_seq'::regclass);


--
-- Name: resource_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_statuses ALTER COLUMN id SET DEFAULT nextval('public.resource_statuses_id_seq'::regclass);


--
-- Name: resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources ALTER COLUMN id SET DEFAULT nextval('public.resources_id_seq'::regclass);


--
-- Name: resources_task_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources_task_statuses ALTER COLUMN id SET DEFAULT nextval('public.resources_task_statuses_id_seq'::regclass);


--
-- Name: seapig_dependencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_dependencies ALTER COLUMN id SET DEFAULT nextval('public.seapig_dependencies_id_seq'::regclass);


--
-- Name: seapig_router_session_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_router_session_states ALTER COLUMN id SET DEFAULT nextval('public.seapig_router_session_states_id_seq'::regclass);


--
-- Name: seapig_router_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_router_sessions ALTER COLUMN id SET DEFAULT nextval('public.seapig_router_sessions_id_seq'::regclass);


--
-- Name: task_hooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_hooks ALTER COLUMN id SET DEFAULT nextval('public.task_hooks_id_seq'::regclass);


--
-- Name: task_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_statuses ALTER COLUMN id SET DEFAULT nextval('public.task_statuses_id_seq'::regclass);


--
-- Name: task_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_values ALTER COLUMN id SET DEFAULT nextval('public.task_values_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."values" ALTER COLUMN id SET DEFAULT nextval('public.values_id_seq'::regclass);


--
-- Name: worker_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_statuses ALTER COLUMN id SET DEFAULT nextval('public.worker_statuses_id_seq'::regclass);


--
-- Name: workers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workers ALTER COLUMN id SET DEFAULT nextval('public.workers_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artifacts artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artifacts
    ADD CONSTRAINT artifacts_pkey PRIMARY KEY (id);


--
-- Name: execution_hooks execution_hooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_hooks
    ADD CONSTRAINT execution_hooks_pkey PRIMARY KEY (id);


--
-- Name: execution_statuses execution_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_statuses
    ADD CONSTRAINT execution_statuses_pkey PRIMARY KEY (id);


--
-- Name: execution_values execution_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_values
    ADD CONSTRAINT execution_values_pkey PRIMARY KEY (id);


--
-- Name: executions executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.executions
    ADD CONSTRAINT executions_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: requirements requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requirements
    ADD CONSTRAINT requirements_pkey PRIMARY KEY (id);


--
-- Name: requirements requirements_unique_uuid; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requirements
    ADD CONSTRAINT requirements_unique_uuid UNIQUE (uuid);


--
-- Name: resource_statuses resource_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_statuses
    ADD CONSTRAINT resource_statuses_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: resources_task_statuses resources_task_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources_task_statuses
    ADD CONSTRAINT resources_task_statuses_pkey PRIMARY KEY (id);


--
-- Name: seapig_dependencies seapig_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_dependencies
    ADD CONSTRAINT seapig_dependencies_pkey PRIMARY KEY (id);


--
-- Name: seapig_router_session_states seapig_router_session_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_router_session_states
    ADD CONSTRAINT seapig_router_session_states_pkey PRIMARY KEY (id);


--
-- Name: seapig_router_sessions seapig_router_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seapig_router_sessions
    ADD CONSTRAINT seapig_router_sessions_pkey PRIMARY KEY (id);


--
-- Name: stats_counter status_name_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stats_counter
    ADD CONSTRAINT status_name_pkey PRIMARY KEY (status_table, status_name);


--
-- Name: task_hooks task_hooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_hooks
    ADD CONSTRAINT task_hooks_pkey PRIMARY KEY (id);


--
-- Name: task_statuses task_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_statuses
    ADD CONSTRAINT task_statuses_pkey PRIMARY KEY (id);


--
-- Name: task_values task_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_values
    ADD CONSTRAINT task_values_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: values values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."values"
    ADD CONSTRAINT values_pkey PRIMARY KEY (id);


--
-- Name: worker_statuses worker_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_statuses
    ADD CONSTRAINT worker_statuses_pkey PRIMARY KEY (id);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- Name: artifacts_created_at_storage_handler_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artifacts_created_at_storage_handler_id_idx1 ON public.artifacts USING btree (created_at, storage_handler, id);


--
-- Name: artifacts_execution_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artifacts_execution_id_idx1 ON public.artifacts USING btree (execution_id) WHERE (execution_id IS NOT NULL);


--
-- Name: artifacts_task_id_name_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX artifacts_task_id_name_idx1 ON public.artifacts USING btree (task_id, name) WHERE (task_id IS NOT NULL);


--
-- Name: broken_artifacts3_id_max_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX broken_artifacts3_id_max_idx ON public.broken_artifacts3 USING btree (id, max);


--
-- Name: broken_artifacts_id_min_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX broken_artifacts_id_min_idx ON public.broken_artifacts USING btree (id, min);


--
-- Name: execution_hooks_updated_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_hooks_updated_at_idx ON public.execution_hooks USING btree (updated_at);


--
-- Name: execution_statuses_execution_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_statuses_execution_id_idx ON public.execution_statuses USING btree (execution_id);


--
-- Name: execution_statuses_execution_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_statuses_execution_id_idx1 ON public.execution_statuses USING btree (execution_id) WHERE current;


--
-- Name: execution_values_execution_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_values_execution_id_idx ON public.execution_values USING btree (execution_id);


--
-- Name: execution_values_execution_id_value_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_values_execution_id_value_id_idx ON public.execution_values USING btree (execution_id, value_id);


--
-- Name: execution_values_value_id_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_values_value_id_id_idx ON public.execution_values USING btree (value_id, id);


--
-- Name: execution_values_value_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_values_value_id_idx ON public.execution_values USING btree (value_id);


--
-- Name: executions_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX executions_user_id_idx ON public.executions USING btree (user_id);


--
-- Name: index_seapig_router_sessions_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_seapig_router_sessions_on_key ON public.seapig_router_sessions USING btree (key);


--
-- Name: resource_statuses_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_statuses_resource_id_created_at_idx ON public.resource_statuses USING btree (resource_id, created_at) WHERE (task_id IS NULL);


--
-- Name: resource_statuses_resource_id_created_at_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_statuses_resource_id_created_at_idx1 ON public.resource_statuses USING btree (resource_id, created_at) WHERE (task_id IS NOT NULL);


--
-- Name: resource_statuses_resource_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_statuses_resource_id_idx ON public.resource_statuses USING btree (resource_id) WHERE current;


--
-- Name: resource_statuses_task_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_statuses_task_id_idx ON public.resource_statuses USING btree (task_id);


--
-- Name: resources_task_statuses_task_status_id_resource_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resources_task_statuses_task_status_id_resource_id_idx ON public.resources_task_statuses USING btree (task_status_id) INCLUDE (resource_id);


--
-- Name: seapig_dependencies_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX seapig_dependencies_id_idx ON public.seapig_dependencies USING btree (id) WHERE (current_version <> reported_version);


--
-- Name: seapig_dependencies_name_current_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX seapig_dependencies_name_current_version_idx ON public.seapig_dependencies USING btree (name, current_version);


--
-- Name: seapig_router_session_states_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX seapig_router_session_states_index_1 ON public.seapig_router_session_states USING btree (seapig_router_session_id, state_id);


--
-- Name: seapig_router_sessions_key_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX seapig_router_sessions_key_token_index ON public.seapig_router_sessions USING btree (key, token);


--
-- Name: seapig_router_sessions_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX seapig_router_sessions_token_index ON public.seapig_router_sessions USING btree (token);


--
-- Name: task_statuses_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_status_idx ON public.task_statuses USING btree (status) WHERE (current = true);


--
-- Name: task_statuses_task_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_task_id_idx ON public.task_statuses USING btree (task_id) WHERE current;


--
-- Name: task_statuses_task_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_task_id_idx1 ON public.task_statuses USING btree (task_id) WHERE (current AND (status = 'waiting'::text));


--
-- Name: task_statuses_task_id_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_task_id_idx2 ON public.task_statuses USING btree (task_id) WHERE (current AND (status = 'assigned'::text));


--
-- Name: task_statuses_worker_id_created_at_task_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_worker_id_created_at_task_id_idx ON public.task_statuses USING btree (worker_id, created_at, task_id) WHERE (current AND (status = 'assigned'::text));


--
-- Name: task_statuses_worker_id_task_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_statuses_worker_id_task_id_idx ON public.task_statuses USING btree (worker_id, task_id) WHERE (current AND (status = 'accepted'::text));


--
-- Name: task_values_task_id_value_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_values_task_id_value_id_idx ON public.task_values USING btree (task_id, value_id);


--
-- Name: tasks_execution_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tasks_execution_id_idx ON public.tasks USING btree (execution_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: values_id_property_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX values_id_property_id_idx ON public."values" USING btree (id, property_id);


--
-- Name: values_property_id_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX values_property_id_id_idx ON public."values" USING btree (property_id, id);


--
-- Name: values_property_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX values_property_id_idx ON public."values" USING btree (property_id);


--
-- Name: worker_statuses_worker_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_statuses_worker_id_idx1 ON public.worker_statuses USING btree (worker_id) WHERE current;


--
-- Name: workers_name_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workers_name_id_idx ON public.workers USING btree (name, id);


--
-- Name: execution_statuses trigger_update_stats_counter_on_execution_statuses; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_stats_counter_on_execution_statuses AFTER INSERT OR UPDATE ON public.execution_statuses FOR EACH ROW EXECUTE FUNCTION public.update_stats_counter();


--
-- Name: task_statuses trigger_update_stats_counter_on_task_statuses; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_stats_counter_on_task_statuses AFTER INSERT OR UPDATE ON public.task_statuses FOR EACH ROW EXECUTE FUNCTION public.update_stats_counter();


--
-- PostgreSQL database dump complete
--

