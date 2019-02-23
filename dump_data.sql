--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--





--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;






--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1 (Debian 11.1-1.pgdg90+1)
-- Dumped by pg_dump version 11.1 (Debian 11.1-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1 (Debian 11.1-1.pgdg90+1)
-- Dumped by pg_dump version 11.1 (Debian 11.1-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgres;

--
-- Name: hdb_views; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_views;


ALTER SCHEMA hdb_views OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: hdb_table_oid_check(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.hdb_table_oid_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (EXISTS (SELECT 1 FROM information_schema.tables st WHERE st.table_schema = NEW.table_schema AND st.table_name = NEW.table_name)) THEN
      return NEW;
    ELSE
      RAISE foreign_key_violation using message = 'table_schema, table_name not in information_schema.tables';
      return NULL;
    END IF;
  END;
$$;


ALTER FUNCTION hdb_catalog.hdb_table_oid_check() OWNER TO postgres;

--
-- Name: inject_table_defaults(text, text, text, text); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        r RECORD;
    BEGIN
      FOR r IN SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = tab_schema AND table_name = tab_name AND column_default IS NOT NULL LOOP
          EXECUTE format('ALTER VIEW %I.%I ALTER COLUMN %I SET DEFAULT %s;', view_schema, view_name, r.column_name, r.column_default);
      END LOOP;
    END;
$$;


ALTER FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) OWNER TO postgres;

--
-- Name: google__insert__public__joey_user(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.google__insert__public__joey_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."joey_user"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ('true') THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."joey_user" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."joey_user" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."joey_user" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."joey_user" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.google__insert__public__joey_user() OWNER TO postgres;

--
-- Name: user__insert__public__startup_details(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.user__insert__public__startup_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."startup_details"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ((EXISTS  (SELECT  1  FROM "public"."joey_user" AS "_be_0_public_joey_user" WHERE (((("_be_0_public_joey_user"."h_id") = (NEW."user_h_id")) AND ('true')) AND ((((("_be_0_public_joey_user"."auth_token") = (((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text)) OR ((("_be_0_public_joey_user"."auth_token") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text) IS NULL))) AND ('true')) AND ('true')))     )) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."startup_details" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."startup_details" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."startup_details" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."startup_details" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__startup_details() OWNER TO postgres;

--
-- Name: user__insert__public__startup_post(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.user__insert__public__startup_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."startup_post"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ((EXISTS  (SELECT  1  FROM "public"."startup_details" AS "_be_0_public_startup_details" WHERE (((("_be_0_public_startup_details"."id") = (NEW."startup_details_id")) AND ('true')) AND ((EXISTS  (SELECT  1  FROM "public"."joey_user" AS "_be_1_public_joey_user" WHERE (((("_be_1_public_joey_user"."h_id") = ("_be_0_public_startup_details"."user_h_id")) AND ('true')) AND ((((("_be_1_public_joey_user"."auth_token") = (((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text)) OR ((("_be_1_public_joey_user"."auth_token") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text) IS NULL))) AND ('true')) AND ('true')))     )) AND ('true')))     )) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."startup_post" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."startup_post" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."startup_post" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."startup_post" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__startup_post() OWNER TO postgres;

--
-- Name: user__insert__public__student_details(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.user__insert__public__student_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."student_details"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ((EXISTS  (SELECT  1  FROM "public"."joey_user" AS "_be_0_public_joey_user" WHERE (((("_be_0_public_joey_user"."h_id") = (NEW."user_hid")) AND ('true')) AND ((((("_be_0_public_joey_user"."auth_token") = (((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text)) OR ((("_be_0_public_joey_user"."auth_token") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text) IS NULL))) AND ('true')) AND ('true')))     )) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."student_details" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."student_details" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."student_details" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."student_details" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__student_details() OWNER TO postgres;

--
-- Name: user__insert__public__user_detail(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.user__insert__public__user_detail() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."user_detail"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ((EXISTS  (SELECT  1  FROM "public"."joey_user" AS "_be_0_public_joey_user" WHERE (((("_be_0_public_joey_user"."h_id") = (NEW."user_h_id")) AND ('true')) AND ((((("_be_0_public_joey_user"."auth_token") = (((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text)) OR ((("_be_0_public_joey_user"."auth_token") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text) IS NULL))) AND ('true')) AND ('true')))     )) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."user_detail" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."user_detail" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."user_detail" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."user_detail" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__user_detail() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.event_invocation_logs OWNER TO postgres;

--
-- Name: event_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_id text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL,
    next_retry_at timestamp without time zone
);


ALTER TABLE hdb_catalog.event_log OWNER TO postgres;

--
-- Name: event_triggers; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.event_triggers (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    name text,
    type text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    configuration json,
    comment text
);


ALTER TABLE hdb_catalog.event_triggers OWNER TO postgres;

--
-- Name: hdb_check_constraint; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_check_constraint AS
 SELECT (n.nspname)::text AS table_schema,
    (ct.relname)::text AS table_name,
    (r.conname)::text AS constraint_name,
    pg_get_constraintdef(r.oid, true) AS "check"
   FROM ((pg_constraint r
     JOIN pg_class ct ON ((r.conrelid = ct.oid)))
     JOIN pg_namespace n ON ((ct.relnamespace = n.oid)))
  WHERE (r.contype = 'c'::"char");


ALTER TABLE hdb_catalog.hdb_check_constraint OWNER TO postgres;

--
-- Name: hdb_foreign_key_constraint; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_foreign_key_constraint AS
 SELECT (q.table_schema)::text AS table_schema,
    (q.table_name)::text AS table_name,
    (q.constraint_name)::text AS constraint_name,
    (min(q.constraint_oid))::integer AS constraint_oid,
    min((q.ref_table_table_schema)::text) AS ref_table_table_schema,
    min((q.ref_table)::text) AS ref_table,
    json_object_agg(ac.attname, afc.attname) AS column_mapping,
    min((q.confupdtype)::text) AS on_update,
    min((q.confdeltype)::text) AS on_delete
   FROM ((( SELECT ctn.nspname AS table_schema,
            ct.relname AS table_name,
            r.conrelid AS table_id,
            r.conname AS constraint_name,
            r.oid AS constraint_oid,
            cftn.nspname AS ref_table_table_schema,
            cft.relname AS ref_table,
            r.confrelid AS ref_table_id,
            r.confupdtype,
            r.confdeltype,
            unnest(r.conkey) AS column_id,
            unnest(r.confkey) AS ref_column_id
           FROM ((((pg_constraint r
             JOIN pg_class ct ON ((r.conrelid = ct.oid)))
             JOIN pg_namespace ctn ON ((ct.relnamespace = ctn.oid)))
             JOIN pg_class cft ON ((r.confrelid = cft.oid)))
             JOIN pg_namespace cftn ON ((cft.relnamespace = cftn.oid)))
          WHERE (r.contype = 'f'::"char")) q
     JOIN pg_attribute ac ON (((q.column_id = ac.attnum) AND (q.table_id = ac.attrelid))))
     JOIN pg_attribute afc ON (((q.ref_column_id = afc.attnum) AND (q.ref_table_id = afc.attrelid))))
  GROUP BY q.table_schema, q.table_name, q.constraint_name;


ALTER TABLE hdb_catalog.hdb_foreign_key_constraint OWNER TO postgres;

--
-- Name: hdb_function; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_function (
    function_schema text NOT NULL,
    function_name text NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_function OWNER TO postgres;

--
-- Name: hdb_function_agg; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_function_agg AS
 SELECT (p.proname)::text AS function_name,
    (pn.nspname)::text AS function_schema,
        CASE
            WHEN (p.provariadic = (0)::oid) THEN false
            ELSE true
        END AS has_variadic,
        CASE
            WHEN ((p.provolatile)::text = ('i'::character(1))::text) THEN 'IMMUTABLE'::text
            WHEN ((p.provolatile)::text = ('s'::character(1))::text) THEN 'STABLE'::text
            WHEN ((p.provolatile)::text = ('v'::character(1))::text) THEN 'VOLATILE'::text
            ELSE NULL::text
        END AS function_type,
    pg_get_functiondef(p.oid) AS function_definition,
    (rtn.nspname)::text AS return_type_schema,
    (rt.typname)::text AS return_type_name,
        CASE
            WHEN ((rt.typtype)::text = ('b'::character(1))::text) THEN 'BASE'::text
            WHEN ((rt.typtype)::text = ('c'::character(1))::text) THEN 'COMPOSITE'::text
            WHEN ((rt.typtype)::text = ('d'::character(1))::text) THEN 'DOMAIN'::text
            WHEN ((rt.typtype)::text = ('e'::character(1))::text) THEN 'ENUM'::text
            WHEN ((rt.typtype)::text = ('r'::character(1))::text) THEN 'RANGE'::text
            WHEN ((rt.typtype)::text = ('p'::character(1))::text) THEN 'PSUEDO'::text
            ELSE NULL::text
        END AS return_type_type,
    p.proretset AS returns_set,
    ( SELECT COALESCE(json_agg(pt.typname), '[]'::json) AS "coalesce"
           FROM (unnest(COALESCE(p.proallargtypes, (p.proargtypes)::oid[])) WITH ORDINALITY pat(oid, ordinality)
             LEFT JOIN pg_type pt ON ((pt.oid = pat.oid)))) AS input_arg_types,
    to_json(COALESCE(p.proargnames, ARRAY[]::text[])) AS input_arg_names
   FROM (((pg_proc p
     JOIN pg_namespace pn ON ((pn.oid = p.pronamespace)))
     JOIN pg_type rt ON ((rt.oid = p.prorettype)))
     JOIN pg_namespace rtn ON ((rtn.oid = rt.typnamespace)))
  WHERE (((pn.nspname)::text !~~ 'pg_%'::text) AND ((pn.nspname)::text <> ALL (ARRAY['information_schema'::text, 'hdb_catalog'::text, 'hdb_views'::text])) AND (NOT (EXISTS ( SELECT 1
           FROM pg_aggregate
          WHERE ((pg_aggregate.aggfnoid)::oid = p.oid)))));


ALTER TABLE hdb_catalog.hdb_function_agg OWNER TO postgres;

--
-- Name: hdb_permission; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_permission (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    role_name text NOT NULL,
    perm_type text NOT NULL,
    perm_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_permission_perm_type_check CHECK ((perm_type = ANY (ARRAY['insert'::text, 'select'::text, 'update'::text, 'delete'::text])))
);


ALTER TABLE hdb_catalog.hdb_permission OWNER TO postgres;

--
-- Name: hdb_permission_agg; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_permission_agg AS
 SELECT hdb_permission.table_schema,
    hdb_permission.table_name,
    hdb_permission.role_name,
    json_object_agg(hdb_permission.perm_type, hdb_permission.perm_def) AS permissions
   FROM hdb_catalog.hdb_permission
  GROUP BY hdb_permission.table_schema, hdb_permission.table_name, hdb_permission.role_name;


ALTER TABLE hdb_catalog.hdb_permission_agg OWNER TO postgres;

--
-- Name: hdb_primary_key; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_primary_key AS
 SELECT tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    json_agg(constraint_column_usage.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN ( SELECT x.tblschema AS table_schema,
            x.tblname AS table_name,
            x.colname AS column_name,
            x.cstrname AS constraint_name
           FROM ( SELECT DISTINCT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_depend d,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (d.refclassid = ('pg_class'::regclass)::oid) AND (d.refobjid = r.oid) AND (d.refobjsubid = a.attnum) AND (d.classid = ('pg_constraint'::regclass)::oid) AND (d.objid = c.oid) AND (c.connamespace = nc.oid) AND (c.contype = 'c'::"char") AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND (NOT a.attisdropped))
                UNION ALL
                 SELECT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (nc.oid = c.connamespace) AND (r.oid =
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confrelid
                            ELSE c.conrelid
                        END) AND (a.attnum = ANY (
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confkey
                            ELSE c.conkey
                        END)) AND (NOT a.attisdropped) AND (c.contype = ANY (ARRAY['p'::"char", 'u'::"char", 'f'::"char"])) AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])))) x(tblschema, tblname, colname, cstrname)) constraint_column_usage ON ((((tc.constraint_name)::text = (constraint_column_usage.constraint_name)::text) AND ((tc.table_schema)::text = (constraint_column_usage.table_schema)::text) AND ((tc.table_name)::text = (constraint_column_usage.table_name)::text))))
  WHERE ((tc.constraint_type)::text = 'PRIMARY KEY'::text)
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_primary_key OWNER TO postgres;

--
-- Name: hdb_query_template; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_query_template (
    template_name text NOT NULL,
    template_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_query_template OWNER TO postgres;

--
-- Name: hdb_relationship; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);


ALTER TABLE hdb_catalog.hdb_relationship OWNER TO postgres;

--
-- Name: hdb_table; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_table (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_table OWNER TO postgres;

--
-- Name: hdb_unique_constraint; Type: VIEW; Schema: hdb_catalog; Owner: postgres
--

CREATE VIEW hdb_catalog.hdb_unique_constraint AS
 SELECT tc.table_name,
    tc.constraint_schema AS table_schema,
    tc.constraint_name,
    json_agg(kcu.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name))
  WHERE ((tc.constraint_type)::text = 'UNIQUE'::text)
  GROUP BY tc.table_name, tc.constraint_schema, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_unique_constraint OWNER TO postgres;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_version (
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    hasura_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgres;

--
-- Name: remote_schemas; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.remote_schemas (
    id bigint NOT NULL,
    name text,
    definition json,
    comment text
);


ALTER TABLE hdb_catalog.remote_schemas OWNER TO postgres;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE; Schema: hdb_catalog; Owner: postgres
--

CREATE SEQUENCE hdb_catalog.remote_schemas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hdb_catalog.remote_schemas_id_seq OWNER TO postgres;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: hdb_catalog; Owner: postgres
--

ALTER SEQUENCE hdb_catalog.remote_schemas_id_seq OWNED BY hdb_catalog.remote_schemas.id;


--
-- Name: joey_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.joey_user (
    id integer NOT NULL,
    h_id text NOT NULL,
    auth_token text NOT NULL,
    role text DEFAULT 'user'::text NOT NULL
);


ALTER TABLE public.joey_user OWNER TO postgres;

--
-- Name: TABLE joey_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.joey_user IS 'donot touch this table';


--
-- Name: google__insert__public__joey_user; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.google__insert__public__joey_user AS
 SELECT joey_user.id,
    joey_user.h_id,
    joey_user.auth_token,
    joey_user.role
   FROM public.joey_user;


ALTER TABLE hdb_views.google__insert__public__joey_user OWNER TO postgres;

--
-- Name: startup_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.startup_details (
    id integer NOT NULL,
    startup_name text NOT NULL,
    about text NOT NULL,
    website text,
    logo_url text,
    user_h_id text NOT NULL,
    is_verified boolean DEFAULT true NOT NULL,
    poc_name text,
    contact_number text,
    email_id text
);


ALTER TABLE public.startup_details OWNER TO postgres;

--
-- Name: user__insert__public__startup_details; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.user__insert__public__startup_details AS
 SELECT startup_details.id,
    startup_details.startup_name,
    startup_details.about,
    startup_details.website,
    startup_details.logo_url,
    startup_details.user_h_id,
    startup_details.is_verified,
    startup_details.poc_name,
    startup_details.contact_number,
    startup_details.email_id
   FROM public.startup_details;


ALTER TABLE hdb_views.user__insert__public__startup_details OWNER TO postgres;

--
-- Name: startup_post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.startup_post (
    id integer NOT NULL,
    user_hid text NOT NULL,
    internship_title text NOT NULL,
    description text NOT NULL,
    attachement_url text,
    internship_profile text NOT NULL,
    duration text NOT NULL,
    stipend text NOT NULL,
    interns_number text NOT NULL,
    location text NOT NULL,
    research_park_startup text NOT NULL,
    skill_requirement text NOT NULL,
    specific_requirement text,
    accomodation text NOT NULL,
    travel_allowance text NOT NULL,
    other_incentives text,
    address text,
    startup_details_id integer NOT NULL,
    status text DEFAULT 'verifying'::text NOT NULL
);


ALTER TABLE public.startup_post OWNER TO postgres;

--
-- Name: TABLE startup_post; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.startup_post IS 'attachment_url spells wrong';


--
-- Name: user__insert__public__startup_post; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.user__insert__public__startup_post AS
 SELECT startup_post.id,
    startup_post.user_hid,
    startup_post.internship_title,
    startup_post.description,
    startup_post.attachement_url,
    startup_post.internship_profile,
    startup_post.duration,
    startup_post.stipend,
    startup_post.interns_number,
    startup_post.location,
    startup_post.research_park_startup,
    startup_post.skill_requirement,
    startup_post.specific_requirement,
    startup_post.accomodation,
    startup_post.travel_allowance,
    startup_post.other_incentives,
    startup_post.address,
    startup_post.startup_details_id,
    startup_post.status
   FROM public.startup_post;


ALTER TABLE hdb_views.user__insert__public__startup_post OWNER TO postgres;

--
-- Name: student_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_details (
    id integer NOT NULL,
    full_name text NOT NULL,
    roll_num text NOT NULL,
    college text,
    branch text,
    cgpa text,
    contact_number text NOT NULL,
    alt_contact_number text,
    alt_email text,
    resume_url text,
    is_paid boolean DEFAULT false NOT NULL,
    payment_link text,
    payment_id text,
    user_hid text NOT NULL,
    payment_request_id text
);


ALTER TABLE public.student_details OWNER TO postgres;

--
-- Name: user__insert__public__student_details; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.user__insert__public__student_details AS
 SELECT student_details.id,
    student_details.full_name,
    student_details.roll_num,
    student_details.college,
    student_details.branch,
    student_details.cgpa,
    student_details.contact_number,
    student_details.alt_contact_number,
    student_details.alt_email,
    student_details.resume_url,
    student_details.is_paid,
    student_details.payment_link,
    student_details.payment_id,
    student_details.user_hid,
    student_details.payment_request_id
   FROM public.student_details;


ALTER TABLE hdb_views.user__insert__public__student_details OWNER TO postgres;

--
-- Name: user_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_detail (
    id integer NOT NULL,
    name text,
    email text,
    image_url text,
    user_h_id text NOT NULL,
    startup_name text,
    startup_id integer
);


ALTER TABLE public.user_detail OWNER TO postgres;

--
-- Name: TABLE user_detail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.user_detail IS 'startup_name is not used';


--
-- Name: user__insert__public__user_detail; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.user__insert__public__user_detail AS
 SELECT user_detail.id,
    user_detail.name,
    user_detail.email,
    user_detail.image_url,
    user_detail.user_h_id,
    user_detail.startup_name,
    user_detail.startup_id
   FROM public.user_detail;


ALTER TABLE hdb_views.user__insert__public__user_detail OWNER TO postgres;

--
-- Name: joey_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.joey_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.joey_user_id_seq OWNER TO postgres;

--
-- Name: joey_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.joey_user_id_seq OWNED BY public.joey_user.id;


--
-- Name: startup_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.startup_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.startup_details_id_seq OWNER TO postgres;

--
-- Name: startup_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.startup_details_id_seq OWNED BY public.startup_details.id;


--
-- Name: startup_post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.startup_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.startup_post_id_seq OWNER TO postgres;

--
-- Name: startup_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.startup_post_id_seq OWNED BY public.startup_post.id;


--
-- Name: student_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_details_id_seq OWNER TO postgres;

--
-- Name: student_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_details_id_seq OWNED BY public.student_details.id;


--
-- Name: user_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_detail_id_seq OWNER TO postgres;

--
-- Name: user_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_detail_id_seq OWNED BY public.user_detail.id;


--
-- Name: remote_schemas id; Type: DEFAULT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.remote_schemas ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.remote_schemas_id_seq'::regclass);


--
-- Name: google__insert__public__joey_user id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.google__insert__public__joey_user ALTER COLUMN id SET DEFAULT nextval('public.joey_user_id_seq'::regclass);


--
-- Name: google__insert__public__joey_user role; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.google__insert__public__joey_user ALTER COLUMN role SET DEFAULT 'user'::text;


--
-- Name: user__insert__public__startup_details id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__startup_details ALTER COLUMN id SET DEFAULT nextval('public.startup_details_id_seq'::regclass);


--
-- Name: user__insert__public__startup_details is_verified; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__startup_details ALTER COLUMN is_verified SET DEFAULT true;


--
-- Name: user__insert__public__startup_post id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__startup_post ALTER COLUMN id SET DEFAULT nextval('public.startup_post_id_seq'::regclass);


--
-- Name: user__insert__public__startup_post status; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__startup_post ALTER COLUMN status SET DEFAULT 'verifying'::text;


--
-- Name: user__insert__public__student_details id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__student_details ALTER COLUMN id SET DEFAULT nextval('public.student_details_id_seq'::regclass);


--
-- Name: user__insert__public__student_details is_paid; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__student_details ALTER COLUMN is_paid SET DEFAULT false;


--
-- Name: user__insert__public__user_detail id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__user_detail ALTER COLUMN id SET DEFAULT nextval('public.user_detail_id_seq'::regclass);


--
-- Name: joey_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joey_user ALTER COLUMN id SET DEFAULT nextval('public.joey_user_id_seq'::regclass);


--
-- Name: startup_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_details ALTER COLUMN id SET DEFAULT nextval('public.startup_details_id_seq'::regclass);


--
-- Name: startup_post id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_post ALTER COLUMN id SET DEFAULT nextval('public.startup_post_id_seq'::regclass);


--
-- Name: student_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_details ALTER COLUMN id SET DEFAULT nextval('public.student_details_id_seq'::regclass);


--
-- Name: user_detail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail ALTER COLUMN id SET DEFAULT nextval('public.user_detail_id_seq'::regclass);


--
-- Data for Name: event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_id, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at) FROM stdin;
\.


--
-- Data for Name: event_triggers; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.event_triggers (id, name, type, schema_name, table_name, configuration, comment) FROM stdin;
\.


--
-- Data for Name: hdb_function; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_function (function_schema, function_name, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_permission; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_permission (table_schema, table_name, role_name, perm_type, perm_def, comment, is_system_defined) FROM stdin;
public	joey_user	google	insert	{"set": {}, "check": {}, "columns": ["auth_token", "h_id", "role"]}	\N	f
public	joey_user	google	select	{"filter": {"h_id": {"_eq": "X-HASURA-USER-H-ID"}}, "columns": ["auth_token", "h_id", "id", "role"], "allow_aggregations": false}	\N	f
public	joey_user	user	select	{"filter": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}, "columns": ["auth_token", "h_id", "id", "role"], "allow_aggregations": false}	\N	f
public	joey_user	google	update	{"filter": {"h_id": {"_eq": "X-HASURA-USER-H-ID"}}, "columns": ["id", "h_id", "auth_token", "role"]}	\N	f
public	joey_user	anonymous	select	{"filter": {}, "columns": ["id", "h_id", "auth_token", "role"], "allow_aggregations": true}	\N	f
public	startup_post	user	insert	{"set": {}, "check": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"]}	\N	f
public	startup_post	user	select	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"], "allow_aggregations": true}	\N	f
public	startup_post	user	update	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"]}	\N	f
public	startup_post	anonymous	select	{"filter": {}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"], "allow_aggregations": true}	\N	f
public	startup_post	user	delete	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}}	\N	f
public	user_detail	user	insert	{"set": {}, "check": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "image_url", "name", "startup_id", "startup_name", "user_h_id"]}	\N	f
public	user_detail	user	select	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "id", "image_url", "name", "startup_id", "startup_name", "user_h_id"], "allow_aggregations": true}	\N	f
public	user_detail	user	update	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "image_url", "name", "startup_id", "startup_name", "user_h_id"]}	\N	f
public	user_detail	user	delete	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}	\N	f
public	startup_details	user	select	{"filter": {"userDetailsBystartupId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["id", "startup_name", "about", "website", "logo_url", "user_h_id", "is_verified", "poc_name", "contact_number", "email_id"], "allow_aggregations": true}	\N	f
public	startup_details	user	insert	{"set": {}, "check": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["about", "contact_number", "email_id", "is_verified", "logo_url", "poc_name", "startup_name", "user_h_id", "website"]}	\N	f
public	startup_details	user	update	{"set": {}, "filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["about", "contact_number", "email_id", "is_verified", "logo_url", "poc_name", "startup_name", "user_h_id", "website"]}	\N	f
public	student_details	user	insert	{"set": {}, "check": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "resume_url", "roll_num", "user_hid"]}	\N	f
public	student_details	user	select	{"filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "id", "is_paid", "payment_id", "payment_link", "resume_url", "roll_num", "user_hid"], "allow_aggregations": true}	\N	f
public	student_details	user	update	{"set": {}, "filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "resume_url", "roll_num", "user_hid"]}	\N	f
\.


--
-- Data for Name: hdb_query_template; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_query_template (template_name, template_defn, comment, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_relationship; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_relationship (table_schema, table_name, rel_name, rel_type, rel_def, comment, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	detail	object	{"manual_configuration": {"remote_table": {"name": "tables", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	primary_key	object	{"manual_configuration": {"remote_table": {"name": "hdb_primary_key", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	columns	array	{"manual_configuration": {"remote_table": {"name": "columns", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	foreign_key_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_foreign_key_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	relationships	array	{"manual_configuration": {"remote_table": {"name": "hdb_relationship", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_permission_agg", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	check_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_check_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	unique_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_unique_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	event_log	trigger	object	{"manual_configuration": {"remote_table": {"name": "event_triggers", "schema": "hdb_catalog"}, "column_mapping": {"trigger_id": "id"}}}	\N	t
hdb_catalog	event_triggers	events	array	{"manual_configuration": {"remote_table": {"name": "event_log", "schema": "hdb_catalog"}, "column_mapping": {"id": "trigger_id"}}}	\N	t
hdb_catalog	event_invocation_logs	event	object	{"foreign_key_constraint_on": "event_id"}	\N	t
hdb_catalog	event_log	logs	array	{"foreign_key_constraint_on": {"table": {"name": "event_invocation_logs", "schema": "hdb_catalog"}, "column": "event_id"}}	\N	t
public	user_detail	joeyUserByuserHId	object	{"foreign_key_constraint_on": "user_h_id"}	\N	f
public	joey_user	userDetailsByuserHId	array	{"foreign_key_constraint_on": {"table": "user_detail", "column": "user_h_id"}}	\N	f
public	joey_user	startupDetailssByuserHId	array	{"foreign_key_constraint_on": {"table": "startup_details", "column": "user_h_id"}}	\N	f
public	startup_details	joeyUserByuserHId	object	{"foreign_key_constraint_on": "user_h_id"}	\N	f
hdb_catalog	hdb_function_agg	return_table_info	object	{"manual_configuration": {"remote_table": {"name": "hdb_table", "schema": "hdb_catalog"}, "column_mapping": {"return_type_name": "table_name", "return_type_schema": "table_schema"}}}	\N	t
public	joey_user	startupPostsByuserHid	array	{"foreign_key_constraint_on": {"table": "startup_post", "column": "user_hid"}}	\N	f
public	startup_post	joeyUserByuserHid	object	{"foreign_key_constraint_on": "user_hid"}	\N	f
public	startup_details	startupPostsBystartupDetailsId	array	{"foreign_key_constraint_on": {"table": "startup_post", "column": "startup_details_id"}}	\N	f
public	startup_post	startupDetailsBystartupDetailsId	object	{"foreign_key_constraint_on": "startup_details_id"}	\N	f
public	startup_details	userDetailsBystartupId	array	{"foreign_key_constraint_on": {"table": "user_detail", "column": "startup_id"}}	\N	f
public	user_detail	startupDetailsBystartupId	object	{"foreign_key_constraint_on": "startup_id"}	\N	f
public	joey_user	studentDetailssByuserHid	array	{"foreign_key_constraint_on": {"table": "student_details", "column": "user_hid"}}	\N	f
public	student_details	joeyUserByuserHid	object	{"foreign_key_constraint_on": "user_hid"}	\N	f
\.


--
-- Data for Name: hdb_table; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_table (table_schema, table_name, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	t
information_schema	tables	t
information_schema	schemata	t
information_schema	views	t
hdb_catalog	hdb_primary_key	t
information_schema	columns	t
hdb_catalog	hdb_foreign_key_constraint	t
hdb_catalog	hdb_relationship	t
hdb_catalog	hdb_permission_agg	t
hdb_catalog	hdb_check_constraint	t
hdb_catalog	hdb_unique_constraint	t
hdb_catalog	hdb_query_template	t
hdb_catalog	event_triggers	t
hdb_catalog	event_log	t
hdb_catalog	event_invocation_logs	t
hdb_catalog	remote_schemas	t
public	user_detail	f
public	joey_user	f
public	startup_details	f
hdb_catalog	hdb_function_agg	t
hdb_catalog	hdb_function	t
hdb_catalog	hdb_version	t
public	startup_post	f
public	student_details	f
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_version (version, upgraded_on, hasura_uuid, cli_state, console_state) FROM stdin;
9	2019-01-30 18:33:30.164662+00	3b56b023-457d-49c3-a677-9648e2584c01	{}	{"telemetryNotificationShown": true}
\.


--
-- Data for Name: remote_schemas; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.remote_schemas (id, name, definition, comment) FROM stdin;
\.


--
-- Data for Name: joey_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.joey_user (id, h_id, auth_token, role) FROM stdin;
2472	116000450446927027712	76dfc8a71dbf3b01ee7da3f778cf525a96045765	user
1820	111030578426826726626	8ef9de03f9267a288420f428ef86ac41b86a4ca4	user
1324	110011265617786100962	033929a3c2fabff5f227637479c334bf6601ffe5	user
1594	106407488023143571708	8185d1cbb03b3950f9bf471020ab54676fbc5d1a	user
2188	103158308128328545694	9a7ba22723eb6a8dc53e590270053dafb368f615	user
2060	105202096528458362102	17db57b839e23c42aa28b05c98ef90f36bbb08f6	user
1547	103546078731885007120	86254e1a7a4d18528d06f540a0f80bb111bd26d3	user
1643	102476915533780948091	152e8b52b339aaf006d32a11c584b9aaa656c0b3	user
1786	116519274255305915920	db66121dba3e363dee4edd22e6e52156def23153	user
1922	101189951357074482183	5b9fb8de42927a8895827b0c401780e76724ee6e	user
2031	107429974676687296166	de7ee0f0246bbfdb3deff23234ea8e13c30ab939	user
1590	102584910929681137125	588e6ae6294fc222a7988fb2dcba0741aa5d6a40	user
1652	100898145044469393733	8d38a727f5f85b2688a841c4849bb2d2f648f5b1	user
1403	113824673222077196247	a9a7e9a03fd6223d37cc7337f555211a0611db86	user
1348	107156601039704846020	f79ac0c6a6efd2649528173086bc2c6ac7ebfef9	user
2228	109266082501365237941	eabe5a95237593b22f58beebcfe7fef3024808ca	user
1780	113564221505157815723	6f727eea4093d36a8e8b0432e88db612996f744b	user
1448	116445166814243602711	b29ab84c615454cbb09c1f267b3cd7b9d13ba428	user
1640	100916162979211575903	f9765bdfd4dd4cd341e6550b66f0146882a747a2	user
2145	109683991238473547277	5029b8c090c2d07aa47c598a1e1defa5ce9fb28e	user
1754	115802938042318956916	b674633c5b63389b71008c81c5dda817a68c15ec	user
1969	110274344916933599324	015872ef1201e021d42820541af13c84a1291c29	user
1546	103656407720006034171	81ad65a56283e7ba040e3a949867b6a491c176bd	user
1563	103563223572046648148	2d8296c5a0e7faf8753b3be63c3bcf1d7b1d572f	user
2198	101396729595279031815	65e27b093759182a8ae7735a13e027eb8b3959f3	user
1513	106774401436596091547	068ebd2ad761a6ff502ac10dd9aba7d82d9076e4	user
2158	101107640131204357570	02d2e086ca1811e1565a0e9bf3f71a9ef8299fdb	user
1794	117013339697530495306	8faf2b46f743a04ac25e4136b63cd60105dfd036	user
1288	116040530755962342318	ee4db3e99e05154bf3a6d7983f2c294825c2303b	user
1488	110553366885836969408	c6c1a4359b6ca8b26b59a59a49abae8cd051c928	user
2097	104821578026829852225	9aea0e91ca2e00c23367ea34c304c239450264f7	user
1822	114503787094540282981	03f062b70b8af4c524125c5f73630e9010c66fb9	user
1625	101818747050100224079	b5d937df3481ea2f2c12f5476131e95a21fdc9d0	user
1648	104379184185174428302	9a56f832417869ec7db7d3d9a54523c724a0e8dc	user
1899	115375476385745576962	2871171b477abbc4376cf00fbd5593787e63743e	user
2379	103319782156851133364	b8480f5ccb088025e3ea846d8de32f8a84ebca18	user
1807	114749538391689307031	a5ec4819edacde892af8d425a394849509b253ad	user
1549	116836169810745668980	9faa8273ca4cf97d7cd8c7471c0a2dc602108541	user
2196	106289280886691331250	557d2096b4fd010c14f1a478b4bde138a6d09e3d	user
1308	103441912139943416551	2688170673e43f6ca0193e09800ddbc30cebcf2d	user
2203	115342870212009600095	7ffe0bc79bb86abde7a93d2bf5d4ce2017fc1753	user
2229	101056800285643890923	62cc014a960e6c15316745c4b0ba5aa3fa463678	user
2201	111320166102807820736	2ac6875fdd5900a06bdb0ccf25b5ee8b9af54efa	user
2221	111687598935683751002	8e76b0ff585c630f7af0312dce478711d235d621	user
1565	107530024622485449869	e0056b98a100c1bf4b0da9a11ab70547e9570ca6	user
2230	107564555087017130990	e0659b971ade013f39c9eba4dea03ed8387aac1f	user
1894	107813869731075135750	c1426bf12ff30d22b3e206abef6e9199d6c10b4d	user
2231	110959428559525986265	013c71a4bb21ba77e63007e72deb5873b47d5639	user
1659	110447218383396106962	8eb96a0bd3c2ebb05ed79b7e2538a74dca2d4c84	user
1622	110505594872527456493	7601a739daabf9fa9cd936f2b1378a2ecf6230dd	user
2106	103304235098083374178	de3a375f0b13294a4765373e81fa62cb59ee7c2f	user
2225	103782240804789880108	0ccfd1870f2dcd00a82ff42c828f68a7cda37e68	user
1582	109140945875383774158	a85a96a3abbff28e1438867c27b2466bcc34ae26	user
2232	106711601084471424539	ebc6cda92a9ecd865775634e88b12de97c4098eb	user
2233	115023583903933855531	42331377940b3082df745c09bf208637e8e36b5e	user
1339	106123538173898449055	2b607913fbc1cf5e394b595b4062f281451a57d8	user
2235	109234805044650346236	1410254eccee31be692a6cd2f1e57ec884829d09	user
2236	113903073200127800235	4bd22382b0ac95fc82955c68685ab6165872568f	user
2241	108896450923947891853	891762c2c78a957b8b150483cd5a0eb4dc16a8e6	user
1862	117894875203741245699	d45ac8ffd77dfbef54abc1e4fd333d7fc7a8b618	user
1572	104298758991766668035	bac31d05c357128769cd74bace565bb7dd3332cd	user
1787	111133250649424423782	85de4ae5db4b7b29c7e6801e490a417805f07ec1	user
2248	102641646898857644341	94fdff9e22079b9c4d1a8982aa9920df19e979b8	user
1928	109249031263145344654	705c6ca3bd9161bc02b86ef7fc528823b88085d9	user
2253	111287724851133369161	0cb6828500b4bfa07d08e6c8e5c93d858d358e5f	user
1768	102540152476572591754	06db9389d7c822e633835912cac92c01e66d132e	user
1548	105373738578694994605	e1a546d62302cebf85d26d7477d095d513f99ff7	user
2255	107831550891832625063	91eac38ff9d5a46c1c3e590d01702a3ce54a7f05	user
1753	108825759819157028428	30125f97319f9a318473508502cb921fb432b44d	user
2257	110296223890564310627	9f19a3702f2e69194bea3638cf90744742259df4	user
2261	106840195352712555805	8d1068acac082459f613681a77eacd47f8847fc5	user
2266	103413867609203995396	751a61f782b86b482a25ba49b2632eee34d6a875	user
2268	115583909410869064703	eb9f33c15c436031d0280e688db5ed6ed1e35a7e	user
2238	101907162894505620447	0577670f8d2486053ec36edd3db88d571875d47c	user
2026	103686313929651160614	9adabd0e25caca3fd2d328e9cf84b75e34862394	user
2211	111049789719558186993	9b47fdacfbf61bc49ffc35b038456a9e92f5a544	user
1834	101326090802695787002	deb08f6e9ed75727ccb15747acc3639a7dc704b7	user
2279	113375788251733149094	c206c99d107710492be2d7fd4b054649eb1b9c89	user
2291	115020366769667334416	4a784c0ed2f3ed00772b01509cf16f215c6f2524	user
2430	105500817840272313799	ad7475300889c0b3d99b92b647fbe003ea912a4b	user
2312	113035858086387927034	eeda45c16bdabc33ef1ce30c7c4697e8b9a4c927	user
2317	114537148790063843816	9004b588d5db5841548519756d816fc1bf87e511	user
2318	103083422834575225895	01a795fbfbcbeb30a1e0ceb42a3d8767f0ee3562	user
1314	110540228254791393418	ba742b109e7f2f48799f915208924305ae44f6e4	user
2528	114839727532236749919	1af22599e2f457b15f4219650de79209d40a5bfd	user
2310	116687833430096689153	2828b7ca8465a1b0d25cf4b0336e770ebb62b119	user
2391	106907442348505117600	d2e535189721952ba0b5123d1933956569798ccb	user
2541	117537405273454723771	f2d659a419b759c84328872ae3ad95c2eeea4c32	user
2531	105791111294087052325	61990eab933551838df908e7575a467d7db40b9d	user
2129	104089503500603657430	e6512b35071283b0447f4ad09ab3d35cec3f7e02	user
2298	108454550000095213572	10bd4b1f7339499e84659692af0b59b669bc3167	user
2322	114818886750636854304	47be2aa044d2ff260f89421ad531e348579a7adf	user
2566	107266261851940045387	90761b8116211735abd04c33af5980e473e5f2aa	user
2395	110988755828086628184	38d045da5fef112c1835e34ac68c2c5526b33d7c	user
2451	100680093250543498335	338089c8222d64b387927fb95e43b682f8371cb8	user
2568	117045864410082434432	3e27eecc224c794e393231ce46331026fc1c75db	user
2412	105502414900621283479	f262daaa32284105150241e7c5e7671032d9ada0	user
2442	105528835513377079359	afbdbccfb47ea533b54b67de987be46e438b46af	user
1415	118208723166374240159	dd0fc7c74f7728aa9dc0bb155034d9a8f48bc7e8	user
2533	117306459721549242620	453a51d1d765337f6f83b489534d51ffb0188b4c	user
2473	112150566284259074738	4946515a09dac64ba3cc977b5720211a3fd5656d	user
2508	114268811780135391116	6d9370a531046537b914e809d43861b88eec0e29	user
2576	103765838603107363304	bb83c6f518ba4c9ee1e3afe8ce9463a80f9c923a	user
2583	103007413487745509743	037f71dee0257b07840e6980dab8b4d20f790477	user
\.


--
-- Data for Name: startup_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_details (id, startup_name, about, website, logo_url, user_h_id, is_verified, poc_name, contact_number, email_id) FROM stdin;
224	Propelld	Propelld is re-thinking education lending from the ground up. Education, even though one of the most talked of subjects in the country, still suffers from a lack of financial access for the 80%ile of income population who don’t have the income means to qualify for loans from traditional Banks. Propelld, with its approach of accountable education lending by using future income as the key metric, has emerged as the top-most lender in this space. With a client base boasting of more than 100 Institutes & 800 centres across India and the who’s who of Education Providers within just 12 months of operations, Propelld’s fast growth has attracted Pre-Series A investment from top Tier A VCs of the Indian Eco-system. With a changing education and hiring landscape, the Govt. push towards skilling and the focus of employees on re-skilling, Propelld stands on the cusp as the leader in the exciting space of vertically integrated education loans.\n	www.propelld.com	https://ibb.co/KqxkbBk	107530024622485449869	t	Victor Senapaty	9920175773	victor@propelld.com
225	Wishup	The job market is changing rapidly. We believe that Remote Working is the future! \nWishup provides trained virtual employees to the very talented new-age entrepreneurs and SME owners globally. Read more about us at www.wishup.co	https://www.wishup.co/	https://imgur.com/a/RfVMozR	104298758991766668035	t	Vivek Gupta	8447754003	vivek@wishup.co
226	Phoakt	PhoaktPhoakt			109140945875383774158	t	Phoakt		
228	automaxis	For the issue of paper based document handling in cross border trade, automaxis is a blockchain enable document digitization platform that gives a time & cost benefit along with creating a tamper proof environment. We have initiated a pilot with a Pharma exporter that exports to 53 countries.	http://www.autom-axis.com	http://autom-axis.com/wp-content/uploads/2017/05/cropped-cropped-automaxis-logo-400281-2.png	101818747050100224079	t	Block chain pilot for doc. digitisation	8688745584	pratik@autom-axis.com
229	Karexpert Technologies Private Limited 	Karexpert Technologies Pvt. Ltd. is a ''Digital Healthcare Technology Platform'' intent to provide services in top 100 cities of India. \nKareXpert is a Pioneer in designing technology platform with a Patient centric approach to make “Patient Continuity” a reality in Indian Healthcare. We are the only technology Company to design patented “Advanced Health Cloud Technology Stack” which connects Patients with all the care Providers -Hospitals, Nursing homes, Clinics, Doctors, Pharmacy shops, Diagnostic labs, Imaging Center, Blood Bank, Organ Bank, and Ambulance. Our Innovative Solutions are compatible to run on any Smart device-Mobile, Tablet, Laptop, Desktop via Mobile App & Web App.\n\nKareXpert Working Culture\nIt’s important to cultivate a positive company culture, so here in Karexpert you have a freedom to think and express your ideas. Karexpert is the best place to learn and give a drastic growth to your skills set. We beleive in continuous learning and improving environment.\n\n	www.karexpert.com	https://www.karexpert.com/	106407488023143571708	t	Pooja	9882065886	pooja.chaudhary@karexpert.com
231	Srjna	SRJNA is a hybrid education model using real & virtual teaching aids to impart 5D classroom experiential learning and smart online assessment platform with deep analytics for K-10 students, teachers and parents. \n\nWe believe that 'True learning comes when it's being experienced', to ensure this we continuously build teaching aids & methodologies and provide to associated schools. SRJNA, a brand of Elation Edtech Pvt Ltd, Initiated by 4 alumni of IITs and XLRI is now a team of 15 enthusiasts who want to make a disruptive change in school education. \n\nSeed funded by Rajasthan Angel Investor Network, SRJNA has been incubated at Startup Oasis, mentored by CIIE-IIM Ahmedabad, University of California - Berkely and recognized by IITs, IIMs, XLRI, Department of Science and Technology (DST) and Rajasthan Education Initiative (REI). We have empowered 25000+ students , 500+ teachers and 80+ schools in Delhi NCR, Rajasthan, Punjab, Haryana & Gujrat.	https://www.srjna.com/	https://www.srjna.com/assets/img/home/logoblack.png	102476915533780948091	t	Nikita Panchal	6377719749	hr@srjna.com
233	RentSher	RentSher is India and UAE’s only Omnichannel Rental Concierge Service for Rental products related to Events, Electronics, A/V and Medical needs.  While \nRentSher started as a peer to peer rental marketplace, overtime we shifted focus to a vendor led model enabling rental businesses to list their products and receive orders through our platform. With a mission of “Renting Made Easy”, we provide a one-stop-shop for rentals with easy discoverability, full transparency and end to end service including doorstep delivery. RentSher has made renting products as easy as booking a bus or a movie ticket - whether its a 1 day or multi-month rental. \n Our India operations hub is Bangalore and the UAE ops are run from Dubai. The tech development, digital and marketing functions are centralized at Bangalore for both countries. \n \nToday, 700 vendors across 10 cities in the two countries provide rental products and services through RentSher.\nOver 100 SMEs and startups and more than 60,000 customers have made use of RentSher’s services. This year alone we have provided rentals for more than 3000 events. 	www.rentsher.com, www.rentsher.ae	https://web_rentsher_india.gumlet.com/images/rent-sher-logo.svg?format=auto&compress=true	115802938042318956916	t	Anubha Verma	8861677739	anubha@rentsher.com
260	Cos-X 	Singapore based tech start-up with development and business operations in India.	www.cos-x.com		101107640131204357570	t	Lalitha	8008032033	hrexpert@cos-x.com
201	Addverb Technologies Pvt Ltd	Addverb Technologies provides Robotic Integration, Warehouse Automation & Industrial IoT solutions by leveraging Industry 4.0 technologies. Our extensive experience in the field of intralogistics automation enables us to design the best solution based on the requirement of our customers. We provide customizable, modular, robust and innovative solutions to cater to the needs of an increasingly digital supply chain. We deliver the modern warehouses of the future, Today.	https://www.addverb.in/		106123538173898449055	t	Ankita Modi	9717228691	ankita.modi@addverb.in
232	ScrapKaroCash	“ScrapKaroCash” is a scrap facilitator and scrap procurer service under waste management Clean Technology where customers will not only get an option to sell their scrap but also redeem coupons; inspired by Digital India, SBM (Swachh Bharat Mission)\nIt’s working on listed domains:-\n1- B2C \n2- B2B \n3- Trade\n4- Compost.\n5- SBM.\nAs of now we’ve lifted more than 150mT of scrap having 150+ active & Key clients.\n\n\nRecognition and Achievements made by this startup till today’s date are mentioned below :-\n1- IMPORT EXPORT LICENSE \nIEC- AAHCC0310R\n2- Attended as a Delegate in INDIA- ITALY technology summit valedictory session held by Indian PM Honourable Shri Narendra Modi and Italy PM Dr. H. E. Conte at Hotel Taj, New Delhi, 29-30 October, 2018.\n3- Invited for a summit held in Moscow with Indian, Russian embassies at 10-14 December, 2018\n4- BITS PILANI shortlisted all over India, top 50 startups.\n5-  Invited by PM Honourable Shri               Narendra Modi for video conferencing  live broadcasted on 06 June, 2018 at DD  News.\n6- MINISTRY OF CORPORATE AFFAIRS\n     CIN- U74999UP2017PTC093731\n7- Shortlisted  in IIM Lucknow at UP Startup Conclave \n8-MINISTRY OF COMMERCE & INDUSTRY (DIPP8978)\n9- Article published on Dainik Jagran Lucknow, 16th September,2018\n10-Letter of Recommendation by Indian Army MAJ. Gen. K.N. Mirji.\n11- GSTIN (09AAHCC0310R1ZJ)\n12- Avail the benefits of MUDRA in the form of CC.\n13-Letter of Recommendation by KLS GIT, PRINCIPAL.\n14- Shortlisted for annual business plan competition organised by IIM, Lucknow.\n	https://www.scrapkarocash.com	https://drive.google.com/file/d/12Rkl-FM-T-bqbhUhQxg6z0TJcDACTf_H/view?usp=drivesdk	110447218383396106962	t	Manvendra Pratap Singh	9480494001	manvendra@scrapkarocash.com
234	iB Hubs	B Hubs is a PAN India startup hub which provides end-to-end assistance to startups. We are working towards nurturing a culture of innovation and entrepreneurship in every nook and corner of India. Till date, iB Hubs has supported more than 100 startups across India. iB Hubs is an initiative of iB Group - a vibrant team of 200+ individuals, majorly comprising of alumni of premier institutions like IIMs, IITs, NITs and BITS and corporate alumni of major MNCs. \n\niB Hubs regularly offers internships/jobs to students from premier national institutes like IITs, IIITs, NITs, BITS etc in various domains like Cyber Security, IoT, Software Development, Management, etc.. 	ibhubs.co		105373738578694994605	t	Sowmya Bezawada	8008900903	hr@ibhubs.co
235	ProYuga Advanced Technologies Limited	ProYuga Advanced Technologies Ltd. develops transformative products in Virtual, Augmented and Mixed Reality.\n\nProYuga has launched its first product iB Cricket, a new format of cricket, in the presence of Shri Ram Nath Kovind, Hon'ble President. iB Cricket is a vSport which provides the world's most immersive Virtual Reality cricket experience.\n\niB Cricket is developed by a team of young graduates from premier institutes like IITs, IIMs, IIIT Hyderabad, etc. For more details, visit our website.\n	proyuga.tech, ib.cricket		102540152476572591754	t	Sowmya Bezawada	8008900903	hr@proyuga.tech
236	Involve Learning Solutions	Involve is an international award winning social start-up founded by young leaders from IIT Madras. We are working to develop future ready skills in school students via Peer teaching. Our clients range from International schools to the corporation of Chennai. \nWe are currently working in Chennai and Bangalore & are supported by Singapore international Foundation, US consulate, & Northwestern University.	www.involveedu.com	https://drive.google.com/open?id=1HLzMKYIo6symjOKJYpkpBcfZHdGnVruK	113564221505157815723	t	Divanshu Kumar	9087864370	divanshu@involveedu.com
237	Voylla Fashion Pvt Ltd	Website: www.voylla.com\n\nCompany Profile:\n\nVoylla is India's leading fashion jewellery brand. In a short span, Voylla has created a niche in the lifestyle segment with a strong omnichannel presence. With a stronghold on manufacturing fashion jewelry, use of the state if the art technology, Voylla is on its way to create history by traversing a territory yet uncharted\n\nThe costume jewelry (also known as Imitation jewelry and fashion jewelry) category operates in what could be the most fragmented market. The competition can well and truly get down to the ubiquitous roadside vendor. Hence, it genuinely offers challenge and opportunity as two sides of the same coin. This category has existed for ages but curiously it doesn’t boast of a single brand worth its logo, at least till today.\n\nIn the last four years, we have made sustained efforts to understand the customer; set up a robust back-end supported by technology with an edge and finely detailed curating. This shows in our repertoire of over 13,000 designs on our site, which gets refreshed with almost new 1,000 designs every week. Over 5 lakh customers have patronized us, making us the top jewelry site in the country.\n\nWith 200+ existing stores we are now all set to come closer to you where you can touch and feel every piece of jewelry before buying them. This is just another step towards providing you a 360-degree, omnichannel experience. With a highly competent management team consisting of top business school, fashion and technology institute alumnus (IIT, NIT, NIFT,etc.) and e-retail company veterans, we aim to create a great lifestyle experience for our esteemed customers\n\nVoylla is leading this exciting journey as a category leader and is on its way to build an aspirational and a durable brand, which will stand for value, quality and irresistible choices. \n\nYour valuable response will be awaited.\nRegards	Website: www.voylla.com	Website: www.voylla.com	111133250649424423782	t	Rahul Joshi	9982205733	rahul.joshi@voylla.com
238	ION Energy INC	Our planet is going through a fundamental shift away from fossil fuels. ION Energy's mission is to accelerate this shift by building cutting-edge energy storage products and services. Founded by a team of PhD Engineers from Stanford, Penn State and IIT with decades of experience in advanced electronics and battery systems, our groundbreaking patented technology acts as the core of high performance applications like Electric Vehicles, Telecom Towers, Data centres & More.\n\nOur cutting-edge BMS capabilities bundled with proprietary software & cloud analytics platforms drastically improves battery performance & enables real-time fleet management.\n\nWe are looking to build deep meaningful partnerships with high-growth potential companies to help them become industry leaders in the inevitably growing Li-ION battery market. To partner with us, reach out at hello@ionenergy.co or visit www.ionenergy.co for more information.\n\nWe're still in search of top talent as we disrupt the battery industry. Know any ambitious and fun-loving people in software, engineering, or operations that want to make new moves in 2019?\nRefer them at work@ionenergy.co	https://www.ionenergy.co/	https://www.ionenergy.co/	117013339697530495306	t	Valentina Dsouza	9945328921	valentina@ionenergy.co
242	Planetworx Technologies Pvt Ltd	Planetworx Technologies is a US incorporated and Bangalore based 2 year old B2B startup with a GDPR compliant audience insights SaaS platform called Trapyz (www.trapyz.com). \n\nPlanetworx is an alumnus of industry leading accelerators like CISCO Launchpad, Pitney Bowes and now part of Airbus Bizlab program. \n\nTrapyz enables behavioural and intent-based segmenting of in-market audiences by analyzing multiple device sensor data. They work with app platforms to enrich consumer data and create additional revenue streams by monetising data for right targeting of consumers. The platform monetizes non-PII data by creating interest profiles based on real world visitation patterns and in-app intents (No personally identifiable information like phone number, e-mail ID or a device ID is captured or used).\n \nOur vision is to make digital marketing more consumer friendly without infringing privacy. The mission is to be the one-stop shop to map offline consumer journeys by leveraging multi-dimensional data in the real world.	www.trapyz.com	https://drive.google.com/open?id=1L62yeGMlkUDQUZDyC5ttRt3ZyRm8tgks	114749538391689307031	t	Ranganathan	9886562627	ranga@planetworx.in
243	Vidyukta Technology Solutions Pvt Ltd	Vidyukta Technology Solutions is founded by IITM alumni, to develop products using new ideas in Deep Learning.			108825759819157028428	t	Sirish Somanchi	9849309056	sirishks@yahoo.com
268	WELLNESYS TECHNOLOGIES PRIVATE LIMITED	At Wellnesys,  our focus is on building innovative systems and intelligent solutions for tracking and delivering holistic wellness of individual.  We unify the best of Ancient sciences(Yoga, Ayurveda, Accupressure, Naturopathy) and Modern technology (IoT, AI, Edge Computing) to create world-class products. Wellness is a stepping stone for reaching one's highest potential. Our Vision is to make holistic wellness accessible for everyone and integrate as part of their lifestyle.	www.wellnesys.com	http://www.wellnesys.com/index.html	101907162894505620447	t	Muralidhar	9611922116	muralidhars@wellnesys.com
230	White Data Systems India Private Limited 	White Data Systems India Private Limited (WDSI) is a private limited company, incorporated in April 2015, which seeks to improve reliability and Quality of service through innovative and integrated technology solutions to the Road Freight & Transport Sector through its i-Loads platform.  WDSI provides a holistic and comprehensive range of services, providing tangible benefits to truck operators, booking agents, brokers and load providers at an optimal price. Being a TVS Logistics subsidiary and having cholamandalam as our investor provides us the expertise to deliver at a superior quality to our clients and also grow at a higher pace.	www.iloads.in		110505594872527456493	t	chitra	9940158710	chitra.c@iloads.in
283	Test999	Teannx n			110553366885836969408	t	Saurbah	8559931413	me16b071@smail.iitm.ac.in
244	Gramophone	At Gramophone we strive to create a difference in farming by bringing timely information, technology and right kind of inputs to achieve better yields for farmers. Our endeavour is to bring the best products and knowledge to the farmers. Gramophone is one stop solution for all kinds of inputs for the farmers. Farmers can buy genuine crop protection, crop nutrition, seeds, implements and agri hardware at their doorstep.\n\nWe believe that technology can remove information asymmetry in the agriculture system. Farmers can access localised package of practice, crop advisory, weather information coupled with the best products to grow. This will improve the productivity and help farmers sustainably increase the income from agriculture.	www.gramophone.in	http://www.gramophone.in/images/gramophone_logo.png	114503787094540282981	t	Drusilla Pereira	9535104208	drusilla@gramophone.co.in
245	EngineerBabu IT Services Private Limited	At EngineerBabu, we offer an expansive suite of cutting-edge IT services to improve your business processes by seamlessly integrating new technology with your existing systems.\nOur services have enabled visionary global giants like Tata Steel and Samsung in building diverse and customized technologies. An in depth analysis of your needs and requirements help us built professional products.	www.engineerbabu.com	https://www.engineerbabu.com/assets/home/logo_purple_80.png	101326090802695787002	t	Anjali Mishra Tiwari	7415182268	hr@ebabu.co
246	Driver Friends	P2P network for cab and auto drivers to crowdsource daily information related to their professions.	NA	NA	117894875203741245699	t	Deepak Sahoo	7020520742	flashiitm@gmail.com
249	Stanza Living	Stanza Living is a technology-enabled student co-living concept which is disrupting the multi-billion-dollar student housing market by putting the student, as a consumer, at the heart of the product and service design, development and execution. From smart space planning in rooms to gamifying food (cutting edge Food-as-a-Service concepts), from creating common areas for engagement and community living to deliver reliable, predictable and standardized services to residents through back-end technology integration, Stanza is challenging the status quo when it comes to student community living. For the first time, we are making student accommodation an experience product in line with evolved hospitality areas like hotels, guest houses and serviced apartments.	http://www.stanzaliving.com	https://media.licdn.com/dms/image/C560BAQEoUG1P_SLraA/company-logo_400_400/0?e=1558569600&v=beta&t=j1luUl9qFfL55KeBSrLmu7DQS7PSb0H5_QeQQDZivCk	115375476385745576962	t	Vibhor Kumar	9999445431	vibhor.kumar@stanzaliving.com
250	Mammoth Analytics	Mammoth is a cloud-based, self serve data management platform focused on the complete data journey from sourcing to insights - with a special focus on data wrangling. \nOur goal is to make data accessible to the non-technical user in a way that any overheads of dealing with data are eliminated.\nOur engineering team is based in Bangalore and regularly deals with matters of solid engineering design, scale, and usability. By interning with Mammoth you would experience this whole process in a very cozy startup setting.	https://mammoth.io/	https://mammoth.io/wp-content/themes/mammoth_wp_theme/images/mammoth-logo.svg	100916162979211575903	t	Pankaj Ratan Lal	9164604660	pankaj@mammoth.io
251	AllEvents.in	AllEvents.in is the world's largest event discovery platform with more than 200 million events from over 30,000 cities of the world.\n\nUniquely harnessing the power of social media, AllEvents.in collects, sorts, categorizes and systematically displays information related to events based on a user’s selected geolocation. The platform presents event information in a manner that facilitates simple discovery. \n\nAllEvents.in is the connecting bridge between Organizers and Event Attendees. We are changing how people discover events, how organizers find their potential audience & how they both engage with each other. \n	https://allevents.in	https://allevents.s3.amazonaws.com/media-kit/ae-logo.png	109249031263145344654	t	Chandresh Vaghanani	+917698993837	chandresh@allevents.in
252	BackBuckle.io	BackBuckle.io enables you to build/enhance/innovate/prototype/experiment your app at 10X time faster and at 12X time reduced cost, saving 30000+ development time. BackBuckle.io, which is a Feature-as-a-Service (FaaS) cloud platform which provides a suite of ready-to-use features and functionalities to\n\n1. Instantly add features/build functionalities to an existing or new App(Mobile/Web/IoT) with just a few API calls!\n2. Build the entire backend of an app in record time.\n3. Quick prototyping of new features for the app.\n4. Dynamically control the total behavior (UI, Data & Logic) of your client's apps making it custom fit your client's users. \n5. Rapid experimentations\n\n\nBackBuckle.io is the winner of Elevate-X 2018 by IIT Madras	https://backbuckle.io	https://backbuckle.io/assets/Logo.png	110274344916933599324	t	Ashwin Kumar	9901010860	jobs@backbuckle.io
253	Eduvanz Financing Private Limited	Eduvanz is a new age Digital Finance Company that provides Education Loans starting from Zero Interest for Students and Skill Seekers.\n\nEduvanz was founded to offer convenient and flexible financial assistance to Students and Leaders who want Quick Results, Attractive Benefits and Transparent Conversations.\n	www.eduvanz.com	https://eduvanz.com/assets/webimages/logo.png	107429974676687296166	t	Bikash Behera	9769480264	bikash.behera@eduvanz.com
258	QuNu Labs Pvt Ltd	We provide cyber-security using principles of quantum physics and quantum optics. We want to change the way people look at data security by making it unhackable!	www.qunulabs.in		104089503500603657430	t	Snehal Gupta	8095506128	snehal@qunulabs.in
257	Manage Artworks	ManageArtworks is a Packaging Artwork Management Software as part of Karomi Technology Private Limited, that helps regulated industries like Pharmaceuticals and CPG to ensure regulatory compliance of their pack labels. We work on artwork management which is a niche domain where there is scope to combine cutting edge technologies from both Computer Vision and Natural Language Processing in an optimal fashion, along with the possibility to work on Computer Graphics.	https://www.manageartworks.com/	https://www.manageartworks.com/wp-content/uploads/2017/11/imageedit_7_7219679184-300x126.png	103304235098083374178	t	Sreenivas	9952940461	sreenivas@karomi.com
259	Medha Innovation and Development Pvt. Ltd	MID is a Tech based startup company working with  AI in biological data analysis and building platform using Big Data Technology over cloud.\n\nMID have its own patented algorithms known for accuracy in prediction.\n\nSkill Area : Bioinformatics , Data Analysis , Bio statistics, Python , AI , D3 js,  Data visualization. 	www.medhaid.com	http://medhaid.com/images/midlogo.png	109683991238473547277	t	Amogh Bhatnagar	9039049182	amogh.bhatnagar53@gmail.com 
262	Chatur Ideas	Chatur Ideas is a startup-enabling platform. After acquiring Nurture Talent Academy (India’s first Institute for Entrepreneurs present across 125+ cities and trained more than 34,000 entrepreneurs), Chatur Ideas is training young entrepreneurs across Institutes and providing them access to its vast ecosystem so as to enrich the entrepreneurship culture right from foundation level. \n\n \n\nAlong with helping startups in colleges, it supports mature startups in raising funds, providing mentoring and assists them with a 360-degree execution support in building their ventures to the next level. \nCurrently, we have more than 950 startups under our wings to which we have provided support in each of the above segments and access to our network comprising of almost 1500 Investors.	www.chaturideas.com	https://drive.google.com/open?id=0B695TN-Vw87ZVlBrY1RLeWF1Wk13VloxMlVhTG1DajkxMjI0	101396729595279031815	t	Vishal	9167058897	vishal@chaturideas.com
263	Peacock Solar	India's leading residential solar company aimed at accelerating residential solar using data analytics and efficient finance.	www.peacock.solar	http://www.peacock.solar/wp-content/uploads/2018/10/xpeacocklogo_better-2.png.pagespeed.ic_.caRRPabiB8-min.png	111320166102807820736	t	Aniket Baheti	9705655855	aniket@peacock.solar
272	Genesys	Genesys powers more than 25 billion of the world’s best customer experiences every year. And top-industry analysts agree: Genesys is the only leader in both cloud and on-premises customer experience solutions.\n\nGreat customer experience drives great business outcomes. More than 11,000 companies in over 100 countries trust Genesys. That’s how we became the industry’s #1 customer experience platform. Helping companies deliver seamless omnichannel customer journeys and build lasting relationships is what we do. From marketing, to sales, to service—make every moment count.	http://www.genesys.com		105202096528458362102	t	Thilagar Thangaraju	+91 44 4019 3548	Thilagar.Thangaraju@genesys.com
273	Genesys Telecom Labs	Genesys is the global omnichannel customer experience and contact center solution leader. Our customer experience platform and solutions help companies engage effortlessly with their customers, across all touchpoints, channels and interactions to deliver differentiated customer journeys, while maximizing revenue and loyalty. In 2012, the ownership of Genesys transferred from Alcatel-Lucent to a company controlled by the Permira Funds with participation from Technology Crossover Ventures. Today, Genesys operates as a standalone company. We help organizations across all industries define the journeys that matter most to customers by delivering consistent experiences to every touchpoint	https://www.genesys.com/	https://www.genesys.com/	108454550000095213572	t	Thilagar	+91 978 659 8656	thilagar.thangaraju@genesys.com
274	Thin Film Solutions - Consultants and Project Executors	Thin Film Solutions is taking a project on Health Care working on new concepts in detecting and estimating pathogens cultured in the laboratory. 	www.thinfilmsolutions.org		103319782156851133364	t	Dr A Subrahmanyam	91-8939526241	tfsmanu@gmail.com
275	Global Mantra Innovations (A Ventech Solutions company)	GMI, the Research & innovation arm of Ventech Solutions, focuses on building products that we believe will disrupt how healthcare products and services are delivered. Banking on cutting edge technologies such as Artificial Intelligence, machine learning, NLP, predictive modelling, advanced analytics and blockchain, GMI builds to deliver products and IP led services in the areas of population health.	https://www.ventechsolutions.com/ventech-global-innovative-services/	https://www.ventechsolutions.com/ventech-global-innovative-services/	116687833430096689153	t	C.S. Thiyagarajan	9841076032	Thiyagarajan.Somasundaram@GlobalMantrai.com
276	LeanAgri 	LeanAgri is a technology service provider with decision making and activity planning solutions for farmers to increase farm yields and incomes. We work with enterprises to provide best of farm management services to associated farmers and farmer management solutions for enterprises. We are IIT Madras Alumni founded company based in Pune, Maharashtra.	www.leanagri.com	https://www.google.com/search?q=leanagri&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjUuNKyqczgAhWaTn0KHTZ4A_QQ_AUIESgE&biw=1707&bih=803&dpr=1.13#imgrc=SzkCuIoTda-3PM:	110988755828086628184	t	Aman	9309821748	aman.verma@leanagri.com
277	Ah! Ventures	ah! Ventures is a growth catalyst that brings together promising businesses and investors by creating wealth creation opportunities for both. Our unique model serves both investors and entrepreneurs through a unique blend of customised services, skill, and industry and domain experience.\n\nFor investors, we offer a bundle of services that are geared to help you not just locate promising investment opportunities, but also evaluate them in a manner that eliminates doubt, and facilitates savvy decision making. Through our continued involvement in the businesses invested in, and our transparency in all dealings, we provide your investment with that extra edge in security and growth.\n\nFor entrepreneurs, we help you create an environment geared for explosive growth through services that benefit every facet of your business - from funding to recruitment to office space. When you come to us, we go through a detailed program that evaluates your business not just for where you stand today, but for what you can be, given all we have to offer. All our services are geared to help you function at a higher level of efficiency and growth, giving you an edge over competition, and helping you create new benchmarks in quality and performance.	http://www.ahventures.in/		104379184185174428302	t	Baskaran Manimohan	9543282005	baskaran@ahventures.in
280	RackBank Datacenters Pvt Ltd	We are into providing datacenter services specifically dedicated servers and colocation. With our data center parks project we also provide the ready to go live infrastructure with all the required amenities for budding as well as giant players looking for setting their own datacenter facility.	https://www.rackbank.com	https://goo.gl/images/YgNrCp	112150566284259074738	t	Sumi Rawat	+91-9993016098	sumi@rackbank.com
281	Curneu MedTech Innovations Private Limited	Curneu MedTech Innovation is a health care technology firm based at IITM Research Park, Chennai, India, and  Heidelberg, Germany. We work on a motive of building an affordable and innovative healthcare solutions that address the clinical needs thereby bringing better lives for the needy.	www.curneu.com		117306459721549242620	t	David Roshan Cyril	9715707807	david.roshan@curneu.com
284	Vayujal Technologies Pvt. Ltd.	844 million people in the world – one in ten – do not have access to clean water due to a number of factors, such as repeated droughts, lack of natural supply, metal and biological contamination, anthropogenic activities, and poor or inadequate infrastructure.\n\nVayuJal Technologies Pvt. Ltd. develops Atmospheric Water Generators (AWGs) to combat the problem at the global level and to provide affordable, clean and healthy water to everyone facing a water shortage or a water contamination problem, through environmentally sustainable technological solutions. Developed AWG units will provide healthy mineralized water for drinking and normal clean water for other purposes, through a combination of its patented surface engineering technology, energy efficient unit design and mineralization technology, at a cost 20 times lesser than the current bottled mineral water costs.\n\nThese units may also run on off-grid solar panel systems to produce water in remote areas, wherever needed, thus providing affordable clean water to everyone, everywhere. Such machines will enable independent access to clean water for each individual facing water shortage issues in urban, rural, industrial, commercial, or remote regions due to multiple issues. Additionally, these variable capacity machines may fulfil water requirements for specific applications such as irrigation, construction sites, army tanks, etc.	www.vayujal.com	http://www.vayujal.com/	107266261851940045387	t	Ramesh Kumar	8939017761	rameshsoni2100@gmail.com
285	Invention Labs Engineering Products Pvt. Ltd	At Invention Labs, we build technology products that enable and empower people with disabilities and their caregivers. Founded by an IIT Madras alum, we work out of the IIT Madras Research Park. We are a dedicated team of passionate social entrepreneurs who love our work because we are improving the lives of people with disabilities using cutting edge technology.\n\nOur flagship product is Avaz - a picture and text based communication app that helps\nchildren with autism communicate. Used by thousands of children around the world, it has won numerous prestigious awards, including the National Award from the President of India and the MIT TR35 from MIT. It was also the subject of a TED talk.	www.avazapp.com		105500817840272313799	t	Narayanan	9566095596	narayananr@avazapp.com
286	My Ally	Great companies change the world, one problem at a time. And great companies begin with great teams.\nWhat if we told you that you could build a thousand great companies by helping them build great teams?\n\nMy Ally's AI Recruiting Assistant leverages cutting edge NLP and ML to automate Recruiting Processes for Hiring Teams around the world. We manage the entire interview scheduling process - including communicating with candidates - with better-than-human speed and accuracy.\n	https://www.myally.ai/	https://d3fy7yvqddn33x.cloudfront.net/static-prod/images/v091418/MyAllyLogo-Green.png	103765838603107363304	t	Patrick	8498081691	pat@myally.ai
287	FinanceKaart.com 	FinanceKaart.com is a leading comprehensive online marketplace for financial products & services which helps consumers to compare & apply different financial products & avail doorstep services free of cost without visiting to any bank branches.\nWith its blended Phy-gital approach FinanceKaart.com is addressing the needs & working as a financial matchmaker for the entire ecosystem with its unique algorithm.\nFinanceKaart.com is a venture of Renaissance Global Marketing and consulting Pvt.Ltd which is a DIPP recognised Fintech startup with  Certificate No. - DIPP30154	www.financekaart.com 		103007413487745509743	t	Ganga R. Gupta 	9889916009 	info@financekaart.com 
\.


--
-- Data for Name: startup_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_post (id, user_hid, internship_title, description, attachement_url, internship_profile, duration, stipend, interns_number, location, research_park_startup, skill_requirement, specific_requirement, accomodation, travel_allowance, other_incentives, address, startup_details_id, status) FROM stdin;
69	107530024622485449869	Frontend Web Application Development Intern	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.\nNature of Work:\nSAAS Product for Training institutes & Financial Institutions\nMicro-services based architecture for scalable solution supporting various use cases\nData stream platform around Institutes, students and Financial Institutes\nProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889353/ecell/ymh5rp6ebameawdimgd4.docx	Frontend Web Application Developer	8 weeks	20000	1	Bengaluru	No	•\tBachelor’s and/or Master’s degree, preferably in CS, or equivalent experience\n•\tComfortable coding in JavaScript and Typescript.\n•\tExperience with modern JavaScript libraries and tooling (e.g. React, Redux, Webpack is a plus)\n•\tFluency in HTML, CSS, and related web technologies\n•\tDemonstrated knowledge of Computer Science fundamentals\n•\tFamiliarity with web best practices (e.g., browser capabilities, unit, and integration testing)\n•\tDemonstrated design and UX sensibilities (Hands on Photoshop, XD is a plus )\n	NA	No	No	Informal Dress Code, Perks of a pre-series A funded Startup	#365 Shared office, 3rd floor, 5th sector, Outer ring road, HSR Layout, Bengaluru - 560102	224	verifying
70	107530024622485449869	Backend Web Application Development Internship	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.\nNature of Work:\nSAAS Product for Training institutes & Financial Institutions\nMicro-services based architecture for scalable solution supporting various use cases\nData stream platform around Institutes, students and Financial Institutes\nProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889420/ecell/uelbmaccgipjgicnpfsi.docx	Backend Web Application Developer	8 weeks	20000	2	Bengaluru	No	Bachelor’s and/or Master’s degree, preferably in CS, or equivalent experience.\n·        Good understanding of data structures and algorithms.\n·        Experience coding in any one of the following C++, Java, C#, Nodejs, Python.\n·        Experience building highly-available distributed systems on cloud infrastructure will be plus.\n·        Exposure to architectural pattern of a large, high-scale web application.	NA	No	No	Informal dress code, other perks of working in a pre-series A funded startup	#365 shared office, 3rd floor, 5th sector, Outer ring road, HSR layout, Bengaluru - 560102	224	verifying
71	106407488023143571708	Full stack developer, Java, Machine Learning, Android, Web development, QA	KareXpert is a Pioneer in designing technology platform with a Patient centric approach to make “Patient Continuity” a reality in Indian Healthcare. We are the only technology Company to design patented “Advanced Health Cloud Technology Stack” which connects Patients with all the care Providers -Hospitals, Nursing homes, Clinics, Doctors, Pharmacy shops, Diagnostic labs, Imaging Center, Blood Bank, Organ Bank, and Ambulance. Our Innovative Solutions are compatible to run on any Smart device-Mobile, Tablet, Laptop, Desktop via Mobile App & Web App.		Full stack developer, Java, Machine Learning, Android, Web development, QA	8 weeks	No stipend	4	Gurgaon	no	Core Java,, OOPS Concept, Spring, Hibernate, Html5, CSS, Angular6, Mysql, android framework, SDLC, STLC	B. Tech CS and IT branch only	no	no	n/a	Karepert Technologies Pvt. Ltd.\n405 Universal Trade Tower, 4th Floor, Block - S, Sohna Road, Sector 49, Gurugram, Haryana, 122018	229	verifying
110	105373738578694994605	Director pf Photography	The Director of Photography will be responsible for studio/outdoor shoot of videos like corporate interviews, corporate events, documentaries, etc.		Director pf Photography	Minimum of 2 months	Rs. 10,000/- to Rs. 20,000/- per month	2	Hyderabad	No	1. Thorough knowledge of continuity.\n2. Hands-on experience on any DSLR camera (like Canon 5D, etc.).\n3. Creativity and passion in film and cinematography.\n4. The ability to listen to others and to work well as part of a team.\n5. Good written and verbal communication.\n6. Attention to detail.\n7. Time management skills.\n8. Ability to deliver with in deadlines.\n9. Integrity and the zeal to grow.\n	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	verifying
126	104379184185174428302	Associate	- We are working on various live projects in the domains of Venture Funding, Investment Banking, Community Management, Database Enhancement, Event Creation & Management, Co-working, Marketing, Social & Digital Media Management, Content Creation, Software Development, Application Development		Analyst	Minimum 8 weeks	0	25	Mumbai	No	- MS Excel, MS PowerPoint, MS Word, Analytical skills\n- Undergraduates or PG students from any discipline interested in the above areas\n- Looking for people to start immediately, duration will vary with projects\n- Internship type (Part time/ Full time/ Virtual internship) - All three available\n	No	No	No	Informal dress code, Flexible working hours	B-402, Kemp Plaza, Ram Nagar, Malad West, Mumbai, Maharashtra - 400064	277	verifying
77	117013339697530495306	2019 Summer Intern - Engineering	We are looking to hire enthusiastic university students with a passion for embedded software development and a willingness to learn, to work in various departments across the company in one of the following areas:\n\nPursuing the challenges of bringing up a new development board\nHow to build, test and debug full software stacks on hardware that hasn’t yet been manufactured\nGaining a deeper understanding of system architecture and performance (CPU or GPU)   \nHow to scale a solution for a single developer into an automated real-time regression farm \n\nThen this is a phenomenal opportunity for you! \n\nAt ION Energy we are building the world’s most advanced battery management and intelligence platform. ION was founded by a team of PhD's with decades of experience in advanced electronics and battery systems. Our groundbreaking and patented BMS technology acts as the core of high-performance applications like Electric Vehicles, Telecom Towers, DataCentres & More.\n \nWhat will you be accountable for? \nAs a Intern, you will be placed in a development team at ION’s R&D office situated in Mumbai suburbs, where you will have a dedicated mentor, and be able to get to grips with the problems ranging across many embedded areas. \nYou will work on the development and testing of kernels, device drivers, development tools, and build & test frameworks whilst being supported by and learning from the rest of the team.\nWhilst a lot of our work does involve Open Source software, many tasks require working with development platforms, or simulated hardware environments where features are being developed and tested before the physical devices have been built, so the problems you will be expected to understand and pursue are ones that are yet unknown to the general community.\n\nThis is you : \nCurrently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field\nEnjoy problem solving and working closely with hardware\nWant to become proficient in system programming\nHave sound C/C++ or shell programming\nHave a good understanding of computer architecture and operating systems and want to apply it to the real world.\n\nBenefits\nYour particular stipend will depend on position and type of employment and may be subject to change. Your package will be confirmed on offer of employment. ION Energy’s benefits program provides all interns an opportunity to become permanent employees based on performance and business needs and a platform to stay innovative and create a positive working environment. 	https://res.cloudinary.com/saarang2017/image/upload/v1550052981/ecell/b6nle3jwjrkkugrfjaiv.pdf	Engineering Intern	Minimum 6weeks	15000 INR	2-3	Mumbai	No	- Currently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field\n- Enjoy problem solving and working closely with hardware\n- Want to become proficient in system programming\n- Have sound C/C++ or shell programming\n- Have a good understanding of computer architecture and operating systems and want to apply it to the real world.\n	- College Projects in Embedded Systems and Electronics\n- Understanding of Electrical Engineering Fundamentals\n- General Enthusiasm to learn 	No	No	Informal Dress code, Dedicated mentor, Office location easily accessed by Mumbai metro and close to domestic airport, Free tea/coffee, Office parties. 	ION Energy INC\n703-704 Wellington Business Park, 2, Hasan Pada Road, Marol, Mumbai, Maharashtra 400059	238	verifying
120	101907162894505620447	AI Engineer for YogiFi - The Future Technology of Holistic Wellness	Looking for young and dynamic engineers to work on our award-winning deep-tech technology product at CES 2019 show.  We are looking for engineers with hands-on exposure to ML & AI algorithms. Knowledge with deep Learning libraries like Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy highly desirable. \n\n\n		Data Scientist, Artificial Intelligence 	4-8 weeks 	15000	1	Bangalore	no	Python, Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy 	Desirable to have prior exposure of working with IoT products. 	Own	Own	Informal dress code, flexible work hours	WELLNESYS TECHNOLOGIES Pvt Ltd.,\n2nd Floor, Institute of Inspiring Innovation Business Labs,\n10th B Main Rd, 4th Block, Jayanagar, Bangalore 560041	268	verifying
79	115802938042318956916	ML intern	As a Machine Learning intern you will be working on cutting edge technologies in machine learning and natural language processing. Suited for somebody who enjoys working on complex data mining and analysis problems.\n\nYou will be responsible for designing and developing solutions for one or more of the following \n- automated chatbots and building innovative customer service solutions. \n- predictive inventory management\n- ML recommended surge pricing, delivery pricing.		Machine Learning	6 to 8 weeks	18000 p.m.	2	Bangalore	no	Python, Pandas, Numpy, Machine Learning, Scikit-learn, Natural language processing	Experience in data mining and analysis , Deep Learning will be a added advantage and allow quick ramp-up	No	3rd AC train reimburse	informal dress code, 5 days a week	Current Address \nNo. 248, Nagawara Junction, Thanisandra Main Road, Outer Ring Rd, \nNear Manyata Tech Park, Nagavara, Bengaluru, Karnataka 560045\n\nFrom March 1st 2019\nBubblespace Coworking\n824, HRBR 1 Block,, HRBR Layout 1st Block, Extension, \nKalyan Nagar, Bengaluru, Karnataka 560043	233	verifying
81	106123538173898449055	Software	To play a critical role in the development of software interface of various automation products\nTo develop & deploy reliable code based on the requirement\nTo perform end-to-end testing of the software products\nTo extensively research on the latest trends in technology and recommend improvement \n\nwill be an internal part of core IT team.		Software	8-12 weeks	25000	8	noida	no	python, java, javascript, html, angular, PHP	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	verifying
82	106123538173898449055	Automation	Managing the development of controls related aspect for all automation products\nTo play a critical role in procurement, calibration, testing and deployment of control related tools like Sensors, PLCs, Scanners, relays and other related hardware\nTo play a critical role in designing of SCADA, PLC logics, Communication mechanism etc.\n\nStudents from Electronics, Instrumentation and Electrical specialization only are eligible for this.		Automation	8-12 weeks	25000	6	noida	no	Basic of their specialization	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	verifying
83	106123538173898449055	Mechanical	To play a critical role in design of all automation related products by providing artistic design and converting it into engineering design\nTo create 2-D & 3-D diagram of various products and create final product renderings\nTo ensure production of the products as per the drawing and ensure all engineering related aspect w.r.t. design are taken care of\nTo assist in deployment of all products related to mechanical project at site		Mechanical	8-12 weeks	25000	4	noida	no	Knowledge of basics of mechanical	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	verifying
80	106123538173898449055	Navigation	This will be a specialized role which will comprise of designing algorithms in SLAM for the mobile robotics vertical of Addverb.\n\nThis is open for all specialization where the candidate has done projects in robotics.		Robotics	8-12 weeks	25000	5	noida	no	Robotics skill	should have previous experience in robotics	no	no	no	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	verifying
78	108825759819157028428	Machine Learning Intern	Job Description:\n  The current product development involves working on new ideas in Deep Learning, using tools such as Tensorflow. The Intern will be provided training in AI / ML libraries and software development techniques.		Machine Learning Intern	2 months	60000 INR	1-2	Hyderabad or Remote-work (work-from-home)	No	Primary requirements:\n  - Expertise in Java, Python or C++\n  - Expertise in Algorithms and Data structures\n  - Ability to understand and implement ideas described in Research journal papers\n  - Good problem solving and communication skills, along with a positive attitude	Secondary requirements:\n  - Prefer experience in NLP, Image processing, Speech recognition, Chatbots\n  - Prefer knowledge of Tensorflow, scikit-learn, Spark, MongoDB, AWS or GCP\n  - Good to have knowledge of Data science and Data mining concepts, R programming and Statistical methods	No	No	To be announced	#301-A, Amsri Residency, Shyam Karan Road, Leela Nagar, Ameerpet, Hyderabad - 500016	243	verifying
121	101818747050100224079	Developer for developing one stop solution for shipping documentation <>automaxis	For the paper based documentation issues in cross border trade in pharma industry, automaxis is a blockchain platform for digital, secure & speedy transfer of these documents by bringing trust in the network & the transfer of ownership on real time.		Developer	7-8 Weeks	5000	3-4	Hyderabad	No	Python, Node JS etc	NA	No	No	Perks for good performances, Informal dress-code complete startup work life!	T-Hub, Catalyst,\nIIIT-H,\nGachibowli,\nHyderabad-500032	228	verifying
76	102476915533780948091	Software Intern	will have to work on live project of integrating toys with learning.		Software trainee	8 weeks	7000 INR	1	Jaipur	No	Machine Learning, Artificial Intelligence.	Should have good knowledge in machine learning.	NO	NO	NO	F 20-A, Malviya Industrial Area, Jaipur - 302017\n\n	231	verifying
74	102540152476572591754	Sports Writer	We’re looking for adept content writers with good knowledge and passion for sports and an excellent knack for writing in the sports genre.\n	https://res.cloudinary.com/saarang2017/image/upload/v1550041130/ecell/bjz9mrp5y55jbudpksvz.pdf	Sports Writer	Minimum 2 months	Rs. 8000/- to Rs.10.000/-	2	Hyderabad	No	A knack for fresh and conceptual thinking, researching and writing sports articles.\nPassionate about sports and the power of sports.\nWell-versed in sports jargon and a natural talent at wielding them.\nShould be adaptive and flexible to learn and produce content in various mediums and platforms, and in styles and sizes.\nA flair for integrating visual elements in the content.\nA bent for creativity and conceptual thinking to support in strategizing and executing the content marketing plans for campaigns/promotional events.\nShould be a team player and be able to deliver the projects effectively on tight deadlines.\nShould possess integrity and the zeal to grow.\n	-	No	No	Informal dress code and lunch will be provided for 6 days	30,31, West Wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\nMaps Link: \nhttps://goo.gl/maps/Vpnw18n49M22	235	verifying
72	110447218383396106962	SKC_IT	All the selected and qualified SKC_IT interns will be assigned under live project.\nWe’ve requirement under four domains :-\n1- Web Designer.\n2- App Developer.\n3- Creative Content Writer.\n4- Software Developer.	https://res.cloudinary.com/saarang2017/image/upload/v1549979932/ecell/dbuvatv9bjvltunwqglg.jpg	•Web Designer- He/she will be responsible for developing a live dynamic website. Credentials pertaining to hosting and server details will be provided later.        • App Developer- You have the inclination but don’t find the right platform to showcase your coding skills . Don’t worry, Sit back ! “ScrapKaroCash” is here. • Creative Content Writer - A Writer who is worthy enough to express it’s requirement in a innovative & creative way. •Software Developer- A techie who’s smart to understand company work flow and give us URL address. Yes! We need a coder who not only understand the complexity of the work flow but also provide us solution in an effective way.	8 weeks	• Creative Content Writer- Certificate will be provided, No stipend. For others INR  ₹ 25,000/- on successfully project completion distribution fairly. Moreover certification will be provided to them.	8-10	Work From Home	No	PHP\nSEO\nHTML/CSS\nJava Script\nPhotoshop\nWord Press\nUI designer\nContent Writer\nC#\nCross-Platform App Development\n\n\n\n	• Analytical Skills -\nMost successful websites are functional but consumer behaviors are changing therefore to meet their expectations design, coding, and development skills will always evolve to satisfy the ever-changing consumer.\nTherefore, web developers need a strong understanding of consumers. Especially web consumers.\n• Responsive Design.\n	NA	NA	NA	GIT Incubation Center,\nUdyambagh, Belagavi\nKarnataka	232	verifying
73	102540152476572591754	Copywriter & UX Writer	We’re looking for a passionate ‘Copywriter and UX Writer’ who can build crisp, compelling and interactive content that drives desired actions from the user.\n	https://res.cloudinary.com/saarang2017/image/upload/v1550041810/ecell/lqb8nwkkbdkzh8ofipvy.pdf	Copywriter & UX Writer	Minimum 2 months	Rs. 8000/- to Rs. 1000/-	2	Hyderabad	No	1. Good command over the English language with a knack for writing crisp and compelling content across a spectrum of styles and genres.\n2. Prior experience in UX writing, Copywriting or Marketing is an additional advantage.\n3. Ability to understand, align and produce content as per business/marketing requirements, business context and brand philosophy.\n4. Strong editing skills to make the text sharp, short and friendlier in an user-interface.\n5. A flair for integrating visual elements in the content.\n6. A bent for creativity and conceptual thinking to support in strategizing and executing the content marketing plans for campaigns/promotional events.\n7. Should be a team player and be able to deliver the projects effectively on tight deadlines.\n8. Should possess integrity and the zeal to grow.\n	-	No	No	Informal dress code and lunch will be provided for 6 days	30,31, West Wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\nMaps Link: \nhttps://goo.gl/maps/Vpnw18n49M22	235	verifying
101	111133250649424423782	Online Marketing-Interns	 Expert level knowledge of Facebook Ads Manager , Google adwords is a pre-requisite.\n\ncustomer retention, reactivation, website personalization, retargeting, social media, referral marketing, and other marketing and promotional activities. \n\nIdentify, design, and analyze new brand-appropriate online marketing initiatives and partnerships. \n		Online Marketing-Interns	10-12 Weeks	8000-10000 Per month	3	Jaipur	No	 Expert level knowledge of Facebook Ads Manager , Google adwords is a pre-requisite.\n\ncustomer retention, reactivation, website personalization, retargeting, social media, referral marketing, and other marketing and promotional activities. \n\nIdentify, design, and analyze new brand-appropriate online marketing initiatives and partnerships. \n	Passionate about digital tools of product marketing, exploring new ways of online marketing with tech acumen	No	NO	NO	J-469-471 RIICO Industrial area, Sitapura, Jaipur-302022	237	verifying
100	111133250649424423782	Interns-Tech	Python Experience + knowledge is desired. \n\n- Hands on experience coding in more than one currently popular web application framework. \n\n- Experience with any dynamic languages is a big plus. \n\n- Should be able to ace problems in data structures and algorithms \n\n- Strong knowledge of object oriented design principles \n\n- Knowledge of software best practices, like test driven development and continuous integration \n\n- Experience working with Agile Methodologies \n\n- Experience with UNIX system administration and web server configuration. \n\n- Knowledge of Internet protocols and database management systems\n		Tech-Itern	10-12 Weeks	10000-12000 Per month	4	Jaipur	no	Python Experience + knowledge is desired. \n\n- Hands on experience coding in more than one currently popular web application framework. \n\n- Experience with any dynamic languages is a big plus. \n\n- Should be able to ace problems in data structures and algorithms \n\n- Strong knowledge of object oriented design principles \n\n- Knowledge of software best practices, like test driven development and continuous integration \n\n- Experience working with Agile Methodologies \n\n- Experience with UNIX system administration and web server configuration. \n\n- Knowledge of Internet protocols and database management systems\nOR\n•\tExperience in optimized UI development for different  OSversions and devices.\n•\tExperience with Javascripts, html, Angular JS an added advantage\n•\tFamiliar with RESTful web service\n•\tStrong experience in Java, XML, and JSON, Web Services and Postgres database.\n•\tKnowledge of ROR frameworks\n•\tUnderstand the core concepts of Java, Android and MVC design thoroughly\n•\tFamiliar with Social Network SDK, Action Bar, Push Notifications, Payment Gateways , Testing Frameworks, & Third Party Libraries\n•\tIdeal candidate should be a good team player, a self-starter and be able to work independently\nOR\nAndroid Developers\n\n	no	NO	No	NO	\nVoylla Fashions Pvt tld\nJ-469-471,RIICO Industrial Area,Sitapura, Jaipur-302022\n	237	verifying
122	107429974676687296166	Data Engineer	Selected intern's day-to-day responsibilities include: \n\n1. Creating and sharing reports and dashboards\n2. Working with cross-functional teams the reporting process including data acquisition and cleaning, report and dashboard creation and visualization\n3. Working on system refinement, testing out newer technologies, etc.\n4. Brainstorm on ideas on how 		Data Engineer	3 Months	5000	2	Mumbai	No	Good Grip Over Excel Formulas & Pivot Tables\nBasic Understanding of SQL is preferred not mandatory\nLogical Thinking\nProblem Solver\nEager to Learn	No	No	No	Certificate, Startup culture	801, Jai Antriksh, Makwana Road, Marol, Andheri (E), Mumbai - 400059	253	verifying
135	112150566284259074738	Associate Trainee	Looking for interns to strategize the launch of our upcoming project.		Business Strategist	Minimum 12 weeks	10000	4	Indore, Madhya Pradesh	No	§  Candidate should be excellent in Communication skills, presentation skills, Analytical Approach, Problem-solving skills.\n\n§  Business Strategizational skills & Convincing Skills	Business orientation and analytical approach.	No	No	Informal Dress Code	RackBank Datacenters Pvt Ltd\nFirst Floor, Building Number 1, Crystal IT Park SEZ, Madhya Pradesh, 452001	280	verifying
85	100916162979211575903	Sofware programming in Web frontend, Web backend, Devlopment operations	You would work with a young world-class team of programmers, designers and testers to implement a few cool features. In the process, you would learn how work happens in a startup focused on solid engineering. The specific project you would be assigned would be a combination of your capability and many opportunities at Mammoth, but would broadly be in the area of our technology stack.\nThe technology stack comprises of multiple components such as PostgreSQL, RabbitMQ, Celery, API Servers all deployed on AWS utilizing various services for scale and elasticity. We use the Python based pyramid framework in the backend and angular and Bootstrap on the front-end. Our test and deployment setup uses Ansible and go.cd. We focus heavily on User experience.		Full Stack Internship	10 weeks	15000	1-3	Bangalore	no	Job Description and Skills\nAs an Intern with Mammoth, you will be solving some interesting and challenging problems in different areas of the product. You must already be damn good at programming in at least one programming language. You are expected to be on top of basic computer science concepts in data structures, algorithms, and operating systems. \n\nExperience with one web framework (like Django, flask, pyramid) is a bonus. Else you should have a good idea of javascript and react or angular to take a few interesting challenges on frontend technologies. Or if you are interested in development operations, then you should know about Ansible and appreciate its power.	None	You need to manage yourself	None	Lunch is on on us. Besides this you would have access to food, refrigerator, microwave and a stocked up kitchen. 	104, 1st A Cross, 4th Main\nDomlur 2nd Stage, Bangalore - 560071	250	verifying
93	101326090802695787002	Graphic Designer	Created web based or app based graphics or logo for any active website or app. Please include any active link or store link for any contributions. Knows his way around in graphics software like Photoshop, Illustrator, Adobe XD or Sketch.\n•\tStrong aesthetic skills with the ability to combine various colors, fonts and layouts\n•\tAttention to visual details\n•\tAbility to collaborate with a team.\n•\tRefine images, fonts and layouts using graphic design software\n•\tStay up-to-date with industry developments and tools\n		Designer	Minimum 4 weeks - Maximum 6 weeks	10,000 PM Minimum	2	Indore, Madhya Pradesh	No	Proficient in any of these softwares\n1. Adobe Illustrator\n2. Adobe Photoshop\n3. Adobe XD\nBasic knowledge of colors, gradients and fonts.	Adobe Illustrator\nAdobe Photoshop	No	No	5 days a week, informal dress code	Plot No 156\nScheme no 78 Part 2,beside Sai girls hostel\nNear vrindavan hotel\nIndore, (M.P.)	245	verifying
95	109249031263145344654	Digital Marketing Intern	- Develop and manage digital marketing campaigns\n- Oversee a social media strategy\n- Write and optimise content for the website and social networking accounts such as Facebook Twitter and Instagram\n- Track and manage the budget for paid online camapigns and bring competitive ROI for the events through those campaigns.\n- Edit and post images, videos, pdf and other required content on different channels.		Digital Marketer	Minimum 8 weeks	7000 INR	1	Ahmedabad	no	Key Skills Required:\n- Intermediate to Advance understanding of Digital Marketing\n- Creative Design & Copywriting skills\n- Basic video editing skills\n\nFamiliarity with Facebook, Instagram and Google Ads will be preferred.	Should be good at creating content.	No	No	Informal Dress Code, Free Lunch, Watching movie during lunch hour, hands-on-experience with real-time company challenges	A-707, Premium House, Nr. Gandhigram Railway Station, Ashram Road, Ahmedabad - 380001.	251	verifying
91	110505594872527456493	Data Analyst	DATA ANALYST _ JD\nBasic Background ->  Mathematics and Programming definitely, Operations Research ideally. Some exposure to supply chain management / logistics would be good\n Not particular about which language, but Python or Ruby would be good.  Exposure to Java script and web programming would be great\nEither a bachelors  from IIT or a Masters degree with coursework in Linear Programming, Data Analysis Techniques.\nKnowledge in  data analysis, linear programming and/or machine learning techniques.  Projects  applying these techniques.\nAbility to crush large data pool into insights and plan of action for improving process.\n\nApply linear programming techniques to optimize the Route, Truck Type selection, Contract Selection\nApply feedback from completed trips to optimize further\nLinear programming techniques for managing part loads, stuffing trucks, loading/unloading trucks.\nAnalyse data quality of GPS Vendors.\nAnalyse outliers in Truck costing\nPredicting truck costing for various routes and truck types.\n		Data Analyst	2 months	10000	2	Chennai	no	DATA ANALYST _ JD\nBasic Background ->  Mathematics and Programming definitely, Operations Research ideally. Some exposure to supply chain management / logistics would be good\n Not particular about which language, but Python or Ruby would be good.  Exposure to Java script and web programming would be great\nEither a bachelors  from IIT or a Masters degree with coursework in Linear Programming, Data Analysis Techniques.\nKnowledge in  data analysis, linear programming and/or machine learning techniques.  Projects  applying these techniques.\nAbility to crush large data pool into insights and plan of action for improving process.\n\nApply linear programming techniques to optimize the Route, Truck Type selection, Contract Selection\nApply feedback from completed trips to optimize further\nLinear programming techniques for managing part loads, stuffing trucks, loading/unloading trucks.\nAnalyse data quality of GPS Vendors.\nAnalyse outliers in Truck costing\nPredicting truck costing for various routes and truck types.	\nData Analytics , Python / R Programmers	No	No	Lunch provided 	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in\nLandmark: Kavery Hospital and hyundai showroom	230	verifying
92	110505594872527456493	JAVA	Java developers responsible for building Java / J2EE applications. This includes anything between complex groups of back-end services and their client-end (desktop and mobile) counterparts. Your primary responsibility will be to design and develop these applications, and to coordinate with the rest of the team working on different layers of the infrastructure. Thus, a commitment to collaborative problem solving, sophisticated design, and product quality is essential.\n\n•\tTranslate application storyboards and use cases into functional applications\n•\tDesign, build, and maintain efficient, reusable, and reliable Java code\n•\tEnsure the best possible performance, quality, and responsiveness of the applications\n•\tIdentify bottlenecks and bugs, and devise solutions to these problems\n•\tHelp maintain code quality, organization, and automation\n•\tTeam Player\nSkills\n•\tProficient in Java, with a good knowledge of its ecosystems\n•\tSolid understanding of object-oriented programming\n•\tFamiliar with various design and architectural patterns\n•\tSkill for writing reusable Java libraries\n•\tKnowledge of concurrency patterns in Java\n•\tFamiliarity with concepts of MVC, JDBC, and RESTful\n•\tKnowledge with popular web application frameworks, SPRING, Hibernate, JSF\n•\tFamiliarity with UI Frameworks like JQuery\n•\tKnack for writing clean, readable Java code\n•\tknowledge with both external and embedded databases\n•\tUnderstanding fundamental design principles behind a scalable application\n•\tBasic understanding of the class loading mechanism in Java\n•\tCreating database schemas that represent and support business processes\n•\tTest Driven Approach for Development\n•\tImplementing automated testing platforms and unit tests\n•\tProficient understanding of code versioning tools, such as Git\n•\tFamiliarity with build tools such as Ant, Maven, and Gradle\n•\tFamiliarity with continuous integration like Jenkins\n•\tQuick Learner\n		JAVA	2 months	10000	1	Chennai	no	Java developers responsible for building Java / J2EE applications. This includes anything between complex groups of back-end services and their client-end (desktop and mobile) counterparts. Your primary responsibility will be to design and develop these applications, and to coordinate with the rest of the team working on different layers of the infrastructure. Thus, a commitment to collaborative problem solving, sophisticated design, and product quality is essential.\n\n•\tTranslate application storyboards and use cases into functional applications\n•\tDesign, build, and maintain efficient, reusable, and reliable Java code\n•\tEnsure the best possible performance, quality, and responsiveness of the applications\n•\tIdentify bottlenecks and bugs, and devise solutions to these problems\n•\tHelp maintain code quality, organization, and automation\n•\tTeam Player\nSkills\n•\tProficient in Java, with a good knowledge of its ecosystems\n•\tSolid understanding of object-oriented programming\n•\tFamiliar with various design and architectural patterns\n•\tSkill for writing reusable Java libraries\n•\tKnowledge of concurrency patterns in Java\n•\tFamiliarity with concepts of MVC, JDBC, and RESTful\n•\tKnowledge with popular web application frameworks, SPRING, Hibernate, JSF\n•\tFamiliarity with UI Frameworks like JQuery\n•\tKnack for writing clean, readable Java code\n•\tknowledge with both external and embedded databases\n•\tUnderstanding fundamental design principles behind a scalable application\n•\tBasic understanding of the class loading mechanism in Java\n•\tCreating database schemas that represent and support business processes\n•\tTest Driven Approach for Development\n•\tImplementing automated testing platforms and unit tests\n•\tProficient understanding of code versioning tools, such as Git\n•\tFamiliarity with build tools such as Ant, Maven, and Gradle\n•\tFamiliarity with continuous integration like Jenkins\n•\tQuick Learner\n	JAVA / J2EE \nweb application frameworks, SPRING, Hibernate, JSF	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	verifying
98	110274344916933599324	Software Developer Intern	“If it scares you, it might be a good thing to try.” – Seth Godin\n\nIf you want to join the force which is going to change the entire dynamics of App(Mobile/Web/IoT) development and App experience, you are banging the right door! Drive the Feature-as-a-Service(FaaS) revolution. \n\nWe Dream Big : We Work Hard. We Challenge : We AchieveInterns \n\nLooking for hardcore dev interns (preferably computer-science background) with a minimum commitment period of 4 months. Interns will be straight placed into our core development team. The exposure, experience, and energy which you get will be topnotch. \n\n		Developer	Minium 4 months	15000	2	Bangalore	No	Backend: Java, Spring-Boot, Python, Knowledge of REST framework & micro-services\nFrontend: Angular 2+, HTML5, CSS, Bootstrap, experience in UX design will be an added advantage. \n\nYou can apply if you have either of frontend or backend skills.	No	No	No	Informal dress code, 6 days a week	BackBuckle.io, Kstart Respace, Second Floor, Ascendas Park Square Mall, ITPB Main Road, Whitefield, Bengaluru, 560066	252	verifying
96	110505594872527456493	UI / UX Designer	•\tCollaborate with product management and engineering to define and implement innovative solutions for the product direction, visuals and experience\n•\tExecute all visual design stages from concept to final hand-off to engineering\n•\tConceptualize original ideas that bring simplicity and user friendliness to complex design roadblocks\n•\tCreate wireframes, storyboards, user flows, process flows and site maps to effectively communicate interaction and design ideas\n•\tPresent and defend designs and key milestone deliverables to peers and executive level stakeholders\n•\tConduct user research and evaluate user feedback\n•\tEstablish and promote design guidelines, best practices and standards\nRequirements\n•\tPassion in UI \n•\tDemonstrable UI design skills with a strong portfolio\n•\tSolid experience in creating wireframes, storyboards, user flows, process flows and site maps\n•\tProficiency in Photoshop, Illustrator, OmniGraffle, or other visual design and wire-framing tools\n•\tProficiency in HTML, CSS, and JavaScript for rapid prototyping.\n•\tExcellent visual design skills with sensitivity to user-system interaction\n•\tAbility to present your designs and sell your solutions to various stakeholders.\n•\tAbility to solve problems creatively and effectively\n•\tUp-to-date with the latest UI trends, techniques, and technologies\n•\tknowledge in an Agile/Scrum development process\n\n		UI / UX Designer	2 months	10000	1	chennai	no	UI / UX Designer	Collaborate with product management and engineering to define and implement innovative solutions for the product direction, visuals and experience\n•\tExecute all visual design stages from concept to final hand-off to engineering\n•\tConceptualize original ideas that bring simplicity and user friendliness to complex design roadblocks\n•\tCreate wireframes, storyboards, user flows, process flows and site maps to effectively communicate interaction and design ideas\n•\tPresent and defend designs and key milestone deliverables to peers and executive level stakeholders\n•\tConduct user research and evaluate user feedback\n•\tEstablish and promote design guidelines, best practices and standards\nRequirements\n•\tPassion in UI \n•\tDemonstrable UI design skills with a strong portfolio\n•\tSolid experience in creating wireframes, storyboards, user flows, process flows and site maps\n•\tProficiency in Photoshop, Illustrator, OmniGraffle, or other visual design and wire-framing tools\n•\tProficiency in HTML, CSS, and JavaScript for rapid prototyping.\n•\tExcellent visual design skills with sensitivity to user-system interaction\n•\tAbility to present your designs and sell your solutions to various stakeholders.\n•\tAbility to solve problems creatively and effectively\n•\tUp-to-date with the latest UI trends, techniques, and technologies\n•\tknowledge in an Agile/Scrum development process\n\n	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	verifying
94	110505594872527456493	Android Developer	Android Developer \nInclude:\n•\tDesigning and developing advanced applications for the Android platform\n•\tUnit-testing code for robustness, including edge cases, usability, and general reliability\n•\tBug fixing and improving application performance\n\nWe are looking for an Android Developer who possesses a passion for pushing mobile technologies to the limits. This Android app developer will work with our team of talented engineers to design and build the next generation of our mobile applications. Android programming works closely with other app development and technical teams.\nResponsibilities\n•\tDesign and build advanced applications for the Android platform\n•\tCollaborate with cross-functional teams to define, design, and ship new features\n•\tWork with outside data sources and APIs\n•\tUnit-test code for robustness, including edge cases, usability, and general reliability\n•\tWork on bug fixing and improving application performance\n•\tContinuously discover, evaluate, and implement new technologies to maximize development efficiency\n•\tSolid background in software development, and design patterns\n•\tknowledge with the Android SDK, java, NDK\n•\tknowledge in high quality Android application to the Google Play Store\n•\tknowledge in communication and messaging applications\n•\t Google Maps integration\n•\t Retrofit,Dagger,Realm\n\nRequirements\n•\tBachelor / Masters in Computer Science, Engineering or a related subject\n•\tsoftware development and Android skills development\n•\tAndroid app development\n•\tone original Android app\n•\tknowledge with Android SDK\n•\tknowledge with remote data via REST and JSON\n•\tknowledge with third-party libraries and APIs\n•\tWorking knowledge of the general mobile landscape, architectures, trends, and emerging technologies\n•\tSolid understanding of the full mobile development life cycle.\n		Android Developer	2 months	10000	1	chennai	no	Android Developer \nInclude:\n•\tDesigning and developing advanced applications for the Android platform\n•\tUnit-testing code for robustness, including edge cases, usability, and general reliability\n•\tBug fixing and improving application performance\n\nWe are looking for an Android Developer who possesses a passion for pushing mobile technologies to the limits. This Android app developer will work with our team of talented engineers to design and build the next generation of our mobile applications. Android programming works closely with other app development and technical teams.\nResponsibilities\n•\tDesign and build advanced applications for the Android platform\n•\tCollaborate with cross-functional teams to define, design, and ship new features\n•\tWork with outside data sources and APIs\n•\tUnit-test code for robustness, including edge cases, usability, and general reliability\n•\tWork on bug fixing and improving application performance\n•\tContinuously discover, evaluate, and implement new technologies to maximize development efficiency\n•\tSolid background in software development, and design patterns\n•\tknowledge with the Android SDK, java, NDK\n•\tknowledge in high quality Android application to the Google Play Store\n•\tknowledge in communication and messaging applications\n•\t Google Maps integration\n•\t Retrofit,Dagger,Realm\n\nRequirements\n•\tBachelor / Masters in Computer Science, Engineering or a related subject\n•\tsoftware development and Android skills development\n•\tAndroid app development\n•\tone original Android app\n•\tknowledge with Android SDK\n•\tknowledge with remote data via REST and JSON\n•\tknowledge with third-party libraries and APIs\n•\tWorking knowledge of the general mobile landscape, architectures, trends, and emerging technologies\n•\tSolid understanding of the full mobile development life cycle.\n	Android	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	verifying
102	117894875203741245699	Android Developer Intern	Driver Friends is an early stage startup solving multiple day-to-day painpoints for Drivers. Our first app is a P2P communication tool for drivers, and is launching soon.\n\nWe are hiring for an android developer intern. Ideal candidates will have:\n- Published at least one app to the playstore (please share link in application)\n- Great knowledge of Android design patterns and architecture components: room, livedata, viewmodel etc\n- Good to have: experience with Postgres, Firebase functions, Apollo GraphQL, Maps and location related APIs\n- Willingness to work in an early stage startup (team = family, high ownership, flexible hours, lots of experiments, agile workflow)		Android Developer	2 months	10000	2	Remote	no	Ideal candidates will have:\n- Published at least one app to the playstore (please share link in application)\n- Great knowledge of Android design patterns and architecture components: room, livedata, viewmodel etc\n- Good to have: experience with Postgres, Firebase functions, Apollo GraphQL, Maps and location related APIs\n- Willingness to work in an early stage startup (team = family, high ownership, flexible hours, lots of experiments, agile workflow)	Android Developer Studio	No	No	Work from home; Early seat in a startup affecting potentially a million lives; more involvement post-internship if work is good, leading up to a job offer	22, Car Street, Ulsoor, Bangalore - 560008	246	verifying
103	111133250649424423782	Intern-Data analytics	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n		Intern-Data analytics	10-12 weeks	10000-12000 Per month	2-4	Jaipur	Yes	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n	no	no	no	no	J 469-471 RIICO Industrial Area,Near chatrala Circle, Sitapura Jaipur-302022	237	verifying
104	103304235098083374178	Developer	Karomi is a global technology solutions provider, with significant focus across two principal industries - Life Sciences and CPG (Food and Cosmetics). Karomi’s flagship product is ManageArtworks, a Packaging Artwork Management Software that helps regulated industries like Pharmaceuticals and CPG to ensure regulatory compliance of their pack labels. From an Artificial Intelligence standpoint, we provide proofing tools for both image and text comparison along with analytics. We are also working on 3D-modeling, photo realistic rendering with real time ray-tracing in order to model and convert company artworks into photo realistic 3D products. Artwork management is a niche domain, being one of the very few domains where there is scope to combine cutting edge technologies from both Computer Vision and Natural Language Processing in an optimal fashion, along with the possibility to work on Computer Graphics.\n\nAs part of your internship, here are some interesting topics in various aspects, that you could potentially work with us: (Note: We are also open for new interesting ideas that have potential for ManageArtworks):\n1. Machine Learning, Deep Learning:\no Semantic Segmentation for Artwork Vs Non-Artwork type classification\no Transfer Learning to reuse pre-trained models for Artwork Management\no Deep learning for limited data samples: Data augmentation, shallow networks\no Generative Adversarial Networks for rendering realistic artworks to create a large artwork data corpus\no Artwork detection using RCNN\no Shallow neural networks for word embedding or document embedding: word2vec, doc2vec\no Random trees, SVM, decision forests for Artwork Classification, document classification.\no Deep learning based optical flow: Flownet\n\n2. Image Processing and Computer Vision:\no Optimal Image registration using optical flow (dense and sparse optical flow), feature based methods\no Error metrics for complex image data comparison\no Image inpainting for information missing in artworks with text data\no Watershed methods for Artwork selection\no Image compression techniques for extremely large resolution artwork files\n\n3. Computer Graphics:\no Physically based rendering (PBR) of photo realistic 3D artwork from 2D images\no 3D modeling for complex meshes with realistic material shader\no Ray tracing or path tracing with realistic global illumination for complex artwork scenarios\n\n4. Others:\no Mobile app development for our current products (Android studio, Java coding)\no Virtual Reality solution for 3D artwork modeling (Unity knowledge is a must)\n\nApart from the above mentioned ideas, we are open to your new ideas if it seems feasible and has potential.	https://res.cloudinary.com/saarang2017/image/upload/v1550488643/ecell/nlhltlckrqwmx7o2enfd.pdf	Developer: AI, CV, NLP	2 months	10,000 (per month)	2	Work from Karomi's office (preferred) or work from home (based on request)	No	Python (compulsory), C++ . For specific R&D projects, please look at the description or the PDF provided with this portal.	Knowledge on android development if interested in working on a mobile environment.	No	No	Snacks, Hot beverage, Flexible work timings, Independent work and ideas (Guidance will be provided)	Karomi Technology Private Limited, 3rd and 4th Floor, B Block, 56, Thirumalai Pillai Road,, Thirumalai Pillai Lane, Parthasarathy Puram, T Nagar, Chennai, Tamil Nadu 600017	257	verifying
105	105373738578694994605	Animator	We are looking for a creative Animator to develop excellent visual frames with 2D/3D or other techniques. Your work should give life to storylines and characters in videos.		Animator	Minimum of 2 months	 Rs. 10,000/- to Rs. 20,000/-	2	Hyderabad	No	Knowledge of 2D/3D and computer-generated animation.\nA creative storytelling with presentation abilities.\nAbility to deliver with in deadlines.\nPatient and being able to concentrate for long periods.\nIntegrity and the zeal to grow.\nTeamwork and excellent communication skills.\nDegree in computer animation, 3D/graphic design, fine arts or relevant field is an additional advantage.\nPrior experience in project management is an additional advantage.	No	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	verifying
106	105373738578694994605	Video Editor	We are looking for a talented video editor to assemble recorded footage into finished projects that match director’s vision and are suitable for broadcasting.		Video Editor	Minimum 2 months	 Rs. 10,000/- to Rs. 20,000/-	2	Hyderabad	No	1. Thorough knowledge of timing and continuity.\n2. Hands on experience on any video editing software (like premiere pro, final cut pro etc).\n3. Creativity and  passion in film and video editing.\n4. The ability to listen to others and to work well as part of a team.\n5. Time management skills.\n6. Ability to deliver with in deadlines.\n7. Integrity and the zeal to grow.	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	verifying
107	114749538391689307031	Data Science Intern	Trapyz is an AI-driven consumer intent to insights SaaS platform with a privacy-first focus to map real-world consumer journeys for brands.\n\nYou’ll be challenged to create innovative solutions using location data generated through millions of logs using Time series Analysis and Forecasting. Also, you’ll be given sole responsibility to build visualization tools for our data which can identify trend, pattern and noise. 		DS Intern	8-12 Weeks	15000	2-3	Bangalore	No	Trapyz is an AI-driven consumer intent to insights SaaS platform with a privacy-first focus to map real-world consumer journeys for brands.\n\nYou’ll be challenged to create innovative solutions using location data generated through millions of logs using Time series Analysis and Forecasting. Also, you’ll be given sole responsibility to build visualization tools for our data which can identify trend, pattern and noise. \n\nAs a DS intern you will be responsible for:\n\n•\tDoing a lot of hands-on programming \n•\tWorking closely with the Founders and the Product Head to translate the business requirements into technical execution\n\nImportant skills to have: \n•\tProgramming Python. Strong background in statistics and mathematics \n•\tKnowledge of AWS, Machine Learning, S3, Dynamo DB etc\n•\tGood verbal and written communication skills	NA	No	Yes	5 Days a week	PlanetWorx Technologies Pvt Ltd,\nCoWrks, \nPurva Premiere, Residency Rd, \nShanthala Nagar, Ashok Nagar, \nBengaluru, Karnataka 560025	242	verifying
108	105373738578694994605	VFX Designer	\niB Hubs is looking for  talented, enthusiast VFX artists who understands and has mastered the techniques of any 2 of the vfx sectors (tracking, rotoscopy, modeling, texturing, rigging, animation, lighting, compositing) to join them in the creation of corporate videos, advertisements etc.\n		VFX Designer	Minimum of 2months	Rs. 10,000/- to Rs. 20,000/- per month	2	Hyderabad	No	1. Knowledge and proficiency in at least 2 of mentioned departments (Lighting, Matchmove, Fx Simulations, Roto, Animation). \n2. Knowledge in vfx graphic software like 3DS MAX/  MAYA 3D/ NUKE X/ HOUDINI/AUTODESK COMBUSTION/EYEON DIGITAL FUSION.\n3. Bachelor's degree in Visual Arts or Computer Arts or comparable professional experience will be an added advantage.\n4. Ongoing interest in, and knowledge of, current design and graphics trends.\n5. Should be able to produce the graphic solutions that are consistent with brand and style guidelines.\n6. Highly organized and detail-oriented with the ability to work efficiently in fast-paced environment, while meeting tight deadlines.\n7. Must be able to take full and independent ownership of demanding projects, while also being able to take direction from co-workers and producers.\n8. Excellent communication skills.\n9. Integrity and the zeal to grow.\n	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	verifying
111	105373738578694994605	Motion Graphics Designer	The Motion Graphics Designer will be responsible for creating and designing engaging graphics to support videos aligned with our optimistic target brand voice.		Motion Graphics Designer	Minimum of 2 months	Rs. 10000-20,000/-	2	Hyderabad	No	1. Knowledge and proficiency in the latest Adobe Creative Suite (After Effects, Premiere). \n2. Ongoing interest in, and knowledge of, current design and graphics trends.\n3. Should be able to produce the graphic solutions that are consistent with brand and style guidelines.\n4. Highly organized and detail-oriented with the ability to work efficiently in fast-paced environment, while meeting tight deadlines.\n5. Must be able to take full and independent ownership of demanding projects, while also being able to take direction from co-workers and producers.\n6. Excellent communication skills.\n7. Integrity and the zeal to grow.\n8. Bachelor's degree in Visual Arts or Computer Arts or comparable professional experience will be a added advantage.\n9. Knowledge in vfx graphic software like Cinema 4D/Maya 3D etc, will be an added advantage.\n	Nothing.	No	No	Lunch will be provided	 30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032	234	verifying
112	101107640131204357570	Front-end Developer	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.		Developer (Front-end)	Minimum 8 - 12 weeks	15000	3	Hyderabad	No	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	Preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	No (Many good PG accommodations available at reasonable cost around the campus)	No	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	verifying
114	101107640131204357570	Android / IOS Developer	Android APP development: B2C apps - Kotlin\nIOS Development: B2C apps - Xcode / Swift/Objective C\nwith understanding on constraint layouts, dagger, etc.\n		Android / IOS Developer	Minimum 8 - 12 weeks	15000	4	Hyderabad	No	Android APP development: B2C apps - Kotlin\nIOS Development: B2C apps - Xcode / Swift/Objective C\nwith understanding on constraint layouts, dagger, XML, etc.\n	Android APP development: B2C apps - Kotlin\nIOS Development: B2C apps - Xcode / Swift/Objective C\nwith understanding on constraint layouts, dagger, XML, etc.\n	NA (Many affordable PGs around the campus)	NA	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.\n\n	260	verifying
113	101107640131204357570	Full Stack Developer / Backend Developer	Full stack / Back end developer -  MEAN Stack or Node Js or Python (Django/Flask),MongoDB/ NoSQL or firebase, SSH, Commandlines, AWS S3, Cryptography, etc\n		Developer (Full stack/Back-end)	Minimum 8 - 12 weeks	15000	4	Hyderabad	No	Full stack / Back end developer -  MEAN Stack or Node Js or Python (Django/Flask),MongoDB/ NoSQL or firebase, SSH, Commandlines, AWS S3, Cryptography, etc\n	MEAN Stack or Node Js or Python (Django/Flask),MongoDB/ NoSQL or firebase, SSH, Commandlines, AWS S3, Cryptography, etc\n	No (Many affordable PGs available around the campus)	No	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	verifying
115	101107640131204357570	Hologram designers or Developers with experience in Voice/Facial recognition, Bot Analytics, VR/AR and Blockchain experts	Technical experts for Hologram designers, Voice/Face recognition, Data analytics, VR/AR and Blockchain experts\n		Hologram designers or Developers with experience in Voice/Facial recognition, Bot Analytics, VR/AR and Blockchain experts	Minimum 5 - 12 weeks	15000	2	Hyderabad	No	Looking for Hologram designers, Data Analytics, Voice/Face recognition, VR/AR and Blockchain experts\n	Looking for Hologram designers, Bot Analytics, Voice/Face recognition, VR/AR and Blockchain experts\n	No (Many affordable PGs near the campus)	No	 5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.\n	260	verifying
116	113564221505157815723	Graphic Designer	It’s time to tell your stories with illustrations. \n\nInvolve, an Ed-Startup based on the realm of peer teaching who believes in revolutionising the education system. We are hiring people with creative brains to expand their Graphic Design department. \n\nThese candidates will be working on a broad spectrum of Visual Communication consisting of Illustrations, Typography,  Page layout techniques, etc. to create Visual Compositions on Digital Media. \n\nCandidates will be working on Corporate Designs such as Logos and Branding, Editorial design, and Advertising such as Posters. We are looking for a trustworthy individual with a fair sense in Aesthetics and experience in Design tools such as Adobe Illustrator or any tools which deal with vector graphics.		Graphic Designer	Minimum 4 weeks	3000-8000 (Depending on work)	2	Chennai or Bangalore	No	Adobe Photoshop, Illustrator or any other vector graphics software	Should have worked on some design projects!	No	No	Informal dress code, Opportunity to work with founders, Huge Networking 	Department of Management Studies, IIT Madras	236	verifying
117	113564221505157815723	Full Stack Developer	We believe that technology can be a huge enabler in scaling impact solutions around the world. We at involve are building first of its kind mobile application that will support our operations and put Involve as a global organisation. This will be the key factor in scaling our operations to help a million school students in 5 years. If you are the one who is looking to build technologies for social Impact, Involve would be the right place to begin your journey. \nThe mobile application will be used by the Involve team and the students for their leadership development, program assessment etc.\nThis project has already started and we are looking for smart & passionate people who can take it to the end. 		Full Stack Developer	6 Weeks	5000-10000 per month	1-2	Chennai	No	Java, Android Studio, Web services	Should have worked on some mobile application project before	No	No	Working with Founder, Opportunity to interact with people who build Aadhar, Networking 	IIT Madras	236	verifying
136	109683991238473547277	Development of tool for Protein and DNA Data analysis using AI methods 	Intern have to involve in data analysis for protein structure and  gene sequence using AI methods , he may require to code for custom application with current team of expert. 		Data Analytics 	Minimum 4 week	5000	1-2	Bio-Incubator, Phase 2 , IIT Madras -Research Park	yes	Python , Statistics , Artificial Intelligence 	Should know programming	No	No	NA	Medha Innovation and Development Pvt. Ltd \nBio-Incubator , Phase 2 , IITMIC - research park, Chennai	259	verifying
118	101396729595279031815	Sales & Marketing	Sales-Intern Job Duties & Responsibilities\nConnecting with colleges for seminars, workshops and other events\nCommunicating with campus ambassadors of Chatur Ideas for delegation of tasks\nCollaborating with E-Cells of different colleges for future correspondence such as E-Summits, Startups Support, Workshops, etc.\nCompetitive Analysis and Market Survey  for new startups approaching Chatur Ideas\nResearch and Build relationships with New clients.\nReach out to customer leads through cold calling.\nEstablish, develop and maintain positive business and customer relationships.\nLead Generation through networking, Database, CRM.\nAnalyze the territory/market's potential, track sales and status reports.\n\nSkills Required\nGood communication skills\nGood written and verbal English communication \nGood negotiation skills\nKnowledge of MS.Office (Ms. Excel, Word, Powerpoint) is must\nInternet savvy\n		Sales & Marketing	2-3 Months	5000 - 15000 INR + Incentives	3-5	Work From Home, Mumbai Office	Yes	Skills Required\nGood communication skills\nGood written and verbal English communication \nGood negotiation skills\nKnowledge of MS.Office (Ms. Excel, Word, Powerpoint) is must\nInternet savvy\n	MS. Office well versed	NO	NO	Informal Dress Code	Chatur Ideas, 101, Kuber, Andheri Link Road, Andheri (W), Mumbai – 400053.	262	verifying
119	101396729595279031815	Operations & Analysis	Intern Job Description for Operations post\nHandling end to end Campus ambassador hiring\nUtilize the campus ambassador for getting the work done\nUnderstanding the existing operations to identify and streamline the processes by eliminating the wastes.\nSkills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n		Operations & Analysis	2-3 Months	5000 - 10000 INR + Incentives	3-5	Work from Home, Mumbai Office	Yes	Skills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n	Ms. Office well versed	NO	NO	Informal Dress Code	Chatur Ideas, 101, Kuber, Andheri Link Road, Andheri (W), Mumbai – 400053.	262	verifying
123	105202096528458362102	AI Analyst Programmer	Organizations across globe have invested in establishing granular levels of data points to develop deep level of understanding about their customers. This includes marketing, leads, sales, on boarding, fulfillment support and every other thinkable stage in the journey of a customer. In parallel, there has been technology revolution which has made it possible to analyse large scale of data sets to generate insight about the customers. At Genesys, we are looking to help our clients leverage their investment in large data sets to improve business outcomes and drive better customer experience.  		AI Analyst Programmer	Minimum 8 weeks	25000	2-3	SP Infocity, Perungudi, Chennai	No	-\tHave exposure to Extract, Transform and Load (ETL) tasks and related tools/interfaces like Athena, Kafka, Kinesis, S3 and Redshift Data marts\n-\tConversant with SQL across range of database platforms like MS SQL, Oracle, PostgreSQL, Redshift \n-\tCan understand discrete and continuous data sets with ability to identify right mathematical models for making high precision predictions.  \n-\tHave applied Natural language understanding (NLU) and Natural Language Programming (NLP) concepts to unstructured textual data.  \n-\tProgramming skills in any f the following languages of Python, R, Scala	Right candidate will be able to extract, clean and process data to build mathematical models for predicting business outcomes. The candidate will have excellent analytical capability to see through data patterns underlying a business problem. Ideal candidate would enjoy building a statistical view of the business problem and come up with independent algorithm to solve these problems. They will have a learning attitude to pick up new technologies, tools and programming on the go with a self-help approach.  	No	No	No	Genesys Telecom Lab India\nGlobal Infocity (SP Infocity), C Block, 4th Floor \n40, MGR Salai, Perungudi, Chennai	272	verifying
124	103319782156851133364	Pathogen Detection with Spectroscopic Techniques- Proof of Concept	The conventional technique to detect the Pathogens is to follow Microbiology.  These techniques are time consuming and labor intensive.   Alternate technologies are needed to speed up the detection (and with quantification).  The emerging Spectroscopic techniques have the potential to detect the molecular species (either organic or inorganic). The present project by M/s Thin Film Solutions is to explore the potential of Spectroscopic techniques to detect the bacteria and pathogens.  		basic knowledge in cell culture and basic knowledge (of undergraduate course) in Optics.	Minimum SIX to EIGHT weeks 	0	2	Chennai	YES	Basic knowledge in microbial cell culture and basic knowledge of Optics (of undergraduate level). Should have a good flare for conducting experiments. 	Attitude for research	The Intern has to look for his accommodation	2 AC travel from the Home town of teh Intern	Informal Dress. SIX day week. 	Dr A Subrahmanyam, M/s Thin Film Solutions, C-2 3rd Loop Road, IIT Madras, Chennai 600036. 	274	verifying
125	104089503500603657430	Project Intern	Qualifications: BE/B-Tech – Electronics and Communications.\nPrimary Role/Scope of Job: \n•\tDeveloping verilog code.\n•\tDefining verification methodology\n•\tBuilding a test bench for self-checking verification.\n•\tModeling of IP to verify RTL functionality vs. requirements.\n•\tWork with software team to implement changes required by the driver. \n•\tModify the design for future features in the FPGA. \n•\tUnderstand over-all chip power save modes and external system requirement.  		FPGA RTL Designer/Hardware Designer	Minimum 8 weeks	10k per month	2-3	Bangalore	Yes	•\tStrong knowledge of ASIC and/or FPGA design methodology and should be well versed in front-end design, simulation, and verification CAD tools.\n•\tExcellent verbal, written and communication skills are required.\n•\tExcellent follow-through, motivation, and persistence\n•\tStrong technical judgment\n•\tKnowledge of digital board design and signal integrity principles is a plus	•\tHas deep knowledge of Xilinx FPGA implementation and tools.\n•\tExperience in state of the art tools and flows.\n•\tSound Knowledge of logic design and RTL implementation\n•\tBoard level testing to validate RTL design\n•\tDesign Documentation\n•\tExperienced with VHDL (desirable)\n•\tActive participation in internal Design Reviews (desirable)\n•\tEthernet - 100/1000 Mbps \n•\tPCIE 2.0 \n•\tSPI\n•\tUART	No	No	5 days a week, informal dress code, fun outings/celebrations	Centenary Building, 2nd Floor, East Wing, MG Road, Bangalore-560025, Karnataka.	258	verifying
137	109683991238473547277	Bioinformatics Analysis using BigOmics and other application 	Task is to perform comparative experiment with different use case and benchmark the accuracy of output. Task may vary across the duration of internship based on requirement. Final outcome may be a publication.		Bioinformatics Analyst	4 week	5000	1-2	Phase2, Bioincubator,  IITMIC - Research Park	yes	Bioinformatics tools understanding , Biological data understanding 	Bioinformatics awareness 	No	No	No	Medha Innovation and Development Pvt. Ltd\nBio incubator , Phase 2 , IITMIC - Research park , Chennai	259	verifying
127	111320166102807820736	Data Interns	Peacock Solar is a Sangam Ventures, Gurgaon, incubated startup aimed at accelerating mass adoption of residential rooftop solar in India, through standardized product offering, easy financing, and efficient execution at scale. Founded by IIT, ISB & IIM alumni, Peacock Solar has been recognized as one of the top 9 innovative ideas in Climate Finance Lab's idea cycle of 2018. Since its inception, Climate Finance Lab ideas have mobilized more than $1.2 billion towards sustainable development. Recently, Peacock Solar has been awarded grant support by US-India Clean Energy Finance for project preparation support. \n\nInterns would assist Peacock Solar in optimizing marketing & operations by analyzing existing customer data, creating segmentation models, analyze campaign level data and source data. You'd get involved in the core data team and work with them towards running projects in optimization and process improvement. Detailed tasks are as follows - \n\n•\tSelecting features, building and optimizing classifiers using machine learning techniques\n•\tData mining using state-of-the-art methods\n•\tExtending company’s data with third party sources of information when needed\n•\tEnhancing data collection procedures to include information that is relevant for building analytic systems\n•\tProcessing, cleansing, and verifying the integrity of data used for analysis\n•\tDoing ad-hoc analysis and presenting results in a clear manner\n•\tCreating automated anomaly detection systems and constant tracking of its performance\n•\tExtract/Transform/Clean the data and generate the reports \n•\tApplying predictive analysis to create strategy of marketing targeting and positioning\n•\tBuild the Predictions Model and Intelligently selection of variables. \n•\tDevelop company A/B Testing Framework and test model quality\n•\tDevelop process and tools to monitor and analyze model performance and data accuracy.\n		Data Internship	10 weeks	10000	2	Gurgaon	No	•\tExcellent understanding of machine learning techniques and algorithms related to regression / clustering/predictions/anomaly, such as k-NN, Naive Bayes, SVM, Decision trees, Random forests, etc.\n•\tExperience with common data science toolkits, such as R, Python etc.\n•\tGreat communication skills\n•\tExperience with data visualization tools, such as D3.js, GGplot, Tableau etc.\n•\tProficiency in using query languages such as SQL\n•\tGood applied statistics skills, such as distributions, statistical testing, regression, etc.\n•\tGood scripting and programming skills \n•\tKnowledge of PHP, Javascript\n•\tExperience in Web Services like AWS, Mysql Dbs, \n•\tData-oriented personality with experience working in similar field. 	NA	NO	NO	Flexible hours, informal dress code, Open leave policy	Peacock Solar, C/o Sangam Ventures, 5th Floor, Plot 146, Sector 44, Gurgaon - 122002	263	verifying
144	114503787094540282981	Application Development 	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nDesign and build advanced applications\nAbility to work with data structures, No-SQL		Application Development 	8 weeks	20000	2	Bangalore	no	Python, Angular, PostgreSQL, Android	None	No	No		9th Main, Indiranagar, Bangalore	244	verifying
145	114503787094540282981	Data Scientist	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nComputer vision and deep learning solutions, including image classification, object detection, segmentation, and equivalent computer vision-based vision tasks\nExperience with common data science toolkits, such as R, Weka, NumPy, etc \n		Data Scientist	8 weeks	20000	2	Bangalore	no	Experience with common data science toolkits, such as R, Weka, NumPy, etc \n	no	no	no		9th Main, Indiranagar. Bangalore	244	verifying
133	111320166102807820736	Website Developer	Develop new user-facing features\nBuild reusable code and libraries for future use\nEnsure the technical feasibility of UI/UX designs\nOptimize application for maximum speed and scalability\nLay the groundwork for web-based assets (e.g., web pages, HTML emails, and campaign landing pages)\nTake care of the ongoing activities of the websites. (i.e. blog post, articles etc.)\nDevelop the new pages and functionality as per the business demand\nEstablish coding guidelines and provide technical guidance for other team members\nDevelop innovative, reusable Web-based tools for activism and community building\nMaintenance and administration of website file repository\nHandle website deployment and build process		Web Developer Intern	10 weeks	10000	2	Gurgaon	NO	Experience developing div based or table less web pages from graphical mock-ups and raw images\nExpert in modern JavaScript MV-VM/MVC frameworks (Vue.js, Meteor.js, Angular.js, Node.js Development most preferred)\nHands on experience in delivering medium to complex level applications\nProficiency with Object Oriented JavaScript, ES6 standards, HTML5, CSS, Typescript, MongoDB.\nExperience in developing Responsive pages using Bootstrap or equivalent\nStrong in programming concepts OOPs, modularization, object creation within loops etc and test driven approach\nFlair to bring in unit test cases (e.g Jest, Chai, Mocha ,Jasmine (or a well-reasoned alternative)\nExperience in JavaScript build tools like Webpack, Grunt, Gulp\nFundamental understanding of Cloud, Docker and Kubernetes environments\nCreating configuration, build, and test scripts for Continuous Integration environments (Jenkins or Equivalent)\nExperience in all phases of website development lifecycle\nBe able to understand high-level concept & direction and develop web experience/web pages from scratch\nMust be proficient at resolving cross-browser compatibility issues.\nExperience on cross Device Mobile web development\nShould have knowledge of Web Developing tools like Firebug, FTP etc.\nAbility to juggle multiple projects/priorities & deadline-driven\nStrong problem identification and problem solving skills\nExcellent communication skills, Ability to work effectively as a team member, across project teams, and independently	NA	NO	NO	Informal Dress-code, flexible hours, certificate upon completion	Peacock Solar, C/o Sangam Ventures,  5th Floor, Plot 146, Sector 44, Gurgaon  - 122002	263	verifying
134	110988755828086628184	Design & Creative	About LeanAgri (https://www.leanagri.com/):\nLeanAgri is an IIT-Madras startup developing solutions in the agri-tech sector. With support from prestigious institutions like ICRISAT (International Crop Research Institute for Semi-Arid Tropics, UN Organization), we are offering technical assistance to farmers and farmer organizations.\n\nAbout the Internship:\nSelected intern's day-to-day responsibilities include: \n\n1. Designing in-app screens, delivering design requirements by the Product team.\n2. Delivering day-to-day design requirements - posters, pamphlets, banners\n3. Capturing and creating testimonial and product videos\n\n# of Internships available: 1\n\nSkill(s) required: Adobe Photoshop and Video Editing\n\nPerks:\nCertificate, Informal dress code.	https://res.cloudinary.com/saarang2017/image/upload/v1550749612/ecell/upelmu6f0bsvejhvezzc.pdf	Design & Creatives	2 Months ( 9 Weeks)	8000	1	Pune	No	Adobe Photoshop \nVideo Editing and Creatives (VFX & Media)	Should have prior experience in Design and VFX.	No	No	Informal Dress Code	LeanAgri, Teerth Complex, Baner, Pune, Maharashtra - 411045	276	verifying
138	105500817840272313799	Write code that will empower people with disabilities!	Are you passionate about writing code that is so amazing that it can change lives, literally?\nHave you dreamed about building technology to empower people with disabilities? Are you\nexcited to take on challenges? Does constant learning give you a high? \nIf this describes you, we would love to have you on our team!\n\nAs a Mobile App Developer Intern at Invention Labs, your responsibilities will include:\n\n1. Work with Android/iOS and other mobile app technologies (like Flutter) to develop new or improve existing mobile applications\n2. Working with the team to brainstorm ideas on product features\n3. Maintaining technical documentation of the work\n4. Creating the next generation of assistive technology products\n5. Working to solve real-life problems faced by children with special needs around the world\n6. Working closely with product development and understand what goes into making products that impacts people lives significantly\n		Mobile App Developer Intern	Minimum 7 weeks	12000	2	Chennai	Yes	Java & Android app development\nor Swift/Objective-C\nor Flutter 	Ready to learn any new programming language/technology	No	No	The incentive to change people's lives!	IIT Madras Research Park \n4th Floor, Taramani, Chennai - 600085\n	285	verifying
139	117306459721549242620	Machine Learning and Computer Vision	The Candidate should be a highly motivated, detail-oriented individual to join our team and work in a MedTech startup environment. The candidate will be developing computer vision and artificial intelligence algorithm for a handheld medical device/application. The candidate shall perform full software lifecycle development within a multidisciplinary team environment.  Duties would include solution building for the concept, algorithm development, software engineering, data/image handling, implementation, and testing.	https://res.cloudinary.com/saarang2017/image/upload/v1550826952/ecell/qkmdov0tx1uvrfljshpp.pdf	Machine Learning Engineer	2 Months	10000	2	Chennai	Yes	 MATLAB, OpenCV and relevant - Image processing, Object detection and piecewise Pattern Matching and recognition, studio/Eclipse integrating OpenCV Library. 	Should have basic knowledge of Biology and medical devices	No	No	Certificates	Curneu MedTech Innovations Private Limited, No.1, 5th Floor, IIT Madras Research Park, Taramani, Chennai - 600113	281	verifying
140	117306459721549242620	CAD - Micro Mechanics, Robotics &  Rapid Prototyping	The Candidate should be an experienced, detail-oriented individual to join our team and work in a MedTech startup environment. The candidate will be involved in designing models of medical devices and surgical tools, rapid prototyping and, micromechanical system development. Duties would include solution building for the concept ideas, design planning, human-centered designing, and analysis.	https://res.cloudinary.com/saarang2017/image/upload/v1550826830/ecell/lrrdhjz3ayis8zjxgzsa.pdf	CAD Mechanical Designer	2 Months	10000	1	Chennai	Yes	Solidworks, Catia or Creo	Should have basic knowledge in biology and medical devices.	No	No	Certificates.	Curneu MedTech Innovations Private Limited, No.1, 5th Floor, IIT Madras Research Park, Taramani, Chennai - 600113	281	verifying
141	103765838603107363304	Marketing Intern	Looking for enthusiastic marketing interns to join our team and provide creative ideas to achieve our goals. You will also have administrative duties in developing and implementing marketing strategies while helping maintain and expand our existing channels.\nThis internship will help you acquire marketing skills and provide you with knowledge of various marketing strategies. Ultimately, you will gain broad experience in marketing and should be prepared to enter any fast-paced work environment.\nWe are looking for talented individuals who are willing to step out of their comfort zone to join us in making history.\nCome join the #AIRecruitingRevolution		Marketing	4-12 weeks	15000	1-2	Hyderabad	No	Strong Verbal/Written Communication Skills\nProblem Solving Skills\nPassion for Marketing	NA	No	No	5-day weeks, Informal Dress code, A dynamic start-up environment that inspires camaraderie	Vindhya C-6, CIE, IIIT Hyderabad,\nGachibowli, Hyderabad, Telangana	286	verifying
142	103765838603107363304	Software Engineering Intern	As a member of the Software Dev Team, you will be building high-quality products in the Recruiting Automation Space. You would design and write code that is reliable and robust, highly scalable and offers a great user experience. You don’t just code features, you will take ownership of them, cross-collaborate across teams, design solutions, implement them, and see them through till they are live in production. Being part of a nimble and agile team, you are creative and can come up with solutions to problems in any aspect of the product and take the initiative to solve them. \nWe are looking for talented individuals who are willing to step out of their comfort zone to join us in making history.\nCome join the #AIRecruitingRevolution.		Software Engineer	4-12 weeks	15000	3-5	Hyderabad	No	Highly Skilled with at least one of Python, Django, PostgreSQL\nWorking knowledge of AWS is a plus	NA	No	No	5-Day Weeks, Informal Dress Code, Fast-paced Dynamic Work Environment	Vindhya 6-6, CIE, IIIT Hyderabad,\nGachibowli, Hyderabad, Telangana	286	verifying
143	105500817840272313799	Write Web Apps to Empower people with special needs	Are you passionate about writing code that is so amazing that it can change lives, literally?\nHave you dreamed about building technology to empower people with disabilities? Are you\nexcited to take on challenges? Does constant learning give you a high? \nIf this describes you, we would love to have you on our team!\n\nAs a Web App Developer Intern at Invention Labs, your responsibilities will include:\n\n1. Work with Python and other web technologies to develop new or improve existing web applications\n2. Working with the team to brainstorm ideas on product features\n3. Maintaining technical documentation of the work\n4. Creating the next generation of assistive technology products/services\n5. Working to solve real-life problems faced by children with special needs around the world\n6. Working closely with product development and understand what goes into making products that impacts people lives significantly		Web App Developer Intern	Minimum 7 weeks	12000	2	Chennai	Yes	Good programming skills	Python\nJavaScript \nBasic knowledge of CSS, HTML	No	No	Ship code that will empower people with disabilities!	IIT Madras Research Park\n4th Floor, \nTaramani, Chennai - 600113	285	verifying
\.


--
-- Data for Name: student_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_details (id, full_name, roll_num, college, branch, cgpa, contact_number, alt_contact_number, alt_email, resume_url, is_paid, payment_link, payment_id, user_hid, payment_request_id) FROM stdin;
17	Mritunjoy Das	AE16B111	\N	\N	\N	9435840783	\N	\N	\N	f	https://www.instamojo.com/@joeydash/cd5fb6a3b11b435f840559224675c3cb	\N	100680093250543498335	cd5fb6a3b11b435f840559224675c3cb
\.


--
-- Data for Name: user_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_detail (id, name, email, image_url, user_h_id, startup_name, startup_id) FROM stdin;
1499	Hemant Ahirwar	hemantahirwar1@gmail.com	https://lh6.googleusercontent.com/-5ZZuFm2wgZM/AAAAAAAAAAI/AAAAAAAAAaw/TCx1OJbyvoI/s96-c/photo.jpg	106774401436596091547	\N	\N
1634	Baskaran Manimohan	baskaran@ahventures.in	https://lh6.googleusercontent.com/-R_pscFX1LGY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOnOjYw9yc5_QaMPrq1YAPJgaRhKw/s96-c/photo.jpg	104379184185174428302	\N	277
1648	Joey Dash	joydassudipta@gmail.com	https://lh3.googleusercontent.com/-hjMQ9VBKHIw/AAAAAAAAAAI/AAAAAAAAFDk/ePiRR90JHaM/s96-c/photo.jpg	118208723166374240159	\N	230
1533	Hari Kishore P na18b019	na18b019@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7ar-bG4aw2w/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP2J9tbNK64Sf_yvE5lfHaOM-0LZQ/s96-c/photo.jpg	103546078731885007120	\N	\N
1580	pooja chaudhary	pooja.chaudhary@karexpert.com	https://lh5.googleusercontent.com/-c6v8I1dADQU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPcozpYmh_u32MT6W9GzvNQm60nDg/s96-c/photo.jpg	106407488023143571708	\N	229
1324	Ankita Modi	ankita.modi@addverb.in	https://lh5.googleusercontent.com/-suM92JNNkUk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNdSKp7QAXefhA5OxZ9lVusl1qghg/s96-c/photo.jpg	106123538173898449055	\N	201
1820	Anjali Sharma	hr@ebabu.co	https://lh5.googleusercontent.com/-7yf0hfOUXuM/AAAAAAAAAAI/AAAAAAAABLc/QxkDT9PHVZ4/s96-c/photo.jpg	101326090802695787002	\N	245
1638	Vellayan L	vellayanl@iloads.in	https://lh6.googleusercontent.com/-IdcrdUP8L-k/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMXUi8NlZNmIk2gD_qEvlW8wfYbqg/s96-c/photo.jpg	100898145044469393733	\N	230
1551	Victor Senapaty	victor@propelld.com	https://lh5.googleusercontent.com/-JGTwFKlfLAU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMWx1IG1Nsw7h59mWbin_r3ud9P7Q/s96-c/photo.jpg	107530024622485449869	\N	224
1808	Drusilla Pereira	drusilla@gramophone.co.in	https://lh4.googleusercontent.com/-ejdc_65PXsI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOUfBKMXBHrl7nTbHQqP1Qbq_3opQ/s96-c/photo.jpg	114503787094540282981	\N	244
1629	HR Srjna	hr@srjna.com	https://lh5.googleusercontent.com/-uVS0-3hO7LQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPKZi2z0WedozGVkflxdkNlehxzkQ/s96-c/photo.jpg	102476915533780948091	\N	231
1608	Chitra, i-loads Senior Manager - Human Resources, Chennai	chitra.c@iloads.in	https://lh5.googleusercontent.com/-y38YE6HlZC8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMDusom469Yz_o4iCgGt5tY_gDHEA/s96-c/photo.jpg	110505594872527456493	\N	230
1806	Ashish Singh	ashish@gramophone.co.in	https://lh5.googleusercontent.com/-cqrVnebIQdI/AAAAAAAAAAI/AAAAAAAAAAo/GeFXTRrZvSE/s96-c/photo.jpg	111030578426826726626	\N	\N
1558	Vivek Gupta	vivek@wishup.co	https://lh4.googleusercontent.com/-Gt4DkI38qY8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOYi5mh4Nm4z7AjFO2LvfC-g14XaA/s96-c/photo.jpg	104298758991766668035	\N	225
1773	Rahul Joshi	rahul.joshi@voylla.com	https://lh4.googleusercontent.com/-e7dvGvQd9-Y/AAAAAAAAAAI/AAAAAAAAEI4/k-p8zYRxPfI/s96-c/photo.jpg	111133250649424423782	\N	237
1645	Manvendra Pratap Singh	singh.manvendr20@gmail.com	https://lh3.googleusercontent.com/--A62WIOaguU/AAAAAAAAAAI/AAAAAAAAEvA/kfC1tY_rV3c/s96-c/photo.jpg	110447218383396106962	\N	232
1754	HR iB Hubs	hr@ibhubs.co	https://lh6.googleusercontent.com/-Mb9A0FoE194/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO2Ge_dmMUD5zoRXnbXy7A_bVEczA/s96-c/photo.jpg	102540152476572591754	\N	235
1772	Namrata Agrawal	a.namrata@meeshamed.net	https://lh4.googleusercontent.com/-hpJN4C2AWlE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPsqk5W4sSESVbw-OXqsFyaSXdq7g/s96-c/photo.jpg	116519274255305915920	\N	\N
1793	Hemanth Sridhar	hemanth@planetworx.in	https://lh5.googleusercontent.com/-H9hstPfmDag/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPtZYjn2z06MUdSVJHofX6v8G3gCw/s96-c/photo.jpg	114749538391689307031	\N	242
1534	Sowmya Bezawada	sowmya@ibhubs.co	https://lh4.googleusercontent.com/-MldLgG5D6bY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNy2n8yZd4zDxUi5PbhOigKnK9V4g/s96-c/photo.jpg	105373738578694994605	\N	234
1740	Anubha Verma	anubha@rentsher.com	https://lh3.googleusercontent.com/-BTH4OPMUvvM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPUVIgg6ig6emPX8ZRIOFFuDwZA5g/s96-c/photo.jpg	115802938042318956916	\N	233
1780	Valentina Dsouza	valentina@ionenergy.co	https://lh4.googleusercontent.com/-qAHNUjR_FSU/AAAAAAAAAAI/AAAAAAAAAC0/nsT7Vb3NMb4/s96-c/photo.jpg	117013339697530495306	\N	238
1766	Divanshu Kumar	divanshu@involveedu.com	https://lh3.googleusercontent.com/-pwwKPuIF0lA/AAAAAAAAAAI/AAAAAAAAACo/JUDrNjkDdVM/s96-c/photo.jpg	113564221505157815723	\N	236
1626	Pankaj Lal	pankaj@mammoth.io	https://lh5.googleusercontent.com/-m6DE_LA4iSM/AAAAAAAAAAI/AAAAAAAAALg/w5oVGQwbPXg/s96-c/photo.jpg	100916162979211575903	\N	250
1739	Sirish Somanchi	sirishks@gmail.com	https://lh6.googleusercontent.com/-3fKko1-sRgI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOb8CK8-KSCqlGs1NTVdzM52C_E1g/s96-c/photo.jpg	108825759819157028428	\N	243
1848	Deepak Sahoo	flashiitm@gmail.com	https://lh4.googleusercontent.com/-weDwsWzPJbk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPuCu07-lzA24_y1z7A7ktmddIYOA/s96-c/photo.jpg	117894875203741245699	\N	246
1611	Pratik Sharma	pratik.sharma1619@gmail.com	https://lh6.googleusercontent.com/-1bRl68CnrqI/AAAAAAAAAAI/AAAAAAAAOts/D1LPi15cunU/s96-c/photo.jpg	101818747050100224079	\N	228
1576	Sidharth Bhatia	bhatiasidharth.89@gmail.com	https://lh6.googleusercontent.com/-SgB6K1OREjg/AAAAAAAAAAI/AAAAAAAAAFA/IQug2PnkDjM/s96-c/photo.jpg	102584910929681137125	\N	\N
1885	Vibhor Kumar	vibhor.kumar@stanzaliving.com	https://lh5.googleusercontent.com/-B99IWpQLIFs/AAAAAAAAAAI/AAAAAAAAACw/qAjsXSzuFSM/s96-c/photo.jpg	115375476385745576962	\N	249
2189	Arokia Doss	arokia.d@srivishnu.edu.in	https://lh4.googleusercontent.com/-DDz9gu_vriY/AAAAAAAAAAI/AAAAAAAABqM/idtU5Q7OJao/s96-c/photo.jpg	115342870212009600095	\N	\N
2144	Sv J	srvajw@gmail.com	https://lh4.googleusercontent.com/-l5qFWbey1rk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN1SpZGyHHiMzehgUD_dC6jGboCOQ/s96-c/photo.jpg	101107640131204357570	\N	260
2083	iB Hubs Careers	careers@ibhubs.co	https://lh6.googleusercontent.com/-75N50cGyVXk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNxgeooH6nnrKGB9PHmOXDJO0UbXw/s96-c/photo.jpg	104821578026829852225	\N	\N
1914	Chandresh Vaghanani	chandresh@allevents.in	https://lh5.googleusercontent.com/-XMRGJqKg4fY/AAAAAAAAAAI/AAAAAAAAAzs/fMNjYRw3Xyo/s96-c/photo.jpg	109249031263145344654	\N	251
1908	Varun Chopra	chopravarun01@gmail.com	https://lh6.googleusercontent.com/-YxfnlUFwfPs/AAAAAAAAAAI/AAAAAAAAKwU/N3HuaVdpmeo/s96-c/photo.jpg	101189951357074482183	\N	\N
2224	Muralidhar Somisetty	muralidhars@wellnesys.com	https://lh6.googleusercontent.com/-mOvpU4EPmPE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMztpS4us1LBpvIDUIfKw-CnBeJiw/s96-c/photo.jpg	101907162894505620447	\N	268
2017	Eduvanz Financing Private Limited	the.eduvanz@gmail.com	https://lh3.googleusercontent.com/-1qtGcLbjwdk/AAAAAAAAAAI/AAAAAAAAABU/p_aZDivYYN8/s96-c/photo.jpg	107429974676687296166	\N	253
2221	PORANDLA RANADEEP	16211a0388@bvrit.ac.in	https://lh4.googleusercontent.com/-iwKtev5m9Dg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNdF-PCngwVtSaEVRsgEqTZAUk_Ow/s96-c/photo.jpg	109234805044650346236	\N	\N
2131	Amogh Bhatnagar	amogh.bhatnagar53@googlemail.com	https://lh3.googleusercontent.com/-37Faz4dRV38/AAAAAAAAAAI/AAAAAAAAEU8/vXYySqtBFgw/s96-c/photo.jpg	109683991238473547277	\N	259
1880	Web Operations webops_ecell	webops_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-E2NF3HyXPss/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMZOW5D3dm1h0LBTxEsyI5-IDk1RQ/s96-c/photo.jpg	107813869731075135750	\N	\N
2222	PULLILA ABHISHEK	17215a0501@bvrit.ac.in	https://lh3.googleusercontent.com/-6AHD4shviaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMgKhy_bbxPLSpJX0lOSFx64yoEPg/s96-c/photo.jpg	113903073200127800235	\N	\N
1955	Ashwin Kumar	ashwin@backbuckle.io	https://lh5.googleusercontent.com/-DYQwQjQqDH4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNBpbgF0pfaLFeAJ4awlb2lds1atA/s96-c/photo.jpg	110274344916933599324	\N	252
2092	Sreenivas Murali	sreenivas.nm5493@gmail.com	https://lh5.googleusercontent.com/-2Bd0fAy5Btc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPzSk3Pge0iU_1YnF-U0EZaReZz_g/s96-c/photo.jpg	103304235098083374178	\N	257
2182	Nirmal Sharma	nirmal2502@gmail.com	https://lh4.googleusercontent.com/-7uKiqWI0nK0/AAAAAAAAAAI/AAAAAAAACno/by8P5qeMagU/s96-c/photo.jpg	106289280886691331250	\N	\N
2227	varun kolakani	varun.kolakani007@gmail.com	https://lh5.googleusercontent.com/-VP9wQ0JwEcM/AAAAAAAAAAI/AAAAAAAAABY/ANufxi1v4-M/s96-c/photo.jpg	108896450923947891853	\N	\N
2115	Snehal Gupta	snehal@qunulabs.in	https://lh3.googleusercontent.com/-gZxfoCCf1UA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNEbLCQjHdwDKKKEz5tRg-rbbzIsA/s96-c/photo.jpg	104089503500603657430	\N	258
2214	Praveen Kolakani	praveenkolakani1998@gmail.com	https://lh3.googleusercontent.com/-O0TPncsPLxI/AAAAAAAAAAI/AAAAAAAADzk/hhyespOKVQk/s96-c/photo.jpg	109266082501365237941	\N	\N
2215	prameela devi	prameela5128@gmail.com	https://lh6.googleusercontent.com/-x7QCVuzbCj4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPQFcWy46_1IBY9uVxkwKwk4s08oQ/s96-c/photo.jpg	101056800285643890923	\N	\N
2216	narsimha kondaji	narsimhakondaji21@gmail.com	https://lh6.googleusercontent.com/-K3jgFwG2OtE/AAAAAAAAAAI/AAAAAAAAEIc/W7OxN725og8/s96-c/photo.jpg	107564555087017130990	\N	\N
2046	Hitesh Haran	hitesh.k.haran@gmail.com	https://lh4.googleusercontent.com/-4xVqveUHGGI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOOCl71LV997f_lClUh1VK20dHOyA/s96-c/photo.jpg	105202096528458362102	\N	272
2187	Peacock Solar	peacocksolarenergy@gmail.com	https://lh3.googleusercontent.com/-CaUmwAeoyfQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP4VPga2UQSICxFXI6W1Gv-ZZnX-w/s96-c/photo.jpg	111320166102807820736	\N	263
2217	Abhishek reddy	abhishek.balannolla@gmail.com	https://lh3.googleusercontent.com/-igJ3MwDy19Y/AAAAAAAAAAI/AAAAAAAAIek/VxsVChJg0MA/s96-c/photo.jpg	110959428559525986265	\N	\N
2184	Vishal Mistry	vishal@chaturideas.com	https://lh4.googleusercontent.com/-l_8se3lLPBw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMMCBIp09V_MjJzyaSqnVycum0KzQ/s96-c/photo.jpg	101396729595279031815	\N	262
2218	MEKALA PRUDHVI REDDY	16211a05e4@bvrit.ac.in	https://lh4.googleusercontent.com/-2V9seW0cBx8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMv4BzIcSAO6LXR0rl2K3Ii0BzVWw/s96-c/photo.jpg	106711601084471424539	\N	\N
2219	KONDURU SHIRIDINATH	16211a0235@bvrit.ac.in	https://lh4.googleusercontent.com/-EMGxZ8z_HSM/AAAAAAAAAAI/AAAAAAAAAAU/3S6AYdk2RLg/s96-c/photo.jpg	115023583903933855531	\N	\N
2012	Mohammed Zakkiria	zakkiria@freightbro.com	https://lh4.googleusercontent.com/-hvMh_zOJeIY/AAAAAAAAAAI/AAAAAAAABoA/ky1R7SyW80g/s96-c/photo.jpg	103686313929651160614	\N	\N
2234	prudhvi reddy	prudhvireddy.m01@gmail.com	https://lh5.googleusercontent.com/-CNmi2bRjUgg/AAAAAAAAAAI/AAAAAAAAACk/2GAAz4IdDIY/s96-c/photo.jpg	102641646898857644341	\N	\N
2239	R Gyanesh	16211a1277@bvrit.ac.in	https://lh4.googleusercontent.com/-YjwnhbZHoFY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOhet8EOT_NSsDc9Uh4rB6zCMH7rQ/s96-c/photo.jpg	111287724851133369161	\N	\N
2241	SAI CHARAN JANA	jana.cherry2010@gmail.com	https://lh5.googleusercontent.com/-Jb-GbRnVQpc/AAAAAAAAAAI/AAAAAAAAABI/REdcXDcYhOM/s96-c/photo.jpg	107831550891832625063	\N	\N
2243	Ritesh Yadav	riteshyadav654@gmail.com	https://lh4.googleusercontent.com/-flpKf188R3A/AAAAAAAAAAI/AAAAAAAAMsg/dKLM-B52qeg/s96-c/photo.jpg	110296223890564310627	\N	\N
2247	SAIRAM BOLLEPALLI	17215a0314@bvrit.ac.in	https://lh5.googleusercontent.com/-OYFZHYLL-yw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMc1iDx-8DIysajrluW5oo5VZr9wA/s96-c/photo.jpg	106840195352712555805	\N	\N
2252	Aravind Reddy Sarugari	aravindreddy08sarugari@gmail.com	https://lh3.googleusercontent.com/-5TqKukyZ8n0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNPzcrIT2nQDhCvqjaDTqX2F6_60A/s96-c/photo.jpg	103413867609203995396	\N	\N
2254	Raj Samurai @ EVP (Expert Value Pack LLP)	raj@expertvaluepack.com	https://lh6.googleusercontent.com/-M4vf3MAVzI0/AAAAAAAAAAI/AAAAAAAACP0/Qc6X7Qegy2Y/s96-c/photo.jpg	115583909410869064703	\N	\N
2265	SARUPURI DHEERAJ	16211a0337@bvrit.ac.in	https://lh4.googleusercontent.com/-crMr5Mn5tyc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNG6gdlZZ0ooqo2rtaTrHXkODmJFw/s96-c/photo.jpg	113375788251733149094	\N	\N
2380	aman verma	amanverma96.15@gmail.com	https://lh6.googleusercontent.com/-B7plUvA029c/AAAAAAAAAAI/AAAAAAAACw0/4bz0EgOIEGg/s96-c/photo.jpg	110988755828086628184	\N	276
2415	Narayanan R	narayananr@avazapp.com	https://lh5.googleusercontent.com/-a0WOYonxxu4/AAAAAAAAAAI/AAAAAAAABKs/qAXnrVRXDa4/s96-c/photo.jpg	105500817840272313799	\N	285
2277	Mohammedabdul rafeeq512	nishatsultana0138@gmail.com	https://lh6.googleusercontent.com/-1hnNYvVn8o4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO62Cfuuuf0fKJQA-snqRdkshjH0Q/s96-c/photo.jpg	115020366769667334416	\N	\N
2364	Subrahmanyam Aryasomayajula	tfsmanu@gmail.com	https://lh3.googleusercontent.com/-zwXZVBl-Jgw/AAAAAAAAAAI/AAAAAAAAABA/BUhBudF2XQQ/s96-c/photo.jpg	103319782156851133364	\N	274
2513	Prasanna Venkatesh	prasanna@fixnix.co	https://lh5.googleusercontent.com/-egom7pOHgrk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPRtiui9-xlID2p96sUEWtqIlCmvA/s96-c/photo.jpg	114839727532236749919	\N	\N
2296	Thiyagarajan C.S	mail2thiyaga@gmail.com	https://lh5.googleusercontent.com/-3738LWkHzo4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOXkv9qfCQggknc4FpT6IEXKIrOTQ/s96-c/photo.jpg	116687833430096689153	\N	275
2568	GANGA GUPTA	grguptabhu@gmail.com	https://lh6.googleusercontent.com/-a0_xW7VZ8xA/AAAAAAAAAAI/AAAAAAAAG9w/fs5zMBpU_ck/s96-c/photo.jpg	103007413487745509743	\N	287
2376	MANIGANDLA KARTHIK	16211a05j2@bvrit.ac.in	https://lh5.googleusercontent.com/-f6iU1f21BEk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQORyDNhrJLPQ3lxVY4xL5H5obv0Eg/s96-c/photo.jpg	106907442348505117600	\N	\N
2428	Shubhangi Rastogi	shubhangi.r@thinkphi.com	https://lh5.googleusercontent.com/-kHHY6N0wlSE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOBLhJl46iMX7LNhis8Vm80-mYAqA/s96-c/photo.jpg	105502414900621283479	\N	\N
2298	PAPPU GEETHA RANI	16wh5a0410@bvrithyderabad.edu.in	https://lh3.googleusercontent.com/-GZw2cyt73_U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPGNLkAJvzSucIidE4-PoOeTMsiOA/s96-c/photo.jpg	113035858086387927034	\N	\N
2303	Vivek Mishra	vivek.mishra@vphrase.com	https://lh4.googleusercontent.com/-5C0M5iSUyG8/AAAAAAAAAAI/AAAAAAAAACE/Xz8f72YmXrU/s96-c/photo.jpg	114537148790063843816	\N	\N
2304	Pranav Prabhakar	pranav@mistay.in	https://lh3.googleusercontent.com/-5uerjcW7oUA/AAAAAAAAAAI/AAAAAAAAAB0/x0O3-PL0r4w/s96-c/photo.jpg	103083422834575225895	\N	\N
2546	Saurabh Jain	saurabhjain2702@gmail.com	https://lh4.googleusercontent.com/-v1tXSEetuRw/AAAAAAAAAAI/AAAAAAAAABw/AF3c_Gme-Hw/s96-c/photo.jpg	114818886750636854304	\N	\N
1733	Joey Dash	joeydash@saarang.org	https://lh3.googleusercontent.com/-fqOTgBE-kMg/AAAAAAAAAAI/AAAAAAAAAAc/g8JI3E0AcEw/s96-c/photo.jpg	103441912139943416551	\N	\N
2590	Akshit Bagde	akshit2000.bagde@gmail.com	https://lh3.googleusercontent.com/-VpGqtlLEyIE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOs9cfLQXTGrlpsM3GcPolvoL9mXg/s96-c/photo.jpg	110540228254791393418	\N	\N
2284	Thilagar Thangaraju	thilagar.thangaraju@gmail.com	https://lh6.googleusercontent.com/-aMY57O0b6bk/AAAAAAAAAAI/AAAAAAAAAEE/Djkwp2pcCTk/s96-c/photo.jpg	108454550000095213572	\N	273
2547	SAURABH JAIN me16b071	me16b071@smail.iitm.ac.in	https://lh6.googleusercontent.com/-CRJj8Y-YaT0/AAAAAAAAAAI/AAAAAAAABOA/Vt5lacfmzFk/s96-c/photo.jpg	110553366885836969408	\N	283
2457	Priyanka Meghani	priyanka@rackbank.com	https://lh3.googleusercontent.com/-fvU6-NwPYRQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOjQ-kCeBqt0Jo42cc14_1v8RCW1g/s96-c/photo.jpg	116000450446927027712	\N	\N
2526	Seethaka Supriya	16wh1a05a1@bvrithyderabad.edu.in	https://lh4.googleusercontent.com/-LjxMnUXySeo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPNCHuBiPUPMxbaXAqpkYXkgI3wjQ/s96-c/photo.jpg	117537405273454723771	\N	\N
2458	Human Resource	hr@rackbank.com	https://lh5.googleusercontent.com/-O3HYTeIlvKQ/AAAAAAAAAAI/AAAAAAAAALI/edhKWDJL6ng/s96-c/photo.jpg	112150566284259074738	\N	280
2493	pranay muddagouni	pranaymuddagouni27@gmail.com	https://lh4.googleusercontent.com/-6Y5r7XCjw4Q/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPyc0y8awmH107feHLck-kpuq4Uvg/s96-c/photo.jpg	114268811780135391116	\N	\N
2516	Chief Nixer	shan@fixnix.co	https://lh6.googleusercontent.com/-2UJKOew9Iuk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMM_brzaJ6EK0suS4QMfUGTZ-7pYw/s96-c/photo.jpg	105791111294087052325	\N	\N
2561	Pat V	pat@myally.ai	https://lh6.googleusercontent.com/-UIWAkvzmT70/AAAAAAAAAAI/AAAAAAAACDg/rIFk3P6j73I/s96-c/photo.jpg	103765838603107363304	\N	286
2551	Ramesh Soni	rameshsoni2100@gmail.com	https://lh5.googleusercontent.com/-AnlhE4dV0ys/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPwWvjRuKaittoTz6bsc1PNY1VPIA/s96-c/photo.jpg	107266261851940045387	\N	284
2553	AIRED project	teamepet@gmail.com	https://lh3.googleusercontent.com/-ApB28oseua0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMh8DDW6017C8Di7uxyX54NcB1nUw/s96-c/photo.jpg	117045864410082434432	\N	\N
2518	David Roshan	c.davidroshan@gmail.com	https://lh6.googleusercontent.com/-hkMZYzT7r5Q/AAAAAAAAAAI/AAAAAAAAAvs/6oGX9K7l0AI/s96-c/photo.jpg	117306459721549242620	\N	281
2436	E-Cell IIT Madras	pr_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-kRHk2N5_ISQ/AAAAAAAAAAI/AAAAAAAAAQQ/Pb00b9CWRhw/s96-c/photo.jpg	100680093250543498335	\N	\N
\.


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);


--
-- Name: joey_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.joey_user_id_seq', 2679, true);


--
-- Name: startup_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_details_id_seq', 287, true);


--
-- Name: startup_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_post_id_seq', 145, true);


--
-- Name: student_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_details_id_seq', 17, true);


--
-- Name: user_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_detail_id_seq', 2662, true);


--
-- Name: event_invocation_logs event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);


--
-- Name: event_triggers event_triggers_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_name_key UNIQUE (name);


--
-- Name: event_triggers event_triggers_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hasura_uuid_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hasura_uuid_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: hdb_function hdb_function_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_function
    ADD CONSTRAINT hdb_function_pkey PRIMARY KEY (function_schema, function_name);


--
-- Name: hdb_permission hdb_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_pkey PRIMARY KEY (table_schema, table_name, role_name, perm_type);


--
-- Name: hdb_query_template hdb_query_template_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_query_template
    ADD CONSTRAINT hdb_query_template_pkey PRIMARY KEY (template_name);


--
-- Name: hdb_relationship hdb_relationship_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);


--
-- Name: hdb_table hdb_table_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_table
    ADD CONSTRAINT hdb_table_pkey PRIMARY KEY (table_schema, table_name);


--
-- Name: remote_schemas remote_schemas_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_name_key UNIQUE (name);


--
-- Name: remote_schemas remote_schemas_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_pkey PRIMARY KEY (id);


--
-- Name: joey_user joey_user_auth_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joey_user
    ADD CONSTRAINT joey_user_auth_token_key UNIQUE (auth_token);


--
-- Name: joey_user joey_user_h_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joey_user
    ADD CONSTRAINT joey_user_h_id_key UNIQUE (h_id);


--
-- Name: joey_user joey_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joey_user
    ADD CONSTRAINT joey_user_id_key UNIQUE (id);


--
-- Name: joey_user joey_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joey_user
    ADD CONSTRAINT joey_user_pkey PRIMARY KEY (id, h_id);


--
-- Name: startup_details startup_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_details
    ADD CONSTRAINT startup_details_pkey PRIMARY KEY (id);


--
-- Name: startup_details startup_details_startup_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_details
    ADD CONSTRAINT startup_details_startup_name_key UNIQUE (startup_name);


--
-- Name: startup_details startup_details_user_h_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_details
    ADD CONSTRAINT startup_details_user_h_id_key UNIQUE (user_h_id);


--
-- Name: startup_post startup_post_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_post
    ADD CONSTRAINT startup_post_pkey PRIMARY KEY (id);


--
-- Name: student_details student_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_details
    ADD CONSTRAINT student_details_pkey PRIMARY KEY (id);


--
-- Name: student_details student_details_user_hid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_details
    ADD CONSTRAINT student_details_user_hid_key UNIQUE (user_hid);


--
-- Name: user_detail user_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_pkey PRIMARY KEY (id);


--
-- Name: user_detail user_detail_user_h_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_user_h_id_key UNIQUE (user_h_id);


--
-- Name: event_invocation_logs_event_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);


--
-- Name: event_log_trigger_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX event_log_trigger_id_idx ON hdb_catalog.event_log USING btree (trigger_id);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_table hdb_table_oid_check; Type: TRIGGER; Schema: hdb_catalog; Owner: postgres
--

CREATE TRIGGER hdb_table_oid_check BEFORE INSERT OR UPDATE ON hdb_catalog.hdb_table FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_table_oid_check();


--
-- Name: google__insert__public__joey_user google__insert__public__joey_user; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER google__insert__public__joey_user INSTEAD OF INSERT ON hdb_views.google__insert__public__joey_user FOR EACH ROW EXECUTE PROCEDURE hdb_views.google__insert__public__joey_user();


--
-- Name: user__insert__public__startup_details user__insert__public__startup_details; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER user__insert__public__startup_details INSTEAD OF INSERT ON hdb_views.user__insert__public__startup_details FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__startup_details();


--
-- Name: user__insert__public__startup_post user__insert__public__startup_post; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER user__insert__public__startup_post INSTEAD OF INSERT ON hdb_views.user__insert__public__startup_post FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__startup_post();


--
-- Name: user__insert__public__student_details user__insert__public__student_details; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER user__insert__public__student_details INSTEAD OF INSERT ON hdb_views.user__insert__public__student_details FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__student_details();


--
-- Name: user__insert__public__user_detail user__insert__public__user_detail; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER user__insert__public__user_detail INSTEAD OF INSERT ON hdb_views.user__insert__public__user_detail FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__user_detail();


--
-- Name: event_invocation_logs event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);


--
-- Name: hdb_permission hdb_permission_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name);


--
-- Name: hdb_relationship hdb_relationship_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name);


--
-- Name: startup_details startup_details_user_h_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_details
    ADD CONSTRAINT startup_details_user_h_id_fkey FOREIGN KEY (user_h_id) REFERENCES public.joey_user(h_id);


--
-- Name: startup_post startup_post_startup_details_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_post
    ADD CONSTRAINT startup_post_startup_details_id_fkey FOREIGN KEY (startup_details_id) REFERENCES public.startup_details(id);


--
-- Name: startup_post startup_post_user_hid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_post
    ADD CONSTRAINT startup_post_user_hid_fkey FOREIGN KEY (user_hid) REFERENCES public.joey_user(h_id);


--
-- Name: student_details student_details_user_hid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_details
    ADD CONSTRAINT student_details_user_hid_fkey FOREIGN KEY (user_hid) REFERENCES public.joey_user(h_id);


--
-- Name: user_detail user_detail_startup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_startup_id_fkey FOREIGN KEY (startup_id) REFERENCES public.startup_details(id);


--
-- Name: user_detail user_detail_user_h_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_user_h_id_fkey FOREIGN KEY (user_h_id) REFERENCES public.joey_user(h_id);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

