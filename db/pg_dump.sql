--
-- PostgreSQL database dump
--

--
-- dumpped as user schedy with:
-- pg_dump --schema-only --no-owner --no-privileges scheduler > pg_dump.sql
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: artifacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artifacts (
    id integer NOT NULL,
    task_id integer,
    name text,
    mimetype text,
    data bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    execution_id integer
);


--
-- Name: artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artifacts_id_seq OWNED BY artifacts.id;


--
-- Name: execution_hooks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE execution_hooks (
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

CREATE SEQUENCE execution_hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE execution_hooks_id_seq OWNED BY execution_hooks.id;


--
-- Name: execution_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE execution_statuses (
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

CREATE SEQUENCE execution_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE execution_statuses_id_seq OWNED BY execution_statuses.id;


--
-- Name: execution_values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE execution_values (
    id integer NOT NULL,
    execution_id integer,
    value_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: execution_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE execution_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execution_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE execution_values_id_seq OWNED BY execution_values.id;


--
-- Name: executions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE executions (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data jsonb
);


--
-- Name: executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE executions_id_seq OWNED BY executions.id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE properties (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE properties_id_seq OWNED BY properties.id;


--
-- Name: resource_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resource_statuses (
    id integer NOT NULL,
    task_id integer,
    description jsonb,
    resource_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    current boolean
);


--
-- Name: resource_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resource_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resource_statuses_id_seq OWNED BY resource_statuses.id;


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resources (
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

CREATE SEQUENCE resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resources_id_seq OWNED BY resources.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seapig_dependencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE seapig_dependencies (
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

CREATE SEQUENCE seapig_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seapig_dependencies_id_seq OWNED BY seapig_dependencies.id;


--
-- Name: seapig_dependency_version_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE seapig_dependency_version_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_dependency_version_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seapig_dependency_version_seq OWNED BY seapig_dependencies.current_version;


--
-- Name: seapig_router_session_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE seapig_router_session_states (
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

CREATE SEQUENCE seapig_router_session_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_router_session_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seapig_router_session_states_id_seq OWNED BY seapig_router_session_states.id;


--
-- Name: seapig_router_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE seapig_router_sessions (
    id integer NOT NULL,
    key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: seapig_router_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE seapig_router_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seapig_router_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE seapig_router_sessions_id_seq OWNED BY seapig_router_sessions.id;


--
-- Name: task_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_statuses (
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

CREATE SEQUENCE task_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_statuses_id_seq OWNED BY task_statuses.id;


--
-- Name: task_values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_values (
    id integer NOT NULL,
    task_id integer,
    value_id integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: task_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_values_id_seq OWNED BY task_values.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tasks (
    id integer NOT NULL,
    execution_id integer,
    description jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    nickname text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "values" (
    id integer NOT NULL,
    property_id integer,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE values_id_seq OWNED BY "values".id;


--
-- Name: worker_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE worker_statuses (
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

CREATE SEQUENCE worker_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE worker_statuses_id_seq OWNED BY worker_statuses.id;


--
-- Name: workers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workers (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workers_id_seq OWNED BY workers.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY artifacts ALTER COLUMN id SET DEFAULT nextval('artifacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY execution_hooks ALTER COLUMN id SET DEFAULT nextval('execution_hooks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY execution_statuses ALTER COLUMN id SET DEFAULT nextval('execution_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY execution_values ALTER COLUMN id SET DEFAULT nextval('execution_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY executions ALTER COLUMN id SET DEFAULT nextval('executions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY properties ALTER COLUMN id SET DEFAULT nextval('properties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_statuses ALTER COLUMN id SET DEFAULT nextval('resource_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources ALTER COLUMN id SET DEFAULT nextval('resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY seapig_dependencies ALTER COLUMN id SET DEFAULT nextval('seapig_dependencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY seapig_router_session_states ALTER COLUMN id SET DEFAULT nextval('seapig_router_session_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY seapig_router_sessions ALTER COLUMN id SET DEFAULT nextval('seapig_router_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_statuses ALTER COLUMN id SET DEFAULT nextval('task_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_values ALTER COLUMN id SET DEFAULT nextval('task_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "values" ALTER COLUMN id SET DEFAULT nextval('values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY worker_statuses ALTER COLUMN id SET DEFAULT nextval('worker_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workers ALTER COLUMN id SET DEFAULT nextval('workers_id_seq'::regclass);


--
-- Name: artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artifacts
    ADD CONSTRAINT artifacts_pkey PRIMARY KEY (id);


--
-- Name: execution_hooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY execution_hooks
    ADD CONSTRAINT execution_hooks_pkey PRIMARY KEY (id);


--
-- Name: execution_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY execution_statuses
    ADD CONSTRAINT execution_statuses_pkey PRIMARY KEY (id);


--
-- Name: execution_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY execution_values
    ADD CONSTRAINT execution_values_pkey PRIMARY KEY (id);


--
-- Name: executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY executions
    ADD CONSTRAINT executions_pkey PRIMARY KEY (id);


--
-- Name: properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: resource_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_statuses
    ADD CONSTRAINT resource_statuses_pkey PRIMARY KEY (id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: seapig_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY seapig_dependencies
    ADD CONSTRAINT seapig_dependencies_pkey PRIMARY KEY (id);


--
-- Name: seapig_router_session_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY seapig_router_session_states
    ADD CONSTRAINT seapig_router_session_states_pkey PRIMARY KEY (id);


--
-- Name: seapig_router_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY seapig_router_sessions
    ADD CONSTRAINT seapig_router_sessions_pkey PRIMARY KEY (id);


--
-- Name: task_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_statuses
    ADD CONSTRAINT task_statuses_pkey PRIMARY KEY (id);


--
-- Name: task_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_values
    ADD CONSTRAINT task_values_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "values"
    ADD CONSTRAINT values_pkey PRIMARY KEY (id);


--
-- Name: worker_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY worker_statuses
    ADD CONSTRAINT worker_statuses_pkey PRIMARY KEY (id);


--
-- Name: workers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- Name: artifacts_execution_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX artifacts_execution_id_idx ON artifacts USING btree (execution_id) WHERE (execution_id IS NOT NULL);


--
-- Name: artifacts_task_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX artifacts_task_id_idx ON artifacts USING btree (task_id) WHERE (execution_id IS NOT NULL);


--
-- Name: artifacts_task_id_name_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX artifacts_task_id_name_idx ON artifacts USING btree (task_id, name);


--
-- Name: artifacts_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX artifacts_updated_at_idx ON artifacts USING btree (updated_at);


--
-- Name: execution_hooks_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_hooks_updated_at_idx ON execution_hooks USING btree (updated_at);


--
-- Name: execution_statuses_execution_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_statuses_execution_id_idx ON execution_statuses USING btree (execution_id);


--
-- Name: execution_statuses_execution_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_statuses_execution_id_idx1 ON execution_statuses USING btree (execution_id) WHERE current;


--
-- Name: execution_statuses_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_statuses_updated_at_idx ON execution_statuses USING btree (updated_at);


--
-- Name: execution_values_execution_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_values_execution_id_idx ON execution_values USING btree (execution_id);


--
-- Name: execution_values_execution_id_value_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_values_execution_id_value_id_idx ON execution_values USING btree (execution_id, value_id);


--
-- Name: execution_values_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_values_updated_at_idx ON execution_values USING btree (updated_at);


--
-- Name: execution_values_value_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX execution_values_value_id_idx ON execution_values USING btree (value_id);


--
-- Name: executions_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX executions_updated_at_idx ON executions USING btree (updated_at);


--
-- Name: executions_user_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX executions_user_id_idx ON executions USING btree (user_id);


--
-- Name: index_seapig_router_sessions_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_seapig_router_sessions_on_key ON seapig_router_sessions USING btree (key);


--
-- Name: properties_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX properties_updated_at_idx ON properties USING btree (updated_at);


--
-- Name: resource_statuses_resource_id_created_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX resource_statuses_resource_id_created_at_idx ON resource_statuses USING btree (resource_id, created_at) WHERE (task_id IS NULL);


--
-- Name: resource_statuses_resource_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX resource_statuses_resource_id_idx ON resource_statuses USING btree (resource_id) WHERE current;


--
-- Name: resource_statuses_task_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX resource_statuses_task_id_idx ON resource_statuses USING btree (task_id);


--
-- Name: resources_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX resources_updated_at_idx ON resources USING btree (updated_at);


--
-- Name: seapig_dependencies_expr_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX seapig_dependencies_expr_idx ON seapig_dependencies USING btree (((current_version <> reported_version))) WHERE (current_version <> reported_version);


--
-- Name: seapig_dependencies_name_current_version_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX seapig_dependencies_name_current_version_idx ON seapig_dependencies USING btree (name, current_version);


--
-- Name: seapig_router_session_states_index_1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX seapig_router_session_states_index_1 ON seapig_router_session_states USING btree (seapig_router_session_id, state_id);


--
-- Name: seapig_router_session_states_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX seapig_router_session_states_updated_at_idx ON seapig_router_session_states USING btree (updated_at);


--
-- Name: seapig_router_sessions_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX seapig_router_sessions_updated_at_idx ON seapig_router_sessions USING btree (updated_at);


--
-- Name: task_statuses_task_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_statuses_task_id_idx ON task_statuses USING btree (task_id) WHERE current;


--
-- Name: task_statuses_task_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_statuses_task_id_idx1 ON task_statuses USING btree (task_id) WHERE (current AND (status = 'waiting'::text));


--
-- Name: task_statuses_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_statuses_updated_at_idx ON task_statuses USING btree (updated_at);


--
-- Name: task_values_task_id_value_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX task_values_task_id_value_id_idx ON task_values USING btree (task_id, value_id);


--
-- Name: tasks_execution_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_execution_id_idx ON tasks USING btree (execution_id);


--
-- Name: tasks_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tasks_updated_at_idx ON tasks USING btree (updated_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_updated_at_idx ON users USING btree (updated_at);


--
-- Name: values_property_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX values_property_id_idx ON "values" USING btree (property_id);


--
-- Name: values_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX values_updated_at_idx ON "values" USING btree (updated_at);


--
-- Name: worker_statuses_worker_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX worker_statuses_worker_id_idx1 ON worker_statuses USING btree (worker_id) WHERE current;


--
-- Name: workers_updated_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX workers_updated_at_idx ON workers USING btree (updated_at);

--
-- created_at: if that table exits the scheduler-init.sh script assumes db is set up
-- should be at the end of the scipt.
--

CREATE TABLE db_created_at (
    time_stamp timestamp without time zone NOT NULL
);

--
-- PostgreSQL database dump complete
--

