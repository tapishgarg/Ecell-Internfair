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
-- Name: user__insert__public__internship_apply_table(); Type: FUNCTION; Schema: hdb_views; Owner: postgres
--

CREATE FUNCTION hdb_views.user__insert__public__internship_apply_table() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."internship_apply_table"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ((EXISTS  (SELECT  1  FROM "public"."student_details" AS "_be_0_public_student_details" WHERE (((("_be_0_public_student_details"."id") = (NEW."student_id")) AND ('true')) AND ((EXISTS  (SELECT  1  FROM "public"."joey_user" AS "_be_1_public_joey_user" WHERE (((("_be_1_public_joey_user"."h_id") = ("_be_0_public_student_details"."user_hid")) AND ('true')) AND ((((("_be_1_public_joey_user"."auth_token") = (((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text)) OR ((("_be_1_public_joey_user"."auth_token") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-auth-token'))::text) IS NULL))) AND ('true')) AND ('true')))     )) AND ('true')))     )) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."internship_apply_table" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."internship_apply_table" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."internship_apply_table" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."internship_apply_table" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
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


ALTER FUNCTION hdb_views.user__insert__public__internship_apply_table() OWNER TO postgres;

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
-- Name: internship_apply_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.internship_apply_table (
    id integer NOT NULL,
    student_id integer NOT NULL,
    internship_id integer NOT NULL,
    resume_url text NOT NULL,
    status text DEFAULT 'Pending'::text NOT NULL
);


ALTER TABLE public.internship_apply_table OWNER TO postgres;

--
-- Name: user__insert__public__internship_apply_table; Type: VIEW; Schema: hdb_views; Owner: postgres
--

CREATE VIEW hdb_views.user__insert__public__internship_apply_table AS
 SELECT internship_apply_table.id,
    internship_apply_table.student_id,
    internship_apply_table.internship_id,
    internship_apply_table.resume_url,
    internship_apply_table.status
   FROM public.internship_apply_table;


ALTER TABLE hdb_views.user__insert__public__internship_apply_table OWNER TO postgres;

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
    status text DEFAULT 'verifying'::text NOT NULL,
    rev_rank integer DEFAULT 1 NOT NULL
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
    startup_post.status,
    startup_post.rev_rank
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
    is_paid boolean DEFAULT false NOT NULL,
    payment_link text,
    payment_id text,
    user_hid text NOT NULL,
    payment_request_id text,
    resume_url text
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
    student_details.is_paid,
    student_details.payment_link,
    student_details.payment_id,
    student_details.user_hid,
    student_details.payment_request_id,
    student_details.resume_url
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
-- Name: internship_apply_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.internship_apply_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internship_apply_table_id_seq OWNER TO postgres;

--
-- Name: internship_apply_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.internship_apply_table_id_seq OWNED BY public.internship_apply_table.id;


--
-- Name: internship_bookmark_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.internship_bookmark_table (
    id integer NOT NULL,
    student_id integer NOT NULL,
    internship_id integer NOT NULL
);


ALTER TABLE public.internship_bookmark_table OWNER TO postgres;

--
-- Name: internship_bookmark_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.internship_bookmark_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internship_bookmark_table_id_seq OWNER TO postgres;

--
-- Name: internship_bookmark_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.internship_bookmark_table_id_seq OWNED BY public.internship_bookmark_table.id;


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
-- Name: user__insert__public__internship_apply_table id; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__internship_apply_table ALTER COLUMN id SET DEFAULT nextval('public.internship_apply_table_id_seq'::regclass);


--
-- Name: user__insert__public__internship_apply_table status; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__internship_apply_table ALTER COLUMN status SET DEFAULT 'Pending'::text;


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
-- Name: user__insert__public__startup_post rev_rank; Type: DEFAULT; Schema: hdb_views; Owner: postgres
--

ALTER TABLE ONLY hdb_views.user__insert__public__startup_post ALTER COLUMN rev_rank SET DEFAULT 1;


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
-- Name: internship_apply_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_apply_table ALTER COLUMN id SET DEFAULT nextval('public.internship_apply_table_id_seq'::regclass);


--
-- Name: internship_bookmark_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_bookmark_table ALTER COLUMN id SET DEFAULT nextval('public.internship_bookmark_table_id_seq'::regclass);


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
public	startup_post	user	update	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"]}	\N	f
public	startup_post	user	delete	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}}	\N	f
public	user_detail	user	insert	{"set": {}, "check": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "image_url", "name", "startup_id", "startup_name", "user_h_id"]}	\N	f
public	user_detail	user	select	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "id", "image_url", "name", "startup_id", "startup_name", "user_h_id"], "allow_aggregations": true}	\N	f
public	user_detail	user	update	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["email", "image_url", "name", "startup_id", "startup_name", "user_h_id"]}	\N	f
public	user_detail	user	delete	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}	\N	f
public	startup_details	user	insert	{"set": {}, "check": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["about", "contact_number", "email_id", "is_verified", "logo_url", "poc_name", "startup_name", "user_h_id", "website"]}	\N	f
public	startup_details	user	update	{"set": {}, "filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["about", "contact_number", "email_id", "is_verified", "logo_url", "poc_name", "startup_name", "user_h_id", "website"]}	\N	f
public	startup_details	user	select	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["id", "startup_name", "about", "website", "logo_url", "user_h_id", "is_verified", "poc_name", "contact_number", "email_id"], "allow_aggregations": true}	\N	f
public	internship_apply_table	user	insert	{"set": {}, "check": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["internship_id", "resume_url", "status", "student_id"]}	\N	f
public	internship_apply_table	user	select	{"filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["id", "internship_id", "resume_url", "status", "student_id"], "allow_aggregations": true}	\N	f
public	student_details	anonymous	select	{"filter": {}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "id", "is_paid", "payment_id", "payment_link", "payment_request_id", "roll_num"], "allow_aggregations": true}	\N	f
public	internship_apply_table	user	update	{"set": {}, "filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["internship_id", "resume_url", "status", "student_id"]}	\N	f
public	startup_post	user	select	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "rev_rank", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"], "allow_aggregations": true}	\N	f
public	student_details	user	insert	{"set": {}, "check": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "payment_request_id", "resume_url", "roll_num", "user_hid"]}	\N	f
public	internship_apply_table	user	delete	{"filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}}	\N	f
public	startup_post	anonymous	select	{"filter": {}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "rev_rank", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance"], "allow_aggregations": true}	\N	f
public	startup_details	anonymous	select	{"filter": {}, "columns": ["about", "contact_number", "email_id", "id", "is_verified", "logo_url", "poc_name", "startup_name", "website"], "allow_aggregations": true}	\N	f
public	internship_apply_table	anonymous	select	{"filter": {}, "columns": ["id", "student_id", "internship_id", "resume_url", "status"], "allow_aggregations": true}	\N	f
public	student_details	user	select	{"filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "id", "is_paid", "payment_id", "payment_link", "payment_request_id", "resume_url", "roll_num", "user_hid"], "allow_aggregations": true}	\N	f
public	student_details	user	update	{"set": {}, "filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "payment_request_id", "resume_url", "roll_num", "user_hid"]}	\N	f
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
public	internship_apply_table	startupPostByinternshipId	object	{"foreign_key_constraint_on": "internship_id"}	\N	f
public	internship_apply_table	studentDetailsBystudentId	object	{"foreign_key_constraint_on": "student_id"}	\N	f
public	startup_post	internshipApplyTablesByinternshipId	array	{"foreign_key_constraint_on": {"table": "internship_apply_table", "column": "internship_id"}}	\N	f
public	student_details	internshipApplyTablesBystudentId	array	{"foreign_key_constraint_on": {"table": "internship_apply_table", "column": "student_id"}}	\N	f
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
public	internship_apply_table	f
public	internship_bookmark_table	f
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
-- Data for Name: internship_apply_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.internship_apply_table (id, student_id, internship_id, resume_url, status) FROM stdin;
38	67	118	https://res.cloudinary.com/si-portal/image/upload/v1551006407/Resumes/gsjbq1yxeohqw3l7ir5t.pdf	Pending
39	67	101	https://res.cloudinary.com/si-portal/image/upload/v1551006613/Resumes/sdp64rj57l24gsbcrl17.pdf	Pending
40	67	119	https://res.cloudinary.com/si-portal/image/upload/v1551006668/Resumes/gygeo10mie1j2maqpvoz.pdf	Pending
46	175	72	https://res.cloudinary.com/si-portal/image/upload/v1551010623/Resumes/wdly3clwe6oskvrlyjkp.pdf	Pending
47	175	81	https://res.cloudinary.com/si-portal/image/upload/v1551011183/Resumes/orxklqzgpjwy004iizd9.pdf	Pending
49	203	145	https://res.cloudinary.com/si-portal/image/upload/v1551013247/Resumes/m118riuigxqo8go6mzr9.pdf	Pending
50	203	81	https://res.cloudinary.com/si-portal/image/upload/v1551013312/Resumes/fawggtrjhxcjg0ve8w9h.pdf	Pending
51	203	107	https://res.cloudinary.com/si-portal/image/upload/v1551013715/Resumes/magonjtea6x7iq8u4w1s.pdf	Pending
52	203	91	https://res.cloudinary.com/si-portal/image/upload/v1551013843/Resumes/qwnjgxl38p1qgh9nvgyc.pdf	Pending
53	203	136	https://res.cloudinary.com/si-portal/image/upload/v1551013890/Resumes/dfehl3ytzo9kkstc8hiw.pdf	Pending
54	354	144	https://res.cloudinary.com/si-portal/image/upload/v1551015783/Resumes/wfxjw0joc5ytd9dlpkyx.pdf	Pending
55	354	145	https://res.cloudinary.com/si-portal/image/upload/v1551015844/Resumes/rj9lweshr8z1g8bpjhsc.pdf	Pending
56	354	107	https://res.cloudinary.com/si-portal/image/upload/v1551016056/Resumes/x7rvhcnk8zgskzjdlwk0.pdf	Pending
57	354	141	https://res.cloudinary.com/si-portal/image/upload/v1551016201/Resumes/gkgt3boxdhq9qu8p276k.pdf	Pending
58	354	91	https://res.cloudinary.com/si-portal/image/upload/v1551016419/Resumes/fiqaoumojoguixx1aauf.pdf	Pending
59	122	83	https://res.cloudinary.com/si-portal/image/upload/v1551018360/Resumes/xwqocireup1fl9deeovg.pdf	Pending
60	122	82	https://res.cloudinary.com/si-portal/image/upload/v1551018455/Resumes/kqq3u6gpbfrn6eoigeca.pdf	Pending
61	378	79	https://res.cloudinary.com/si-portal/image/upload/v1551018675/Resumes/fbtvxvbynfdkh08mvdab.pdf	Pending
62	378	78	https://res.cloudinary.com/si-portal/image/upload/v1551018811/Resumes/yg7dwycpvj6ysgmmwtzl.pdf	Pending
63	378	104	https://res.cloudinary.com/si-portal/image/upload/v1551018911/Resumes/ri8bpqbkomiidkzps6i9.pdf	Pending
64	435	119	https://res.cloudinary.com/si-portal/image/upload/v1551021954/Resumes/hstgspunjmwdhgh7qtca.pdf	Pending
65	435	145	https://res.cloudinary.com/si-portal/image/upload/v1551022073/Resumes/mlsp7ris0yndguvtshto.pdf	Pending
66	435	91	https://res.cloudinary.com/si-portal/image/upload/v1551022410/Resumes/lhnpeuxtl0wppv7r91ye.pdf	Pending
67	435	136	https://res.cloudinary.com/si-portal/image/upload/v1551022519/Resumes/gl4yns9q2jgbxn2s5u2f.pdf	Pending
69	53	78	https://res.cloudinary.com/si-portal/image/upload/v1551028870/Resumes/y7xwv2mgwx4kd9twbtli.pdf	Pending
70	53	120	https://res.cloudinary.com/si-portal/image/upload/v1551029864/Resumes/vkkvxkfoulcttkg09ghb.pdf	Pending
71	53	79	https://res.cloudinary.com/si-portal/image/upload/v1551030170/Resumes/bzd5pvlrz3fykonxt1er.pdf	Pending
72	53	104	https://res.cloudinary.com/si-portal/image/upload/v1551030281/Resumes/ahxv1siotukn3esd0hdc.pdf	Pending
73	53	139	https://res.cloudinary.com/si-portal/image/upload/v1551030393/Resumes/i9diqi4ypzt1i8yyn4aj.pdf	Pending
74	579	149	https://res.cloudinary.com/si-portal/image/upload/v1551070860/Resumes/qjivc6eaofoyp4byqkb6.pdf	Pending
75	579	119	https://res.cloudinary.com/si-portal/image/upload/v1551071298/Resumes/xb8bgn59mdtel4vvbm9f.pdf	Pending
76	579	79	https://res.cloudinary.com/si-portal/image/upload/v1551071708/Resumes/k2wnaqxbxopkro5tcajo.pdf	Pending
77	579	81	https://res.cloudinary.com/si-portal/image/upload/v1551071768/Resumes/pirjvrr03rdw6gdz65mf.pdf	Pending
78	579	82	https://res.cloudinary.com/si-portal/image/upload/v1551071819/Resumes/yvkj7ucjpyifvhz86bbq.pdf	Pending
82	97	140	https://res.cloudinary.com/si-portal/image/upload/v1551092428/Resumes/wzmrzxwmbqjqcfidadom.pdf	Pending
83	97	83	https://res.cloudinary.com/si-portal/image/upload/v1551092833/Resumes/zqte9o1zqsy7ztvdgctw.pdf	Pending
84	97	149	https://res.cloudinary.com/si-portal/image/upload/v1551093218/Resumes/jlwmauu2wx5csb0liexl.pdf	Pending
85	415	145	https://res.cloudinary.com/si-portal/image/upload/v1551094657/Resumes/d5710thzdk5tkkjaxi3d.pdf	Pending
86	485	78	https://res.cloudinary.com/si-portal/image/upload/v1551094745/Resumes/j73ux4qzpy1vrly2izx4.pdf	Pending
87	485	143	https://res.cloudinary.com/si-portal/image/upload/v1551094794/Resumes/opqdmccsyji4lm0keezl.pdf	Pending
88	485	77	https://res.cloudinary.com/si-portal/image/upload/v1551094943/Resumes/wxldyadpvcnizcvtewdk.pdf	Pending
89	415	78	https://res.cloudinary.com/si-portal/image/upload/v1551095221/Resumes/kr619doh5sqhzs7ueg6k.pdf	Pending
90	514	82	https://res.cloudinary.com/si-portal/image/upload/v1551105425/Resumes/xrntbrrftbxbqhwe3q7q.pdf	Pending
91	514	125	https://res.cloudinary.com/si-portal/image/upload/v1551105762/Resumes/skhorx1qgwh3evhsbux0.pdf	Pending
92	634	83	https://res.cloudinary.com/si-portal/image/upload/v1551109270/Resumes/auxgnp59homplqabe9pw.pdf	Pending
93	634	140	https://res.cloudinary.com/si-portal/image/upload/v1551109477/Resumes/d6kbmhuyezyeew2xa11p.pdf	Pending
94	634	149	https://res.cloudinary.com/si-portal/image/upload/v1551109556/Resumes/dvh90umbdr0puetuge3o.pdf	Pending
95	110	112	https://res.cloudinary.com/si-portal/image/upload/v1551110300/Resumes/h1gs14i09wadkamufpmv.pdf	Pending
96	110	70	https://res.cloudinary.com/si-portal/image/upload/v1551110360/Resumes/wstfbscjjvnrtdo1aq8f.pdf	Pending
97	110	101	https://res.cloudinary.com/si-portal/image/upload/v1551110397/Resumes/omtgjissjrmsbfmbo2m9.pdf	Pending
98	110	76	https://res.cloudinary.com/si-portal/image/upload/v1551110424/Resumes/of95yorki806hb8w2cgy.pdf	Pending
99	110	149	https://res.cloudinary.com/si-portal/image/upload/v1551110459/Resumes/rovwvugmijjgqhhasjf0.pdf	Pending
100	496	136	https://res.cloudinary.com/si-portal/image/upload/v1551114057/Resumes/sucrwrjdbkn4qx8fehqf.pdf	Pending
101	496	145	https://res.cloudinary.com/si-portal/image/upload/v1551114756/Resumes/exq80acdotxwirxot7fr.pdf	Pending
102	496	104	https://res.cloudinary.com/si-portal/image/upload/v1551114821/Resumes/yb1dwyz0uy5lmfyg9zk5.pdf	Pending
103	496	120	https://res.cloudinary.com/si-portal/image/upload/v1551114872/Resumes/vhmyw5zloktkx2w1ajhy.pdf	Pending
104	496	79	https://res.cloudinary.com/si-portal/image/upload/v1551114942/Resumes/ggtmf1csmxqvdnlklhxk.pdf	Pending
109	665	149	https://res.cloudinary.com/si-portal/image/upload/v1551121222/Resumes/udcertmck4jh8qm7qfod.pdf	Pending
111	665	77	https://res.cloudinary.com/si-portal/image/upload/v1551121262/Resumes/qmqisauac24uljvu9clk.pdf	Pending
112	665	82	https://res.cloudinary.com/si-portal/image/upload/v1551121294/Resumes/sdmk9nzhoyobpq1cw5nl.pdf	Pending
114	665	125	https://res.cloudinary.com/si-portal/image/upload/v1551121359/Resumes/ekoyzkscfdtuicmw6vkc.pdf	Pending
119	621	123	https://res.cloudinary.com/si-portal/image/upload/v1551122048/Resumes/iufudtxtxzoklfokgxyh.pdf	Pending
120	621	79	https://res.cloudinary.com/si-portal/image/upload/v1551122198/Resumes/n2youv0foql193wzanuq.pdf	Pending
121	621	107	https://res.cloudinary.com/si-portal/image/upload/v1551122281/Resumes/q4p3oxo287f14xs8jlnf.pdf	Pending
122	621	120	https://res.cloudinary.com/si-portal/image/upload/v1551122460/Resumes/ehqhjuss6juvgl3yatgn.pdf	Pending
123	621	142	https://res.cloudinary.com/si-portal/image/upload/v1551122842/Resumes/hqdcgvwipumha4ic6pml.pdf	Pending
124	435	107	https://res.cloudinary.com/si-portal/image/upload/v1551146336/Resumes/ik0g5imqwhki7eigqcub.pdf	Pending
125	351	78	https://res.cloudinary.com/si-portal/image/upload/v1551162466/Resumes/jm56y1tmvbzc0u8bbvte.pdf	Pending
126	351	120	https://res.cloudinary.com/si-portal/image/upload/v1551162484/Resumes/jbhizdfc2hq3kdhbt0wd.pdf	Pending
127	351	79	https://res.cloudinary.com/si-portal/image/upload/v1551162504/Resumes/b88ack3lmkwvkjfpe2gp.pdf	Pending
128	351	91	https://res.cloudinary.com/si-portal/image/upload/v1551162530/Resumes/dontdzp1u2hios99sjoc.pdf	Pending
129	351	136	https://res.cloudinary.com/si-portal/image/upload/v1551162557/Resumes/dwmc2jsbrhbbtqgscefb.pdf	Pending
130	405	139	https://res.cloudinary.com/si-portal/image/upload/v1551175233/Resumes/svfnqieacry7r8jy7jbo.pdf	Pending
\.


--
-- Data for Name: internship_bookmark_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.internship_bookmark_table (id, student_id, internship_id) FROM stdin;
\.


--
-- Data for Name: joey_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.joey_user (id, h_id, auth_token, role) FROM stdin;
2472	116000450446927027712	76dfc8a71dbf3b01ee7da3f778cf525a96045765	user
1820	111030578426826726626	8ef9de03f9267a288420f428ef86ac41b86a4ca4	user
25763	100876230019394013623	6dfb9ed76c1eb7c3dc4e81db9f6efdde59b7f789	user
1594	106407488023143571708	8185d1cbb03b3950f9bf471020ab54676fbc5d1a	user
2188	103158308128328545694	a053dc8af7f7a83381977cc97df1974a61f2cd65	user
2060	105202096528458362102	17db57b839e23c42aa28b05c98ef90f36bbb08f6	user
1547	103546078731885007120	86254e1a7a4d18528d06f540a0f80bb111bd26d3	user
1643	102476915533780948091	152e8b52b339aaf006d32a11c584b9aaa656c0b3	user
1786	116519274255305915920	db66121dba3e363dee4edd22e6e52156def23153	user
1922	101189951357074482183	5b9fb8de42927a8895827b0c401780e76724ee6e	user
2031	107429974676687296166	de7ee0f0246bbfdb3deff23234ea8e13c30ab939	user
1590	102584910929681137125	588e6ae6294fc222a7988fb2dcba0741aa5d6a40	user
1652	100898145044469393733	8d38a727f5f85b2688a841c4849bb2d2f648f5b1	user
19882	107063297132920862498	6b104432127cc859dd8155f673b337ca95ba64c9	user
1780	113564221505157815723	6f727eea4093d36a8e8b0432e88db612996f744b	user
1448	116445166814243602711	b29ab84c615454cbb09c1f267b3cd7b9d13ba428	user
1640	100916162979211575903	f9765bdfd4dd4cd341e6550b66f0146882a747a2	user
2145	109683991238473547277	5029b8c090c2d07aa47c598a1e1defa5ce9fb28e	user
1754	115802938042318956916	b674633c5b63389b71008c81c5dda817a68c15ec	user
1969	110274344916933599324	015872ef1201e021d42820541af13c84a1291c29	user
1403	113824673222077196247	817987f0fc2d8a1d371e4c9ee96380292ec93752	user
1822	114503787094540282981	97161e120d9729da2592fa2271e128248ca2bbdb	user
2198	101396729595279031815	65e27b093759182a8ae7735a13e027eb8b3959f3	user
1513	106774401436596091547	068ebd2ad761a6ff502ac10dd9aba7d82d9076e4	user
2158	101107640131204357570	02d2e086ca1811e1565a0e9bf3f71a9ef8299fdb	user
1794	117013339697530495306	8faf2b46f743a04ac25e4136b63cd60105dfd036	user
1288	116040530755962342318	ee4db3e99e05154bf3a6d7983f2c294825c2303b	user
2196	106289280886691331250	dd98b75301c44b2e7076b9c439660bac0550b473	user
1625	101818747050100224079	b5d937df3481ea2f2c12f5476131e95a21fdc9d0	user
1648	104379184185174428302	0725af2caff5491e7d90ab63f530c2e3c918604e	user
1324	110011265617786100962	86db390561f62b33023706ecd34bbdf3a1a08354	user
1563	103563223572046648148	6b7ff083f5a86eb5b09f7fc8d0abfe7e35e31b83	user
2379	103319782156851133364	b8480f5ccb088025e3ea846d8de32f8a84ebca18	user
1548	105373738578694994605	835f1cba8da510fdafc25b564d3f6837a5f5622c	user
1549	116836169810745668980	9faa8273ca4cf97d7cd8c7471c0a2dc602108541	user
1899	115375476385745576962	619b72a7a02632caed6698bcf3a070a6fe54f61f	user
4470	103752593630791624652	1cddc4e69a327ba5d10992a7480f3bbd526ebcfd	user
1807	114749538391689307031	043d173597aa46572a679acfb25133467d7e7406	user
2203	115342870212009600095	7ffe0bc79bb86abde7a93d2bf5d4ce2017fc1753	user
1753	108825759819157028428	1e42f3d0f20ccc95830ee7c6e771f2e8006ad4d9	user
2201	111320166102807820736	2ac6875fdd5900a06bdb0ccf25b5ee8b9af54efa	user
2097	104821578026829852225	4f7b44110276758ae2ebd1f438efcff74dbbffa3	user
1894	107813869731075135750	393246bd9cbeb137680eeb4aa53f02e05461078c	user
2229	101056800285643890923	3b0e3d73ec81d33dd1811339d4d7550ae358bef4	user
2221	111687598935683751002	8e76b0ff585c630f7af0312dce478711d235d621	user
23952	112959020768381661176	364a1e8bfd23af02fc2c3e858745c6b78eb61294	user
1565	107530024622485449869	e0056b98a100c1bf4b0da9a11ab70547e9570ca6	user
2230	107564555087017130990	e0659b971ade013f39c9eba4dea03ed8387aac1f	user
2231	110959428559525986265	013c71a4bb21ba77e63007e72deb5873b47d5639	user
1659	110447218383396106962	8eb96a0bd3c2ebb05ed79b7e2538a74dca2d4c84	user
4037	106783215449844945185	60269ccb9daf57d2a40791c8d73cfc2556817673	user
2238	101907162894505620447	f1d16e7a32c0f78249bd109b40eb1d47c84bdc1f	user
1622	110505594872527456493	f4d04a81792a2a4263751b90bb44179c6fd5f7ba	user
2106	103304235098083374178	de3a375f0b13294a4765373e81fa62cb59ee7c2f	user
2225	103782240804789880108	0ccfd1870f2dcd00a82ff42c828f68a7cda37e68	user
1582	109140945875383774158	a85a96a3abbff28e1438867c27b2466bcc34ae26	user
2232	106711601084471424539	ebc6cda92a9ecd865775634e88b12de97c4098eb	user
2233	115023583903933855531	42331377940b3082df745c09bf208637e8e36b5e	user
1339	106123538173898449055	2b607913fbc1cf5e394b595b4062f281451a57d8	user
2235	109234805044650346236	1410254eccee31be692a6cd2f1e57ec884829d09	user
2236	113903073200127800235	4bd22382b0ac95fc82955c68685ab6165872568f	user
2228	109266082501365237941	7791f39ccb7335fb130954320274ee2ace6460b7	user
2241	108896450923947891853	891762c2c78a957b8b150483cd5a0eb4dc16a8e6	user
1862	117894875203741245699	d45ac8ffd77dfbef54abc1e4fd333d7fc7a8b618	user
1572	104298758991766668035	bac31d05c357128769cd74bace565bb7dd3332cd	user
1787	111133250649424423782	85de4ae5db4b7b29c7e6801e490a417805f07ec1	user
2248	102641646898857644341	94fdff9e22079b9c4d1a8982aa9920df19e979b8	user
1928	109249031263145344654	705c6ca3bd9161bc02b86ef7fc528823b88085d9	user
2253	111287724851133369161	0cb6828500b4bfa07d08e6c8e5c93d858d358e5f	user
2255	107831550891832625063	91eac38ff9d5a46c1c3e590d01702a3ce54a7f05	user
2257	110296223890564310627	9f19a3702f2e69194bea3638cf90744742259df4	user
2261	106840195352712555805	8d1068acac082459f613681a77eacd47f8847fc5	user
2266	103413867609203995396	751a61f782b86b482a25ba49b2632eee34d6a875	user
2268	115583909410869064703	eb9f33c15c436031d0280e688db5ed6ed1e35a7e	user
2026	103686313929651160614	9adabd0e25caca3fd2d328e9cf84b75e34862394	user
2211	111049789719558186993	9b47fdacfbf61bc49ffc35b038456a9e92f5a544	user
1834	101326090802695787002	deb08f6e9ed75727ccb15747acc3639a7dc704b7	user
4886	110088160541028725569	63d17d33140c084f902801df314965d813556b52	user
2279	113375788251733149094	c206c99d107710492be2d7fd4b054649eb1b9c89	user
22015	103796546597774896206	5570124ee5974c4802ff9aacdbf498b4a9e5a61d	user
2291	115020366769667334416	4a784c0ed2f3ed00772b01509cf16f215c6f2524	user
2430	105500817840272313799	ad7475300889c0b3d99b92b647fbe003ea912a4b	user
5094	108716062842174923272	8ee03f548cf74539fe07f6b82fcfdfea489da457	user
4670	113501286160076496682	d88461b4461641a030d971d102cd10b6fdd0c93c	user
2312	113035858086387927034	eeda45c16bdabc33ef1ce30c7c4697e8b9a4c927	user
2317	114537148790063843816	9004b588d5db5841548519756d816fc1bf87e511	user
2318	103083422834575225895	01a795fbfbcbeb30a1e0ceb42a3d8767f0ee3562	user
1308	103441912139943416551	60125c68b277a48b45244615509e44101c79dab5	user
2528	114839727532236749919	1af22599e2f457b15f4219650de79209d40a5bfd	user
31538	100888486472323143652	ddae24d871b11ef04d90194c68ee409bb3507878	user
3149	105135735319080728525	0ddcf1693a4578b81ad8cde835396a7b67306a1b	user
4858	102312700975952431360	a76858ac296deb7dac17b80bc87c3d9f11a24999	user
4875	101142874371716107680	82d9bdd1a2f54b82a8691cd873a72950a995e0c0	user
4897	103517082880442482622	72949b444a77a99f4e283e7557b2995a5061ddf8	user
2310	116687833430096689153	2828b7ca8465a1b0d25cf4b0336e770ebb62b119	user
33005	107945827618686612359	d62c0848e563dca455a410a291a48eb6ea03d88b	user
2391	106907442348505117600	8c331c63feeaa44415f6157d07fe6d662c99b86f	user
4780	105648143853551093911	f9d4f36e7dd74cb181d5ed06a41d30a95ba9f77a	user
4881	106151943570612705662	d2ae25da2aebf9c2ab42c76ecf76fd37752613f4	user
2541	117537405273454723771	f2d659a419b759c84328872ae3ad95c2eeea4c32	user
2531	105791111294087052325	61990eab933551838df908e7575a467d7db40b9d	user
2298	108454550000095213572	10bd4b1f7339499e84659692af0b59b669bc3167	user
2566	107266261851940045387	90761b8116211735abd04c33af5980e473e5f2aa	user
2395	110988755828086628184	38d045da5fef112c1835e34ac68c2c5526b33d7c	user
28222	114899068497843267952	dcbb2db16ec74160cac750f83336d3106ee0b85c	user
4787	116786289933147386527	b2652a629323008bdd3befb19a12c5b152535a0e	user
2568	117045864410082434432	3e27eecc224c794e393231ce46331026fc1c75db	user
13095	103825959457084390467	a34dbc1c9f585a60775f054a45356d15fc1bc3b3	user
5184	100046381709706919563	2557722f8aa856b3ee72c7e157b7c6c5937c94c8	user
4937	117068008597284134843	1a63d3ce1d9ce34f14c3bfa8f40b24732474d334	user
23997	109862116486377951732	413017602642bcb40c9b14964ec86cb6fe16cfe6	user
2442	105528835513377079359	afbdbccfb47ea533b54b67de987be46e438b46af	user
25951	100265483523057320076	6e9840b00e8d328c2d72ffdefcae004874179704	user
4061	112396581591786005083	1c8a74a000112a59e2e01e1e7eec73683f0a0bc5	user
4874	116739830006062100225	2418b77f9ed304be15b147a4edcf36892958782f	user
2533	117306459721549242620	453a51d1d765337f6f83b489534d51ffb0188b4c	user
5081	116987835442491396459	5f446348404a547afed0ecae964e2ab606d553ae	user
5010	108046082470898711935	2c98c8d5b9a5fb29e9b5b6263f90f583939562e3	user
1415	118208723166374240159	d6ebaf44b04a1fc6b55fadfeff663487cca24b6b	user
2473	112150566284259074738	4946515a09dac64ba3cc977b5720211a3fd5656d	user
2508	114268811780135391116	6d9370a531046537b914e809d43861b88eec0e29	user
4178	112955715421977386894	0cc917c0b235865c4c4d97d9de72622652ca544e	user
2576	103765838603107363304	bb83c6f518ba4c9ee1e3afe8ce9463a80f9c923a	user
8680	101682012856295676880	cc4130b3e29b2e5f8cf5630206ed884f042ac738	user
5018	101452552670608521565	4628003399aa72a2b5d5ae78a1c92a6941d63ecf	user
2583	103007413487745509743	037f71dee0257b07840e6980dab8b4d20f790477	user
5005	110086250388526798686	b035295da1a35ff47a0d2364115d939420fcccac	user
4873	113046604995058376278	d88eddb319fe30a83426da4d977e80aa832bce74	user
2412	105502414900621283479	1fd4ac0b16ba94f4aa0b30a8e7add9cd7be7f710	user
4889	114832114521563248786	58d68b10de4cdcf65c3ba34947abfcb84182e33a	user
4962	113814269201509832881	5c2f6b2a76be179fc92444e5e9d2356121ecb202	user
4867	106346546956435892842	e4f0c5cf3888bad485f7449eaec9f5c1e55725d9	user
4935	117005101380398480170	a489c9bfcb6103e37bbf727769ff5c9c8a87dce4	user
4936	112693133093914151701	70b2009de3ef87edb8c8333bbd30cc18fcb58637	user
4896	100180464561448951684	cf68552eb748d643153cfda53a41d4e2e9f6b0b8	user
4930	102052775561051041362	a916fa71e04c605004407d29929a15269a6b4541	user
2129	104089503500603657430	6610b54571e65cebf84d441fff7044eae4ee90c7	user
4965	102139067499961218783	b4793e7e609bf22e0acda0cf5560533d1457bd66	user
4853	101807814707039385860	50bb38e1ba1e8978195c0e470b0440c4b6dc34ac	user
4880	105718181361808782027	9db41464bc6b5356647ad12ca741656497d342e6	user
1314	110540228254791393418	3dab0b10c2171ed6fea88d5d431b77fed8f9ffb5	user
5051	109694605773547105071	d9be11e23ee6287e0691bedf2bef16f6083517ad	user
5052	104402072932888164460	43842112b617d6dcf8c66e1cacfb708fee97e2d8	user
5013	101052355478693521918	f238952ed6a6e329e0f794bd584ed2824408c728	user
5097	116204895236238903886	0dce44d09a18a6a094289d0d1facd073606dbfda	user
5120	104171369330644075313	f037fe3509054c1ba3eac04b83d1a6044eb8bace	user
5155	113583843316589152036	a3737312077c6b3bc41d21d4817f471e3956e6f2	user
5136	116474837895993246041	99c59cbcbfd0ea52071a4d41a235b4c6a2c0c1bd	user
4927	111558464273085465448	a800cd783c27ba90a7a93c3041551f1e0ec38143	user
5164	105392709235674293466	f9d014b7b25ab15bb8051dde6517c9292b8c0e2e	user
5215	117732606660029053405	c3b34b42a6c5ae7b6bd127af33f0473f2d40e932	user
5233	104341823850477467850	629c6fcd11fea212a0615869f907dba7867da923	user
5230	100174145732475175347	754ff93c88f53bf824562ec8c4dab99c762348b4	user
2322	114818886750636854304	09de2a680d25783fc8c7b6a9ba562e78c7607970	user
6392	100006462132328751764	45d96eeb2f92c8c4808c815e6b8c95cd6962acae	user
5300	101285149807471176908	9f9ee075cfac6f2b1cd5f5eec18ced96fa9b4a33	user
5254	101475449072728420854	9b55c3c4dab7edbad79510adf5fb0baa5dd82b25	user
6673	115248078929890303214	1eb44b0830f5f88960dd4014d43b6b118e3005e8	user
5425	101887063519379114033	ba809739f63960e0ec36c3218594f9d8927019b6	user
12361	115566315786288546293	4ada15708ba01947383e24020723f2c62e7b205f	user
6953	101180110198873131231	6a33dd222616f8ce86e1060ac9507abe3d20a3de	user
6421	101491417144470081112	faf03428ff8c2c11cdbbb731b008bf873b8b1043	user
6000	102748409040120330310	a2e439ecc0c528753d3a551a3b0ee8afc8844a8c	user
5976	107413706842790560056	8d376f485ac98ce6fe8ded9457bac10a5b435837	user
5127	101411725174892658523	911ae327c051747f2f095a83b253c12930c6b623	user
5450	107434291759433018037	0c9fcb00835b509b1823cfb4a151339e82297523	user
5644	107489933466838356493	f2b427284cc97dda5cc612c88e8314b42fdfe048	user
5350	116111249617413389973	ca984d2fd367f3140b043a840f82a9a9c33e7589	user
5363	113973502411437413660	365539918a946e2bba85131719081c9bcd5f3ab2	user
1488	110553366885836969408	b3c371aa963febaa60c9045faa1a7ea1106b7d5e	user
6280	108536031230585647935	dda7af81bfd039f6f6cbf2a0518163623336867c	user
5983	109289325891115045173	f4cc0179e274034417006788eee2bee360306906	user
5313	104615193672641411565	b5e20508d128a8c3284304a1289b5bc7d9c609d2	user
5920	111140359246612411654	18df6e3e785c413a0bf885a68b4927207f1af8cc	user
6950	113529269457401139010	86105219143582d99071b01cd511bbc83e76210e	user
6642	103923783699459229771	c9054f3ac31d9e868ce1fcbb1ec93817f84430de	user
5500	115382621843699309946	cb21eae16afc807499fed4e40160f2e14b622d11	user
5409	117437871277613629999	55e81b5d40500555e60363585cac2b819491af7d	user
5457	114351628888398386175	a1f32159428fb186a7cb85d5964197eddc9c9251	user
5695	114121932947581881721	b464e8560de498c73eae832ccd6124cff3d2093c	user
6387	100629454340115098641	574442299832ff5bf3c7efa030602a77b14889fc	user
5488	105735616610991386244	2ce646f56fcb978c54c453a4033743098549ce08	user
5966	103702551939099288693	b9531b67327249add11e8ce396372b2039c630f3	user
5416	112154048075183298220	fbae56d34acee30571f8ff4e5e314a5ad18fe476	user
5400	100323225494928384224	d783d364f7be5a630a94eaace3e8abe212b77eb1	user
6140	114360394443508391157	15e1c0e800f43bcb49e38aeaa347174954e8c180	user
6513	116428881593753626712	f601c0917143c0cbdd34120020c7823af19aa56d	user
17382	109336905989992874826	71a9d0cf0dee3833cb2ca7057a1230b6883fef79	user
6328	105534379261061050947	79fe609176b466431e39152e1cf15ed2b3b1af2d	user
6966	113538741896053160350	6b76b2a35522b70c59f75529f4c41b96abff73c8	user
28235	114229644261800945706	814cc8904f38f4344a074059a32b6dc989bbae0a	user
6139	105122427801569397480	5ff9e6b838e4de2d3083d3236ee9d90634cee4c2	user
31550	108562404006563394764	658ba2be24f2e7cd53b53e88be2575de5c9a20b9	user
5681	111128207069265376383	6941f3b74a34b5f738dc88e05e557d15f04a66cf	user
6468	110408636199196777944	12e69d15834840f46a30fdf1d0acec18d1d90259	user
5531	117356223086180674242	224d385730ae6308e266cc46ba03908f90c5aba8	user
5933	106540878792009138011	7891209e882ef1769f0c34a656e4563a8423e1d4	user
6303	112872968935980064890	ef2043c16157d6eba885b12d51afcc4c2f9e9b73	user
6244	100870213224601082705	6c08d7f83b15a268fec42769ada5d430a2b16a76	user
5462	106478730192157907359	d68c96e127de90d7736072b7c2d1ed6c37c83857	user
6496	101633193710942170825	b47a18e71920b2bc9598a052bda98bf228afb37d	user
6536	112870414950478249881	51f8907527afd2659f17ffca3c940d067adfa0a8	user
22035	101470848680816951799	906481ecfa9bad47805552c167d6aedc70a04eb4	user
5967	107147930685919857188	de8e38458739d7f79ea55c25c28d68e19ce76400	user
6111	110606774466678924370	f56e273000af3d1f2d5a300fbced6ee9dcf4895f	user
6263	114704333810864603254	9190a60afc1cf1e264b8e01a7b6824363ec105f1	user
6256	108848347453031165545	cffeb0f9828284ec9064833ab9b55e52ed9e407b	user
6465	105001332348729167995	84da3723ba896e3c372294314f9d6799b92ef439	user
6573	113681390068745417997	2335d97c40e59e50f084d3e241014658d5082df6	user
6186	100373514490827653919	31e7b25de469ba472e9329a4336e567ad97f435b	user
6077	107301028745384927900	556052d962cd0ae02cd9ca95c684cac5c9a6f596	user
6825	112857156281300752937	ecdc12735f88e5d09787213663e1c5824e1ab609	user
7421	102187519138824292606	d413d2dcc79eb56f6860c02cf1ff009e738a0c3a	user
6543	108210163016263470552	ed4428aab9605c5c1e24f4df634ae9561f0b7541	user
6235	108773897194648952785	dc08967c0a98853e493305a9a5a7bcede02defeb	user
6838	110757805238250702422	4ac01123c4ed3d338f8ff704b7689282e29d4d9f	user
6556	109157931691641267125	2846f5659129591a82a94c1ef701b56ef80a2fae	user
5747	118240680244675482931	53fbc66a03d9d2d8226edd45b9599413e2b5171d	user
6728	117479216273329852537	7ff155e3b90fe2f93a849749869df10c93eee4fc	user
6719	107177554755735141269	8a9f6b09054ceda4ef58d6ded8c9d10c5ad85a68	user
6707	104863773335365538808	e74ecc4b917cc9be3372c64586697b262c61e7cd	user
6690	115339962081142646939	e35be12deec1173fd40611b7ee9c61c6274ed2d8	user
6883	112472980945916590575	8bcd87baaac8bfa17f7819473c086933dd80c7fe	user
6578	117966690353831815134	85bca4064a25bead68ad84576f04732f395b5436	user
6922	117968929471255721604	866c2c2667fd92c5a4b42d9a014a44c85fb54682	user
6933	113712306728446985892	a860219b124bf3ddd688a1cc4887cfeab4d526af	user
6970	107456246453619734809	20b4bbb1be46ed9f85f11181f5a1a4cbece583c7	user
6169	102269853381680672389	77ce944dfbb033b956f38243d4313bf2533cb416	user
6253	114840229803252179382	b0fe2e66a3354ea61d25f46e96ed00773b4440b3	user
8747	109583020944427160732	86f7106e9ef724e49b2831abcbbb27412d815d43	user
8564	101171591693354500761	37f3aee5dbb4d4f7cc175559d74dec5a1a7a936e	user
7138	111066027705891320913	03a83df23abe581ca93efb7e0df7b6e43ae53258	user
7173	117764114579954744999	d623427a7cb0c9ce759dc1fc2f5282e8e7c25f29	user
7091	102663222527337708902	1fbd2b5f8bc076503a0100f391cefb1c5ac41956	user
7426	111640459531281754733	61aea1b1780c463bfa563027c73b21d80936fa3a	user
7879	107393448684071128659	b8f8c557b19d2435bd6d37588b619f6d586c2d84	user
7893	100341530229780615772	df8f013bcf799dd9863b3051c05839b2aefef624	user
7520	104425878332120909243	412e6effe370fed62c6daca28ea80fdb1c86e248	user
8078	112203812328864098110	55c7553762a9f970d76ea058861cb73cddc3707e	user
7295	114369799590663114921	0a1ec4428270b02747b24abdcfd37e99e653e93b	user
8482	103612128499527056792	3decf7f9d634279b604bd273341cf7eeed4d5ec3	user
17423	115511980295745235576	0e4ecad8611af34de649c958e7ccbdb2351c485f	user
7744	112565833256553704360	a30fbfc553f387befdb8785db57e9cc853f1984d	user
8210	117773863857662055608	669f5ce9dfd7e295044d0021c7dd6958c47d120d	user
8373	113236801941654391084	878906ea8b1f9783645ae3bd88deaa5cdb8bcc45	user
7669	105433782240224469335	c1a9dc47e1a545e84a3ef1b5efe6f6f5bc52a424	user
8399	111703803711058182719	0cf44e238cb26081735cb5f133a4fe80503a56b8	user
7407	115215758125593906638	c291330c4a4a780a768e5dbafa213205d8c1c723	user
7362	105187746276593629594	52d54e22f4c6856922cfd8005958a8436474129e	user
7408	106538374742209182977	1673e5c90ff78c214b8d34fcbbf554049c2c384d	user
7419	114574453579413335824	255f762d1d2c6fbfe1bd4addbd9e28068480267e	user
7420	109557453092405104728	5a0615eb54b2a982d81c3aa498c3164e8d06b75c	user
7309	106891091144539984258	7985cd5eb01f88d263c83ad5f73399f87c6963f0	user
8073	113464349539753011433	060f7a8a6e389bf5a8eea6657e3e3199c6556e44	user
19604	101142872646572669147	ccd158d83400f219451b69b84574d704334cc005	user
7467	111567725646650165125	5f1f1d4d6451709ee0e23a8cb306a28f028dfb02	user
7076	103273107959465057265	d146919c3bd9133f34fb5bb2f523ca833d1aefe0	user
8278	108345004535686987028	7e7bf4e61d96155a2d499e740d97d4b5d6410df0	user
8452	104003420105956436392	c48b7438842578db240d63731b1473a952be4e9d	user
7170	113597979260889639153	a2f12b0d9313ce88236bae7c5f084a79970ef8f9	user
7062	116528854078263730275	8b7af022e6682d3f810f2145a1a2afa7d005e643	user
28316	109375259884013763053	fd5b036c4b1440e07ad5515a2f9322490f969c3c	user
7814	114740917522394709774	9057baadb69dd9a82766e93d1384209736ed4177	user
4834	101827448437274338234	b1a2b8185ed3675ed1c1bb91d7452dd53bc21a8e	user
28327	118364658301318604496	99dc8bd0ba6de038c2130309087dc0de50e589e6	user
7236	114748309222522139021	e2761fbaa5a932a910102b4434c43d3be7f348e8	user
8328	100317160726643486440	decea83fe792661bd72ecaa6b3843d4bd760f985	user
8219	108947651890682672904	12126dd8c6804c293210c19d5f9cf306cca1a583	user
7086	107198149074547760918	748fd686c66696eda093ea3f4ec49103c8c9db1f	user
7543	109098813558670849559	9678d586e8e6113e469869edcb6c706589e99fd2	user
7829	104220784359784029268	57d45f9fa9db4d714fccaabfb92232a30181288e	user
7478	114326744260308541754	06d389ee817d55f94fc9695d208b8982a735a118	user
7452	103398500054194363991	81c4aa92e92ea11ca336274df657105145cbc8c8	user
8366	118244727025742575334	2c63bf563c95f422f1e561e1fa1f86d32045db3e	user
7356	117692580625665353891	7614dc50c703b65feec2a3b79a99946fc958e015	user
7215	116481244449985283889	d918eb51df4d660dc508faf0e0b4736bf1c51af8	user
8758	104547213757131706346	96ed1b48ad1ef1ae1580a63c38e88d5fc6dc0269	user
8263	116189371214953919032	838075a1dcb3bb96ef0dcd47a510b85c2321094b	user
8289	111983544338321266182	2a039f0056fc88b5d99d5a02aaedc779357e61f2	user
7588	114591386611984022174	05a12b6dbc701c60d0b109f3ac89429d4cd708cb	user
8996	110283615455900532725	53df5ffa073c64de71453192cc0c13163858a2b2	user
7507	117310687405189973052	eefc8d85bbdf20d9f848cb7705e241ac2c2bbfb7	user
7670	109614878105074181482	8e513f58e245e65c77bc8664cee086d6ace8aed0	user
7445	114885547058071668870	6d90b750c111ac6f75e757075f8f47c558c20a0c	user
7828	115039944234930695540	0826d371afde9a314ff539e8dba503ccf3f182c1	user
7707	118406601333681717065	e93096f31a718d499cac8b8601dca12ab6135dd1	user
8056	105506572235545868243	88fbd111b3d42f4a103b911c5b59474a1cf62a99	user
8253	102330392737983603678	2237cd653306586c12418aea41d12e2e6105bf77	user
7306	101307535630091801474	1b75a0d519d1def2208768025b73d1d1920c19e7	user
7823	102658268322549131527	688864af751a3aee82b84e2fd5a832df12242d78	user
8252	104063535906637928892	e0992ca9a334c494d4a7befc463803787b4b61c2	user
7888	110931047755608602680	03a000299037d023f2c25f73d92a10793c0cc82f	user
8150	117368038713753317104	5c8e7202751c0c3697ad9a4b5e34694d68eb6be1	user
8092	106335102413062346097	2587dbe9ef41f0dd3e5aac9ac239464973e3e0d0	user
7942	109441309750837717539	60ecd37aa7c3b861f910fd39cc7b93da548207bc	user
7151	100444374512123718431	9cbc6b464360d30b7359ea8c46e9fa0f52954cb2	user
8032	105620503580613926309	95c2329e4dc29d048e55396b34f764d7e07919b1	user
8085	115420891548775866632	36ee6034fbad7debffce2a1fb92044cff66fdcf6	user
8135	100427482293316682936	a8e467f56c830a4b200fa3047000a67cf161e3b2	user
7969	106596281639246034885	e4fbc49ba699e8a8415c279fad8f8d1d50fc7ac2	user
8249	104237264283215661649	d6edc1a21adaaf2cd6fa84d83b852f790a5abd88	user
7353	109121374241590014827	0845d360de31e0f82813f09ea5442e49ac619068	user
7638	114591124276679160265	450ece533826680e807295b05322aa002a7619fd	user
8388	116369894268542139381	a13394e587899d32a0ac27cc5a4640dc0f8b7e2a	user
8425	114218010316466093767	0f401964a5dd210b8c564108960221b9899d3a6f	user
9940	103108124271782832702	15c4d3c5373a850488abc1c502db1f3241a1e3ef	user
9020	106635592932027981078	95974733e086f606931acf74ad7854c28c8950d5	user
9932	110659738883261836733	ab942cab9bd12f873cf9878b6b22a535394e5a0a	user
10147	112998653258877975475	9ad9302a6bfb6b1f9fca4c839e2d08c1ce3c3cc0	user
12170	112485056914497957154	260edebf5565d42b37696a8be0f344b79725797f	user
8824	102006920462605638334	74a68834246e457d7e25a537fe10864773404696	user
9602	112654001619380731452	f759c8e3cd6c55ecef00a22bb2d958423cf432a6	user
19679	114026602230300339467	bab1b0b91e042257e6e84327135360ee0af2093f	user
8663	101964436097463168367	357f46deed7069bc921fab1393e8201ee8b6ec22	user
12542	106415391789496258631	1b9c059a48562892d6786b5e0fc961c13a63e483	user
10668	117276624581419753619	14940dfd362116ded9a103904b6a12501f5cc901	user
9841	102823766561575238807	865d5f583817a9ba074b809970b8d1aeca631231	user
9935	116533323679531504829	17792b86dc6231110e453d07a6d398024b927b95	user
8943	105702456308731098062	8597230c989633035b64cfe5325896aeed2ee18e	user
11167	103438144378005049128	28c479f6713e9972c5ac303080178811fb869a47	user
9941	115433360587726830200	d5e951eb7c90a1473dcbb70cb9a5c11331cba870	user
9770	108496699258995503222	a314ba8d92ab3eaa449a78b7d0eebb7e4f8fc547	user
13161	108129314142137762765	62d260772c841438271da7a62571f155c5a7bcff	user
12711	107814725617372580100	131dfb956012c65b238a5bc695f7b3a4ae05e366	user
9001	102627795555924271019	62c8a9a7d42d6b57194df19036cbd0c1a74cdc10	user
13138	102032140608250677548	76d072c6f17a56600e0db240f46a4fcab470c44c	user
13293	106409347122793214783	c5761ecc822e70c2c39d8d55a546bc7028946a9b	user
9161	102719715304204500462	2d56cbd4e40ddf46ee28704a6b9278f3dd3de7c4	user
10439	115330146506587527272	9d5f53f63f80ae07ffd7ce251824bf6d7fa80a30	user
12120	101529745547818567302	720efaaf9fb22a4ee21b2182096f9f35c229f83c	user
9737	116478683189057283291	d14130174f2fcbf92f55b660aa98a44cddfb6f1c	user
8153	104564285080152210085	096af418edb51258111e31681af08b6215616b52	user
10940	106286990530112922841	cb5ed8c1a01a776f9c4729cf8ef4b35e3e298c22	user
10598	105765378409248116613	4b8ab3b161b4d0ad4df0ee8712fc4126bc1d09a4	user
9877	111171075972860896041	c0cdaa8eabcee84048f52575ef783e3c15ebb74f	user
12015	103091607039681871319	71d21d28f993e476260a6deaae2a42c7f0fe40af	user
13311	108121395666667399036	c124b6546b34362c05b0760ebe731b2973951780	user
9882	114352721177624111587	ee26565fa818d84478d4daa2d361310029bdf56d	user
10773	116522826000331691456	549f852821b8a6411696f56deffe73a40f4f9e21	user
11350	115889029059451906334	dff68312d511930b32d11bcb404bb718d761d66c	user
10025	109352785883855242466	224bef82fa96f9c27340d5b912c218dae52d7636	user
9273	107033203380308127028	d6f9d7016b55e5739bedad4ab38e3aaad4208b23	user
10594	108283492057740057468	d0b0210515c8c827faa17c7053da67e8f19bef15	user
9507	102378491167760853351	3cd521b85d319b2e57f9d59814b3e0fc153a38e6	user
10563	103131193577480666827	efa730e7bcf57aad2e17988af9b1cfad61ff6ccf	user
9431	101172755541818547188	be32d1e7961ae81e30268e4a253a45e816d3a134	user
26266	104093527338529559700	7b167fec25f433783a5b4520cafd473c8be41a47	user
9146	111335512155779191240	3f5527957314c548ea06282c8cb35f96a3d67989	user
31549	103488078305005976029	41347ead85c1ae42e62790975213d19a2996518c	user
24110	106377076448856502613	e00007c7bc98eb2d4ff4e7650bbaf1afe53b3167	user
11607	102481396492377586097	703556442c7b2cb97695c49bb90b17ccb17235dc	user
10717	111054950123693497601	59cf958584a2e55c8d0b1e62b1f91b0e8f3f486a	user
9907	105102379391896692236	9145c332768374c067b6d0780672d627dac95813	user
10074	107225841050163511047	19184f599de3e7e8456caab4e37d7fc2ee547f04	user
10916	116202437207229418439	79b4e8dcdd560bf48fd1654149dac383c66449f0	user
10321	100876071657723299498	16b7bc798a44bbdcdf51808ce5aa58d8dc153b34	user
10774	111790252858780067280	952272ccf3b932d5687275980c3ee9b239c7b4f9	user
11085	110220417219976226248	7fbc194194cfdcc144057b7d8ad4a66385a24723	user
12852	106278554674995616834	97143b3035c1ccc7e009ab4150911ac4b40edb06	user
11551	109215285114265989714	e26ec8ac5b53c25bebe2fc26044740ebc1aa1793	user
11244	108657894448748089100	23912ff990f3a1e913a4c93641deb219a6ac4afd	user
11587	112367639576206413452	0f3da4c562ed77680733dc163974b9cf340bef92	user
11359	103723685173753170428	398bcaebb5e96e51c0590f198360d564b11263ae	user
10629	116365908916402634741	ff1b6411b46dcc65a323e5198315f8c4af9acdae	user
10762	105703282986440185552	7cbd40f2a980acbb89fc86e303801421ca16d362	user
9569	108382685221057954981	7fd6d4092e99deae405f8d498ea1462d6aca9120	user
11214	111692737566168118435	424bd7f9afaf32047805cdb895cf898e28259092	user
7615	116837958596212598480	c12ec15b6ab1c0a46daffece1d3748d4066706fe	user
11727	112744303022609382424	fcd04e4c64fdd416891149cb1cc5c50a7c13990e	user
11536	108013768579266369989	4a4e47dce4d096e334e029b987c3f0d3b8290407	user
11349	101136801595257969901	f65d7736780c8018a8e08677df7c938525d61ad9	user
11656	114813019548048172570	9adfc4dadfb91aa316a17c83526316b98531e8d7	user
11852	113809084463578215556	2905d40517b3f66720686874e18c454ae4a9e0a6	user
11527	100744438715150722107	10fa9aa57a6b9d82a5198dcf67b3e572d95912a9	user
11777	106307654230780304539	4929b87001a8bcac1ac6c748dde4c42dc3e5a3ef	user
11764	116047930466793291791	81d70f773605cc29826ac5def04f525104198c7d	user
12609	105966691583185367517	a9b1eb1b78114d5b03b0952d8764678959f97730	user
12668	117480425800545607089	af8b5588f7390c9fe71c8144eb990909c3150731	user
12851	103501151941800356274	86a70654e7b4cd591fdfb14909c84b8616cc9790	user
9730	104662693858655380465	6d592a9c51eb87851751ce016228e03a4eb383ae	user
12916	114879248319936894164	a57230a39125ce95462cc5d1c9ef6bcdff58d6c6	user
11092	115879398366126639386	fac87afec6f4958001de68efaa488ecdbac39c54	user
11112	118004615112209735453	8cc74f3e0c32926dbfbe6f11d8d395ba8f61fed3	user
10903	111650156609320815046	9154bd88b77ff9e5724063499605b1b5672bda9f	user
8620	103628381857359898368	cccee176e9e2c18891a3e0bd34178d7d18ad05cb	user
8859	109432364385136243098	9a0bb914271cc81fa23b3b76f3ccff69a3f1c69f	user
11042	113399580761841634153	496234af06a337ce9e2df353f082d7ac15cec972	user
9377	110018183307703015999	f0393c2dfee2e3071bfeffd09a6ebcabaaf53b2c	user
9892	111710272164921687698	0ef9565b6eb5dd1f23cf81d7a0591e70d280169f	user
9494	103308922454507465852	7c4856e26ed46b7136adf431da95d6cf7a7c225f	user
9641	104294280397208849479	5f7855dc046bcd4576d338b482583431a83368eb	user
10000	108733883465772823484	ba174fc55fd67f54b537fdca8e8a0ad203b9c0d2	user
24136	107532999868296523502	fe928639cca704c299818d794db846b6425d006d	user
9268	113069714899047220836	6da16fcd4e3410088a435ecb30e29399c0965bf0	user
12802	108600984309818701065	bfea31f6d9b43cbb6cad7f064ffa8231220557ba	user
9071	101626955168185208012	7a632da66085e1b9d082563ace95d42d49cd276e	user
12227	113493577180279750534	0950c3a6ab1917bdf1504f5b1c600573144be789	user
11825	114049354868175047110	5241a4d08e72ec44eda8c660c0b4174fd9bf5eb0	user
9485	106355600612411521354	2996324834cb267f219ec311698e0c79a74b404e	user
13210	112966794963954956260	a01b25fb1586ac29819536a57cefa3aad7fb4edb	user
8799	111873789583675808617	5bc6de8d6dcd870f2ff3274bc5bd9cd403d02f02	user
9357	102952072459497959474	8ceb010866cca4f75f2dd0969ded1d919eb9ad71	user
11040	105359990990724355526	f827a72c9d0d70237b7c2ab24397ef00784a292a	user
9581	106806052669784234976	a0cce4e973f8865043282ffdcb6e7d715459537f	user
9580	113468750706613363716	170fa95095ed52f9e943d88b7e261db1b6970119	user
10403	112188830982780019541	144580b82f0abbc39a9680dae378ab11038697ea	user
9837	106348211089456308863	f68787be5daa0c9feebf23085503fdddf268ab92	user
9385	110271268844549390100	2d37c4aba809ae6949eabe50d0dff0606d3c6c6d	user
10906	100540351647011424813	7e78de81baec417aa1d32aaca0219cbb243780cc	user
9657	104523922747918185043	4cbed3013af14b8a0cd12bcb9087bd67e5434c33	user
8611	106653443315295232533	972bd0f8076b599b0553b194b350b30aae95c827	user
10404	109473029886699548381	cde162dfdcd2bb3289d738107b3196ef7a808d61	user
10104	101988431255785683948	96d1a7852e317ae5407d3e956fd3785cff08f3d2	user
11570	103396227673197383401	c18d98acc0fb153ab1909c8d37dc83954ad0256c	user
10972	105383915539197235322	819178f34e6472e7ffa935eda7cc317c271c14b1	user
8347	101719078540936693965	8bd72c8c63ed79a095806d7e0eeb60b9fae0695f	user
2451	100680093250543498335	5fa9f75622d9fc7f55fc2046a73fdfdb9f940663	user
9707	102341274763983527312	ad3e3f8712e0ddb60b1a0ebc28ba4a6f3a0a45e3	user
11579	114454817398927418390	023dc27f5f3588473d1022f1766fe4d0a98ef923	user
8928	104196509524819380284	ad94b2818443af11979aca710d81ebeb3b4aa179	user
9838	102195777194996285654	a025d7917cf28ba5fd7b299e174f72513f12fd84	user
9438	101171188455426530274	928ecf7b210f2c2fa8a60fa20c50176d9b4aabca	user
9418	104181085677236457428	7e6db6f7d043ef39a82d7b6b3c1b4689d8bf0529	user
9658	104768237535269074850	c42272c30e68b45ad90c205fdf904c66fe5c933e	user
10947	112870015091726857162	42510df7ac62ed6d75259fd608308781e48e14fa	user
9103	104971464362178380321	5ad3a1aa13a24d9f84881f0b8c4d1fe7829a0918	user
9378	109722948945101591188	e6570e6f882c6b8c547642feca156013a0b685a8	user
11001	107008061572479616642	630ff9ac5220e6d26cab3064ce91b47266e5a0f2	user
10584	108977537476281644524	9e213a6c90bebc86170ac227c17f37a1c6ba3e4a	user
6710	101927668361428071197	5f71fc749c3ebaf1495fec418267314be5be9ac1	user
11095	109341647643235882215	84b00d63a1e8c65c1e7987b3c50eab6c5136796f	user
7055	114582343462323173676	c60596116405bb3a05c22008e5a1bc5f436c2794	user
10176	105576284422817967929	992eb71d765076355270e293f03a78992c74d4b7	user
12531	104947023065993961827	cd8b042e1991fdd78150e77241731cefc3ba7181	user
12439	114919245168293555948	32545fb5c277e8cf4b89924270087878926b5662	user
9865	116667899528785398547	1e40c159583f1aa3e01e00c43c5eb3c7b17ca7e4	user
11219	104819180766332055249	68535c23d00919512b2c313d4550eded156c7c9d	user
10400	117857658398501576041	fe2d3949342c237e6e655fef963b189f8d8dfb94	user
22051	111325908744268034050	3d194ca903bfb4de010c8bd48c91cbafc501bfa4	user
11398	118180651001550783697	a87ae3a7966e20556451d0fe1c6fb21bee44cff3	user
11066	118415782790952721983	f8b6caebb2ebb4fdf6df7e370ccdecf4228801a7	user
11336	101457174803921195320	74661709960ddc24beaeda45f59c70227380ef54	user
11041	102636321268460229245	9c0e204c6a78b071092401562eaa25ba550d02e4	user
11190	105648755733096962226	6a6085d61a7dfda863ca8c4b8bf638fa93a6c70b	user
11445	102735459409810377329	753bfda951d09f1e80729e7c2acd9a1cb5bcbfc5	user
11625	105778861737439936758	09c245758e6f25e2fb8dd6848c62b23cd1baf8cd	user
11301	112550532760599361927	30c1b447156b784e92db6c7ec1eada79b0d0eef7	user
12428	116834353417570903175	449e4aae024b97bd29f66519cdb321c62faaf654	user
12065	117829093653038208495	480f0303cc62ee72827c12de421917055499b1f0	user
11715	101042086808084988246	c2e1c5dff6f0df15ad851c9c0a46dab0bdb71e6f	user
10520	100903677923974025368	650c9804f42335b926c9d278eb3998c7493ea349	user
12165	102696267879158004647	40846ba7af59a61720c020d8dba24762b2400819	user
12298	104261072724142761059	13a1ca54c9f2e60fd9681770cca284623946955f	user
12474	103607262433637419142	aa9f3033ba5862b33d8086e9917c68c364573241	user
11998	114628427311007654470	0d363142e94c6c3f6fe996e88478415fb2fee8f4	user
11211	110816632514375330936	de8fbcdfdcf331aee00faedd7b66670fbb844ce4	user
19696	109344380723582753140	a35fd3ee01d67693b397585e6e9766d605c6b803	user
13451	102478213252906447785	6dbac3e886e8339842be00586be35a7d3e927ecf	user
13544	104688448802023181992	953dd998a9d49ee1b683d9c34039d4b5bac293fc	user
12917	101898331174970475313	05cca366e7fe69d0826dc670fefeaea848c9a910	user
13344	103930184170610275776	14ca785bbf0a5fc9fda62668faf1f1e098001821	user
12516	100666867636647034609	46a7347345ca7c51ae007f60c4d53bf6fbc45f5d	user
31663	110975995114402452564	e753706e5fc76935f120ed0988186447c52c8d99	user
14336	113591277455155100948	9294bf0da634c148103a16b3791fd4e0e9451a26	user
11043	114663810596979050512	88abdc386b0309e3c7e18950bf3cd7bf655bc921	user
13904	101500598466006405003	1fc8b5afa85130a35ef20d3f5e9acd7f60475b98	user
14382	115890582017119856079	b64fe24e54b88ff9d57c84b8fb2f104dfa5559c9	user
13353	101145697867206691422	041643cc5434d276aaa1aa2277f77f39203797a1	user
13604	108340065003624681178	112e4c54114d01408ea76ac9d5b9210d60c707bf	user
13337	108833854089057606604	e8a465fd7d5ce7a2fa879905534b08250be524db	user
15001	111370167988093752199	55f9994bd65042807f69908cbc8602b1e2f6c740	user
13488	103402530637959619603	e40d76e661e0b62e16e9ec4f722922ec68ac99d2	user
13555	101907654598338293396	efd37594a2c4890f4f437e97068be0d2fe3289ce	user
17469	108604979568748127567	875fb534e448460c7fe2c9178db63b859c6539f2	user
13319	110719102246911509342	72d232b9ca8fa024aaf99a5ba30b04a73d74c8ff	user
14187	113382390019554265804	7c9754652b56e2726c010786a13e77fe2ece43fc	user
13243	100386862991581341157	493b4e140e4ceb877e5d258990f360eeb83f5a0a	user
13508	113546016407135303566	0e38b3530016650622bef0b1de611251090f4b28	user
14069	117979108882613694104	9e402083deef7df1370a2b074027dfc9fc5bba54	user
14186	109793064286665109593	cc00e956e89fa346d489a1d321f80daa09790364	user
13034	100628633987918286449	fb172c5ecf3c4c0f639b424e9d284f2e92f6ae24	user
13763	101908311592942095194	c73fa03545d7e7cf3afa7f8f4b79d4fdd5cb1f47	user
13298	106113073509749904874	18dd34875da9c7c8da292a96ed949ec8e17a01dd	user
14655	107777212290619963576	ab9a06316930217257783a151469ac421e67af32	user
14484	102703552648579370653	bccdd44fb37bbfeb9e9ee7ef66c1f45b3b24ecc4	user
26267	106650680769126177630	275a589eb9b70f6fc50983797b1f9f1f20a93a95	user
13318	100409827768971410841	c5076ea1d5020ef1ef811c75f1139a55a1d747c1	user
12999	102021247714894981375	f3c64dd42b75a126a0dbaf36e2d9eea65b4c8eb9	user
13242	117882539865048649647	38c6e03833f0bee1cbb19d0f9ee840bae94b39d3	user
13675	102818605285608644890	5f7f42def7509267632a1cb2c325cd7cf54cc6f6	user
13674	109188619298060523645	ac63d57fb9982ccddcd3b53d2f0f9d57b7223afa	user
13334	103740957304582810016	0c2b45fe0cbca4338a7fdfeaedfd3db466fc448c	user
14333	101937276611031739312	072c65c76b2f803ccd71d48b3efb7698d51372dc	user
13786	104876254277989979222	3f9d511a747d15c9ac3114d7c41db3e1f511a6ea	user
12817	108390131197877790585	07a6083c58a4b67bba43d32717430faa2c524bfe	user
13611	117874484285329294192	40fc26d711f13582bb9fe51977200ba4722f977b	user
13859	114118288202789491662	80872df4c253a0092753ba70485752e906feb93b	user
13501	109052781110646956753	0c9829afab3479c3aaedb5a6744af1067566a4a4	user
13241	116666622718086105584	b2c178c3f8374f8e29d474db63e19a15e3e95b79	user
13394	109309174537793376519	cfe54e369ceb1a0b27b6ea6e6ae12e77a7eb06f6	user
13543	116858837678187515139	2d48d98c8acfbd582aca7cd508301e02b450cb9c	user
6399	107726028519801979477	dec57019633ff07d563a1383a707229077f66fdb	user
14326	101589422478585216731	b6953262fc00cec7fe4f4a3874cca5ba99c924a2	user
13082	100356755692278374488	cb8152c06f435eb5b44af7ced0c4d0dab7cf1966	user
13942	111673488765813015438	378bda82816992e47257a972f89ccbc791094a21	user
14030	108208364475622836441	5b3435eee7fb6de58dd63951c3c5b7177bd57b9c	user
13979	104490561986228753301	0608a22e8370a32226476827ac5675703bf9ce64	user
14173	103019045688394534925	e3b3896813292892286f681d16ffc247d2202d6d	user
13968	107020637866794952560	286c3caaf8374223febaa4817c864f5c0b6a5f23	user
14723	107140808833289035360	fa22fbe38fb8ae42a03993b909b42367abe3f346	user
14130	117920921016867287631	f3b593646b85889b6140e4df8ba9e9747db9f7f9	user
14325	111720544730942682902	503719899b05991014b21b9ecc70a2214e1f63a7	user
14220	118048228050424097200	40787ec4c899b35afd68922a149c38fee3ad5a6d	user
13013	115337446901304980916	1074ffc5ba98517e4ea5ce372bcd6b832fb28b92	user
14526	108729366027135127866	db26c820163c4c65f8df79bf6d2d71552aa00f19	user
14629	108496485977679015175	f7a0d899d657708ca4081b85531af521285776b0	user
13008	105867436203536915647	8dda88b6f1eac5be72b13c2ed7a222ce51da7ec5	user
14465	101521652097057965274	75434c5ba1af953ad622556e719512a91580309e	user
14656	114864206938564902207	57119edc9b4c5ff1014deb7b0d5a06a800a1796a	user
14440	113477294628654744659	802ae95d07ac3a1aa8456b6e2346d83d9aafa44c	user
14476	113726068402775339149	e33b7ff9f5d02ffda3d8fe7738b194b28b4aef83	user
14720	110174260954976084383	6554777559209f764986570dbf2f05c3576611a1	user
14728	117668160078649532199	7ef76f8ba2003ea7ac3238dd02decf94ef296713	user
14764	113078466770221533079	055473fa59e1266e4290ef4490fe914f20772427	user
14765	100429882498919065692	a854157671346269929f5e18d3194a83f355b6ad	user
14819	110032815839257235598	3a4ceba62457f2f93593f2f75428e701598b81cb	user
14854	105377586685653541429	6afc7a925113fcd7884601d9f7d903ff62a3d04c	user
14909	106805539441737421965	3b51a93fdb6ccb71fcc04d3cb2cef40e138f2179	user
14930	102216187786719638066	6687715c48036ea81f43be16211ae59b531c8ead	user
14969	100971570005396746354	fe9903fa4f5e8b362b00eededf40f3626e16f9fc	user
14697	103626818376068643468	bdacbf04a929d5365a2a32b5645d68ec02973235	user
14648	104684351632584032808	6ec0c0f56d506a8c8ab335b9d38a1e8fcc1efab8	user
15343	103388567827480574153	c04dd72caecaa00a2354b4b0d5c19a9c3fab8d73	user
24179	108973532333561486167	f72200e5e3f79b14ad24d4a9972bb806533502d8	user
15076	104348561115381214339	f11e80488d9be4f5549557d770cabf3a00c917b0	user
15884	117676065019035894011	2c54833366b2d84f1a78a67e85f3c03b4de5a3a9	user
16175	116247351025346764156	5253ec7747fd9eefbfb57e6d7d727ad6eab6459d	user
15320	106520394041788378062	85c63206a92057824d21aab9b149e4bfc2851cd2	user
17333	105366476143622097769	eb96dbbc18a087b50f2f4b573e9b08e909b8bdc2	user
15408	110147729374572380021	3eb6c36046c952f7b142aca50963a4935305f09c	user
15180	112839692817362631777	39a003d652ae74a15a14b452ce706e25d4b023fd	user
15008	100107002515350266130	064a91b97e16d1c7aa90c4ce9e8dceccabf10cd6	user
31670	108497453376781852945	29f2bd06ab7d511ec34172df14a39422826fd2f1	user
15303	112311579826220205379	f8c059fd435dfe7ae2a84427640c1efa9e158b9c	user
16397	109744159274623744110	09698360f2762c6120cf840aabc2c7769b0fa87b	user
15887	113995434481521167625	5a12341e959acf77691438651b00be9f93de0e42	user
15085	114900651924072623893	1e001307c560e7053de3d346209a1a47852eaf19	user
15403	107391169496297798803	7a1e360d83f5da8df1c21f5fafc59e18a5b82471	user
17294	104718836887841018992	7e7b54e5c06eb9e0c2e09ba1ce5d24654b9f6274	user
15336	116325192833520695834	4119ecdbd72e62b376db431bc94e1151d05740b7	user
15890	105471448741221920964	c2769c3cd7c981e51dc7e23cdabcbc6ba8aa2618	user
24462	109853930299444486331	c21992895c3c22d2badf41c46a3f50531fffa9d8	user
16651	117559934115571313893	2cc76bf101b46659b0362d85c4cbd841d1fe39f7	user
15071	105637238575566408188	4ea95ba9ba07b835ef1351d660c0f0d551d3ac30	user
3259	101532661979094815998	3c0a9833dfcea908a11a087d81940e2c6c83e754	user
15260	106864235843535730933	1f6bd5d54fd202861e977bd2d1a17e3c4902cc3d	user
15415	101973134345965974975	66b46811793101e2f83f161455399bf92a5c1ce0	user
15831	114962124492980809294	66cbe609dd64cd73d58dea4c4c0a134379c31358	user
28328	103815376056397201895	ae9df8c516a4744ccb61a050bc00b1daddca4d0a	user
13688	103736639878516984826	22ea3215bcab367f28425cce4c6ee206f2beed6e	user
15207	104971261271364772625	d2f14b168bdc430c190acb8b6c27a3e2923aeb55	user
15229	111516434597847091452	afe69cc94b7df7b183c77de468eeb8a954251739	user
17633	111188347595798707135	205bf5ef8aceae6646354e1449f247c2e2cb9e9f	user
15373	100091215008298175933	e5824b104196dcd68a28ca4287ab12ef739cedd7	user
15131	114468659310476432891	4057708574509f1dc34e16a394f7d7769d9d76c7	user
15138	118291383481609082734	5f8a604f64be4dec6cefc3aac5c347e04e677393	user
15086	108682568981573619294	c9e0305f7d0999032609f52f6196fc5578e8b271	user
15584	107636850314884387300	4709b78750e5a8dd6621e70b627dad9c3b8013f8	user
17669	115799443155105349456	7422bf69b107e1d1b60f357d81e7a86da051abfd	user
15162	116708695537716690014	4187aba46de8088f46fa5d136a51ace338bf7869	user
15960	103007964566549103489	149bcdef2aad6c657a36d1a4dea362072c0d42a4	user
15143	114990232765248097863	f2fab923e5ad333f9730ac67b14a9aef2589ea35	user
16916	114334225426749652469	f7a0c0cfc950bf6bc752732531ed893cbffd1fe1	user
15265	113663342479235055911	84fcc24f06948cb33a836c68475404a65dcfa498	user
15027	105392264781439901850	23957e447378ef4d42b6a4a5ecbd7290286951f5	user
16646	102645890726189369599	c662887c2b2aea1a52a2fbac5034e5004ef9b8f7	user
17217	111654948696293074286	0157edabbf6d8b2bca0e42b3d657c7beccf77fa2	user
17016	117191117879143045227	e0ee83b9afa4eee55ca50126cbd16cd6cad66063	user
15298	105889863618992805661	8d1771754b6203721b12cf1b0536a27f6e982226	user
15853	104533319500165504550	3d79673a45567827a16ae244daea7c4c82b1aa96	user
15522	108827967019219649387	f58d3fbca65273dc602e8e845f2ef92d42cf24e5	user
15591	108093437797103881179	3db3d23a1f11a9b7168e5085e3dc2818f0c7c9d1	user
15951	103742106521483093681	d733bb48c877a5ba5149bd4fb6a8b9a18b705026	user
15934	107698263262342388125	2728152557755d6c2f08974660c0415d7aa9cc4d	user
15720	111262646770972346368	060a788afa040f43f8bfb1b1ff54006fb350b9fa	user
16604	103242500128253530271	063773c100fb9172e624003ce7f566f9dafefe05	user
15935	111958938459816957059	b59cdb4ec542d6272b3dd61590375730d14a8b76	user
15344	100007341599144671991	950b87ed923fe9dced3cd79de894a2697cec14a4	user
22062	109854238168986987809	db0af4b127ade805e25a89ca460ca7eb7c45a529	user
15378	103349567730122948734	5ea16a437481a8a22fae703223ad1fe91c5a48b3	user
15919	112952408322513748665	07f451297e1b389a48a325d923075797059eaa52	user
16028	109747320167467827913	eac16f668159f77786e7f1e33d205a7a7e8cde8b	user
16721	111106753838981121071	da8c8821947a98501da7f44c52a890720728962e	user
16708	114676563882884899432	ebad7f08a8c22594ae6e5bea8a77a56588468685	user
16540	100935303792996603450	d9f6bbe5beaead4f328f57a3be8338c1fb67f931	user
16573	116139004159248953879	34944d7b9367e55635f5252f2624322adcc26e25	user
16493	100062293771283967265	ca432e2a004efc77ce5a18d034335e4fd74fe704	user
16688	110026865942229726407	35490b04daaec0657d4f141bfca4dd700df39560	user
16656	111554553216462510738	d28b1ee8ad04f76a188aac42fd23e3cbaac42848	user
16858	113301572741765960778	e8e368e37869e5448d6b0b73dfc84a30bbfe41c1	user
16488	112577341060416034211	9fdac7f2a429d9d64a6c52b04c1d1611ca9008b3	user
16901	108442910388268961677	a4440996a861be9cbdb973259cb14caea7e560c6	user
16697	106052007854326033612	583b15c732a20234307fb2f0af6aba17acf722a3	user
16837	103413670559273735347	d0588d548d574f4446e1f7c78a5ef62e9c67f0c7	user
17011	112784499723253825036	3ff28f962bf4b27e030478eaa15b84dcdbbcdc0b	user
17050	103072076127132184671	5058f4b596265962b04d24d60b170374cc22a619	user
17206	115308042909963382834	04e2d17cb82e2edee920681c46529d4b6b8bdbec	user
17115	110451448148325121158	02474fae6600c49b2c7d454b5fbd67f906b77d0a	user
12885	102078790618882377357	ce88c2b8307377dc5c30ef98b616f26fd5f01c76	user
31687	111341297199545613038	9a3cc1b8b9eeaf439dcbc663db12a39ece7892ad	user
18454	104914948058055303827	b47358868aafb9454eabde61e1601067602b1e49	user
22122	112136155569381255577	b6efaa1ee008ad7f386871beed96f2da368e80fe	user
12485	110834837890329203639	7b9df84dacce88578da905a509e4c796df64e237	user
18015	103731424788131632129	e64c9544e915f88a36830636c0904a80d148407e	user
21134	113696412226304739237	9aee10e406ad69af47ce685890f5075b16cd76f7	user
20403	108254744377935010731	fed9232976e41ebdf94a6c0f963619a8ab322b8f	user
22087	106892782443561710330	2a42dfe78e98881bc79a15f085bc841002c5373f	user
17797	106412861907604390589	eda7593e109070eff528418b4be2b6c45f80a4e7	user
20375	114460255359960686690	19a7d3d713fc236b0b01f16dcc7e153aa6255325	user
20317	109889406964683955247	139cfebb995f9c0838fd4cd9b36632bbb54d1bfa	user
17460	101286071491115366059	14618043c30bea48dc23ab27cb840182be4389a1	user
19773	117809046150519937646	561b1a4458c1bc4e48800e52ad7d8bc978c896b9	user
1348	107156601039704846020	9afcd097abe8cb8743cde7b122c43a4d093741c3	user
20817	107214507937748421041	61f477fa180c822176ad5658548c416fa842e92b	user
13754	110865832851443517161	070809b0f7eaa726e16d198b235b96ab92f7c683	user
18809	106897637662401533070	e7cfeb39b23409b6263fb57098d269bd3dc5e151	user
18367	115248932068817934496	94834b99eb096ab85db8cd11cc2a6701752ccbc6	user
18390	113736050608649390939	c18b3a9e0d7f90ceb9bb4b249e5ccb14065d3b25	user
18783	104667207184638210763	52166bfa0f234f577022748944137b19e35efb15	user
17501	117908332937907735815	3df929f98c0ce0ad7aececd69d2841957fe41584	user
19523	106581333278827306337	377dc51ae1623b8852749e651f6ceb264b544af6	user
19816	110925589402818603855	595d0f21a019afb94851511c7cbbfa4f790418cf	user
17734	105277617859997020173	7b94d594844692d82e2ac93e2e7f7ca03fd24ec5	user
17826	101944578273299352029	a2d5d8e001d747e7f9a02e221ac451c1bfef73b3	user
20883	116421020974357240608	9f15f4855247ac91dbab94ea7937ee0c629f18d3	user
16619	114460674227562471128	45a7a9d3516d55f1d92adfee7767547870ca6739	user
19867	114065040695019741051	ec821f7fc82ce6de07790815ad15179ba9f098da	user
21170	110896153092092864357	9455c8bbd8060c69f872346fb328dcbf4f4bb914	user
18582	112767914135815011236	801a406ada3a4df459c7b317d63910b3d8447ca4	user
24243	100970809889276910970	0968451774184d9ff22c82a2e6dadd307a9b1c32	user
20221	111147619192315513583	9dcf94954530e541635ef56ee05b8ae9fe43d663	user
6477	101398156657528003471	6b95d7768c4dbb29600dc911d1b2ee5bb357f978	user
19512	117437619686111413164	552273eb905e09be8db461feb74192374a146c8c	user
22080	117494115772237022933	a1a48ae79900a9a82696b08544d0cce57e612ec9	user
22504	107836389792965014526	9a8dbe09b026af9adeb0e45ad9948ed95c435b1a	user
20454	105869193300848969627	f2cb698e781de41095ff08168062c46d118d2cf6	user
22067	115877582789598330117	1e2ecca97c256da61abafc462abc046bcc87d416	user
20524	101723642987973735918	ee9929daf9b7ffa1743270bc0b76a9aa59b02751	user
22083	105691299700355446674	fbd9f2274426848653faabc43bdcbc28b0010d19	user
22201	112066593181711337536	a7748bff4ba6d926dbeb365ff684b9c65a5b3a20	user
18489	108556356234958183057	e6818fadcd0eb021d72105b593868bd075b8c601	user
18583	108859269534227428590	faa96511ee63b30cdcaf2b1821e49604ad6d2274	user
19486	103881707281584352472	36f3960da61a39b32f94adc28aa13da7b251c045	user
18668	103485490581328043118	4b85562841a209cd6c02bd93bbf2f082d3b7f3d1	user
22106	115825834927273789916	83d4071933b2a2e3e8f63397ebe9f683b46a4811	user
19079	100879140504622169752	3d245e518d08bf749753dbb00945db9b039daa99	user
19962	114001870545129070750	3e17acfe8cd5768151333a23fdc3b9c4f43253e0	user
20595	111249737724193533146	78e80ad2d506515f22482870e5b36f0a028511d8	user
22044	107461628160278570223	e710b1a26e2aac4158d5047f0cdd51b30f797fa0	user
20142	115291249054184396904	d72b7d19ca5cda6d2c4061f4e0b6dec2945cc04f	user
1546	103656407720006034171	0e8c8f948b07a860b5f3a7544d4a22fa1f416a7d	user
28368	113655434189423231739	14969b7206897d2759949591f7c9a36f1a54122b	user
22208	118225482088722822025	d2d2ff301db177ac9e463ef6578efb2eb81055d4	user
22266	105682417554191071301	75aab4721dfde798f13296f4d256f42a2ba2e608	user
18967	102337992027001659603	e7efd01611d8838003b74e3906aaf9c5713bfac6	user
22305	101204317216387759803	7248ba00dd354d57e213a9b5338b498d2c797c92	user
21331	112876412127381726329	a97d6a8da2cdafbae8cf133f97a118e882cb8519	user
22413	107625376588793983867	7e3abd3822012f78ee2b72661ede4d3fc1e4d47a	user
11814	116481728933509462775	39abc9b25aa7e620562e211a649b4e5ad3324b3b	user
20896	111592449927501447231	6a574a29d5b414e0ef5514c00f90493071189505	user
20565	100435892597443729390	96aa83e146618ea3298514a36da0476a58a3639e	user
21052	109875688119492220593	a18ddbe19658d6bcbe7fcc4d473c20969eed21a5	user
21437	106946853683032263380	17cd060973721244812be0676dd236f4a60a5f42	user
22469	110557781693948154226	6c221dae9262fbf59985d401b6873f0793a8e5bd	user
21290	115768587578837624653	f7bb01ad6dcbd262f9e26c2745eb46b630eb885b	user
20445	106522512292842581656	f1c9c921c887f2c7421399a13384f457285dfeae	user
21751	109749255160356686705	fe42e5eeb91bd5fb8792dcee5767b991adb1911f	user
22470	114645348011786260170	399de4244117131f9fbd8afe734dddfc3805f45e	user
22569	112393030428376886191	6340668f299c1bdaa093ec76c30aa44194a2a450	user
8505	111203068180225244060	efa137cf3c114d8f625c076a6d2c92664288cc6b	user
19997	111057843707706628162	bcc0c4bd03ea886a7a14c72c9b1a9c37d1bee361	user
4872	110035970755160527050	b1eafe4afdd7310f652ee70a9e4c592a362144f0	user
20161	110061169103924354522	bbdeab95b6c498f1755ad4dc5c36b174b3227bfc	user
15521	105076259957419969308	aefc1438e55fcb4738874176b3438756fe180602	user
18152	105096418295296750167	23f1bdbc2ad7941c52f3b3783f9c61444218da6c	user
20250	113868334961980318603	ce15550b778b466c8e311ac9afc379398c90f2c9	user
20560	101346850687390430152	3f52f4cd8b5c17df438443dae29faefd5ae1d3b9	user
18307	112700648469597583626	c0753856ce9493295f0dc5307fabeeb8dc21a3ea	user
20480	115720717467371239169	e39926191ee956ed1072794dc49e09175dba9bc2	user
18433	106938518456953472362	e5f81129b07e12d97646be6f9bac1b322215b2a1	user
19707	106673190696374476111	436b86520c7bbbbec0522591b7cd102d3d8c6891	user
22920	100759552192333828461	ff54efe0b3cb40e9b3a0ce21c9d5446f1b7987f8	user
20334	103255886189575172045	a7e680b1823fb22c7a0a064e1494d92bae520d48	user
17779	106998521804104200708	806272ee4e28e936eef82a4ad7bc75f03e5ca984	user
22281	116009261508057191570	c97b2345b510c97fa09256b254267f120474ac44	user
19795	110852755961220516170	d8a8b6974b322034f39512965b6665604f737398	user
20588	102358353258651799998	e87e07d7db0e446f915c6630984897577368cc0f	user
18768	106652687558722558532	9162eac42d4ce08411086f9468dcda235577d327	user
22424	113713806575169641545	8c803fe6ee789e91f068db5c882373dc36d93e3c	user
20751	107080380616313180851	9c7ea7b2dbe14d40be5c73a93dbfafe4a3f526bf	user
19565	100911127677636231036	856d80c2e07425a3e890c7b1e05cc05790b3ae4a	user
20362	113270308068308693920	3735c7fcffdd3fbf74f816d19571a8378ff2484a	user
17778	105728784342910026116	3f70cc7d1a35fd08d39088e15b71489fe543a856	user
22614	104926536466147692972	e41b6314e7d807cd57e201acee636e5083e3596f	user
17143	115433487120178068422	7943e6c7f4b46ac590fcf4f9050ae4eac5da9279	user
15936	113326721099031890221	5d0fa7e16bb0a09d08f424ca243526bbad98b073	user
18881	111244159787042145700	26da27fce836d94611d4d20705b81285e149226e	user
18432	100588547910962681744	e4331b022924833ab852b28892ae8114bb9489ef	user
31694	116309397895817359481	0c23c8569b46f414e59c8187e8a18ab2e5667fe3	user
18553	109067105576989264497	7b9c6c83cefb8ecac9b79eb2ed53a09d7837ec2c	user
28660	108612518526783380262	b838e3314167797c3d4f6ecefe87ba8a4112db2a	user
20129	112127390827729456273	58ab5c65f05015fac64c3dcffaea96630fd3f522	user
17686	100582633053159315898	c709be69d70c85a3f38d0c063fb64a396580ed63	user
9088	107870943386419228789	6824cfa86d329995b1c3168beebd35b0fcd5c40b	user
23116	104634840831330665715	7b0ad4169e1376fd83a9e91462b4a008b6a07407	user
26277	116969460420605090641	16f4aabf260f19e2e7a3857ae8e8478f281cfce1	user
17560	104594709803863772446	8e8ff772dd07d11411789aa73c9f651e66d21a9e	user
19176	112313337700316144644	ab69aa061adef19970a45cf91bb47bada6320a53	user
21338	117867040483756946449	ab553869cf9d3ef986fb0d827f4e2fbd3998b5b9	user
17689	106629575846126937942	d901e4f803d1a8a27dcd5a427c7888a628ef7ccd	user
21075	116530412916957561133	cd5f481ed9633166bdf906f4984328f173a89609	user
24630	109709409847775998792	0c06e9e9b0ee8af7f2d42479dcec63afc8592fdd	user
17875	117741399179967439398	46c81b30f7899d06cdfaf7f60b0c416218c5315d	user
24306	115919916983778122153	5cee4349832578626602f8213e898960f7c44fed	user
17755	106306673607640422342	a7f98c9de93eafc457663a2ab2169cca0ce7cb14	user
19094	112948527520079330665	31184f360400e04c1549c4c93b9591369059aa48	user
17878	114936367563313121781	ddeb5363a8b0d8f0854045c7d764aced7027d1de	user
19726	109365219417101681548	97bc8dad85971e1d3640f915d6d92b17ce8eaa1b	user
17786	117437415408129738801	6d372f663a784ca3b6a42a7134794626944e181d	user
18159	102790137285939618944	d4bf9bfd4ddae5318ec94db8294c90614d2ad386	user
20828	105792740625464197848	b92e23a02f58b988a1c7ec5d24348947e8645cf5	user
20461	107705980388869672861	d389054ca39f563df984958ac4df56a59adc2518	user
21211	114181895600121266149	58470e99464ada4045f91115373b31d40de0dda5	user
20438	102016362692018663817	b9cf7b7fad55a1a712c137be7b045eb61f191413	user
21446	117810709345028814872	703f0b58e638d146267cbfa20b5ac358653fd795	user
18047	108763835762663930458	adf628a9a1b7ed0dd8f88dc474a4dd92b123770c	user
22615	104450763274076701017	0b6faa250e301a2af2cfab7edb69941aa3f8eec2	user
18038	110009852962409606178	e83a6915aee6ed25bbb0bf820fef403a4bb4c403	user
22960	104974498060929724022	61da242fee4cb92a52b317586e076117260cc777	user
22618	113492022217102262285	ba7c9c47db058d58094a3531e2304c403b86630c	user
22660	109487415983875666548	7dfe64a3af3a9aa034281ac7cd51f473e31a5f00	user
22852	100341754789141716230	363311dd4acbd98f321d8a383e497b3dc96bb67f	user
4906	116457314552526686941	1ecad94f4e53e202c7f7081876b25489eb3da126	user
22638	114159781783372500287	e28d26cfb0e16505f79301cd14bb077596ee6404	user
22655	106557254269091722228	519ffc7139aa795d2a9c01ed15dd41032cbb7ab7	user
23035	110686490924474524488	e4f087b785a70f9c148334b660b7ccabf57a7e60	user
22629	117116469784985259310	e5bdc16fb77030b0836cfe7af4e700da3204280d	user
22765	117267055404556932067	fae15977faf6b85c44e1f4168a011f4f3cd7a046	user
22895	117953295521680922925	60eb13c3f70ad7f6366fa660130b303816570e92	user
23643	110884617323037851906	d5a7c95bbfc570fad66e83c257739cdd25b4e335	user
23056	112641700725756825255	1b8e5d957b831447344cb3014a29ae2f0e7fdd81	user
23055	103379898408398890704	39f6b275523d6b6dd79a303972231ab757d68068	user
22525	114495091859516183950	8908f2add377d80c127bee71a7b4f54eecdd4720	user
23087	108292690118262690170	891bddfdd7422e4fb978cd7f2a664394b4b3f18c	user
23257	102189547402903864598	28df7c90bd7aa5e791d44952257f9a4aaaea191a	user
17494	116564363134490855745	db8c1b7e2f3ddad8412efe44266559ea10133a66	user
23459	113673177751333352404	200ffde9347d0d6a3c5d9e1e36ed93559998e70f	user
23662	116011204695993253377	c1e3df0c92bba3ffa4b8b8497e9c3fa616e5ff3a	user
22182	107915352569700271839	49cf79dae3478e6562cc1ee89de36a1a695ae8a0	user
22223	109352364693906201046	932110ff4e67dcfb55ea73af9bdb88c3f01c6ec6	user
1768	102540152476572591754	5b9754358395b3d26478df557704db8c27715d3d	user
24443	105194294420005024985	1d7b643d03ab3e34a5bdb627b8271387880ad01d	user
26658	115363131130228230104	c009040eacb4790e7d485b25b4c598224aa865fb	user
24520	109337807907743319459	6d3df52e611635369b1a9f3b144d2f1bd3131bb8	user
27437	113898531098001531017	2db4ce38bdf48760cee7eb8ad9250f2952ca9f6d	user
5060	109528850140803698362	19b6f72927d770b9f28bd217c98e41354026aa26	user
25073	117722541088958689814	7c0c259f5b380fef4672be04a57dc76ad24b58ac	user
28741	105129447643258192565	76544da9fb37e9c06c50c70b0e535f6038cbd07e	user
26373	107354349562927299129	d77bab0d11fcd4340b2618bb49fbf0e8e356c20a	user
28399	117522885357146815824	59602deff39f6c95c480357d8be106fef425a60a	user
25140	101106264716659583583	0cecd1f8e52073ac0f70e32d7ffef00b75493cc2	user
17027	108704163013899237434	e1dd976b3660cc056a5bbbde27d2b9614c6fcc35	user
25213	105157880401213216108	2cdd9c3e9b797db03efe420ccaed8bf9777ea875	user
9548	116759539753758122369	1abd0ec4956fdd82cfe3e2f4c359cf2082fa97a8	user
28121	115429325526115543173	45ad310bd8a8d776ea0235dda3e48a792a9dd978	user
23813	101207355282354584537	01dd3842a5e7f10d2b703682b5acd6f7636b7bfd	user
31740	100449272907606959639	10e83fab7455fd3524cd6ce38f894fc1b4b8f93c	user
24786	106382963580686831393	4609185c008d9327603a3cdaef24771d0ffd114d	user
23840	101438283653535686514	c9a5b51df78e7db893d360d87c00ea135538a3be	user
25072	116709489304696093648	4b578b0a7f5a2b43b180d244ee65d2174e746c73	user
24717	114422993971584074304	2460ab9edffa0fe17311580a9d484bd07f78c732	user
25104	110583083225141718209	041a0850b621d2699954e1d6c9508a67bc220dd0	user
26890	106260862891379060047	9dbff11aba2d18774b8e97b3f3370570731ac2b4	user
23861	114164113258062776352	7ceac2fca1f58e9e3eb96d532a842981cefd2494	user
14657	108580434982066918605	f9fd95a780ebf764bf0029c848acdc541cb6edab	user
5702	100166136587028365869	5b309baea193415b90f60d9e2810ef725b5f073c	user
23884	104682014066766388268	d8b70aa916401759495f5a7197b38c0d9bb47d63	user
5692	107827922432577522549	ccae8f4edb5961a90ae5adb8ede0b21f89f12939	user
27023	104736555837409789469	1a53a0de268858aebed9419e9fe0aa745b9d1614	user
8232	100967102642433990682	4feb1926adb2315a065bae663884cda776a8000f	user
26612	102402073813591617342	feba7fd8df4548a39e9992181547e8dadc7ea486	user
25597	103582724679949481090	f1abe8a826cec798e0908f5676625c1d09b561f8	user
27024	112049149719514009007	ba44e723df1e6db6d75502e382526f17c399ec71	user
20726	113469919102071155341	f3aa520abb1fb152721f4d372c6ee06bcccdd0b6	user
26593	112618428019925030389	f0475df083c68a8a791a9efefda00e68a33afa49	user
24945	107374093030287723532	e13908632df9888997d0276f7d11c71632ef68d3	user
27967	117666344407524188304	1a1450b16ebdea4e6357bd915ff17983e23e672d	user
25123	113169541347174262384	dcab17cec094f8f0af9ab82855cc9373c7f59885	user
24906	106378460874227252041	302c5b25ca5d88f1be4cc9edf1f45ab8ffb7708f	user
25570	105128571150899208559	8b7160f8f6bfa5dc8e7d03ee2e10b776bb3dc182	user
18516	103766762960350989371	53ca897cbe41ac0e392bf189e6903a690c5e57ea	user
15549	100506628714015360019	19fdab65902439c506445a6868da1193a1f6c3d6	user
25606	115973126818073760547	af230773a28641173f815abad6b4f161a2bd2dfb	user
25526	117021699570065796472	e553a00de90f8d7727132b7bdd922f828c138217	user
14479	109376490111650622719	80c338a7a2f380ba6018a279e4532afbe6c191d4	user
26344	100427472165562945104	761d5b2494015828788b7ee5c6b53ffaca6892ba	user
4577	104162540670104310859	4f2accb7379a3a839dd6b1fc056e5643d9d11876	user
12842	108623107305019567249	f2fc84d5fcf83cce62738b53fe76bdad96ac06ea	user
26575	112949199454355147888	353ddf91f6cda806e0a18463c436c8b9df47679e	user
7005	108551370712006348201	5bdd3e164ebcb70ad15632449208c701a6bc5242	user
25567	112964373295196225922	7ea56688afaf4b7e6fcbb81d527bcab1539e2ce2	user
27767	103681198192226683449	1aa6130248429e7368521bd740ef3eaaf617f788	user
26694	106968421421627012684	412eb41c3c1cd88fc9e87c30f07f5e890824e389	user
27144	107191617387841036716	7f1902b0fb66c1bd5351da91c3cf34192a82ddf2	user
27327	109462656671413477932	cb2e4a608d8d03a9c402e90aefd11db7da828945	user
27155	104811365561245605458	a3d5d8de1c97eddd24b24bbbe81c76d46913c19b	user
27255	109149479407133340377	e85f504b587ae0926c23829b5f0ea71f0eadb1e6	user
27052	106397610480480776616	77b758dec7beeda9e670485342a7c837f2cc5484	user
27376	105396769861562619378	65ebabff0eedd04a593b06fd9b17f57c5c0c890b	user
26866	111418050118613804064	f77801d2bfa42f8bb7d95688a1a5b05b7966d1b9	user
27356	106771827630157931759	6c9b647bacd35d4793b68aa6a93d85ac74593951	user
27285	106697543274326521115	fa515f8e5e0cbfd73945864b5ce76aea65b30c7a	user
27714	106333256045300862628	84410ffac9da3d039ede8162f621cd6a29f418ea	user
27480	105981475021868380652	f4003ec71836c9ccc445f712ea651e45d9d0ba83	user
22503	117553069435742054785	64d22317544a50bf6ee827decb15134a3a55b8d4	user
6969	114093894912804568558	78bc06ff804a696b8cd336b625e720475f72b659	user
26953	114372531126316025056	3a0ca5095eee61918d11e643f21056a55865d643	user
27798	104939767890573263935	e1c2bc11a6de4e97e73bb44583e850a69ced0b85	user
27870	115045186166643555681	0b26c8616d87ae8fbf1e70b902bb5953ebb0116c	user
27308	107302960648089981349	73aa22d6ad6f520936537c7333d2e6578833fc26	user
27926	116843335163451067244	34ec97bcabd3ab81aaabdff5a488c739f81e9ce1	user
27974	113266173583192039644	f7d58bf7ce7f505b43dceb818109dc9747e3374a	user
28034	117220098631782020186	dfec6439e80f9f138ae06ede1ef87a8f658c6409	user
28029	105471787389153334156	072a06844e9bf75df250f4cc6efe53d845621dea	user
28147	114988120529880919375	08b94d3182d2e2c714ee09a18f572fca5a60438e	user
27393	108995877968137167099	af509025558fa0c8835dde53d34418d0b9417402	user
25116	109658648941971927034	a828ca166005455ca3687fdab7c1ce6c992b7a03	user
28142	103934013085623006665	295297a80ac0d8a38cceaab5f600a5e01f05526f	user
28778	112903484933357443701	323edbf8b1809cb3ecf5155814b2a012b781ab7d	user
31289	113978798657604321179	0b3a52accf082d770c2fa8152f72cded6a41700a	user
30440	113373841263217521331	fcf6ad9212d3920d5398fefb54b5834591e19ce3	user
29789	107011537595407121485	49511e485d1da3802325e4a148f0794711bd27e8	user
29756	104568218955685711298	a22a1767a74b352b0042ca099cf5f68fc99f2d29	user
30762	107316691326563583876	c80ee124d316a19338bec0fcfcff84958b8e057c	user
28158	105429541963527635739	71e4f54c5304298e572db192c491f56191c108a3	user
30725	110631595063399051560	bc0bb41a18cb720c0a5f27d8cba8fe232a029154	user
29277	100243732331133126469	37a916d6bb75bc80b5335dcb80e757eea18d9c90	user
30464	104993826254420756174	df5d83e12ced84b05f52eff3b27cf2b0d410fb69	user
30879	100037774541223863716	15b05b18a0828d05ad668628b1fa109e0603f482	user
27361	113833084535795360196	3e07a82cd1814d56829a51b32a06d434799007f3	user
21139	107482180927586997711	842c80b9b2b5738d723de1bf27870cb5b8409c24	user
33061	114125499907159457197	9714a474e7513b648745b2774c18ab4d72b85008	user
30599	105641726480696282068	000a248c4c337808637831c7d8364f152943e052	user
31482	112287264203593620364	ef16887b28878d35be98bc6f23563d814d2f9d63	user
29373	108745443239295634264	a3787e20e2a61049fb2200199f7f36b0f38a5ea7	user
29284	100296111466514776944	09eb7188ae8f856193bb3ce349bbd6849fdc6d37	user
29034	108499776031400240541	6a96ac1a6ab1c479eb7675622ff94cb984056012	user
28909	111444722576795034356	d72603e82ddada093146f35d5b7ff75b5f1a9846	user
7048	106053419849481655127	c3d1a19654aa2e98ec00d8e0540af744e83eac6f	user
28898	116542312738324327668	62d0b479907dda8eff066824502eb2c408184650	user
15060	105969740549441975949	4bda1a81a8f6c9732ff180bce84fa02e26a3d80d	user
29045	103694818377194007378	f1d0715555ae12f6b0c2ef3ee023657e1da8cde8	user
29152	109373480618194925149	4bdb684128b0f8542a1b0b3be4a4c6b69d1e06f1	user
29800	114525950068404793740	403f76d5654b2f001642266e8789130bbda992aa	user
29879	109743691959278449583	3f95467d3258746db3a6debb4b83f93cf6e0f2f6	user
19360	117615406391981290590	b543793b472010305d84126041c108ae0f6d9039	user
29092	107872733361138175010	85dd60800c1c57e30c67b1ef27118f34e516f815	user
30429	101387875457663094752	0672e54bae8a6769f521406f210ea228d22b5926	user
29229	102591162228450335149	17dde1eb2fc7bc29db72c0f6c854eb193425cc73	user
29570	100868456227333581488	ace00a90a95a11c33bc17f1021dd9efdb72fb652	user
29188	105554845638346109132	445662554aadb164fa183734163fff1abd61aca1	user
29117	104256975787115165957	5f41a47467142991a26987eecdb9864eafc56d82	user
30712	111402924341024612788	33a9fed9ab6729663d383a11c7890334a63a0297	user
30355	101117154862776106863	a2826424c0e4b571221390d5de856630768c9613	user
29185	104453942492243173593	490130113610cc2543be7972a70633c672406739	user
16579	101798089697138461999	7ca6f2f620e49ce039fdcf0e02cb40c473fdb327	user
29933	100286415691765663285	c5fffc3ada2bccfc8bb006e8628fefcf33ee506a	user
29054	101450182798146604393	118172e021354c5ca6521773a97444daacb09d5e	user
5263	106447284908872676152	80459319739271669191ed83de83e4694372e594	user
30447	109519412055323157832	f6dca397329f4350bf7810f37efa6a5c9f17c617	user
29882	108516706940208226941	cfb6ed126df6ffe40e0c504e18bcbbd629908926	user
29952	109380325252415730229	83161d96854b53120b595fe1604d31b91e7ce60e	user
30598	114705015611565927812	389b8bbcc071951c8a62cf0cc532e9627ca5a362	user
18310	114298599139971688237	298c2dc3be3574f01b90bc51aa177e006dfd06f5	user
30188	115819299473070317876	2079eb29ca25561728ee8a3e52a102494914d68c	user
7361	115801243251886489865	f65d0cc3e658d7820d421c8aa484b8c81e71b977	user
30320	115378101767185398982	0a025461d1b1bbcc16475d2fad4a23b1e8120200	user
30130	113963390817630213542	88afcb2612c1efe934af2b7cdced22ba7c8cf03c	user
30178	110674105699847080840	19a0ca2ad7fdb216791923ced4fa7f485802ae58	user
30404	113888245761012053183	a33acfcf62e648f215c851f14450d194650c558f	user
30354	111063540894847667512	45e12f96d8d91d45cfbb798976f1c02fedf1a065	user
31272	100426036979229502939	1b235b29c88d35855c863f41205ea38054acffae	user
30728	101981507199442917246	cef25d4d1a16c0d83b2dd0dbfffcb9ef8dbbc4aa	user
30497	110547291697641871185	aba4fcd4611417541c8c71b719e2991bd7f63534	user
31005	105035077380299958583	266bba7f51cd38fc2db8d2ef6bf7e8e53107c68f	user
12044	114564795634879121831	ff3275d09ab709aaf81be732ef41b2804353851a	user
30679	101305269674174084117	17adfad4cdf76a8c6dbda282e724f8a93ee0e62b	user
30830	103207216063002712121	1929e29139557b5b489a8e1308220dd22434b2a5	user
30823	114227557694963116135	509225c21517c23c70419a31131eef5d0d97f2f4	user
30932	115958018513124626982	2aa8ed35a761b9d7314a52f165a174f8507327c9	user
30892	110739697356936056700	922ea7f576a997ac36f284b0af238801487c639d	user
30794	110177970648727277741	2b434db18685d40418825ea817a2ada59ae60c0e	user
31290	104721656847829616857	d67cca7667767ea7a0564aa2f624b504c807292d	user
31387	116107742058190876844	5985b2caf75ee63954c6ff6a8f2b84050d8bdf70	user
30743	114068218062917305811	5321f14e825cce4509ea5eea3452616c37207894	user
31390	103933336112421689610	1fe674010154a34d559ab507000a1cd58c7c68d2	user
31422	109618915614330966312	9288f02d6a8f70c4876c17da0c77d7b820994252	user
31417	114817523383876433918	3fe85bd8785321c0431be16cb95476853bc235cc	user
31437	112505714881529466921	cd593290bd7000168297c2081361726964e02464	user
31447	109507225878783702985	917d798f395715ff9082a4bd4f49e07a6e94088a	user
31446	116239684292494076893	ac8d17c74e6446963a537968ee97be33af59188d	user
31460	100012191509507254635	bb3a3001267a87eec0739691d90a1332ad85c2b0	user
32171	109932093479652910983	9afb281b61c5558e69fc11c880f0b6aac2c714ba	user
31481	113934733771700894590	5f0fcd07301b0c586a7c45379e6d11767937a201	user
31949	106719939357621846168	9f928ac93d8594d902e3a93ef69922d36d0ead9b	user
32217	118403157346615964994	a02d739ad55e2cb6cf6c0e21b3f1a3d1da36a544	user
32222	114263084990181004463	f7369bbfb4479f4a2ac73f6993e1b4ad935eabb9	user
31901	102191701944784594793	335562d320c1f6cd3e2f88dcc460598f4c52e9f7	user
32941	113912321613751055552	11cff24ec794d1e6acb996b4226da56be614ad6d	user
32231	108611939221151782017	90a64d612642a0191bb1ea3631a072295b390c4d	user
32616	115893466469162485501	837159f1781ea2b694cea52cb3214900e16102eb	user
33159	116990118273206494266	f785b765c4bee8b489085614959150712a46cae2	user
32647	108036690488109078326	ec0c8d3a9da4d1d00378210c0601b6efa4fd70f6	user
32196	101051984663811579290	997c82bf6b4cf24aaf0dc439da4f2900ae67710f	user
31769	100903650956250637024	4736902aba4963eaed418b0769cb8aa09339dc47	user
32234	103384854572338898390	d09c039f7b1ca835b8fb09924b62b2a75b6ea94a	user
33277	112311651424196547257	0a83800acb2f94b3138923776b2092761a618661	user
29471	109415117240233735834	e21c29e4490fc00b77c6556937c1411659266f43	user
33288	101061940570555323156	0d7bc753dd27a51fa25a57e119a6f04f67bde23f	user
32056	105384267813869488602	28e00be665425efed96b6e6116420a1eb6ae769a	user
32936	103246051290396859124	a88ca1cf3cfab92275c7ea0a21873cd2061c5cb1	user
31832	110908060872101561853	2e7c7ce6039f8795db6dbf717fe27a7123a6cdd2	user
33305	102009742594823010660	b00d5dbbe06138262bacc00d0b1f5d0c3f5679d5	user
31458	110741549368883137465	227d427afcb781ed49ab3ea0c51af0f96838d0b4	user
31710	114186203002331939794	f57bd451c947a8b252d39dcc59736513ce46912a	user
32582	102350455221991151858	76f39657b75ddd5c2161f0ae61b00c63d8a1c3a2	user
32128	117074336345478983632	221bf7281eb86cfbbf8a02e76aa0c33cd784c0ee	user
31859	104918609758142636078	de6589bfc1769a828ba52084de932741bfe2f25b	user
33042	100622507197575721798	9e52fa2cd2925ba5a5b6d662e66a5cce129aa228	user
32157	103160522592401353055	ab6743c838aa1ad52e5d62d14e4f53f4dfbd2814	user
33068	111667440765596819119	f93fd85279217095bd273b695706114a9e6a5295	user
32665	114193926166367007704	91027eba0444b9d569d0868e56e5a42e152940e4	user
32710	110258860955993442540	ff1d152d48a85d0c35818a4705d2662d50ed321d	user
32722	114957683442917804408	2412afe180f8e3e56617be7fa51de7de2982c159	user
32392	101207118991399661302	aee6f03b50a68496f07071da83aa4cfc5cc8c8e4	user
31483	116481189120918940278	8cc8f46ee0dca7163b5af89f65c4fd2af9b1ea6b	user
32571	102360546003990525254	4cfbcd054d7cc93856ac86fbcf8c674a881d1ef3	user
31868	100524604573790733663	29992745edf99040e7efcafd6e1651c5f02b15f3	user
32043	112003487079351151254	439ebbbc1b2218579a42dc494b6dd4c0de7e45c8	user
31459	117781477599627077599	4be60af582e49235094dc3050bf8c69c3581524c	user
32741	116964737184564653833	755de5898014e43505c712edd5d50e181b7d4007	user
32690	110440598782266049609	faa52089cdac360f03b8a95fcb7e83dce0d9509e	user
32166	110709070786638999738	52b8e84db7e70b526895384a5bcb70b37f5715b9	user
31939	107788240121980522888	16fe04bbf3b80eb99df1147f011e9561821b35fb	user
33148	111028326981029209404	a52dcb0ea332cfebec30cefad5cbfa8af029356b	user
31938	101977943695203459345	aa52d7202e0441de1e5d976c715e8fcd07cce459	user
32656	109259502533616809707	34f6449ac2be32ba70066708aee45c31135c88b2	user
31940	103489347539476665655	78be7f5631fe3142d287b305c00355900b5f6562	user
32553	118235247777358642097	3545653d54c86a7357a7b82b7bc502f48559f70e	user
15228	101052838935126041501	e1ade30959d6437cd45c078b387ea0f8eaf145fe	user
32009	108034461483395868632	3a6c558ad27b7fd6b63f8be0dd4efeb53b602840	user
31869	113427824936637840996	72019780aeb251e652c4d7e22b54c343e6fb5208	user
31870	101203371747531185357	cdb4d3b55bf4ba4f510ad8162d3a6070e1f5275c	user
32022	105368299530436984082	5287eb8b3534a8fe793361bf3804bf4a637a76a1	user
31701	117599913019367044159	4db7406eb59158e4835c5459616d567ef30c79d4	user
32261	102337752411335677874	73a77613ed76837b47ad3886dcff9361637a9019	user
32566	113351528543477790115	7e3557834284c6428f63ede00b97bd6020ff2ecb	user
32869	104706326988907598783	e8081679a418d03bde8cc216f55f3a9130344ba5	user
\.


--
-- Data for Name: startup_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_details (id, startup_name, about, website, logo_url, user_h_id, is_verified, poc_name, contact_number, email_id) FROM stdin;
260	Cos-X 	Singapore based tech start-up with development and business operations in India.	www.cos-x.com	https://i.ibb.co/zPq1mZS/Capture.png	101107640131204357570	t	Lalitha	8008032033	hrexpert@cos-x.com
225	Wishup	The job market is changing rapidly. We believe that Remote Working is the future! Wishup provides trained virtual employees to the very talented new-age entrepreneurs and SME owners globally. Read more about us at www.wishup.co	https://www.wishup.co/	https://www.wishup.co/categories/img/wishup-footer.png	104298758991766668035	t	Vivek Gupta	8447754003	vivek@wishup.co
228	automaxis	For the issue of paper based document handling in cross border trade, automaxis is a blockchain enable document digitization platform that gives a time & cost benefit along with creating a tamper proof environment. We have initiated a pilot with a Pharma exporter that exports to 53 countries.	http://www.autom-axis.com	http://autom-axis.com/wp-content/uploads/2017/05/cropped-cropped-automaxis-logo-400281-2.png	101818747050100224079	t	Block chain pilot for doc. digitisation	8688745584	pratik@autom-axis.com
231	Srjna	SRJNA is a hybrid education model using real & virtual teaching aids to impart 5D classroom experiential learning and smart online assessment platform with deep analytics for K-10 students, teachers and parents. \n\nWe believe that 'True learning comes when it's being experienced', to ensure this we continuously build teaching aids & methodologies and provide to associated schools. SRJNA, a brand of Elation Edtech Pvt Ltd, Initiated by 4 alumni of IITs and XLRI is now a team of 15 enthusiasts who want to make a disruptive change in school education. \n\nSeed funded by Rajasthan Angel Investor Network, SRJNA has been incubated at Startup Oasis, mentored by CIIE-IIM Ahmedabad, University of California - Berkely and recognized by IITs, IIMs, XLRI, Department of Science and Technology (DST) and Rajasthan Education Initiative (REI). We have empowered 25000+ students , 500+ teachers and 80+ schools in Delhi NCR, Rajasthan, Punjab, Haryana & Gujrat.	https://www.srjna.com/	https://www.srjna.com/assets/img/home/logoblack.png	102476915533780948091	t	Nikita Panchal	6377719749	hr@srjna.com
233	RentSher	RentSher is India and UAE’s only Omnichannel Rental Concierge Service for Rental products related to Events, Electronics, A/V and Medical needs.  While \nRentSher started as a peer to peer rental marketplace, overtime we shifted focus to a vendor led model enabling rental businesses to list their products and receive orders through our platform. With a mission of “Renting Made Easy”, we provide a one-stop-shop for rentals with easy discoverability, full transparency and end to end service including doorstep delivery. RentSher has made renting products as easy as booking a bus or a movie ticket - whether its a 1 day or multi-month rental. \n Our India operations hub is Bangalore and the UAE ops are run from Dubai. The tech development, digital and marketing functions are centralized at Bangalore for both countries. \n \nToday, 700 vendors across 10 cities in the two countries provide rental products and services through RentSher.\nOver 100 SMEs and startups and more than 60,000 customers have made use of RentSher’s services. This year alone we have provided rentals for more than 3000 events. 	www.rentsher.com, www.rentsher.ae	https://web_rentsher_india.gumlet.com/images/rent-sher-logo.svg?format=auto&compress=true	115802938042318956916	t	Anubha Verma	8861677739	anubha@rentsher.com
229	Karexpert Technologies Private Limited 	Karexpert Technologies Pvt. Ltd. is a ''Digital Healthcare Technology Platform'' intent to provide services in top 100 cities of India. KareXpert is a Pioneer in designing technology platform with a Patient centric approach to make “Patient Continuity” a reality in Indian Healthcare. We are the only technology Company to design patented “Advanced Health Cloud Technology Stack” which connects Patients with all the care Providers -Hospitals, Nursing homes, Clinics, Doctors, Pharmacy shops, Diagnostic labs, Imaging Center, Blood Bank, Organ Bank, and Ambulance. Our Innovative Solutions are compatible to run on any Smart device-Mobile, Tablet, Laptop, Desktop via Mobile App & Web App.KareXpert Working CultureIt’s important to cultivate a positive company culture, so here in Karexpert you have a freedom to think and express your ideas. Karexpert is the best place to learn and give a drastic growth to your skills set. We beleive in continuous learning and improving environment.	www.karexpert.com	https://dhs.karexpert.com/dhs/wp-content/uploads/2018/11/Kx_logo.png	106407488023143571708	t	Pooja	9882065886	pooja.chaudhary@karexpert.com
201	Addverb Technologies Pvt Ltd	Addverb Technologies provides Robotic Integration, Warehouse Automation & Industrial IoT solutions by leveraging Industry 4.0 technologies. Our extensive experience in the field of intralogistics automation enables us to design the best solution based on the requirement of our customers. We provide customizable, modular, robust and innovative solutions to cater to the needs of an increasingly digital supply chain. We deliver the modern warehouses of the future, Today.	https://www.addverb.in/	https://www.addverb.in/images/logo.png	106123538173898449055	t	Ankita Modi	9717228691	ankita.modi@addverb.in
238	ION Energy INC	Our planet is going through a fundamental shift away from fossil fuels. ION Energy's mission is to accelerate this shift by building cutting-edge energy storage products and services. Founded by a team of PhD Engineers from Stanford, Penn State and IIT with decades of experience in advanced electronics and battery systems, our groundbreaking patented technology acts as the core of high performance applications like Electric Vehicles, Telecom Towers, Data centres & More.Our cutting-edge BMS capabilities bundled with proprietary software & cloud analytics platforms drastically improves battery performance & enables real-time fleet management.We are looking to build deep meaningful partnerships with high-growth potential companies to help them become industry leaders in the inevitably growing Li-ION battery market. 	https://www.ionenergy.co/	https://www.ionenergy.co/wp-content/uploads/2018/05/IONlogo_250.png	117013339697530495306	t	Valentina Dsouza	9945328921	valentina@ionenergy.co
232	ScrapKaroCash	“ScrapKaroCash” is a scrap facilitator and scrap procurer service under waste management Clean Technology where customers will not only get an option to sell their scrap but also redeem coupons; inspired by Digital India, SBM (Swachh Bharat Mission)It’s working on listed domains:-1- B2C 2- B2B 3- Trade4- Compost.5- SBM.As of now we’ve lifted more than 150mT of scrap having 150+ active & Key clients.Recognition and Achievements made by this startup till today’s date are mentioned below :-1- IMPORT EXPORT LICENSE IEC- AAHCC0310R2- Attended as a Delegate in INDIA- ITALY technology summit valedictory session held by Indian PM Honourable Shri Narendra Modi and Italy PM Dr. H. E. Conte at Hotel Taj, New Delhi, 29-30 October, 2018.3- Invited for a summit held in Moscow with Indian, Russian embassies at 10-14 December, 20184- BITS PILANI shortlisted all over India, top 50 startups.5-  Invited by PM Honourable Shri               Narendra Modi for video conferencing  live broadcasted on 06 June, 2018 at DD  News.6- MINISTRY OF CORPORATE AFFAIRS     CIN- U74999UP2017PTC0937317- Shortlisted  in IIM Lucknow at UP Startup Conclave 8-MINISTRY OF COMMERCE & INDUSTRY (DIPP8978)9- Article published on Dainik Jagran Lucknow, 16th September,201810-Letter of Recommendation by Indian Army MAJ. Gen. K.N. Mirji.11- GSTIN (09AAHCC0310R1ZJ)12- Avail the benefits of MUDRA in the form of CC.13-Letter of Recommendation by KLS GIT, PRINCIPAL.14- Shortlisted for annual business plan competition organised by IIM, Lucknow.	https://www.scrapkarocash.com	https://www.scrapkarocash.com/wp-content/uploads/2018/05/cropped-WhatsApp-Image-2018-05-24-at-17.23.07-1.jpeg	110447218383396106962	t	Manvendra Pratap Singh	9480494001	manvendra@scrapkarocash.com
304	SMART ENERGY MONITORING CONTROLLING SYSTEM	The present system of energy metering as well as billing in India uses electromechanical and somewhere digital energy meter.\nThere are major problems in existing system like\n•\tIt consumes more time and labour\n•\tOne of the prime reasons is the traditional billing\n•\tA system which is inaccurate.\n•\tMany times, slow, costly, and lack in flexibility as well as reliability.\nWhile our innovation gives real power consumption as well as accurate billing. It provides real time monitoring & Controlling of electricity uses. It is less time consuming and cost effective.\nAn electricity meter or energy meter is a device that measures the amount of electric energy consumed by a residence, business, or an electrically powered device. But sometimes the limited functionality of these meters restricts their area of application; especially in inaccessible positions or in the area. A possible solution is a SMART ENERGY MONITORING & CONTROLLING SYSTEM which is able to send its data via wireless communication to a PC or a remote device where monitoring and analysis of the data will be easily made. This measurement system is aimed to be used in measuring energy related quantities such as units consumed, consumed power, active load etc.	https://youtu.be/MWlzEiZHgWk	https://youtu.be/sF0k3qfWXik	103723685173753170428	t	Aliraza Merchant	8200344234	mysmartsystem44@gmail.com
230	White Data Systems India Private Limited 	White Data Systems India Private Limited (WDSI) is a private limited company, incorporated in April 2015, which seeks to improve reliability and Quality of service through innovative and integrated technology solutions to the Road Freight & Transport Sector through its i-Loads platform.  WDSI provides a holistic and comprehensive range of services, providing tangible benefits to truck operators, booking agents, brokers and load providers at an optimal price. Being a TVS Logistics subsidiary and having cholamandalam as our investor provides us the expertise to deliver at a superior quality to our clients and also grow at a higher pace.	www.iloads.in	https://www.iloads.in/Images/home/logo.png	110505594872527456493	t	chitra	9940158710	chitra.c@iloads.in
234	iB Hubs	B Hubs is a PAN India startup hub which provides end-to-end assistance to startups. We are working towards nurturing a culture of innovation and entrepreneurship in every nook and corner of India. Till date, iB Hubs has supported more than 100 startups across India. iB Hubs is an initiative of iB Group - a vibrant team of 200+ individuals, majorly comprising of alumni of premier institutions like IIMs, IITs, NITs and BITS and corporate alumni of major MNCs. iB Hubs regularly offers internships/jobs to students from premier national institutes like IITs, IIITs, NITs, BITS etc in various domains like Cyber Security, IoT, Software Development, Management, etc.. 	ibhubs.co	https://d1ov0p6puz91hu.cloudfront.net/logos/iBhubs_logo.svg	105373738578694994605	t	Sowmya Bezawada	8008900903	hr@ibhubs.co
235	ProYuga Advanced Technologies Limited	ProYuga Advanced Technologies Ltd. develops transformative products in Virtual, Augmented and Mixed Reality.ProYuga has launched its first product iB Cricket, a new format of cricket, in the presence of Shri Ram Nath Kovind, Hon'ble President. iB Cricket is a vSport which provides the world's most immersive Virtual Reality cricket experience.iB Cricket is developed by a team of young graduates from premier institutes like IITs, IIMs, IIIT Hyderabad, etc. For more details, visit our website.	proyuga.tech	https://s3-ap-southeast-1.amazonaws.com/ibhubs-media-files/iBHubs+_+Startups/proyuga.svg	102540152476572591754	t	Sowmya Bezawada	8008900903	hr@proyuga.tech
285	Invention Labs Engineering Products Pvt. Ltd	At Invention Labs, we build technology products that enable and empower people with disabilities and their caregivers. Founded by an IIT Madras alum, we work out of the IIT Madras Research Park. We are a dedicated team of passionate social entrepreneurs who love our work because we are improving the lives of people with disabilities using cutting edge technology.Our flagship product is Avaz - a picture and text based communication app that helpschildren with autism communicate. Used by thousands of children around the world, it has won numerous prestigious awards, including the National Award from the President of India and the MIT TR35 from MIT. It was also the subject of a TED talk.	www.avazapp.com	https://www.nayi-disha.org/sites/default/files/photos/Avaz%20icon.png	105500817840272313799	t	Narayanan	9566095596	narayananr@avazapp.com
243	Vidyukta Technology Solutions Pvt Ltd	Vidyukta Technology Solutions is founded by IITM alumni, to develop products using new ideas in Deep Learning.		https://www.solidbackgrounds.com/images/1920x1080/1920x1080-white-solid-color-background.jpg	108825759819157028428	t	Sirish Somanchi	9849309056	sirishks@yahoo.com
305	Skcript 	Skcript is a five year old start-up with major work in the consulting line and a few products housed in. The Skcripters are a bunch of some of the smartest people who are working on technologies like Blockchain, AI, ML, RPA, Mobility and Web platforms. 	https://www.skcript.com	https://drive.google.com/drive/folders/1BSxhAzfRl58HQcqFPAcxEuDM2FurVIr0?usp=sharing	114628427311007654470	t	Skcript	7448333043	pankaj@skcript.com
236	Involve Learning Solutions	Involve is an international award winning social start-up founded by young leaders from IIT Madras. We are working to develop future ready skills in school students via Peer teaching. Our clients range from International schools to the corporation of Chennai. We are currently working in Chennai and Bangalore & are supported by Singapore international Foundation, US consulate, & Northwestern University.	www.involveedu.com	http://www.involveedu.com/logopng.png	113564221505157815723	t	Divanshu Kumar	9087864370	divanshu@involveedu.com
268	WELLNESYS TECHNOLOGIES PRIVATE LIMITED	At Wellnesys,  our focus is on building innovative systems and intelligent solutions for tracking and delivering holistic wellness of individual.  We unify the best of Ancient sciences(Yoga, Ayurveda, Accupressure, Naturopathy) and Modern technology (IoT, AI, Edge Computing) to create world-class products. Wellness is a stepping stone for reaching one's highest potential. Our Vision is to make holistic wellness accessible for everyone and integrate as part of their lifestyle.	www.wellnesys.com	http://www.wellnesys.com/img/wallnesyslogo.png	101907162894505620447	t	Muralidhar	9611922116	muralidhars@wellnesys.com
237	Voylla Fashion Pvt Ltd	Website: www.voylla.comCompany Profile:Voylla is India's leading fashion jewellery brand. In a short span, Voylla has created a niche in the lifestyle segment with a strong omnichannel presence. With a stronghold on manufacturing fashion jewelry, use of the state if the art technology, Voylla is on its way to create history by traversing a territory yet unchartedThe costume jewelry (also known as Imitation jewelry and fashion jewelry) category operates in what could be the most fragmented market. The competition can well and truly get down to the ubiquitous roadside vendor. Hence, it genuinely offers challenge and opportunity as two sides of the same coin. This category has existed for ages but curiously it doesn’t boast of a single brand worth its logo, at least till today.In the last four years, we have made sustained efforts to understand the customer; set up a robust back-end supported by technology with an edge and finely detailed curating. This shows in our repertoire of over 13,000 designs on our site, which gets refreshed with almost new 1,000 designs every week. Over 5 lakh customers have patronized us, making us the top jewelry site in the country.With 200+ existing stores we are now all set to come closer to you where you can touch and feel every piece of jewelry before buying them. This is just another step towards providing you a 360-degree, omnichannel experience. With a highly competent management team consisting of top business school, fashion and technology institute alumnus (IIT, NIT, NIFT,etc.) and e-retail company veterans, we aim to create a great lifestyle experience for our esteemed customersVoylla is leading this exciting journey as a category leader and is on its way to build an aspirational and a durable brand, which will stand for value, quality and irresistible choices. Your valuable response will be awaited.Regards	Website: www.voylla.com	https://media.voylla.com/fit-in/240x105/voylla--logo-24-12-2018.png	111133250649424423782	t	Rahul Joshi	9982205733	rahul.joshi@voylla.com
244	Gramophone	At Gramophone we strive to create a difference in farming by bringing timely information, technology and right kind of inputs to achieve better yields for farmers. Our endeavour is to bring the best products and knowledge to the farmers. Gramophone is one stop solution for all kinds of inputs for the farmers. Farmers can buy genuine crop protection, crop nutrition, seeds, implements and agri hardware at their doorstep.\n\nWe believe that technology can remove information asymmetry in the agriculture system. Farmers can access localised package of practice, crop advisory, weather information coupled with the best products to grow. This will improve the productivity and help farmers sustainably increase the income from agriculture.	www.gramophone.in	http://www.gramophone.in/images/gramophone_logo.png	114503787094540282981	t	Drusilla Pereira	9535104208	drusilla@gramophone.co.in
250	Mammoth Analytics	Mammoth is a cloud-based, self serve data management platform focused on the complete data journey from sourcing to insights - with a special focus on data wrangling. \nOur goal is to make data accessible to the non-technical user in a way that any overheads of dealing with data are eliminated.\nOur engineering team is based in Bangalore and regularly deals with matters of solid engineering design, scale, and usability. By interning with Mammoth you would experience this whole process in a very cozy startup setting.	https://mammoth.io/	https://mammoth.io/wp-content/themes/mammoth_wp_theme/images/mammoth-logo.svg	100916162979211575903	t	Pankaj Ratan Lal	9164604660	pankaj@mammoth.io
253	Eduvanz Financing Private Limited	Eduvanz is a new age Digital Finance Company that provides Education Loans starting from Zero Interest for Students and Skill Seekers.\n\nEduvanz was founded to offer convenient and flexible financial assistance to Students and Leaders who want Quick Results, Attractive Benefits and Transparent Conversations.\n	www.eduvanz.com	https://eduvanz.com/assets/webimages/logo.png	107429974676687296166	t	Bikash Behera	9769480264	bikash.behera@eduvanz.com
245	EngineerBabu IT Services Private Limited	At EngineerBabu, we offer an expansive suite of cutting-edge IT services to improve your business processes by seamlessly integrating new technology with your existing systems.Our services have enabled visionary global giants like Tata Steel and Samsung in building diverse and customized technologies. An in depth analysis of your needs and requirements help us built professional products.	www.engineerbabu.com	https://www.engineerbabu.com/assets/home/logo_purple_80.png	101326090802695787002	t	Anjali Mishra Tiwari	7415182268	hr@ebabu.co
249	Stanza Living	Stanza Living is a technology-enabled student co-living concept which is disrupting the multi-billion-dollar student housing market by putting the student, as a consumer, at the heart of the product and service design, development and execution. From smart space planning in rooms to gamifying food (cutting edge Food-as-a-Service concepts), from creating common areas for engagement and community living to deliver reliable, predictable and standardized services to residents through back-end technology integration, Stanza is challenging the status quo when it comes to student community living. For the first time, we are making student accommodation an experience product in line with evolved hospitality areas like hotels, guest houses and serviced apartments.	http://www.stanzaliving.com	https://d1ksfjvcjhdtdf.cloudfront.net/images/stanza-logo.svg	115375476385745576962	t	Vibhor Kumar	9999445431	vibhor.kumar@stanzaliving.com
251	AllEvents.in	AllEvents.in is the world's largest event discovery platform with more than 200 million events from over 30,000 cities of the world.Uniquely harnessing the power of social media, AllEvents.in collects, sorts, categorizes and systematically displays information related to events based on a user’s selected geolocation. The platform presents event information in a manner that facilitates simple discovery. AllEvents.in is the connecting bridge between Organizers and Event Attendees. We are changing how people discover events, how organizers find their potential audience & how they both engage with each other. 	https://allevents.in	http://gigacon.org/wp-content/uploads/2016/10/allevents.in_.png	109249031263145344654	t	Chandresh Vaghanani	+917698993837	chandresh@allevents.in
252	BackBuckle.io	BackBuckle.io enables you to build/enhance/innovate/prototype/experiment your app at 10X time faster and at 12X time reduced cost, saving 30000+ development time. BackBuckle.io, which is a Feature-as-a-Service (FaaS) cloud platform which provides a suite of ready-to-use features and functionalities to1. Instantly add features/build functionalities to an existing or new App(Mobile/Web/IoT) with just a few API calls!2. Build the entire backend of an app in record time.3. Quick prototyping of new features for the app.4. Dynamically control the total behavior (UI, Data & Logic) of your client's apps making it custom fit your client's users. 5. Rapid experimentationsBackBuckle.io is the winner of Elevate-X 2018 by IIT Madras	https://backbuckle.io	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAATUAAACjCAMAAADciXncAAAAhFBMVEUAAAD////MzMyZmZn19fVqamqrq6uenp7W1tY+Pj7AwMCmpqbr6+sfHx8qKirh4eE3NzfT09NISEjy8vK4uLj5+fmGhobd3d1SUlLo6Ohvb2/IyMiQkJAZGRmvr69QUFB5eXk6OjpgYGCLi4sODg5sbGwmJiZaWlp+fn4WFhYxMTELCwvvp13dAAARc0lEQVR4nO2d6YKyNhSGFTdEFBEBRURERx3n/u+vJGxZTiAooLR9f3ydKutjSM6WMBj8dzUaMpp8+or6oP+pvaKmqF2PWL+/1+vfX7OX+IVqhFq0dcfJ3rZtWfreMFzVVJSDpm232yDWYuZfnNCb3Heb+fP22/hddK0mqCnsMSRl6YZrxmy3wXQxm41833ceoechuptb87faoBqgdngRWpnssWUps0e0bOGWG9D71O5NwtL3e90a2/kHe9M/feED/T61aYPUdFVbePPzznMWSo7OCNZt3Pk7ep+a2SC1RLayiOIDLx+Bm36iPlq49Tf0PrVXx4IKmT5qYUc//VGsSws3/7K+llrc5MwQDQabqY7/1/gi+/uLqcXaz1bxGVajxBrcHlsA8JK+m1rc4BbI01gmQ85+0wKBV/Tt1GJuPjrL3Hjt6trR91OLezTcxBb47+8YTPtAbTgcoRM52IILmybwivpBbXhAo6mHsNn3FijUVU+oDQ00mEboL70FCnXVF2pDGxm9P+ivQ9nVXE/eaBFoB9M1ULxK0YLFZVfPYnmGs8VWUeMDuPHus3DOb9IbakMLjQnYAongm/3xA9W2wX314PGUupnTReGPYLuLkI5cyVC7TBeMAq97asM9am3IM3W5YPHc0fZW+d6WUtke1o4LQ0e7mw8ihiBBbcEfQyHQd0ZtaA7Srs1jL1GT2t8t5XZcVHA361Cb8ftr5PfdURsG8em28X9V9hq3kgfQxCmNi7CZZXJrUOM2YKB1SQ01sjO6O9b6kKU2tHYws41bvS/xW1VRA1ralN5ClpqNotqxdKR9LD2VZY0FnTincUpo8Sq1oQ0OJaHM+eWpAX3aiDkjSW06G438i/MIQ8/7mUwipHt03+1Op81mM0c6r2M9V7HWmebzzea0292jiefMDqXdeozrFP9n/zK1xIJhBDxPgKSpAdB89pQkNeh3rK3VZGQILz2+533c5hgbqga1ocGd0JfbUZYaAM3hzklSaywAthFx2A4GAX8ZdahxD4sjuZ8kNaBPC/kbJKk1mIhbwf2lvcHGx4zeuBY1mzZ4I9n95KjxLQ3sSluiBrb0Ie7Z4n8VetOC2l49zByU49/sonB2AM1WCvlRF2KKRy9ydylq/EWPwXADSa3ZjHkA3UrsvOucC59Qsw7OfcUcYzPiqezJjgQ8ydA2Rt49Hr5OkTdzLXlqADQ4/twetYEK3dAP9gToDRE1jfMYEl35x/en+PYMQptSt/p0TElqALQzfFUkNfaXflMb6PkKcH9Lb6jZo6v4MFxzIixOyBcz+R9/c5Chxg8Euiho0CI18PEZY0uB3k5g8Wfas/eSf3MGTjAFj7FRCZMFpsa3NFcIhKQmF46R1xy4qeH5wVGrEGuQjfPGBJRbBIKD/BHWBUiNPxbQaDO1SQ101xwv/qfkgeTFGRcZgCtvTpulR0oFUQOglZQ/kjfWeBkLZIEGk2FNG2czZg6RlT8A9VBSKVeAGv94KmVHaJXaAKBmoqZTqwddsa5t5h5c+J9E6oActYiHti09AklNMMy+IcgjRdTEfcF58vBngXZQzFxcGChjw3cAcn0MR423kdiwDCPyzEBi4k1Bo6glOtMt8lWdfRohZe2AHVzJyGOZqoMks4ojtEuNf4YSAd3PZstBECmNqz65oBRsdXCqpFYFrWVqovrVE7dhnerDtKPecVZ0KHdVVdTYsAovklrzNT9XwXUxdu2yXkl1Ss3jvpDsmCuohdVHaJfaQBCbpqMvm4r0koDag/tC8qLKqZWPnolapiYI61IhZ/5J+yg1Pt7Nq2VqgkePDHCsxSGycmq8DS15UVX9WnURMUmN66PfFxz/GoaCK6hFra22JlFm1zI1wQUSlxXWhtY+tWFYcQSSWkXE5hUJEkhEugVKABva5b45P1Pd2cEipcbzlgw/SKQCw/IjtExNYOYWHe6G/1KN6GTZXEDtzo0iPwMpcdSA4SgsPQJJrYU6RkHerbAj+d+d88C5mEdKbc0ZLBXeo/CcI8D0EUTkE7VMTdBrFS4LN8jyVYGcZZIFcTgXrDS6U4iPeQAtXlBnl6hlarz9jlU0CvZXtnnzhztGBocPVcjF7YD4GuT6lWBT5DZ7VZMqauw3QNiCu0lF9IWEBwnuN4EfCjGPD1P7Y78BQticf5FR4/PullS4E8wbAD3wWAikZWqCgoI8pHMTESm04/bOtrnxsSUZJ1KQowKMpLHIqlDYnZtVbWpcISUwgzUnC6RD+fqfVEQYTJAPhWxLQfCsZWq8TYWVWxfcE8olboEnJ6d2Ag4NY/sNKvOhYGkKMDghtd3WKqjx+Rgm4gA11uIphmKZgNF2dXSpulyguMkC3UySmqRpXUeCJ7TofriAx5i6TLB4tKAGDjauR69QcPZR/ydVUwQ88jrU2khqpebwaxKMoQU1/jqtYlD6gyvbiBEDDpzvt1Gapz5G03QTufo1IACjAwnPlqn9VFGDHFXTP8We6PkhqgYkqK0Fm6C73VM1wpK1kkAhlMVXLpC/dQvUBL5BUb3/K75toUjrhA8XCSRblwtEn/nSInLcCBuHJvJDiTkPtcpLE1E2nSDuyUmW2hJIMBrsQ0o2hrBpZsKmQLjoYJUbpakgUpRKbj6RfOX8GYjIszVZZ+Kim8+HiiJF5H3DBbyFNC5bzPgPciF0+VkaXGRqyLvHxU81bpRXIglqFXftCqOSuaRWDaoxI2gONH9mZkkRWpKM6dWSIJZL+ehL8awOfLOV1AahREK1BjXA9Y33p2vusu5U4Dy8J0HegPY2S7AdjjLUBuvqzq0OtWSOPntWynZepdDChkBREiQ2mG7iKrppHPOVoBY7IWDFOXxKiVm1UM9CnfaYfGa1MBYIu3puNlQIpZLdpPXP2d4ZLiONymwYOyDCYFyxN+BKgtY3uUFK7cPr4YSMczTWsvt8bjVawohtqEHPuqUs6BYRHujjHSAP3WE2QtuR2eXvoBZ3Tg9NNXTd2huqsri/Nj3pdx3NFNM19jpaV9SND/Qzb2edxm+hhnR8rs+r929zuXqe189brVLzmvoman3RMTXYLCDdf72tN/fJw19My7SYycn3/eQPcudg6n/DIjy19NAKw8Q8JEq6hbo1ZW/J/I61sqS0hBL1H5LbQj1TKzqVOTKdqyfdKjdj5MNiF174TslG8zpTLwaFL2tqElMjvkG1a4jbljBr/k3qcoEiKbVpyDcmYLmPj0quiOrTKskkfkK96NUGLzY2G71Aw1SQTNNUVddFK0DiEMP4DXdC6YuRK43NtnTDcA9TP4zQe1uWVP9zvf4el7flavVcn/HiWGh1rHsUTX68MHSciz+aLYJgqx1M000JG8kyZDHmsY3WIBsb2zeYHc+ne3xdTS8PUaI7sHZlhsoeW+4hGDnhZDdveHWUv9/jDVFGC5DFgGmn4IZ8e6CPQx8v2BDSfGQa2IIa79WAqrdH8QaumNzB4YIQ/+0H8d+C93x4ARSkCPJB/ukEJhFftvBiqaOLtzt/6sUhZ0Rhzy9vgJcopsMyIZMqsIIjtTk71SVJAJoJejw5RBDIE2QK6er09Jzf8aIQPBfN4KkhmGOS2gZyo3NuY55aktHJ6nLUEmqCZAe9tGRKrZVsS23JUsuTSGNDVVUj62qyTBRPLYGW53xfoAa2tW6CDt4UhSedxyP0fiZRdL/f4+EjnCpZI5GklibnrCBCaYG/5Xyyxc5OlvxiqV0PNLRqaso0YEQ5L3+dUhP8jno2MstRS1saNTwsHV1MLfGECKOwklpFoLTVfCgngbmTx4mkqCVBe75kdiqilkwMJEt+K6lVuMVZ7r0b71mQjK9HDZeYASWMgyirxqCoHZOStJDc8l1qecq6hYmOvJqg5ogvdwVQS19/QleCvkmtqJ+RW+TnTQnKZepQ+8VNp3wWC0HthDcfM+Wzb1Irphrapds1pAao4Wp8u3zecUHtlDgP7Gyn96iRK8t1MR4IqOXlMhLU8O+scVtQyqkl01/4RTXfo0aWG4flV9KIBGNoDWpJuXFFvXpGLZnvoPMDx3vUSJ8rLL+SRiTw8WpQwx1xlZ2UUkvaxB4Ybd+jRs6gbmG+ASdBkVkNaiG1vUAJtWSwBRfVfM/KbXluCydBVWQNarhn5CdE0sLUkrJ9FVzevJLagalSWVyIi+qammAJnrz+s5oafsarZs8W4S/BCgL1vXeDCJ61PGePk4Ba3naqqeFnvKpePacmev9VfWqugFoXLw8UJBTzFlFNDT/jVRmtoq0JbPfm2loH1P4Epdp57EqSWlVKC1NLfHZ42cRKauqW0YxImHRMTTS1IDdam3xC0/l3YGtrbgxtYY0FVvwKmony3r2a2oKiLFBC7arSByf0nr3WMTVwafB61LARVrXGa2rlLk0Rtl5Rg2YoUU9RQo3PkGFq2FzFTtK+oiok86iWSWvj+7bmqHVQQSaYm1z0U09EjXeB/hCGxJ3EExHtimBg7r3/GjC2XlETvQYpHxOxb85P0L8hDAaRyqwItRaRoiM8JPSKmmiaWWF/ueCV4Cc7nceEb6rCESWikvCQ0By1DkLgohfiFYkQfEEhux+eDJYOnMmIUt4JkxHwmwq0tj5Rg6biM9R8oGGkbTTbCF9z+ShKZVtugLnbHLX2y6EEyxaR14iDr2N2EMUbPclNYKcqWzaGzuwd+SGhT9TgJRd0flFTxvaf0a0r6R0B613L8g9MPnTJYWuOWvvZdziSqwAL6FLdVmKvhMUHyYPOulWeJcy9L5OHtOjbMDXBiwW/jRrYrdlTuvtPOu9R3hCWSa6BDESm663vH8V933BhlojaYMX0bfgk89uKEf4OU/OX7HerwmPplNoa7NbGPrMweLKVvvV2m9PuJyl7GerUMvz3tPB/f7hEu9NuclGSDwRP6CB/SLP2ianprFT8U2FqFvelUeQqOqUGr+5hOUxAdAcsQ2IxJtwaDjllUID6tSX1WMO76wU1XmOYWuv5UNjGVX02SPXkFggD3qjl8w33kN8BQI0eEl6gZn2IGnw1sylvs0ZUzFfwsvcLBdcIiHT8EKCWDQnYWIbNbQtTE2QfiQVPuqQmWH4n3EKW/tmbmqrrqub0R1z7uv5ZKKoab7R9bCgTD73Dme9wlvP88/UcUtJ3rsDv5vMiztLu+6howQvz2SetkyBVk2r33WeUBBHJPepjejHNsVCH1ATxjgPquntMrfF3OlKCFrdF8lCx5v/UJM5EaPxE6713UqfZnNp8Vy0l0XvZFeya92f2GVZX1Fai1w4+0ND6JVNEpNXiO7gpicKR9h9aOR6qMPtmdURNOF98i19jIfkKy68ReTvtLLkV6yaeZD/HtfSSL1z5GnVBbSdepcZMPMK+zN/ORFIThDbfVdl6K5NkleGemWsUtTaO75WuWK0kk13s1vqGlkRS07ZBsFgsRqOR718uF8dxHrFCLM/zJpNJMjMRawPphCa9TyaeF4YPx59tjfIVBFDdAYpl8++g+nLVXAzFRlPiscaQ8PR/eQVpIiX8NIW6+uQSMvtjGlP9NITa+iS1e/q66U6mvTWqD1JDyXMciO5wMY6G9DlqyLLFRS9trNresj5GDdVD4hW+930zOwafo7ZfZSfvYm5I0/oQNdzAcAatb84U1meo4apHHKesKoH/Tn2EGjY1whxf//QBahYuu8ItTeEnFvRC3VPTsHmGayn6Z96m6pqaifMqaxxxCz9762+oW2oazuAtcUMz++cS5OqOmu36uJBkPkO2rdGjZeZ5dUPNtjQHl/KsJgeU4rMuLcWNOxJc59OstnfMaP7YJr+R2+t2hlT1lrsmZOnjIoesznrcn2USTT1sQ7arhf8CZEgvvL+zHqqhPdb3hrt1onkvlvqWk+T7NxkWNpE+sHTDVU1F07bBdDFDqRqUp0EpmiQ9s3n2u+8HtZspepYu0eNmYagxAuVw0LY4ZzWb4aSV7ztOzOEniu6nzXz+XC1/e+oOvaF/AJ36JLhsEnWMAAAAAElFTkSuQmCC	110274344916933599324	t	Ashwin Kumar	9901010860	jobs@backbuckle.io
258	QuNu Labs Pvt Ltd	We provide cyber-security using principles of quantum physics and quantum optics. We want to change the way people look at data security by making it unhackable!	www.qunulabs.in	https://www.qnulabs.com/images/qnu-logo.svg	104089503500603657430	t	Snehal Gupta	8095506128	snehal@qunulabs.in
246	Driver Friends	P2P network for cab and auto drivers to crowdsource daily information related to their professions.	NA	https://www.solidbackgrounds.com/images/1920x1080/1920x1080-white-solid-color-background.jpg	117894875203741245699	t	Deepak Sahoo	7020520742	flashiitm@gmail.com
257	Manage Artworks	ManageArtworks is a Packaging Artwork Management Software as part of Karomi Technology Private Limited, that helps regulated industries like Pharmaceuticals and CPG to ensure regulatory compliance of their pack labels. We work on artwork management which is a niche domain where there is scope to combine cutting edge technologies from both Computer Vision and Natural Language Processing in an optimal fashion, along with the possibility to work on Computer Graphics.	https://www.manageartworks.com/	https://www.manageartworks.com/wp-content/uploads/2017/11/imageedit_7_7219679184-300x126.png	103304235098083374178	t	Sreenivas	9952940461	sreenivas@karomi.com
296	ThinkPhi	Our mission is to be earth’s most sustainable company. We hope to get there by building products and solutions that accelerate the use of sustainable resources.  Our products focus on creating Outdoor Sustainable Spaces in and around your home and business. We are the inventors of the original "Ulta Chaata", a patented system that is an outdoor shade which harvests rainwater and generates solar power. From the Ulta Chaata came Model 1080, the world's most advance shade.  In 2019 we launched the HALO series which has various applications that enable intelligent outdoor space applications.  We believe that organisations and individuals can influence behavioural change through the use of our simple products that help conserve earth’s natural resources.  Our founding team started the company with a small team of Designers, Architects, and Engineers. Over time the team discovered that 30% of outdoor spaces around campuses is under utilised. Our future as a company is to provide usable, connected, and sustainable spaces.	www.thinkphi.com	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOsAAADXCAMAAADMbFYxAAAAeFBMVEUAAAD////39/fOzs6dnZ12dna8vLyBgYG3t7dMTEwXFxdAQEDo6Oh4eHivr6/z8/NsbGyOjo5eXl7U1NTf39/u7u7l5eXGxsaZmZkhISGnp6dHR0c7Ozt+fn5RUVFwcHCKioozMzNjY2MsLCwODg4cHBwoKCgTExObvP0BAAALZklEQVR4nO2da2OrLAzHp+3abutl9rp1vbjr+f7f8FErFjCEgEHtnv3feU5r/Q0kIQlwF/1/dNf1A7SoP9bfqT/W36k/VmZtVoPRfpgkaZqO0yQZzneDddzGD6sKyhpvR8Pnh687WJ/L436wCfn7moKxruezTwOkqlOyW4R6CFVBWNfDJQnz2sSzUQsNzM4aj85unELvyYr7WTTxssYTxwZV9TgOisvJuvtoAnrRV7JlfCJVbKybxDTeuuphxPVMmphYB436bk1JkJGKhXV0YCXNdR+gKzOwzr/ZSXMt180fTVVj1slrENKClrltG7LufoKR5jqzelSNWLenoKS5XrhAo2as4+CkuXY9YB21QpppyWWAfFkXvAYV175T1kmLpJkeWJrWj5XB8XXUpCPWFZfn66LnTliHHZBm+m7sR7mztjkoqWraj11Zp+FcQruOrbIOOiTNdGqRdd8tavbSNjE+TqxJ16iZGoxQLqyzrjkLDdpgbd+BgOU9GaCzdmdrdPnaHjLrQ9eEkjxhqaz9adVcflFVImu/UD3fWRprP0ZgWT7JEBJrH+yqLo8YI4V13jUXKPcQI4G1Yx/YpPcArJuuoUz64GftchKHyzV2bGXtm7WR5ega21g7CrgQ5TbDs7CuuqbBdeBk7RrGppSP9blrFqtcXlmUtbWUTQMxscZdc1B0z8Pal0AELnovRlhvoQdn+sfB2jUEVUlz1nay5hyiTu+MrNuuCeh6aMoavuyDT8Twk4m1p5NWWK/NWGk13X0RraDCwNpyPURjNWHt7wQd1tCftZ/RNEz+rLfWrLSGBVlvxDtU5MvKX/ocXnM/1puyrUIEGwux9jl0aJY9nQWwAsHvz3RcUyrcjVN+da99Y5n/47Ph8mcIZoi+ivtei+KO+a+8q58pfxuYWi99WIHnAEPsovmH0B+oSAdfo5A75fIJrqj5Lm77WF0Xl+oqrjI9t3nUv5tp6sEKVBuCfzMxOyhYp9o3iqHi+uKPlMuMNdI7AsBaLBtVwnslKhzJtaYB6qw74DYBWIHB3sq6xlDtZqf+ASjKBLIqfdiddeHMWnZSo5mwRZ5qrGDw8LTY5JoWvx5Pi4tFw3atNw/O+lWiQv3uIltIscaKznAm0Cd8WWteN8r6vYC/JMuVFTWuI1ZWvQwDY/0s17ejFZEWE6uz4vFvZlataAphFd/A04aWTqyz4m4/N6v6lzWzilpaW5GKGyu+AJubNVqTWEWt/9GCaqkE0lnxe7GzKjczsYquaV8Ij4fFNdY1fi9+VjnkbmAdl58kJEjx3LPGaikZYGUtGa6BaJB1KdqKNPtCi540VksEnJVVTK8rOJBV2BFanStqdTRWy614WcuhpMqmgKyliKEStKZAZbW8rgirnv7ZU1jLLifsnJk11maxRqEvrMpqi5WaWaNYVURiLR8tsbAu6FkIOiswqaSyQrKyCnOyRFk3/8ioqIVVWW1xYXZWkYl5RVidsqNYZkdltd2Jn7VsiCnC6hTrm1FZbUNTCNayzm6HsBIcpkpvVFZrds7MungZKlqRWcvx6QUbh62O8FVU1hd/Vi/7etH58uMfmH2lV+Ej5ZgKq7WgKQirGE9+vsys9mYQQoJOCutbN6zl823uINZj2VDUJZrIOiWF1WrHArGWHW8FsX4If56Y6kemdTKrvf4wFOu79BT1+WtZv2QOIMpCjI7Mqj9ve6zyLgNAXKKMgZPyh0ixk8xqv1cwVslIQ/Gm0vOz2v87NDcps9o7STjW6/gJxhHL/6W4izRW+9sfkLUyjHB8uJyEExYL0VjtazZCsn6irMKWLKxlK2ZnQma1OychWUWCzJTPEQURtmm7OQ0rs9qraIOylglUY55ODF8Wj8dcYdsn1stLac5JimQyHgA0b8ogs9pX9AZmLfofkmsWkWJ0QnsrrD84a5UBwMLiPWM9bNfrNWgrl+v11Smvs1b+FfKoXKy3oD9WnfV2Vm5g+j+x0uxrH7dWcBeNtd9rmKmi+cO3tqABlhHVcf56C6Kx3mSNtC5iXOKGltCZRYw3BVzHfI4Xlba7YX2m8hZl/6O7yMW3YtMlLGIcEaocZlKtomyiTbkvzQE+t+kSFjE+HD2xcEECqufUUZ/Cek9hRdZzuOVzvAVVCi7kpmVjpeZzyAkiZ8FVkVIZBBsrNU/H6Eyc1TKT4jHj5XOmczoRbpxUGs7GakZ1zKvTFavW+l5FO5Qrka9VrVyscvkfysq39UAeBttK76PGWgVIq9GQi5VcL8G3PrLII0op0xprCVs1LBcrvQ7GVt9EVQEiW/06axnIF1dcrPT6Jq41vnutWSHWS05DeFBcrNixd271iFStZIzqMbUVOUUyQsQHmFjfEVTHOlOqNvq9INad3PhMrOMIkVv9MFV5T1KcdIh1EoDVpX6YKQxTI4NYRwFYXerCmfaSI/Xh4qUWbinIenZldar3Z3phixitPGuCWIvfE1buwpomslLVLBFYndZxMO0mVzyk/D4ArJcnF+4/Fk6gs+IrJd3WXVH1oT8VwFq8WlXYh4cVRa2x1leleumyBANjvTg4VfidhfXsxspkdS4vzqAK6uisT5dp3dUusbA6rpPkchPLKfPo+Pxw+PnWWGfivbqODhdWdX3EInZkxVGJ65rdBY7+cbyZTqdXl1XymEGb8+zGaunCxPXqHrJv96B0IQ5fwrabBm0fAh+927a3U1KgHKy2vy3wASbW7FGx3S12alyAgdW6TyJt3xBfHY7zyWi1Wm/V6F68SvQICAOrz74h9jJidxWjTFxs8DJeQivGmrPaz0xqaZ8fyB9W1JzVa5+fELnJ8KyPVlR4Xy7qCky6wrN67ssVoJggPKsd1bCPHntyMjgr5VyDlvZHDM6KxUpxVvaGDc1KOq6ipf1MQ7NSUI371DKfrx2YtdE+tdy1TtZShxP0gaP6j8abEGwrxmpfM+mkw3E2O2KZsdfsAzO9+DP/1uxouryq4b7SnHnn0MLWbZNYXdZNdyzqcZpY+d6NCM1XEVlvZWdeKip6Hsdt7OFKP4IQY2WKi4eVw1nkaA+4heJpOqrlXKT+nyrDdi5S/8di8hhMYO35OWbvLqjW8+nClWNyyBomdWLt9Xkrjife2sex766JjEI3kvNi7e2KByg7th7t95OBoRqGYJ96umznp/aggyqdexhC8SeKLaZusdOu9ALwlbqFIhCBIvkdaScwuPSJXC3j9lkbpGk+lsOGZy1J95egeYpeX0v0J/s25dGjLrAzq2W7qb4zbevUtqRvvmXweLSYG3mewBtrayYd1WgWj36sPWrZ2pZq5jdMGZ8c5n99eWdrqIi3ozSsy1y3H6Nx3QnGCjx8WaO0JRxMwEINLDUu2yYn1u5X7/8DZnFoWEzebNWNtWvf+A1yc9HJifzCOrJG6y6nePBqSzR2ItcourJ2OXk3lH8EZO0qLPNlWj4WrA/n6mRvBnPdKjo2yVM7H9Yobt+twMqXsF3i/W1OpZYPEn1CA4Yp8k35c56s0abNIcpyCCiSFldKxX1ZW0z2nKxRYPPfXYle+LNGcTt7liEbRQsZG1ZN4jVgzX4j/KSWFgM2ef+qm9WINYpGDsdHeOiDmsSAe7FmkRuyRtE+HO2JWvQRwWETPf7WmDVY+PgBP6hLV714qvaXYmDNrC3/yfMfDm16kbYwBMjMsrBmP8QbjUrdko2lJteOnEA3YGLNPHC23RUPhHJ2g+LB/uVlODH0CTbWTCMONzl17rxkcbJmU455M9dx5lLq4Sxe1kyLiWfxzGvqNvC6i5011+rFcah6fJ57jUZuCsKaa7U/00JTT+NRC5y5grHmWqznyYdxw7rv0/1wZ1s4yqmgrELbwW4+TMrz6NP0ZT/ZrZB90UKpFdae6I/1d+qP9Xfqj/V36o/1d+o/w6OxG/htmrYAAAAASUVORK5CYII=	105502414900621283479	t	Shubhangi	9833153900 	shubhangi.r@thinkphi.com
259	Medha Innovation and Development Pvt. Ltd	MID is a Tech based startup company working with  AI in biological data analysis and building platform using Big Data Technology over cloud.\n\nMID have its own patented algorithms known for accuracy in prediction.\n\nSkill Area : Bioinformatics , Data Analysis , Bio statistics, Python , AI , D3 js,  Data visualization. 	www.medhaid.com	http://medhaid.com/images/midlogo.png	109683991238473547277	t	Amogh Bhatnagar	9039049182	amogh.bhatnagar53@gmail.com 
263	Peacock Solar	India's leading residential solar company aimed at accelerating residential solar using data analytics and efficient finance.	www.peacock.solar	http://www.peacock.solar/wp-content/uploads/2018/10/xpeacocklogo_better-2.png.pagespeed.ic_.caRRPabiB8-min.png	111320166102807820736	t	Aniket Baheti	9705655855	aniket@peacock.solar
276	LeanAgri 	LeanAgri is a technology service provider with decision making and activity planning solutions for farmers to increase farm yields and incomes. We work with enterprises to provide best of farm management services to associated farmers and farmer management solutions for enterprises. We are IIT Madras Alumni founded company based in Pune, Maharashtra.	www.leanagri.com	https://leanagri.com/wp-content/uploads/2017/08/Logo2.png	110988755828086628184	t	Aman	9309821748	aman.verma@leanagri.com
273	Genesys Telecom Labs	Genesys is the global omnichannel customer experience and contact center solution leader. Our customer experience platform and solutions help companies engage effortlessly with their customers, across all touchpoints, channels and interactions to deliver differentiated customer journeys, while maximizing revenue and loyalty. In 2012, the ownership of Genesys transferred from Alcatel-Lucent to a company controlled by the Permira Funds with participation from Technology Crossover Ventures. Today, Genesys operates as a standalone company. We help organizations across all industries define the journeys that matter most to customers by delivering consistent experiences to every touchpoint	https://www.genesys.com/	https://www.genesys.com/	108454550000095213572	t	Thilagar	+91 978 659 8656	thilagar.thangaraju@genesys.com
275	Global Mantra Innovations (A Ventech Solutions company)	GMI, the Research & innovation arm of Ventech Solutions, focuses on building products that we believe will disrupt how healthcare products and services are delivered. Banking on cutting edge technologies such as Artificial Intelligence, machine learning, NLP, predictive modelling, advanced analytics and blockchain, GMI builds to deliver products and IP led services in the areas of population health.	https://www.ventechsolutions.com/ventech-global-innovative-services/	https://www.ventechsolutions.com/ventech-global-innovative-services/	116687833430096689153	t	C.S. Thiyagarajan	9841076032	Thiyagarajan.Somasundaram@GlobalMantrai.com
280	RackBank Datacenters Pvt Ltd	We are into providing datacenter services specifically dedicated servers and colocation. With our data center parks project we also provide the ready to go live infrastructure with all the required amenities for budding as well as giant players looking for setting their own datacenter facility.	https://www.rackbank.com	https://www.rackbank.com/images/logo.png	112150566284259074738	t	Sumi Rawat	+91-9993016098	sumi@rackbank.com
262	Chatur Ideas	Chatur Ideas is a startup-enabling platform. After acquiring Nurture Talent Academy (India’s first Institute for Entrepreneurs present across 125+ cities and trained more than 34,000 entrepreneurs), Chatur Ideas is training young entrepreneurs across Institutes and providing them access to its vast ecosystem so as to enrich the entrepreneurship culture right from foundation level.  Along with helping startups in colleges, it supports mature startups in raising funds, providing mentoring and assists them with a 360-degree execution support in building their ventures to the next level. Currently, we have more than 950 startups under our wings to which we have provided support in each of the above segments and access to our network comprising of almost 1500 Investors.	www.chaturideas.com	https://www.chaturideas.com/images/logo.png	101396729595279031815	t	Vishal	9167058897	vishal@chaturideas.com
272	Genesys	Genesys powers more than 25 billion of the world’s best customer experiences every year. And top-industry analysts agree: Genesys is the only leader in both cloud and on-premises customer experience solutions.Great customer experience drives great business outcomes. More than 11,000 companies in over 100 countries trust Genesys. That’s how we became the industry’s #1 customer experience platform. Helping companies deliver seamless omnichannel customer journeys and build lasting relationships is what we do. From marketing, to sales, to service—make every moment count.	http://www.genesys.com	https://genbin.genesys.com/media/genesys_logo_tagline.svg	105202096528458362102	t	Thilagar Thangaraju	+91 44 4019 3548	Thilagar.Thangaraju@genesys.com
281	Curneu MedTech Innovations Private Limited	Curneu MedTech Innovation is a health care technology firm based at IITM Research Park, Chennai, India, and  Heidelberg, Germany. We work on a motive of building an affordable and innovative healthcare solutions that address the clinical needs thereby bringing better lives for the needy.	www.curneu.com	https://www.curneu.com/images/logo.png	117306459721549242620	t	David Roshan Cyril	9715707807	david.roshan@curneu.com
274	Thin Film Solutions - Consultants and Project Executors	Thin Film Solutions is taking a project on Health Care working on new concepts in detecting and estimating pathogens cultured in the laboratory. 	www.thinfilmsolutions.org	http://www.thinfilmsolutions.org/images/logo.jpg	103319782156851133364	t	Dr A Subrahmanyam	91-8939526241	tfsmanu@gmail.com
306	SynerSense	Medical Device and AI data analytics platform. We are making better world for people diagnostics with orthopedics and neurological, to provide right treatment on right time  and changing way of traditional treatment.\n\nAward winning Product and PoC in India and internationally. 			105396769861562619378	t	i-Sense	+918072051691	synersense@gmail.com
284	Vayujal Technologies Pvt. Ltd.	844 million people in the world – one in ten – do not have access to clean water due to a number of factors, such as repeated droughts, lack of natural supply, metal and biological contamination, anthropogenic activities, and poor or inadequate infrastructure.\n\nVayuJal Technologies Pvt. Ltd. develops Atmospheric Water Generators (AWGs) to combat the problem at the global level and to provide affordable, clean and healthy water to everyone facing a water shortage or a water contamination problem, through environmentally sustainable technological solutions. Developed AWG units will provide healthy mineralized water for drinking and normal clean water for other purposes, through a combination of its patented surface engineering technology, energy efficient unit design and mineralization technology, at a cost 20 times lesser than the current bottled mineral water costs.\n\nThese units may also run on off-grid solar panel systems to produce water in remote areas, wherever needed, thus providing affordable clean water to everyone, everywhere. Such machines will enable independent access to clean water for each individual facing water shortage issues in urban, rural, industrial, commercial, or remote regions due to multiple issues. Additionally, these variable capacity machines may fulfil water requirements for specific applications such as irrigation, construction sites, army tanks, etc.	www.vayujal.com	http://www.vayujal.com/	107266261851940045387	t	Ramesh Kumar	8939017761	rameshsoni2100@gmail.com
287	FinanceKaart.com 	FinanceKaart.com is a leading comprehensive online marketplace for financial products & services which helps consumers to compare & apply different financial products & avail doorstep services free of cost without visiting to any bank branches.\nWith its blended Phy-gital approach FinanceKaart.com is addressing the needs & working as a financial matchmaker for the entire ecosystem with its unique algorithm.\nFinanceKaart.com is a venture of Renaissance Global Marketing and consulting Pvt.Ltd which is a DIPP recognised Fintech startup with  Certificate No. - DIPP30154	www.financekaart.com 		103007413487745509743	t	Ganga R. Gupta 	9889916009 	info@financekaart.com 
224	Propelld	Propelld is re-thinking education lending from the ground up. Education, even though one of the most talked of subjects in the country, still suffers from a lack of financial access for the 80%ile of income population who don’t have the income means to qualify for loans from traditional Banks. Propelld, with its approach of accountable education lending by using future income as the key metric, has emerged as the top-most lender in this space. With a client base boasting of more than 100 Institutes & 800 centres across India and the who’s who of Education Providers within just 12 months of operations, Propelld’s fast growth has attracted Pre-Series A investment from top Tier A VCs of the Indian Eco-system. With a changing education and hiring landscape, the Govt. push towards skilling and the focus of employees on re-skilling, Propelld stands on the cusp as the leader in the exciting space of vertically integrated education loans.	www.propelld.com	https://i.ibb.co/qsYf7hf/Propelld-Final-Lower-Size.png	107530024622485449869	t	Victor Senapaty	9920175773	victor@propelld.com
277	Ah! Ventures	ah! Ventures is a growth catalyst that brings together promising businesses and investors by creating wealth creation opportunities for both. Our unique model serves both investors and entrepreneurs through a unique blend of customised services, skill, and industry and domain experience.For investors, we offer a bundle of services that are geared to help you not just locate promising investment opportunities, but also evaluate them in a manner that eliminates doubt, and facilitates savvy decision making. Through our continued involvement in the businesses invested in, and our transparency in all dealings, we provide your investment with that extra edge in security and growth.For entrepreneurs, we help you create an environment geared for explosive growth through services that benefit every facet of your business - from funding to recruitment to office space. When you come to us, we go through a detailed program that evaluates your business not just for where you stand today, but for what you can be, given all we have to offer. All our services are geared to help you function at a higher level of efficiency and growth, giving you an edge over competition, and helping you create new benchmarks in quality and performance.	http://www.ahventures.in/	http://www.clubah.com/images/logo.jpg	104379184185174428302	t	Baskaran Manimohan	9543282005	baskaran@ahventures.in
286	My Ally	Great companies change the world, one problem at a time. And great companies begin with great teams.What if we told you that you could build a thousand great companies by helping them build great teams?My Ally's AI Recruiting Assistant leverages cutting edge NLP and ML to automate Recruiting Processes for Hiring Teams around the world. We manage the entire interview scheduling process - including communicating with candidates - with better-than-human speed and accuracy.	https://www.myally.ai/	https://d1qb2nb5cznatu.cloudfront.net/startups/i/570288-a27b6774d94ad9d4d5827b45c0432dc7-medium_jpg.jpg?buster=1538687080	103765838603107363304	t	Patrick	8498081691	pat@myally.ai
300	FixNix	We are world's 1st pure play SaaS regTech startup "FixNix"​, our award winning Risk Orchestration Platform to streamline Governance, Risk & Compliance process via workflows, along with predictive analytics models to predict & data lake to handle unstructured data.	https://fixnix.co/	https://www.google.com/imgres?imgurl=https%3A%2F%2Ffixnix.co%2Fwp-content%2Fuploads%2F2018%2F04%2Ffixnix-grc.png&imgrefurl=https%3A%2F%2Ffixnix.co%2F&docid=nSWoG48KM7GIhM&tbnid=sOT7tOWD-JlXSM%3A&vet=10ahUKEwiA89C-0dPgAhXCXisKHfYuDzsQMwhAKAAwAA..i&w=1024&h=732&bih=754&biw=1536&q=fixnix&ved=0ahUKEwiA89C-0dPgAhXCXisKHfYuDzsQMwhAKAAwAA&iact=mrc&uact=8	114839727532236749919	t	Prasanna Venkatesh	9962645350	prasanna@fixnix.co
302	Test	Cool			114818886750636854304	t	Saurabh	8559931413	saurabhjain2702@gmail.com
307	Myzun	I want to apply for the internship.			109259502533616809707	t		9600729655	myzun74@gmail.com
242	Planetworx Technologies Pvt Ltd	Planetworx Technologies is a US incorporated and Bangalore based 2 year old B2B startup with a GDPR compliant audience insights SaaS platform called Trapyz (www.trapyz.com). Planetworx is an alumnus of industry leading accelerators like CISCO Launchpad, Pitney Bowes and now part of Airbus Bizlab program. Trapyz enables behavioural and intent-based segmenting of in-market audiences by analyzing multiple device sensor data. They work with app platforms to enrich consumer data and create additional revenue streams by monetising data for right targeting of consumers. The platform monetizes non-PII data by creating interest profiles based on real world visitation patterns and in-app intents (No personally identifiable information like phone number, e-mail ID or a device ID is captured or used). Our vision is to make digital marketing more consumer friendly without infringing privacy. The mission is to be the one-stop shop to map offline consumer journeys by leveraging multi-dimensional data in the real world.	www.trapyz.com	https://trapyz.com/assets/logo-brand.svg	114749538391689307031	t	Ranganathan	9886562627	ranga@planetworx.in
303	Accomox	cool			103441912139943416551	t			
308	WEGoT Utility Solutions 	Can we reduce water consumption/demand by making people more accountable and leveraging technology to make real time decisions to eliminate any inefficiency in the water network of all buildings in the built environment?\vUse VenAqua!, WEGoT’s IoT water management solution, which helps manage the entire water infrastructure in a property. It acquires granular consumption data that was previously unavailable by using low cost, high precision sensors that track flow, pressure and quality of water and then apply it to the various water related applications in the property. \vVenAqua, has brought about a much need behavioral change in the way people treat water and has resulted in saving more than 550 million liters of water.\n	www.wegot.in		116990118273206494266	t	Parvati Parkkot	9822487371	hr@wegot.in
\.


--
-- Data for Name: startup_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_post (id, user_hid, internship_title, description, attachement_url, internship_profile, duration, stipend, interns_number, location, research_park_startup, skill_requirement, specific_requirement, accomodation, travel_allowance, other_incentives, address, startup_details_id, status, rev_rank) FROM stdin;
112	101107640131204357570	Front-end Developer	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.		Developer (Front-end)	Minimum 8 - 12 weeks	15000	3	Hyderabad	No	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	Preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	No (Many good PG accommodations available at reasonable cost around the campus)	No	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
70	107530024622485449869	Backend Web Application Development Internship	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.\nNature of Work:\nSAAS Product for Training institutes & Financial Institutions\nMicro-services based architecture for scalable solution supporting various use cases\nData stream platform around Institutes, students and Financial Institutes\nProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889420/ecell/uelbmaccgipjgicnpfsi.docx	Backend Web Application Developer	8 weeks	20000	2	Bengaluru	No	Bachelor’s and/or Master’s degree, preferably in CS, or equivalent experience.\n·        Good understanding of data structures and algorithms.\n·        Experience coding in any one of the following C++, Java, C#, Nodejs, Python.\n·        Experience building highly-available distributed systems on cloud infrastructure will be plus.\n·        Exposure to architectural pattern of a large, high-scale web application.	NA	No	No	Informal dress code, other perks of working in a pre-series A funded startup	#365 shared office, 3rd floor, 5th sector, Outer ring road, HSR layout, Bengaluru - 560102	224	live	1
101	111133250649424423782	Online Marketing-Interns	 Customer retention, reactivation, website personalization, retargeting, social media, referral marketing, and other marketing and promotional activities. Identify, design, and analyze new brand-appropriate online marketing initiatives and partnerships. 		Online Marketing-Interns	10-12 Weeks	8000-10000 Per month	3	Jaipur	No	 Expert level knowledge of Facebook Ads Manager , Google adwords is a pre-requisite.	Passionate about digital tools of product marketing, exploring new ways of online marketing with tech acumen	No	NO	NO	J-469-471 RIICO Industrial area, Sitapura, Jaipur-302022	237	live	1
76	102476915533780948091	Software Intern	Will have to work on live project of integrating toys with learning.		Software trainee	8 weeks	7000 INR	1	Jaipur	No	Machine Learning, Artificial Intelligence.	Should have good knowledge in machine learning.	NO	NO	NO	F 20-A, Malviya Industrial Area, Jaipur - 302017	231	live	1
149	105502414900621283479	IoT Intern	We are looking for an intern team to design and deliver a hardware and software module to track outdoor micro climate environments. In this role, you will work on a rapid development of the hardware device followed by a software platform which will apply advanced machine learning, modeling and control techniques to the hardware device.		IoT Intern	6 weeks	25000	2	Mumbai	No	Design and build if electronic control systems and oversee module construction.Design and manufacture of PCB and other circuits.Testing of the hardware in harsh outdoor environmentsAnalyze large-scale field data to evaluate and ultimately improve algorithm performancePresent high-level designs, development plans and performance data to executivesBuild a translation index for NLP scenario’s around raw data collected from the deviceIdentify improvements to existing features and concepts for new features	Working towards a degree in BA/BS in Electrical Engineering, Computer Science or a related fieldFluency in at least one of: Python, MATLAB, C/C++, Java	Guest House	Train/ Flight	5-Days a week, Young and energetic environment	Unique House, 25 S.A, Syed Abdullah Brelvi Marg, Near, Horniman Circle, Fort, Mumbai, Maharashtra 400001	296	live	1
74	102540152476572591754	Sports Writer	We’re looking for adept content writers with good knowledge and passion for sports and an excellent knack for writing in the sports genre.\n	https://res.cloudinary.com/saarang2017/image/upload/v1550041130/ecell/bjz9mrp5y55jbudpksvz.pdf	Sports Writer	Minimum 2 months	Rs. 8000/- to Rs.10.000/-	2	Hyderabad	No	A knack for fresh and conceptual thinking, researching and writing sports articles.\nPassionate about sports and the power of sports.\nWell-versed in sports jargon and a natural talent at wielding them.\nShould be adaptive and flexible to learn and produce content in various mediums and platforms, and in styles and sizes.\nA flair for integrating visual elements in the content.\nA bent for creativity and conceptual thinking to support in strategizing and executing the content marketing plans for campaigns/promotional events.\nShould be a team player and be able to deliver the projects effectively on tight deadlines.\nShould possess integrity and the zeal to grow.\n	-	No	No	Informal dress code and lunch will be provided for 6 days	30,31, West Wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\nMaps Link: \nhttps://goo.gl/maps/Vpnw18n49M22	235	live	1
122	107429974676687296166	Data Engineer	Selected intern's day-to-day responsibilities include: \n\n1. Creating and sharing reports and dashboards\n2. Working with cross-functional teams the reporting process including data acquisition and cleaning, report and dashboard creation and visualization\n3. Working on system refinement, testing out newer technologies, etc.\n4. Brainstorm on ideas on how 		Data Engineer	3 Months	5000	2	Mumbai	No	Good Grip Over Excel Formulas & Pivot Tables\nBasic Understanding of SQL is preferred not mandatory\nLogical Thinking\nProblem Solver\nEager to Learn	No	No	No	Certificate, Startup culture	801, Jai Antriksh, Makwana Road, Marol, Andheri (E), Mumbai - 400059	253	live	1
77	117013339697530495306	2019 Summer Intern - Engineering	We are looking to hire enthusiastic university students with a passion for embedded software development and a willingness to learn, to work in various departments across the company in one of the following areas: -Pursuing the challenges of bringing up a new development board -How to build, test and debug full software stacks on hardware that hasn’t yet been manufactured. -Gaining a deeper understanding of system architecture and performance (CPU or GPU) -How to scale a solution for a single developer into an automated real-time regression farm  Then this is a phenomenal opportunity for you! At ION Energy we are building the world’s most advanced battery management and intelligence platform. ION was founded by a team of PhD's with decades of experience in advanced electronics and battery systems. Our groundbreaking and patented BMS technology acts as the core of high-performance applications like Electric Vehicles, Telecom Towers, DataCentres & More.  What will you be accountable for?  As a Intern, you will be placed in a development team at ION’s R&D office situated in Mumbai suburbs, where you will have a dedicated mentor, and be able to get to grips with the problems ranging across many embedded areas. You will work on the development and testing of kernels, device drivers, development tools, and build & test frameworks whilst being supported by and learning from the rest of the team. Whilst a lot of our work does involve Open Source software, many tasks require working with development platforms, or simulated hardware environments where features are being developed and tested before the physical devices have been built, so the problems you will be expected to understand and pursue are ones that are yet unknown to the general community. This is you :  -Currently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field -Enjoy problem solving and working closely with hardware -Want to become proficient in system programming -Have sound C/C++ or shell programming -Have a good understanding of computer architecture and operating systems and want to apply it to the real world. Benefits Your particular stipend will depend on position and type of employment and may be subject to change. Your package will be confirmed on offer of employment. ION Energy’s benefits program provides all interns an opportunity to become permanent employees based on performance and business needs and a platform to stay innovative and create a positive working environment.	https://res.cloudinary.com/saarang2017/image/upload/v1550052981/ecell/b6nle3jwjrkkugrfjaiv.pdf	Engineering Intern	Minimum 6weeks	15000 INR	2-3	Mumbai	No	- Currently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field- Enjoy problem solving and working closely with hardware- Want to become proficient in system programming- Have sound C/C++ or shell programming- Have a good understanding of computer architecture and operating systems and want to apply it to the real world.	- College Projects in Embedded Systems and Electronics- Understanding of Electrical Engineering Fundamentals- General Enthusiasm to learn 	No	No	Informal Dress code, Dedicated mentor, Office location easily accessed by Mumbai metro and close to domestic airport, Free tea/coffee, Office parties. 	ION Energy INC703-704 Wellington Business Park, 2, Hasan Pada Road, Marol, Mumbai, Maharashtra 400059	238	live	1
150	105396769861562619378	ML/AI - Android developer	Develop data visualizations to inform network decision-making utilizing Tableau, or similar on android mobile platform\nFront end  - Design and develop UI for dynamic 2D/3D plots visualization in real-time\nBack end – a data visualization support that is capable of supporting front end dashboards and data visualization and data base connection\nManages a repository of re-usable data visualization templates and views.\nSciChart for Android is a Feature Rich and powerful Chart component for Scientific data plotting		ML/AI - Android developer	min 4 weeks	15000	1	Ahmedabad, Gujarat	Yes	\nAndroid Developer Responsibilities. Include: Designing and developing advanced applications for the Android platform.\nJava, JavaScript, JSON, python or ability to learn quickly.\nSQL, 	Detail oriented in scientific computer science and statistical analytics knowledge would be considers plus\nShould have experience of AI/ML sample application data science analytics	Yes	No	Informal dress-code	Ahmedabad, Gujarat, India	306	verifying	1
93	101326090802695787002	Graphic Designer	Created web based or app based graphics or logo for any active website or app. Please include any active link or store link for any contributions. Knows his way around in graphics software like Photoshop, Illustrator, Adobe XD or Sketch.\n•\tStrong aesthetic skills with the ability to combine various colors, fonts and layouts\n•\tAttention to visual details\n•\tAbility to collaborate with a team.\n•\tRefine images, fonts and layouts using graphic design software\n•\tStay up-to-date with industry developments and tools\n		Designer	Minimum 4 weeks - Maximum 6 weeks	10,000 PM Minimum	2	Indore, Madhya Pradesh	No	Proficient in any of these softwares\n1. Adobe Illustrator\n2. Adobe Photoshop\n3. Adobe XD\nBasic knowledge of colors, gradients and fonts.	Adobe Illustrator\nAdobe Photoshop	No	No	5 days a week, informal dress code	Plot No 156\nScheme no 78 Part 2,beside Sai girls hostel\nNear vrindavan hotel\nIndore, (M.P.)	245	live	1
151	114628427311007654470	Backend Intern	We create some of the technically advanced products with brilliant minds. Our work focuses on the highest of the quality and programming design that the world has ever seen. Everyone in the company are aligned with the vision of our outcomes that transform real human experiences. We do this by taking up complex, big and exciting ideas that have never been done before.\nPacking some of the most complex technologies in the world, and delivering it to our customers in the simplest way is our goal. As a backend intern, you will be responsible for creating bold, ridiculously complex systems to solve problems.\nP.S.: We’re trying to make a gender balanced workplace, reach out if you’re a woman.\nWe need ‘the’ one who is daring enough to think big and go after it.\n\nThe stipend mentioned is the basic pay, the pay will be revisited when impressed with your performance.  		Backend Developer	Minimum 4 weeks 	5000	2	Skcript 	No	Good understanding of Object Oriented Concepts\nUnderstanding of ORM\nA good understanding of how to solve complex problems.\nInterest in detail oriented programming.\nStrong communication and time management skills.\nComfortable working with new technologies that could be big in the next five years.\nAn interest in open source.\nA keen interest in designing your code beautifully and if possible produce the required results. Who cares how the code works when it looks beautiful?\nUnderstand and care about atomic elements of your code.	Basic hands on experience on working with OOPS concepts and sample projects. 	No	Covered in Stipend	Semi-formal and In-formal dress code and Refreshments.	1579 A, 15th Main Rd, Bharathi Colony, J Block, Bharathi Nagar, Anna Nagar, Chennai, Tamil Nadu 600040	305	verifying	1
98	110274344916933599324	Software Developer Intern	“If it scares you, it might be a good thing to try.” – Seth Godin\n\nIf you want to join the force which is going to change the entire dynamics of App(Mobile/Web/IoT) development and App experience, you are banging the right door! Drive the Feature-as-a-Service(FaaS) revolution. \n\nWe Dream Big : We Work Hard. We Challenge : We AchieveInterns \n\nLooking for hardcore dev interns (preferably computer-science background) with a minimum commitment period of 4 months. Interns will be straight placed into our core development team. The exposure, experience, and energy which you get will be topnotch. \n\n		Developer	Minium 4 months	15000	2	Bangalore	No	Backend: Java, Spring-Boot, Python, Knowledge of REST framework & micro-services\nFrontend: Angular 2+, HTML5, CSS, Bootstrap, experience in UX design will be an added advantage. \n\nYou can apply if you have either of frontend or backend skills.	No	No	No	Informal dress code, 6 days a week	BackBuckle.io, Kstart Respace, Second Floor, Ascendas Park Square Mall, ITPB Main Road, Whitefield, Bengaluru, 560066	252	live	1
152	114628427311007654470	Marketing Intern	At Skcript, we design, develop and launch top-notch digital products. This includes the products that we build for ourselves, the ones that we make for our customers and the ones that we build for everyone. Some are experimental, some are for a small set of people, and some are large products. Everything falls back to the unmatched quality of our products and services.\n\nSkcript is still a very young company, with less than ten people working on products that touch millions of lives. Currently, we are building new things that are ahead of the curve. We experiment a ton of ideas, fail, learn, go back to the blank white canvas over and over again until we find the right solution.\n\nIn less than five years of existence, we’ve achieved some of the things that many people spoke about for years. Today, we’re doing something big for which we would like someone to tell that to the world.\n\nAs a marketing intern, you will be working with both our internal teams and our customers.		Marketing Intern	Minimum 4 weeks	5000	1	Anna Nagar	No	Understand and expose the value of the team to the world.\nDraft strategies to take the products and Skcript’s work to a higher level.\nCreate marketing strategies that will live and rule even if Thanos has killed you.\nBe a person who wants to lie sprawled on the ground waiting for ideas to storm through.\nEnlighten the team with your words and content. Be very prepared to hear words and grammatical terms that doesn’t exist in the multi-verse.\nIf you can read through emails, texts and paper notes and respond without hesitating, you may now step into the office right away and shoot all of us in the head and take your position immediately.	Interesting writing style and strategical marketing plans 	No	Included in the Stipend. 	Informal/semi-casual dress code and Refreshments 	1579 A, 15th Main Rd, Bharathi Colony, J Block, Bharathi Nagar, Anna Nagar, Chennai, Tamil Nadu 600040	305	verifying	1
153	114628427311007654470	Ruby on Rails Intern	We create some of the technically advanced products with brilliant minds. Our work focuses on the highest of the quality and programming design that the world has ever seen.\n\nEveryone in the company are aligned with the vision of our outcomes that transform real human experiences. We do this by taking up complex, big and exciting ideas that have never been done before.\n\nPacking some of the most complex technologies in the world, and delivering it to our customers in the simplest way is our goal. As a backend engineer, you will be responsible for creating bold, ridiculously complex systems to solve problems.\n\nP.S.: We’re trying to make a gender balanced workplace, reach out if you’re a woman.\n\nWe need ‘the’ one who is daring enough to think big and go after it.\n\nMentioned Stipend is the basic and will be revisited with better performance. :)		ROR Intern	Minimum 4 weeks	5000	1	Anna NagarNo	No	Excellent understanding of Ruby on Rails framework (We will put you through an evaluation process)\nExcellent understanding of ORM\nHave a good understanding of how to solve complex problems.\nInterest in detail oriented programming.\nStrong communication and time management skills.\nComfortable working with new technologies that could be big in the next five years.\nA massive interest in open source.\nA keen interest in designing your code beautifully and if possible produce the required results. Who cares how the code works when it looks beautiful?\nUnderstand and care about atomic elements of your code.	Basic hands on experience on working on projects. 	No	Included in the Stipend	Informal/Semi-formal dress code and refreshments.	1579 A, 15th Main Rd, Bharathi Colony, J Block, Bharathi Nagar, Anna Nagar, Chennai, Tamil Nadu 600040	305	verifying	1
103	111133250649424423782	Intern-Data analytics	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n		Intern-Data analytics	10-12 weeks	10000-12000 Per month	2-4	Jaipur	Yes	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n	no	no	no	no	J 469-471 RIICO Industrial Area,Near chatrala Circle, Sitapura Jaipur-302022	237	live	1
114	101107640131204357570	Android / IOS Developer	Android APP development: B2C apps - KotlinIOS Development: B2C apps - Xcode / Swift/Objective Cwith understanding on constraint layouts, dagger, etc.		Android / IOS Developer	Minimum 8 - 12 weeks	15000	4	Hyderabad	No	Android APP development: B2C apps - KotlinIOS Development: B2C apps - Xcode / Swift/Objective Cwith understanding on constraint layouts, dagger, XML, etc.	NA	NA (Many affordable PGs around the campus)	NA	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
154	114503787094540282981	Data Analyst	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nData mining/data analysis methods, using a variety of data tools, building and implementing models, using/creating algorithms and creating/running simulations\nExperience in handling large data sets in Relational and Non-Relational Databases\n\nExperience in GCP big data tools like bigquery, bigtable, cloud spanner is a plus 		Data Analyst	Minimum 2 months	20000	1	Bangalore	no	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nData mining/data analysis methods, using a variety of data tools, building and implementing models, using/creating algorithms and creating/running simulations\nExperience in handling large data sets in Relational and Non-Relational Databases\n\nExperience in GCP big data tools like bigquery, bigtable, cloud spanner is a plus 	none	No	No		9th Main, Indiranagar, Bangalore	244	verifying	1
119	101396729595279031815	Operations & Analysis	Intern Job Description for Operations post\nHandling end to end Campus ambassador hiring\nUtilize the campus ambassador for getting the work done\nUnderstanding the existing operations to identify and streamline the processes by eliminating the wastes.\nSkills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n		Operations & Analysis	2-3 Months	5000 - 10000 INR + Incentives	3-5	Work from Home, Mumbai Office	Yes	Skills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n	Ms. Office well versed	NO	NO	Informal Dress Code	Chatur Ideas, 101, Kuber, Andheri Link Road, Andheri (W), Mumbai – 400053.	262	live	1
145	114503787094540282981	Data Scientist	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nComputer vision and deep learning solutions, including image classification, speech to text,  context based learning, object detection, segmentation, and equivalent computer vision-based vision tasks\nExperience with common data science toolkits, such as tensorflow, keras and any other ML frameworks etc \nProficient in python		Data Scientist	8 weeks	20000	2	Bangalore	no	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nComputer vision and deep learning solutions, including image classification, speech to text,  context based learning, object detection, segmentation, and equivalent computer vision-based vision tasks\nExperience with common data science toolkits, such as tensorflow, keras and any other ML frameworks etc \nProficient in python	no	no	no		9th Main, Indiranagar. Bangalore	244	live	1
144	114503787094540282981	Application Development 	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nDesign and build advanced applications\nAbility to work with data structures, No-SQL		Application Development 	8 weeks	20000	2	Bangalore	no	Python, Angular, PostgreSQL, Android	None	No	No		9th Main, Indiranagar, Bangalore	244	live	1
133	111320166102807820736	Website Developer	Develop new user-facing features\nBuild reusable code and libraries for future use\nEnsure the technical feasibility of UI/UX designs\nOptimize application for maximum speed and scalability\nLay the groundwork for web-based assets (e.g., web pages, HTML emails, and campaign landing pages)\nTake care of the ongoing activities of the websites. (i.e. blog post, articles etc.)\nDevelop the new pages and functionality as per the business demand\nEstablish coding guidelines and provide technical guidance for other team members\nDevelop innovative, reusable Web-based tools for activism and community building\nMaintenance and administration of website file repository\nHandle website deployment and build process		Web Developer Intern	10 weeks	10000	2	Gurgaon	NO	Experience developing div based or table less web pages from graphical mock-ups and raw images\nExpert in modern JavaScript MV-VM/MVC frameworks (Vue.js, Meteor.js, Angular.js, Node.js Development most preferred)\nHands on experience in delivering medium to complex level applications\nProficiency with Object Oriented JavaScript, ES6 standards, HTML5, CSS, Typescript, MongoDB.\nExperience in developing Responsive pages using Bootstrap or equivalent\nStrong in programming concepts OOPs, modularization, object creation within loops etc and test driven approach\nFlair to bring in unit test cases (e.g Jest, Chai, Mocha ,Jasmine (or a well-reasoned alternative)\nExperience in JavaScript build tools like Webpack, Grunt, Gulp\nFundamental understanding of Cloud, Docker and Kubernetes environments\nCreating configuration, build, and test scripts for Continuous Integration environments (Jenkins or Equivalent)\nExperience in all phases of website development lifecycle\nBe able to understand high-level concept & direction and develop web experience/web pages from scratch\nMust be proficient at resolving cross-browser compatibility issues.\nExperience on cross Device Mobile web development\nShould have knowledge of Web Developing tools like Firebug, FTP etc.\nAbility to juggle multiple projects/priorities & deadline-driven\nStrong problem identification and problem solving skills\nExcellent communication skills, Ability to work effectively as a team member, across project teams, and independently	NA	NO	NO	Informal Dress-code, flexible hours, certificate upon completion	Peacock Solar, C/o Sangam Ventures,  5th Floor, Plot 146, Sector 44, Gurgaon  - 122002	263	live	1
134	110988755828086628184	Design & Creative	About LeanAgri (https://www.leanagri.com/):\nLeanAgri is an IIT-Madras startup developing solutions in the agri-tech sector. With support from prestigious institutions like ICRISAT (International Crop Research Institute for Semi-Arid Tropics, UN Organization), we are offering technical assistance to farmers and farmer organizations.\n\nAbout the Internship:\nSelected intern's day-to-day responsibilities include: \n\n1. Designing in-app screens, delivering design requirements by the Product team.\n2. Delivering day-to-day design requirements - posters, pamphlets, banners\n3. Capturing and creating testimonial and product videos\n\n# of Internships available: 1\n\nSkill(s) required: Adobe Photoshop and Video Editing\n\nPerks:\nCertificate, Informal dress code.	https://res.cloudinary.com/saarang2017/image/upload/v1550749612/ecell/upelmu6f0bsvejhvezzc.pdf	Design & Creatives	2 Months ( 9 Weeks)	8000	1	Pune	No	Adobe Photoshop \nVideo Editing and Creatives (VFX & Media)	Should have prior experience in Design and VFX.	No	No	Informal Dress Code	LeanAgri, Teerth Complex, Baner, Pune, Maharashtra - 411045	276	live	1
78	108825759819157028428	Machine Learning Intern	Job Description:  The current product development involves working on new ideas in Deep Learning, using tools such as Tensorflow. The Intern will be provided training in AI / ML libraries and software development techniques.		Machine Learning Intern	2 months	60000 INR	1-2	Hyderabad or Remote-work (work-from-home)	No	Primary requirements:  - Expertise in Java, Python or C++  - Expertise in Algorithms and Data structures  - Ability to understand and implement ideas described in Research journal papers  - Good problem solving and communication skills, along with a positive attitude	Secondary requirements:  - Prefer experience in NLP, Image processing, Speech recognition, Chatbots  - Prefer knowledge of Tensorflow, scikit-learn, Spark, MongoDB, AWS or GCP  - Good to have knowledge of Data science and Data mining concepts, R programming and Statistical methods	No	No	To be announced	#301-A, Amsri Residency, Shyam Karan Road, Leela Nagar, Ameerpet, Hyderabad - 500016	243	live	2
120	101907162894505620447	AI Engineer for YogiFi - The Future Technology of Holistic Wellness	Looking for young and dynamic engineers to work on our award-winning deep-tech technology product at CES 2019 show.  We are looking for engineers with hands-on exposure to ML & AI algorithms. Knowledge with deep Learning libraries like Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy highly desirable. \n\n\n		Data Scientist, Artificial Intelligence 	4-8 weeks 	15000	1	Bangalore	no	Python, Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy 	Desirable to have prior exposure of working with IoT products. 	Own	Own	Informal dress code, flexible work hours	WELLNESYS TECHNOLOGIES Pvt Ltd.,\n2nd Floor, Institute of Inspiring Innovation Business Labs,\n10th B Main Rd, 4th Block, Jayanagar, Bangalore 560041	268	live	1
79	115802938042318956916	ML intern	As a Machine Learning intern you will be working on cutting edge technologies in machine learning and natural language processing. Suited for somebody who enjoys working on complex data mining and analysis problems.\n\nYou will be responsible for designing and developing solutions for one or more of the following \n- automated chatbots and building innovative customer service solutions. \n- predictive inventory management\n- ML recommended surge pricing, delivery pricing.		Machine Learning	6 to 8 weeks	18000 p.m.	2	Bangalore	no	Python, Pandas, Numpy, Machine Learning, Scikit-learn, Natural language processing	Experience in data mining and analysis , Deep Learning will be a added advantage and allow quick ramp-up	No	3rd AC train reimburse	informal dress code, 5 days a week	Current Address \nNo. 248, Nagawara Junction, Thanisandra Main Road, Outer Ring Rd, \nNear Manyata Tech Park, Nagavara, Bengaluru, Karnataka 560045\n\nFrom March 1st 2019\nBubblespace Coworking\n824, HRBR 1 Block,, HRBR Layout 1st Block, Extension, \nKalyan Nagar, Bengaluru, Karnataka 560043	233	live	1
81	106123538173898449055	Software	To play a critical role in the development of software interface of various automation products\nTo develop & deploy reliable code based on the requirement\nTo perform end-to-end testing of the software products\nTo extensively research on the latest trends in technology and recommend improvement \n\nwill be an internal part of core IT team.		Software	8-12 weeks	25000	8	noida	no	python, java, javascript, html, angular, PHP	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
82	106123538173898449055	Automation	Managing the development of controls related aspect for all automation products\nTo play a critical role in procurement, calibration, testing and deployment of control related tools like Sensors, PLCs, Scanners, relays and other related hardware\nTo play a critical role in designing of SCADA, PLC logics, Communication mechanism etc.\n\nStudents from Electronics, Instrumentation and Electrical specialization only are eligible for this.		Automation	8-12 weeks	25000	6	noida	no	Basic of their specialization	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
83	106123538173898449055	Mechanical	To play a critical role in design of all automation related products by providing artistic design and converting it into engineering design\nTo create 2-D & 3-D diagram of various products and create final product renderings\nTo ensure production of the products as per the drawing and ensure all engineering related aspect w.r.t. design are taken care of\nTo assist in deployment of all products related to mechanical project at site		Mechanical	8-12 weeks	25000	4	noida	no	Knowledge of basics of mechanical	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
80	106123538173898449055	Navigation	This will be a specialized role which will comprise of designing algorithms in SLAM for the mobile robotics vertical of Addverb.\n\nThis is open for all specialization where the candidate has done projects in robotics.		Robotics	8-12 weeks	25000	5	noida	no	Robotics skill	should have previous experience in robotics	no	no	no	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
121	101818747050100224079	Developer for developing one stop solution for shipping documentation <>automaxis	For the paper based documentation issues in cross border trade in pharma industry, automaxis is a blockchain platform for digital, secure & speedy transfer of these documents by bringing trust in the network & the transfer of ownership on real time.		Developer	7-8 Weeks	5000	3-4	Hyderabad	No	Python, Node JS etc	NA	No	No	Perks for good performances, Informal dress-code complete startup work life!	T-Hub, Catalyst,\nIIIT-H,\nGachibowli,\nHyderabad-500032	228	live	1
71	106407488023143571708	Full stack developer, Java, Machine Learning, Android, Web development, QA	KareXpert is a Pioneer in designing technology platform with a Patient centric approach to make “Patient Continuity” a reality in Indian Healthcare. We are the only technology Company to design patented “Advanced Health Cloud Technology Stack” which connects Patients with all the care Providers -Hospitals, Nursing homes, Clinics, Doctors, Pharmacy shops, Diagnostic labs, Imaging Center, Blood Bank, Organ Bank, and Ambulance. Our Innovative Solutions are compatible to run on any Smart device-Mobile, Tablet, Laptop, Desktop via Mobile App & Web App.		Full stack developer, Java, Machine Learning, Android, Web development, QA	8 weeks	No stipend	4	Gurgaon	no	Core Java,, OOPS Concept, Spring, Hibernate, Html5, CSS, Angular6, Mysql, android framework, SDLC, STLC	B. Tech CS and IT branch only	no	no	n/a	Karepert Technologies Pvt. Ltd.\n405 Universal Trade Tower, 4th Floor, Block - S, Sohna Road, Sector 49, Gurugram, Haryana, 122018	229	live	1
110	105373738578694994605	Director pf Photography	The Director of Photography will be responsible for studio/outdoor shoot of videos like corporate interviews, corporate events, documentaries, etc.		Director pf Photography	Minimum of 2 months	Rs. 10,000/- to Rs. 20,000/- per month	2	Hyderabad	No	1. Thorough knowledge of continuity.\n2. Hands-on experience on any DSLR camera (like Canon 5D, etc.).\n3. Creativity and passion in film and cinematography.\n4. The ability to listen to others and to work well as part of a team.\n5. Good written and verbal communication.\n6. Attention to detail.\n7. Time management skills.\n8. Ability to deliver with in deadlines.\n9. Integrity and the zeal to grow.\n	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	live	1
126	104379184185174428302	Associate	- We are working on various live projects in the domains of Venture Funding, Investment Banking, Community Management, Database Enhancement, Event Creation & Management, Co-working, Marketing, Social & Digital Media Management, Content Creation, Software Development, Application Development		Analyst	Minimum 8 weeks	0	25	Mumbai	No	- MS Excel, MS PowerPoint, MS Word, Analytical skills\n- Undergraduates or PG students from any discipline interested in the above areas\n- Looking for people to start immediately, duration will vary with projects\n- Internship type (Part time/ Full time/ Virtual internship) - All three available\n	No	No	No	Informal dress code, Flexible working hours	B-402, Kemp Plaza, Ram Nagar, Malad West, Mumbai, Maharashtra - 400064	277	live	1
148	115375476385745576962	Software Developer	Vision: \nTo redefine the student living experience in India by creating technology-enabled co-living spaces that are tailored to suit their needs and aspirations. \n\nWho we are: \nStanza Living is one of the fastest growing start-ups in India that’s focused on building an exceptional co-living brand for students that they spontaneously connect with. We are a full-stack business and want to build a brand that is first identified and remembered for its quality, a brand whose quality speaks for itself. \nWe want to take away the stress of accommodation-hunting from students and redefine that space with high- quality and professionally managed co-living spaces. We want to offer students something beyond cramped and stuffy rooms, non-existent infrastructure, poor maintenance and a pitiful state of affairs – Stanza Living residences are places where students want to come back to every day, a place that will give them a sense of belonging, of fraternity and of comfort. \nWe’ve already embarked on the journey towards the first phase of being LEGENDARY!\n\n Why Join Us? \n• A phenomenal work environment, with tremendous growth opportunities \n• Opportunity to shape a potential Indian unicorn \n• To learn and grow in a flat office structure that appreciates ownership and respects individual opinions \n• Opportunity to work on cutting-edge technology solutions \n• A place where hard work & smart work is always rewarded \n• Direct impact of the work you do on thousands of college students in India \n• Forever fuelling the hustler, the dreamer, the revolutionary in you \nDesired Skills\nGood with Data Structures and Algorithms, OO Design Patterns,\nJavaEE (Spring,Hibernate), MYSQL, MongoDB\nGood knowledge of Computer Networking and Operating System concepts, Amazon Web services\nComfortable working with front end (Web) technologies - JavaScript / JQuery,\nExposure to Angular, Angular-Ionic, React, React Native will be a plus,\nExposure to Artificial Intelligence/Machine Learning fundamentals will be a plus		SDE	4 weeks	15000	2-3	New Delhi	No	Java, Data Structure, Algorithm, Spring, Hibernate	Desired Skills\n\nGood with Data Structures and Algorithms, OO Design Patterns,\nJavaEE (Spring, Hibernate), MYSQL, MongoDB\nGood knowledge of Computer Networking and Operating System concepts, Amazon Web services\nComfortable working with front end (Web) technologies - JavaScript / JQuery,\nExposure to Angular, Angular-Ionic, React, React Native will be a plus,\nExposure to Artificial Intelligence/Machine Learning fundamentals will be a plus	No	No	5 days working, informal dress code	Stanza Living, 6th Floor, OSE Tower, 5B, Hotel Aloft, Aerocity, New Delhi - 110037	249	live	1
69	107530024622485449869	Frontend Web Application Development Intern	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.Nature of Work:SAAS Product for Training institutes & Financial InstitutionsMicro-services based architecture for scalable solution supporting various use casesData stream platform around Institutes, students and Financial InstitutesProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889353/ecell/ymh5rp6ebameawdimgd4.docx	Frontend Web Application Developer	8 weeks	20000	1	Bengaluru	No	•\tBachelor’s and/or Master’s degree, preferably in CS, or equivalent experience•\tComfortable coding in JavaScript and Typescript.•\tExperience with modern JavaScript libraries and tooling (e.g. React, Redux, Webpack is a plus)•\tFluency in HTML, CSS, and related web technologies•\tDemonstrated knowledge of Computer Science fundamentals•\tFamiliarity with web best practices (e.g., browser capabilities, unit, and integration testing)•\tDemonstrated design and UX sensibilities (Hands on Photoshop, XD is a plus )	NA	No	No	Informal Dress Code, Perks of a pre-series A funded Startup	#365 Shared office, 3rd floor, 5th sector, Outer ring road, HSR Layout, Bengaluru - 560102	224	live	1
73	102540152476572591754	Copywriter & UX Writer	We’re looking for a passionate ‘Copywriter and UX Writer’ who can build crisp, compelling and interactive content that drives desired actions from the user.\n	https://res.cloudinary.com/saarang2017/image/upload/v1550041810/ecell/lqb8nwkkbdkzh8ofipvy.pdf	Copywriter & UX Writer	Minimum 2 months	Rs. 8000/- to Rs. 1000/-	2	Hyderabad	No	1. Good command over the English language with a knack for writing crisp and compelling content across a spectrum of styles and genres.\n2. Prior experience in UX writing, Copywriting or Marketing is an additional advantage.\n3. Ability to understand, align and produce content as per business/marketing requirements, business context and brand philosophy.\n4. Strong editing skills to make the text sharp, short and friendlier in an user-interface.\n5. A flair for integrating visual elements in the content.\n6. A bent for creativity and conceptual thinking to support in strategizing and executing the content marketing plans for campaigns/promotional events.\n7. Should be a team player and be able to deliver the projects effectively on tight deadlines.\n8. Should possess integrity and the zeal to grow.\n	-	No	No	Informal dress code and lunch will be provided for 6 days	30,31, West Wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\nMaps Link: \nhttps://goo.gl/maps/Vpnw18n49M22	235	live	1
135	112150566284259074738	Associate Trainee	Looking for interns to strategize the launch of our upcoming project.		Business Strategist	Minimum 12 weeks	10000	4	Indore, Madhya Pradesh	No	§  Candidate should be excellent in Communication skills, presentation skills, Analytical Approach, Problem-solving skills.\n\n§  Business Strategizational skills & Convincing Skills	Business orientation and analytical approach.	No	No	Informal Dress Code	RackBank Datacenters Pvt Ltd\nFirst Floor, Building Number 1, Crystal IT Park SEZ, Madhya Pradesh, 452001	280	live	1
85	100916162979211575903	Sofware programming in Web frontend, Web backend, Devlopment operations	You would work with a young world-class team of programmers, designers and testers to implement a few cool features. In the process, you would learn how work happens in a startup focused on solid engineering. The specific project you would be assigned would be a combination of your capability and many opportunities at Mammoth, but would broadly be in the area of our technology stack.\nThe technology stack comprises of multiple components such as PostgreSQL, RabbitMQ, Celery, API Servers all deployed on AWS utilizing various services for scale and elasticity. We use the Python based pyramid framework in the backend and angular and Bootstrap on the front-end. Our test and deployment setup uses Ansible and go.cd. We focus heavily on User experience.		Full Stack Internship	10 weeks	15000	1-3	Bangalore	no	Job Description and Skills\nAs an Intern with Mammoth, you will be solving some interesting and challenging problems in different areas of the product. You must already be damn good at programming in at least one programming language. You are expected to be on top of basic computer science concepts in data structures, algorithms, and operating systems. \n\nExperience with one web framework (like Django, flask, pyramid) is a bonus. Else you should have a good idea of javascript and react or angular to take a few interesting challenges on frontend technologies. Or if you are interested in development operations, then you should know about Ansible and appreciate its power.	None	You need to manage yourself	None	Lunch is on on us. Besides this you would have access to food, refrigerator, microwave and a stocked up kitchen. 	104, 1st A Cross, 4th Main\nDomlur 2nd Stage, Bangalore - 560071	250	live	1
95	109249031263145344654	Digital Marketing Intern	- Develop and manage digital marketing campaigns\n- Oversee a social media strategy\n- Write and optimise content for the website and social networking accounts such as Facebook Twitter and Instagram\n- Track and manage the budget for paid online camapigns and bring competitive ROI for the events through those campaigns.\n- Edit and post images, videos, pdf and other required content on different channels.		Digital Marketer	Minimum 8 weeks	7000 INR	1	Ahmedabad	no	Key Skills Required:\n- Intermediate to Advance understanding of Digital Marketing\n- Creative Design & Copywriting skills\n- Basic video editing skills\n\nFamiliarity with Facebook, Instagram and Google Ads will be preferred.	Should be good at creating content.	No	No	Informal Dress Code, Free Lunch, Watching movie during lunch hour, hands-on-experience with real-time company challenges	A-707, Premium House, Nr. Gandhigram Railway Station, Ashram Road, Ahmedabad - 380001.	251	live	1
104	103304235098083374178	Developer	Karomi is a global technology solutions provider, with significant focus across two principal industries - Life Sciences and CPG (Food and Cosmetics). Karomi’s flagship product is ManageArtworks, a Packaging Artwork Management Software that helps regulated industries like Pharmaceuticals and CPG to ensure regulatory compliance of their pack labels. From an Artificial Intelligence standpoint, we provide proofing tools for both image and text comparison along with analytics. We are also working on 3D-modeling, photo realistic rendering with real time ray-tracing in order to model and convert company artworks into photo realistic 3D products. Artwork management is a niche domain, being one of the very few domains where there is scope to combine cutting edge technologies from both Computer Vision and Natural Language Processing in an optimal fashion, along with the possibility to work on Computer Graphics.\n\nAs part of your internship, here are some interesting topics in various aspects, that you could potentially work with us: (Note: We are also open for new interesting ideas that have potential for ManageArtworks):\n1. Machine Learning, Deep Learning:\no Semantic Segmentation for Artwork Vs Non-Artwork type classification\no Transfer Learning to reuse pre-trained models for Artwork Management\no Deep learning for limited data samples: Data augmentation, shallow networks\no Generative Adversarial Networks for rendering realistic artworks to create a large artwork data corpus\no Artwork detection using RCNN\no Shallow neural networks for word embedding or document embedding: word2vec, doc2vec\no Random trees, SVM, decision forests for Artwork Classification, document classification.\no Deep learning based optical flow: Flownet\n\n2. Image Processing and Computer Vision:\no Optimal Image registration using optical flow (dense and sparse optical flow), feature based methods\no Error metrics for complex image data comparison\no Image inpainting for information missing in artworks with text data\no Watershed methods for Artwork selection\no Image compression techniques for extremely large resolution artwork files\n\n3. Computer Graphics:\no Physically based rendering (PBR) of photo realistic 3D artwork from 2D images\no 3D modeling for complex meshes with realistic material shader\no Ray tracing or path tracing with realistic global illumination for complex artwork scenarios\n\n4. Others:\no Mobile app development for our current products (Android studio, Java coding)\no Virtual Reality solution for 3D artwork modeling (Unity knowledge is a must)\n\nApart from the above mentioned ideas, we are open to your new ideas if it seems feasible and has potential.	https://res.cloudinary.com/saarang2017/image/upload/v1550488643/ecell/nlhltlckrqwmx7o2enfd.pdf	Developer: AI, CV, NLP	2 months	10,000 (per month)	2	Work from Karomi's office (preferred) or work from home (based on request)	No	Python (compulsory), C++ . For specific R&D projects, please look at the description or the PDF provided with this portal.	Knowledge on android development if interested in working on a mobile environment.	No	No	Snacks, Hot beverage, Flexible work timings, Independent work and ideas (Guidance will be provided)	Karomi Technology Private Limited, 3rd and 4th Floor, B Block, 56, Thirumalai Pillai Road,, Thirumalai Pillai Lane, Parthasarathy Puram, T Nagar, Chennai, Tamil Nadu 600017	257	live	1
100	111133250649424423782	Interns-Tech	Python Experience + knowledge is desired. - Hands on experience coding in more than one currently popular web application framework. - Experience with any dynamic languages is a big plus. - Should be able to ace problems in data structures and algorithms - Strong knowledge of object oriented design principles - Knowledge of software best practices, like test driven development and continuous integration - Experience working with Agile Methodologies - Experience with UNIX system administration and web server configuration. - Knowledge of Internet protocols and database management systems		Tech-Intern	10-12 Weeks	10000-12000 Per month	4	Jaipur	no	Python Experience + knowledge is desired. - Hands on experience coding in more than one currently popular web application framework. - Experience with any dynamic languages is a big plus. - Should be able to ace problems in data structures and algorithms - Strong knowledge of object oriented design principles - Knowledge of software best practices, like test driven development and continuous integration - Experience working with Agile Methodologies - Experience with UNIX system administration and web server configuration. - Knowledge of Internet protocols and database management systemsOR•\tExperience in optimized UI development for different  OSversions and devices.•\tExperience with Javascripts, html, Angular JS an added advantage•\tFamiliar with RESTful web service•\tStrong experience in Java, XML, and JSON, Web Services and Postgres database.•\tKnowledge of ROR frameworks•\tUnderstand the core concepts of Java, Android and MVC design thoroughly•\tFamiliar with Social Network SDK, Action Bar, Push Notifications, Payment Gateways , Testing Frameworks, & Third Party Libraries•\tIdeal candidate should be a good team player, a self-starter and be able to work independentlyORAndroid Developers	no	NO	No	NO	Voylla Fashions Pvt tldJ-469-471,RIICO Industrial Area,Sitapura, Jaipur-302022	237	live	1
91	110505594872527456493	Data Analyst	DATA ANALYST _ JD\nBasic Background ->  Mathematics and Programming definitely, Operations Research ideally. Some exposure to supply chain management / logistics would be good\n Not particular about which language, but Python or Ruby would be good.  Exposure to Java script and web programming would be great\nEither a bachelors  from IIT or a Masters degree with coursework in Linear Programming, Data Analysis Techniques.\nKnowledge in  data analysis, linear programming and/or machine learning techniques.  Projects  applying these techniques.\nAbility to crush large data pool into insights and plan of action for improving process.\n\nApply linear programming techniques to optimize the Route, Truck Type selection, Contract Selection\nApply feedback from completed trips to optimize further\nLinear programming techniques for managing part loads, stuffing trucks, loading/unloading trucks.\nAnalyse data quality of GPS Vendors.\nAnalyse outliers in Truck costing\nPredicting truck costing for various routes and truck types.\n		Data Analyst	2 months	10000	2	Chennai	no	DATA ANALYST _ JD\nBasic Background ->  Mathematics and Programming definitely, Operations Research ideally. Some exposure to supply chain management / logistics would be good\n Not particular about which language, but Python or Ruby would be good.  Exposure to Java script and web programming would be great\nEither a bachelors  from IIT or a Masters degree with coursework in Linear Programming, Data Analysis Techniques.\nKnowledge in  data analysis, linear programming and/or machine learning techniques.  Projects  applying these techniques.\nAbility to crush large data pool into insights and plan of action for improving process.\n\nApply linear programming techniques to optimize the Route, Truck Type selection, Contract Selection\nApply feedback from completed trips to optimize further\nLinear programming techniques for managing part loads, stuffing trucks, loading/unloading trucks.\nAnalyse data quality of GPS Vendors.\nAnalyse outliers in Truck costing\nPredicting truck costing for various routes and truck types.	\nData Analytics , Python / R Programmers	No	No	Lunch provided 	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in\nLandmark: Kavery Hospital and hyundai showroom	230	live	1
92	110505594872527456493	JAVA	Java developers responsible for building Java / J2EE applications. This includes anything between complex groups of back-end services and their client-end (desktop and mobile) counterparts. Your primary responsibility will be to design and develop these applications, and to coordinate with the rest of the team working on different layers of the infrastructure. Thus, a commitment to collaborative problem solving, sophisticated design, and product quality is essential.\n\n•\tTranslate application storyboards and use cases into functional applications\n•\tDesign, build, and maintain efficient, reusable, and reliable Java code\n•\tEnsure the best possible performance, quality, and responsiveness of the applications\n•\tIdentify bottlenecks and bugs, and devise solutions to these problems\n•\tHelp maintain code quality, organization, and automation\n•\tTeam Player\nSkills\n•\tProficient in Java, with a good knowledge of its ecosystems\n•\tSolid understanding of object-oriented programming\n•\tFamiliar with various design and architectural patterns\n•\tSkill for writing reusable Java libraries\n•\tKnowledge of concurrency patterns in Java\n•\tFamiliarity with concepts of MVC, JDBC, and RESTful\n•\tKnowledge with popular web application frameworks, SPRING, Hibernate, JSF\n•\tFamiliarity with UI Frameworks like JQuery\n•\tKnack for writing clean, readable Java code\n•\tknowledge with both external and embedded databases\n•\tUnderstanding fundamental design principles behind a scalable application\n•\tBasic understanding of the class loading mechanism in Java\n•\tCreating database schemas that represent and support business processes\n•\tTest Driven Approach for Development\n•\tImplementing automated testing platforms and unit tests\n•\tProficient understanding of code versioning tools, such as Git\n•\tFamiliarity with build tools such as Ant, Maven, and Gradle\n•\tFamiliarity with continuous integration like Jenkins\n•\tQuick Learner\n		JAVA	2 months	10000	1	Chennai	no	Java developers responsible for building Java / J2EE applications. This includes anything between complex groups of back-end services and their client-end (desktop and mobile) counterparts. Your primary responsibility will be to design and develop these applications, and to coordinate with the rest of the team working on different layers of the infrastructure. Thus, a commitment to collaborative problem solving, sophisticated design, and product quality is essential.\n\n•\tTranslate application storyboards and use cases into functional applications\n•\tDesign, build, and maintain efficient, reusable, and reliable Java code\n•\tEnsure the best possible performance, quality, and responsiveness of the applications\n•\tIdentify bottlenecks and bugs, and devise solutions to these problems\n•\tHelp maintain code quality, organization, and automation\n•\tTeam Player\nSkills\n•\tProficient in Java, with a good knowledge of its ecosystems\n•\tSolid understanding of object-oriented programming\n•\tFamiliar with various design and architectural patterns\n•\tSkill for writing reusable Java libraries\n•\tKnowledge of concurrency patterns in Java\n•\tFamiliarity with concepts of MVC, JDBC, and RESTful\n•\tKnowledge with popular web application frameworks, SPRING, Hibernate, JSF\n•\tFamiliarity with UI Frameworks like JQuery\n•\tKnack for writing clean, readable Java code\n•\tknowledge with both external and embedded databases\n•\tUnderstanding fundamental design principles behind a scalable application\n•\tBasic understanding of the class loading mechanism in Java\n•\tCreating database schemas that represent and support business processes\n•\tTest Driven Approach for Development\n•\tImplementing automated testing platforms and unit tests\n•\tProficient understanding of code versioning tools, such as Git\n•\tFamiliarity with build tools such as Ant, Maven, and Gradle\n•\tFamiliarity with continuous integration like Jenkins\n•\tQuick Learner\n	JAVA / J2EE \nweb application frameworks, SPRING, Hibernate, JSF	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	live	1
96	110505594872527456493	UI / UX Designer	•\tCollaborate with product management and engineering to define and implement innovative solutions for the product direction, visuals and experience\n•\tExecute all visual design stages from concept to final hand-off to engineering\n•\tConceptualize original ideas that bring simplicity and user friendliness to complex design roadblocks\n•\tCreate wireframes, storyboards, user flows, process flows and site maps to effectively communicate interaction and design ideas\n•\tPresent and defend designs and key milestone deliverables to peers and executive level stakeholders\n•\tConduct user research and evaluate user feedback\n•\tEstablish and promote design guidelines, best practices and standards\nRequirements\n•\tPassion in UI \n•\tDemonstrable UI design skills with a strong portfolio\n•\tSolid experience in creating wireframes, storyboards, user flows, process flows and site maps\n•\tProficiency in Photoshop, Illustrator, OmniGraffle, or other visual design and wire-framing tools\n•\tProficiency in HTML, CSS, and JavaScript for rapid prototyping.\n•\tExcellent visual design skills with sensitivity to user-system interaction\n•\tAbility to present your designs and sell your solutions to various stakeholders.\n•\tAbility to solve problems creatively and effectively\n•\tUp-to-date with the latest UI trends, techniques, and technologies\n•\tknowledge in an Agile/Scrum development process\n\n		UI / UX Designer	2 months	10000	1	chennai	no	UI / UX Designer	Collaborate with product management and engineering to define and implement innovative solutions for the product direction, visuals and experience\n•\tExecute all visual design stages from concept to final hand-off to engineering\n•\tConceptualize original ideas that bring simplicity and user friendliness to complex design roadblocks\n•\tCreate wireframes, storyboards, user flows, process flows and site maps to effectively communicate interaction and design ideas\n•\tPresent and defend designs and key milestone deliverables to peers and executive level stakeholders\n•\tConduct user research and evaluate user feedback\n•\tEstablish and promote design guidelines, best practices and standards\nRequirements\n•\tPassion in UI \n•\tDemonstrable UI design skills with a strong portfolio\n•\tSolid experience in creating wireframes, storyboards, user flows, process flows and site maps\n•\tProficiency in Photoshop, Illustrator, OmniGraffle, or other visual design and wire-framing tools\n•\tProficiency in HTML, CSS, and JavaScript for rapid prototyping.\n•\tExcellent visual design skills with sensitivity to user-system interaction\n•\tAbility to present your designs and sell your solutions to various stakeholders.\n•\tAbility to solve problems creatively and effectively\n•\tUp-to-date with the latest UI trends, techniques, and technologies\n•\tknowledge in an Agile/Scrum development process\n\n	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	live	1
94	110505594872527456493	Android Developer	Android Developer \nInclude:\n•\tDesigning and developing advanced applications for the Android platform\n•\tUnit-testing code for robustness, including edge cases, usability, and general reliability\n•\tBug fixing and improving application performance\n\nWe are looking for an Android Developer who possesses a passion for pushing mobile technologies to the limits. This Android app developer will work with our team of talented engineers to design and build the next generation of our mobile applications. Android programming works closely with other app development and technical teams.\nResponsibilities\n•\tDesign and build advanced applications for the Android platform\n•\tCollaborate with cross-functional teams to define, design, and ship new features\n•\tWork with outside data sources and APIs\n•\tUnit-test code for robustness, including edge cases, usability, and general reliability\n•\tWork on bug fixing and improving application performance\n•\tContinuously discover, evaluate, and implement new technologies to maximize development efficiency\n•\tSolid background in software development, and design patterns\n•\tknowledge with the Android SDK, java, NDK\n•\tknowledge in high quality Android application to the Google Play Store\n•\tknowledge in communication and messaging applications\n•\t Google Maps integration\n•\t Retrofit,Dagger,Realm\n\nRequirements\n•\tBachelor / Masters in Computer Science, Engineering or a related subject\n•\tsoftware development and Android skills development\n•\tAndroid app development\n•\tone original Android app\n•\tknowledge with Android SDK\n•\tknowledge with remote data via REST and JSON\n•\tknowledge with third-party libraries and APIs\n•\tWorking knowledge of the general mobile landscape, architectures, trends, and emerging technologies\n•\tSolid understanding of the full mobile development life cycle.\n		Android Developer	2 months	10000	1	chennai	no	Android Developer \nInclude:\n•\tDesigning and developing advanced applications for the Android platform\n•\tUnit-testing code for robustness, including edge cases, usability, and general reliability\n•\tBug fixing and improving application performance\n\nWe are looking for an Android Developer who possesses a passion for pushing mobile technologies to the limits. This Android app developer will work with our team of talented engineers to design and build the next generation of our mobile applications. Android programming works closely with other app development and technical teams.\nResponsibilities\n•\tDesign and build advanced applications for the Android platform\n•\tCollaborate with cross-functional teams to define, design, and ship new features\n•\tWork with outside data sources and APIs\n•\tUnit-test code for robustness, including edge cases, usability, and general reliability\n•\tWork on bug fixing and improving application performance\n•\tContinuously discover, evaluate, and implement new technologies to maximize development efficiency\n•\tSolid background in software development, and design patterns\n•\tknowledge with the Android SDK, java, NDK\n•\tknowledge in high quality Android application to the Google Play Store\n•\tknowledge in communication and messaging applications\n•\t Google Maps integration\n•\t Retrofit,Dagger,Realm\n\nRequirements\n•\tBachelor / Masters in Computer Science, Engineering or a related subject\n•\tsoftware development and Android skills development\n•\tAndroid app development\n•\tone original Android app\n•\tknowledge with Android SDK\n•\tknowledge with remote data via REST and JSON\n•\tknowledge with third-party libraries and APIs\n•\tWorking knowledge of the general mobile landscape, architectures, trends, and emerging technologies\n•\tSolid understanding of the full mobile development life cycle.\n	Android	no	no	lunch provided	White Data Systems India p ltd\nGanesh Towers 3rd floor,\nNo.152 old no.96/1\nLuz church road, Mylapore\nChennai – 600004\nwww.iloads.in	230	live	1
102	117894875203741245699	Android Developer Intern	Driver Friends is an early stage startup solving multiple day-to-day painpoints for Drivers. Our first app is a P2P communication tool for drivers, and is launching soon.\n\nWe are hiring for an android developer intern. Ideal candidates will have:\n- Published at least one app to the playstore (please share link in application)\n- Great knowledge of Android design patterns and architecture components: room, livedata, viewmodel etc\n- Good to have: experience with Postgres, Firebase functions, Apollo GraphQL, Maps and location related APIs\n- Willingness to work in an early stage startup (team = family, high ownership, flexible hours, lots of experiments, agile workflow)		Android Developer	2 months	10000	2	Remote	no	Ideal candidates will have:\n- Published at least one app to the playstore (please share link in application)\n- Great knowledge of Android design patterns and architecture components: room, livedata, viewmodel etc\n- Good to have: experience with Postgres, Firebase functions, Apollo GraphQL, Maps and location related APIs\n- Willingness to work in an early stage startup (team = family, high ownership, flexible hours, lots of experiments, agile workflow)	Android Developer Studio	No	No	Work from home; Early seat in a startup affecting potentially a million lives; more involvement post-internship if work is good, leading up to a job offer	22, Car Street, Ulsoor, Bangalore - 560008	246	live	1
105	105373738578694994605	Animator	We are looking for a creative Animator to develop excellent visual frames with 2D/3D or other techniques. Your work should give life to storylines and characters in videos.		Animator	Minimum of 2 months	 Rs. 10,000/- to Rs. 20,000/-	2	Hyderabad	No	Knowledge of 2D/3D and computer-generated animation.\nA creative storytelling with presentation abilities.\nAbility to deliver with in deadlines.\nPatient and being able to concentrate for long periods.\nIntegrity and the zeal to grow.\nTeamwork and excellent communication skills.\nDegree in computer animation, 3D/graphic design, fine arts or relevant field is an additional advantage.\nPrior experience in project management is an additional advantage.	No	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	live	1
106	105373738578694994605	Video Editor	We are looking for a talented video editor to assemble recorded footage into finished projects that match director’s vision and are suitable for broadcasting.		Video Editor	Minimum 2 months	 Rs. 10,000/- to Rs. 20,000/-	2	Hyderabad	No	1. Thorough knowledge of timing and continuity.\n2. Hands on experience on any video editing software (like premiere pro, final cut pro etc).\n3. Creativity and  passion in film and video editing.\n4. The ability to listen to others and to work well as part of a team.\n5. Time management skills.\n6. Ability to deliver with in deadlines.\n7. Integrity and the zeal to grow.	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	live	1
108	105373738578694994605	VFX Designer	\niB Hubs is looking for  talented, enthusiast VFX artists who understands and has mastered the techniques of any 2 of the vfx sectors (tracking, rotoscopy, modeling, texturing, rigging, animation, lighting, compositing) to join them in the creation of corporate videos, advertisements etc.\n		VFX Designer	Minimum of 2months	Rs. 10,000/- to Rs. 20,000/- per month	2	Hyderabad	No	1. Knowledge and proficiency in at least 2 of mentioned departments (Lighting, Matchmove, Fx Simulations, Roto, Animation). \n2. Knowledge in vfx graphic software like 3DS MAX/  MAYA 3D/ NUKE X/ HOUDINI/AUTODESK COMBUSTION/EYEON DIGITAL FUSION.\n3. Bachelor's degree in Visual Arts or Computer Arts or comparable professional experience will be an added advantage.\n4. Ongoing interest in, and knowledge of, current design and graphics trends.\n5. Should be able to produce the graphic solutions that are consistent with brand and style guidelines.\n6. Highly organized and detail-oriented with the ability to work efficiently in fast-paced environment, while meeting tight deadlines.\n7. Must be able to take full and independent ownership of demanding projects, while also being able to take direction from co-workers and producers.\n8. Excellent communication skills.\n9. Integrity and the zeal to grow.\n	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	live	1
111	105373738578694994605	Motion Graphics Designer	The Motion Graphics Designer will be responsible for creating and designing engaging graphics to support videos aligned with our optimistic target brand voice.		Motion Graphics Designer	Minimum of 2 months	Rs. 10000-20,000/-	2	Hyderabad	No	1. Knowledge and proficiency in the latest Adobe Creative Suite (After Effects, Premiere). \n2. Ongoing interest in, and knowledge of, current design and graphics trends.\n3. Should be able to produce the graphic solutions that are consistent with brand and style guidelines.\n4. Highly organized and detail-oriented with the ability to work efficiently in fast-paced environment, while meeting tight deadlines.\n5. Must be able to take full and independent ownership of demanding projects, while also being able to take direction from co-workers and producers.\n6. Excellent communication skills.\n7. Integrity and the zeal to grow.\n8. Bachelor's degree in Visual Arts or Computer Arts or comparable professional experience will be a added advantage.\n9. Knowledge in vfx graphic software like Cinema 4D/Maya 3D etc, will be an added advantage.\n	Nothing.	No	No	Lunch will be provided	 30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032	234	live	1
116	113564221505157815723	Graphic Designer	It’s time to tell your stories with illustrations. \n\nInvolve, an Ed-Startup based on the realm of peer teaching who believes in revolutionising the education system. We are hiring people with creative brains to expand their Graphic Design department. \n\nThese candidates will be working on a broad spectrum of Visual Communication consisting of Illustrations, Typography,  Page layout techniques, etc. to create Visual Compositions on Digital Media. \n\nCandidates will be working on Corporate Designs such as Logos and Branding, Editorial design, and Advertising such as Posters. We are looking for a trustworthy individual with a fair sense in Aesthetics and experience in Design tools such as Adobe Illustrator or any tools which deal with vector graphics.		Graphic Designer	Minimum 4 weeks	3000-8000 (Depending on work)	2	Chennai or Bangalore	No	Adobe Photoshop, Illustrator or any other vector graphics software	Should have worked on some design projects!	No	No	Informal dress code, Opportunity to work with founders, Huge Networking 	Department of Management Studies, IIT Madras	236	live	1
113	101107640131204357570	Full Stack Developer / Backend Developer	Full stack / Back end developer -  MEAN Stack or Node Js or Python (Django/Flask),MongoDB/ NoSQL or firebase, SSH, Commandlines, AWS S3, Cryptography, etc		Developer (Full stack/Back-end)	Minimum 8 - 12 weeks	15000	4	Hyderabad	No	Full stack / Back end developer -  MEAN Stack or Node Js or Python (Django/Flask),MongoDB/ NoSQL or firebase, SSH, Commandlines, AWS S3, Cryptography, etc	NA	No (Many affordable PGs available around the campus)	No	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
117	113564221505157815723	Full Stack Developer	We believe that technology can be a huge enabler in scaling impact solutions around the world. We at involve are building first of its kind mobile application that will support our operations and put Involve as a global organisation. This will be the key factor in scaling our operations to help a million school students in 5 years. If you are the one who is looking to build technologies for social Impact, Involve would be the right place to begin your journey. \nThe mobile application will be used by the Involve team and the students for their leadership development, program assessment etc.\nThis project has already started and we are looking for smart & passionate people who can take it to the end. 		Full Stack Developer	6 Weeks	5000-10000 per month	1-2	Chennai	No	Java, Android Studio, Web services	Should have worked on some mobile application project before	No	No	Working with Founder, Opportunity to interact with people who build Aadhar, Networking 	IIT Madras	236	live	1
136	109683991238473547277	Development of tool for Protein and DNA Data analysis using AI methods 	Intern have to involve in data analysis for protein structure and  gene sequence using AI methods , he may require to code for custom application with current team of expert. 		Data Analytics 	Minimum 4 week	5000	1-2	Bio-Incubator, Phase 2 , IIT Madras -Research Park	yes	Python , Statistics , Artificial Intelligence 	Should know programming	No	No	NA	Medha Innovation and Development Pvt. Ltd \nBio-Incubator , Phase 2 , IITMIC - research park, Chennai	259	live	1
118	101396729595279031815	Sales & Marketing	Sales-Intern Job Duties & Responsibilities\nConnecting with colleges for seminars, workshops and other events\nCommunicating with campus ambassadors of Chatur Ideas for delegation of tasks\nCollaborating with E-Cells of different colleges for future correspondence such as E-Summits, Startups Support, Workshops, etc.\nCompetitive Analysis and Market Survey  for new startups approaching Chatur Ideas\nResearch and Build relationships with New clients.\nReach out to customer leads through cold calling.\nEstablish, develop and maintain positive business and customer relationships.\nLead Generation through networking, Database, CRM.\nAnalyze the territory/market's potential, track sales and status reports.\n\nSkills Required\nGood communication skills\nGood written and verbal English communication \nGood negotiation skills\nKnowledge of MS.Office (Ms. Excel, Word, Powerpoint) is must\nInternet savvy\n		Sales & Marketing	2-3 Months	5000 - 15000 INR + Incentives	3-5	Work From Home, Mumbai Office	Yes	Skills Required\nGood communication skills\nGood written and verbal English communication \nGood negotiation skills\nKnowledge of MS.Office (Ms. Excel, Word, Powerpoint) is must\nInternet savvy\n	MS. Office well versed	NO	NO	Informal Dress Code	Chatur Ideas, 101, Kuber, Andheri Link Road, Andheri (W), Mumbai – 400053.	262	live	1
123	105202096528458362102	AI Analyst Programmer	Organizations across globe have invested in establishing granular levels of data points to develop deep level of understanding about their customers. This includes marketing, leads, sales, on boarding, fulfillment support and every other thinkable stage in the journey of a customer. In parallel, there has been technology revolution which has made it possible to analyse large scale of data sets to generate insight about the customers. At Genesys, we are looking to help our clients leverage their investment in large data sets to improve business outcomes and drive better customer experience.  		AI Analyst Programmer	Minimum 8 weeks	25000	2-3	SP Infocity, Perungudi, Chennai	No	-\tHave exposure to Extract, Transform and Load (ETL) tasks and related tools/interfaces like Athena, Kafka, Kinesis, S3 and Redshift Data marts\n-\tConversant with SQL across range of database platforms like MS SQL, Oracle, PostgreSQL, Redshift \n-\tCan understand discrete and continuous data sets with ability to identify right mathematical models for making high precision predictions.  \n-\tHave applied Natural language understanding (NLU) and Natural Language Programming (NLP) concepts to unstructured textual data.  \n-\tProgramming skills in any f the following languages of Python, R, Scala	Right candidate will be able to extract, clean and process data to build mathematical models for predicting business outcomes. The candidate will have excellent analytical capability to see through data patterns underlying a business problem. Ideal candidate would enjoy building a statistical view of the business problem and come up with independent algorithm to solve these problems. They will have a learning attitude to pick up new technologies, tools and programming on the go with a self-help approach.  	No	No	No	Genesys Telecom Lab India\nGlobal Infocity (SP Infocity), C Block, 4th Floor \n40, MGR Salai, Perungudi, Chennai	272	live	1
125	104089503500603657430	Project Intern	Qualifications: BE/B-Tech – Electronics and Communications.\nPrimary Role/Scope of Job: \n•\tDeveloping verilog code.\n•\tDefining verification methodology\n•\tBuilding a test bench for self-checking verification.\n•\tModeling of IP to verify RTL functionality vs. requirements.\n•\tWork with software team to implement changes required by the driver. \n•\tModify the design for future features in the FPGA. \n•\tUnderstand over-all chip power save modes and external system requirement.  		FPGA RTL Designer/Hardware Designer	Minimum 8 weeks	10k per month	2-3	Bangalore	Yes	•\tStrong knowledge of ASIC and/or FPGA design methodology and should be well versed in front-end design, simulation, and verification CAD tools.\n•\tExcellent verbal, written and communication skills are required.\n•\tExcellent follow-through, motivation, and persistence\n•\tStrong technical judgment\n•\tKnowledge of digital board design and signal integrity principles is a plus	•\tHas deep knowledge of Xilinx FPGA implementation and tools.\n•\tExperience in state of the art tools and flows.\n•\tSound Knowledge of logic design and RTL implementation\n•\tBoard level testing to validate RTL design\n•\tDesign Documentation\n•\tExperienced with VHDL (desirable)\n•\tActive participation in internal Design Reviews (desirable)\n•\tEthernet - 100/1000 Mbps \n•\tPCIE 2.0 \n•\tSPI\n•\tUART	No	No	5 days a week, informal dress code, fun outings/celebrations	Centenary Building, 2nd Floor, East Wing, MG Road, Bangalore-560025, Karnataka.	258	live	1
137	109683991238473547277	Bioinformatics Analysis using BigOmics and other application 	Task is to perform comparative experiment with different use case and benchmark the accuracy of output. Task may vary across the duration of internship based on requirement. Final outcome may be a publication.		Bioinformatics Analyst	4 week	5000	1-2	Phase2, Bioincubator,  IITMIC - Research Park	yes	Bioinformatics tools understanding , Biological data understanding 	Bioinformatics awareness 	No	No	No	Medha Innovation and Development Pvt. Ltd\nBio incubator , Phase 2 , IITMIC - Research park , Chennai	259	live	1
115	101107640131204357570	Hologram designers or Developers with experience in Voice/Facial recognition, Bot Analytics, VR/AR and Blockchain experts	Technical experts for Hologram designers, Voice/Face recognition, Data analytics, VR/AR and Blockchain experts		Hologram designers or Developers with experience in Voice/Facial recognition, Bot Analytics, VR/AR and Blockchain experts	Minimum 5 - 12 weeks	15000	2	Hyderabad	No	Looking for Hologram designers, Data Analytics, Voice/Face recognition, VR/AR and Blockchain experts	None	No (Many affordable PGs near the campus)	No	 5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
127	111320166102807820736	Data Science 	Peacock Solar is a Sangam Ventures, Gurgaon, incubated startup aimed at accelerating mass adoption of residential rooftop solar in India, through standardized product offering, easy financing, and efficient execution at scale. Founded by IIT, ISB & IIM alumni, Peacock Solar has been recognized as one of the top 9 innovative ideas in Climate Finance Lab's idea cycle of 2018. Since its inception, Climate Finance Lab ideas have mobilized more than $1.2 billion towards sustainable development. Recently, Peacock Solar has been awarded grant support by US-India Clean Energy Finance for project preparation support. Interns would assist Peacock Solar in optimizing marketing & operations by analyzing existing customer data, creating segmentation models, analyze campaign level data and source data. You'd get involved in the core data team and work with them towards running projects in optimization and process improvement. Detailed tasks are as follows - •\tSelecting features, building and optimizing classifiers using machine learning techniques•\tData mining using state-of-the-art methods•\tExtending company’s data with third party sources of information when needed•\tEnhancing data collection procedures to include information that is relevant for building analytic systems•\tProcessing, cleansing, and verifying the integrity of data used for analysis•\tDoing ad-hoc analysis and presenting results in a clear manner•\tCreating automated anomaly detection systems and constant tracking of its performance•\tExtract/Transform/Clean the data and generate the reports •\tApplying predictive analysis to create strategy of marketing targeting and positioning•\tBuild the Predictions Model and Intelligently selection of variables. •\tDevelop company A/B Testing Framework and test model quality•\tDevelop process and tools to monitor and analyze model performance and data accuracy.		Data Science Internship	10 weeks	10000	2	Gurgaon	No	•\tExcellent understanding of machine learning techniques and algorithms related to regression / clustering/predictions/anomaly, such as k-NN, Naive Bayes, SVM, Decision trees, Random forests, etc.•\tExperience with common data science toolkits, such as R, Python etc.•\tGreat communication skills•\tExperience with data visualization tools, such as D3.js, GGplot, Tableau etc.•\tProficiency in using query languages such as SQL•\tGood applied statistics skills, such as distributions, statistical testing, regression, etc.•\tGood scripting and programming skills •\tKnowledge of PHP, Javascript•\tExperience in Web Services like AWS, Mysql Dbs, •\tData-oriented personality with experience working in similar field. 	NA	NO	NO	Flexible hours, informal dress code, Open leave policy	Peacock Solar, C/o Sangam Ventures, 5th Floor, Plot 146, Sector 44, Gurgaon - 122002	263	live	1
138	105500817840272313799	Write code that will empower people with disabilities!	Are you passionate about writing code that is so amazing that it can change lives, literally?\nHave you dreamed about building technology to empower people with disabilities? Are you\nexcited to take on challenges? Does constant learning give you a high? \nIf this describes you, we would love to have you on our team!\n\nAs a Mobile App Developer Intern at Invention Labs, your responsibilities will include:\n\n1. Work with Android/iOS and other mobile app technologies (like Flutter) to develop new or improve existing mobile applications\n2. Working with the team to brainstorm ideas on product features\n3. Maintaining technical documentation of the work\n4. Creating the next generation of assistive technology products\n5. Working to solve real-life problems faced by children with special needs around the world\n6. Working closely with product development and understand what goes into making products that impacts people lives significantly\n		Mobile App Developer Intern	Minimum 7 weeks	12000	2	Chennai	Yes	Java & Android app development\nor Swift/Objective-C\nor Flutter 	Ready to learn any new programming language/technology	No	No	The incentive to change people's lives!	IIT Madras Research Park \n4th Floor, Taramani, Chennai - 600085\n	285	live	1
139	117306459721549242620	Machine Learning and Computer Vision	The Candidate should be a highly motivated, detail-oriented individual to join our team and work in a MedTech startup environment. The candidate will be developing computer vision and artificial intelligence algorithm for a handheld medical device/application. The candidate shall perform full software lifecycle development within a multidisciplinary team environment.  Duties would include solution building for the concept, algorithm development, software engineering, data/image handling, implementation, and testing.	https://res.cloudinary.com/saarang2017/image/upload/v1550826952/ecell/qkmdov0tx1uvrfljshpp.pdf	Machine Learning Engineer	2 Months	10000	2	Chennai	Yes	 MATLAB, OpenCV and relevant - Image processing, Object detection and piecewise Pattern Matching and recognition, studio/Eclipse integrating OpenCV Library. 	Should have basic knowledge of Biology and medical devices	No	No	Certificates	Curneu MedTech Innovations Private Limited, No.1, 5th Floor, IIT Madras Research Park, Taramani, Chennai - 600113	281	live	1
140	117306459721549242620	CAD - Micro Mechanics, Robotics &  Rapid Prototyping	The Candidate should be an experienced, detail-oriented individual to join our team and work in a MedTech startup environment. The candidate will be involved in designing models of medical devices and surgical tools, rapid prototyping and, micromechanical system development. Duties would include solution building for the concept ideas, design planning, human-centered designing, and analysis.	https://res.cloudinary.com/saarang2017/image/upload/v1550826830/ecell/lrrdhjz3ayis8zjxgzsa.pdf	CAD Mechanical Designer	2 Months	10000	1	Chennai	Yes	Solidworks, Catia or Creo	Should have basic knowledge in biology and medical devices.	No	No	Certificates.	Curneu MedTech Innovations Private Limited, No.1, 5th Floor, IIT Madras Research Park, Taramani, Chennai - 600113	281	live	1
141	103765838603107363304	Marketing Intern	Looking for enthusiastic marketing interns to join our team and provide creative ideas to achieve our goals. You will also have administrative duties in developing and implementing marketing strategies while helping maintain and expand our existing channels.\nThis internship will help you acquire marketing skills and provide you with knowledge of various marketing strategies. Ultimately, you will gain broad experience in marketing and should be prepared to enter any fast-paced work environment.\nWe are looking for talented individuals who are willing to step out of their comfort zone to join us in making history.\nCome join the #AIRecruitingRevolution		Marketing	4-12 weeks	15000	1-2	Hyderabad	No	Strong Verbal/Written Communication Skills\nProblem Solving Skills\nPassion for Marketing	NA	No	No	5-day weeks, Informal Dress code, A dynamic start-up environment that inspires camaraderie	Vindhya C-6, CIE, IIIT Hyderabad,\nGachibowli, Hyderabad, Telangana	286	live	1
142	103765838603107363304	Software Engineering Intern	As a member of the Software Dev Team, you will be building high-quality products in the Recruiting Automation Space. You would design and write code that is reliable and robust, highly scalable and offers a great user experience. You don’t just code features, you will take ownership of them, cross-collaborate across teams, design solutions, implement them, and see them through till they are live in production. Being part of a nimble and agile team, you are creative and can come up with solutions to problems in any aspect of the product and take the initiative to solve them. \nWe are looking for talented individuals who are willing to step out of their comfort zone to join us in making history.\nCome join the #AIRecruitingRevolution.		Software Engineer	4-12 weeks	15000	3-5	Hyderabad	No	Highly Skilled with at least one of Python, Django, PostgreSQL\nWorking knowledge of AWS is a plus	NA	No	No	5-Day Weeks, Informal Dress Code, Fast-paced Dynamic Work Environment	Vindhya 6-6, CIE, IIIT Hyderabad,\nGachibowli, Hyderabad, Telangana	286	live	1
143	105500817840272313799	Write Web Apps to Empower people with special needs	Are you passionate about writing code that is so amazing that it can change lives, literally?\nHave you dreamed about building technology to empower people with disabilities? Are you\nexcited to take on challenges? Does constant learning give you a high? \nIf this describes you, we would love to have you on our team!\n\nAs a Web App Developer Intern at Invention Labs, your responsibilities will include:\n\n1. Work with Python and other web technologies to develop new or improve existing web applications\n2. Working with the team to brainstorm ideas on product features\n3. Maintaining technical documentation of the work\n4. Creating the next generation of assistive technology products/services\n5. Working to solve real-life problems faced by children with special needs around the world\n6. Working closely with product development and understand what goes into making products that impacts people lives significantly		Web App Developer Intern	Minimum 7 weeks	12000	2	Chennai	Yes	Good programming skills	Python\nJavaScript \nBasic knowledge of CSS, HTML	No	No	Ship code that will empower people with disabilities!	IIT Madras Research Park\n4th Floor, \nTaramani, Chennai - 600113	285	live	1
124	103319782156851133364	Pathogen Detection with Spectroscopic Techniques- Proof of Concept	The conventional technique to detect the Pathogens is to follow Microbiology.  These techniques are time consuming and labor intensive.   Alternate technologies are needed to speed up the detection (and with quantification).  The emerging Spectroscopic techniques have the potential to detect the molecular species (either organic or inorganic). The present project by M/s Thin Film Solutions is to explore the potential of Spectroscopic techniques to detect the bacteria and pathogens.  		Research Internship	Minimum SIX to EIGHT weeks 	0	2	Chennai	YES	Basic knowledge in microbial cell culture and basic knowledge of Optics (of undergraduate level). Should have a good flare for conducting experiments. 	Attitude for research	The Intern has to look for his accommodation	2 AC travel from the Home town of teh Intern	Informal Dress. SIX day week. 	Dr A Subrahmanyam, M/s Thin Film Solutions, C-2 3rd Loop Road, IIT Madras, Chennai 600036. 	274	live	1
107	114749538391689307031	Data Science Intern	Trapyz is an AI-driven consumer intent to insights SaaS platform with a privacy-first focus to map real-world consumer journeys for brands.You’ll be challenged to create innovative solutions using location data generated through millions of logs using Time series Analysis and Forecasting. Also, you’ll be given sole responsibility to build visualization tools for our data which can identify trend, pattern and noise. 		Data Science	8-12 Weeks	15000	2-3	Bangalore	No	Trapyz is an AI-driven consumer intent to insights SaaS platform with a privacy-first focus to map real-world consumer journeys for brands.You’ll be challenged to create innovative solutions using location data generated through millions of logs using Time series Analysis and Forecasting. Also, you’ll be given sole responsibility to build visualization tools for our data which can identify trend, pattern and noise. As a DS intern you will be responsible for:•\tDoing a lot of hands-on programming •\tWorking closely with the Founders and the Product Head to translate the business requirements into technical executionImportant skills to have: •\tProgramming Python. Strong background in statistics and mathematics •\tKnowledge of AWS, Machine Learning, S3, Dynamo DB etc•\tGood verbal and written communication skills	NA	No	Yes	5 Days a week	PlanetWorx Technologies Pvt Ltd,CoWrks, Purva Premiere, Residency Rd, Shanthala Nagar, Ashok Nagar, Bengaluru, Karnataka 560025	242	live	1
72	110447218383396106962	SKC_IT	All the selected and qualified SKC_IT interns will be assigned under live project. 1- Web Designer : He/she will be responsible for developing a live dynamic website. Credentials pertaining to hosting and server details will be provided later. 2- App Developer : You have the inclination but don’t find the right platform to showcase your coding skills . Don’t worry, Sit back ! “ScrapKaroCash” is here. 3- Creative Content Writer : A Writer who is worthy enough to express it’s requirement in a innovative & creative way. 4- Software Developer :  A techie who’s smart to understand company work flow and give us URL address. Yes! We need a coder who not only understand the complexity of the work flow but also provide us solution in an effective way.	https://res.cloudinary.com/saarang2017/image/upload/v1549979932/ecell/dbuvatv9bjvltunwqglg.jpg	•Web Designer • App Developer • Creative Content Writer •Software Developer	8 weeks	• Creative Content Writer- Certificate will be provided, No stipend. For others INR  ₹ 25,000/- on successfully project completion distribution fairly. Moreover certification will be provided to them.	8-10	Work From Home	No	PHP SEO HTML/CSS Java Script Photoshop Word Press UI designer Content Writer C# Cross-Platform App Development	• Analytical Skills -Most successful websites are functional but consumer behaviors are changing therefore to meet their expectations design, coding, and development skills will always evolve to satisfy the ever-changing consumer.Therefore, web developers need a strong understanding of consumers. Especially web consumers.• Responsive Design.	NA	NA	NA	GIT Incubation Center,Udyambagh, BelagaviKarnataka	232	live	1
\.


--
-- Data for Name: student_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_details (id, full_name, roll_num, college, branch, cgpa, contact_number, alt_contact_number, alt_email, is_paid, payment_link, payment_id, user_hid, payment_request_id, resume_url) FROM stdin;
37	Mritunjoy Das	AE16B111	\N	\N	\N	9435840783	\N	\N	t	https://www.instamojo.com/@joeydash/cfbc308320e540a9bd38a95474a8a240	\N	112396581591786005083	cfbc308320e540a9bd38a95474a8a240	\N
38	Meghana E	16wh1a1216	\N	\N	\N	7093256911	\N	\N	f	https://www.instamojo.com/@joeydash/723998f4859f4a7eaea67bfb5673e707	\N	103752593630791624652	723998f4859f4a7eaea67bfb5673e707	\N
23	Neeraj	Jadhavar	\N	\N	\N	7776081403	\N	\N	f	https://www.instamojo.com/@joeydash/ed3c7c7d31fa4fd7a0af702429468f5d	\N	101532661979094815998	ed3c7c7d31fa4fd7a0af702429468f5d	\N
39	Abhishek Tigga	ee17b101	\N	\N	\N	8290993926	\N	\N	f	https://www.instamojo.com/@joeydash/01bf19f7147545fb84a3e3364df833e9	\N	104162540670104310859	01bf19f7147545fb84a3e3364df833e9	\N
40	Thirumala Reddy Manisha Reddy	16wh1a05b6	\N	\N	\N	8328258020	\N	\N	f	https://www.instamojo.com/@joeydash/0ddd5805cf6945f391d94165d6427805	\N	113501286160076496682	0ddd5805cf6945f391d94165d6427805	\N
42	Siddhant Toknekar	ED18B031	\N	\N	\N	9130213213	\N	\N	f	https://www.instamojo.com/@joeydash/0e6e76bde19847559cb0194e5ba0b929	\N	116786289933147386527	0e6e76bde19847559cb0194e5ba0b929	\N
27	Saurabh Jain	ME16B071	IITM	Mechanical Engineering	9.37	8559931413	9940312393	me16b071@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/5bf424c3354b48f4ba939f2ed2750c18	MOJO9223J05A71988827	107156601039704846020	5bf424c3354b48f4ba939f2ed2750c18	\N
28	Mukund Khandelwal	ME16B152	\N	\N	\N	7000338552	\N	\N	f	https://www.instamojo.com/@joeydash/fbeb89711ec8431c9e0915664455dc82	\N	103158308128328545694	fbeb89711ec8431c9e0915664455dc82	\N
30	Samyak Jain	EE17B116 	\N	\N	\N	7999675599	\N	\N	f	https://www.instamojo.com/@joeydash/9c364ef51e6d466f9c62bc85a6f81979	\N	103656407720006034171	9c364ef51e6d466f9c62bc85a6f81979	\N
32	Saurabh	ME16B071	\N	\N	\N	9940312393	\N	\N	f	https://www.instamojo.com/@joeydash/396d9f2e58794550a0a2572eb13c4aef	\N	110553366885836969408	396d9f2e58794550a0a2572eb13c4aef	\N
36	Akshat Nagar	ee17b122	\N	\N	\N	8962705800	\N	\N	f	https://www.instamojo.com/@joeydash/7fc523c209a44da9bb8475798ca65359	\N	112955715421977386894	7fc523c209a44da9bb8475798ca65359	\N
43	Sai Rohitth Chiluka 	ED18B027 	\N	\N	\N	9381582625	\N	\N	f	https://www.instamojo.com/@joeydash/f383e30d72de4cb8b971a57b1a5ee528	\N	101827448437274338234	f383e30d72de4cb8b971a57b1a5ee528	\N
44	Monika Nathawat	NA18B027	\N	\N	\N	9214406296	\N	\N	f	https://www.instamojo.com/@joeydash/fd2c2783ef11460aae7ee17a57f3dde0	\N	101807814707039385860	fd2c2783ef11460aae7ee17a57f3dde0	\N
45	T B Ramkamal	EE18B153	\N	\N	\N	7550168631	\N	\N	f	https://www.instamojo.com/@joeydash/50a1ee8d42bb4f9baf78f43555035277	\N	106346546956435892842	50a1ee8d42bb4f9baf78f43555035277	\N
46	Rohan Narayan 	EP18B028	\N	\N	\N	8129510549	\N	\N	f	https://www.instamojo.com/@joeydash/6a8e81bdaac740369b5b69110875352e	\N	110035970755160527050	6a8e81bdaac740369b5b69110875352e	\N
47	Sukrit Kumar Gupta	CE16B013	\N	\N	\N	9454199718	\N	\N	f	https://www.instamojo.com/@joeydash/1c3dc1aab86147008dba4a3e7a76377d	\N	113046604995058376278	1c3dc1aab86147008dba4a3e7a76377d	\N
48	Shashank M Patil 	Ch18b022	\N	\N	\N	6362748509	\N	\N	f	https://www.instamojo.com/@joeydash/40a8a150efd54e3c8fb850218240f848	\N	114832114521563248786	40a8a150efd54e3c8fb850218240f848	\N
49	Amarnath Prasad	AE18B001	\N	\N	\N	8972637830	\N	\N	f	https://www.instamojo.com/@joeydash/2840a37faa7f418eacb8295a2cc25569	\N	110088160541028725569	2840a37faa7f418eacb8295a2cc25569	\N
50	Aditya Parag Rindani	ME18B037	\N	\N	\N	7506072729	\N	\N	f	https://www.instamojo.com/@joeydash/c36b0f823a4044a78131a05ddf06edc7	\N	106151943570612705662	c36b0f823a4044a78131a05ddf06edc7	\N
51	Prajeet Oza	MM17B024	\N	\N	\N	8767888916	\N	\N	f	https://www.instamojo.com/@joeydash/957d2ddf4829467281c64796bd71d6e6	\N	100180464561448951684	957d2ddf4829467281c64796bd71d6e6	\N
52	Aditya kommineni 	Ee17b047	\N	\N	\N	8309801301	\N	\N	f	https://www.instamojo.com/@joeydash/9b09a887b0a94286bcaaf229661a3a13	\N	103517082880442482622	9b09a887b0a94286bcaaf229661a3a13	\N
54	Divika Agarwal	Ch17b043	\N	\N	\N	9167879798	\N	\N	f	https://www.instamojo.com/@joeydash/9998d92d7c914273980d4002652d8f0f	\N	102052775561051041362	9998d92d7c914273980d4002652d8f0f	\N
55	Rutvik Baxi	Ed18b050	\N	\N	\N	8866419419	\N	\N	f	https://www.instamojo.com/@joeydash/8ddb6621a8834d8a941019cb7e5398fc	\N	117005101380398480170	8ddb6621a8834d8a941019cb7e5398fc	\N
56	Amrit Sharma	EP18B015	\N	\N	\N	8586824098	\N	\N	f	https://www.instamojo.com/@joeydash/9ce682100d6c435688436ff39515cb6f	\N	117068008597284134843	9ce682100d6c435688436ff39515cb6f	\N
57	Siddharth Lotia	18101046	\N	\N	\N	9406020745	\N	\N	f	https://www.instamojo.com/@joeydash/2e4a66e68d9e487bb2f6eeec8d07fefc	\N	113814269201509832881	2e4a66e68d9e487bb2f6eeec8d07fefc	\N
58	Neel Balar	Ed18b019	\N	\N	\N	9663329307	\N	\N	f	https://www.instamojo.com/@joeydash/f31a6c2943ae4359b83f529c6f7e60b3	\N	110086250388526798686	f31a6c2943ae4359b83f529c6f7e60b3	\N
59	Harshita Ojha	Bs17b012 	\N	\N	\N	9009800655	\N	\N	f	https://www.instamojo.com/@joeydash/d1906d410bd34c8698419e0847d2d6cf	\N	101052355478693521918	d1906d410bd34c8698419e0847d2d6cf	\N
60	Sourabh Thakur	Ch17b022	\N	\N	\N	7062940762	\N	\N	f	https://www.instamojo.com/@joeydash/8daaa9eb1cb3454c847a21fe292fcbf3	\N	108046082470898711935	8daaa9eb1cb3454c847a21fe292fcbf3	\N
61	Pranav Dayanand Pawar	MM17B003	\N	\N	\N	9521379785	\N	\N	f	https://www.instamojo.com/@joeydash/819f779c46ef42f38f9ff8ad34cd5ef4	\N	102139067499961218783	819f779c46ef42f38f9ff8ad34cd5ef4	\N
62	Parth Doshi	BE17B024	\N	\N	\N	8884647279	\N	\N	f	https://www.instamojo.com/@joeydash/026dbe681bba42d4b8b656dfe9f991ca	\N	109694605773547105071	026dbe681bba42d4b8b656dfe9f991ca	\N
63	KASHYAP AVS	ED17B026	\N	\N	\N	7337421279	\N	\N	f	https://www.instamojo.com/@joeydash/a2538cc394b54752b71ac17072756a9c	\N	112693133093914151701	a2538cc394b54752b71ac17072756a9c	\N
65	SREE VISHNU KUMAR V 	ED18B032	\N	\N	\N	7904754979	\N	\N	f	https://www.instamojo.com/@joeydash/90ca614ee6f5441bafa59edbd53450b4	\N	116987835442491396459	90ca614ee6f5441bafa59edbd53450b4	\N
66	Unnat Gaud	ch18b004	\N	\N	\N	9930881423	\N	\N	f	https://www.instamojo.com/@joeydash/36727675088040d59d31f59b2a4862ea	\N	108716062842174923272	36727675088040d59d31f59b2a4862ea	\N
68	Ayush Toshniwal	EE17B157 	\N	\N	\N	8975051167	\N	\N	f	https://www.instamojo.com/@joeydash/9bedd873bb1d4f60b923be97eaecd0b4	\N	101411725174892658523	9bedd873bb1d4f60b923be97eaecd0b4	\N
53	Subhankar Chakraborty	EE17B031	IITM	ELectrical Engineering	9.40	8328960847	null	null	t	https://www.instamojo.com/@joeydash/186d26f66f8840c298150a7779506041	MOJO9224Y05N48160980	116457314552526686941	186d26f66f8840c298150a7779506041	\N
29	Akshit Bagde	Ee17b103	IIT Madras	\N	8.33	7228901202			t	https://www.instamojo.com/@joeydash/3c40c54203be4693bc676e540a927ec8	\N	110540228254791393418	3c40c54203be4693bc676e540a927ec8	\N
41	Om Kotwal	EE17B120	\N	\N	\N	7506606195	\N	\N	f	https://www.instamojo.com/@joeydash/e6431540502a4dfa9b6c00fdb3951d02	\N	105648143853551093911	e6431540502a4dfa9b6c00fdb3951d02	\N
69	Abhinav Azafd	ED17B001	\N	\N	\N	8504894849	\N	\N	f	https://www.instamojo.com/@joeydash/28239a0f44e041ddb2fd82e86b15da0a	\N	116474837895993246041	28239a0f44e041ddb2fd82e86b15da0a	\N
71	Alexander David	MM17B009	\N	\N	\N	8903458216	\N	\N	f	https://www.instamojo.com/@joeydash/476f004917a44f48a177e7a7bfa72de6	\N	100046381709706919563	476f004917a44f48a177e7a7bfa72de6	\N
73	SUBHASIS PATRA	1741012100	\N	\N	\N	8328861067	\N	\N	f	https://www.instamojo.com/@joeydash/f418232799c2444a9a1db930820f0b12	\N	100174145732475175347	f418232799c2444a9a1db930820f0b12	\N
64	harigovind	ed17b042	iitm	engineering design	8.6	9496663228	null	ed17b042@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/d3e1ab6a89684211966f7fe1209cfebb	MOJO9224A05A48151378	109528850140803698362	d3e1ab6a89684211966f7fe1209cfebb	\N
82	A  T Nathaniel Nirmal	110117018	\N	\N	\N	9789975621	\N	\N	f	https://www.instamojo.com/@joeydash/57d9267dd6ca4f219f7fdcc6c3273fef	\N	100323225494928384224	57d9267dd6ca4f219f7fdcc6c3273fef	\N
83	Prashant Jay	ED17B021	\N	\N	\N	7891425196	\N	\N	f	https://www.instamojo.com/@joeydash/da2c08424d4f417c8496a914cd29109e	\N	117437871277613629999	da2c08424d4f417c8496a914cd29109e	\N
81	Meenal	CE17B046	IITM	CIVIL ENGINEERING	6.8	7798570786	null	meenalkamalakar@gmail.com	t	https://www.instamojo.com/@joeydash/dacfd77952da411c89b62832f2ee61e6	MOJO9225505A19468398	113973502411437413660	dacfd77952da411c89b62832f2ee61e6	\N
70	Pranjali Vatsalaya 	EE17B144 	\N	\N	\N	9840914404	\N	\N	f	https://www.instamojo.com/@joeydash/e42db52051c74ae39aed437bebffc2a7	\N	111558464273085465448	e42db52051c74ae39aed437bebffc2a7	\N
67	Aryan Pandey	ch17b105	IITM	Chemical Engineering	8.61	9840919511	9873481644	ch17b105@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/6e8d03b65c1c4fc494c623298450bb2c	MOJO9224Z05A48151320	104171369330644075313	6e8d03b65c1c4fc494c623298450bb2c	\N
72	Neil Ghosh	ME17B060	\N	\N	\N	9527087532	\N	\N	f	https://www.instamojo.com/@joeydash/d5180fb94e944324b4b805450f547c10	\N	117732606660029053405	d5180fb94e944324b4b805450f547c10	\N
74	PRADEEPA. K	311117205043	\N	\N	\N	9840899059	\N	\N	f	https://www.instamojo.com/@joeydash/1d8d2153e8a24f6cb92ccc5eeb2e112b	\N	104341823850477467850	1d8d2153e8a24f6cb92ccc5eeb2e112b	\N
75	PRADUMN KARAGI	Be18b009	\N	\N	\N	8947027067	\N	\N	f	https://www.instamojo.com/@joeydash/86623f535f8e4c7fab40c91ff38a0343	\N	101475449072728420854	86623f535f8e4c7fab40c91ff38a0343	\N
77	Nikit bassi	NA	\N	\N	\N	9592995946	\N	\N	f	https://www.instamojo.com/@joeydash/4a80828f3a5c4c6da7518e23067fe9fa	\N	101285149807471176908	4a80828f3a5c4c6da7518e23067fe9fa	\N
78	Vundela Sasidhar Reddy	ED18B056	\N	\N	\N	7093556234	\N	\N	f	https://www.instamojo.com/@joeydash/231619e968484c2db09db4ba2608c281	\N	104615193672641411565	231619e968484c2db09db4ba2608c281	\N
79	RISHABH SHAH	ME18B029	\N	\N	\N	7567607501	\N	\N	f	https://www.instamojo.com/@joeydash/35c0b0125cd44397a79e93222095cea6	\N	106447284908872676152	35c0b0125cd44397a79e93222095cea6	\N
84	Karil Garg 	Bs18b018 	\N	\N	\N	9549639468 	\N	\N	f	https://www.instamojo.com/@joeydash/bc06d8ed26cc4606a74a6a211af38864	\N	114351628888398386175	bc06d8ed26cc4606a74a6a211af38864	\N
85	Goutham Zampani 	CE14B062	\N	\N	\N	9790469254	\N	\N	f	https://www.instamojo.com/@joeydash/3d06ff23824042bbb3368081e8881088	\N	107434291759433018037	3d06ff23824042bbb3368081e8881088	\N
86	Aniswar Srivatsa Krishnan	CS18B050	\N	\N	\N	6383393474	\N	\N	f	https://www.instamojo.com/@joeydash/b0a05fc2a6914762a73424eaeaf99dae	\N	101887063519379114033	b0a05fc2a6914762a73424eaeaf99dae	\N
87	Niharika Srivastav	I056	\N	\N	\N	9619176070	\N	\N	f	https://www.instamojo.com/@joeydash/bdcc668c18364cb19676c17e76fa9e3d	\N	115382621843699309946	bdcc668c18364cb19676c17e76fa9e3d	\N
89	Abhranil Chakrabarti	CH17B034	\N	\N	\N	9082120679	\N	\N	f	https://www.instamojo.com/@joeydash/b0075bf8551e43d7b9647a7a0bf4ae55	\N	105735616610991386244	b0075bf8551e43d7b9647a7a0bf4ae55	\N
91	Siddharth Dey	Me18b075	\N	\N	\N	8018971019	\N	\N	f	https://www.instamojo.com/@joeydash/a6c42b208c044fae8f1205d0cf742545	\N	106478730192157907359	a6c42b208c044fae8f1205d0cf742545	\N
93	Taher Poonawala	mm17b032	\N	\N	\N	9619790376	\N	\N	f	https://www.instamojo.com/@joeydash/528b4f309bb240dcaf0c48da1fdbcd4b	\N	117356223086180674242	528b4f309bb240dcaf0c48da1fdbcd4b	\N
80	Srishti Adhikary	AE18B012	IITM	Aerospace Engineering	9.22	8904404266	7397243527	7.0111SA2000ms@gmail.com	t	https://www.instamojo.com/@joeydash/6b4dab56f419456f9833fe1fea3dfedf	MOJO9224E05D48151542	116111249617413389973	6b4dab56f419456f9833fe1fea3dfedf	\N
94	Gagan Srivastav	Ee17b042	\N	\N	\N	9490825193	\N	\N	f	https://www.instamojo.com/@joeydash/5827ecc897ee4b2a99ddbde27879e0df	\N	107489933466838356493	5827ecc897ee4b2a99ddbde27879e0df	\N
95	Ram kiran	me17b149	\N	\N	\N	9182743080	\N	\N	f	https://www.instamojo.com/@joeydash/702dbafb92724c66844c3a5c2ca81a50	\N	111128207069265376383	702dbafb92724c66844c3a5c2ca81a50	\N
96	NITIN CHAUHAN	ME15B122	\N	\N	\N	9999393960	\N	\N	f	https://www.instamojo.com/@joeydash/47fbd1f29afd49b98090cc6e715c0c2d	\N	100166136587028365869	47fbd1f29afd49b98090cc6e715c0c2d	\N
98	Aayush Atalkar	10	\N	\N	\N	8237189043	\N	\N	f	https://www.instamojo.com/@joeydash/b55dfa281779463a840ec1170309a916	\N	114121932947581881721	b55dfa281779463a840ec1170309a916	\N
99	Yerra Jai Ganesh	Me17b075	\N	\N	\N	9494211910	\N	\N	f	https://www.instamojo.com/@joeydash/3ec1649b6c5742d8b13a69a766308d3d	\N	118240680244675482931	3ec1649b6c5742d8b13a69a766308d3d	\N
100	Aditya Raj	1RV17CS010	\N	\N	\N	7277113307	\N	\N	f	https://www.instamojo.com/@joeydash/fae1139c7e5445aaba1cc6f9c8f9d850	\N	111140359246612411654	fae1139c7e5445aaba1cc6f9c8f9d850	\N
101	Yashwanth	Me18b006	\N	\N	\N	7993621838	\N	\N	f	https://www.instamojo.com/@joeydash/d74246b32a634c77b852b5b2b4d8e6fa	\N	106540878792009138011	d74246b32a634c77b852b5b2b4d8e6fa	\N
102	Rahul Jain	CH18B019	\N	\N	\N	9530181131	\N	\N	f	https://www.instamojo.com/@joeydash/57206d35559f4c69a885cadc7af8c27b	\N	107147930685919857188	57206d35559f4c69a885cadc7af8c27b	\N
103	Bablu Devsingh Sitole	me18b103	\N	\N	\N	8370079960	\N	\N	f	https://www.instamojo.com/@joeydash/d7869543535d4e2a8d84b326473be6af	\N	103702551939099288693	d7869543535d4e2a8d84b326473be6af	\N
104	J.A.Dhanush Aadithya	ED17B010	\N	\N	\N	9176168935	\N	\N	f	https://www.instamojo.com/@joeydash/a207265e12bb42ae836686353ed04dc2	\N	109289325891115045173	a207265e12bb42ae836686353ed04dc2	\N
105	Sai Krishna kota	Ce17b054	\N	\N	\N	9182246163	\N	\N	f	https://www.instamojo.com/@joeydash/226449895ac147f3b565d45e8f2317c4	\N	102748409040120330310	226449895ac147f3b565d45e8f2317c4	\N
107	Neel Changani	K009	\N	\N	\N	9819660821	\N	\N	f	https://www.instamojo.com/@joeydash/33e5ff51ac30465d8d8c1eac445a0fd1	\N	114360394443508391157	33e5ff51ac30465d8d8c1eac445a0fd1	\N
108	Sriujanm	17CE1081	\N	\N	\N	9403254410	\N	\N	f	https://www.instamojo.com/@joeydash/584cba27c9a844c19f3a125fa1e60bcb	\N	105122427801569397480	584cba27c9a844c19f3a125fa1e60bcb	\N
109	Varun Choudhary 	CE15B96	\N	\N	\N	7023582684	\N	\N	f	https://www.instamojo.com/@joeydash/53f8a2b904c4421486d350c3dbd4523b	\N	110606774466678924370	53f8a2b904c4421486d350c3dbd4523b	\N
106	Kandra Pavan	ME18B148	IITM	Mechanical Engineering	9.71	7358034555	9498302250	null	t	https://www.instamojo.com/@joeydash/f65e4c602f8046c3a28210ad21bd21de	MOJO9224U05D48151813	107301028745384927900	f65e4c602f8046c3a28210ad21bd21de	\N
111	Rohit Mahendran	16me118	\N	\N	\N	9047548111	\N	\N	f	https://www.instamojo.com/@joeydash/b37e0c83d8054273a26b5b5cf4d9fc1a	\N	108773897194648952785	b37e0c83d8054273a26b5b5cf4d9fc1a	\N
112	Nithin Uppalapati	EE18B035	\N	\N	\N	6303458453	\N	\N	f	https://www.instamojo.com/@joeydash/9b08b92721704e2fa667aa75d87099ea	\N	108848347453031165545	9b08b92721704e2fa667aa75d87099ea	\N
113	shreyas shandilya	ed16b029	\N	\N	\N	7985153872	\N	\N	f	https://www.instamojo.com/@joeydash/6ebb49d163b34e02a42d685c7d6689cf	\N	114840229803252179382	6ebb49d163b34e02a42d685c7d6689cf	\N
114	Siddharth JP	NA16B118	\N	\N	\N	9840681502	\N	\N	f	https://www.instamojo.com/@joeydash/4bbfc8b7e34f4124ab2890b195e00634	\N	108536031230585647935	4bbfc8b7e34f4124ab2890b195e00634	\N
115	K Vamshi Krishna	me18m039	\N	\N	\N	8106294939	\N	\N	f	https://www.instamojo.com/@joeydash/81b5615f5eaf46cf94a40a8c7e776134	\N	112872968935980064890	81b5615f5eaf46cf94a40a8c7e776134	\N
110	Raman Kumar	BS16B028	INDIAN INSTITUTE OF TECHNOLOGY MADRAS	BIOTECHNOLOGY	6.42	8096866804	7449103008	bs16b028@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/71b52f16cd7f45eea29ab990eb994b6a	MOJO9225X05N19479958	100373514490827653919	71b52f16cd7f45eea29ab990eb994b6a	\N
116	Shashwath	ED16B028	\N	\N	\N	9036011556	\N	\N	f	https://www.instamojo.com/@joeydash/bd0283887dd7480ba010e2d418fbdb2e	\N	100006462132328751764	bd0283887dd7480ba010e2d418fbdb2e	\N
117	Bharat Jayaprakash	ED16B007	\N	\N	\N	8369695129	\N	\N	f	https://www.instamojo.com/@joeydash/dfe82f2345264c868589588c5050bb63	\N	100629454340115098641	dfe82f2345264c868589588c5050bb63	\N
118	Sikhakollu Venkata Pavan Sumanth 	Ee18b064 	\N	\N	\N	7032020575	\N	\N	f	https://www.instamojo.com/@joeydash/10dd74a3cb1546a9a5b7d455723174bf	\N	105534379261061050947	10dd74a3cb1546a9a5b7d455723174bf	\N
120	Mitte Siddartha sai	Cs18b028	\N	\N	\N	9133464549	\N	\N	f	https://www.instamojo.com/@joeydash/bf40c1be1e2049358a8ed3a808fb927d	\N	105001332348729167995	bf40c1be1e2049358a8ed3a808fb927d	\N
129	Varad Joshi	me17b038	\N	\N	\N	9511639134	\N	\N	f	https://www.instamojo.com/@joeydash/79a292e4b83d493db29a7a701540a71c	\N	117966690353831815134	79a292e4b83d493db29a7a701540a71c	\N
127	V Vishnu Kiran	CS18B067	IIT Madras	Computer science	10	7338712646	9840017313	cs18b067@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/0fd28307c37c43b38941f75804a92948	MOJO9224A05D48152097	113681390068745417997	0fd28307c37c43b38941f75804a92948	\N
135	Mokshagna Sai Teja Komatipolu	2015104062	\N	\N	\N	9941989881	\N	\N	f	https://www.instamojo.com/@joeydash/e13e3ab8a79a4bee9efb3c8aa0574f21	\N	103923783699459229771	e13e3ab8a79a4bee9efb3c8aa0574f21	\N
136	S Sidhartha Narayan 	EP18B030 	\N	\N	\N	7010892474	\N	\N	f	https://www.instamojo.com/@joeydash/c02dd2add4bd41fe9d7e49f268864363	\N	110757805238250702422	c02dd2add4bd41fe9d7e49f268864363	\N
137	Devraj	me15b100	\N	\N	\N	9468865064	\N	\N	f	https://www.instamojo.com/@joeydash/9ec1831f5c0843fc9fcad183a54e61f4	\N	107413706842790560056	9ec1831f5c0843fc9fcad183a54e61f4	\N
138	Rudram	ed16b024	\N	\N	\N	9940334981	\N	\N	f	https://www.instamojo.com/@joeydash/2e7cc4416c094e3694f2df1f0e98b5ad	\N	113712306728446985892	2e7cc4416c094e3694f2df1f0e98b5ad	\N
122	shubham jain	Me16b165	IITM	Mechanical Engineering	7.95	8486217292	8428317882	me16b165@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/228be1bbfc46416e9b3cac50f31f1e63	MOJO9224Z05D48155690	101398156657528003471	228be1bbfc46416e9b3cac50f31f1e63	\N
119	Arjun RK	18bec1120	\N	\N	\N	9003052629	\N	\N	f	https://www.instamojo.com/@joeydash/08a5a3e6818e448c911198bc92f50b9e	\N	114704333810864603254	08a5a3e6818e448c911198bc92f50b9e	\N
121	Viswanath Tadi	cs18b047	\N	\N	\N	9398821800	\N	\N	f	https://www.instamojo.com/@joeydash/0f5f358482bc4a85af7f26423cc7bb50	\N	110408636199196777944	0f5f358482bc4a85af7f26423cc7bb50	\N
123	Ameya Rajesh Ainchwar	ME18B122	\N	\N	\N	9892525841	\N	\N	f	https://www.instamojo.com/@joeydash/7f62cf4e740e41beb620b46ebaf9fa25	\N	101633193710942170825	7f62cf4e740e41beb620b46ebaf9fa25	\N
124	Adriza Mishra	BS18B013	\N	\N	\N	9717279799	\N	\N	f	https://www.instamojo.com/@joeydash/3fe2206da0734590b8c82e3192d34790	\N	116428881593753626712	3fe2206da0734590b8c82e3192d34790	\N
125	Naga sai	Ch18b053	\N	\N	\N	6303305778	\N	\N	f	https://www.instamojo.com/@joeydash/2fb87f44938b4745b5ac9e5995ccdcd5	\N	112870414950478249881	2fb87f44938b4745b5ac9e5995ccdcd5	\N
126	Aditya Parag Rindani	ME18B037	\N	\N	\N	7506072729	\N	\N	f	https://www.instamojo.com/@joeydash/3d0eec45aa224808896a6ddc4aa9601f	\N	108210163016263470552	3d0eec45aa224808896a6ddc4aa9601f	\N
128	Yuvraj Singh	CS18B064	\N	\N	\N	7988056690	\N	\N	f	https://www.instamojo.com/@joeydash/9af616cb7c504b51b07c2e81e4c1b4a7	\N	101491417144470081112	9af616cb7c504b51b07c2e81e4c1b4a7	\N
130	Mansi Choudhary	EE17B053	\N	\N	\N	8332957411	\N	\N	f	https://www.instamojo.com/@joeydash/955bc106cd684244be5968a4e682cbbd	\N	115248078929890303214	955bc106cd684244be5968a4e682cbbd	\N
131	Suraj Reddy	Bs18B015	\N	\N	\N	9381571532	\N	\N	f	https://www.instamojo.com/@joeydash/88e5286aea88469d8308dc1ab3acbb8f	\N	115339962081142646939	88e5286aea88469d8308dc1ab3acbb8f	\N
132	Poulomi Kha 	bs16b026	\N	\N	\N	9619502945	\N	\N	f	https://www.instamojo.com/@joeydash/19330d1a3cb942a3a1a1192d33ad3465	\N	104863773335365538808	19330d1a3cb942a3a1a1192d33ad3465	\N
134	Akilesh Kannan	ee18b122	\N	\N	\N	9840372545	\N	\N	f	https://www.instamojo.com/@joeydash/0b9acf0adbad40edb9dd057a019b4484	\N	107177554755735141269	0b9acf0adbad40edb9dd057a019b4484	\N
139	Sudheendra	CS18B006	\N	\N	\N	9989434913	\N	\N	f	https://www.instamojo.com/@joeydash/e5dbd932e53242cca49ca57dae209e5f	\N	101180110198873131231	e5dbd932e53242cca49ca57dae209e5f	\N
142	Saluru Durga Sandeep	ME16B125	\N	\N	\N	9500195784	\N	\N	f	https://www.instamojo.com/@joeydash/fda6466aec15452cbcd4bb82e5e88e92	\N	106053419849481655127	fda6466aec15452cbcd4bb82e5e88e92	\N
143	Krishna Gopal Sharma	CS18B021	\N	\N	\N	9887744162	\N	\N	f	https://www.instamojo.com/@joeydash/9878ded171d342918beaeec608a3d5d0	\N	114582343462323173676	9878ded171d342918beaeec608a3d5d0	\N
144	Krishna Tejaswi 	ep17b018	\N	\N	\N	8985763064	\N	\N	f	https://www.instamojo.com/@joeydash/2b2338a2c5344bb7b4de5ab5e882f4f1	\N	107198149074547760918	2b2338a2c5344bb7b4de5ab5e882f4f1	\N
145	Padidam Venkata Nitesh Kumar 	Ce16b006	\N	\N	\N	9032904382	\N	\N	f	https://www.instamojo.com/@joeydash/c650258b03ae4e63b8e19100378b12ff	\N	103273107959465057265	c650258b03ae4e63b8e19100378b12ff	\N
146	Avasarala Krishna Koustubha 	ME18B126 	\N	\N	\N	9676776292 	\N	\N	f	https://www.instamojo.com/@joeydash/4efb19a522514c74bd8ff66db38279b7	\N	100444374512123718431	4efb19a522514c74bd8ff66db38279b7	\N
147	Anurag harsh	3616001	\N	\N	\N	9962905726	\N	\N	f	https://www.instamojo.com/@joeydash/d5df4a9b2a954ab8ab8d24c849f87024	\N	117764114579954744999	d5df4a9b2a954ab8ab8d24c849f87024	\N
148	Ramanan S	EE18B145	\N	\N	\N	8825894252	\N	\N	f	https://www.instamojo.com/@joeydash/2ab2872f3afd4a27a0aa52af07fd10e7	\N	113597979260889639153	2ab2872f3afd4a27a0aa52af07fd10e7	\N
149	Viknesh S	ee17b073	\N	\N	\N	9003171125	\N	\N	f	https://www.instamojo.com/@joeydash/6af9151e017a44c4909e1b355721a561	\N	111066027705891320913	6af9151e017a44c4909e1b355721a561	\N
150	Lakshna	ed16b044	\N	\N	\N	9500195719	\N	\N	f	https://www.instamojo.com/@joeydash/308702cdf03449c68abb5010afdbb02e	\N	101307535630091801474	308702cdf03449c68abb5010afdbb02e	\N
151	KORRAPATI H P BHARADWAJ	EE16B112	\N	\N	\N	9500182950	\N	\N	f	https://www.instamojo.com/@joeydash/7e6a23be812d43f9b9402e9561556913	\N	116481244449985283889	7e6a23be812d43f9b9402e9561556913	\N
152	E SAMEER KUMAR	ME17B048	\N	\N	\N	6380241248	\N	\N	f	https://www.instamojo.com/@joeydash/09068ab9fced4065a44d477e64c913f3	\N	115801243251886489865	09068ab9fced4065a44d477e64c913f3	\N
153	Kaivalya Rakesh Chitre 	me17b018 	\N	\N	\N	8779693065	\N	\N	f	https://www.instamojo.com/@joeydash/c8026f1ff6be406590e51469d965bd13	\N	109121374241590014827	c8026f1ff6be406590e51469d965bd13	\N
154	Neha Swaminathan	BE18B008	\N	\N	\N	6379698944	\N	\N	f	https://www.instamojo.com/@joeydash/8cf1f677161c4b7da3c6e7aadfbb3106	\N	109557453092405104728	8cf1f677161c4b7da3c6e7aadfbb3106	\N
155	Basu Jindal	ME18B008	\N	\N	\N	6352487497	\N	\N	f	https://www.instamojo.com/@joeydash/3d4b6f4be6d54f2c8f9805fb23ccb8da	\N	111640459531281754733	3d4b6f4be6d54f2c8f9805fb23ccb8da	\N
156	T Bala Sundar 	CS17B1062	\N	\N	\N	8247646440	\N	\N	f	https://www.instamojo.com/@joeydash/c33263919f754d1eb936518ca7b02757	\N	114885547058071668870	c33263919f754d1eb936518ca7b02757	\N
157	G Venkata Sai Anooj	ME17B049	\N	\N	\N	7675888538	\N	\N	f	https://www.instamojo.com/@joeydash/a6d6a5443f94468a888e4e896e65f2db	\N	105187746276593629594	a6d6a5443f94468a888e4e896e65f2db	\N
158	Shubham Kanekar	mm17b019	\N	\N	\N	9822229994	\N	\N	f	https://www.instamojo.com/@joeydash/5800a51fb41d473abb57ae7f0533398a	\N	117310687405189973052	5800a51fb41d473abb57ae7f0533398a	\N
159	Mohammed Sanjeed	ED17B047	\N	\N	\N	8921957265	\N	\N	f	https://www.instamojo.com/@joeydash/f247d5898545468da8725d44b811b8d0	\N	114326744260308541754	f247d5898545468da8725d44b811b8d0	\N
160	Sunanda Vishnu Somwase	8041	\N	\N	\N	9021393816	\N	\N	f	https://www.instamojo.com/@joeydash/377b1567fb0647b18062b239625d4759	\N	102269853381680672389	377b1567fb0647b18062b239625d4759	\N
161	Samad faraz	170106049	\N	\N	\N	8402036342	\N	\N	f	https://www.instamojo.com/@joeydash/82b6147246bc4cd09f4e810a10d953dc	\N	104425878332120909243	82b6147246bc4cd09f4e810a10d953dc	\N
162	Yogeshwar	18BEC1084	\N	\N	\N	9940017676	\N	\N	f	https://www.instamojo.com/@joeydash/1f8b8f53463d4b0ca3a263b4ee8bf341	\N	109098813558670849559	1f8b8f53463d4b0ca3a263b4ee8bf341	\N
163	Saye Sharan	ME16B177	\N	\N	\N	7358739081	\N	\N	f	https://www.instamojo.com/@joeydash/f8f6d4a3085748a3acaa4ecab24a34ee	\N	114591386611984022174	f8f6d4a3085748a3acaa4ecab24a34ee	\N
164	Devansh	BT16MEC035	\N	\N	\N	8272845556	\N	\N	f	https://www.instamojo.com/@joeydash/d6e3313828aa4f6cae3aeaa6a02bb6db	\N	111567725646650165125	d6e3313828aa4f6cae3aeaa6a02bb6db	\N
140	Dhruvjyoti Bagadthey	ee17b156	IITM	Electrical engineering	9.91	8902377455	9831799051	djbagadthey@gmail.com	t	https://www.instamojo.com/@joeydash/7edd948c179a4f4cbd795b81f9169b43	MOJO9224Z05A48152770	114093894912804568558	7edd948c179a4f4cbd795b81f9169b43	\N
141	Kashish Kumar	CE17M079	IITM	Civil Engineering (Structural Engineering)	8.25	9971797184	null	null	t	https://www.instamojo.com/@joeydash/dbe7237040e44f9692dd4c58083e0c85	MOJO9225R05A19467171	108551370712006348201	dbe7237040e44f9692dd4c58083e0c85	\N
172	Skanda Swaroop TH	ME16B130	\N	\N	\N	9176330618	\N	\N	f	https://www.instamojo.com/@joeydash/51f7efe07286446da4bc2061a80a18e4	\N	114591124276679160265	51f7efe07286446da4bc2061a80a18e4	\N
173	P. Satya Sai Nithish	ME16B157	\N	\N	\N	9677210586	\N	\N	f	https://www.instamojo.com/@joeydash/dcffdc328fb84337ab4a79dca06cfe5f	\N	105433782240224469335	dcffdc328fb84337ab4a79dca06cfe5f	\N
174	RA Keerthan	CH17B078	\N	\N	\N	7299024061	\N	\N	f	https://www.instamojo.com/@joeydash/4c8cc13c26c24d7d8eec791e2278ec43	\N	118406601333681717065	4c8cc13c26c24d7d8eec791e2278ec43	\N
176	Sushma	ED17B016	\N	\N	\N	9182802442	\N	\N	f	https://www.instamojo.com/@joeydash/b79f81f8b15541e1a74367118f339d2d	\N	115039944234930695540	b79f81f8b15541e1a74367118f339d2d	\N
177	Krishnakanth R	EE17B015	\N	\N	\N	9080486390	\N	\N	f	https://www.instamojo.com/@joeydash/984bc67544ec479d9bee232a24977e51	\N	102658268322549131527	984bc67544ec479d9bee232a24977e51	\N
179	Omender Mina	Mm18b025	\N	\N	\N	7230993266	\N	\N	f	https://www.instamojo.com/@joeydash/7890f25ed3204a6bafbd6b6fb1712c1b	\N	104220784359784029268	7890f25ed3204a6bafbd6b6fb1712c1b	\N
182	Abhi	C072	\N	\N	\N	7048138715	\N	\N	f	https://www.instamojo.com/@joeydash/12f8b22b95a041e482aae613bbfadcec	\N	109441309750837717539	12f8b22b95a041e482aae613bbfadcec	\N
183	Gorthy Sai Shashank	ME17B141	\N	\N	\N	9840932156	\N	\N	f	https://www.instamojo.com/@joeydash/e5257615b66d4584b7f47f879d1974ab	\N	105620503580613926309	e5257615b66d4584b7f47f879d1974ab	\N
186	Vihaan Akshaay Rajendiran	ME17B171	\N	\N	\N	7708809996	\N	\N	f	https://www.instamojo.com/@joeydash/01709c148381436a9a9d5049ae504805	\N	113464349539753011433	01709c148381436a9a9d5049ae504805	\N
187	Karthik Bachu	ME17B053	\N	\N	\N	8074928621	\N	\N	f	https://www.instamojo.com/@joeydash/e9d06e63ae274da3b6b68fe9674754f9	\N	112203812328864098110	e9d06e63ae274da3b6b68fe9674754f9	\N
189	Sourav H	412415106094	\N	\N	\N	7358225765	\N	\N	f	https://www.instamojo.com/@joeydash/25874ec57d05405cac23f8c5271711b1	\N	117368038713753317104	25874ec57d05405cac23f8c5271711b1	\N
190	Srijan Kumar Upadhyay 	NA17B034	\N	\N	\N	9575162116	\N	\N	f	https://www.instamojo.com/@joeydash/7bb61260afb54e569cf31621ccfbdba6	\N	117773863857662055608	7bb61260afb54e569cf31621ccfbdba6	\N
191	Denish Dhanji Vaid	EE17B159	\N	\N	\N	8879936887	\N	\N	f	https://www.instamojo.com/@joeydash/895b395e68ac47e099230096810240b3	\N	100967102642433990682	895b395e68ac47e099230096810240b3	\N
193	Turkesh Pote	29	\N	\N	\N	9769274603	\N	\N	f	https://www.instamojo.com/@joeydash/1b12d1d55eb5483da129c8e66e1a1f85	\N	108345004535686987028	1b12d1d55eb5483da129c8e66e1a1f85	\N
194	Sushwath	ED17B036	\N	\N	\N	8897100392	\N	\N	f	https://www.instamojo.com/@joeydash/f8224b2241cf4b5586e4d70997152cca	\N	102330392737983603678	f8224b2241cf4b5586e4d70997152cca	\N
195	Sidharth A P	CS17M045	\N	\N	\N	8086274662	\N	\N	f	https://www.instamojo.com/@joeydash/f402626ad27c4a7e99a62b3a88cc41f3	\N	111983544338321266182	f402626ad27c4a7e99a62b3a88cc41f3	\N
197	Srihari	K.S	\N	\N	\N	9080530055	\N	\N	f	https://www.instamojo.com/@joeydash/b3df0a7059904b888dbdde1223779607	\N	101719078540936693965	b3df0a7059904b888dbdde1223779607	\N
198	Vikas Singh	150180107061	\N	\N	\N	9639614942	\N	\N	f	https://www.instamojo.com/@joeydash/e2d8cfc97fb842999ebd3398731680a7	\N	100317160726643486440	e2d8cfc97fb842999ebd3398731680a7	\N
201	Abhishek Kumar	17BBA1631	\N	\N	\N	9570717114	\N	\N	f	https://www.instamojo.com/@joeydash/8663a87c09fd4fbd9874a3c2d6ac50c0	\N	114218010316466093767	8663a87c09fd4fbd9874a3c2d6ac50c0	\N
202	Sambit Tarai	ed16b026	\N	\N	\N	9940308429	\N	\N	f	https://www.instamojo.com/@joeydash/456d194112f64e9197d36243df9b2846	\N	104003420105956436392	456d194112f64e9197d36243df9b2846	\N
175	Avvari Sai SSV Bharadwaj	CS17B007	IITM	Computer Science and Engineering	8.44	7382091743	9440779557	avvaribp@gmail.com	t	https://www.instamojo.com/@joeydash/a0e3ead36f564321b7aaa8c4c3442ec1	MOJO9224D05N48152807	116528854078263730275	a0e3ead36f564321b7aaa8c4c3442ec1	\N
203	Mohammed Khandwawala	EE16B117	Indian Institute of Technology Madras	Electrical Engineering	8.51	9940329022	null	mohammedkhandwawala100@gmail.com	t	https://www.instamojo.com/@joeydash/f529ec681dde4e3888a77ab43530ae36	MOJO9224F05A48153125	118244727025742575334	f529ec681dde4e3888a77ab43530ae36	\N
199	Aman Basheer A	ED17B032	IITM	Engineering Design	7.01	9497602271	9840924667	aman.basheer.a@gmail.com	t	https://www.instamojo.com/@joeydash/f5482cf696fd46d6b2f52f07693f4707	MOJO9226O05D95508317	111703803711058182719	f5482cf696fd46d6b2f52f07693f4707	\N
178	Harshitha Mothukuri	ASM17PGDM011	\N	\N	\N	9948125533	\N	\N	f	https://www.instamojo.com/@joeydash/33f7d80c51eb4ebea036505a05bd5a3e	\N	114740917522394709774	33f7d80c51eb4ebea036505a05bd5a3e	\N
180	Unman Nibandhe	ME18B035	\N	\N	\N	8007691177	\N	\N	f	https://www.instamojo.com/@joeydash/b9d424671ce74971b02a7e9eb1e92f60	\N	107393448684071128659	b9d424671ce74971b02a7e9eb1e92f60	\N
181	Aaysha Anser Babu 	ae18b014 	\N	\N	\N	8301967536	\N	\N	f	https://www.instamojo.com/@joeydash/e2f0879938114788b87d465edf0f8415	\N	110931047755608602680	e2f0879938114788b87d465edf0f8415	\N
133	Jonathan Ve Vance	ED17B014	IITM	Engineering Design	8.71	9497568098	8921041726	jonathanvevance@gmail.com	t	https://www.instamojo.com/@joeydash/8749bb860c0440948a90e47687c666aa	MOJO9224D05A48152443	101927668361428071197	8749bb860c0440948a90e47687c666aa	\N
171	Jebby Arulson	ae17b028	IITM	AEROSPACE ENGINEERING	9.13	7299247992	9941424233	jebbyarulson@gmail.com	t	https://www.instamojo.com/@joeydash/8720be91d4ed4956ba30a7c1a2e145b8	MOJO9224G05N48152458	116837958596212598480	8720be91d4ed4956ba30a7c1a2e145b8	\N
184	Souridas A	ae18b046	\N	\N	\N	9656123558	\N	\N	f	https://www.instamojo.com/@joeydash/c549d4a3dd924f269ad6860ec2d4a9cb	\N	106596281639246034885	c549d4a3dd924f269ad6860ec2d4a9cb	\N
185	Bhashwar Ghosh	EP17B019	\N	\N	\N	9455708982	\N	\N	f	https://www.instamojo.com/@joeydash/1397b93db8264ef18a817a5be89d5831	\N	105506572235545868243	1397b93db8264ef18a817a5be89d5831	\N
192	Aditya Balachander	EE18B101	\N	\N	\N	9940518320	\N	\N	f	https://www.instamojo.com/@joeydash/6abc2bcc4d8548a1a43ba4244ee482d9	\N	116189371214953919032	6abc2bcc4d8548a1a43ba4244ee482d9	\N
196	Tadikamalla Chetana Tanmayee	ce18b125	\N	\N	\N	9948335818 	\N	\N	f	https://www.instamojo.com/@joeydash/c1703e3506d948a0b6884ff6e7f1be50	\N	107726028519801979477	c1703e3506d948a0b6884ff6e7f1be50	\N
200	Mohil	ME16B117	\N	\N	\N	8793038793	\N	\N	f	https://www.instamojo.com/@joeydash/efaed96176754f95a8c61e32fdd63f6a	\N	104564285080152210085	efaed96176754f95a8c61e32fdd63f6a	\N
204	Ananya Shetty	PH18B007	\N	\N	\N	9892974022	\N	\N	f	https://www.instamojo.com/@joeydash/6d96def546004636b0024a7d0556bcc7	\N	103612128499527056792	6d96def546004636b0024a7d0556bcc7	\N
205	Santhosh	ASM17PGDM014	\N	\N	\N	9963989698	\N	\N	f	https://www.instamojo.com/@joeydash/b28f07335a374c7e8c806f32a8e719f3	\N	111203068180225244060	b28f07335a374c7e8c806f32a8e719f3	\N
206	Alaparthi. Lohitha 	Bs18b008	\N	\N	\N	8919602965 	\N	\N	f	https://www.instamojo.com/@joeydash/fc9be256ce1b471293054f5fb9d4074f	\N	101171591693354500761	fc9be256ce1b471293054f5fb9d4074f	\N
207	Ahad Modak	052	\N	\N	\N	9930438173	\N	\N	f	https://www.instamojo.com/@joeydash/ac01db11bd29483e9901cf1073aa58ee	\N	106653443315295232533	ac01db11bd29483e9901cf1073aa58ee	\N
208	Abhimanyu Swaroop	MM17B008	\N	\N	\N	9819915368	\N	\N	f	https://www.instamojo.com/@joeydash/1fe773be6d694fdba134d0ac5bb48b32	\N	101964436097463168367	1fe773be6d694fdba134d0ac5bb48b32	\N
209	Chinmay Kulkarni	14426	\N	\N	\N	9404028919	\N	\N	f	https://www.instamojo.com/@joeydash/be1c25c92b764705836095943c1c99e8	\N	104547213757131706346	be1c25c92b764705836095943c1c99e8	\N
210	Teja	AE16B104	\N	\N	\N	9494133978	\N	\N	f	https://www.instamojo.com/@joeydash/f22306d5d58743dc80626542249eea7e	\N	109432364385136243098	f22306d5d58743dc80626542249eea7e	\N
211	Aayush Raj	MM18B008	\N	\N	\N	9767210407	\N	\N	f	https://www.instamojo.com/@joeydash/bfbec96fd8624417b375da54ca2bcb8e	\N	104196509524819380284	bfbec96fd8624417b375da54ca2bcb8e	\N
212	Aditya singh mahala 	CE17B023 	\N	\N	\N	9840870610 	\N	\N	f	https://www.instamojo.com/@joeydash/aa66c9180e7e4f3b8bf08a7c9f54542d	\N	105702456308731098062	aa66c9180e7e4f3b8bf08a7c9f54542d	\N
213	Abhishek Bakolia	EE16B101	\N	\N	\N	9462735198	\N	\N	f	https://www.instamojo.com/@joeydash/9ae73a07137149b6a54dcbca5a9d41cb	\N	110283615455900532725	9ae73a07137149b6a54dcbca5a9d41cb	\N
214	Yuvraj Singh	CS18B064	\N	\N	\N	7988056690	\N	\N	f	https://www.instamojo.com/@joeydash/899cdef68f9d4f0a8ba01f2af0d549a2	\N	106635592932027981078	899cdef68f9d4f0a8ba01f2af0d549a2	\N
215	HANUSHAVARDHINI.S	HS18H019	\N	\N	\N	6383841254	\N	\N	f	https://www.instamojo.com/@joeydash/5ceb0019172c4c8aa63227e2ae270b5f	\N	101626955168185208012	5ceb0019172c4c8aa63227e2ae270b5f	\N
216	Varun Awasthi	CH18B028	\N	\N	\N	7798948567	\N	\N	f	https://www.instamojo.com/@joeydash/b8efea263bd046e190a5a4f604b3d990	\N	102627795555924271019	b8efea263bd046e190a5a4f604b3d990	\N
217	Siddharth Kapre	ch16b065	\N	\N	\N	6361095619	\N	\N	f	https://www.instamojo.com/@joeydash/4faf9ff6bc0d47179ff74b5892050743	\N	102719715304204500462	4faf9ff6bc0d47179ff74b5892050743	\N
218	Kiran Skk	Bs17b107	\N	\N	\N	8660061270	\N	\N	f	https://www.instamojo.com/@joeydash/31e471813380435ca08d2c4ab11da6c1	\N	107033203380308127028	31e471813380435ca08d2c4ab11da6c1	\N
219	Abhishek Sekar 	EE18B067 	\N	\N	\N	9884918855 	\N	\N	f	https://www.instamojo.com/@joeydash/5588403a5d4245bf8d07b0fec8831074	\N	113069714899047220836	5588403a5d4245bf8d07b0fec8831074	\N
220	Sashank	ME18B160	\N	\N	\N	9381131601	\N	\N	f	https://www.instamojo.com/@joeydash/41c42ef58af541829f5858a176a10619	\N	110018183307703015999	41c42ef58af541829f5858a176a10619	\N
221	Atharva Mashalkar	CE18B136	\N	\N	\N	7620099155	\N	\N	f	https://www.instamojo.com/@joeydash/b15ab4a175dd4313a8c02c885bc18264	\N	109722948945101591188	b15ab4a175dd4313a8c02c885bc18264	\N
222	Kailash Lakshmikanth	BE18B004	\N	\N	\N	6380044291	\N	\N	f	https://www.instamojo.com/@joeydash/a9ed7dde5e724110beeb0c48f1147a06	\N	110271268844549390100	a9ed7dde5e724110beeb0c48f1147a06	\N
223	Vibodh pankaj	EE18B159	\N	\N	\N	9885277781	\N	\N	f	https://www.instamojo.com/@joeydash/a0f3349f621c45faad4e3497574a97d6	\N	104181085677236457428	a0f3349f621c45faad4e3497574a97d6	\N
224	Sri Sindhu Gunturi	CS18B058 	\N	\N	\N	7702626727	\N	\N	f	https://www.instamojo.com/@joeydash/e82cc361645646fc8a699290e2fec571	\N	101172755541818547188	e82cc361645646fc8a699290e2fec571	\N
225	Aniket Charjan 	17ME02018 	\N	\N	\N	8888502370 	\N	\N	f	https://www.instamojo.com/@joeydash/1f8baccb780242a4af00dd3c089fe70b	\N	101171188455426530274	1f8baccb780242a4af00dd3c089fe70b	\N
226	ADITYA TODKAR	55	\N	\N	\N	9404382819	\N	\N	f	https://www.instamojo.com/@joeydash/f4da64163bc7477c9ac7f556c78c0052	\N	106355600612411521354	f4da64163bc7477c9ac7f556c78c0052	\N
227	Shankar lal	Ce16b125	\N	\N	\N	7822025458	\N	\N	f	https://www.instamojo.com/@joeydash/defa6b00a53a4733b1e6a6ecb6e6bdcd	\N	102378491167760853351	defa6b00a53a4733b1e6a6ecb6e6bdcd	\N
228	Sivasubramaniyan Sivanandan	EE17B029	\N	\N	\N	9003222378	\N	\N	f	https://www.instamojo.com/@joeydash/63f29e7fd1764a228a6226ff0bf21e66	\N	116759539753758122369	63f29e7fd1764a228a6226ff0bf21e66	\N
229	Nandhini	110117058	\N	\N	\N	8825624134	\N	\N	f	https://www.instamojo.com/@joeydash/b3ea554aeb0b4e20aac6ffc55ea1af71	\N	103308922454507465852	b3ea554aeb0b4e20aac6ffc55ea1af71	\N
230	Naveen Kumaar S	ME17B028	\N	\N	\N	8838169339	\N	\N	f	https://www.instamojo.com/@joeydash/870e43b8cce6496998bead853f553f03	\N	113468750706613363716	870e43b8cce6496998bead853f553f03	\N
231	Nithin Babu	EE18B021	\N	\N	\N	9566112265	\N	\N	f	https://www.instamojo.com/@joeydash/c08a3c4e29a34f14a1e93060cb344228	\N	104294280397208849479	c08a3c4e29a34f14a1e93060cb344228	\N
232	Nischith shadagopan m n	CS18B102	\N	\N	\N	9886548048	\N	\N	f	https://www.instamojo.com/@joeydash/8607d4ff03a4420f9602d865e4849af4	\N	104768237535269074850	8607d4ff03a4420f9602d865e4849af4	\N
188	Nishant Patil	EE17B023	IITM	Electrical Engineering 	9	9087100334	null	null	t	https://www.instamojo.com/@joeydash/dd03fccce95e443286d8026c793f98fe	MOJO9224205A48153197	100427482293316682936	dd03fccce95e443286d8026c793f98fe	\N
240	Adnan Faisal	17MI31003	\N	\N	\N	9748730688	\N	\N	f	https://www.instamojo.com/@joeydash/8679766c42c44997a9d5422ab65808cd	\N	102823766561575238807	8679766c42c44997a9d5422ab65808cd	\N
246	Rithvik Anil	ME16B123	\N	\N	\N	9884304490	\N	\N	f	https://www.instamojo.com/@joeydash/17bad409f4c84841939182f59ea600f7	\N	108733883465772823484	17bad409f4c84841939182f59ea600f7	\N
239	Anirudh Chavali	ME17B007	IITM	Mechanical engineering	8.88	9080958460	7207803252	wdp4.20043kjm@gmail.com	t	https://www.instamojo.com/@joeydash/cc8f4a6eef02438284ca7d61bbd59261	MOJO9224P05D48153408	106348211089456308863	cc8f4a6eef02438284ca7d61bbd59261	\N
247	Yash Gupta	1MS16CV111	\N	\N	\N	8105946633	\N	\N	f	https://www.instamojo.com/@joeydash/fec91de9e53b45c4841d809384846288	\N	104971464362178380321	fec91de9e53b45c4841d809384846288	\N
248	Shubham Subhas Danannavar	ED17B024	\N	\N	\N	9940038097	\N	\N	f	https://www.instamojo.com/@joeydash/dff63fec83394471bbf62f40b3183e20	\N	101988431255785683948	dff63fec83394471bbf62f40b3183e20	\N
249	Sahil Kumar 	ME17B066 	\N	\N	\N	9082380294 	\N	\N	f	https://www.instamojo.com/@joeydash/3867d53d5f114eab87201a5462e480d2	\N	112998653258877975475	3867d53d5f114eab87201a5462e480d2	\N
251	D.Pavan Kumar Singh	Ae17b003	\N	\N	\N	6360063723	\N	\N	f	https://www.instamojo.com/@joeydash/5b776c791a3c4db0918c06254adf3aad	\N	100876071657723299498	5b776c791a3c4db0918c06254adf3aad	\N
252	Avasarala Krishna Koustubha	ME18B126	\N	\N	\N	9676776292	\N	\N	f	https://www.instamojo.com/@joeydash/8709c2aca0c648e19000a9b541be51c7	\N	104063535906637928892	8709c2aca0c648e19000a9b541be51c7	\N
259	SRIKANTH MALYALA	CE16B040	\N	\N	\N	9092929824	\N	\N	f	https://www.instamojo.com/@joeydash/dc07ae64b0f7405997de6beba4982910	\N	117276624581419753619	dc07ae64b0f7405997de6beba4982910	\N
260	Suhas Kumar	EE17B109	IITM	Electrical Engineering	8.86	9949510388	9840913607	morisettysuhas@gmail.com	t	https://www.instamojo.com/@joeydash/50817e639d3d46d283526c3bdf40d6a9	MOJO9224U05D48153883	116522826000331691456	50817e639d3d46d283526c3bdf40d6a9	\N
236	Bolisetty N V S R Mahesh	ME16B137	IITM	MECHANICAL 	7.89	9493823170	8074617183	bnvsrmaheshiitm@gmail.com	t	https://www.instamojo.com/@joeydash/592b37a2a4ba445883fd51c72a8ce577	MOJO9224V05D48154593	104662693858655380465	592b37a2a4ba445883fd51c72a8ce577	\N
238	Aravamudhan	171101506	\N	\N	\N	9176985869	\N	\N	f	https://www.instamojo.com/@joeydash/f3d19ca8eac646448a02562f4376b3da	\N	102195777194996285654	f3d19ca8eac646448a02562f4376b3da	\N
234	Sourav Bose	ASM17PGDM004	\N	\N	\N	9836948966	\N	\N	f	https://www.instamojo.com/@joeydash/6b32909ec74148dc8feede8740b64d91	\N	104523922747918185043	6b32909ec74148dc8feede8740b64d91	\N
235	Sarva M Sumanth	15G01A0585	\N	\N	\N	7780374216	\N	\N	f	https://www.instamojo.com/@joeydash/cd10670e55f24ce89f3b21c9be5fb2a5	\N	102341274763983527312	cd10670e55f24ce89f3b21c9be5fb2a5	\N
237	Niraj Kumar	17085049	\N	\N	\N	8083305109	\N	\N	f	https://www.instamojo.com/@joeydash/d197deccf0db45bb8a402910a830e2b4	\N	108496699258995503222	d197deccf0db45bb8a402910a830e2b4	\N
241	SAI SREE HARSHA	ME16B132	\N	\N	\N	9940325889	\N	\N	f	https://www.instamojo.com/@joeydash/bbf8937871824ae9b5b498faf080f250	\N	111710272164921687698	bbf8937871824ae9b5b498faf080f250	\N
242	VS Shyam	MM18B114	\N	\N	\N	8903404956	\N	\N	f	https://www.instamojo.com/@joeydash/0f048f7af55e4b18bdc73501446ff4f6	\N	116533323679531504829	0f048f7af55e4b18bdc73501446ff4f6	\N
243	Pruthvi Raj R G	EE17B114	\N	\N	\N	8217387210	\N	\N	f	https://www.instamojo.com/@joeydash/c6f8e91d77d64d40b12c558aa5bd52f2	\N	116667899528785398547	c6f8e91d77d64d40b12c558aa5bd52f2	\N
244	Tejas Tayade	ME17B072	\N	\N	\N	7021467871	\N	\N	f	https://www.instamojo.com/@joeydash/1e03e9f40c784292a7158618cfd96a08	\N	115433360587726830200	1e03e9f40c784292a7158618cfd96a08	\N
245	Rishbha	ME16B162	\N	\N	\N	9500191210	\N	\N	f	https://www.instamojo.com/@joeydash/940fd86efafb469c89a84aa4d5221fdb	\N	103108124271782832702	940fd86efafb469c89a84aa4d5221fdb	\N
250	Sreenadhuni Kishan Rao	ED18B033	\N	\N	\N	9381404355	\N	\N	f	https://www.instamojo.com/@joeydash/b1579a2397ed4c5e8842d99cf4c19543	\N	105576284422817967929	b1579a2397ed4c5e8842d99cf4c19543	\N
253	Atharv Tiwari	18CHE163	\N	\N	\N	7709760009	\N	\N	f	https://www.instamojo.com/@joeydash/7716539db17c4c8e95065484d0a1e25f	\N	112188830982780019541	7716539db17c4c8e95065484d0a1e25f	\N
254	Saurav Jaiswal	16SCS2235	\N	\N	\N	9546852272	\N	\N	f	https://www.instamojo.com/@joeydash/0c36d97956624747a42d2fd55e218d7d	\N	103131193577480666827	0c36d97956624747a42d2fd55e218d7d	\N
255	Shankar T	412415205092	\N	\N	\N	9003175919	\N	\N	f	https://www.instamojo.com/@joeydash/affa54d9adc844e1952c2966cf9ce3f0	\N	108977537476281644524	affa54d9adc844e1952c2966cf9ce3f0	\N
256	Ramita Jawahar 	ME18B164 	\N	\N	\N	9500007218	\N	\N	f	https://www.instamojo.com/@joeydash/21f76882d976497086c6271dca91cb84	\N	105765378409248116613	21f76882d976497086c6271dca91cb84	\N
257	Om Shri Prasath	EE17B113	\N	\N	\N	8072112173	\N	\N	f	https://www.instamojo.com/@joeydash/628627c483de49159a8022d95307c879	\N	108283492057740057468	628627c483de49159a8022d95307c879	\N
258	Gayathri Guggilla 	EE14B086	\N	\N	\N	9790463669	\N	\N	f	https://www.instamojo.com/@joeydash/5be53d49c2f144418270c4ae397c1034	\N	116365908916402634741	5be53d49c2f144418270c4ae397c1034	\N
261	Aakash Kumar Katha	bs15b001	\N	\N	\N	9940143290	\N	\N	f	https://www.instamojo.com/@joeydash/4c3328d86f3c4aa381249d0a37eaa9f8	\N	111790252858780067280	4c3328d86f3c4aa381249d0a37eaa9f8	\N
264	Arabhi Subhash	cs17b005	\N	\N	\N	9440224805	\N	\N	f	https://www.instamojo.com/@joeydash/8b86adec316840d691301b15b5913027	\N	116202437207229418439	8b86adec316840d691301b15b5913027	\N
266	Hanu Siddhanth	ED16B012	\N	\N	\N	9940315984	\N	\N	f	https://www.instamojo.com/@joeydash/479f63b44e154135aaffe9a91c4cd7d4	\N	106286990530112922841	479f63b44e154135aaffe9a91c4cd7d4	\N
267	Ashwin S Nair	CH16B033	\N	\N	\N	9940315981	\N	\N	f	https://www.instamojo.com/@joeydash/060b4cc169a342f79a9c86d4467d6e6c	\N	112870015091726857162	060b4cc169a342f79a9c86d4467d6e6c	\N
268	Tushar Lanjewar	Ch16b042	\N	\N	\N	7261937961	\N	\N	f	https://www.instamojo.com/@joeydash/eea739e3c7884c019b02f9f2a340a1a7	\N	105383915539197235322	eea739e3c7884c019b02f9f2a340a1a7	\N
269	Dev Kabra	ME17B139	\N	\N	\N	9092201788	\N	\N	f	https://www.instamojo.com/@joeydash/10da3392dc9241c3ae97893245ed7050	\N	114663810596979050512	10da3392dc9241c3ae97893245ed7050	\N
270	Yashwanth jain	Nil	\N	\N	\N	9962787953	\N	\N	f	https://www.instamojo.com/@joeydash/181921531dbc4c18a3af2768dc7b870b	\N	100540351647011424813	181921531dbc4c18a3af2768dc7b870b	\N
271	Sake Rohithya	CH18B063	\N	\N	\N	9100883998	\N	\N	f	https://www.instamojo.com/@joeydash/393fcc5015df4c0081251c29172310e4	\N	118415782790952721983	393fcc5015df4c0081251c29172310e4	\N
272	Parthik	Ce15b086	\N	\N	\N	8169596409	\N	\N	f	https://www.instamojo.com/@joeydash/69d6b5b851f14c2e8c72388fcf121f30	\N	115879398366126639386	69d6b5b851f14c2e8c72388fcf121f30	\N
273	Abishek S	EE18B001	\N	\N	\N	6383939046	\N	\N	f	https://www.instamojo.com/@joeydash/779c8e6a1c234ae88cbbc89c5f2cb5c9	\N	110220417219976226248	779c8e6a1c234ae88cbbc89c5f2cb5c9	\N
274	Kothuri kranthi kireet	CE18B039	\N	\N	\N	6303498469	\N	\N	f	https://www.instamojo.com/@joeydash/5daacb17ae9f41fab6585633ba1e591c	\N	118004615112209735453	5daacb17ae9f41fab6585633ba1e591c	\N
275	Revanth Chandra G	CH16b007	\N	\N	\N	9940309948	\N	\N	f	https://www.instamojo.com/@joeydash/a20d7d9c6a1044a1a6a7ed8e475e0e4e	\N	103438144378005049128	a20d7d9c6a1044a1a6a7ed8e475e0e4e	\N
276	B. Abhilash 	EE17B123 	\N	\N	\N	9445684978 	\N	\N	f	https://www.instamojo.com/@joeydash/94c46fa638114b8bbf0f326a9be1a2d4	\N	105648755733096962226	94c46fa638114b8bbf0f326a9be1a2d4	\N
277	Vividh Garg	CH16B072	\N	\N	\N	+919409053136	\N	\N	f	https://www.instamojo.com/@joeydash/ceeadc88c35d4140aa29fc07115d1309	\N	110816632514375330936	ceeadc88c35d4140aa29fc07115d1309	\N
278	Deepak Varma Mudigonda	CE16B123	\N	\N	\N	8428315991	\N	\N	f	https://www.instamojo.com/@joeydash/4e4d6ffd75c84d04ad6404763742b3bc	\N	104819180766332055249	4e4d6ffd75c84d04ad6404763742b3bc	\N
279	Akshat Singh	CS18B001	\N	\N	\N	7355717394	\N	\N	f	https://www.instamojo.com/@joeydash/8d0e4c6810de4f6d94e7ba908351501f	\N	102636321268460229245	8d0e4c6810de4f6d94e7ba908351501f	\N
280	Satya Rohith B	AE16B022	\N	\N	\N	9940311495	\N	\N	f	https://www.instamojo.com/@joeydash/9c8b89da4321464e868675b7bb2a3cbe	\N	108657894448748089100	9c8b89da4321464e868675b7bb2a3cbe	\N
281	Harini	107117043	\N	\N	\N	8056443379	\N	\N	f	https://www.instamojo.com/@joeydash/011acce1c3f74a33a2b49790f289f9fe	\N	112550532760599361927	011acce1c3f74a33a2b49790f289f9fe	\N
282	Lalitha	CE17B063	\N	\N	\N	9444425923	\N	\N	f	https://www.instamojo.com/@joeydash/8380853396f14f2ebbeaafd4238cfbde	\N	101136801595257969901	8380853396f14f2ebbeaafd4238cfbde	\N
283	Suparshva Jain 	CH16B114	\N	\N	\N	9669348116 	\N	\N	f	https://www.instamojo.com/@joeydash/5bfdbf3209e94d70a573cf57e9db3265	\N	115889029059451906334	5bfdbf3209e94d70a573cf57e9db3265	\N
284	Rakesh Raushan 	Ae16b109	\N	\N	\N	9940332489	\N	\N	f	https://www.instamojo.com/@joeydash/c95aeb12804a4b198b2550268a05d50c	\N	101457174803921195320	c95aeb12804a4b198b2550268a05d50c	\N
285	Wasim akram	Mm18b032	\N	\N	\N	9381884341	\N	\N	f	https://www.instamojo.com/@joeydash/f07440c3072a4a1b96f6c7c894b1e27c	\N	118180651001550783697	f07440c3072a4a1b96f6c7c894b1e27c	\N
286	Gabriel Ve Vance	EE17B105	\N	\N	\N	8547083904	\N	\N	f	https://www.instamojo.com/@joeydash/a547d85af1a04ad8bc296f0d3884ca95	\N	102735459409810377329	a547d85af1a04ad8bc296f0d3884ca95	\N
287	Navya prasad	1js16ec054	\N	\N	\N	9886616684	\N	\N	f	https://www.instamojo.com/@joeydash/0485770aeee44d70a4e725b95e67df15	\N	107008061572479616642	0485770aeee44d70a4e725b95e67df15	\N
288	Aliraza Merchant	131020109044	\N	\N	\N	9723700175	\N	\N	f	https://www.instamojo.com/@joeydash/32644f7a2fe3476bbe8ba2f999112669	\N	103723685173753170428	32644f7a2fe3476bbe8ba2f999112669	\N
290	P.S.Vasupradha	RA1811004040005	\N	\N	\N	8310256305	\N	\N	f	https://www.instamojo.com/@joeydash/932b337c834c40a8bb2af46f526bdbf5	\N	108013768579266369989	932b337c834c40a8bb2af46f526bdbf5	\N
291	Kethavath kiran	EE18M037	\N	\N	\N	9491486768	\N	\N	f	https://www.instamojo.com/@joeydash/d061922870294ac498a0d816536a93d8	\N	109215285114265989714	d061922870294ac498a0d816536a93d8	\N
292	Navneeth Suresh	Ch16b111	\N	\N	\N	9884330885	\N	\N	f	https://www.instamojo.com/@joeydash/e130a38ff31e470e8ab3d0781155dd8d	\N	114454817398927418390	e130a38ff31e470e8ab3d0781155dd8d	\N
293	Pavan Kumar 	Ae16b023	\N	\N	\N	8639289014	\N	\N	f	https://www.instamojo.com/@joeydash/5e8dad5340d044b589e4076b31966b4c	\N	102481396492377586097	5e8dad5340d044b589e4076b31966b4c	\N
289	Shree Pandey	Mm18b113	\N	\N	\N	8319101668	\N	\N	f	https://www.instamojo.com/@joeydash/369c4e993c40425bac16c404cc418f6a	\N	100744438715150722107	369c4e993c40425bac16c404cc418f6a	\N
294	Shriram Elangovan 	CH18B107 	\N	\N	\N	9884883040	\N	\N	f	https://www.instamojo.com/@joeydash/660a3e6ba4454e7886bf9b060347318d	\N	111335512155779191240	660a3e6ba4454e7886bf9b060347318d	\N
295	Narayan Srinivasan	EE15B108	\N	\N	\N	9790802716	\N	\N	f	https://www.instamojo.com/@joeydash/28a5a56f66dc41f488211dfcdd42fd11	\N	114813019548048172570	28a5a56f66dc41f488211dfcdd42fd11	\N
296	Ajmal Hussain	HS17H035	\N	\N	\N	8086746304	\N	\N	f	https://www.instamojo.com/@joeydash/b3cba7f98151454fbeb357c2514be0fa	\N	103396227673197383401	b3cba7f98151454fbeb357c2514be0fa	\N
297	Shreekara Guruprasad	ME17B035	\N	\N	\N	7259742606	\N	\N	f	https://www.instamojo.com/@joeydash/1dbe4b7ed5d14d46bf88607dfb2a3b1f	\N	101042086808084988246	1dbe4b7ed5d14d46bf88607dfb2a3b1f	\N
298	Malu Deep Kamal	ME17B056	\N	\N	\N	7010826642	\N	\N	f	https://www.instamojo.com/@joeydash/a601124a9e584c569c6a0108055df1c1	\N	112744303022609382424	a601124a9e584c569c6a0108055df1c1	\N
299	Rudra Desai	cs18b012	\N	\N	\N	8401219589	\N	\N	f	https://www.instamojo.com/@joeydash/c7d7dd1459ea48ddb4692ba626a4b7be	\N	116047930466793291791	c7d7dd1459ea48ddb4692ba626a4b7be	\N
300	Anirudh Murali	ME18B123 	\N	\N	\N	7021729025 	\N	\N	f	https://www.instamojo.com/@joeydash/ea64fb9dd2304ba4917f0a782b7979b5	\N	106307654230780304539	ea64fb9dd2304ba4917f0a782b7979b5	\N
301	Guru Subramanian	EP17B001	\N	\N	\N	9944859017	\N	\N	f	https://www.instamojo.com/@joeydash/992117a3e8184ce6849bc78700621aaa	\N	113809084463578215556	992117a3e8184ce6849bc78700621aaa	\N
303	Mangalam Kumar Mishra	17M19	\N	\N	\N	7250874986	\N	\N	f	https://www.instamojo.com/@joeydash/17754942acf842a096c2a02b4916f393	\N	114564795634879121831	17754942acf842a096c2a02b4916f393	\N
304	Rohit Kadvekar	ME16B112	\N	\N	\N	9326003932	\N	\N	f	https://www.instamojo.com/@joeydash/41aaa4f82fc14b0d9c3faf620bfccfe3	\N	117829093653038208495	41aaa4f82fc14b0d9c3faf620bfccfe3	\N
305	Sundar Raman P	EE17B069	\N	\N	\N	8056040677	\N	\N	f	https://www.instamojo.com/@joeydash/661acb4ae61042f7aab3f979c51e243d	\N	101529745547818567302	661acb4ae61042f7aab3f979c51e243d	\N
306	SHUBHAM KUMAR	17IT40	\N	\N	\N	7319884578	\N	\N	f	https://www.instamojo.com/@joeydash/b9e20a342d3049208e42952969765357	\N	100903677923974025368	b9e20a342d3049208e42952969765357	\N
307	Gokul Venkatesan	ME18B047	\N	\N	\N	8190973360 	\N	\N	f	https://www.instamojo.com/@joeydash/445799b9aeab4f6c8996dbe9443c426e	\N	102696267879158004647	445799b9aeab4f6c8996dbe9443c426e	\N
308	Y sai sorry vardhan	R141649	\N	\N	\N	9133868659	\N	\N	f	https://www.instamojo.com/@joeydash/0c6ff28f638848f48f76ef902924060c	\N	113493577180279750534	0c6ff28f638848f48f76ef902924060c	\N
309	Rohit Dasari	CE16B121	\N	\N	\N	9500195690	\N	\N	f	https://www.instamojo.com/@joeydash/2560ce2013954a12ba53dc86a8c7db8a	\N	104261072724142761059	2560ce2013954a12ba53dc86a8c7db8a	\N
310	Akash Pramod Yalla 	EE17B037	\N	\N	\N	9502031390	\N	\N	f	https://www.instamojo.com/@joeydash/836680ddb24d4dfd9a6aa80d673db62e	\N	112485056914497957154	836680ddb24d4dfd9a6aa80d673db62e	\N
311	Krishna vamsi	ce17b018	\N	\N	\N	8179736569	\N	\N	f	https://www.instamojo.com/@joeydash/b7a09e75e27f459093e09658f6f3ffbe	\N	114919245168293555948	b7a09e75e27f459093e09658f6f3ffbe	\N
312	Praveena 	Ch16b006	\N	\N	\N	7550195160	\N	\N	f	https://www.instamojo.com/@joeydash/8328410bd09d406c8b878a6055f296ad	\N	103607262433637419142	8328410bd09d406c8b878a6055f296ad	\N
313	pm siddharth 	ch18b016	\N	\N	\N	7358241762	\N	\N	f	https://www.instamojo.com/@joeydash/f02ff43e5f1845f582b42707b6b6180b	\N	104947023065993961827	f02ff43e5f1845f582b42707b6b6180b	\N
314	Hari Shankar SJ	EE17B011	\N	\N	\N	9445396201	\N	\N	f	https://www.instamojo.com/@joeydash/dc1748c40b084cad9f36856a4e9aedbd	\N	110834837890329203639	dc1748c40b084cad9f36856a4e9aedbd	\N
315	Hrishikesh T M	ED16B013	\N	\N	\N	9500188576	\N	\N	f	https://www.instamojo.com/@joeydash/1204cccc76d74d7bb836400b356d985b	\N	100666867636647034609	1204cccc76d74d7bb836400b356d985b	\N
316	Shivansh Rai	17311015	\N	\N	\N	9685577110	\N	\N	f	https://www.instamojo.com/@joeydash/aac8f6eb1b0d4d39bd6930e5bca7c8d1	\N	106415391789496258631	aac8f6eb1b0d4d39bd6930e5bca7c8d1	\N
317	Vandit kumar garg	CE18B128	\N	\N	\N	7023980385	\N	\N	f	https://www.instamojo.com/@joeydash/2c2538e8b1e44319ac84bd3d7754767d	\N	105966691583185367517	2c2538e8b1e44319ac84bd3d7754767d	\N
318	Abhishek r gopalan	Ch18b032	\N	\N	\N	9789960749	\N	\N	f	https://www.instamojo.com/@joeydash/4cae156467eb4364954187e613e5652f	\N	115566315786288546293	4cae156467eb4364954187e613e5652f	\N
319	Kudari Saraswathi	CE17B105	\N	\N	\N	9182053778	\N	\N	f	https://www.instamojo.com/@joeydash/75f2dbadb46343e3ac005d8e4902888e	\N	107814725617372580100	75f2dbadb46343e3ac005d8e4902888e	\N
320	Siddhant Ranavare	CH18B025	\N	\N	\N	8898939393	\N	\N	f	https://www.instamojo.com/@joeydash/a23cf9f9384845449a34f00ad77fcf89	\N	108600984309818701065	a23cf9f9384845449a34f00ad77fcf89	\N
321	Shubham Dayanand Mashalkar	SEETC327	\N	\N	\N	9766566338	\N	\N	f	https://www.instamojo.com/@joeydash/9cd1fd5143fb44c78cfb5fa2c602d2a4	\N	108390131197877790585	9cd1fd5143fb44c78cfb5fa2c602d2a4	\N
322	Pranay Mandar	CE17B004	\N	\N	\N	9642619181	\N	\N	f	https://www.instamojo.com/@joeydash/99a4c9d46d2043cf85e9453dab49f6fd	\N	102078790618882377357	99a4c9d46d2043cf85e9453dab49f6fd	\N
323	MD Izaan Hassan	CE17B047	\N	\N	\N	9840887534	\N	\N	f	https://www.instamojo.com/@joeydash/673ca9729a4d4b9383215cd2c784d4a3	\N	114879248319936894164	673ca9729a4d4b9383215cd2c784d4a3	\N
324	Ashish Kumar	0526cs161010	\N	\N	\N	9955737903	\N	\N	f	https://www.instamojo.com/@joeydash/904b960c854a41798155553886f902ec	\N	101898331174970475313	904b960c854a41798155553886f902ec	\N
325	Parekh Harsh Malay	ME16B173	\N	\N	\N	8097448364	\N	\N	f	https://www.instamojo.com/@joeydash/a16c4ea9ebb74575936054b9cc19ce68	\N	108623107305019567249	a16c4ea9ebb74575936054b9cc19ce68	\N
326	Akshay Anil Dewalwar 	ME15B080	\N	\N	\N	9962740490 	\N	\N	f	https://www.instamojo.com/@joeydash/57eb0036a927494db3e71a31a0e48691	\N	105867436203536915647	57eb0036a927494db3e71a31a0e48691	\N
327	Pavan kalyan	Ch17b056	\N	\N	\N	9182257358	\N	\N	f	https://www.instamojo.com/@joeydash/aebef7111a644d478df94e27b6b643ce	\N	102021247714894981375	aebef7111a644d478df94e27b6b643ce	\N
328	Veeresh 	Ep17b013	\N	\N	\N	9110865520	\N	\N	f	https://www.instamojo.com/@joeydash/5f5ba929fbc94977bdd3d586a6d32998	\N	115337446901304980916	5f5ba929fbc94977bdd3d586a6d32998	\N
329	Jawahar Ram	BS17B014	\N	\N	\N	9445272156	\N	\N	f	https://www.instamojo.com/@joeydash/e7d038800878485a80ea014f211fd9cd	\N	100628633987918286449	e7d038800878485a80ea014f211fd9cd	\N
330	Vivek bharathi	40	\N	\N	\N	9600316153	\N	\N	f	https://www.instamojo.com/@joeydash/b4c066df52f849658aa7147c4effad29	\N	100356755692278374488	b4c066df52f849658aa7147c4effad29	\N
331	Santosh Sriram	ch18b065	\N	\N	\N	9176562132	\N	\N	f	https://www.instamojo.com/@joeydash/a54171fcc94140a092e1041da484cb57	\N	103825959457084390467	a54171fcc94140a092e1041da484cb57	\N
334	Nasreen	ce17b120	\N	\N	\N	9182673561	\N	\N	f	https://www.instamojo.com/@joeydash/5938f2d66f03404780441ec021f3c5c0	\N	102032140608250677548	5938f2d66f03404780441ec021f3c5c0	\N
332	Ujwal kumar	1MV17CS129	\N	\N	\N	+919611478322	\N	\N	f	https://www.instamojo.com/@joeydash/2e39ddaa231543219fceb81d03af0e22	\N	114049354868175047110	2e39ddaa231543219fceb81d03af0e22	\N
335	Meka Sai Krishna	AE17B007	\N	\N	\N	9790935431	\N	\N	f	https://www.instamojo.com/@joeydash/0d6a5d72070b42a9914a4f092ae6a38f	\N	112966794963954956260	0d6a5d72070b42a9914a4f092ae6a38f	\N
337	Piyush Sanjeev Agarwal	2017A1PS0898	\N	\N	\N	9028012394	\N	\N	f	https://www.instamojo.com/@joeydash/187b8be843d04c67917f05963183670d	\N	116666622718086105584	187b8be843d04c67917f05963183670d	\N
341	Chella Thiyagarajan N 	ME17B179	\N	\N	\N	8903766607	\N	\N	f	https://www.instamojo.com/@joeydash/58dbd7c209784373945664d209788222	\N	110719102246911509342	58dbd7c209784373945664d209788222	\N
265	Vivek S	CE16B064	IITM	CIVIL ENGINEERING	6.94	9947835672	8075815920	vivek.kottakkal@gmail.com	t	https://www.instamojo.com/@joeydash/4984c8d726764c8eb05c1cbb6c118dd1	MOJO9224905N48154892	111650156609320815046	4984c8d726764c8eb05c1cbb6c118dd1	\N
342	Dande Sai Ridhima	CE17B029	\N	\N	\N	8790182236	\N	\N	f	https://www.instamojo.com/@joeydash/5b5944ef6d14403da8e361d2de7cb53b	\N	108833854089057606604	5b5944ef6d14403da8e361d2de7cb53b	\N
336	Harshit Kedia	CS17B103	\N	\N	\N	8947041241	\N	\N	f	https://www.instamojo.com/@joeydash/77af11b1d35f4e1cba5638df7116666f	\N	100386862991581341157	77af11b1d35f4e1cba5638df7116666f	\N
338	Mounika Kambham	Be17b020	\N	\N	\N	9840925420	\N	\N	f	https://www.instamojo.com/@joeydash/99ad80e9bba74eee9c452170e9d4b41a	\N	106113073509749904874	99ad80e9bba74eee9c452170e9d4b41a	\N
339	Nikhil Saini	Ce18b044	\N	\N	\N	9982709232	\N	\N	f	https://www.instamojo.com/@joeydash/94fdf4bab51b4363b9a090f106fdbd79	\N	108121395666667399036	94fdf4bab51b4363b9a090f106fdbd79	\N
340	Pradeep Bokka	CS18M016	\N	\N	\N	7702344122	\N	\N	f	https://www.instamojo.com/@joeydash/83fc4b7dc83747d0b8129ad87682eec1	\N	100409827768971410841	83fc4b7dc83747d0b8129ad87682eec1	\N
343	GAYATHRI DEVI S	611716104006	\N	\N	\N	9487425735	\N	\N	f	https://www.instamojo.com/@joeydash/4a62a597c54a4e819a8976ee47d4bb49	\N	103740957304582810016	4a62a597c54a4e819a8976ee47d4bb49	\N
344	Susmitha	113216103081	\N	\N	\N	9677683645	\N	\N	f	https://www.instamojo.com/@joeydash/66acb7d0a46d48679eaad0b7260bcea2	\N	101145697867206691422	66acb7d0a46d48679eaad0b7260bcea2	\N
345	MEDASANI RAKESH	EE17B108	\N	\N	\N	9491007655	\N	\N	f	https://www.instamojo.com/@joeydash/143c1f6b597b4edbac7ea784a83f4e8e	\N	109309174537793376519	143c1f6b597b4edbac7ea784a83f4e8e	\N
347	Esakki Ganesh 	59521	\N	\N	\N	9488988848 	\N	\N	f	https://www.instamojo.com/@joeydash/1aa43bf9acc64ab48e283507b8a71328	\N	102478213252906447785	1aa43bf9acc64ab48e283507b8a71328	\N
348	MOHD FAISAL	CH16B110	\N	\N	\N	8299094428	\N	\N	f	https://www.instamojo.com/@joeydash/13223f72d0534e6a8d67146901694e73	\N	109052781110646956753	13223f72d0534e6a8d67146901694e73	\N
349	Monish Kumar V	CE18B118	\N	\N	\N	7010680040	\N	\N	f	https://www.instamojo.com/@joeydash/579a76a4c95d45b181fcb73f8d430603	\N	113546016407135303566	579a76a4c95d45b181fcb73f8d430603	\N
350	Purav Pandya	ce18b046	\N	\N	\N	7211147197	\N	\N	f	https://www.instamojo.com/@joeydash/e7642737e179440f90b401db257e56ea	\N	116858837678187515139	e7642737e179440f90b401db257e56ea	\N
352	Sai N	Be17b010	\N	\N	\N	9952918124	\N	\N	f	https://www.instamojo.com/@joeydash/d51f770d860c459fb4138e6129b76359	\N	117874484285329294192	d51f770d860c459fb4138e6129b76359	\N
353	Raghul Shreeram S	ED18B023	\N	\N	\N	9566466794	\N	\N	f	https://www.instamojo.com/@joeydash/8bd54f40984242b89b90d2e71920fb4a	\N	108340065003624681178	8bd54f40984242b89b90d2e71920fb4a	\N
355	Breasha Gupta	BE17B015	\N	\N	\N	9137932713	\N	\N	f	https://www.instamojo.com/@joeydash/ee1f4d769c844b8a9b9521deb79982cd	\N	103736639878516984826	ee1f4d769c844b8a9b9521deb79982cd	\N
356	Duggirala Rohith Raj 	Na16b021 	\N	\N	\N	7449103403 	\N	\N	f	https://www.instamojo.com/@joeydash/45d3062828c64e5dbac407155264806e	\N	110865832851443517161	45d3062828c64e5dbac407155264806e	\N
357	Sujay Bokil	ME17B120	\N	\N	\N	9840921440	\N	\N	f	https://www.instamojo.com/@joeydash/da8b39ca44ec45c2a7ea72f1a981ead5	\N	101908311592942095194	da8b39ca44ec45c2a7ea72f1a981ead5	\N
358	N S KEERTHI 	BT18M018 	\N	\N	\N	7760684168	\N	\N	f	https://www.instamojo.com/@joeydash/7531b1d5667b40eab24feced1c6dae09	\N	114118288202789491662	7531b1d5667b40eab24feced1c6dae09	\N
351	Mohit Singla	CS17B113	IIT Madras	Computer Science and Engineering	9.55	9877092646	8360489123	mohitsingla1098@gmail.com	t	https://www.instamojo.com/@joeydash/88c9cfebf84f4cfeb429e51c3d6619b8	MOJO9224N05D48155188	101907654598338293396	88c9cfebf84f4cfeb429e51c3d6619b8	\N
354	Vinayathi	CE16B021	IITM	Civil engineering	6.17	9500182979	8639167146	vinayathi.iitm@gmail.com	t	https://www.instamojo.com/@joeydash/d9e0430ccb2747d88ba725f1072940fd	MOJO9224Y05D48155197	102818605285608644890	d9e0430ccb2747d88ba725f1072940fd	\N
359	Siddharth D P	EE18B072	\N	\N	\N	8050678320	\N	\N	f	https://www.instamojo.com/@joeydash/ab2a2604a6004d64b7de95a92e1c8d09	\N	111673488765813015438	ab2a2604a6004d64b7de95a92e1c8d09	\N
360	Anshu Rathour	RA1611008020121	\N	\N	\N	8789686848	\N	\N	f	https://www.instamojo.com/@joeydash/42af80820370466eb39d06a1307e5061	\N	107020637866794952560	42af80820370466eb39d06a1307e5061	\N
361	Komal k	1js15ec039	\N	\N	\N	9980724745	\N	\N	f	https://www.instamojo.com/@joeydash/e877df60cf2b4309bb2861106713529a	\N	104490561986228753301	e877df60cf2b4309bb2861106713529a	\N
362	Bheemarasetty raja venkata satya saikumar 	AE17B102	\N	\N	\N	9840930368	\N	\N	f	https://www.instamojo.com/@joeydash/73da37953763405789281dd805f1f596	\N	108208364475622836441	73da37953763405789281dd805f1f596	\N
364	Arundhati Medya	BT18M005	\N	\N	\N	9903687201	\N	\N	f	https://www.instamojo.com/@joeydash/7a22c83640f54acbb6f82063f462ce89	\N	113382390019554265804	7a22c83640f54acbb6f82063f462ce89	\N
365	Sharath Kumar K	171101502	\N	\N	\N	7904459959	\N	\N	f	https://www.instamojo.com/@joeydash/9c74dedf9c3c4e3db9e6667d5a40a85f	\N	118048228050424097200	9c74dedf9c3c4e3db9e6667d5a40a85f	\N
363	Ujjal Nandy	ME17B085	IITM	Mechanical	9.09	9840905014	null		t	https://www.instamojo.com/@joeydash/8a833848fba444a9a3ba8c369b47c015	MOJO9224N05A48155514	109793064286665109593	8a833848fba444a9a3ba8c369b47c015	\N
366	Pushpak Waskle	Bs16b006	\N	\N	\N	7477286728	\N	\N	f	https://www.instamojo.com/@joeydash/5f10bfcaca954f9d83bf3db1d921e72b	\N	111720544730942682902	5f10bfcaca954f9d83bf3db1d921e72b	\N
367	Amarendra Kumar	1504510005	\N	\N	\N	7236969358	\N	\N	f	https://www.instamojo.com/@joeydash/3c20877060534d1ba680ee595e9d3ef8	\N	101937276611031739312	3c20877060534d1ba680ee595e9d3ef8	\N
368	Althaf Shaik	R151631	\N	\N	\N	9490304798	\N	\N	f	https://www.instamojo.com/@joeydash/513eb70f79404ac491250d0a7573f9ff	\N	113591277455155100948	513eb70f79404ac491250d0a7573f9ff	\N
369	Kaviya.R	312316106088	\N	\N	\N	8939272026	\N	\N	f	https://www.instamojo.com/@joeydash/d46e4b39284442e98f046750d3570164	\N	115890582017119856079	d46e4b39284442e98f046750d3570164	\N
370	Koyya likitha sai megana 	16131A0246	\N	\N	\N	9010252223 	\N	\N	f	https://www.instamojo.com/@joeydash/78ce6506df294c339c3b73777f5fc8c1	\N	101589422478585216731	78ce6506df294c339c3b73777f5fc8c1	\N
371	Adarsh Jagtap	BE18B003	\N	\N	\N	7425867800	\N	\N	f	https://www.instamojo.com/@joeydash/408f3e4023424e85b6fa6f9d3bdcd6ad	\N	113477294628654744659	408f3e4023424e85b6fa6f9d3bdcd6ad	\N
372	Vipul Gaurav	1MV16CS124	\N	\N	\N	9986804620	\N	\N	f	https://www.instamojo.com/@joeydash/1f363eeb0c5d411d9e0aa05fc5e213da	\N	101521652097057965274	1f363eeb0c5d411d9e0aa05fc5e213da	\N
373	DEEKSHA R	1MV16ME025	\N	\N	\N	7259720474	\N	\N	f	https://www.instamojo.com/@joeydash/d69c48f94c5d476f992338e3e76ef76e	\N	113726068402775339149	d69c48f94c5d476f992338e3e76ef76e	\N
374	Adarsh Kumar Patil	ae17b017	\N	\N	\N	6377006521	\N	\N	f	https://www.instamojo.com/@joeydash/689a3fdd0d394a039f8a11a365270a51	\N	109376490111650622719	689a3fdd0d394a039f8a11a365270a51	\N
375	Mahasweta Dasgupta 	16uce021	\N	\N	\N	7085635213	\N	\N	f	https://www.instamojo.com/@joeydash/48a622e73eb0430580cfc1dd976c453a	\N	108496485977679015175	48a622e73eb0430580cfc1dd976c453a	\N
376	Ashutosh Patil	ME17B001	\N	\N	\N	7981587869	\N	\N	f	https://www.instamojo.com/@joeydash/e7c8fc8e8f2846f4940fdc62d1e920d7	\N	108580434982066918605	e7c8fc8e8f2846f4940fdc62d1e920d7	\N
377	A Karunakaran 	Ms 18a 013	\N	\N	\N	9502860564	\N	\N	f	https://www.instamojo.com/@joeydash/e886648814754ee1b93215c3dd71bda3	\N	107225841050163511047	e886648814754ee1b93215c3dd71bda3	\N
379	Harsh Sheth	CE15B075	\N	\N	\N	9820440431	\N	\N	f	https://www.instamojo.com/@joeydash/ca31ef1f27604ae5bf137200fae754a4	\N	117668160078649532199	ca31ef1f27604ae5bf137200fae754a4	\N
380	Shivesh	NA18B114	\N	\N	\N	8104959938	\N	\N	f	https://www.instamojo.com/@joeydash/12752da0c7fb40b4af6a949c672d84ec	\N	110174260954976084383	12752da0c7fb40b4af6a949c672d84ec	\N
384	B Midhun Varman	ee18b113	\N	\N	\N	6379518551	\N	\N	f	https://www.instamojo.com/@joeydash/e759ddb032114e568b542eab0355c4d1	\N	102216187786719638066	e759ddb032114e568b542eab0355c4d1	\N
378	Sourav Sahoo	EE17B040	IITM	Electrical Engineering	9.54	7665194156	null	sahoo.sourav1999@gmail.com	t	https://www.instamojo.com/@joeydash/251da30f003848be88fa666e925927e6	MOJO9224905A48156421	103626818376068643468	251da30f003848be88fa666e925927e6	\N
381	SUMIT KUMAR	17UCE185	\N	\N	\N	7297066735	\N	\N	f	https://www.instamojo.com/@joeydash/a63c75a28148499d8e32a8c1bd023cf9	\N	113078466770221533079	a63c75a28148499d8e32a8c1bd023cf9	\N
382	MUKESH KANTH.S	NA18B101	\N	\N	\N	9940117603	\N	\N	f	https://www.instamojo.com/@joeydash/d87967bb69a04f0194d065bee331771b	\N	100429882498919065692	d87967bb69a04f0194d065bee331771b	\N
383	Anunay Khetan	I028	\N	\N	\N	9421623405	\N	\N	f	https://www.instamojo.com/@joeydash/b8ec5d47ceeb477c8942cd78ded3e231	\N	105377586685653541429	b8ec5d47ceeb477c8942cd78ded3e231	\N
385	Shubham Jha	12180080	\N	\N	\N	6381849891	\N	\N	f	https://www.instamojo.com/@joeydash/63e2fb2e3aab463b8c757ccb6c140de8	\N	106278554674995616834	63e2fb2e3aab463b8c757ccb6c140de8	\N
386	Deep Sahni	NA16B110	\N	\N	\N	8240186950	\N	\N	f	https://www.instamojo.com/@joeydash/304e1f900c7f40a6b72a6ade1e1751cb	\N	100107002515350266130	304e1f900c7f40a6b72a6ade1e1751cb	\N
387	Veluru Vinodh	17104099	\N	\N	\N	9100486610	\N	\N	f	https://www.instamojo.com/@joeydash/2a94474975464bdd8050d0de038fcd22	\N	111370167988093752199	2a94474975464bdd8050d0de038fcd22	\N
388	Achraj Sarma	AE15B004	\N	\N	\N	9566102389	\N	\N	f	https://www.instamojo.com/@joeydash/8a17d0a3cd9e46d289df0d06a8dab8a4	\N	105392264781439901850	8a17d0a3cd9e46d289df0d06a8dab8a4	\N
389	Suraj	21	\N	\N	\N	8461069246	\N	\N	f	https://www.instamojo.com/@joeydash/22328fdbf2dc41b097f0afaae9e13f2b	\N	105969740549441975949	22328fdbf2dc41b097f0afaae9e13f2b	\N
390	Nimisha Sharma	AE17B113	\N	\N	\N	9314766790	\N	\N	f	https://www.instamojo.com/@joeydash/72c4e30a2c8946e9b47ee28f3711262f	\N	105637238575566408188	72c4e30a2c8946e9b47ee28f3711262f	\N
391	Akanksha	17113012	\N	\N	\N	8572863148	\N	\N	f	https://www.instamojo.com/@joeydash/da397e8019ea401a918d749721a9cb4c	\N	108682568981573619294	da397e8019ea401a918d749721a9cb4c	\N
392	Sanjana	ee17b072	\N	\N	\N	8971735336	\N	\N	f	https://www.instamojo.com/@joeydash/f99911267ce44f869ac0d589397956a8	\N	104348561115381214339	f99911267ce44f869ac0d589397956a8	\N
393	Sooryakiran	ME17B174	\N	\N	\N	9789819860	\N	\N	f	https://www.instamojo.com/@joeydash/c00b7f22c7704fd286497914e7a831d9	\N	114990232765248097863	c00b7f22c7704fd286497914e7a831d9	\N
395	Raghu Veer. T	ME16B160	\N	\N	\N	9494013799	\N	\N	f	https://www.instamojo.com/@joeydash/bf7f49576d7c4410ac646773bffb68d9	\N	114468659310476432891	bf7f49576d7c4410ac646773bffb68d9	\N
397	Rahul Singla	CH17B065	\N	\N	\N	8054342464	\N	\N	f	https://www.instamojo.com/@joeydash/9c5e7a85f3234114835dfa4d105e4881	\N	104971261271364772625	9c5e7a85f3234114835dfa4d105e4881	\N
398	Dakshana 	HS17H021 	\N	\N	\N	9176820038 	\N	\N	f	https://www.instamojo.com/@joeydash/111ebd73385648fa974de2728610d10d	\N	111516434597847091452	111ebd73385648fa974de2728610d10d	\N
399	Chandrama	52	\N	\N	\N	9082971250	\N	\N	f	https://www.instamojo.com/@joeydash/8561b247a86e41e0b0b62502d46dfbdb	\N	106864235843535730933	8561b247a86e41e0b0b62502d46dfbdb	\N
400	Raviteja D	AE16B007	\N	\N	\N	9010720419	\N	\N	f	https://www.instamojo.com/@joeydash/a33eb0f19c84490d84ae09ea09acc8c0	\N	113663342479235055911	a33eb0f19c84490d84ae09ea09acc8c0	\N
401	Hari Narayanan 	106117043	\N	\N	\N	8946007602	\N	\N	f	https://www.instamojo.com/@joeydash/22bb98734d6f489b926c1f43a6211bfb	\N	106520394041788378062	22bb98734d6f489b926c1f43a6211bfb	\N
402	Raj Kumar Singh	OE17M058	\N	\N	\N	9545592420	\N	\N	f	https://www.instamojo.com/@joeydash/6f537237ff364bb39d69674b1330b71b	\N	105889863618992805661	6f537237ff364bb39d69674b1330b71b	\N
403	Shashank V	CH17B119	\N	\N	\N	9176939845	\N	\N	f	https://www.instamojo.com/@joeydash/a87a186979694091a7cf931524807fb9	\N	116325192833520695834	a87a186979694091a7cf931524807fb9	\N
404	Kiran Kumar	ME16B104	\N	\N	\N	7702210101	\N	\N	f	https://www.instamojo.com/@joeydash/d250b9d82a444decb457b7e4e66de541	\N	103388567827480574153	d250b9d82a444decb457b7e4e66de541	\N
406	Krishna  vamsi	AE17B036 	\N	\N	\N	8309929647	\N	\N	f	https://www.instamojo.com/@joeydash/2e34d7de5d5442b995e283c89922f62b	\N	100007341599144671991	2e34d7de5d5442b995e283c89922f62b	\N
407	R Jean Paul 	312316106076	\N	\N	\N	9789822905	\N	\N	f	https://www.instamojo.com/@joeydash/597db052153747d4be919661c2590022	\N	100091215008298175933	597db052153747d4be919661c2590022	\N
408	Tejas Anand Srivastava	17DTPH017	\N	\N	\N	9450233330	\N	\N	f	https://www.instamojo.com/@joeydash/56a231514c9d42aaaeece9041ebd0f52	\N	103349567730122948734	56a231514c9d42aaaeece9041ebd0f52	\N
409	Subhash Ranjan	Na16b037	\N	\N	\N	7564037052	\N	\N	f	https://www.instamojo.com/@joeydash/89d3e1f7660848e9a57ca46580b00efd	\N	107391169496297798803	89d3e1f7660848e9a57ca46580b00efd	\N
410	Akella Srinivas Marthand	17331A0101	\N	\N	\N	9492745773	\N	\N	f	https://www.instamojo.com/@joeydash/d075703af83f458883ecfb2b4082e395	\N	110147729374572380021	d075703af83f458883ecfb2b4082e395	\N
412	Sanket Kasbale	AE17B042	\N	\N	\N	8237889123	\N	\N	f	https://www.instamojo.com/@joeydash/95562db87a5c418b8031fd1fa0262bf4	\N	101973134345965974975	95562db87a5c418b8031fd1fa0262bf4	\N
413	Agila s	108117004	\N	\N	\N	9003036317	\N	\N	f	https://www.instamojo.com/@joeydash/c63f34a551a8436bb471f1670daf512c	\N	108827967019219649387	c63f34a551a8436bb471f1670daf512c	\N
417	Adithyan Radhakrishnan 	EP15B001 	\N	\N	\N	9840279276	\N	\N	f	https://www.instamojo.com/@joeydash/0308dc07ee5a47d586f642f19ea25050	\N	108093437797103881179	0308dc07ee5a47d586f642f19ea25050	\N
418	Sonawane Priyanka Nandu	231	\N	\N	\N	7776885221	\N	\N	f	https://www.instamojo.com/@joeydash/cffcad725ae24cf5a15f576b584af620	\N	111262646770972346368	cffcad725ae24cf5a15f576b584af620	\N
419	VARUN SAHAY	CE17B020	\N	\N	\N	8074073468	\N	\N	f	https://www.instamojo.com/@joeydash/f4a7a596828d4729897b33d7bf717393	\N	114962124492980809294	f4a7a596828d4729897b33d7bf717393	\N
420	Ajaiy Ramasubramanian	AE17B019	\N	\N	\N	9952030980	\N	\N	f	https://www.instamojo.com/@joeydash/cad10db4ff944f0c93b8e2ea26cb1ddf	\N	104533319500165504550	cad10db4ff944f0c93b8e2ea26cb1ddf	\N
421	Gunavardhan Reddy	CH18B035	\N	\N	\N	7416173741	\N	\N	f	https://www.instamojo.com/@joeydash/db32e351c5e64b79a8ece62e86a30529	\N	117676065019035894011	db32e351c5e64b79a8ece62e86a30529	\N
415	Sumanth R Hegde	EE17B032	IITM	Electrical Engineering	9.74	9740457567	null	null	t	https://www.instamojo.com/@joeydash/469ac6b2e60f47ddaafdbb3ea3161776	MOJO9225G05D19462946	100506628714015360019	469ac6b2e60f47ddaafdbb3ea3161776	\N
405	Nancy Jijhotiya	BS15B021	IIT Madras	Biotechnology	5.97	9940110804	null	naina10196@gmail.com	t	https://www.instamojo.com/@joeydash/768322d4e54e4595b2e230b639adee5e	MOJO9226205A95519964	101052838935126041501	768322d4e54e4595b2e230b639adee5e	\N
422	Sornamugi. K	59390	\N	\N	\N	7397608608	\N	\N	f	https://www.instamojo.com/@joeydash/a7b16f3cea904407ae903cc96aa888d9	\N	113995434481521167625	a7b16f3cea904407ae903cc96aa888d9	\N
423	Dinesh Kumar	ME17B046	\N	\N	\N	9790745254	\N	\N	f	https://www.instamojo.com/@joeydash/88f4eae9181f47dd986fc1a30308f23f	\N	105471448741221920964	88f4eae9181f47dd986fc1a30308f23f	\N
424	Duggani Rohit Kumar	ED16B009	\N	\N	\N	9566146700	\N	\N	f	https://www.instamojo.com/@joeydash/3d5358cb0c804909ac3c0af422d3dabb	\N	112952408322513748665	3d5358cb0c804909ac3c0af422d3dabb	\N
425	Neel Parmar	EP18B023	\N	\N	\N	9420945467	\N	\N	f	https://www.instamojo.com/@joeydash/361bc249f6964943ae69d86adcea4db2	\N	113326721099031890221	361bc249f6964943ae69d86adcea4db2	\N
426	Harisankar	Nagarajan	\N	\N	\N	9600926725	\N	\N	f	https://www.instamojo.com/@joeydash/a0e3d8401de2481babe536e1a8faddc4	\N	103007964566549103489	a0e3d8401de2481babe536e1a8faddc4	\N
427	Thameemmu K Komath	MS18A053	\N	\N	\N	9633960803	\N	\N	f	https://www.instamojo.com/@joeydash/c04c42aac6114e88906b94bd1e6f5b22	\N	103742106521483093681	c04c42aac6114e88906b94bd1e6f5b22	\N
428	Kala B	BT18M015	\N	\N	\N	8754632221	\N	\N	f	https://www.instamojo.com/@joeydash/2fbac4c98b4d4b238f7120e51d254f90	\N	107698263262342388125	2fbac4c98b4d4b238f7120e51d254f90	\N
430	Mukesh V	ME18B156 	\N	\N	\N	8056836775 	\N	\N	f	https://www.instamojo.com/@joeydash/203468774cbc423f90bbf35b1e20d432	\N	109744159274623744110	203468774cbc423f90bbf35b1e20d432	\N
431	Satyajit Sahu	RA1711003020618	\N	\N	\N	7397398911	\N	\N	f	https://www.instamojo.com/@joeydash/58b4c77af1314a9993dc892829864a9b	\N	116478683189057283291	58b4c77af1314a9993dc892829864a9b	\N
432	Sahil Ahmad Ansari	ME17B065	\N	\N	\N	9082390336	\N	\N	f	https://www.instamojo.com/@joeydash/a25fa4bc728a4b65bba059981f8ec174	\N	112577341060416034211	a25fa4bc728a4b65bba059981f8ec174	\N
433	Deepak	ME18B046	\N	\N	\N	9940224448	\N	\N	f	https://www.instamojo.com/@joeydash/4a3407fc9d6943e49f368131c5deebc9	\N	100062293771283967265	4a3407fc9d6943e49f368131c5deebc9	\N
434	T Harshith Reddy	ed18b036	\N	\N	\N	8374672990	\N	\N	f	https://www.instamojo.com/@joeydash/e610628ceb8f43068d369b328981a00d	\N	100935303792996603450	e610628ceb8f43068d369b328981a00d	\N
436	Harshit Jindal	CH17B112	\N	\N	\N	9056270060	\N	\N	f	https://www.instamojo.com/@joeydash/1ceb8ad0fb554a29b956b3246b9bd086	\N	103242500128253530271	1ceb8ad0fb554a29b956b3246b9bd086	\N
437	Mritunjoy Das	AE16B111	\N	\N	\N	9435840783	\N	\N	f	https://www.instamojo.com/@joeydash/989b8eadb5ba4faeaddc1696c3393640	\N	117559934115571313893	989b8eadb5ba4faeaddc1696c3393640	\N
438	Aashish M	112814114003	\N	\N	\N	9092555371	\N	\N	f	https://www.instamojo.com/@joeydash/8f5597d9b367448aa0dd117542586a17	\N	111554553216462510738	8f5597d9b367448aa0dd117542586a17	\N
439	Sindhuja 	AM.EN.U4CSE17503	\N	\N	\N	7594098292	\N	\N	f	https://www.instamojo.com/@joeydash/df6097ca453b49b182ceb14208343612	\N	114460674227562471128	df6097ca453b49b182ceb14208343612	\N
435	Harshal Shedolkar	BT18M014	IITM	Bioprocess Engineering	7.64	+91-8237673891	+91-8830366193	harshal95iitk@gmail.com	t	https://www.instamojo.com/@joeydash/1613d057e5604493a904cb42cefcdfe6	MOJO9224P05N48157568	101798089697138461999	1613d057e5604493a904cb42cefcdfe6	\N
440	Aishwarya Cholin	MS17A003	\N	\N	\N	8762439656	\N	\N	f	https://www.instamojo.com/@joeydash/9047415962a94698ad83da30d2e2ad21	\N	106052007854326033612	9047415962a94698ad83da30d2e2ad21	\N
441	Vignesh Kumar	CH18B118	\N	\N	\N	9445662199	\N	\N	f	https://www.instamojo.com/@joeydash/64d78a974f69497da8f4916b6cf0fc52	\N	114676563882884899432	64d78a974f69497da8f4916b6cf0fc52	\N
442	G sanjay kumar 	181816	\N	\N	\N	9014992243	\N	\N	f	https://www.instamojo.com/@joeydash/0d1aac88f409475ba4805a06c1dd43f3	\N	103413670559273735347	0d1aac88f409475ba4805a06c1dd43f3	\N
444	Patnala susmitha	AE17B012	\N	\N	\N	8985362170	\N	\N	f	https://www.instamojo.com/@joeydash/447a9d5270054838b4f4e61c8b7d9620	\N	113301572741765960778	447a9d5270054838b4f4e61c8b7d9620	\N
445	Falgun phulbandhe 	MM17B017	\N	\N	\N	7030688489	\N	\N	f	https://www.instamojo.com/@joeydash/a1b9b32e10b749a9bff05846c897117a	\N	108442910388268961677	a1b9b32e10b749a9bff05846c897117a	\N
446	Shankeshi Rahul	Me17b067	\N	\N	\N	8639601555	\N	\N	f	https://www.instamojo.com/@joeydash/aca5f563463d41aa8d68560a78a84f20	\N	114334225426749652469	aca5f563463d41aa8d68560a78a84f20	\N
447	K.Nisha	ee18b110	\N	\N	\N	9940052036	\N	\N	f	https://www.instamojo.com/@joeydash/31bf142f19434ab18e7599dfd8dcefcf	\N	112784499723253825036	31bf142f19434ab18e7599dfd8dcefcf	\N
448	Dhananjay Virat	Ae18b003	\N	\N	\N	6205113440	\N	\N	f	https://www.instamojo.com/@joeydash/a5754c77cba846dcb50803e6e1e655b8	\N	117191117879143045227	a5754c77cba846dcb50803e6e1e655b8	\N
449	Mooizz	CS17B034	\N	\N	\N	8555061283	\N	\N	f	https://www.instamojo.com/@joeydash/1e87253071744c26afec55a707768de3	\N	108704163013899237434	1e87253071744c26afec55a707768de3	\N
450	ALFRED K J	ED17B029	\N	\N	\N	9496901561	\N	\N	f	https://www.instamojo.com/@joeydash/e4cb926268f4409aabc19bfcfa11caf6	\N	103072076127132184671	e4cb926268f4409aabc19bfcfa11caf6	\N
451	Abhishek Kumar Raj	Bs18b010	\N	\N	\N	8210434159	\N	\N	f	https://www.instamojo.com/@joeydash/e17da71bcb8e4aaba61a38668ed33270	\N	110451448148325121158	e17da71bcb8e4aaba61a38668ed33270	\N
452	Aditya Gupta	Bs18b001	\N	\N	\N	6388137202	\N	\N	f	https://www.instamojo.com/@joeydash/14191af4dfb84d39bd107447651bcf3b	\N	115433487120178068422	14191af4dfb84d39bd107447651bcf3b	\N
453	Hemanth Kumar N.J 	ae16b032 	\N	\N	\N	9003538220	\N	\N	f	https://www.instamojo.com/@joeydash/0ed51d4021fb49f492d1d22cb9610175	\N	104718836887841018992	0ed51d4021fb49f492d1d22cb9610175	\N
454	Mekala sathvik	AE18B111	\N	\N	\N	6374111250	\N	\N	f	https://www.instamojo.com/@joeydash/5a8ac631fce9421880fc6005c065e7eb	\N	105366476143622097769	5a8ac631fce9421880fc6005c065e7eb	\N
455	Manu Chauhan	Me18b060	\N	\N	\N	9871341963	\N	\N	f	https://www.instamojo.com/@joeydash/5ec27a558b9e4304a09fb5eebd745dcd	\N	109336905989992874826	5ec27a558b9e4304a09fb5eebd745dcd	\N
456	Srinath M	A13559018001	\N	\N	\N	7904950799	\N	\N	f	https://www.instamojo.com/@joeydash/ae7f7b9f66544d8d81aae34f29f2dea0	\N	115511980295745235576	ae7f7b9f66544d8d81aae34f29f2dea0	\N
457	Bipul	Gupta	\N	\N	\N	9989386838	\N	\N	f	https://www.instamojo.com/@joeydash/3e35df99debd465da1285c989a3c4ce0	\N	108604979568748127567	3e35df99debd465da1285c989a3c4ce0	\N
458	Maha Ram Ravindra nath tagore	R161549	\N	\N	\N	6300273025	\N	\N	f	https://www.instamojo.com/@joeydash/50b01b9f36884a1692f361b6c1ce8bfd	\N	101286071491115366059	50b01b9f36884a1692f361b6c1ce8bfd	\N
459	Shubham goyal	1804331047	\N	\N	\N	9680551186	\N	\N	f	https://www.instamojo.com/@joeydash/64fe7ec3a4a6496bb6ff6e29364ef4d5	\N	116564363134490855745	64fe7ec3a4a6496bb6ff6e29364ef4d5	\N
460	DAGADA BHANU VAEDHAN REDDY	ME18B130	\N	\N	\N	8978237951	\N	\N	f	https://www.instamojo.com/@joeydash/11b7291250c5486eaca08c338aa1812b	\N	117908332937907735815	11b7291250c5486eaca08c338aa1812b	\N
461	Nagarjuna Dnv	CE17B008	\N	\N	\N	9603909398	\N	\N	f	https://www.instamojo.com/@joeydash/a410446678c74fa6b6f576bed7c71724	\N	104594709803863772446	a410446678c74fa6b6f576bed7c71724	\N
462	Harshita jain	MM16b105	\N	\N	\N	9940317741	\N	\N	f	https://www.instamojo.com/@joeydash/7198a7028359458e8e1ec62d5146f8bd	\N	115799443155105349456	7198a7028359458e8e1ec62d5146f8bd	\N
463	Ritvik Rishi	CS18B057	\N	\N	\N	7015048732	\N	\N	f	https://www.instamojo.com/@joeydash/ec099a8489b445059fbb60d26136e4b5	\N	105277617859997020173	ec099a8489b445059fbb60d26136e4b5	\N
464	Shankeshi Rahul	Me17b067 	\N	\N	\N	8639601555	\N	\N	f	https://www.instamojo.com/@joeydash/b7cb03e9547848c4b74a6fb685227905	\N	106306673607640422342	b7cb03e9547848c4b74a6fb685227905	\N
414	Jaisingh	ME15B096	IIT Madras	Mechanical Engineering	8.56	8946014839	9092724672	null	t	https://www.instamojo.com/@joeydash/d5c59d38437c4376854462b18a84d465	MOJO9224W05D48158904	105076259957419969308	d5c59d38437c4376854462b18a84d465	\N
465	Akshat Sharda	ED18B041	\N	\N	\N	7424960405	\N	\N	f	https://www.instamojo.com/@joeydash/814c20a0ade04efbb029f45e1787fe13	\N	105728784342910026116	814c20a0ade04efbb029f45e1787fe13	\N
466	Arul	1601070101	\N	\N	\N	6179191919	\N	\N	f	https://www.instamojo.com/@joeydash/6abb940b9bd841a6b26cfb3338ec3d10	\N	106998521804104200708	6abb940b9bd841a6b26cfb3338ec3d10	\N
467	Naveen Gurram	EE17B010	\N	\N	\N	7382991205	\N	\N	f	https://www.instamojo.com/@joeydash/4b423ab2d1564fea98f0e54f7dd96696	\N	106412861907604390589	4b423ab2d1564fea98f0e54f7dd96696	\N
468	Jayesh Kumar	ED18B045	\N	\N	\N	7888420763	\N	\N	f	https://www.instamojo.com/@joeydash/e31186e445fc414f99475c17a09ced93	\N	117437415408129738801	e31186e445fc414f99475c17a09ced93	\N
469	Varun Kumar S	AE18B044	\N	\N	\N	7339503560	\N	\N	f	https://www.instamojo.com/@joeydash/d3a8d4f444e545938abf62e1b148a8b1	\N	101944578273299352029	d3a8d4f444e545938abf62e1b148a8b1	\N
470	Vishav Rakesh Vig 	CS18B062	\N	\N	\N	8360683505	\N	\N	f	https://www.instamojo.com/@joeydash/436e6732c45c420b80cc9a287abce93a	\N	117741399179967439398	436e6732c45c420b80cc9a287abce93a	\N
472	Mahima bothra	16070123055	\N	\N	\N	8770129127	\N	\N	f	https://www.instamojo.com/@joeydash/0ef29aa4d7494ae89671ac932e4db94a	\N	114936367563313121781	0ef29aa4d7494ae89671ac932e4db94a	\N
473	Abhishek reddy	220003080	\N	\N	\N	7013041417	\N	\N	f	https://www.instamojo.com/@joeydash/3850fdab227e4c2986ec9df1dc617e6c	\N	110009852962409606178	3850fdab227e4c2986ec9df1dc617e6c	\N
474	kruthik sai	Ed18b020	\N	\N	\N	9110764324	\N	\N	f	https://www.instamojo.com/@joeydash/a4d84ece5f624a62a6109de6f2b41200	\N	108763835762663930458	a4d84ece5f624a62a6109de6f2b41200	\N
475	Nirmal	ME16B153	\N	\N	\N	8108070221	\N	\N	f	https://www.instamojo.com/@joeydash/e8718a40c376409dae8cb3a8d47583e3	\N	106289280886691331250	e8718a40c376409dae8cb3a8d47583e3	\N
476	Naina Alex 	1MS17IM028 	\N	\N	\N	9650048997 	\N	\N	f	https://www.instamojo.com/@joeydash/180d763f6c8b42e6a69a50186191500e	\N	105096418295296750167	180d763f6c8b42e6a69a50186191500e	\N
477	Yeshwanth	Ee17b025 	\N	\N	\N	8466886201	\N	\N	f	https://www.instamojo.com/@joeydash/f630c73083c140c088fdd37108f9534e	\N	114298599139971688237	f630c73083c140c088fdd37108f9534e	\N
479	Narayana Jeevana Reddy	EE17B022	\N	\N	\N	8309760777	\N	\N	f	https://www.instamojo.com/@joeydash/6eafcfd30acd45e1a33ac5a1938c8789	\N	112700648469597583626	6eafcfd30acd45e1a33ac5a1938c8789	\N
480	Satyarthi Mishra	1560095	\N	\N	\N	+919831531359	\N	\N	f	https://www.instamojo.com/@joeydash/e665110168c340ddb0d65786f0793c47	\N	115248932068817934496	e665110168c340ddb0d65786f0793c47	\N
481	Medha Shukla	16ESKIT057 	\N	\N	\N	7792085227	\N	\N	f	https://www.instamojo.com/@joeydash/2aeeee70856f46b7a0be82c693400115	\N	113736050608649390939	2aeeee70856f46b7a0be82c693400115	\N
482	Jai Nagle	54	\N	\N	\N	8169667299	\N	\N	f	https://www.instamojo.com/@joeydash/84fc315ab6c14e0ea184851fb23c2f37	\N	106938518456953472362	84fc315ab6c14e0ea184851fb23c2f37	\N
483	Yogitha B M	MM18B007	\N	\N	\N	6385113776	\N	\N	f	https://www.instamojo.com/@joeydash/b015f41229a34851ac252ab1880ea907	\N	100588547910962681744	b015f41229a34851ac252ab1880ea907	\N
486	Sandeep George	NA15B023	\N	\N	\N	9447881702	\N	\N	f	https://www.instamojo.com/@joeydash/d472c79dbdf84f89bdd8690eedb1216c	\N	103485490581328043118	d472c79dbdf84f89bdd8690eedb1216c	\N
487	Priyansh Kalawat	CH17B016	\N	\N	\N	8074258222	\N	\N	f	https://www.instamojo.com/@joeydash/4876e76144ff487a9f5045ba40d3da37	\N	106652687558722558532	4876e76144ff487a9f5045ba40d3da37	\N
488	Gaurav Tambade	CH18B048	\N	\N	\N	9823248789	\N	\N	f	https://www.instamojo.com/@joeydash/ddb9b948f7a545dc9ed240d41ed8a988	\N	104667207184638210763	ddb9b948f7a545dc9ed240d41ed8a988	\N
490	Revanth	EP17B008	\N	\N	\N	9080616892	\N	\N	f	https://www.instamojo.com/@joeydash/41ad8b1225024001ab72cba2262d1d8a	\N	111244159787042145700	41ad8b1225024001ab72cba2262d1d8a	\N
489	KALAPATAPU KIRTIKANTH	ce16b003	 IIT MADRAS	civil engineering	6.6	9885136651	9701802261	kirtiaourpally@gmail.com	t	https://www.instamojo.com/@joeydash/8fde013c911648f4a2487e57f107a4b2	MOJO9224O05A48160418	116481728933509462775	8fde013c911648f4a2487e57f107a4b2	\N
491	Khushi Shah	18bbl022	\N	\N	\N	7359000464	\N	\N	f	https://www.instamojo.com/@joeydash/5d0c04e3d50d4819b6748f4df9139673	\N	112767914135815011236	5d0c04e3d50d4819b6748f4df9139673	\N
492	Aniket Bhoyar	BE16B017 	\N	\N	\N	8766406849 	\N	\N	f	https://www.instamojo.com/@joeydash/4867c7a261104cc0a7796df32e2a3e29	\N	102337992027001659603	4867c7a261104cc0a7796df32e2a3e29	\N
493	Yashwant	Ae18b115	\N	\N	\N	8708347213	\N	\N	f	https://www.instamojo.com/@joeydash/c14ed222f4894114951087b2da209aa6	\N	100879140504622169752	c14ed222f4894114951087b2da209aa6	\N
494	Shreyas Sharad Wani	EE18B031	\N	\N	\N	9403298276	\N	\N	f	https://www.instamojo.com/@joeydash/cd9c74eb7f4345b28a3802d5db0e7581	\N	112948527520079330665	cd9c74eb7f4345b28a3802d5db0e7581	\N
495	Vallabi.A	HS18H042	\N	\N	\N	7397263216	\N	\N	f	https://www.instamojo.com/@joeydash/a8b67487a0e244239635a29459c1c9fc	\N	107870943386419228789	a8b67487a0e244239635a29459c1c9fc	\N
485	MUKUND VARMA T	ME18B157	IIT MADRAS	MECHANICAL ENGINEERING	9.11	9952951152	9840533885	mukundvarmat@gmail.com	t	https://www.instamojo.com/@joeydash/337e9a36845943c188fe270558ea31d1	MOJO9224U05N48160869	103766762960350989371	337e9a36845943c188fe270558ea31d1	\N
497	Prajeet Oza	MM17B024	\N	\N	\N	8767888916	\N	\N	f	https://www.instamojo.com/@joeydash/90d7a945810641559fe03b8b3262cc15	\N	103881707281584352472	90d7a945810641559fe03b8b3262cc15	\N
498	Nishant Paparkar	MM17B022	\N	\N	\N	7710832903	\N	\N	f	https://www.instamojo.com/@joeydash/91c446ed62144fa6b4ea0e3737d5e47f	\N	117437619686111413164	91c446ed62144fa6b4ea0e3737d5e47f	\N
499	Balaji Kummari	168W1A1227	\N	\N	\N	8790892038	\N	\N	f	https://www.instamojo.com/@joeydash/e1fa24358edb4d948b94b147df369947	\N	106581333278827306337	e1fa24358edb4d948b94b147df369947	\N
500	Santhosh  L 	1616159	\N	\N	\N	9655884465	\N	\N	f	https://www.instamojo.com/@joeydash/412e3108b9954e27ad57edc307095013	\N	100911127677636231036	412e3108b9954e27ad57edc307095013	\N
501	T Arunkumar	108116094	\N	\N	\N	9894953481	\N	\N	f	https://www.instamojo.com/@joeydash/b4021e15fa7444b999e85857001155f7	\N	101142872646572669147	b4021e15fa7444b999e85857001155f7	\N
502	KALEPALLI YASWANTH	178W5A1201	\N	\N	\N	9494761110	\N	\N	f	https://www.instamojo.com/@joeydash/25027ca3085140a5bda59d87a303ca17	\N	109344380723582753140	25027ca3085140a5bda59d87a303ca17	\N
503	HARSHIT SHRIVASTAVA	EE18B037	\N	\N	\N	6265584205	\N	\N	f	https://www.instamojo.com/@joeydash/7c60c511f8b34d51b2d5567c96cfc4c5	\N	106673190696374476111	7c60c511f8b34d51b2d5567c96cfc4c5	\N
504	Gurajala Bhavitha Chowdary 	EE17B126	\N	\N	\N	9100686649	\N	\N	f	https://www.instamojo.com/@joeydash/1efcfbd7248146d58f6178d41e83cdbc	\N	109365219417101681548	1efcfbd7248146d58f6178d41e83cdbc	\N
509	RANJEEV KUMAR 	NA15B044 	\N	\N	\N	8210821147	\N	\N	f	https://www.instamojo.com/@joeydash/9e4e725f119b461f97234bf6e384b3e6	\N	114065040695019741051	9e4e725f119b461f97234bf6e384b3e6	\N
510	Dany Chrysolite Singala	16UEC077	\N	\N	\N	7661005660	\N	\N	f	https://www.instamojo.com/@joeydash/151616ad11a146f0873f6f4eec4bd928	\N	107063297132920862498	151616ad11a146f0873f6f4eec4bd928	\N
505	Sarath Nair 	CH18B066	\N	\N	\N	7350684431	\N	\N	f	https://www.instamojo.com/@joeydash/2cc8d50dfe8046409777aa2e4660af30	\N	117809046150519937646	2cc8d50dfe8046409777aa2e4660af30	\N
506	Balasubramaniam M C	Ee18b155	\N	\N	\N	8197256507	\N	\N	f	https://www.instamojo.com/@joeydash/559a66d1cdef41e68589f317c3970ba9	\N	110852755961220516170	559a66d1cdef41e68589f317c3970ba9	\N
508	Debajyoti Biswas	EE14D302	\N	\N	\N	9176338192	\N	\N	f	https://www.instamojo.com/@joeydash/51f0b8605541421e893d789df8ba47f2	\N	110925589402818603855	51f0b8605541421e893d789df8ba47f2	\N
511	Vishal	Ed16b059	\N	\N	\N	9940318997	\N	\N	f	https://www.instamojo.com/@joeydash/0ebb0fbccfab41fb95053fe0f4d44bdc	\N	114001870545129070750	0ebb0fbccfab41fb95053fe0f4d44bdc	\N
512	Girish Mahawar	ME18B107	\N	\N	\N	9928032779	\N	\N	f	https://www.instamojo.com/@joeydash/80bba5696d884c1388459bce77de7e02	\N	111057843707706628162	80bba5696d884c1388459bce77de7e02	\N
513	Kishore	EE16B056	\N	\N	\N	9655423181	\N	\N	f	https://www.instamojo.com/@joeydash/09e4c9530e29438f96373965460fc9ec	\N	115291249054184396904	09e4c9530e29438f96373965460fc9ec	\N
515	NOOKALA HARSHA VARDHAN	CE15B084	\N	\N	\N	9940110633	\N	\N	f	https://www.instamojo.com/@joeydash/ea8045ebefe04c7c98410e1b0470e276	\N	111147619192315513583	ea8045ebefe04c7c98410e1b0470e276	\N
516	aditi	na16b101	\N	\N	\N	8830559371	\N	\N	f	https://www.instamojo.com/@joeydash/085ebd9a19e44aa2beb659fb29ff0a5c	\N	113868334961980318603	085ebd9a19e44aa2beb659fb29ff0a5c	\N
517	Akash Surya K 	BS18B014 	\N	\N	\N	8838341074 	\N	\N	f	https://www.instamojo.com/@joeydash/087c7952150046d19163f5b5683d3561	\N	109889406964683955247	087c7952150046d19163f5b5683d3561	\N
518	Akash Kumar	HS16H006	\N	\N	\N	8428317499	\N	\N	f	https://www.instamojo.com/@joeydash/d560ffa2b5464608a32be3ff3cac2741	\N	103255886189575172045	d560ffa2b5464608a32be3ff3cac2741	\N
519	MATHURTHI AMRUTHA VARSHINI	EE17B019	\N	\N	\N	7981276333	\N	\N	f	https://www.instamojo.com/@joeydash/7232b2c862df446aab8a95d185140579	\N	113270308068308693920	7232b2c862df446aab8a95d185140579	\N
520	Krithika	170401050	\N	\N	\N	9941227909	\N	\N	f	https://www.instamojo.com/@joeydash/0e550098c54a4f6f8fe31f195fda1aa9	\N	114460255359960686690	0e550098c54a4f6f8fe31f195fda1aa9	\N
521	Tanmayi	13	\N	\N	\N	7594098297	\N	\N	f	https://www.instamojo.com/@joeydash/caac4005d342404aa04c209b8a201e61	\N	108254744377935010731	caac4005d342404aa04c209b8a201e61	\N
522	Kamesh K	MM16B107	\N	\N	\N	7395948407	\N	\N	f	https://www.instamojo.com/@joeydash/1ff34a16d24d415481a5db1e8ae6f551	\N	102016362692018663817	1ff34a16d24d415481a5db1e8ae6f551	\N
523	Chandra Desai	ae18b022	\N	\N	\N	9409659393	\N	\N	f	https://www.instamojo.com/@joeydash/95a6d251a7a04b93be01e472b65fcdfb	\N	106522512292842581656	95a6d251a7a04b93be01e472b65fcdfb	\N
524	Sreejanya R	NA17B033	\N	\N	\N	9495870301	\N	\N	f	https://www.instamojo.com/@joeydash/5eb5a090b49447ddb3a177cb7f400955	\N	105869193300848969627	5eb5a090b49447ddb3a177cb7f400955	\N
525	Prasanthi mounika	Ce16b060	\N	\N	\N	9500195524	\N	\N	f	https://www.instamojo.com/@joeydash/8ccf33a5a6e7405f924fe6b5166c1738	\N	107705980388869672861	8ccf33a5a6e7405f924fe6b5166c1738	\N
526	MADDINENI BHARGAVA	Ee18b112	\N	\N	\N	6302207979	\N	\N	f	https://www.instamojo.com/@joeydash/aadee44ba2de4049acd55c6020ff9b64	\N	115720717467371239169	aadee44ba2de4049acd55c6020ff9b64	\N
527	Praveen Daniel 	7	\N	\N	\N	9791423038	\N	\N	f	https://www.instamojo.com/@joeydash/8568b7e11ba6471082290278f0ddf6ca	\N	101723642987973735918	8568b7e11ba6471082290278f0ddf6ca	\N
530	Yukti	CE16B136	\N	\N	\N	7087146594	\N	\N	f	https://www.instamojo.com/@joeydash/632f66188aff4985ad131436ff21559d	\N	101346850687390430152	632f66188aff4985ad131436ff21559d	\N
531	Hari Ranjan Meena	ME18B108	\N	\N	\N	9588931185	\N	\N	f	https://www.instamojo.com/@joeydash/e6dee445bd3442d090b35be993178264	\N	100435892597443729390	e6dee445bd3442d090b35be993178264	\N
533	Ikben Ghosh	16SET518	\N	\N	\N	7980308603	\N	\N	f	https://www.instamojo.com/@joeydash/58b8c07c1717458a8dc36162ce7265f8	\N	102358353258651799998	58b8c07c1717458a8dc36162ce7265f8	\N
534	Avichal Agrawal	mm17b014	\N	\N	\N	9082407117	\N	\N	f	https://www.instamojo.com/@joeydash/6dbbf0ad439244ee81046d6d14b44abe	\N	111249737724193533146	6dbbf0ad439244ee81046d6d14b44abe	\N
302	Aanand Krishnan	BE17B001	IITM	Bioengineering	8.69	8754582733	null	null	t	https://www.instamojo.com/@joeydash/e899243f4388423fbaee9e89ca146b11	MOJO9224305D48162751	103091607039681871319	e899243f4388423fbaee9e89ca146b11	\N
535	Deepak kumar	1sb16cs029	\N	\N	\N	9934223805	\N	\N	f	https://www.instamojo.com/@joeydash/f14021cb828246acb9b69e3734133e64	\N	113469919102071155341	f14021cb828246acb9b69e3734133e64	\N
536	Poluri chaitanya	16SET508	\N	\N	\N	6302962721	\N	\N	f	https://www.instamojo.com/@joeydash/10c0f2900f3541b3828849d9f82b4217	\N	107080380616313180851	10c0f2900f3541b3828849d9f82b4217	\N
539	Marlapalli Sai Jaswanth	Me17b025	\N	\N	\N	8639972888	\N	\N	f	https://www.instamojo.com/@joeydash/f046cbe4c0ab469cbc2ed216f73b1807	\N	105792740625464197848	f046cbe4c0ab469cbc2ed216f73b1807	\N
540	Nitesh Kumar	Me16b063	\N	\N	\N	9940314006	\N	\N	f	https://www.instamojo.com/@joeydash/7fc9f2c160ef44a0ac9ad9e04f481dbc	\N	111592449927501447231	7fc9f2c160ef44a0ac9ad9e04f481dbc	\N
541	Saurabh Jain	ME16B071	\N	\N	\N	9940312393	\N	\N	f	https://www.instamojo.com/@joeydash/7c887e7bde44480399d699534678a07e	\N	114818886750636854304	7c887e7bde44480399d699534678a07e	\N
542	Sushanth	Ch17b041	\N	\N	\N	7981255750	\N	\N	f	https://www.instamojo.com/@joeydash/2836c9dfc3fb477fba93d423fba3f68f	\N	109875688119492220593	2836c9dfc3fb477fba93d423fba3f68f	\N
543	Shikha Raj	na16b013	\N	\N	\N	9940337601	\N	\N	f	https://www.instamojo.com/@joeydash/fc31e664374e4de29227701a2d0e5e07	\N	116530412916957561133	fc31e664374e4de29227701a2d0e5e07	\N
544	Sanket Waghmare	MM16B103	\N	\N	\N	8390342784	\N	\N	f	https://www.instamojo.com/@joeydash/a358789b32ab48c585c658e261aeafd5	\N	113696412226304739237	a358789b32ab48c585c658e261aeafd5	\N
545	Santosh Kumar mantripragada 	Ce17b128 	\N	\N	\N	7780717597 	\N	\N	f	https://www.instamojo.com/@joeydash/4b9c0a403dc64241bee650709255f0f5	\N	107482180927586997711	4b9c0a403dc64241bee650709255f0f5	\N
546	Subeer Nayak	BE18B030	\N	\N	\N	7240544264	\N	\N	f	https://www.instamojo.com/@joeydash/0c072b940d244af399cef72c81a72531	\N	110896153092092864357	0c072b940d244af399cef72c81a72531	\N
547	Prajjwal Kumar	NA16B115	\N	\N	\N	8789145542	\N	\N	f	https://www.instamojo.com/@joeydash/5698f1eb24c348e0a12e8326f0d03405	\N	114181895600121266149	5698f1eb24c348e0a12e8326f0d03405	\N
548	SRIRAMRAGUNATHAN	CH17B072	\N	\N	\N	7738346746	\N	\N	f	https://www.instamojo.com/@joeydash/7a54c58a731042cdb4a7a72a9fee6b52	\N	112876412127381726329	7a54c58a731042cdb4a7a72a9fee6b52	\N
549	Sona Sheril Antony 	CH17B071	\N	\N	\N	9600148759	\N	\N	f	https://www.instamojo.com/@joeydash/49f6fc33a33942be945743f0ddd14e3b	\N	117867040483756946449	49f6fc33a33942be945743f0ddd14e3b	\N
550	Nitish kumar	0039	\N	\N	\N	8210306295	\N	\N	f	https://www.instamojo.com/@joeydash/b47bc2f5e44c4fb1b571509e09b27ebb	\N	117810709345028814872	b47bc2f5e44c4fb1b571509e09b27ebb	\N
551	GUDE SAI GANESH	ME17B012	\N	\N	\N	7989613477	\N	\N	f	https://www.instamojo.com/@joeydash/67467f22bd384a9e8e21466cdbd5b954	\N	113538741896053160350	67467f22bd384a9e8e21466cdbd5b954	\N
552	B.SHASHI KUMAR	Me16b007	\N	\N	\N	8639617904	\N	\N	f	https://www.instamojo.com/@joeydash/ddb9722b61294b878e3e07bc8c11f3b4	\N	109749255160356686705	ddb9722b61294b878e3e07bc8c11f3b4	\N
553	Sri Harsha	1GA17CS154	\N	\N	\N	7349698441	\N	\N	f	https://www.instamojo.com/@joeydash/d9c94a9fc9204b1baeb53d73c155792a	\N	103796546597774896206	d9c94a9fc9204b1baeb53d73c155792a	\N
554	Rajat Kumar	17	\N	\N	\N	7903925396	\N	\N	f	https://www.instamojo.com/@joeydash/607b8c5470564fad96276e395f75795e	\N	107461628160278570223	607b8c5470564fad96276e395f75795e	\N
555	RAG SANIL	ae16b108	\N	\N	\N	8281810740	\N	\N	f	https://www.instamojo.com/@joeydash/9015eecb0f1b42d89bf119e471130439	\N	109854238168986987809	9015eecb0f1b42d89bf119e471130439	\N
556	Geethakrishna	16ak1a0518	\N	\N	\N	9666308802	\N	\N	f	https://www.instamojo.com/@joeydash/b04faa2470e0436e8fe25e706cf08d69	\N	115877582789598330117	b04faa2470e0436e8fe25e706cf08d69	\N
557	RAG SANIL	ae16b108	\N	\N	\N	8281810740	\N	\N	f	https://www.instamojo.com/@joeydash/60e06b6693aa4a669b96124ef9ac19c1	\N	105691299700355446674	60e06b6693aa4a669b96124ef9ac19c1	\N
558	R KAVIN KAILASH	AE16B1113	\N	\N	\N	9751227444	\N	\N	f	https://www.instamojo.com/@joeydash/3755d2538aec4f6ab860e6cb22f8fcb9	\N	115825834927273789916	3755d2538aec4f6ab860e6cb22f8fcb9	\N
559	Surender	mm17b002	\N	\N	\N	8668103994	\N	\N	f	https://www.instamojo.com/@joeydash/4c199f5fd09f4636a56980f6a0ecc9a2	\N	112136155569381255577	4c199f5fd09f4636a56980f6a0ecc9a2	\N
560	Sameer N. Soni	MM18B031	\N	\N	\N	7987114992	\N	\N	f	https://www.instamojo.com/@joeydash/0f75b880b1b54ba1a3af2718e2a627d6	\N	107915352569700271839	0f75b880b1b54ba1a3af2718e2a627d6	\N
561	Rohith M Athreya 	ME17B033	\N	\N	\N	9113095354	\N	\N	f	https://www.instamojo.com/@joeydash/3ad5413ece4645b097d27d288fb1b644	\N	112066593181711337536	3ad5413ece4645b097d27d288fb1b644	\N
562	MSK Karthik	AE15B022	IITM	Aerospace	9	9940123449	null	null	t	https://www.instamojo.com/@joeydash/79ae2389a8044655b185870720d05cfc	MOJO9225U05D19454047	118225482088722822025	79ae2389a8044655b185870720d05cfc	\N
564	K R Prasad 	AE17B015	\N	\N	\N	9789826914	\N	\N	f	https://www.instamojo.com/@joeydash/609c4807da6641f6ad0865c090494cef	\N	105682417554191071301	609c4807da6641f6ad0865c090494cef	\N
565	VIVEK OOMMEN	ME16B176	\N	\N	\N	8547366520	\N	\N	f	https://www.instamojo.com/@joeydash/c2e15ac3319b4d0bbf6d98f2ffb1c78a	\N	116009261508057191570	c2e15ac3319b4d0bbf6d98f2ffb1c78a	\N
566	Jeswant Krishna K	AE17B030	\N	\N	\N	9566089903	\N	\N	f	https://www.instamojo.com/@joeydash/48c40af72fbc4d71b159bfe29cf9af1d	\N	101204317216387759803	48c40af72fbc4d71b159bfe29cf9af1d	\N
567	Adithi K	bt18m001	\N	\N	\N	9884460586	\N	\N	f	https://www.instamojo.com/@joeydash/3739859646fb45a0a8c23f70d8de1366	\N	107625376588793983867	3739859646fb45a0a8c23f70d8de1366	\N
568	Tavva Alekhya	CH18B116	\N	\N	\N	6303596568	\N	\N	f	https://www.instamojo.com/@joeydash/f1a8b41535264d6a8ffa78042c2fd614	\N	113713806575169641545	f1a8b41535264d6a8ffa78042c2fd614	\N
569	Vamsi Krishna Mula 	CE14B104	\N	\N	\N	9566267928	\N	\N	f	https://www.instamojo.com/@joeydash/c1ab012d6ce545f7acea4e3c87a995cc	\N	110557781693948154226	c1ab012d6ce545f7acea4e3c87a995cc	\N
570	Sathya Narayanan	me16b126	\N	\N	\N	9487058596	\N	\N	f	https://www.instamojo.com/@joeydash/cebb3f64f057403cbe1ae226ccfbfd01	\N	114645348011786260170	cebb3f64f057403cbe1ae226ccfbfd01	\N
571	Sumanth devarasetty	ee18b046	\N	\N	\N	6369121663	\N	\N	f	https://www.instamojo.com/@joeydash/6b3e5eb17c61450bab668f0608eb86cb	\N	107836389792965014526	6b3e5eb17c61450bab668f0608eb86cb	\N
573	Y Siva sai krishna	Ae16b115	\N	\N	\N	9652148081	\N	\N	f	https://www.instamojo.com/@joeydash/1abc033040c442e8b7c0a66291d33660	\N	117116469784985259310	1abc033040c442e8b7c0a66291d33660	\N
574	Kadhir	Me18b147	\N	\N	\N	7338825370	\N	\N	f	https://www.instamojo.com/@joeydash/308833bdffa44c8a844669b7d7b7a356	\N	106557254269091722228	308833bdffa44c8a844669b7d7b7a356	\N
575	Sai Mounika B	BE15B008	\N	\N	\N	9994967219	\N	\N	f	https://www.instamojo.com/@joeydash/bc3df130e1bf4d1ca79f21b7e8c50fdd	\N	109487415983875666548	bc3df130e1bf4d1ca79f21b7e8c50fdd	\N
576	K Vikas Mahendar	ME18B146	\N	\N	\N	7708146322	\N	\N	f	https://www.instamojo.com/@joeydash/61707b9e124340b69c2ae8b5d5be8e90	\N	111325908744268034050	61707b9e124340b69c2ae8b5d5be8e90	\N
577	Akhilesh Bais	ME17B133	\N	\N	\N	9840878425	\N	\N	f	https://www.instamojo.com/@joeydash/a72362b1d8eb428095adbe9ebfb216da	\N	117267055404556932067	a72362b1d8eb428095adbe9ebfb216da	\N
578	Sagnik Datta	CE18B122	\N	\N	\N	6369588692	\N	\N	f	https://www.instamojo.com/@joeydash/508a391efcfc44f9b369f3684aa45f97	\N	117953295521680922925	508a391efcfc44f9b369f3684aa45f97	\N
580	Dharmana Chandramouli	NA16B005	\N	\N	\N	8428316882	\N	\N	f	https://www.instamojo.com/@joeydash/359b7c8601124b6294a5821b23e74b77	\N	104974498060929724022	359b7c8601124b6294a5821b23e74b77	\N
581	Bharath S	ME15B015	\N	\N	\N	8870098181	\N	\N	f	https://www.instamojo.com/@joeydash/bffe400cfec9437cad57a5226d7b8754	\N	112641700725756825255	bffe400cfec9437cad57a5226d7b8754	\N
582	M.Yashwant	EE17B107	\N	\N	\N	8985649832	\N	\N	f	https://www.instamojo.com/@joeydash/2effe17da99c476987adff22d0b699da	\N	108292690118262690170	2effe17da99c476987adff22d0b699da	\N
583	Pinak Das	CS-46/16	\N	\N	\N	+919101124302	\N	\N	f	https://www.instamojo.com/@joeydash/eb849801d73046dd877207ce2d0b7883	\N	104634840831330665715	eb849801d73046dd877207ce2d0b7883	\N
579	Shaik Riyaz	RA1611003010231	S.R.M institute of science and technology	Computer science	6.67	9952919265	8328554415	shaikriyaz_shaik@srmuniv.edu.in	t	https://www.instamojo.com/@joeydash/598420e25da44ef4a52a2bb61fc96ce8	MOJO9225N05D19456246	100759552192333828461	598420e25da44ef4a52a2bb61fc96ce8	\N
584	Gorantala Rohith Kumar	ee18b008	\N	\N	\N	9133454606	\N	\N	f	https://www.instamojo.com/@joeydash/6e926d7700c64553af75f72e55156808	\N	102189547402903864598	6e926d7700c64553af75f72e55156808	\N
585	Sri Anirudh Reddy Bolusani	Ee17b043	\N	\N	\N	9477333999	\N	\N	f	https://www.instamojo.com/@joeydash/de14b433d39b4055937945fc882de2aa	\N	113673177751333352404	de14b433d39b4055937945fc882de2aa	\N
586	Dipam Shah	CH15B078	\N	\N	\N	9924472969	\N	\N	f	https://www.instamojo.com/@joeydash/2665f7fdcb0846f6880c8c9d920aea4b	\N	110884617323037851906	2665f7fdcb0846f6880c8c9d920aea4b	\N
587	Vishal kumar	1	\N	\N	\N	7762856909	\N	\N	f	https://www.instamojo.com/@joeydash/252fabe7f3e9433c9862802027132415	\N	116011204695993253377	252fabe7f3e9433c9862802027132415	\N
590	Tushar Anand	1604051	\N	\N	\N	8299850006	\N	\N	f	https://www.instamojo.com/@joeydash/e4596d266b0d4ce9ba018a39316caee2	\N	101438283653535686514	e4596d266b0d4ce9ba018a39316caee2	\N
591	Mridul Rathore	ME17B155	\N	\N	\N	9785225807	\N	\N	f	https://www.instamojo.com/@joeydash/8ee703ffc21542cca5793a0594d26d37	\N	114164113258062776352	8ee703ffc21542cca5793a0594d26d37	\N
592	Mohit Kumar	MS17S013	\N	\N	\N	9582867453	\N	\N	f	https://www.instamojo.com/@joeydash/7362cbe892ed4f83981517a2eecfba36	\N	104682014066766388268	7362cbe892ed4f83981517a2eecfba36	\N
563	L.P.Manikandan	ME15B115	Indian Institute of Technology Madras	Mechanical/ IDDD Robotics	8.28	7708390718	9663573709	manish.lapasi@gmail.com	t	https://www.instamojo.com/@joeydash/d16e6a0622fc4df388a31c6028a837b8	MOJO9225C05N19457946	109352364693906201046	d16e6a0622fc4df388a31c6028a837b8	\N
593	Narendhiran	ch18b015	\N	\N	\N	9498810912	\N	\N	f	https://www.instamojo.com/@joeydash/bfe4a358e33f48cdadec0f7184266814	\N	112959020768381661176	bfe4a358e33f48cdadec0f7184266814	\N
595	Syed Waseem Hussain	U101115FCS162	\N	\N	\N	8696853263	\N	\N	f	https://www.instamojo.com/@joeydash/9a1eacadf2ae49eab0a1df415203f2c7	\N	104914948058055303827	9a1eacadf2ae49eab0a1df415203f2c7	\N
596	Bambom Perme	ce16b024	\N	\N	\N	9884255236	\N	\N	f	https://www.instamojo.com/@joeydash/74b1016d621344bbbb3a9cb4248eb31a	\N	107532999868296523502	74b1016d621344bbbb3a9cb4248eb31a	\N
597	Vivek Sharma	ME18S038	\N	\N	\N	8233223197	\N	\N	f	https://www.instamojo.com/@joeydash/7928d8d1bd394c54a1b335c029f37953	\N	100970809889276910970	7928d8d1bd394c54a1b335c029f37953	\N
598	Threlok	170102072	\N	\N	\N	9676096941	\N	\N	f	https://www.instamojo.com/@joeydash/22111eee494c41a3aacc1bfb16fd9127	\N	115919916983778122153	22111eee494c41a3aacc1bfb16fd9127	\N
599	D Tony Fredrick	EE17B154	\N	\N	\N	9481154975	\N	\N	f	https://www.instamojo.com/@joeydash/c0bc0d88d33c46098a8f4a4eb8a8b8b6	\N	105194294420005024985	c0bc0d88d33c46098a8f4a4eb8a8b8b6	\N
600	Neeharika C V	EE16B156	\N	\N	\N	9940307213	\N	\N	f	https://www.instamojo.com/@joeydash/053ad919d0564b0faa5f0dbec3f3ec94	\N	109853930299444486331	053ad919d0564b0faa5f0dbec3f3ec94	\N
601	Joaquim Fernandes	30	\N	\N	\N	9637713080	\N	\N	f	https://www.instamojo.com/@joeydash/ea44d97c6d664b95b275a28f0acf00d0	\N	109337807907743319459	ea44d97c6d664b95b275a28f0acf00d0	\N
602	P Sai Venkat Kushal	ee17b141	\N	\N	\N	9398244646	\N	\N	f	https://www.instamojo.com/@joeydash/74a92cd296354274b3252dbbc07ab3a5	\N	109709409847775998792	74a92cd296354274b3252dbbc07ab3a5	\N
588	Razeem Ahmad	ED17B022	IITM	Engineering Design	6.71	9447635699	\N	\N	t	https://www.instamojo.com/@joeydash/9023068a63844ceca2d704e587705d73	MOJO9225K05D19457442\t	101207355282354584537	9023068a63844ceca2d704e587705d73	\N
603	Nishant	Ms18s010	\N	\N	\N	8989954909	\N	\N	f	https://www.instamojo.com/@joeydash/cb5354ba94f84c5f8a547cef7a38d825	\N	114422993971584074304	cb5354ba94f84c5f8a547cef7a38d825	\N
604	perumalla ritwik	me18m097@smail.iitm.ac.in	\N	\N	\N	9704648302	\N	\N	f	https://www.instamojo.com/@joeydash/089b558015a74eba9c1c695f570fbb42	\N	107374093030287723532	089b558015a74eba9c1c695f570fbb42	\N
605	Nikhil Mattapally	EE17B138	\N	\N	\N	9949271131	\N	\N	f	https://www.instamojo.com/@joeydash/2f8de4df39c84533932c9948efba6de3	\N	116709489304696093648	2f8de4df39c84533932c9948efba6de3	\N
606	Suraj Dange	AE14B032	\N	\N	\N	6379357455	\N	\N	f	https://www.instamojo.com/@joeydash/a5acdfc1f0ad4f4d803a9a62db7bc7d6	\N	117722541088958689814	a5acdfc1f0ad4f4d803a9a62db7bc7d6	\N
607	Advait Walsangikar	AE17B101	\N	\N	\N	9079686312	\N	\N	f	https://www.instamojo.com/@joeydash/6572d4764b0e4a3b9a5c56b6443b84cd	\N	109658648941971927034	6572d4764b0e4a3b9a5c56b6443b84cd	\N
608	Rakesh R	AM14D006	\N	\N	\N	7299559971	\N	\N	f	https://www.instamojo.com/@joeydash/ebc0041aa21c4a0fb2547bd73f300f17	\N	113169541347174262384	ebc0041aa21c4a0fb2547bd73f300f17	\N
609	Ashutosh Sharma 	1601010041	\N	\N	\N	8932064575 	\N	\N	f	https://www.instamojo.com/@joeydash/8908fcb19ecd482098767f70a0c919ca	\N	101106264716659583583	8908fcb19ecd482098767f70a0c919ca	\N
610	Akanksha	EE15B071	\N	\N	\N	9940116030	\N	\N	f	https://www.instamojo.com/@joeydash/12d907ff97c74cb18e9efefe2ff0e2bc	\N	105157880401213216108	12d907ff97c74cb18e9efefe2ff0e2bc	\N
611	Kusumitha Kampara	CH17B054	\N	\N	\N	9490935495	\N	\N	f	https://www.instamojo.com/@joeydash/6cbe46e3de2e4efa8e653e25b8d0be03	\N	105128571150899208559	6cbe46e3de2e4efa8e653e25b8d0be03	\N
612	Kaja Sai Manikanta	me17s074	\N	\N	\N	9985271663	\N	\N	f	https://www.instamojo.com/@joeydash/aa613a054d2d4d9d8a2503dae38aac96	\N	103582724679949481090	aa613a054d2d4d9d8a2503dae38aac96	\N
97	Davis Andherson F	ED17B037	IITM	Engineering Design	8	9941389689	9444460282	davis.andherson@gmail.com	t	https://www.instamojo.com/@joeydash/cff9f16465ab4c00b88e25d3e76da558	MOJO9225C05D19468527	107827922432577522549	cff9f16465ab4c00b88e25d3e76da558	\N
613	harshit singh	ae14b042	\N	\N	\N	9790463246	\N	\N	f	https://www.instamojo.com/@joeydash/5b4379a8470d49e1b7c19cf2adb2bca1	\N	105135735319080728525	5b4379a8470d49e1b7c19cf2adb2bca1	\N
572	Manoj S	ME18B152	IIT Madras	Mechanical Engineering	8.19	9677222498	9790970419	manoj.s.2908@gmail.com	t	https://www.instamojo.com/@joeydash/ed40270a4f3b4edf97427234f049b1d1	MOJO9225Z05A19469369	117553069435742054785	ed40270a4f3b4edf97427234f049b1d1	\N
614	G Pradeep	EE16B050	\N	\N	\N	8939532364	\N	\N	f	https://www.instamojo.com/@joeydash/082732d73ddb4ec3a719613617d180a1	\N	100265483523057320076	082732d73ddb4ec3a719613617d180a1	\N
615	Prashis	Me18B024 	\N	\N	\N	9370074490	\N	\N	f	https://www.instamojo.com/@joeydash/89ee3d4a474143f999e49a5dd25cb354	\N	104093527338529559700	89ee3d4a474143f999e49a5dd25cb354	\N
616	Dhruv Shah	AE17B107	\N	\N	\N	8460558518	\N	\N	f	https://www.instamojo.com/@joeydash/05b68da0dc704670a4b00b25f57ac8c5	\N	106650680769126177630	05b68da0dc704670a4b00b25f57ac8c5	\N
617	Keshav Saini	ME17B148	\N	\N	\N	9840898599	\N	\N	f	https://www.instamojo.com/@joeydash/c7a991a1a0724aa2b85066aa110033b4	\N	116969460420605090641	c7a991a1a0724aa2b85066aa110033b4	\N
618	Abhijeet Ingle	AE17B016	\N	\N	\N	9840893243	\N	\N	f	https://www.instamojo.com/@joeydash/f3158a442d6741f8a46c1a28a2a9b2ea	\N	100427472165562945104	f3158a442d6741f8a46c1a28a2a9b2ea	\N
619	NANDHA KUMAR S 	ME18S050	\N	\N	\N	9941445998	\N	\N	f	https://www.instamojo.com/@joeydash/307b7861db284afe8f22053d7a9de7ff	\N	107354349562927299129	307b7861db284afe8f22053d7a9de7ff	\N
620	Manthan Solanki	21	\N	\N	\N	9725586747	\N	\N	f	https://www.instamojo.com/@joeydash/dc7462d724b94db98e8e0e6b9c7695ec	\N	112618428019925030389	dc7462d724b94db98e8e0e6b9c7695ec	\N
622	Vaibhavkumar Patel	ME17B176	\N	\N	\N	9824695018	\N	\N	f	https://www.instamojo.com/@joeydash/cd182fa5f14c4d06b924db82ce47801a	\N	115363131130228230104	cd182fa5f14c4d06b924db82ce47801a	\N
623	Abhishek kumar	ee18m076	\N	\N	\N	8789694469	\N	\N	f	https://www.instamojo.com/@joeydash/74eb0a47c88a42a2bd1a896261f4f76b	\N	106968421421627012684	74eb0a47c88a42a2bd1a896261f4f76b	\N
625	Aaditya Sharma	164001	\N	\N	\N	9917181369	\N	\N	f	https://www.instamojo.com/@joeydash/9fbce93aedb24c24b33e8feda179aaa5	\N	106260862891379060047	9fbce93aedb24c24b33e8feda179aaa5	\N
624	AMAN KUMAR GAUTAM	EE16B103	IITM	Electrical engineering	6.77	7318559404	9695027431	ee16b103@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/37b742119c2f439780f831b20851fcbe	MOJO9225105N19476059	111418050118613804064	37b742119c2f439780f831b20851fcbe	\N
626	Arihant Samar	CS18B052	\N	\N	\N	9742364790	\N	\N	f	https://www.instamojo.com/@joeydash/0264d28a8d0a4bf899323baa8fd25e52	\N	114372531126316025056	0264d28a8d0a4bf899323baa8fd25e52	\N
627	MD Tufail Ahmad 	18LEIT05	\N	\N	\N	7549695585	\N	\N	f	https://www.instamojo.com/@joeydash/801c1531674f4436a8299a31f71fb6a2	\N	104736555837409789469	801c1531674f4436a8299a31f71fb6a2	\N
628	Abhinav Anand	2015-IPG-003	\N	\N	\N	8461077468	\N	\N	f	https://www.instamojo.com/@joeydash/6d0d078f8f014d71b590fde8712d0741	\N	112049149719514009007	6d0d078f8f014d71b590fde8712d0741	\N
629	taneshq verma	me17b168	\N	\N	\N	8851182337	\N	\N	f	https://www.instamojo.com/@joeydash/3f8e3528372244f8913d245c22d5398d	\N	113492022217102262285	3f8e3528372244f8913d245c22d5398d	\N
514	shashikant singh	EE18M063	IITM	ELECTRICAL ENGINEERING  - CONTROL AND INSTRUMENTATION	8.20	8610651104	null	skantsingh943@gmail.com	t	https://www.instamojo.com/@joeydash/87b2b96f66bc407da298804d44121d3c	MOJO9225D05D19477029	110061169103924354522	87b2b96f66bc407da298804d44121d3c	\N
630	jen	q	\N	\N	\N	7738383883	\N	\N	f	https://www.instamojo.com/@joeydash/9deb52501a934d22acdfb1bbbbe3b89f	\N	107191617387841036716	9deb52501a934d22acdfb1bbbbe3b89f	\N
631	Anup Kakasaheb Gurav	MM17B011	\N	\N	\N	7090901311	\N	\N	f	https://www.instamojo.com/@joeydash/b57eba3cd2b7489f9399465dd8a72176	\N	104811365561245605458	b57eba3cd2b7489f9399465dd8a72176	\N
632	Aman	16ESBCS002	\N	\N	\N	+917610019033	\N	\N	f	https://www.instamojo.com/@joeydash/dcb2533a163f47d5aace5473655d4894	\N	109149479407133340377	dcb2533a163f47d5aace5473655d4894	\N
633	H Madhan Kumar	EP18B006	\N	\N	\N	6303564574	\N	\N	f	https://www.instamojo.com/@joeydash/492a3cf551bf4a43b8b01d4d4af7b2dc	\N	106697543274326521115	492a3cf551bf4a43b8b01d4d4af7b2dc	\N
635	P. Srujana	CS18B035	\N	\N	\N	9381296917	\N	\N	f	https://www.instamojo.com/@joeydash/333e0f50990c4f6fa32f4f18c809fe70	\N	113833084535795360196	333e0f50990c4f6fa32f4f18c809fe70	\N
636	Hitesh Pawar	ME18B161	\N	\N	\N	9579878711	\N	\N	f	https://www.instamojo.com/@joeydash/888e61eb23b940d79a495295bce4d7e9	\N	113898531098001531017	888e61eb23b940d79a495295bce4d7e9	\N
637	ASHISH MAKNIKAR	NA16B112	\N	\N	\N	7690985820	\N	\N	f	https://www.instamojo.com/@joeydash/1311a841133844d1a5475dc8edb4c7fb	\N	105981475021868380652	1311a841133844d1a5475dc8edb4c7fb	\N
634	Surjeet Kumar Verma	me17b071	IIT  Madras	Mechanical Engineering	8.36	9123223627	null	me17b071@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/a6dddf92569748ad8101d43827d5902a	MOJO9225V05A19478922	107302960648089981349	a6dddf92569748ad8101d43827d5902a	\N
638	 Prallavit Devgade	109	\N	\N	\N	8624814114	\N	\N	f	https://www.instamojo.com/@joeydash/0189784864bd4395b02d38945dcd5bea	\N	106333256045300862628	0189784864bd4395b02d38945dcd5bea	\N
639	Surbhi Garg	bt18m027	\N	\N	\N	9758678500	\N	\N	f	https://www.instamojo.com/@joeydash/80dc88048320401aa0f83b4be941f000	\N	103681198192226683449	80dc88048320401aa0f83b4be941f000	\N
640	Awik Dhar	Ch18b041	\N	\N	\N	8511169233	\N	\N	f	https://www.instamojo.com/@joeydash/26975e2e407a42a7b5d9449e8712b95b	\N	115045186166643555681	26975e2e407a42a7b5d9449e8712b95b	\N
496	Mamata Lingappa Vaddodagi	EE17B135	IITM	Electrical Engineering	8.08	7337661121	null	mamatalvaddodagi@gmail.com	t	https://www.instamojo.com/@joeydash/5ef8ee7b609d415595654b767e9aa50e	MOJO9225D05N19479918	117615406391981290590	5ef8ee7b609d415595654b767e9aa50e	\N
641	Sovan Kar	1SB16CS099	\N	\N	\N	7908124301	\N	\N	f	https://www.instamojo.com/@joeydash/f6c56c054ec4484ea7c126727fb79cf8	\N	113266173583192039644	f6c56c054ec4484ea7c126727fb79cf8	\N
642	Shivam Chandak	CE16B127	\N	\N	\N	9940307471	\N	\N	f	https://www.instamojo.com/@joeydash/3e3c3a8eb927406da331c2ec77c216ef	\N	105471787389153334156	3e3c3a8eb927406da331c2ec77c216ef	\N
643	Karthik S	ME18B149	\N	\N	\N	6379796668	\N	\N	f	https://www.instamojo.com/@joeydash/d9dbb08773ed4a6eb2fa5b8647ec97b6	\N	117220098631782020186	d9dbb08773ed4a6eb2fa5b8647ec97b6	\N
644	mohit kushwah	BS18B022	\N	\N	\N	8962887629	\N	\N	f	https://www.instamojo.com/@joeydash/ee16393a6be44c79b934833ea0b9b581	\N	115429325526115543173	ee16393a6be44c79b934833ea0b9b581	\N
645	Saarthak Marathe	ME17B162	\N	\N	\N	9769900339	\N	\N	f	https://www.instamojo.com/@joeydash/f596896f966a4211827164644dab7c8e	\N	103934013085623006665	f596896f966a4211827164644dab7c8e	\N
646	Dhananjay Katkar	ME16B145	\N	\N	\N	9011822550	\N	\N	f	https://www.instamojo.com/@joeydash/23fd6345dfcd4197973fb6dfe9f8e9d0	\N	114988120529880919375	23fd6345dfcd4197973fb6dfe9f8e9d0	\N
647	GOSANGI SAI VAMSHI KRISHNA	ME16B108	\N	\N	\N	8074571746	\N	\N	f	https://www.instamojo.com/@joeydash/a505e551b651476bab307526edb53635	\N	105429541963527635739	a505e551b651476bab307526edb53635	\N
648	Utkarsh Mishra	17010101083	\N	\N	\N	9769384457	\N	\N	f	https://www.instamojo.com/@joeydash/4b0117fb273f4796b5ec6b1783b334ae	\N	113529269457401139010	4b0117fb273f4796b5ec6b1783b334ae	\N
649	Ramyak Sanghvi	160320107087	\N	\N	\N	7622849986	\N	\N	f	https://www.instamojo.com/@joeydash/1befcf8517d44d3f8721d1637596f603	\N	114899068497843267952	1befcf8517d44d3f8721d1637596f603	\N
650	lakshman kanth	me16b021	\N	\N	\N	9500199282	\N	\N	f	https://www.instamojo.com/@joeydash/182c322dd0394b5287b07f46f33a8a00	\N	114229644261800945706	182c322dd0394b5287b07f46f33a8a00	\N
651	Suhas Sathesh Rao	ME17B069	\N	\N	\N	9481190251	\N	\N	f	https://www.instamojo.com/@joeydash/c97b8a7df1a24d84a93b505ffff23aec	\N	109375259884013763053	c97b8a7df1a24d84a93b505ffff23aec	\N
652	Neerav Oraon	EP18B010	\N	\N	\N	7050074319	\N	\N	f	https://www.instamojo.com/@joeydash/ee600c814b014f15b2de07a7c0319518	\N	117522885357146815824	ee600c814b014f15b2de07a7c0319518	\N
653	Bhanwar Lal Rawal	EE18M020	\N	\N	\N	9694910609	\N	\N	f	https://www.instamojo.com/@joeydash/95ddfefa94154df1a24719ef0e3aa49d	\N	108612518526783380262	95ddfefa94154df1a24719ef0e3aa49d	\N
654	Rajat Bhandari	CE17B125	\N	\N	\N	7742922500	\N	\N	f	https://www.instamojo.com/@joeydash/16c8ecf6c3524cdaa4cb135e0e78dc33	\N	112903484933357443701	16c8ecf6c3524cdaa4cb135e0e78dc33	\N
655	Shreyash Patidar	ME18B074	\N	\N	\N	6265592388	\N	\N	f	https://www.instamojo.com/@joeydash/107e9dd9f54e4e09a51c4d5e13e22d6c	\N	116542312738324327668	107e9dd9f54e4e09a51c4d5e13e22d6c	\N
656	Adithya Swaroop	EE17B115	\N	\N	\N	9492218401	\N	\N	f	https://www.instamojo.com/@joeydash/4e42561baa6146caa23cf842849ecd35	\N	111444722576795034356	4e42561baa6146caa23cf842849ecd35	\N
657	Ashish Jacob Abraham 	MM17B013 	\N	\N	\N	9446363408	\N	\N	f	https://www.instamojo.com/@joeydash/c94eb7c5d8d5479c80055318bdc010f0	\N	101450182798146604393	c94eb7c5d8d5479c80055318bdc010f0	\N
658	Nikilesh B	EE17B112	\N	\N	\N	9500893173	\N	\N	f	https://www.instamojo.com/@joeydash/5873540958bb48c187163cce116c20a7	\N	107872733361138175010	5873540958bb48c187163cce116c20a7	\N
659	Gunjan Mudgal	ME16B141	\N	\N	\N	8769247505	\N	\N	f	https://www.instamojo.com/@joeydash/24ad2c1176e0439f8cbd36cacb772b47	\N	109373480618194925149	24ad2c1176e0439f8cbd36cacb772b47	\N
660	Jashwanth Sai Yadlapally 	CS18B048	\N	\N	\N	9652404456	\N	\N	f	https://www.instamojo.com/@joeydash/71bfef917563456a91c8282b4d3b829b	\N	105554845638346109132	71bfef917563456a91c8282b4d3b829b	\N
661	Deepanshu Aggarwal	2015IPG-113	\N	\N	\N	9991385150	\N	\N	f	https://www.instamojo.com/@joeydash/e484672a783e4a4eabe4c31de922872f	\N	102591162228450335149	e484672a783e4a4eabe4c31de922872f	\N
662	Rishika Varma k 	CS18B045	\N	\N	\N	6379050565	\N	\N	f	https://www.instamojo.com/@joeydash/61d2eb9f471a40d8beb358321a17a014	\N	100243732331133126469	61d2eb9f471a40d8beb358321a17a014	\N
663	SAINI SRIVIDYA	18JJ5A0207	\N	\N	\N	9182636591	\N	\N	f	https://www.instamojo.com/@joeydash/42a6855da0dc4454a21a8652baa36f5a	\N	100296111466514776944	42a6855da0dc4454a21a8652baa36f5a	\N
664	SUSHANTH REDDY DARAM	17JJ1A0211	\N	\N	\N	9154530110	\N	\N	f	https://www.instamojo.com/@joeydash/c5bfcbf3c6384922aac6ab422059cb4d	\N	108745443239295634264	c5bfcbf3c6384922aac6ab422059cb4d	\N
666	Kudumala Sai Thrisul	16MI100013	\N	\N	\N	7477798999	\N	\N	f	https://www.instamojo.com/@joeydash/5db60515c4774d249940cf71ab22121c	\N	100868456227333581488	5db60515c4774d249940cf71ab22121c	\N
621	Devashish	ME15B098	IIT Madras	Mechanical Engineering	6.93	9785393864	8079015336	dewasheeshsoni@gmail.com	t	https://www.instamojo.com/@joeydash/17436dc005c94bfea74609db75eda924	MOJO9225G05D19485641	102402073813591617342	17436dc005c94bfea74609db75eda924	\N
665	Ayush Toshniwal	EE17B157	IITM	Electrical Engineering	9.15	8975051167	null	ee17b157@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/b03e9db997ba4a0fbe4064d3d59d1fa0	MOJO9225405A19485647	109415117240233735834	b03e9db997ba4a0fbe4064d3d59d1fa0	\N
667	Hari Prasad V	ED17B012	\N	\N	\N	9003295916	\N	\N	f	https://www.instamojo.com/@joeydash/54ee4bdf63fe4f57be3505e1c35503ff	\N	107011537595407121485	54ee4bdf63fe4f57be3505e1c35503ff	\N
668	Shyamashrita Chatterjee	41	\N	\N	\N	9475013167	\N	\N	f	https://www.instamojo.com/@joeydash/6d62f179efd14104aa482f533ee3a5d3	\N	114525950068404793740	6d62f179efd14104aa482f533ee3a5d3	\N
669	Dhanush Ram S	14MSE1125	\N	\N	\N	7200308008	\N	\N	f	https://www.instamojo.com/@joeydash/964f5ea5b2ef495c9b3225fc0346015e	\N	108516706940208226941	964f5ea5b2ef495c9b3225fc0346015e	\N
670	Madhav Maheshwari	ME17B151	\N	\N	\N	8503963106	\N	\N	f	https://www.instamojo.com/@joeydash/edaa2948aa12461699d37aad07d21c3a	\N	105718181361808782027	edaa2948aa12461699d37aad07d21c3a	\N
671	Uma T.V.	ME17B170	IITM	Mechanical Engineering	8.93	8056534932	9043874395	me17b170@smail.iitm.ac.in	t	https://www.instamojo.com/@joeydash/e7d7fb24e80a491da77ef962a8c923dd	MOJO9226K05N95454078	113963390817630213542	e7d7fb24e80a491da77ef962a8c923dd	\N
672	Hari Priya Palla 	NA18B020 	\N	\N	\N	7397259639 	\N	\N	f	https://www.instamojo.com/@joeydash/61ce69c0c9df46da8df7aca336bb420c	\N	115819299473070317876	61ce69c0c9df46da8df7aca336bb420c	\N
673	sruthi duvvuri	4	\N	\N	\N	8886848120	\N	\N	f	https://www.instamojo.com/@joeydash/d1825cdb424a476fbe41e983b420ccc9	\N	115378101767185398982	d1825cdb424a476fbe41e983b420ccc9	\N
674	Sri Ram K	ED18B054	\N	\N	\N	8078375573	\N	\N	f	https://www.instamojo.com/@joeydash/d4efcc74918240049766b39d4a903e7e	\N	101117154862776106863	d4efcc74918240049766b39d4a903e7e	\N
675	Mayank Singh	bs18b021	\N	\N	\N	8076500401	\N	\N	f	https://www.instamojo.com/@joeydash/c2092d3257bf4cb28eb8b56bd44cc1c3	\N	111063540894847667512	c2092d3257bf4cb28eb8b56bd44cc1c3	\N
676	Chhaya Sharma 	Ce18b028 	\N	\N	\N	7737600718 	\N	\N	f	https://www.instamojo.com/@joeydash/81cac717b56b4c11bd1aa1929acf9dfe	\N	113888245761012053183	81cac717b56b4c11bd1aa1929acf9dfe	\N
677	S Jeeva	ME18B030	\N	\N	\N	8939016959	\N	\N	f	https://www.instamojo.com/@joeydash/878c0e97e5ce46bbab7aa57cd7cd61b3	\N	101387875457663094752	878c0e97e5ce46bbab7aa57cd7cd61b3	\N
678	Rajat Vikas Singhal	CS17B042	\N	\N	\N	9104210264	\N	\N	f	https://www.instamojo.com/@joeydash/8b3e6f6c3b1f47d195094ad8ed108b9b	\N	109519412055323157832	8b3e6f6c3b1f47d195094ad8ed108b9b	\N
679	S.Preethi	312216205072	\N	\N	\N	8220563575	\N	\N	f	https://www.instamojo.com/@joeydash/5370f50c064f4eff94d6328dcb490796	\N	113373841263217521331	5370f50c064f4eff94d6328dcb490796	\N
680	Maheshwar Kuchana	1600261C203	\N	\N	\N	8295674252	\N	\N	f	https://www.instamojo.com/@joeydash/c0da7372fb7b42f982a885d34017b2d9	\N	110547291697641871185	c0da7372fb7b42f982a885d34017b2d9	\N
682	R Sailesh	ae18b011	\N	\N	\N	8500290020	\N	\N	f	https://www.instamojo.com/@joeydash/886341b8e543488799e78d21d3920cde	\N	101305269674174084117	886341b8e543488799e78d21d3920cde	\N
683	Vicky Kumar Sharma	BT18M028	\N	\N	\N	8095467414	\N	\N	f	https://www.instamojo.com/@joeydash/eb47a153ac4f40fa991f97811f6d8460	\N	111402924341024612788	eb47a153ac4f40fa991f97811f6d8460	\N
684	Rowin Albert 	201604143	\N	\N	\N	9524134678	\N	\N	f	https://www.instamojo.com/@joeydash/e8d8c39ffbc44799af516242219a0e55	\N	110631595063399051560	e8d8c39ffbc44799af516242219a0e55	\N
685	Sanjay Raaj T	1717127	\N	\N	\N	8778419329	\N	\N	f	https://www.instamojo.com/@joeydash/e06e323c87704759bbdbdf1bdf6ec005	\N	101981507199442917246	e06e323c87704759bbdbdf1bdf6ec005	\N
686	Lokesh	EE17B066	\N	\N	\N	8074274432	\N	\N	f	https://www.instamojo.com/@joeydash/511f8d22235244b88b9daeb3457ce37f	\N	114068218062917305811	511f8d22235244b88b9daeb3457ce37f	\N
687	Soumya	Ee18b054	\N	\N	\N	9176415740	\N	\N	f	https://www.instamojo.com/@joeydash/1885cfc0df714d49b4333d5209a592a0	\N	107316691326563583876	1885cfc0df714d49b4333d5209a592a0	\N
689	ABHIJITH T S	NA16B016	\N	\N	\N	9446090097	\N	\N	f	https://www.instamojo.com/@joeydash/aea44cd6445a4f6ebbd9a19b468d47b8	\N	110177970648727277741	aea44cd6445a4f6ebbd9a19b468d47b8	\N
681	Samrat mark	16107002	Hindustan institute of technology and science	Biotechnology	8.4	9962785525	+919944141266	akumar@hindustanuniv.ac.in	t	https://www.instamojo.com/@joeydash/428538e32de245439663c0db997f6aa4	MOJO9226M05A95509137	105641726480696282068	428538e32de245439663c0db997f6aa4	\N
690	Mugil Soorya P M	16107003	\N	\N	\N	9600860639	\N	\N	f	https://www.instamojo.com/@joeydash/40d8989d6d814027a955848737228eb0	\N	114227557694963116135	40d8989d6d814027a955848737228eb0	\N
691	Ebin Abraham 	16107006	\N	\N	\N	8870416512	\N	\N	f	https://www.instamojo.com/@joeydash/a5d6bfae06274ad587a27f6dde08589d	\N	103207216063002712121	a5d6bfae06274ad587a27f6dde08589d	\N
692	Priyadharshini	16107001	\N	\N	\N	7358538926	\N	\N	f	https://www.instamojo.com/@joeydash/cf4fd0aa16c845068e3604ac0f78b176	\N	100037774541223863716	cf4fd0aa16c845068e3604ac0f78b176	\N
693	Sanjana Prabhu	Ee17b072	\N	\N	\N	8971735336	\N	\N	f	https://www.instamojo.com/@joeydash/037be1d2a1f64286b209e00ef3fa5451	\N	115958018513124626982	037be1d2a1f64286b209e00ef3fa5451	\N
694	Neethu S. R	ma18c020	\N	\N	\N	7907193983	\N	\N	f	https://www.instamojo.com/@joeydash/0219cc6c5f404acba6194a942025da03	\N	105035077380299958583	0219cc6c5f404acba6194a942025da03	\N
695	Kalash Verma	me18b052	\N	\N	\N	7471117800	\N	\N	f	https://www.instamojo.com/@joeydash/24080bec1f044116bae671a56133dbf7	\N	108382685221057954981	24080bec1f044116bae671a56133dbf7	\N
696	Swapnil Bagate	EE18B152	\N	\N	\N	9230254404	\N	\N	f	https://www.instamojo.com/@joeydash/736e91e477aa4b85a973ebefbd9f0e25	\N	100426036979229502939	736e91e477aa4b85a973ebefbd9f0e25	\N
697	Hemanth Ram	ee18b132	\N	\N	\N	9498866441	\N	\N	f	https://www.instamojo.com/@joeydash/da63b793a7bd40509038f5cfa587f89d	\N	113978798657604321179	da63b793a7bd40509038f5cfa587f89d	\N
698	Maheshwari S	201603051	\N	\N	\N	7397500860	\N	\N	f	https://www.instamojo.com/@joeydash/ba2dac0e3a064211a5cc977e3e7a6776	\N	116107742058190876844	ba2dac0e3a064211a5cc977e3e7a6776	\N
699	Mahima	15wh1a0502	\N	\N	\N	9603694286	\N	\N	f	https://www.instamojo.com/@joeydash/15035cfd9c564254a96cb4720e62fb3c	\N	103933336112421689610	15035cfd9c564254a96cb4720e62fb3c	\N
700	Ramakrishnan J	201604134	\N	\N	\N	9840918022	\N	\N	f	https://www.instamojo.com/@joeydash/e0f5b4a9bcad4b12826a036d32693af7	\N	114817523383876433918	e0f5b4a9bcad4b12826a036d32693af7	\N
701	M.K.ABDUL HAMEED	170292601002	\N	\N	\N	7010870972	\N	\N	f	https://www.instamojo.com/@joeydash/5bf66471dd5c4b5cbfe1fa96e3add8ac	\N	112505714881529466921	5bf66471dd5c4b5cbfe1fa96e3add8ac	\N
703	Joshua Edwin Ragul	16130028	\N	\N	\N	7708283111	\N	\N	f	https://www.instamojo.com/@joeydash/68bc79eeb4a94b979e59eb76176d645a	\N	109507225878783702985	68bc79eeb4a94b979e59eb76176d645a	\N
704	Aniket Suresh Patil	me15b124	\N	\N	\N	9503052117	\N	\N	f	https://www.instamojo.com/@joeydash/f1cd66eedc374f02b8d6c113a72f7c4e	\N	110741549368883137465	f1cd66eedc374f02b8d6c113a72f7c4e	\N
705	DUGGIRALA PAVAN SAIRAM	EE18B048	\N	\N	\N	8985655689	\N	\N	f	https://www.instamojo.com/@joeydash/228bfd19558846a9917f037cfe34dd50	\N	117781477599627077599	228bfd19558846a9917f037cfe34dd50	\N
706	Subhrakanti Das	00	\N	\N	\N	9679080874	\N	\N	f	https://www.instamojo.com/@joeydash/6386157ac2844412b08370fae1e12a93	\N	100012191509507254635	6386157ac2844412b08370fae1e12a93	\N
707	Deepakkumar 	170292601012	\N	\N	\N	9003493080	\N	\N	f	https://www.instamojo.com/@joeydash/0309db0f14cc4a68b1ba695a737c1e0e	\N	113934733771700894590	0309db0f14cc4a68b1ba695a737c1e0e	\N
708	AswathiRajeevan 	180292601015	\N	\N	\N	9544324999	\N	\N	f	https://www.instamojo.com/@joeydash/a6e680d6e97c4c689d0aa9be22d5d16b	\N	112287264203593620364	a6e680d6e97c4c689d0aa9be22d5d16b	\N
709	fazil hussain 	180292601033	\N	\N	\N	9566193689	\N	\N	f	https://www.instamojo.com/@joeydash/836f8ea461ad4c9080d6070ed2a49121	\N	116481189120918940278	836f8ea461ad4c9080d6070ed2a49121	\N
710	Nakul Mandhre	15130036	\N	\N	\N	9952910749	\N	\N	f	https://www.instamojo.com/@joeydash/ca95917e59dd4f4c845802ba5f2db5ad	\N	100888486472323143652	ca95917e59dd4f4c845802ba5f2db5ad	\N
711	Varad Thikekar	CH18B072	\N	\N	\N	9359013414	\N	\N	f	https://www.instamojo.com/@joeydash/543164407b2648299b4e2542e1ca7ca9	\N	108562404006563394764	543164407b2648299b4e2542e1ca7ca9	\N
712	Mahasumrizwan 	180292601053	\N	\N	\N	8122170192	\N	\N	f	https://www.instamojo.com/@joeydash/c81d371fff2748a886ad1151af531a33	\N	110975995114402452564	c81d371fff2748a886ad1151af531a33	\N
713	Poornima	180292601080	\N	\N	\N	9566366119	\N	\N	f	https://www.instamojo.com/@joeydash/d1a6c1dcad914ca884681c5dc19553ac	\N	108497453376781852945	d1a6c1dcad914ca884681c5dc19553ac	\N
714	Keerthi VC	KTE17ME037	\N	\N	\N	7034063783	\N	\N	f	https://www.instamojo.com/@joeydash/85025cf5824b40f199f96df98a87057c	\N	111341297199545613038	85025cf5824b40f199f96df98a87057c	\N
715	Suresh Ramesh Khetawat	121601013	\N	\N	\N	8281112788	\N	\N	f	https://www.instamojo.com/@joeydash/a4d5dae73b934b4f9cf77d5510a9f904	\N	117599913019367044159	a4d5dae73b934b4f9cf77d5510a9f904	\N
716	Murugan	171291601116	\N	\N	\N	9788556888	\N	\N	f	https://www.instamojo.com/@joeydash/ceac050d3750494697861617872274a0	\N	114186203002331939794	ceac050d3750494697861617872274a0	\N
717	Preethi 	171411601027	\N	\N	\N	9500462423 	\N	\N	f	https://www.instamojo.com/@joeydash/32f45c55f91245c79367d6292ffd8322	\N	103488078305005976029	32f45c55f91245c79367d6292ffd8322	\N
718	Yuvanshankar.B	171291601192	\N	\N	\N	8428877071	\N	\N	f	https://www.instamojo.com/@joeydash/b808fbc92efb44a68018ece8d2da0735	\N	100903650956250637024	b808fbc92efb44a68018ece8d2da0735	\N
719	Raghuvaran sharma 	16211a0423	\N	\N	\N	9676879695	\N	\N	f	https://www.instamojo.com/@joeydash/fffe1b0d7f73473e8e93797af490035b	\N	110908060872101561853	fffe1b0d7f73473e8e93797af490035b	\N
721	J sai charan	16211a0579	\N	\N	\N	8008233650	\N	\N	f	https://www.instamojo.com/@joeydash/fea0cec5684642758570987ea15615b2	\N	113427824936637840996	fea0cec5684642758570987ea15615b2	\N
722	panshul kushwaha	ipg-2015-055	\N	\N	\N	7987737674	\N	\N	f	https://www.instamojo.com/@joeydash/d8ec3e0aff964b69a36f3c259f8c5695	\N	100524604573790733663	d8ec3e0aff964b69a36f3c259f8c5695	\N
723	Amulya amsanpally	17211a0406	\N	\N	\N	9959854232	\N	\N	f	https://www.instamojo.com/@joeydash/a644831adc4240bcbb73988918a47e58	\N	101203371747531185357	a644831adc4240bcbb73988918a47e58	\N
724	Shamira	171291601062	\N	\N	\N	7094028655	\N	\N	f	https://www.instamojo.com/@joeydash/ddd0500b4d984a9ba4ed642ad30f0484	\N	102191701944784594793	ddd0500b4d984a9ba4ed642ad30f0484	\N
720	Jatin Tiwari	16211a1241	BVRITN	Information Technology	9.4	9642338010	9848951139	jatintiwari456@gmail.com	t	https://www.instamojo.com/@joeydash/cd4ec830f18845e98f5a22c84caf13c8	MOJO9226105D95513856	104918609758142636078	cd4ec830f18845e98f5a22c84caf13c8	\N
725	Anusha	16211a0379	\N	\N	\N	8317641604	\N	\N	f	https://www.instamojo.com/@joeydash/65a68fb8ac7540cb98491faa0802db07	\N	101977943695203459345	65a68fb8ac7540cb98491faa0802db07	\N
726	M.Pavan Goud	16211a04a9	\N	\N	\N	9502458914	\N	\N	f	https://www.instamojo.com/@joeydash/c4b1e269e57c40fe9ae6e4c637593700	\N	103489347539476665655	c4b1e269e57c40fe9ae6e4c637593700	\N
727	Harshika	17211a1229	\N	\N	\N	7093598204	\N	\N	f	https://www.instamojo.com/@joeydash/6d0671a629f04066abe9615e06a790db	\N	106719939357621846168	6d0671a629f04066abe9615e06a790db	\N
728	Abhiram Tarimala	CH17B033	\N	\N	\N	9972297121	\N	\N	f	https://www.instamojo.com/@joeydash/be5a9a69c6324e58b762894284d8d6af	\N	108034461483395868632	be5a9a69c6324e58b762894284d8d6af	\N
729	Jaya v	171291601070	\N	\N	\N	7338718258	\N	\N	f	https://www.instamojo.com/@joeydash/0a263844eca1433882cef34138c6d1cc	\N	105368299530436984082	0a263844eca1433882cef34138c6d1cc	\N
730	Animi	17265A0213	\N	\N	\N	7989201489	\N	\N	f	https://www.instamojo.com/@joeydash/ddea6b83da354bee88564a6be00a1678	\N	112003487079351151254	ddea6b83da354bee88564a6be00a1678	\N
731	R.Mohan	201604090	\N	\N	\N	9677803934	\N	\N	f	https://www.instamojo.com/@joeydash/cc2abbbe53d24345bb285d6f87304fbb	\N	105384267813869488602	cc2abbbe53d24345bb285d6f87304fbb	\N
732	PUSALA SAI VIVEK 	Ce18b047	\N	\N	\N	9966880407	\N	\N	f	https://www.instamojo.com/@joeydash/9993efdf187b48d4870ff0b66cbe8caa	\N	117074336345478983632	9993efdf187b48d4870ff0b66cbe8caa	\N
733	Divya	180292601026	\N	\N	\N	8667895250	\N	\N	f	https://www.instamojo.com/@joeydash/c02d4e89cf004463aa607d2d46347def	\N	103160522592401353055	c02d4e89cf004463aa607d2d46347def	\N
734	Ãśhwîťh kumar	17211a0332	\N	\N	\N	8639784406	\N	\N	f	https://www.instamojo.com/@joeydash/c8ec753f2d7e44768a34d63c81e2b1ab	\N	109932093479652910983	c8ec753f2d7e44768a34d63c81e2b1ab	\N
735	Karishma sultana S	171291601058	\N	\N	\N	9789973260	\N	\N	f	https://www.instamojo.com/@joeydash/069399d4469a40beace8f41cf1362bca	\N	101051984663811579290	069399d4469a40beace8f41cf1362bca	\N
738	Meenupriya O S	72	\N	\N	\N	9495279432	\N	\N	f	https://www.instamojo.com/@joeydash/2b7a42b174f246c58767685b656084be	\N	118403157346615964994	2b7a42b174f246c58767685b656084be	\N
739	Vinjamuri Solmon Raju	17211a12b7	\N	\N	\N	9515319387	\N	\N	f	https://www.instamojo.com/@joeydash/73e495149eb24ca7910290aea6e6e57b	\N	114263084990181004463	73e495149eb24ca7910290aea6e6e57b	\N
740	Monisha S	160071601094	\N	\N	\N	7530003417	\N	\N	f	https://www.instamojo.com/@joeydash/897de6d23a6747baa588e156cf498d92	\N	108611939221151782017	897de6d23a6747baa588e156cf498d92	\N
741	Venkata Siva Yashwant Kumar Deu	16211a05v9	\N	\N	\N	8143481585	\N	\N	f	https://www.instamojo.com/@joeydash/0a2e9905c4224afe982a1d935aa559a2	\N	103384854572338898390	0a2e9905c4224afe982a1d935aa559a2	\N
742	Bathimurge Dhavalika	16211A0418	\N	\N	\N	9676299440	\N	\N	f	https://www.instamojo.com/@joeydash/697a8076851f4531a04d0829ee3d268c	\N	102337752411335677874	697a8076851f4531a04d0829ee3d268c	\N
743	Mohamed Laeeq	171291601097	\N	\N	\N	7338999862	\N	\N	f	https://www.instamojo.com/@joeydash/3a6692cb7df24d3bac07e695079b8dfd	\N	102350455221991151858	3a6692cb7df24d3bac07e695079b8dfd	\N
744	Kusma Thummagunta	160071601171	\N	\N	\N	6302341156	\N	\N	f	https://www.instamojo.com/@joeydash/75a659a150e3452aa3027728b8d4a79b	\N	108036690488109078326	75a659a150e3452aa3027728b8d4a79b	\N
745	Sankar P	17135099	\N	\N	\N	8112737625	\N	\N	f	https://www.instamojo.com/@joeydash/2141bd5f3ff949e7bf05c4781f9839e4	\N	114193926166367007704	2141bd5f3ff949e7bf05c4781f9839e4	\N
746	Manasa Gonchigar	EP14B015	\N	\N	\N	9087601224	\N	\N	f	https://www.instamojo.com/@joeydash/90fb7024a054432a95b28466191e864e	\N	110440598782266049609	90fb7024a054432a95b28466191e864e	\N
747	YELLA REDDY	17104072	\N	\N	\N	9123539445	\N	\N	f	https://www.instamojo.com/@joeydash/821626fdc7aa490eae9700685fdb1d9e	\N	110258860955993442540	821626fdc7aa490eae9700685fdb1d9e	\N
748	Balaga Jhansi 	Ce17b028	\N	\N	\N	8790154032	\N	\N	f	https://www.instamojo.com/@joeydash/e615130c52ae49a09c151bb0b6358466	\N	116964737184564653833	e615130c52ae49a09c151bb0b6358466	\N
749	Shiva Prasad Sunka 	17211a04m7	\N	\N	\N	8897427110	\N	\N	f	https://www.instamojo.com/@joeydash/2edc4de520fc41dfa8a3fb9c3f4f12e3	\N	115893466469162485501	2edc4de520fc41dfa8a3fb9c3f4f12e3	\N
750	Sai Suchith Mahajan	121601016	\N	\N	\N	+91-8281112807	\N	\N	f	https://www.instamojo.com/@joeydash/bbc93b58b1ea4c9b9e2658094046ff01	\N	103246051290396859124	bbc93b58b1ea4c9b9e2658094046ff01	\N
751	Shivam Rai 	17bce1182 	\N	\N	\N	7397431710 	\N	\N	f	https://www.instamojo.com/@joeydash/2fc40652f1af43ffb86ab06e79dee133	\N	113912321613751055552	2fc40652f1af43ffb86ab06e79dee133	\N
752	Bhavishya Garg	1604040	\N	\N	\N	9079158654	\N	\N	f	https://www.instamojo.com/@joeydash/1b66451896754338a223eed2ca046d35	\N	107945827618686612359	1b66451896754338a223eed2ca046d35	\N
753	Hari Karan V	170101012	\N	\N	\N	9551453145	\N	\N	f	https://www.instamojo.com/@joeydash/535e0066f74d43b3bd3b81bfd190b7b5	\N	114125499907159457197	535e0066f74d43b3bd3b81bfd190b7b5	\N
754	N.Snehita Chowdary	16wh1a0433	\N	\N	\N	9573904667	\N	\N	f	https://www.instamojo.com/@joeydash/7807bac3ead741bcbb90f0edcc3af01c	\N	100622507197575721798	7807bac3ead741bcbb90f0edcc3af01c	\N
755	Thirulogasundhar Balakamatchi	FP065	\N	\N	\N	8939350725	\N	\N	f	https://www.instamojo.com/@joeydash/39481cc5dd1b489f8ce881fa2f8c2361	\N	111028326981029209404	39481cc5dd1b489f8ce881fa2f8c2361	\N
756	ELAVARASAN. M	170292601065	\N	\N	\N	9952085290	\N	\N	f	https://www.instamojo.com/@joeydash/e2752c09ef0d4f02b4c20e323a939a71	\N	112311651424196547257	e2752c09ef0d4f02b4c20e323a939a71	\N
757	LOKA RAMAKRISHNA REDDY	16211A05D4	\N	\N	\N	9505868212	\N	\N	f	https://www.instamojo.com/@joeydash/283c274ca5e1425bb39176421eaacaaa	\N	101061940570555323156	283c274ca5e1425bb39176421eaacaaa	\N
758	Dharmesh Khalkho	EE15B084	\N	\N	\N	9840282726	\N	\N	f	https://www.instamojo.com/@joeydash/3b66e19f388d4fed9cf976f398f715e2	\N	102009742594823010660	3b66e19f388d4fed9cf976f398f715e2	\N
\.


--
-- Data for Name: user_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_detail (id, name, email, image_url, user_h_id, startup_name, startup_id) FROM stdin;
4386	Joey Dash	joeydash@saarang.org	https://lh3.googleusercontent.com/-fqOTgBE-kMg/AAAAAAAAAAI/AAAAAAAAAAc/g8JI3E0AcEw/s96-c/photo.jpg	103441912139943416551	\N	\N
1499	Hemant Ahirwar	hemantahirwar1@gmail.com	https://lh6.googleusercontent.com/-5ZZuFm2wgZM/AAAAAAAAAAI/AAAAAAAAAaw/TCx1OJbyvoI/s96-c/photo.jpg	106774401436596091547	\N	\N
1739	Sirish Somanchi	sirishks@gmail.com	https://lh6.googleusercontent.com/-3fKko1-sRgI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOb8CK8-KSCqlGs1NTVdzM52C_E1g/s96-c/photo.jpg	108825759819157028428	\N	243
4858	Madhav Maheshwari	madhavmaheshwari79@gmail.com	https://lh6.googleusercontent.com/-aiYP4fg0zcM/AAAAAAAAAAI/AAAAAAAAHXs/l0fZj3PIr60/s96-c/photo.jpg	105718181361808782027	\N	\N
4851	Rohan Rajmohan	rohanrrajmohan@gmail.com	https://lh5.googleusercontent.com/-nD3Xkwt-QV8/AAAAAAAAAAI/AAAAAAAAAf4/yN3lglHnzu0/s96-c/photo.jpg	110035970755160527050	\N	\N
4759	Om Kotwal	omkotwal14@gmail.com	https://lh4.googleusercontent.com/-Hz0BCz7SRqs/AAAAAAAAAAI/AAAAAAAAAB8/0qENic0HOdM/s96-c/photo.jpg	105648143853551093911	\N	\N
4853	Amarnath Prasad	amrnth007@gmail.com	https://lh4.googleusercontent.com/-BtTRd84R6SA/AAAAAAAAAAI/AAAAAAAAHeo/_uoH9Ji7LA4/s96-c/photo.jpg	116739830006062100225	\N	\N
1648	Joey Dash	joydassudipta@gmail.com	https://lh3.googleusercontent.com/-hjMQ9VBKHIw/AAAAAAAAAAI/AAAAAAAAFDk/ePiRR90JHaM/s96-c/photo.jpg	118208723166374240159	\N	277
1533	Hari Kishore P na18b019	na18b019@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7ar-bG4aw2w/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP2J9tbNK64Sf_yvE5lfHaOM-0LZQ/s96-c/photo.jpg	103546078731885007120	\N	\N
4852	SUKRIT KUMAR GUPTA	sukrit.dakshana15@gmail.com	https://lh6.googleusercontent.com/-i-kvWY0-JPY/AAAAAAAAAAI/AAAAAAAABKo/ZnUODV8w8wI/s96-c/photo.jpg	113046604995058376278	\N	\N
1754	HR iB Hubs	hr@ibhubs.co	https://lh6.googleusercontent.com/-Mb9A0FoE194/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf7bqHOhxR1zO-OflUcwdIyhgf1zg/s96-c/photo.jpg	102540152476572591754	\N	235
4905	Pranjali Vatsalaya	pranjali.vats888@gmail.com	https://lh5.googleusercontent.com/-ZkOiAsrR3MM/AAAAAAAAAAI/AAAAAAAAAhY/f-VlLcQcAVg/s96-c/photo.jpg	111558464273085465448	\N	\N
1808	Drusilla Pereira	drusilla@gramophone.co.in	https://lh4.googleusercontent.com/-ejdc_65PXsI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc1zHmVbdPE1iorwTFS53j90Rlm9A/s96-c/photo.jpg	114503787094540282981	\N	244
1580	pooja chaudhary	pooja.chaudhary@karexpert.com	https://lh5.googleusercontent.com/-c6v8I1dADQU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPcozpYmh_u32MT6W9GzvNQm60nDg/s96-c/photo.jpg	106407488023143571708	\N	229
1793	Hemanth Sridhar	hemanth@planetworx.in	https://lh5.googleusercontent.com/-H9hstPfmDag/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfx1Otsgn5KU0a8gVJhZaZrUF2vpw/s96-c/photo.jpg	114749538391689307031	\N	242
1324	Ankita Modi	ankita.modi@addverb.in	https://lh5.googleusercontent.com/-suM92JNNkUk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNdSKp7QAXefhA5OxZ9lVusl1qghg/s96-c/photo.jpg	106123538173898449055	\N	201
1820	Anjali Sharma	hr@ebabu.co	https://lh5.googleusercontent.com/-7yf0hfOUXuM/AAAAAAAAAAI/AAAAAAAABLc/QxkDT9PHVZ4/s96-c/photo.jpg	101326090802695787002	\N	245
1534	Sowmya Bezawada	sowmya@ibhubs.co	https://lh4.googleusercontent.com/-MldLgG5D6bY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfKL2bx6Mnm2ngh9j5KOAiT4D2LwA/s96-c/photo.jpg	105373738578694994605	\N	234
3965	SAURABH JAIN me16b071	me16b071@smail.iitm.ac.in	https://lh6.googleusercontent.com/-CRJj8Y-YaT0/AAAAAAAAAAI/AAAAAAAABOA/Vt5lacfmzFk/s96-c/photo.jpg	110553366885836969408	\N	\N
1608	Chitra, i-loads Senior Manager - Human Resources, Chennai	chitra.c@iloads.in	https://lh5.googleusercontent.com/-y38YE6HlZC8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMDusom469Yz_o4iCgGt5tY_gDHEA/s96-c/photo.jpg	110505594872527456493	\N	230
1638	Vellayan L	vellayanl@iloads.in	https://lh6.googleusercontent.com/-IdcrdUP8L-k/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMXUi8NlZNmIk2gD_qEvlW8wfYbqg/s96-c/photo.jpg	100898145044469393733	\N	230
1551	Victor Senapaty	victor@propelld.com	https://lh5.googleusercontent.com/-JGTwFKlfLAU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMWx1IG1Nsw7h59mWbin_r3ud9P7Q/s96-c/photo.jpg	107530024622485449869	\N	224
1629	HR Srjna	hr@srjna.com	https://lh5.googleusercontent.com/-uVS0-3hO7LQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPKZi2z0WedozGVkflxdkNlehxzkQ/s96-c/photo.jpg	102476915533780948091	\N	231
1806	Ashish Singh	ashish@gramophone.co.in	https://lh5.googleusercontent.com/-cqrVnebIQdI/AAAAAAAAAAI/AAAAAAAAAAo/GeFXTRrZvSE/s96-c/photo.jpg	111030578426826726626	\N	\N
1558	Vivek Gupta	vivek@wishup.co	https://lh4.googleusercontent.com/-Gt4DkI38qY8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOYi5mh4Nm4z7AjFO2LvfC-g14XaA/s96-c/photo.jpg	104298758991766668035	\N	225
1773	Rahul Joshi	rahul.joshi@voylla.com	https://lh4.googleusercontent.com/-e7dvGvQd9-Y/AAAAAAAAAAI/AAAAAAAAEI4/k-p8zYRxPfI/s96-c/photo.jpg	111133250649424423782	\N	237
1645	Manvendra Pratap Singh	singh.manvendr20@gmail.com	https://lh3.googleusercontent.com/--A62WIOaguU/AAAAAAAAAAI/AAAAAAAAEvA/kfC1tY_rV3c/s96-c/photo.jpg	110447218383396106962	\N	232
1772	Namrata Agrawal	a.namrata@meeshamed.net	https://lh4.googleusercontent.com/-hpJN4C2AWlE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPsqk5W4sSESVbw-OXqsFyaSXdq7g/s96-c/photo.jpg	116519274255305915920	\N	\N
1740	Anubha Verma	anubha@rentsher.com	https://lh3.googleusercontent.com/-BTH4OPMUvvM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPUVIgg6ig6emPX8ZRIOFFuDwZA5g/s96-c/photo.jpg	115802938042318956916	\N	233
1780	Valentina Dsouza	valentina@ionenergy.co	https://lh4.googleusercontent.com/-qAHNUjR_FSU/AAAAAAAAAAI/AAAAAAAAAC0/nsT7Vb3NMb4/s96-c/photo.jpg	117013339697530495306	\N	238
1766	Divanshu Kumar	divanshu@involveedu.com	https://lh3.googleusercontent.com/-pwwKPuIF0lA/AAAAAAAAAAI/AAAAAAAAACo/JUDrNjkDdVM/s96-c/photo.jpg	113564221505157815723	\N	236
1626	Pankaj Lal	pankaj@mammoth.io	https://lh5.googleusercontent.com/-m6DE_LA4iSM/AAAAAAAAAAI/AAAAAAAAALg/w5oVGQwbPXg/s96-c/photo.jpg	100916162979211575903	\N	250
1848	Deepak Sahoo	flashiitm@gmail.com	https://lh4.googleusercontent.com/-weDwsWzPJbk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPuCu07-lzA24_y1z7A7ktmddIYOA/s96-c/photo.jpg	117894875203741245699	\N	246
1611	Pratik Sharma	pratik.sharma1619@gmail.com	https://lh6.googleusercontent.com/-1bRl68CnrqI/AAAAAAAAAAI/AAAAAAAAOts/D1LPi15cunU/s96-c/photo.jpg	101818747050100224079	\N	228
1576	Sidharth Bhatia	bhatiasidharth.89@gmail.com	https://lh6.googleusercontent.com/-SgB6K1OREjg/AAAAAAAAAAI/AAAAAAAAAFA/IQug2PnkDjM/s96-c/photo.jpg	102584910929681137125	\N	\N
1880	Web Operations webops_ecell	webops_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-E2NF3HyXPss/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcmocOCuwTndSyNEml4gQ63sU6UFw/s96-c/photo.jpg	107813869731075135750	\N	\N
2189	Arokia Doss	arokia.d@srivishnu.edu.in	https://lh4.googleusercontent.com/-DDz9gu_vriY/AAAAAAAAAAI/AAAAAAAABqM/idtU5Q7OJao/s96-c/photo.jpg	115342870212009600095	\N	\N
2144	Sv J	srvajw@gmail.com	https://lh4.googleusercontent.com/-l5qFWbey1rk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN1SpZGyHHiMzehgUD_dC6jGboCOQ/s96-c/photo.jpg	101107640131204357570	\N	260
2083	iB Hubs Careers	careers@ibhubs.co	https://lh6.googleusercontent.com/-75N50cGyVXk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNxgeooH6nnrKGB9PHmOXDJO0UbXw/s96-c/photo.jpg	104821578026829852225	\N	\N
1885	Vibhor Kumar	vibhor.kumar@stanzaliving.com	https://lh5.googleusercontent.com/-B99IWpQLIFs/AAAAAAAAAAI/AAAAAAAAACw/qAjsXSzuFSM/s96-c/photo.jpg	115375476385745576962	\N	249
1914	Chandresh Vaghanani	chandresh@allevents.in	https://lh5.googleusercontent.com/-XMRGJqKg4fY/AAAAAAAAAAI/AAAAAAAAAzs/fMNjYRw3Xyo/s96-c/photo.jpg	109249031263145344654	\N	251
1908	Varun Chopra	chopravarun01@gmail.com	https://lh6.googleusercontent.com/-YxfnlUFwfPs/AAAAAAAAAAI/AAAAAAAAKwU/N3HuaVdpmeo/s96-c/photo.jpg	101189951357074482183	\N	\N
2017	Eduvanz Financing Private Limited	the.eduvanz@gmail.com	https://lh3.googleusercontent.com/-1qtGcLbjwdk/AAAAAAAAAAI/AAAAAAAAABU/p_aZDivYYN8/s96-c/photo.jpg	107429974676687296166	\N	253
4016	Bagde Akshit ee17b103	ee17b103@smail.iitm.ac.in	https://lh3.googleusercontent.com/-0n29isXZiiY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfatKqx-Jk58iAs5pKYrmDrOGFkGg/s96-c/photo.jpg	106783215449844945185	\N	\N
2221	PORANDLA RANADEEP	16211a0388@bvrit.ac.in	https://lh4.googleusercontent.com/-iwKtev5m9Dg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNdF-PCngwVtSaEVRsgEqTZAUk_Ow/s96-c/photo.jpg	109234805044650346236	\N	\N
2131	Amogh Bhatnagar	amogh.bhatnagar53@googlemail.com	https://lh3.googleusercontent.com/-37Faz4dRV38/AAAAAAAAAAI/AAAAAAAAEU8/vXYySqtBFgw/s96-c/photo.jpg	109683991238473547277	\N	259
4449	E Meghana	16wh1a1216@bvrithyderabad.edu.in	https://lh4.googleusercontent.com/-ZUhsEHaLPQI/AAAAAAAAAAI/AAAAAAAAABA/R_Tg5dVP6LQ/s96-c/photo.jpg	103752593630791624652	\N	\N
2222	PULLILA ABHISHEK	17215a0501@bvrit.ac.in	https://lh3.googleusercontent.com/-6AHD4shviaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMgKhy_bbxPLSpJX0lOSFx64yoEPg/s96-c/photo.jpg	113903073200127800235	\N	\N
1955	Ashwin Kumar	ashwin@backbuckle.io	https://lh5.googleusercontent.com/-DYQwQjQqDH4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNBpbgF0pfaLFeAJ4awlb2lds1atA/s96-c/photo.jpg	110274344916933599324	\N	252
4766	SIDDHANT TOKNEKAR	toknekarsiddhant@gmail.com	https://lh3.googleusercontent.com/-2l1QACT_Z2s/AAAAAAAAAAI/AAAAAAAAABs/v8EnLJlyLK0/s96-c/photo.jpg	116786289933147386527	\N	\N
2092	Sreenivas Murali	sreenivas.nm5493@gmail.com	https://lh5.googleusercontent.com/-2Bd0fAy5Btc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPzSk3Pge0iU_1YnF-U0EZaReZz_g/s96-c/photo.jpg	103304235098083374178	\N	257
2182	Nirmal Sharma	nirmal2502@gmail.com	https://lh4.googleusercontent.com/-7uKiqWI0nK0/AAAAAAAAAAI/AAAAAAAACno/by8P5qeMagU/s96-c/photo.jpg	106289280886691331250	\N	\N
2227	varun kolakani	varun.kolakani007@gmail.com	https://lh5.googleusercontent.com/-VP9wQ0JwEcM/AAAAAAAAAAI/AAAAAAAAABY/ANufxi1v4-M/s96-c/photo.jpg	108896450923947891853	\N	\N
2115	Snehal Gupta	snehal@qunulabs.in	https://lh3.googleusercontent.com/-gZxfoCCf1UA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rekjDKAwtHUPpHMMHjcME6ewZYnPg/s96-c/photo.jpg	104089503500603657430	\N	258
2216	narsimha kondaji	narsimhakondaji21@gmail.com	https://lh6.googleusercontent.com/-K3jgFwG2OtE/AAAAAAAAAAI/AAAAAAAAEIc/W7OxN725og8/s96-c/photo.jpg	107564555087017130990	\N	\N
2046	Hitesh Haran	hitesh.k.haran@gmail.com	https://lh4.googleusercontent.com/-4xVqveUHGGI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOOCl71LV997f_lClUh1VK20dHOyA/s96-c/photo.jpg	105202096528458362102	\N	272
2187	Peacock Solar	peacocksolarenergy@gmail.com	https://lh3.googleusercontent.com/-CaUmwAeoyfQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP4VPga2UQSICxFXI6W1Gv-ZZnX-w/s96-c/photo.jpg	111320166102807820736	\N	263
2217	Abhishek reddy	abhishek.balannolla@gmail.com	https://lh3.googleusercontent.com/-igJ3MwDy19Y/AAAAAAAAAAI/AAAAAAAAIek/VxsVChJg0MA/s96-c/photo.jpg	110959428559525986265	\N	\N
2224	Muralidhar Somisetty	muralidhars@wellnesys.com	https://lh6.googleusercontent.com/-mOvpU4EPmPE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMztpS4us1LBpvIDUIfKw-CnBeJiw/s96-c/photo.jpg	101907162894505620447	\N	268
2184	Vishal Mistry	vishal@chaturideas.com	https://lh4.googleusercontent.com/-l_8se3lLPBw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMMCBIp09V_MjJzyaSqnVycum0KzQ/s96-c/photo.jpg	101396729595279031815	\N	262
2218	MEKALA PRUDHVI REDDY	16211a05e4@bvrit.ac.in	https://lh4.googleusercontent.com/-2V9seW0cBx8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMv4BzIcSAO6LXR0rl2K3Ii0BzVWw/s96-c/photo.jpg	106711601084471424539	\N	\N
2219	KONDURU SHIRIDINATH	16211a0235@bvrit.ac.in	https://lh4.googleusercontent.com/-EMGxZ8z_HSM/AAAAAAAAAAI/AAAAAAAAAAU/3S6AYdk2RLg/s96-c/photo.jpg	115023583903933855531	\N	\N
2012	Mohammed Zakkiria	zakkiria@freightbro.com	https://lh4.googleusercontent.com/-hvMh_zOJeIY/AAAAAAAAAAI/AAAAAAAABoA/ky1R7SyW80g/s96-c/photo.jpg	103686313929651160614	\N	\N
2234	prudhvi reddy	prudhvireddy.m01@gmail.com	https://lh5.googleusercontent.com/-CNmi2bRjUgg/AAAAAAAAAAI/AAAAAAAAACk/2GAAz4IdDIY/s96-c/photo.jpg	102641646898857644341	\N	\N
2239	R Gyanesh	16211a1277@bvrit.ac.in	https://lh4.googleusercontent.com/-YjwnhbZHoFY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOhet8EOT_NSsDc9Uh4rB6zCMH7rQ/s96-c/photo.jpg	111287724851133369161	\N	\N
2241	SAI CHARAN JANA	jana.cherry2010@gmail.com	https://lh5.googleusercontent.com/-Jb-GbRnVQpc/AAAAAAAAAAI/AAAAAAAAABI/REdcXDcYhOM/s96-c/photo.jpg	107831550891832625063	\N	\N
2243	Ritesh Yadav	riteshyadav654@gmail.com	https://lh4.googleusercontent.com/-flpKf188R3A/AAAAAAAAAAI/AAAAAAAAMsg/dKLM-B52qeg/s96-c/photo.jpg	110296223890564310627	\N	\N
2247	SAIRAM BOLLEPALLI	17215a0314@bvrit.ac.in	https://lh5.googleusercontent.com/-OYFZHYLL-yw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMc1iDx-8DIysajrluW5oo5VZr9wA/s96-c/photo.jpg	106840195352712555805	\N	\N
4867	Shashank M Patil ch18b022	ch18b022@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Q31UIRBygVE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP7uDZ1lvghCfgvH30pcvo8gy0a0w/s96-c/photo.jpg	114832114521563248786	\N	\N
2215	prameela devi	prameela5128@gmail.com	https://lh6.googleusercontent.com/-x7QCVuzbCj4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcQNZDU3pn7-OX6_xaziQBsvS74Lw/s96-c/photo.jpg	101056800285643890923	\N	\N
2214	Praveen Kolakani	praveenkolakani1998@gmail.com	https://lh3.googleusercontent.com/-O0TPncsPLxI/AAAAAAAAAAI/AAAAAAAADzk/hhyespOKVQk/s96-c/photo.jpg	109266082501365237941	\N	\N
2252	Aravind Reddy Sarugari	aravindreddy08sarugari@gmail.com	https://lh3.googleusercontent.com/-5TqKukyZ8n0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNPzcrIT2nQDhCvqjaDTqX2F6_60A/s96-c/photo.jpg	103413867609203995396	\N	\N
2254	Raj Samurai @ EVP (Expert Value Pack LLP)	raj@expertvaluepack.com	https://lh6.googleusercontent.com/-M4vf3MAVzI0/AAAAAAAAAAI/AAAAAAAACP0/Qc6X7Qegy2Y/s96-c/photo.jpg	115583909410869064703	\N	\N
2265	SARUPURI DHEERAJ	16211a0337@bvrit.ac.in	https://lh4.googleusercontent.com/-crMr5Mn5tyc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNG6gdlZZ0ooqo2rtaTrHXkODmJFw/s96-c/photo.jpg	113375788251733149094	\N	\N
2380	aman verma	amanverma96.15@gmail.com	https://lh6.googleusercontent.com/-B7plUvA029c/AAAAAAAAAAI/AAAAAAAACw0/4bz0EgOIEGg/s96-c/photo.jpg	110988755828086628184	\N	276
2415	Narayanan R	narayananr@avazapp.com	https://lh5.googleusercontent.com/-a0WOYonxxu4/AAAAAAAAAAI/AAAAAAAABKs/qAXnrVRXDa4/s96-c/photo.jpg	105500817840272313799	\N	285
2277	Mohammedabdul rafeeq512	nishatsultana0138@gmail.com	https://lh6.googleusercontent.com/-1hnNYvVn8o4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO62Cfuuuf0fKJQA-snqRdkshjH0Q/s96-c/photo.jpg	115020366769667334416	\N	\N
2364	Subrahmanyam Aryasomayajula	tfsmanu@gmail.com	https://lh3.googleusercontent.com/-zwXZVBl-Jgw/AAAAAAAAAAI/AAAAAAAAABA/BUhBudF2XQQ/s96-c/photo.jpg	103319782156851133364	\N	274
2513	Prasanna Venkatesh	prasanna@fixnix.co	https://lh5.googleusercontent.com/-egom7pOHgrk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPRtiui9-xlID2p96sUEWtqIlCmvA/s96-c/photo.jpg	114839727532236749919		300
2296	Thiyagarajan C.S	mail2thiyaga@gmail.com	https://lh5.googleusercontent.com/-3738LWkHzo4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOXkv9qfCQggknc4FpT6IEXKIrOTQ/s96-c/photo.jpg	116687833430096689153	\N	275
2568	GANGA GUPTA	grguptabhu@gmail.com	https://lh6.googleusercontent.com/-a0_xW7VZ8xA/AAAAAAAAAAI/AAAAAAAAG9w/fs5zMBpU_ck/s96-c/photo.jpg	103007413487745509743	\N	287
2428	Shubhangi Rastogi	shubhangi.r@thinkphi.com	https://lh5.googleusercontent.com/-kHHY6N0wlSE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcBuAH1wRWrSaeAiJu1dZU79BhLGQ/s96-c/photo.jpg	105502414900621283479		296
2376	MANIGANDLA KARTHIK	16211a05j2@bvrit.ac.in	https://lh5.googleusercontent.com/-f6iU1f21BEk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re8hMezoCSZDTIKo0TpCC0fTki79w/s96-c/photo.jpg	106907442348505117600	\N	\N
2676	Saurabh Jain	saurabhjain2799@gmail.com	https://lh5.googleusercontent.com/-ShuQsG1kJo0/AAAAAAAAAAI/AAAAAAAAGNM/cDVsuw9I11w/s96-c/photo.jpg	107156601039704846020	\N	\N
2298	PAPPU GEETHA RANI	16wh5a0410@bvrithyderabad.edu.in	https://lh3.googleusercontent.com/-GZw2cyt73_U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPGNLkAJvzSucIidE4-PoOeTMsiOA/s96-c/photo.jpg	113035858086387927034	\N	\N
2303	Vivek Mishra	vivek.mishra@vphrase.com	https://lh4.googleusercontent.com/-5C0M5iSUyG8/AAAAAAAAAAI/AAAAAAAAACE/Xz8f72YmXrU/s96-c/photo.jpg	114537148790063843816	\N	\N
2304	Pranav Prabhakar	pranav@mistay.in	https://lh3.googleusercontent.com/-5uerjcW7oUA/AAAAAAAAAAI/AAAAAAAAAB0/x0O3-PL0r4w/s96-c/photo.jpg	103083422834575225895	\N	\N
3353	Mukund Khandelwal	mukundkhandelwal387@gmail.com	https://lh4.googleusercontent.com/-lIfx29SyK-Y/AAAAAAAAAAI/AAAAAAAAA64/vl76NErdncM/s96-c/photo.jpg	103158308128328545694	\N	\N
4556	Abhishek Tigga ee17b101	ee17b101@smail.iitm.ac.in	https://lh6.googleusercontent.com/-gDsu2xZf7EU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reHT1R1apdSoe-i-k946EYuWZrNUg/s96-c/photo.jpg	104162540670104310859	\N	\N
3027	Tapish Garg	tapishgarg0@gmail.com	https://lh5.googleusercontent.com/-zORyO3Aa-hI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcFdVYomZ1zNdT1I7HuqgDeGD8b0A/s96-c/photo.jpg	113824673222077196247	\N	\N
3034	Akshit Bagde	akshit2000.bagde@gmail.com	https://lh3.googleusercontent.com/-VpGqtlLEyIE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOs9cfLQXTGrlpsM3GcPolvoL9mXg/s96-c/photo.jpg	110540228254791393418	\N	\N
2284	Thilagar Thangaraju	thilagar.thangaraju@gmail.com	https://lh6.googleusercontent.com/-aMY57O0b6bk/AAAAAAAAAAI/AAAAAAAAAEE/Djkwp2pcCTk/s96-c/photo.jpg	108454550000095213572	\N	273
2546	Saurabh Jain	saurabhjain2702@gmail.com	https://lh4.googleusercontent.com/-v1tXSEetuRw/AAAAAAAAAAI/AAAAAAAAABw/AF3c_Gme-Hw/s96-c/photo.jpg	114818886750636854304	\N	302
2457	Priyanka Meghani	priyanka@rackbank.com	https://lh3.googleusercontent.com/-fvU6-NwPYRQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOjQ-kCeBqt0Jo42cc14_1v8RCW1g/s96-c/photo.jpg	116000450446927027712	\N	\N
2526	Seethaka Supriya	16wh1a05a1@bvrithyderabad.edu.in	https://lh4.googleusercontent.com/-LjxMnUXySeo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPNCHuBiPUPMxbaXAqpkYXkgI3wjQ/s96-c/photo.jpg	117537405273454723771	\N	\N
2458	Human Resource	hr@rackbank.com	https://lh5.googleusercontent.com/-O3HYTeIlvKQ/AAAAAAAAAAI/AAAAAAAAALI/edhKWDJL6ng/s96-c/photo.jpg	112150566284259074738	\N	280
2493	pranay muddagouni	pranaymuddagouni27@gmail.com	https://lh4.googleusercontent.com/-6Y5r7XCjw4Q/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPyc0y8awmH107feHLck-kpuq4Uvg/s96-c/photo.jpg	114268811780135391116	\N	\N
2516	Chief Nixer	shan@fixnix.co	https://lh6.googleusercontent.com/-2UJKOew9Iuk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMM_brzaJ6EK0suS4QMfUGTZ-7pYw/s96-c/photo.jpg	105791111294087052325	\N	\N
2561	Pat V	pat@myally.ai	https://lh6.googleusercontent.com/-UIWAkvzmT70/AAAAAAAAAAI/AAAAAAAACDg/rIFk3P6j73I/s96-c/photo.jpg	103765838603107363304	\N	286
2551	Ramesh Soni	rameshsoni2100@gmail.com	https://lh5.googleusercontent.com/-AnlhE4dV0ys/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPwWvjRuKaittoTz6bsc1PNY1VPIA/s96-c/photo.jpg	107266261851940045387	\N	284
2553	AIRED project	teamepet@gmail.com	https://lh3.googleusercontent.com/-ApB28oseua0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMh8DDW6017C8Di7uxyX54NcB1nUw/s96-c/photo.jpg	117045864410082434432	\N	\N
2518	David Roshan	c.davidroshan@gmail.com	https://lh6.googleusercontent.com/-hkMZYzT7r5Q/AAAAAAAAAAI/AAAAAAAAAvs/6oGX9K7l0AI/s96-c/photo.jpg	117306459721549242620	\N	281
3132	Harshit Singh	harshitsingh0123@gmail.com	https://lh3.googleusercontent.com/-gWdDs71VTuk/AAAAAAAAAAI/AAAAAAAAKhQ/7aH5ZgEz1hg/s96-c/photo.jpg	105135735319080728525	\N	\N
3242	Neeraj Jadhavar	jadhavarneeraj@gmail.com	https://lh4.googleusercontent.com/-S2D7fLT0Jwk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQONyMvFzlwZvWP6oWatk8tNwU5XhQ/s96-c/photo.jpg	101532661979094815998	\N	\N
4813	rohitth c	rohitthc123456789@gmail.com	https://lh6.googleusercontent.com/-LfwONza6Kfg/AAAAAAAAAAI/AAAAAAAAAHQ/-1N61P-AXmA/s96-c/photo.jpg	101827448437274338234	\N	\N
4868	Subhankar Chakraborty	subhankarchakraborty48@gmail.com	https://lh4.googleusercontent.com/-eDM9QFooYTo/AAAAAAAAAAI/AAAAAAAAAok/VZa4nuEJn80/s96-c/photo.jpg	101142874371716107680	\N	\N
2851	samyak jain	jsamyak39@gmail.com	https://lh3.googleusercontent.com/-IRVlAqiNknI/AAAAAAAAAAI/AAAAAAAAFFo/hTFdbvXZFRM/s96-c/photo.jpg	103656407720006034171	\N	\N
4839	Chinmay Raut	rautchinmay19@gmail.com	https://lh5.googleusercontent.com/-E2drtF1MNgs/AAAAAAAAAAI/AAAAAAAAIOQ/v-noUbfVQ9c/s96-c/photo.jpg	102312700975952431360	\N	\N
4991	Harshita Ojha bs17b012	bs17b012@smail.iitm.ac.in	https://lh5.googleusercontent.com/-c5nffVLnB2I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcHwGuXS4KLSUlO_OM7ZRelkgF5Bg/s96-c/photo.jpg	101052355478693521918	\N	\N
4832	Monika Nathawat	monikanathawat666@gmail.com	https://lh3.googleusercontent.com/-SGg1MH1lu2Y/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdNyJXs_JL_bkZZQu0Dx5DzGqEpig/s96-c/photo.jpg	101807814707039385860	\N	\N
4943	Pranav Pawar	pranavpawar3@gmail.com	https://lh4.googleusercontent.com/-c-s9-pk0ZqU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcHO4CUA4NI32rDj0Up-sEj-TbMtA/s96-c/photo.jpg	102139067499961218783	\N	\N
4913	Rutvik Baxi	rutvikbaxi@gmail.com	https://lh4.googleusercontent.com/-qD21S2sRe20/AAAAAAAAAAI/AAAAAAAAAAo/YboBpLAakk0/s96-c/photo.jpg	117005101380398480170	\N	\N
4846	T B Ramkamal ee18b153	ee18b153@smail.iitm.ac.in	https://lh5.googleusercontent.com/-6fhrQN3etyw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO1xMa8AyJ1lHlEuByXcacxz3QPPQ/s96-c/photo.jpg	106346546956435892842	\N	\N
4884	Subhankar Chakraborty	subhankarchakraborty415@gmail.com	https://lh4.googleusercontent.com/-AJUJeHaIczk/AAAAAAAAAAI/AAAAAAAAAIk/rA7Pc86hQgY/s96-c/photo.jpg	116457314552526686941	\N	\N
4874	Prajeet Oza	prajeet0810@gmail.com	https://lh6.googleusercontent.com/-z7mXYFQSydY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMznvdo8QJPoBK2GeXmEXbP_6vkew/s96-c/photo.jpg	100180464561448951684	\N	\N
4996	Mitanshu Khurana	khurana.mitanshu@gmail.com	https://lh4.googleusercontent.com/-tq1Wp8w37_Q/AAAAAAAAAAI/AAAAAAAAAWk/Lyet4XwgwQU/s96-c/photo.jpg	101452552670608521565	\N	\N
4157	Akshat Nagar	akshatnagarakioo@gmail.com	https://lh4.googleusercontent.com/-a5-koFrAuWI/AAAAAAAAAAI/AAAAAAAAABg/jJIs_3DVi-0/s96-c/photo.jpg	112955715421977386894	\N	\N
4875	Kommineni Aditya ee17b047	ee17b047@smail.iitm.ac.in	https://lh5.googleusercontent.com/-Qd4N03TfxxQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPA-WkcLd1b7qrdGO_gH_tXwQuZOw/s96-c/photo.jpg	103517082880442482622	\N	\N
4940	Siddharth Lotia	siddharthlotia04@gmail.com	https://lh3.googleusercontent.com/-QRfNeFgmI5M/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdbmAJY5vO7TN-wINqZb_SaL1JIZA/s96-c/photo.jpg	113814269201509832881	\N	\N
5059	Sree Vishnu Kumar V ed18b032	ed18b032@smail.iitm.ac.in	https://lh6.googleusercontent.com/-_dmj1I-c-tg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN15xt7o4Tz8Y76Beg7Kz5_Q1lRwQ/s96-c/photo.jpg	116987835442491396459	\N	\N
5105	Ayush Atul Toshniwal ee17b157	ee17b157@smail.iitm.ac.in	https://lh5.googleusercontent.com/-qUv43xfQuPs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcLi68vNy5BsuVVoojBjHOt86JC6w/s96-c/photo.jpg	101411725174892658523	\N	\N
4649	Thirumala ReddyManishaReddy	16wh1a05b6@bvrithyderabad.edu.in	https://lh4.googleusercontent.com/-OCf5-yzk838/AAAAAAAAAAI/AAAAAAAAACE/ed_TW_5AyEg/s96-c/photo.jpg	113501286160076496682	\N	\N
2436	E-Cell IIT Madras	pr_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-kRHk2N5_ISQ/AAAAAAAAAAI/AAAAAAAAAQQ/Pb00b9CWRhw/s96-c/photo.jpg	100680093250543498335	\N	\N
5072	Gaud Unnat ch18b004	ch18b004@smail.iitm.ac.in	https://lh4.googleusercontent.com/-dCNFZ6ZXw64/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN7cPEcNwemfZufOsqEhdfpqQyx1Q/s96-c/photo.jpg	108716062842174923272	\N	\N
5030	Harshal Raaj Patnaik	harshalraajpatnaik@gmail.com	https://lh5.googleusercontent.com/-FanCVpyjwh4/AAAAAAAAAAI/AAAAAAAAAJ0/22X6ypU_Kj4/s96-c/photo.jpg	104402072932888164460	\N	\N
4908	Divika Sanjay Agarwal ch17b043	ch17b043@smail.iitm.ac.in	https://lh6.googleusercontent.com/-8d9SKmoXN6I/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNIhNOQr309K7WRUWVGu3hQCElKuQ/s96-c/photo.jpg	102052775561051041362	\N	\N
5142	Sanjay V	cy18c038@smail.iitm.ac.in	https://lh6.googleusercontent.com/-PGg88uSrHEo/AAAAAAAAAAI/AAAAAAAAAAU/K8E7w4PjIIU/s96-c/photo.jpg	105392709235674293466	\N	\N
4915	Amrit Sharma ep18b015	ep18b015@smail.iitm.ac.in	https://lh4.googleusercontent.com/-GvZPi24Y-Q0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcqA2vINRQsxd2oljVr3KNiCpCGjw/s96-c/photo.jpg	117068008597284134843	\N	\N
4983	neel balar	neelbalar7@gmail.com	https://lh6.googleusercontent.com/-FZf73yMdHgs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOJHFqkB6m2Uw3sKQ5P3UFF4gAkow/s96-c/photo.jpg	110086250388526798686	\N	\N
4864	Amarnath Prasad ae18b001	ae18b001@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Oe5Fp-9tW2M/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdUzfTedDAEjkkIhUFBdlu_0gUZoQ/s96-c/photo.jpg	110088160541028725569	\N	\N
5098	aryan pandey	aryanp35@gmail.com	https://lh4.googleusercontent.com/-Y-QpxPMvBDM/AAAAAAAAAAI/AAAAAAAAAmE/daYKVts9Si8/s96-c/photo.jpg	104171369330644075313	\N	\N
4914	Ava Venkata Sai Kashyap ed17b026	ed17b026@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jklFt8gKaoc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfxB3vkgonLNciCMOk4VXWUr79GYw/s96-c/photo.jpg	112693133093914151701	\N	\N
5075	akriti ahuja	dhitu.ahuja@gmail.com	https://lh5.googleusercontent.com/-9EYOqnlRuMY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdlLkZhRGtCgFbmhTOh0Jg0VFqt5g/s96-c/photo.jpg	116204895236238903886	\N	\N
5133	Meesa Shivaram Prasad cs18b056	cs18b056@smail.iitm.ac.in	https://lh5.googleusercontent.com/-jtkhydQIMZ0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd1NuUSKwXrEZY7HAdHZc8r9nv26w/s96-c/photo.jpg	113583843316589152036	\N	\N
5193	Neil Ghosh me17b060	me17b060@smail.iitm.ac.in	https://lh6.googleusercontent.com/-ZtxyOPISnMk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reKGxmg0i7hMIAMHnyJ-dQ_dHZ_AA/s96-c/photo.jpg	117732606660029053405	\N	\N
5038	HARIGOVIND RAMASWAMY	hgovind98@gmail.com	https://lh6.googleusercontent.com/-vMHyCHfqhRg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcQrKVzY_T7T9paQSvkX1kITgLYHw/s96-c/photo.jpg	109528850140803698362	\N	\N
5029	Parth Keyur Doshi be17b024	be17b024@smail.iitm.ac.in	https://lh3.googleusercontent.com/-kOpGoSbb_nQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcBaK8MJI7HJ93JDS_aZWn5_12wtA/s96-c/photo.jpg	109694605773547105071	\N	\N
5114	ABHINAV AZAD	abhiazadz@gmail.com	https://lh4.googleusercontent.com/-jOcefTJxbE8/AAAAAAAAAAI/AAAAAAAANhY/ReNBiPkRme8/s96-c/photo.jpg	116474837895993246041	\N	\N
5162	Alexander David D mm17b009	mm17b009@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ET3DUr_u06I/AAAAAAAAAAI/AAAAAAAAABE/LQJ_eZ44KUk/s96-c/photo.jpg	100046381709706919563	\N	\N
5232	Pradumn Karagi be18b009	be18b009@smail.iitm.ac.in	https://lh3.googleusercontent.com/-l8-i12-EQSY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdS8_Bg13FQm2YgdrWChD9nB9Llkg/s96-c/photo.jpg	101475449072728420854	\N	\N
5208	Subhasis Patra	subhasispatra23@gmail.com	https://lh5.googleusercontent.com/-xIJPdiHHmfY/AAAAAAAAAAI/AAAAAAAAAWs/aQge91HGbbg/s96-c/photo.jpg	100174145732475175347	\N	\N
5211	PRADEEPA K 17IT	pradeepa.21it@licet.ac.in	https://lh3.googleusercontent.com/-6LqduwnNrdY/AAAAAAAAAAI/AAAAAAAAADU/8P6WIbgrtcM/s96-c/photo.jpg	104341823850477467850	\N	\N
5291	Sasidhar Reddy	sasidharv10@gmail.com	https://lh5.googleusercontent.com/-I-Ge0KyMM1Q/AAAAAAAAAAI/AAAAAAAACME/_NnP8OEiAKk/s96-c/photo.jpg	104615193672641411565	\N	\N
5509	Taher Murtaza Poonawala mm17b032	mm17b032@smail.iitm.ac.in	https://lh3.googleusercontent.com/-X5vBb_dQyDA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcGWlFKvIgVcuXoj0otNQVtqIPV2Q/s96-c/photo.jpg	117356223086180674242	\N	\N
6164	Raman Kumar	ramankumarrks3720@gmail.com	https://lh4.googleusercontent.com/-d6ePxjH95os/AAAAAAAAAAI/AAAAAAAAARo/HcOLidb0d14/s96-c/photo.jpg	100373514490827653919	\N	\N
5435	Karil Garg bs18b018	bs18b018@smail.iitm.ac.in	https://lh5.googleusercontent.com/-9WS0UvUDeB8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdr_zFdQGqMC7JrAEa3cjmRMBXYYg/s96-c/photo.jpg	114351628888398386175	\N	\N
5723	ganesh yerra	yjaiganesh99@gmail.com	https://lh5.googleusercontent.com/-8rYG9koSaG4/AAAAAAAAAAI/AAAAAAAAF0w/DKpDfWpigWs/s96-c/photo.jpg	118240680244675482931	\N	\N
5670	Davis Andherson F ED17B037	ed17b037@smail.iitm.ac.in	https://lh5.googleusercontent.com/-mLhwVFB4ou0/AAAAAAAAAAI/AAAAAAAAAS0/OvGRYaw1Xr0/s96-c/photo.jpg	107827922432577522549	\N	\N
5394	RITHIC KUMAR N RITHIC KUMAR N	coe18b044@iiitdm.ac.in	https://lh4.googleusercontent.com/-J5iqXuINTd4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOu8OVy173oph0TMipOUJRNs3eg8Q/s96-c/photo.jpg	112154048075183298220	\N	\N
5387	prashant jay	prashantjayoficial@gmail.com	https://lh4.googleusercontent.com/-NSLYIAB_190/AAAAAAAAAAI/AAAAAAAAABI/sq_uSIvbcfg/s96-c/photo.jpg	117437871277613629999	\N	\N
5378	Nathaniel Nirmal	nathanielat@gmail.com	https://lh3.googleusercontent.com/-ymDP-1KmfbM/AAAAAAAAAAI/AAAAAAAABwM/xoJ4DpMgtpo/s96-c/photo.jpg	100323225494928384224	\N	\N
5478	Niharika Srivastav	niharikas869@gmail.com	https://lh6.googleusercontent.com/-L2CkcrmW74s/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdQdzZ59DyQCp8S4gt_XIRCx872zw/s96-c/photo.jpg	115382621843699309946	\N	\N
5466	Abhranil Chakrabarti	abhranil.chakrabarti1@gmail.com	https://lh3.googleusercontent.com/-roIYc87-opQ/AAAAAAAAAAI/AAAAAAAAAV4/jjWrmfGa9Sg/s96-c/photo.jpg	105735616610991386244	\N	\N
5278	nikit bassi	nikit.bassi@gmail.com	https://lh5.googleusercontent.com/-62duocELSdQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfmWm-RCer4vudFf_tMJX4eHKZqNA/s96-c/photo.jpg	101285149807471176908	\N	\N
5944	Bablu Devisingh Sitole	oficialbsitole2812@gmail.com	https://lh5.googleusercontent.com/-e-qnpCZi-dU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reWigEwUeP91JNsonMSHtVPnU5Y1w/s96-c/photo.jpg	103702551939099288693	\N	\N
5444	Siddharth Dey me18b075	me18b075@smail.iitm.ac.in	https://lh3.googleusercontent.com/-DGkZT6huPUc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re92HMuALMx8p5xl74fsRIvDDR9bw/s96-c/photo.jpg	106478730192157907359	\N	\N
5403	Aniswar S K	bosompaddy@gmail.com	https://lh3.googleusercontent.com/-rFQ1ub0ZdfM/AAAAAAAAAAI/AAAAAAAAAxA/ersQbDPs_E0/s96-c/photo.jpg	101887063519379114033	\N	\N
5945	R J	dsanklecha.rj@gmail.com	https://lh4.googleusercontent.com/-dmbt3n7PIks/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPdOncF9I_LvT2sD3PcMe6OP4CJPg/s96-c/photo.jpg	107147930685919857188	\N	\N
5978	Sai Krishna Kota ce17b054	ce17b054@smail.iitm.ac.in	https://lh3.googleusercontent.com/-dpoumKNKFOk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc5MTzCUFAMztuXOHdeX-JkVjjhyQ/s96-c/photo.jpg	102748409040120330310	\N	\N
6117	Sriujan Harihar	sriujanh1299@gmail.com	https://lh3.googleusercontent.com/-SxDkBL-bDKs/AAAAAAAAAAI/AAAAAAAAAp8/TPJyCE12Wxc/s96-c/photo.jpg	105122427801569397480	\N	\N
5680	Nitin Chauhan	nitinchauhan771@gmail.com	https://lh6.googleusercontent.com/-W5Tecs7sz38/AAAAAAAAAAI/AAAAAAAAVso/EZpawRFt8LE/s96-c/photo.jpg	100166136587028365869	\N	\N
5428	Goutham Zampani	gouthamzampani@gmail.com	https://lh4.googleusercontent.com/-0QBKMxs4Fg0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc-3Di1eKw7D76-vO2JB6YHmCdwqg/s96-c/photo.jpg	107434291759433018037	\N	\N
5674	aayush atalkar	aayushatalkar@gmail.com	https://lh4.googleusercontent.com/-PAtzLCWQ1aI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNF7s0q3Y5UUORVxYU970E1G2lkcw/s96-c/photo.jpg	114121932947581881721	\N	\N
5898	Aditya Raj	adityarazz129@gmail.com	https://lh5.googleusercontent.com/-bS18EqXJilk/AAAAAAAAAAI/AAAAAAAAAXA/_m4aj4GC07E/s96-c/photo.jpg	111140359246612411654	\N	\N
5958	dhanush ja	dhanushja3@gmail.com	https://lh3.googleusercontent.com/-gxrcmoE4OVw/AAAAAAAAAAI/AAAAAAAAAQ0/duwJwyC6Bjc/s96-c/photo.jpg	109289325891115045173	\N	\N
5911	Avula Yashwanth Reddy me18b006	me18b006@smail.iitm.ac.in	https://lh3.googleusercontent.com/-dd-5uZG8C4E/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re0cv4JqRFW87bnUuS_FzJZs4kvKw/s96-c/photo.jpg	106540878792009138011	\N	\N
5328	Srishti Adhikary ae18b012	ae18b012@smail.iitm.ac.in	https://lh6.googleusercontent.com/-AdPd59me20w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcsbaww5oqiyDedSuN2AAsSQoT7qA/s96-c/photo.jpg	116111249617413389973	\N	\N
5659	RAM KIRAN	ramkiran432@gmail.com	https://lh6.googleusercontent.com/-8nSWboxOhaM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reFIcAk2H3JQe3SA1QEYT97sWKq2Q/s96-c/photo.jpg	111128207069265376383	\N	\N
6118	NeEl ChAnGaNi	neel1499@gmail.com	https://lh6.googleusercontent.com/-Gy7QBpvzxh4/AAAAAAAAAAI/AAAAAAAAABs/dtetrteU8eY/s96-c/photo.jpg	114360394443508391157	\N	\N
6090	Varun Choudhary	varunrolaniya.vc@gmail.com	https://lh6.googleusercontent.com/-e4lfeESvOFw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNrTHqy0Oy9i0svsBbj_7UVvC514A/s96-c/photo.jpg	110606774466678924370	\N	\N
6213	Rohit Mahendran	rohitmahendran@gmail.com	https://lh5.googleusercontent.com/-vGPeoOFuQoo/AAAAAAAAAAI/AAAAAAAAAPo/hqxeLPhzWmg/s96-c/photo.jpg	108773897194648952785	\N	\N
6147	Sunanda Somwase	sunandasomwase@gmail.com	https://lh4.googleusercontent.com/-nDRIiVkPZ88/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reecCqn37LKZwx48xSzlrK1HRw0Zg/s96-c/photo.jpg	102269853381680672389	\N	\N
6222	Dhawal Samel	dhawalsamel99@gmail.com	https://lh3.googleusercontent.com/-6tWTsrPqtE4/AAAAAAAAAAI/AAAAAAAAAVM/K-UL86kvC0w/s96-c/photo.jpg	100870213224601082705	\N	\N
6231	shreyas shandilya	shandilya.shreyas@gmail.com	https://lh5.googleusercontent.com/-O-c993EAvuk/AAAAAAAAAAI/AAAAAAAAK8I/-q41nQXlsXg/s96-c/photo.jpg	114840229803252179382	\N	\N
5954	Devraj Babeli	me15b100@smail.iitm.ac.in	https://lh3.googleusercontent.com/-XPedVL3wdQM/AAAAAAAAAAI/AAAAAAAAAd0/gqSBy9g0pSU/s96-c/photo.jpg	107413706842790560056	\N	\N
6472	Ameya Ainchwar	ameya.potter7@gmail.com	https://lh6.googleusercontent.com/-UleH8WwJ_FI/AAAAAAAAAAI/AAAAAAAAPjs/La-VSOjF_l4/s96-c/photo.jpg	101633193710942170825	\N	\N
8318	Srihari K.S	kssrihari2000@gmail.com	https://lh3.googleusercontent.com/-LRbMeiuiYQs/AAAAAAAAAAI/AAAAAAAAYqU/2sZt1sqdRYw/s96-c/photo.jpg	101719078540936693965	\N	\N
4990	Sourabh Thakur	sourabhthakurbhl@gmail.com	https://lh3.googleusercontent.com/-XpAH7WAp6ik/AAAAAAAAAAI/AAAAAAAAMFo/4C-uSLzfkKY/s96-c/photo.jpg	108046082470898711935	\N	\N
6057	kandra pavan	kandrapavan@gmail.com	https://lh5.googleusercontent.com/-KbpmNa6iyVE/AAAAAAAAAAI/AAAAAAAAAsE/KQxfLd52zzw/s96-c/photo.jpg	107301028745384927900	\N	\N
6234	Uppalapati Nithin Chowdary ee18b035	ee18b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-usXS_ub7LAI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf-_XhmyrwPtkFAxYd9O_H5izyilQ/s96-c/photo.jpg	108848347453031165545	\N	\N
6241	Hunch D	rkarjun02052001@gmail.com	https://lh6.googleusercontent.com/-QuRR6JKVHlo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdBYVajPz0cwR7JVhnUbIhoovZWIQ/s96-c/photo.jpg	114704333810864603254	\N	\N
6258	SIDDHARTH J P na16b118	na16b118@smail.iitm.ac.in	https://lh3.googleusercontent.com/-DouPxSl6YaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPqmecnxwZVnNs9SlY58IZWJ4AvPg/s96-c/photo.jpg	108536031230585647935	\N	\N
6281	K Vamshi Krishna me18m039	me18m039@smail.iitm.ac.in	https://lh4.googleusercontent.com/-9YbdNsTCJ60/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcwcFq4fz1f2qH3-fPs39YlgeSKzw/s96-c/photo.jpg	112872968935980064890	\N	\N
6512	Kunuku Naga Sai ch18b053	ch18b053@smail.iitm.ac.in	https://lh4.googleusercontent.com/-2h7VWoPyDR0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOhXKurs3v3Bsdz_WrdC8gEXTGldg/s96-c/photo.jpg	112870414950478249881	\N	\N
6444	Viswanath Tadi cs18b047	cs18b047@smail.iitm.ac.in	https://lh5.googleusercontent.com/-DMfm2MkCfho/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcY1vmtBzMCbjCmfLTQOY51kB9Tbg/s96-c/photo.jpg	110408636199196777944	\N	\N
6519	Aditya Parag Rindani me18b037	me18b037@smail.iitm.ac.in	https://lh3.googleusercontent.com/-zO-AbVfG4cE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfUJDsHFlrNzXlwXDK6tzxukmy5bQ/s96-c/photo.jpg	108210163016263470552	\N	\N
6666	Chamakura Suraj Reddy bs18b015	bs18b015@smail.iitm.ac.in	https://lh4.googleusercontent.com/-c1x2jyRfMNk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNasrqNFuMW6FCh_iB4Xco1bmLgQw/s96-c/photo.jpg	115339962081142646939	\N	\N
7036	Sai Bharadwaj Avvari	saibharadwajavvari9@gmail.com	https://lh6.googleusercontent.com/-4dF13U_ujpA/AAAAAAAAAAI/AAAAAAAAAMc/P7UrFwIbjFU/s96-c/photo.jpg	116528854078263730275	\N	\N
6370	Shashwath Sargovi Bacha	shashwathsb1998@gmail.com	https://lh3.googleusercontent.com/-_xVPHJdztUM/AAAAAAAAAAI/AAAAAAAAAFQ/_V310an66qc/s96-c/photo.jpg	100006462132328751764	\N	\N
6453	Shubham Jain	shubham.sj2310@gmail.com	https://lh3.googleusercontent.com/-Z5VTOMhMqYQ/AAAAAAAAAAI/AAAAAAAALGE/-9cAtTbNomk/s96-c/photo.jpg	101398156657528003471	\N	\N
6365	Bharat Jam	bharatwrrr@gmail.com	https://lh4.googleusercontent.com/-6CU1RytlxV8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reNsL3VLzLlupISRLhNyCvfvS2rrQ/s96-c/photo.jpg	100629454340115098641	\N	\N
6814	Sidhartha Narayan	sidharthanarayan.s@gmail.com	https://lh4.googleusercontent.com/-so5mziAyzcU/AAAAAAAAAAI/AAAAAAAAZOc/O8KHs-mVe9M/s96-c/photo.jpg	110757805238250702422	\N	\N
6618	mokshagna saiteja	mokshagnasaiteja517@gmail.com	https://lh5.googleusercontent.com/-sxETCjv_rc0/AAAAAAAAAAI/AAAAAAAAABs/UFB94FA5u9Q/s96-c/photo.jpg	103923783699459229771	\N	\N
6441	Mitte Siddartha Sai cs18b028	cs18b028@smail.iitm.ac.in	https://lh3.googleusercontent.com/-gAuG_6Cn1Rc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rej1XxD6GXemNqI_LHp0OfVqsbRAg/s96-c/photo.jpg	105001332348729167995	\N	\N
6801	S Sidhartha Narayan ep18b030	ep18b030@smail.iitm.ac.in	https://lh3.googleusercontent.com/-HsNOVDVgwvk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdF5JqiIsPW_GmFruDskzUtanmwQw/s96-c/photo.jpg	112857156281300752937	\N	\N
6306	Sikhakollu Venkata Pavan Sumanth ee18b064	ee18b064@smail.iitm.ac.in	https://lh4.googleusercontent.com/-dVwuWsgAZWg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNpcIcwOBcM4ZyGlitMYI1BZbIuCA/s96-c/photo.jpg	105534379261061050947	\N	\N
6489	Adriza Mishra bs18b013	bs18b013@smail.iitm.ac.in	https://lh4.googleusercontent.com/-B19uHcTDDc4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc64v6hcBaAuQBMTi3l82QXyISQBA/s96-c/photo.jpg	116428881593753626712	\N	\N
6704	Guna Sekhar	gunasekharggs14@gmail.com	https://lh6.googleusercontent.com/-pBeI-V22RMU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdVVquFhvfrnVj8fJZViN9n96OvOw/s96-c/photo.jpg	117479216273329852537	\N	\N
6683	POULOMI KHA bs16b026	bs16b026@smail.iitm.ac.in	https://lh3.googleusercontent.com/-YeAmKTVM9Rw/AAAAAAAAAAI/AAAAAAAAA30/vd-JmgyTj-I/s96-c/photo.jpg	104863773335365538808	\N	\N
6532	Mamata L V	mamatalvaddodagi@gmail.com	https://lh4.googleusercontent.com/-XWvrug97U6A/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdX-t4mhmXX61HXYi_k6jtrSdyrMg/s96-c/photo.jpg	109157931691641267125	\N	\N
6399	Yuvraj Singh	yuvraj7345@gmail.com	https://lh3.googleusercontent.com/-bz-E2Ngeooc/AAAAAAAAAAI/AAAAAAAAAAU/mi8roXort4Q/s96-c/photo.jpg	101491417144470081112	\N	\N
6896	anshul suryan	anshulsuryan97@gmail.com	https://lh3.googleusercontent.com/-Xq4roz07ZWg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfQaAChmDeptn2FSs2lOE6YKT2nXg/s96-c/photo.jpg	117968929471255721604	\N	\N
7024	SALURU DURGA SANDEEP me16b125	me16b125@smail.iitm.ac.in	https://lh3.googleusercontent.com/-mB1r98QB9IE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdP4pP2McVieZa9NSOaeRW6jTs3XQ/s96-c/photo.jpg	106053419849481655127	\N	\N
6857	SHUBHAM MAURYA	subhamrawjnv@gmail.com	https://lh6.googleusercontent.com/-6k5Fi9dULQs/AAAAAAAAAAI/AAAAAAAAAKo/QX7r2Oqt8js/s96-c/photo.jpg	112472980945916590575	\N	\N
6649	Mansi Choudhary ee17b053	ee17b053@smail.iitm.ac.in	https://lh5.googleusercontent.com/-s3N_q5PaKeU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reVwpDnvWrp9OraMT13GqhBf56ZoQ/s96-c/photo.jpg	115248078929890303214	\N	\N
6547	Vishnu Kiran	nv.vishnukiran00@gmail.com	https://lh5.googleusercontent.com/-Kf5jJ4450rw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPUWcGHHRZJGXJz3Gv5ZbpruWNWhg/s96-c/photo.jpg	113681390068745417997	\N	\N
6554	Varad Joshi me17b038	me17b038@smail.iitm.ac.in	https://lh3.googleusercontent.com/-H_qvYxefJPQ/AAAAAAAAAAI/AAAAAAAAAmI/hUieBJ5GaIw/s96-c/photo.jpg	117966690353831815134	\N	\N
6907	Rudram Piplad	ed16b024@smail.iitm.ac.in	https://lh5.googleusercontent.com/-JsSkNLQv5b0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNJgq-FiEjRZFmBSVzvbxQv2m_DuA/s96-c/photo.jpg	113712306728446985892	\N	\N
6940	Gude Sai Ganesh me17b012	me17b012@smail.iitm.ac.in	https://lh4.googleusercontent.com/-6yRWmv1xvNc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfBKq7a73WNCSZrFaRMxjy1GzYJrQ/s96-c/photo.jpg	113538741896053160350	\N	\N
6944	korrayi jagadeesh	korrayijagadeesh21@gmail.com	https://lh6.googleusercontent.com/-_mrZqzQd4mo/AAAAAAAAAAI/AAAAAAAAABA/998ggPcctuU/s96-c/photo.jpg	107456246453619734809	\N	\N
6927	Buddhavarapu Venkata Surya Sudheendra cs18b006	cs18b006@smail.iitm.ac.in	https://lh3.googleusercontent.com/-3ngH0fhM4d8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfgPvEe-ACorJU_02b412eXArYDZg/s96-c/photo.jpg	101180110198873131231	\N	\N
6377	Vasavi Gandham	vasavi.g71@gmail.com	https://lh4.googleusercontent.com/-xAPDnwsSUnU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re9oBS-q2Bihfmj9pDOuJtmEHp-ag/s96-c/photo.jpg	107726028519801979477	\N	\N
6695	Akilesh Kannan	akileshkannan@gmail.com	https://lh5.googleusercontent.com/-Xx9oQvzko-0/AAAAAAAAAAI/AAAAAAAABA0/jAh2eA2LZUU/s96-c/photo.jpg	107177554755735141269	\N	\N
6943	Dhruvjyoti Bagadthey ee17b156	ee17b156@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jHuUleOlxiM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd9LWSE6jSykxc41lfHXg0I6RyY2Q/s96-c/photo.jpg	114093894912804568558	\N	\N
7029	Krishna Gopal Sharma cs18b021	cs18b021@smail.iitm.ac.in	https://lh3.googleusercontent.com/-oidk_duqK0s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM9aJgrIeEq_kCB4TFCD8YQIYHL9w/s96-c/photo.jpg	114582343462323173676	\N	\N
6979	Kashish Kumar ce17m079	ce17m079@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ktOrBJNZQvk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPfFUEWysnZrzf_iurJXacXoW7qGQ/s96-c/photo.jpg	108551370712006348201	\N	\N
5241	Rishabh shah	shahrishabh14@gmail.com	https://lh4.googleusercontent.com/-J6r_OnRj4nQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN4E8D9yCTWPa6Kiq0g2n1uI8tPYw/s96-c/photo.jpg	106447284908872676152	\N	\N
7065	PEDAPUDI JASHWANTH SATYA SRINIVAS ee15b049	ee15b049@smail.iitm.ac.in	https://lh3.googleusercontent.com/-acrqHVbLY8g/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfXJD6L6AWVdZNsmMhLyNwbMaPi4Q/s96-c/photo.jpg	102663222527337708902	\N	\N
6686	Jonathan Ve Vance ed17b014	ed17b014@smail.iitm.ac.in	https://lh3.googleusercontent.com/-NPsYUXAHceA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf_Kz5g1zMSRFZQMuny9JiEUVzsKw/s96-c/photo.jpg	101927668361428071197	\N	\N
7418	Bala Sundar	balasundar333@gmail.com	https://lh4.googleusercontent.com/-UQ9tUxZCGL8/AAAAAAAAAAI/AAAAAAAAAP8/P1FRzWK-gY4/s96-c/photo.jpg	114885547058071668870	\N	\N
7380	Basu Jindal	bjbasujindal@gmail.com	https://lh6.googleusercontent.com/-zfvcbsOx6T0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdULr2Gdo_O_zuoNhdng_m2obAHtQ/s96-c/photo.jpg	115215758125593906638	\N	\N
7381	DEDDY JOBSON ee15b125	ee15b125@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7Qx4HCSpCAI/AAAAAAAAAAI/AAAAAAAAAHo/natt2vX9a1U/s96-c/photo.jpg	106538374742209182977	\N	\N
7392	Ravi Gupta	ravi.gupta2323@gmail.com	https://lh6.googleusercontent.com/-6Hxoca7nEno/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMkfeXYpDiZBMNN82r2ByV4sxlWIQ/s96-c/photo.jpg	114574453579413335824	\N	\N
7393	Neha Swaminathan be18b008	be18b008@smail.iitm.ac.in	https://lh3.googleusercontent.com/-PqKloPMPwVI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reJ26RZDrW9SaZapWYhiciteawRsg/s96-c/photo.jpg	109557453092405104728	\N	\N
7284	Ranjith Ramamurthy Tevnan ee18b146	ee18b146@smail.iitm.ac.in	https://lh4.googleusercontent.com/-7ZO6Q0Ip8ko/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPC_8D4D_FYGf3JaUroHKfkXZRKsg/s96-c/photo.jpg	106891091144539984258	\N	\N
7143	Ramanan S ee18b145	ee18b145@smail.iitm.ac.in	https://lh6.googleusercontent.com/-SE_9T4cTlwU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf8Tw6QhdxpcDGflq8pCQY5nV0kmg/s96-c/photo.jpg	113597979260889639153	\N	\N
7212	KUMUD MITTAL ed16b043	ed16b043@smail.iitm.ac.in	https://lh6.googleusercontent.com/-Al2Yk_O-s0U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO5Q3cl4yCLNKOTsT3Rvxq95-2P6A/s96-c/photo.jpg	114748309222522139021	\N	\N
7190	KORRAPATI HANUMATH PRANAV BHARADWAJ ee16b112	ee16b112@smail.iitm.ac.in	https://lh3.googleusercontent.com/-O6Cy_eqXAO0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOZVS9R3JjMh6oZmDYzkaJG4sbnQA/s96-c/photo.jpg	116481244449985283889	\N	\N
7059	Krishna Tejaswi	krishnatejaswi99@gmail.com	https://lh4.googleusercontent.com/-rkMflFZKiMc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNZluJCgdjWUuLxNSetxKyhQnOk3g/s96-c/photo.jpg	107198149074547760918	\N	\N
7423	Sanjeed I	msanjeed5@gmail.com	https://lh6.googleusercontent.com/-GeU8go3JMM0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOjqylnoYLi5-lM8_kOZDVXJFlLsw/s96-c/photo.jpg	103398500054194363991	\N	\N
7326	Kaivalya Rakesh Chitre me17b018	me17b018@smail.iitm.ac.in	https://lh5.googleusercontent.com/-HMymrdbPt6k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reOavk5r7A4tzKK_cOi9gvcQTwmKw/s96-c/photo.jpg	109121374241590014827	\N	\N
7147	ANURAG HARSH	anuragharsh113@gmail.com	https://lh4.googleusercontent.com/--1ov1G4BYbM/AAAAAAAAAAI/AAAAAAAAAxw/nOs9KlOBWMs/s96-c/photo.jpg	117764114579954744999	\N	\N
7329	Sarath B	sbsrth@gmail.com	https://lh5.googleusercontent.com/-kLLfbh_ONrM/AAAAAAAAAAI/AAAAAAAAALo/5KkV-AbgMJw/s96-c/photo.jpg	117692580625665353891	\N	\N
7125	Avasarala Krishna Koustubha me18b126	me18b126@smail.iitm.ac.in	https://lh3.googleusercontent.com/-HdCs4z3TVr4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZR1u6YDvLGzRYoXDVNxyqE1Rq4Q/s96-c/photo.jpg	100444374512123718431	\N	\N
7588	Jebby Arulson ae17b028	ae17b028@smail.iitm.ac.in	https://lh6.googleusercontent.com/-L-W9GD42pbU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdYgE4NRKcaqxiZgLBK6t0WDijg_w/s96-c/photo.jpg	116837958596212598480	\N	\N
7269	sameer kumar	sameere997@gmail.com	https://lh5.googleusercontent.com/-R_3csDSKFtI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP7PHxnbdDAMbkSvgAQmfxPWQu-pg/s96-c/photo.jpg	114369799590663114921	\N	\N
7280	M LAKSHNA ed16b044	ed16b044@smail.iitm.ac.in	https://lh4.googleusercontent.com/-mh5J9bUOdKg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc0nGgSC1WCvHRK2HumFR1BPMGjYA/s96-c/photo.jpg	101307535630091801474	\N	\N
7451	Mohammed Sanjeed ed17b047	ed17b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-0sb1zcB8oHc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reMPm72AojJofvgadlZkatWcyDcLg/s96-c/photo.jpg	114326744260308541754	\N	\N
7399	Basu Jindal me18b008	me18b008@smail.iitm.ac.in	https://lh3.googleusercontent.com/-og-fhCxe3Ls/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc9UW_AN1EMfVPO_6KKZ_lNqFPdlw/s96-c/photo.jpg	111640459531281754733	\N	\N
7609	Skanda Swaroop	swaroopskanda98@gmail.com	https://lh3.googleusercontent.com/-PlpvuNNnuX0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re90AtRKlaRmyNBlKHI7CuHl855bA/s96-c/photo.jpg	114591124276679160265	\N	\N
7335	Anooj Gandham	anoojchill@gmail.com	https://lh6.googleusercontent.com/-0dkBZQMFuYM/AAAAAAAAAAI/AAAAAAAAA88/LF85C58Zbzg/s96-c/photo.jpg	105187746276593629594	\N	\N
7480	Shubham Kanekar	kanekarsk@gmail.com	https://lh3.googleusercontent.com/-0LpaPsYZ-PI/AAAAAAAAAAI/AAAAAAAABZg/5Yg8TEu49AQ/s96-c/photo.jpg	117310687405189973052	\N	\N
7561	SAYE SHARAN me16b177	me16b177@smail.iitm.ac.in	https://lh5.googleusercontent.com/-nYFpmev0Fxs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reh3BoXm-oiQ9SiHxRcyr41dwKFJQ/s96-c/photo.jpg	114591386611984022174	\N	\N
7642	nithish satya sai	nithishlonglast999@gmail.com	https://lh3.googleusercontent.com/-jc4w88zllWg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP0if9fhEGhyg0HZCxN8Revwk4EIQ/s96-c/photo.jpg	105433782240224469335	\N	\N
7493	Faraz Farooqui	farazfarooqui08@gmail.com	https://lh5.googleusercontent.com/-wM26vIRq5Sw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQODy_u8hooQwFcMakf4ipFJBQoSSg/s96-c/photo.jpg	104425878332120909243	\N	\N
7516	YOGAEESHWAR SURIYANARAYANAN	yogaganapathy.suri@gmail.com	https://lh6.googleusercontent.com/-W3uZxmW7c24/AAAAAAAAAAI/AAAAAAAAAE0/8H70esPHzJs/s96-c/photo.jpg	109098813558670849559	\N	\N
5622	Bandela Gagan Sreevastav Reddy ee17b042	ee17b042@smail.iitm.ac.in	https://lh4.googleusercontent.com/-959eKkwt2NM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reyt3P-MMpIiPuoo3tjJURkOXlazw/s96-c/photo.jpg	107489933466838356493	\N	\N
7440	DEVANSH SINGH	devanshsingh110@gmail.com	https://lh6.googleusercontent.com/-U5QsPqVYjYs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rePkVpm1Ifqm1XBCE7xYyByQ0LNiA/s96-c/photo.jpg	111567725646650165125	\N	\N
6924	Utkarsh Mishra	utkarshm065@gmail.com	https://lh3.googleusercontent.com/-s4ssEPvnRDs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3revqoUaQ5k4ymlR3Qn2tBblTsfsxw/s96-c/photo.jpg	113529269457401139010	\N	\N
7394	Indraneel Chavhan	indraneelchavhan@gmail.com	https://lh3.googleusercontent.com/-We92GF5Q74w/AAAAAAAAAAI/AAAAAAAAAFE/Nj5xcGLfojs/s96-c/photo.jpg	102187519138824292606	\N	\N
7050	Nitesh Padidam	niteshpadidam@gmail.com	https://lh5.googleusercontent.com/-MAdvxId8Ewc/AAAAAAAAAAI/AAAAAAAAAAk/7raQQuE3jQI/s96-c/photo.jpg	103273107959465057265	\N	\N
7866	Sirusala Niranth Sai 4-Yr B.Tech. Electronics Engg., IIT(BHU), Varanasi	sirusalansai.ece18@itbhu.ac.in	https://lh3.googleusercontent.com/-0yRav1sEYko/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcNwoJn2HvGkvilQjIy-yjv1BhJNA/s96-c/photo.jpg	100341530229780615772	\N	\N
8003	me17b141@smail.iitm.ac.in	me17b141@smail.iitm.ac.in	https://lh3.googleusercontent.com/--AV2_-gVVN8/AAAAAAAAAAI/AAAAAAAAAAA/N2OrThJ44H4/s96-c/photo.jpg	105620503580613926309	\N	\N
8201	Denish Dhanji Vaid ee17b159	ee17b159@smail.iitm.ac.in	https://lh3.googleusercontent.com/-1fyQqfKNPR8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdLLsyP-SuHXwaGfg4pXLld5Roh9Q/s96-c/photo.jpg	100967102642433990682	\N	\N
8181	Srijan Upadhyay	srijanupadhyay99@gmail.com	https://lh6.googleusercontent.com/-P-JchJLmNPI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcIMsaDgFNXDsHr0tHZf_5VWlFjYg/s96-c/photo.jpg	117773863857662055608	\N	\N
8044	Vihaan Akshaay Rajendiran me17b171	me17b171@smail.iitm.ac.in	https://lh6.googleusercontent.com/-RNX9t11Tydc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOxiVAQQpEwR1N6SRDrhwCW_nRC9g/s96-c/photo.jpg	113464349539753011433	\N	\N
7801	K Sushma ed17b016	ed17b016@smail.iitm.ac.in	https://lh4.googleusercontent.com/-r8SS599iPuE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcFqW9oqkS39zOXzK6lzsDrlkg5mA/s96-c/photo.jpg	115039944234930695540	\N	\N
7861	Aaysha Anser Babu ae18b014	ae18b014@smail.iitm.ac.in	https://lh6.googleusercontent.com/-fVq9qXloLsg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNc2oYwZb3vDTTAqEV-jEQOFK21UQ/s96-c/photo.jpg	110931047755608602680	\N	\N
8027	Bhashwar Ghosh	bhashwarghosh@gmail.com	https://lh3.googleusercontent.com/-6W1vF0ti_GQ/AAAAAAAAAAI/AAAAAAAAAB0/wsCbh46dp4E/s96-c/photo.jpg	105506572235545868243	\N	\N
8220	PARAG GOYAL	ae16b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-P-RSRDcDxtY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMZCKaZurGONwGlYnj9avQv1L2gqg/s96-c/photo.jpg	104237264283215661649	\N	\N
7796	Krishnakanth R ee17b015	ee17b015@smail.iitm.ac.in	https://lh3.googleusercontent.com/-0fDCB9yt1j4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd_C-As2fdezWkg4rszg9cVPS14pA/s96-c/photo.jpg	102658268322549131527	\N	\N
7717	sowjanya vemuri	sowjanyavemuri1997@gmail.com	https://lh5.googleusercontent.com/-sbb7DAEiljw/AAAAAAAAAAI/AAAAAAAACLY/hGM-8cVatfc/s96-c/photo.jpg	112565833256553704360	\N	\N
7787	Harshitha Mothukuri	harshithamothukuri413@gmail.com	https://lh6.googleusercontent.com/-P5Nnc5JyHno/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNqDL_dlsJG1HL-kdaxx6aahAjDew/s96-c/photo.jpg	114740917522394709774	\N	\N
7680	Ra Keerthan ch17b078	ch17b078@smail.iitm.ac.in	https://lh4.googleusercontent.com/-JljkvCHWnaI/AAAAAAAAAAI/AAAAAAAAAAo/2OeqFal404A/s96-c/photo.jpg	118406601333681717065	\N	\N
7802	Omender Mina mm18b025	mm18b025@smail.iitm.ac.in	https://lh6.googleusercontent.com/-Cp7iG2z6gBk/AAAAAAAAAAI/AAAAAAAAAEw/Zf4mj3QsQ1w/s96-c/photo.jpg	104220784359784029268	\N	\N
8190	Vaid Denish	vaiddenish11@gmail.com	https://lh6.googleusercontent.com/-ruFTICaH5N8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfjAUEzurzM8IDLBtO0qwgEPzE_mw/s96-c/photo.jpg	108947651890682672904	\N	\N
8056	Rajas Milind Neve me17b062	me17b062@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ktatzZu8lA4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcJxzTRPxVWlrXvEfqTgSAjPeWWcg/s96-c/photo.jpg	115420891548775866632	\N	\N
7915	AbhI ShAh	abhishah4001@gmail.com	https://lh6.googleusercontent.com/-vf5DaTWZJ30/AAAAAAAAAAI/AAAAAAAANbs/LmpkCztFSsE/s96-c/photo.jpg	109441309750837717539	\N	\N
8049	Karthik Bachu me17b053	me17b053@smail.iitm.ac.in	https://lh4.googleusercontent.com/-5ajiEhWpvJQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMTcnG-Hv1TRyBAU3j6DgocyRod2Q/s96-c/photo.jpg	112203812328864098110	\N	\N
8063	ROHIT JEJANI ae15b035	ae15b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-3lFxJtqBbrE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reZipgHFmQzy8WGfuNgm2uH-3FwLA/s96-c/photo.jpg	106335102413062346097	\N	\N
8106	Nishant Patil	nishant.jnv@gmail.com	https://lh5.googleusercontent.com/-IA0WnDKdFR4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOKN2VtXZ9UZ2W_TnKcfgUtCb2h6w/s96-c/photo.jpg	100427482293316682936	\N	\N
8260	Sidharth Areeparambath	sidhartharamana@gmail.com	https://lh3.googleusercontent.com/-8Sl6agNpC6s/AAAAAAAAAAI/AAAAAAAABUc/lrHzg_2z2II/s96-c/photo.jpg	111983544338321266182	\N	\N
7942	Souridas A	souridas510@gmail.com	https://lh3.googleusercontent.com/-JlB331yuU5E/AAAAAAAAAAI/AAAAAAAAACU/F6qoSu3NBD8/s96-c/photo.jpg	106596281639246034885	\N	\N
7112	S Viknesh ee17b073	ee17b073@smail.iitm.ac.in	https://lh6.googleusercontent.com/-afIiwMSPDZQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZ6e5NfEX_I3yktqcu-yMKLF-nFg/s96-c/photo.jpg	111066027705891320913	\N	\N
8121	Sourav Hemachandran	souravhemachandhran@gmail.com	https://lh4.googleusercontent.com/-v45s8W0QLwo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMQL6mh3hLVUlMGvcfVDv0Xj1-wIw/s96-c/photo.jpg	117368038713753317104	\N	\N
8234	Aditya Balachander ee18b101	ee18b101@smail.iitm.ac.in	https://lh4.googleusercontent.com/--KrZaB5IKS8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdlVjGevDF-7KaJAbmZk9O95icFCw/s96-c/photo.jpg	116189371214953919032	\N	\N
7852	Unman Uday Nibandhe me18b035	me18b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-fFwjeNNH2ys/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNr80E_wqcwldM9z83sfzAfIOrRRA/s96-c/photo.jpg	107393448684071128659	\N	\N
8223	avasarala koustubha	ak.koustu@gmail.com	https://lh5.googleusercontent.com/-yJ0duaPAojQ/AAAAAAAAAAI/AAAAAAAAEs4/2fY5J8mPcbc/s96-c/photo.jpg	104063535906637928892	\N	\N
8249	Turkesh pote	turkeshpote@gmail.com	https://lh6.googleusercontent.com/-I9yD13rzt38/AAAAAAAAAAI/AAAAAAAABDY/5r-RWQ_Aw_U/s96-c/photo.jpg	108345004535686987028	\N	\N
8224	Bondala Sushwath ed17b036	ed17b036@smail.iitm.ac.in	https://lh3.googleusercontent.com/-oX3JBfX87yE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNAWMfGnxlihk-HeaXRYjImoX5XLA/s96-c/photo.jpg	102330392737983603678	\N	\N
8299	Vikas Singh	singhvikas086@gmail.com	https://lh6.googleusercontent.com/-8xe5iE_R7fQ/AAAAAAAAAAI/AAAAAAAAAOQ/Bi2YIRMFJnc/s96-c/photo.jpg	100317160726643486440	\N	\N
8124	Mohil Chaudhari	mohilchau@gmail.com	https://lh5.googleusercontent.com/-u0RDuDIcDhg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNvWj0CsN6aku6CcrWxsIcFX0h8qQ/s96-c/photo.jpg	104564285080152210085	\N	\N
4859	Aditya Rindani	aditya0070.ar@gmail.com	https://lh6.googleusercontent.com/-o8s0hrFYnls/AAAAAAAAAAI/AAAAAAAAD-8/omW82l_PGsM/s96-c/photo.jpg	106151943570612705662	\N	\N
8344	Guntupalli Sai Vinay ce17b019	ce17b019@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Se9Tqka4hTA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdVOyUkPrWKiex_oqERfcS716e-9g/s96-c/photo.jpg	113236801941654391084	\N	\N
7643	Yash Goyal ed17b057	ed17b057@smail.iitm.ac.in	https://lh4.googleusercontent.com/-oTFf4qJlayk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM9YqcbaUxgSTPddjHUSm2tXxwCEQ/s96-c/photo.jpg	109614878105074181482	\N	\N
8359	Shahan Mohammadi	shahanmohammadi@gmail.com	https://lh5.googleusercontent.com/-wASUxoal3Wo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3refr2_QPPun4eGQeh4M8gkNH4wUuA/s96-c/photo.jpg	116369894268542139381	\N	\N
8396	ABHISHEK SINGH	abskbdl@gmail.com	https://lh3.googleusercontent.com/-24I0ev7NNJY/AAAAAAAAAAI/AAAAAAAAAew/BoKlVquHNyA/s96-c/photo.jpg	114218010316466093767	\N	\N
8423	Sambit Tarai	sambitarai17@gmail.com	https://lh4.googleusercontent.com/-5D-HRoarg3E/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNkgIKv1myEiFSpWQfSS4L4Gcbvjw/s96-c/photo.jpg	104003420105956436392	\N	\N
7334	E Sameer Kumar me17b048	me17b048@smail.iitm.ac.in	https://lh5.googleusercontent.com/-uGFDGwEGQgs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdEGfGqcLK2ut8FGmfZEQWkvh-BVw/s96-c/photo.jpg	115801243251886489865	\N	\N
8830	BOBBA TEJASWARA REDDY ae16b104	ae16b104@smail.iitm.ac.in	https://lh3.googleusercontent.com/-U0MQGk3rznY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdNU36DRZOrszNqxpVsx6GouGJI_A/s96-c/photo.jpg	109432364385136243098	\N	\N
8967	abhishek bakolia	abhishekbakolia22@gmail.com	https://lh5.googleusercontent.com/-VerhyeVZvaE/AAAAAAAAAAI/AAAAAAAAAAo/FkFwJOOqQMQ/s96-c/photo.jpg	110283615455900532725	\N	\N
8718	venkatesh kataraki	venkataraki@gmail.com	https://lh6.googleusercontent.com/-rBDawQwfFyM/AAAAAAAAAAI/AAAAAAAAAB8/xv2PalE1KYk/s96-c/photo.jpg	109583020944427160732	\N	\N
8795	dhanveer raj	dhanveer1512raj@gmail.com	https://lh6.googleusercontent.com/-nBpG8alNIrY/AAAAAAAAAAI/AAAAAAAAAR4/INrH13lUYOQ/s96-c/photo.jpg	102006920462605638334	\N	\N
8535	Lohitha Chowdary	lohithaalaparthi@gmail.com	https://lh5.googleusercontent.com/-rKXS1Ao7YUs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNQycoVOke1FSH_I7eSo2-zoCrYQw/s96-c/photo.jpg	101171591693354500761	\N	\N
9059	Vallabi A hs18h042	hs18h042@smail.iitm.ac.in	https://lh3.googleusercontent.com/-yaM9-Jfumu4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcIlDB15tD2bFaGsLNrqJEFdV0GCA/s96-c/photo.jpg	107870943386419228789	\N	\N
8582	Ahad Modak	ahadmodak786@gmail.com	https://lh4.googleusercontent.com/-8mFKAab6fyQ/AAAAAAAAAAI/AAAAAAAANXU/-tdiBNEaeoE/s96-c/photo.jpg	106653443315295232533	\N	\N
8729	Chinmay Kulkarni	chindiksal@gmail.com	https://lh6.googleusercontent.com/-yZ-gpujkMFI/AAAAAAAAAAI/AAAAAAAAABE/udF1BYMvYFI/s96-c/photo.jpg	104547213757131706346	\N	\N
8770	Ravi Krishnan	ravikrishnan3@gmail.com	https://lh5.googleusercontent.com/-1wk4Y9KJhL0/AAAAAAAAAAI/AAAAAAAAAMk/AqAfELmA3wM/s96-c/photo.jpg	111873789583675808617	\N	\N
8337	MOHAMMED KHANDWAWALA ee16b117	ee16b117@smail.iitm.ac.in	https://lh3.googleusercontent.com/-7zf3vM31Gfo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re0eDk07gw6EaKUr0Y5Xmb3QbOu6w/s96-c/photo.jpg	118244727025742575334	\N	\N
8591	Abhimanyu Swaroop mm17b008	mm17b008@smail.iitm.ac.in	https://lh4.googleusercontent.com/-0fMLMpwFbF4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfhT9iR6mHHvoOolev_bXFIBqKuhQ/s96-c/photo.jpg	103628381857359898368	\N	\N
9347	Sashaank Nimmagadda	sashank.n.1711@gmail.com	https://lh3.googleusercontent.com/-ONdlxFj9dRI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPPg2XEE0MUiCnyPCSmVAMPHmSQgQ/s96-c/photo.jpg	110018183307703015999	\N	\N
9131	SIDDHARTH KAPRE ch16b065	ch16b065@smail.iitm.ac.in	https://lh6.googleusercontent.com/-hfaP3Yeta5I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdLJjqNfVDKcHzxFvK69OExxIwFIA/s96-c/photo.jpg	102719715304204500462	\N	\N
8371	Aman Basheer A	ed17b032@smail.iitm.ac.in	https://lh6.googleusercontent.com/-IulD6J4udTY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN-4E-I4e0aqU2IhSAEXK0CmlTk_w/s96-c/photo.jpg	111703803711058182719	\N	\N
8476	kopparthi Santhu	kopparthis1@gmail.com	https://lh4.googleusercontent.com/-B5Th4qgHxls/AAAAAAAAAAI/AAAAAAAACMA/KGCNgJAryi4/s96-c/photo.jpg	111203068180225244060	\N	\N
8452	Ananya Shetty	ph18b007@smail.iitm.ac.in	https://lh3.googleusercontent.com/-1KJ50p6QJnY/AAAAAAAAAAI/AAAAAAAAAAc/pr273ulphwE/s96-c/photo.jpg	103612128499527056792	\N	\N
8989	Yuvraj Singh	yuvraj1107singh@gmail.com	https://lh4.googleusercontent.com/-Lc5QpXzY5c0/AAAAAAAAAAI/AAAAAAAAAAo/sLDMHmlWGlc/s96-c/photo.jpg	106635592932027981078	\N	\N
8972	Varun Pradeep Awasthi ch18b028	ch18b028@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rS688_WONt4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfUZiOJetGlnhedYHl7e4oYtAu-XQ/s96-c/photo.jpg	102627795555924271019	\N	\N
9042	Hanushavardhini S hs18h019	hs18h019@smail.iitm.ac.in	https://lh3.googleusercontent.com/-m30jnYA34Po/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd7hiRvAoi4AaUZcGcHcdVNmBpJYg/s96-c/photo.jpg	101626955168185208012	\N	\N
8914	Aditya singh	adityasingh2841999@gmail.com	https://lh5.googleusercontent.com/-zppTFk3axD0/AAAAAAAAAAI/AAAAAAAAHBM/5wFNSml80t8/s96-c/photo.jpg	105702456308731098062	\N	\N
9401	Sri Sindhu Varma Gunturi	srisindhu777@gmail.com	https://lh6.googleusercontent.com/-vWVYbJct5jc/AAAAAAAAAAI/AAAAAAAAAEk/Ca5ZHqnjXus/s96-c/photo.jpg	101172755541818547188	\N	\N
9074	Yash Gupta	yashguptapsp@gmail.com	https://lh4.googleusercontent.com/-BW1uVa9S_OY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNv2sVHcXWL6s4mjjiAgZDGVg_LRA/s96-c/photo.jpg	104971464362178380321	\N	\N
8899	aayush raj	aayushr6@gmail.com	https://lh5.googleusercontent.com/-txpfbAEYKFg/AAAAAAAAAAI/AAAAAAAABvU/RrkkE-ayoo4/s96-c/photo.jpg	104196509524819380284	\N	\N
9388	Vibodh Pankaj ee18b159	ee18b159@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jHnNWx3kwV4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMG5D7W2ii4co9XPQsijzwoc9RdHg/s96-c/photo.jpg	104181085677236457428	\N	\N
9408	CHARJAN ANIKET RAVINDRA	car10@iitbbs.ac.in	https://lh6.googleusercontent.com/-WiBKdLELmqA/AAAAAAAAAAI/AAAAAAAAAAs/FtT1NJFwZv0/s96-c/photo.jpg	101171188455426530274	\N	\N
9355	Kailash Lakshmikanth	kailashiitm2k18@gmail.com	https://lh3.googleusercontent.com/-SP-EHd_I32w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reSgCwpqQ3zgbe9XqB9-G0v52PeNw/s96-c/photo.jpg	110271268844549390100	\N	\N
9327	Venkatesh prasad	venkatesh.siddu10@gmail.com	https://lh6.googleusercontent.com/-0r2w1mxrIXU/AAAAAAAAAAI/AAAAAAAAM1g/KgoNWHxpXMY/s96-c/photo.jpg	102952072459497959474	\N	\N
9243	Kiran S K K bs17b017	bs17b017@smail.iitm.ac.in	https://lh4.googleusercontent.com/-rIX4TAekVnk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfO7M2DEdx16qDI2NjFHMqeypoIQQ/s96-c/photo.jpg	107033203380308127028	\N	\N
9238	Abhishek Sekar ee18b067	ee18b067@smail.iitm.ac.in	https://lh4.googleusercontent.com/-E0ldF-hAPHc/AAAAAAAAAAI/AAAAAAAAAAo/VtPQj-gt5sU/s96-c/photo.jpg	113069714899047220836	\N	\N
9348	Atharva Mashalkar ce18b136	ce18b136@smail.iitm.ac.in	https://lh4.googleusercontent.com/-qU98v-GateM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMpoHIJ30tcsJ4ROH1Cuy1ust545A/s96-c/photo.jpg	109722948945101591188	\N	\N
9455	Aditya Todkar	aditodkar@gmail.com	https://lh4.googleusercontent.com/-3uf5Igunbao/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdpZdmIQblR6fZPwerff1fUcxuqYA/s96-c/photo.jpg	106355600612411521354	\N	\N
8651	R Aditya be18b029	be18b029@smail.iitm.ac.in	https://lh3.googleusercontent.com/-EIalQ3r2LR0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNM55YhBfQ28gxuY0J-HFHMEcjKHg/s96-c/photo.jpg	101682012856295676880	\N	\N
9464	nandhini swaminathan	nandhiniiswaminathan@gmail.com	https://lh4.googleusercontent.com/-XnfmXted7p8/AAAAAAAAAAI/AAAAAAAAD7s/GHuimlfeMdc/s96-c/photo.jpg	103308922454507465852	\N	\N
9116	Shriram Elangovan	shri99elango@gmail.com	https://lh6.googleusercontent.com/-uRr-rIx3OO0/AAAAAAAAAAI/AAAAAAAANBQ/eToO1-w3UHs/s96-c/photo.jpg	111335512155779191240	\N	\N
9516	Sivasubramaniyan Sivanandan ee17b029	ee17b029@smail.iitm.ac.in	https://lh6.googleusercontent.com/-c3E65eD10JI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfeCj7yAIxArZh2ixBrXdugO9vQtA/s96-c/photo.jpg	116759539753758122369	\N	\N
9705	Satyajit Sahu	satyajitsahu2000@gmail.com	https://lh6.googleusercontent.com/-1LK3eW3Yb4k/AAAAAAAAAAI/AAAAAAAAAEQ/RVBRpzap1Bc/s96-c/photo.jpg	116478683189057283291	\N	\N
9844	Bharath Srinivasan	anibmw.audi@gmail.com	https://lh5.googleusercontent.com/-MY3jLfOdD7k/AAAAAAAAAAI/AAAAAAAAAGI/42fCa4cJaJA/s96-c/photo.jpg	114352721177624111587	\N	\N
9675	sumanth sarva	sumanthsarvasms@gmail.com	https://lh4.googleusercontent.com/-3lnJxU_phLQ/AAAAAAAAAAI/AAAAAAAALMs/-j0bY6J7uJQ/s96-c/photo.jpg	102341274763983527312	\N	\N
9609	Nithin Babu	nithinchennai123@gmail.com	https://lh6.googleusercontent.com/-1taC-D4HjFU/AAAAAAAAAAI/AAAAAAAAALo/_QJcdNBcCoc/s96-c/photo.jpg	104294280397208849479	\N	\N
9570	SOURAV SAMANTA	souravsamanta541996@gmail.com	https://lh3.googleusercontent.com/-5dB4s7OITTU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNoqNoYlDW0yFVaqj96TwliHhW4NQ/s96-c/photo.jpg	112654001619380731452	\N	\N
9548	naveen kumaar srinivasan	s.nav2enias@gmail.com	https://lh4.googleusercontent.com/-4qnibQABLq0/AAAAAAAAAAI/AAAAAAAADN4/_4D9UPhPQeo/s96-c/photo.jpg	113468750706613363716	\N	\N
9738	Niraj Kumar	nir8083@gmail.com	https://lh3.googleusercontent.com/-VgNCXDiE1kM/AAAAAAAAAAI/AAAAAAAAAWU/tJYEG53OWog/s96-c/photo.jpg	108496699258995503222	\N	\N
10136	Sreenadhuni Kishan Rao ed18b033	ed18b033@smail.iitm.ac.in	https://lh4.googleusercontent.com/-FKNEj2K8bw0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM4KAppuZ6bBixdXPdBAb57fhzVhQ/s96-c/photo.jpg	105576284422817967929	\N	\N
9549	V Tandava Krishna Mohan bs18b030	bs18b030@smail.iitm.ac.in	https://lh4.googleusercontent.com/-s7wSR_RcugI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfRfydXJDmTkcw-heMP8LLzq_FFvA/s96-c/photo.jpg	106806052669784234976	\N	\N
9625	Sourav Bose	sbose703@gmail.com	https://lh5.googleusercontent.com/-Q8NghmnmWnI/AAAAAAAAAAI/AAAAAAAAAsQ/9jz-s6pSWbo/s96-c/photo.jpg	104523922747918185043	\N	\N
8634	Abhimanyu Swaroop	abhiswaroop210100@gmail.com	https://lh4.googleusercontent.com/-5VvGqSNGyO8/AAAAAAAAAAI/AAAAAAAAAAs/99UXw95qzy0/s96-c/photo.jpg	101964436097463168367	\N	\N
9903	RISHBHA JAIN me16b162	me16b162@smail.iitm.ac.in	https://lh6.googleusercontent.com/-rzmyjsvPVfM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfincaAhg4YYk5e0DFkOopIIlwQ_Q/s96-c/photo.jpg	103108124271782832702	\N	\N
9985	bhaskar lankapalli	bhaskarlankapalli2000@gmail.com	https://lh3.googleusercontent.com/-3HyooG-UXuA/AAAAAAAAAAI/AAAAAAAAF0w/oNgcxivKHh4/s96-c/photo.jpg	109352785883855242466	\N	\N
9475	SHANKAR LAL ce16b125	ce16b125@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Wyiv_N4pTQ0/AAAAAAAAAAI/AAAAAAAAAMY/ed9LDcucNgE/s96-c/photo.jpg	102378491167760853351	\N	\N
9894	Yaswanth a	yashwan98@gmail.com	https://lh5.googleusercontent.com/-wRtEI_MhQJQ/AAAAAAAAAAI/AAAAAAAAHk0/DP5Z1i_LI5o/s96-c/photo.jpg	110659738883261836733	\N	\N
9869	Tejas Raju Tayade me17b072	me17b072@smail.iitm.ac.in	https://lh3.googleusercontent.com/-E1ySsABvY8I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rct2KNXt837qeZUPhok4m71gUfIUQ/s96-c/photo.jpg	105102379391896692236	\N	\N
9839	SUMIT KUMAR	sumitkumar150299@gmail.com	https://lh4.googleusercontent.com/-JLzXYUhcOoU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMuBfzX91YZBMI0nWX1ByYK9xPsiQ/s96-c/photo.jpg	111171075972860896041	\N	\N
11308	SUPARSHVA JAIN ch16b114	ch16b114@smail.iitm.ac.in	https://lh4.googleusercontent.com/-8mOuP1AXHUs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMhdrzLkRogE_ZoWEmxzXnvtuL6Dg/s96-c/photo.jpg	115889029059451906334	\N	\N
9806	chavali anirudh	chavaliani0123@gmail.com	https://lh6.googleusercontent.com/-qkPpEvsg7K0/AAAAAAAAAAI/AAAAAAAAlvA/WXhhZpPhZnk/s96-c/photo.jpg	106348211089456308863	\N	\N
9897	Shyam V S mm18b114	mm18b114@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Cid6A9cYRCQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPXe4atstcRpyw6nuvQ9kZCswpNDA/s96-c/photo.jpg	116533323679531504829	\N	\N
9902	Tejas Tayade	sirtejas98@gmail.com	https://lh4.googleusercontent.com/-VpY7mhE6Da8/AAAAAAAAAAI/AAAAAAAAXPY/H5ZcIzWOBG4/s96-c/photo.jpg	115433360587726830200	\N	\N
9626	Nischith Shadagopan M N cs18b102	cs18b102@smail.iitm.ac.in	https://lh4.googleusercontent.com/-LFksSIAPNFE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPLLXGes_19J0M8BzhGIPHtbxSoZw/s96-c/photo.jpg	104768237535269074850	\N	\N
10281	D Pavan Kumar Singh ae17b003	ae17b003@smail.iitm.ac.in	https://lh6.googleusercontent.com/-O0C7eQxSauo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdu4gNhJOpe90XS6gMAyhP5QCdEZQ/s96-c/photo.jpg	100876071657723299498	\N	\N
9830	Pruthvi Raj R G ee17b114	ee17b114@smail.iitm.ac.in	https://lh3.googleusercontent.com/-S5cqfRnDZrg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOCIqDy1iNYsq59D5jHnTdDizrecA/s96-c/photo.jpg	116667899528785398547	\N	\N
9960	Rithvik Anil	rithvik.anil@gmail.com	https://lh4.googleusercontent.com/-3sGbm2B1yvA/AAAAAAAAAAI/AAAAAAAAIOo/UkwLOqZFeh8/s96-c/photo.jpg	108733883465772823484	\N	\N
9809	Adnan Faisal	adnanfaisal8581@gmail.com	https://lh6.googleusercontent.com/-1cDAI2byWVQ/AAAAAAAAAAI/AAAAAAAAGf8/osWkqOWWREQ/s96-c/photo.jpg	102823766561575238807	\N	\N
10107	Sahil Rajesh Kumar me17b066	me17b066@smail.iitm.ac.in	https://lh3.googleusercontent.com/-P1J00vwRs_k/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPKACCbiDAvDy82zKHi1-KxdBUCEg/s96-c/photo.jpg	112998653258877975475	\N	\N
9854	sai sree harsha	assharsha518@gmail.com	https://lh3.googleusercontent.com/-wdZiP-lL5w4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf6jK-UGlvX1kBDhsFGfutbhIefXg/s96-c/photo.jpg	111710272164921687698	\N	\N
10364	Abhishek Kumar	abhishekucskumar@gmail.com	https://lh3.googleusercontent.com/-EW3AvXIwcss/AAAAAAAAAAI/AAAAAAAAAAc/m0n0R9mn_7o/s96-c/photo.jpg	109473029886699548381	\N	\N
10360	lemon reddy	lemonreddy87@gmail.com	https://lh5.googleusercontent.com/-H5B0aKkN_SA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNmV4H4VeqrKo_Nl0wPCxklOXIBag/s96-c/photo.jpg	117857658398501576041	\N	\N
10363	Atharv Tiwari	atharv.tiwari02@gmail.com	https://lh6.googleusercontent.com/-WaN6h64fP2g/AAAAAAAAAAI/AAAAAAAAF54/z2PcarfM9uk/s96-c/photo.jpg	112188830982780019541	\N	\N
10399	Vignesh P	pvignesh3991@gmail.com	https://lh3.googleusercontent.com/-jIbf-dW11z0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMONeVuYE5OqEk2TwQwuV8diQEtRQ/s96-c/photo.jpg	115330146506587527272	\N	\N
10064	Shubham Danannavar	shubhamsd4@gmail.com	https://lh3.googleusercontent.com/-xww-KlhqlUA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdEtpN6qT3nBpIGdoV4kBCP9GVjAQ/s96-c/photo.jpg	101988431255785683948	\N	\N
10034	karuna Karan	sathuvachari18@gmail.com	https://lh4.googleusercontent.com/-YaDeMlKlfgU/AAAAAAAAAAI/AAAAAAAAAFk/ytOvbbpf8UA/s96-c/photo.jpg	107225841050163511047	\N	\N
10478	SHUBHAM KUMAR	subhamkumar2510@gmail.com	https://lh6.googleusercontent.com/-o2dLioD5_iQ/AAAAAAAAAAI/AAAAAAAAAwA/uTVAFJ9PfWs/s96-c/photo.jpg	100903677923974025368	\N	\N
9537	Kalash Verma	kalashverma1212@gmail.com	https://lh5.googleusercontent.com/-xfAqwZ48Vi8/AAAAAAAAAAI/AAAAAAAAWME/ZT5yDBlYlzE/s96-c/photo.jpg	108382685221057954981	\N	\N
10732	AAKASH KUMAR KATHA bs15b001	bs15b001@smail.iitm.ac.in	https://lh4.googleusercontent.com/-K8dMFhVQurk/AAAAAAAAAAI/AAAAAAAAESk/ZRozBilFGKs/s96-c/photo.jpg	111790252858780067280	\N	\N
10551	Om Shri Prasath	ee17b113@smail.iitm.ac.in	https://lh5.googleusercontent.com/-qfTPzqOVLVo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc8dkq6Px9now8eGahgiWJ8XIeP9A/s96-c/photo.jpg	108283492057740057468	\N	\N
10720	Suhas Morisetty	morisettysuhas@gmail.com	https://lh3.googleusercontent.com/-E1ik6oCFqU8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfa-LF-YsO1vY2icuMeUW-w0DxLug/s96-c/photo.jpg	105703282986440185552	\N	\N
10540	Shankar Thyagarajan	shankar15498@gmail.com	https://lh5.googleusercontent.com/-VtaOHAPrqsU/AAAAAAAAAAI/AAAAAAAABos/oR_45D_jcQA/s96-c/photo.jpg	108977537476281644524	\N	\N
11053	Kothuri Kranthi Kireet ce18b039	ce18b039@smail.iitm.ac.in	https://lh5.googleusercontent.com/-e8J8177QQYg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNGCLFhIaOyGvjFn0ZRVLhkkFrSUw/s96-c/photo.jpg	109341647643235882215	\N	\N
10675	S Vishal ch18b020	ch18b020@smail.iitm.ac.in	https://lh6.googleusercontent.com/-4sF3iUp5rYo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPXuONgE9jpeQedfD8i9kNO-Ll2Ew/s96-c/photo.jpg	111054950123693497601	\N	\N
10998	Shameem Ahamed Ibrahim M	ee17b148@smail.iitm.ac.in	https://lh5.googleusercontent.com/-7cQA51di99M/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPqXJ_2VcCG9MhG5NVOmBbbZpRP6w/s96-c/photo.jpg	105359990990724355526	\N	\N
10626	Malyala Srikanth	malyala2srikanth@gmail.com	https://lh5.googleusercontent.com/-p4Qx39cVWFM/AAAAAAAAAAI/AAAAAAAACDo/JRLO2XkMzCc/s96-c/photo.jpg	117276624581419753619	\N	\N
11070	KOTHURI KRANTHI KIREET	kranthi16112001@gmail.com	https://lh4.googleusercontent.com/-RN9IMwQ7WEE/AAAAAAAAAAI/AAAAAAAAAAc/Lx4vdiunGys/s96-c/photo.jpg	118004615112209735453	\N	\N
10861	VIVEK .S ce16b064	ce16b064@smail.iitm.ac.in	https://lh3.googleusercontent.com/-q9uHli1N1lY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reuw4yEZ-WbIPV1UYXqn4fUo9p6mQ/s96-c/photo.jpg	111650156609320815046	\N	\N
10930	LANJEWAR TUSHAR TULSHIRAM ch16b042	ch16b042@smail.iitm.ac.in	https://lh5.googleusercontent.com/-BEDrpCCpqDU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOaw8sx-c6mRITfvWFTFFcuNZVGkg/s96-c/photo.jpg	105383915539197235322	\N	\N
10521	Saurav Jaiswal	sauravjaiswal999@gmail.com	https://lh3.googleusercontent.com/-NRYwSi-xg38/AAAAAAAAAAI/AAAAAAAAAGc/0ANlIy1bv2s/s96-c/photo.jpg	103131193577480666827	\N	\N
10556	John Smith	ramitajawahar2000@gmail.com	https://lh5.googleusercontent.com/-_TMHKS_BfEo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN-xQvbw4e7CeGFFG0moPg35alW4A/s96-c/photo.jpg	105765378409248116613	\N	\N
10905	ASHWIN S NAIR ch16b033	ch16b033@smail.iitm.ac.in	https://lh3.googleusercontent.com/-ASizGLmd0sg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfQzmQiWErhx0orUYYS-EX0lM970w/s96-c/photo.jpg	112870015091726857162	\N	\N
10999	Akshat Singh cs18b001	cs18b001@smail.iitm.ac.in	https://lh3.googleusercontent.com/-sUDsMctCJf4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMnGPSIGwO6sv-md5Fmt3LDg0S_tw/s96-c/photo.jpg	102636321268460229245	\N	\N
11148	B Abhilash ee17b123	ee17b123@smail.iitm.ac.in	https://lh4.googleusercontent.com/-lLWQoPWJEaM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPyJtiKNPUpsZsR6gW_XmbPhQLjhQ/s96-c/photo.jpg	105648755733096962226	\N	\N
11125	Revanth Chandra Gampa	ch16b007@smail.iitm.ac.in	https://lh6.googleusercontent.com/-9Z4hoMM1GcI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcqhw9CxIHvoy3MA6jY6r3h9GsAnQ/s96-c/photo.jpg	103438144378005049128	\N	\N
10587	Gayathri Guggilla	gayathri.guggila@gmail.com	https://lh6.googleusercontent.com/-2NpN31FBEnQ/AAAAAAAAAAI/AAAAAAAAbWY/Qimsy0aAr48/s96-c/photo.jpg	116365908916402634741	\N	\N
10864	Yashwanth Corporate	corporate.yashwanth09889@gmail.com	https://lh5.googleusercontent.com/-WZn69GppkNw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdkD3aqHSRrWfM6JhCZLnLJqkLBNQ/s96-c/photo.jpg	100540351647011424813	\N	\N
10731	Morisetty Venkata Anoop Suhas Kumar ee17b109	ee17b109@smail.iitm.ac.in	https://lh5.googleusercontent.com/-snivsPIquOE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdlUbvX--gofXj91UtwkeKJejHlyg/s96-c/photo.jpg	116522826000331691456	\N	\N
11043	Abishek S	abisubramanya27@gmail.com	https://lh4.googleusercontent.com/-PSzg-HVPJR4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rerZYUK2cw4ZUxLj-_wxDNxQL0Faw/s96-c/photo.jpg	110220417219976226248	\N	\N
11000	Sonam Kumari	sonamgwp1998@gmail.com	https://lh4.googleusercontent.com/-oJuCODxCIiw/AAAAAAAAAAI/AAAAAAAAH8Y/Cgy8CzAOKN0/s96-c/photo.jpg	113399580761841634153	\N	\N
10898	HANU SIDDHANTH RAPETI ed16b012	ed16b012@smail.iitm.ac.in	https://lh6.googleusercontent.com/-KIvSwZLOUeM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPAWOiWjXAhQ5m7QlU63E_PZP0b-w/s96-c/photo.jpg	106286990530112922841	\N	\N
11170	Achintya Saraswat	achintya.mukesh.saraswat@gmail.com	https://lh5.googleusercontent.com/-Cg5NvgEdiVg/AAAAAAAAAAI/AAAAAAAAAA4/2vT8OmzOgKY/s96-c/photo.jpg	111692737566168118435	\N	\N
11001	Dev Kabra	me17b139@smail.iitm.ac.in	https://lh3.googleusercontent.com/-MSicWmRPaaU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rciufWPWw_xNOLvEJ-JPR43r1IOGA/s96-c/photo.jpg	114663810596979050512	\N	\N
11024	Sake Rohithya ch18b063	ch18b063@smail.iitm.ac.in	https://lh6.googleusercontent.com/-5vopiWEYV6w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdi5GrOGZNjsqqKei3wiM2HjqK8nA/s96-c/photo.jpg	118415782790952721983	\N	\N
10874	Arabhi Subhash cs17b005	cs17b005@smail.iitm.ac.in	https://lh4.googleusercontent.com/-x-BjC3Xjnvk/AAAAAAAAAAI/AAAAAAAAAdA/lqRXBCFYixI/s96-c/photo.jpg	116202437207229418439	\N	\N
11050	Executive Director director_ecell	director_ecell@smail.iitm.ac.in	https://lh5.googleusercontent.com/-nckAnl-9kNw/AAAAAAAAAAI/AAAAAAAAAA0/9Sqxaqy6IoY/s96-c/photo.jpg	115879398366126639386	\N	\N
11177	deepak mudigonda	mudigondadeepak714@gmail.com	https://lh5.googleusercontent.com/-ZyK86D6KHMc/AAAAAAAAAAI/AAAAAAAABhQ/6udF8XM9u7g/s96-c/photo.jpg	104819180766332055249	\N	\N
11202	SATYA RIS	ae16b022@smail.iitm.ac.in	https://lh3.googleusercontent.com/-45Vazk8kZpI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd4_UOI22ZbDs2cb0oKqBw_VqzwXg/s96-c/photo.jpg	108657894448748089100	\N	\N
9697	BOLISETTY N V S RAGHAVENDRA MAHESH me16b137	me16b137@smail.iitm.ac.in	https://lh3.googleusercontent.com/-SsO2kKIqids/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reHaGa6EvKmFllHK3bFwd_GpJ4dKA/s96-c/photo.jpg	104662693858655380465	\N	\N
11307	Vallury Venkata Sri Lalitha ce17b063	ce17b063@smail.iitm.ac.in	https://lh5.googleusercontent.com/-S0e8yHdkV7E/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rffV55bnS2hqly3Y6whxQdSwEND_Q/s96-c/photo.jpg	101136801595257969901	\N	\N
11294	RAKESH RAUSHAN ae16b109	ae16b109@smail.iitm.ac.in	https://lh3.googleusercontent.com/-IWXo7IKmScI/AAAAAAAAAAI/AAAAAAAAAmo/BW0TlXTC98s/s96-c/photo.jpg	101457174803921195320	\N	\N
11356	Shaik Wasim Akram mm18b032	mm18b032@smail.iitm.ac.in	https://lh5.googleusercontent.com/-J4opgGpSI2s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPnyawM6pUwlVWKfSyUW1CgK5qv0Q/s96-c/photo.jpg	118180651001550783697	\N	\N
11735	Anirudh Rama Murali me18b123	me18b123@smail.iitm.ac.in	https://lh6.googleusercontent.com/-c4J0y0INuRc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfrJOVVeo9Fj282XkNwFtO1sr2dsQ/s96-c/photo.jpg	106307654230780304539	\N	\N
11778	Ujwal Kumar	ukujwalkumar80@gmail.com	https://lh6.googleusercontent.com/-DRto9HRCKU8/AAAAAAAAAAI/AAAAAAAAF_E/TfSiLpn0x0Q/s96-c/photo.jpg	114049354868175047110	\N	\N
11403	Gabriel Ve Vance ee17b105	ee17b105@smail.iitm.ac.in	https://lh6.googleusercontent.com/-VIt0oh9S4OY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMtIaEx6qD5wYvgtO0npNWKm2lUgA/s96-c/photo.jpg	102735459409810377329	\N	\N
11496	ps vasupradha	vasupradaps@gmail.com	https://lh5.googleusercontent.com/-sUZ6Xo7CAwI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc0HDLw9Mrwaac9kb-BmarkkO0F4A/s96-c/photo.jpg	108013768579266369989	\N	\N
11583	DipaK Patil	dp15092000@gmail.com	https://lh5.googleusercontent.com/--KTcRopBIiQ/AAAAAAAAAAI/AAAAAAAAChQ/1J8RiMLi55M/s96-c/photo.jpg	105778861737439936758	\N	\N
11485	Shree Pandey mm18b113	mm18b113@smail.iitm.ac.in	https://lh4.googleusercontent.com/-tN7ocLDW0hw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfjBpURienmOLFg7ePwE5TSABUjIA/s96-c/photo.jpg	100744438715150722107	\N	\N
11511	Kethavath Kiran ee18m037	ee18m037@smail.iitm.ac.in	https://lh5.googleusercontent.com/-8clTY9ucPVs/AAAAAAAAAAI/AAAAAAAAAAc/0JbSxaCfQ_E/s96-c/photo.jpg	109215285114265989714	\N	\N
11565	BONDILI PAVAN KUMAR ae16b023	ae16b023@smail.iitm.ac.in	https://lh4.googleusercontent.com/-f_OvlAdd40E/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3retM-nRbo0Cge7Dx_2y-rQgEODtow/s96-c/photo.jpg	102481396492377586097	\N	\N
11537	NAVNEETH SURESH ch16b111	ch16b111@smail.iitm.ac.in	https://lh4.googleusercontent.com/-o0JAKPE3HjI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMRy6FBgaWSWV7sw1rAfGxDgZGHLw/s96-c/photo.jpg	114454817398927418390	\N	\N
11673	Shreekara Guruprasad me17b035	me17b035@smail.iitm.ac.in	https://lh3.googleusercontent.com/-1EdEwbNteJo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfmXlb6ADV_l4kTk7YqmoRdKGxksg/s96-c/photo.jpg	101042086808084988246	\N	\N
11545	Jyotiraditya Singh	jyotiraditya.singh56@gmail.com	https://lh5.googleusercontent.com/-pO3JppUy3JE/AAAAAAAAAAI/AAAAAAAAACc/vc1tifiVzcA/s96-c/photo.jpg	112367639576206413452	\N	\N
11317	INCSMART SYSTEM	mysmartsystem44@gmail.com	https://lh3.googleusercontent.com/-0XRrpQy8w6Q/AAAAAAAAAAI/AAAAAAAAAIU/P8y0P5O1nts/s96-c/photo.jpg	103723685173753170428	\N	304
11805	Gru Subraminion	gurusubramanianchtr@gmail.com	https://lh4.googleusercontent.com/-oMM8kFPGQD0/AAAAAAAAAAI/AAAAAAAAP2E/TVDaN7TBw-0/s96-c/photo.jpg	113809084463578215556	\N	\N
11259	harini blazee	hariniroy16@gmail.com	https://lh6.googleusercontent.com/-dyxN8RTGviw/AAAAAAAAAAI/AAAAAAAAAAo/x_HJ9J7PeRU/s96-c/photo.jpg	112550532760599361927	\N	\N
11614	Narayan Srinivasan	ee15b108@smail.iitm.ac.in	https://lh6.googleusercontent.com/-hB5Gz_mANKM/AAAAAAAAAAI/AAAAAAAAAVY/Vbd2vEsjUao/s96-c/photo.jpg	114813019548048172570	\N	\N
11169	VIVIDH GARG ch16b072	ch16b072@smail.iitm.ac.in	https://lh3.googleusercontent.com/-p2ovjyK3yag/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcRn46WCUkW5t1jfjTYKcNjdItUDA/s96-c/photo.jpg	110816632514375330936	\N	\N
11997	Mangalam Mishra	mishrajnv61@gmail.com	https://lh6.googleusercontent.com/-rZmzdH0G1UQ/AAAAAAAAAAI/AAAAAAAAAC4/0qeNedHYE08/s96-c/photo.jpg	114564795634879121831	\N	\N
10959	navya prasad	navyaprasad1998@gmail.com	https://lh6.googleusercontent.com/-OEvDVZff7Gw/AAAAAAAAAAI/AAAAAAAAG40/1pIzSZKLFVw/s96-c/photo.jpg	107008061572479616642	\N	\N
12116	Gokul Venkatesan me18b047	me18b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-I4jeEDvF5uI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMFn4aEcaMlV-gUUA28J6gepsicWg/s96-c/photo.jpg	102696267879158004647	\N	\N
11968	david parker	davidparkerpro@gmail.com	https://lh3.googleusercontent.com/-sEAmh122McQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rffMLAEUCZDkHwV0eFL1DjUV6K4uQ/s96-c/photo.jpg	103091607039681871319	\N	\N
12377	Ramprasad Rakhonde	rbrakhonde@gmail.com	https://lh3.googleusercontent.com/-WkXb5tMvwGg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcPe6dRxhus0BCgk_SmUFJwiKD2gQ/s96-c/photo.jpg	116834353417570903175	\N	\N
11722	Desai Rudra Pritesh cs18b012	cs18b012@smail.iitm.ac.in	https://lh6.googleusercontent.com/-NSh9ktZewXg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd6f0tXeS4oQAI-niVvPh7p_Y6fQg/s96-c/photo.jpg	116047930466793291791	\N	\N
12176	y sai sowrya vardhan	r141649@rguktrkv.ac.in	https://lh3.googleusercontent.com/-OJet84MuOSU/AAAAAAAAAAI/AAAAAAAAABg/9fSx8UVTQlE/s96-c/photo.jpg	113493577180279750534	\N	\N
12121	Yalla Akash Pramod ee17b037	ee17b037@smail.iitm.ac.in	https://lh6.googleusercontent.com/-6OpMfBP8gcw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdYoHLvcA-woVHuAXRUdwvs9OQ5fg/s96-c/photo.jpg	112485056914497957154	\N	\N
12247	Rohit Dasari	ce16b121@smail.iitm.ac.in	https://lh6.googleusercontent.com/-u63I-eLy1yI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc50e2qrrBBUt55TcAqn9tuRrSqWw/s96-c/photo.jpg	104261072724142761059	\N	\N
11685	Malu Deep Kamal me17b056	me17b056@smail.iitm.ac.in	https://lh5.googleusercontent.com/-D5kEbQ8WNks/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO7sp6qmmiy0fQfHwV0iBuqOkOFPA/s96-c/photo.jpg	112744303022609382424	\N	\N
12071	Sundar Raman P	ee17b069@smail.iitm.ac.in	https://lh5.googleusercontent.com/-yiijD9uOYh8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcmPIBqsQhRS2QblylnF84qhrMXhA/s96-c/photo.jpg	101529745547818567302	\N	\N
11769	KALAPATAPU KIRTIKANTH ce16b003	ce16b003@smail.iitm.ac.in	https://lh5.googleusercontent.com/-z21XdMWkqwE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re_icZe7EyOYxEUbCXKGka18Wsueg/s96-c/photo.jpg	116481728933509462775	\N	\N
11950	Pankaj Harita	pankaj@skcript.com	https://lh5.googleusercontent.com/-E_dShO2z-iE/AAAAAAAAAAI/AAAAAAAAAAs/pXqCf_lcbyA/s96-c/photo.jpg	114628427311007654470	\N	305
12434	Hari Shankar S.J ee17b011	ee17b011@smail.iitm.ac.in	https://lh5.googleusercontent.com/-UHCqy-2okpY/AAAAAAAAAAI/AAAAAAAAARA/dDtlxZUqSDs/s96-c/photo.jpg	110834837890329203639	\N	\N
12424	DHARAVAT PRAVEENA ch16b006	ch16b006@smail.iitm.ac.in	https://lh6.googleusercontent.com/-C_OA-CV7fi0/AAAAAAAAAAI/AAAAAAAAAE8/oo4mREqvA7Q/s96-c/photo.jpg	103607262433637419142	\N	\N
12310	Abhishek Gopalan	abhishekgopalan321@gmail.com	https://lh6.googleusercontent.com/-iVP8JnxMzwU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reOT63pubQJom86vX34-oxzQR0a1A/s96-c/photo.jpg	115566315786288546293	\N	\N
12018	Rohit Tushar	rohitkadvekar329@gmail.com	https://lh5.googleusercontent.com/-K8M7v7snHew/AAAAAAAAAAI/AAAAAAAAABE/oE2zwabXFPA/s96-c/photo.jpg	117829093653038208495	\N	\N
12388	vamsi vammu	vammuvamsi64@gmail.com	https://lh3.googleusercontent.com/-OGiS_E9rq3k/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPzY1CsLQaGMzgvYrLFjREG8hbCHg/s96-c/photo.jpg	114919245168293555948	\N	\N
11528	Ajmal Hussain hs17h035	hs17h035@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Iu3fMttaaOA/AAAAAAAAAAI/AAAAAAAAAAc/bUWz14wZBRI/s96-c/photo.jpg	103396227673197383401	\N	\N
12794	Shivahari R	r.shivahari@gmail.com	https://lh4.googleusercontent.com/-i8Bc3Eb0KHM/AAAAAAAAAAI/AAAAAAAACh4/5CgqAzkl0WQ/s96-c/photo.jpg	103501151941800356274	\N	\N
13025	vivek bharathi	bharathi.sugan98@gmail.com	https://lh3.googleusercontent.com/-1zgR9-yDe4g/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reOPFCdn3KrafnMAdY74YOrEEHl0w/s96-c/photo.jpg	100356755692278374488	\N	\N
12556	Vandit Kumar Garg ce18b128	ce18b128@smail.iitm.ac.in	https://lh5.googleusercontent.com/-JCbyOKNM4gA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reU6fAHQi-qBsW7cQ0HfLDCmL8iBw/s96-c/photo.jpg	105966691583185367517	\N	\N
12615	Guttukonda Sreeja ce17b035	ce17b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rB038KmThyQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc-7xYHtVJADIX_jYo0ryRjkVQ-Dw/s96-c/photo.jpg	117480425800545607089	\N	\N
13280	Dande Sai Ridhima ce17b029	ce17b029@smail.iitm.ac.in	https://lh6.googleusercontent.com/-GybIRfkvyCU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reaiOTbGs0mAWth1QWI6jjYVYZ13g/s96-c/photo.jpg	108833854089057606604	\N	\N
12828	Pranay Mandar	pranaymandar@gmail.com	https://lh5.googleusercontent.com/-iZsAuHINzsc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rePYYt3XfjbpwnCTjCGGFC93f743g/s96-c/photo.jpg	102078790618882377357	\N	\N
12465	HRISHIKESH T M ed16b013	ed16b013@smail.iitm.ac.in	https://lh3.googleusercontent.com/-xiNP8J6YDjI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPLMCzWqo0yW522BbJLYnsB09dBiA/s96-c/photo.jpg	100666867636647034609	\N	\N
13104	tamil backup	tamilbackup7@gmail.com	https://lh4.googleusercontent.com/-TA8Y2ZR9ScQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMOShB80nyoqjhxlQVfKWgqNQM7xQ/s96-c/photo.jpg	108129314142137762765	\N	\N
13183	ABHIJEET SHINDE	abhijeet.shinde1997@gmail.com	https://lh4.googleusercontent.com/-tqfOfYbTyjc/AAAAAAAAAAI/AAAAAAAAJLw/cXGf6s4d_SM/s96-c/photo.jpg	117882539865048649647	\N	\N
12745	Siddhant Chandrakant Ranavare ch18b025	ch18b025@smail.iitm.ac.in	https://lh5.googleusercontent.com/-QcxRc7LmFaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcbUaXfeDv690Whfp5sdlattPvD_Q/s96-c/photo.jpg	108600984309818701065	\N	\N
12859	Mohammed Izaan Hassan ce17b047	ce17b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-fLlkeeRlaLg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO91Sm6pPYWdaVrpvtLT8Ba8YalYg/s96-c/photo.jpg	114879248319936894164	\N	\N
12478	P M Siddharth ch18b016	ch18b016@smail.iitm.ac.in	https://lh5.googleusercontent.com/-it3SJ6trjzs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfkv6yWWHmtaxruqJG36560tIblDQ/s96-c/photo.jpg	104947023065993961827	\N	\N
12658	Kudari Saraswathi ce17b105	ce17b105@smail.iitm.ac.in	https://lh3.googleusercontent.com/-6P5x90HF6gE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reEAeYzpM7EUWHsYRwXZKMN5OIHDQ/s96-c/photo.jpg	107814725617372580100	\N	\N
12860	ASHISH KUMAR	ak356782@gmail.com	https://lh5.googleusercontent.com/-apxplBRaImw/AAAAAAAAAAI/AAAAAAAAADc/AqQiT7l82is/s96-c/photo.jpg	101898331174970475313	\N	\N
12951	Akshay Dewalwar	akshaydewalwar305@gmail.com	https://lh4.googleusercontent.com/-qJdNOyZuzOs/AAAAAAAAAAI/AAAAAAAAFu8/UtYWsHvgspI/s96-c/photo.jpg	105867436203536915647	\N	\N
12760	shubham mashalkar	shubhammashalkar11@gmail.com	https://lh3.googleusercontent.com/-3WHalXjFOyQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfq1c90gvv2AYzK09V-Zsvagfb7qQ/s96-c/photo.jpg	108390131197877790585	\N	\N
12489	Shivansh Rai	shvnshr16@gmail.com	https://lh3.googleusercontent.com/-tgH98GIJo4c/AAAAAAAAAAI/AAAAAAAABjE/zbzGdehjBgI/s96-c/photo.jpg	106415391789496258631	\N	\N
12977	Jawahar Ram bs17b014	bs17b014@smail.iitm.ac.in	https://lh6.googleusercontent.com/-L_deH5ROJbM/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMJi7am3Q9iIK3nTdb5t1pdQXlUyw/s96-c/photo.jpg	100628633987918286449	\N	\N
4040	God Save me	cubetechnologyindia@gmail.com	https://lh6.googleusercontent.com/-tFsQlO6T_kg/AAAAAAAAAAI/AAAAAAAAH2g/sHEhA6WtvE0/s96-c/photo.jpg	112396581591786005083	\N	\N
13259	Bokka Pradeep cs18m016	cs18m016@smail.iitm.ac.in	https://lh4.googleusercontent.com/-TUiBxTYQwuc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMDTlIHbOBhUkMYEjMBNSilVJBcuA/s96-c/photo.jpg	100409827768971410841	\N	\N
13080	Nasreen Mohammad	mdnasreen2000@gmail.com	https://lh6.googleusercontent.com/-FeNzcKXpF4M/AAAAAAAAAAI/AAAAAAAALbM/1edkRWISc8Q/s96-c/photo.jpg	102032140608250677548	\N	\N
13234	rushikesh badgujar	badgujarrushikesh01@gmail.com	https://lh4.googleusercontent.com/-2EoXOFqyNuU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM-DxHBPX_8ReiNDHI2m1ArZyoPnw/s96-c/photo.jpg	106409347122793214783	\N	\N
12942	Pavankalyan Koribilli	pavankalyankoribilli@gmail.com	https://lh5.googleusercontent.com/-BF7x80xzIg0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc3S4Xkm0PVQ8mfJEUHXeqK2tGHrg/s96-c/photo.jpg	102021247714894981375	\N	\N
12956	Veeresh S ep17b013	ep17b013@smail.iitm.ac.in	https://lh4.googleusercontent.com/--5wGEiDS8wQ/AAAAAAAAAAI/AAAAAAAAAA8/0gQGzKIGyQo/s96-c/photo.jpg	115337446901304980916	\N	\N
13151	M Sai Krishna ae17b007	ae17b007@smail.iitm.ac.in	https://lh5.googleusercontent.com/-NAlRyX-_rgs/AAAAAAAAAAI/AAAAAAAAAAU/eHjq5JTiCPQ/s96-c/photo.jpg	112966794963954956260	\N	\N
13260	Thiyagu Tenysen	thiyagutenysen@gmail.com	https://lh6.googleusercontent.com/-PqnN7ItYj3k/AAAAAAAAAAI/AAAAAAAAAKU/_jptfYQRexo/s96-c/photo.jpg	110719102246911509342	\N	\N
13184	Harshit Kedia cs17b103	cs17b103@smail.iitm.ac.in	https://lh5.googleusercontent.com/-r4yDxHp9BHY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNJCJOOsL4v2uXdX51N1VePrTvW0w/s96-c/photo.jpg	100386862991581341157	\N	\N
13252	Nikhil Saini ce18b044	ce18b044@smail.iitm.ac.in	https://lh4.googleusercontent.com/-6iie1OrREv8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd9ydWb69-9hnTEevx9steZoNGVPw/s96-c/photo.jpg	108121395666667399036	\N	\N
12785	PAREKH HARSH MALAY me16b173	me16b173@smail.iitm.ac.in	https://lh6.googleusercontent.com/-wKBT1M909XM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdIi8gXjVt1OJLZPujA58VDuQ9oTg/s96-c/photo.jpg	108623107305019567249	\N	\N
13285	Ganesh Kolla ae17b006	ae17b006@smail.iitm.ac.in	https://lh4.googleusercontent.com/-E2GcqD4ncz8/AAAAAAAAAAI/AAAAAAAAAAc/zhb7zOGg4cs/s96-c/photo.jpg	103930184170610275776	\N	\N
12795	Shubham The Rock Jhason Sr	awesomeshubham.jha@gmail.com	https://lh3.googleusercontent.com/-VnE2m1pzFfo/AAAAAAAAAAI/AAAAAAAAANs/HseNSj5QUcQ/s96-c/photo.jpg	106278554674995616834	\N	\N
13275	gayathri devi	gayuga99@gmail.com	https://lh3.googleusercontent.com/-THE-AWLRcSU/AAAAAAAAAAI/AAAAAAAAAYU/JJAHTUytDsI/s96-c/photo.jpg	103740957304582810016	\N	\N
13294	Susmitha S	susmithashanmugam@gmail.com	https://lh5.googleusercontent.com/-5bKS7db-5G0/AAAAAAAAAAI/AAAAAAAACLU/D_xL4b6t3yg/s96-c/photo.jpg	101145697867206691422	\N	\N
13335	Medasani Rakesh ee17b108	ee17b108@smail.iitm.ac.in	https://lh6.googleusercontent.com/-6lmi4s8rOcM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rejAl0iFL3E0Cdf8ISmytbGZXhbow/s96-c/photo.jpg	109309174537793376519	\N	\N
13038	Santosh Sriram ch18b065	ch18b065@smail.iitm.ac.in	https://lh5.googleusercontent.com/-8VdA2RWzjkw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reGdzpcQKO0ZUxeNdUrGDEKNi27hw/s96-c/photo.jpg	103825959457084390467	\N	\N
31809	Pavan Goud	pavangoudmakthala@gmail.com	https://lh3.googleusercontent.com/-9vDOM5-i72A/AAAAAAAAAAI/AAAAAAAABWY/cBZWc3RsTD0/s96-c/photo.jpg	103489347539476665655	\N	\N
13485	Mohit Singla	mohitsingla1098@gmail.com	https://lh4.googleusercontent.com/-XfO19OFzVSw/AAAAAAAAAAI/AAAAAAAAAPE/cenedvuWh2c/s96-c/photo.jpg	104688448802023181992	\N	\N
13442	MOHD FAISAL ch16b110	ch16b110@smail.iitm.ac.in	https://lh6.googleusercontent.com/--raJQ_U9VZg/AAAAAAAAAAI/AAAAAAAAANc/vCPAg5uRId0/s96-c/photo.jpg	109052781110646956753	\N	\N
13239	Kambham Mounika be17b020	be17b020@smail.iitm.ac.in	https://lh6.googleusercontent.com/-kH85EHVSJ4Q/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO76iVEvZKk_5zPH3XWL6TbhbjEfg/s96-c/photo.jpg	106113073509749904874	\N	\N
14123	Arundhati Medya bt18m005	bt18m005@smail.iitm.ac.in	https://lh3.googleusercontent.com/-qPD0FE5gQgw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcY97yywfB6RMIF6b5Mj-luqIN_Wg/s96-c/photo.jpg	113382390019554265804	\N	\N
13840	vivek sai perikala	ed16b019@smail.iitm.ac.in	https://lh5.googleusercontent.com/--yUPuA6T1lg/AAAAAAAAAAI/AAAAAAAAV48/GmEKtpN7www/s96-c/photo.jpg	101500598466006405003	\N	\N
13392	Esakki Ganesh	esakki.ganesh.9599@gmail.com	https://lh4.googleusercontent.com/-Ikuv-NATqMo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re2SDj6MOAYenZOWbaHO1MGf8K-UQ/s96-c/photo.jpg	102478213252906447785	\N	\N
13966	Bheemarasetty Raja Venkata Satya Saikumar ae17b102	ae17b102@smail.iitm.ac.in	https://lh6.googleusercontent.com/-G9EWctI9o_w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdjwc2y6xgkSzNdumiz0JyTa8zkAQ/s96-c/photo.jpg	108208364475622836441	\N	\N
13429	chandan Sharma	chandansharma1906@gmail.com	https://lh3.googleusercontent.com/-Y9R36gIWzaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcCHHODLfg5M0Obq05L_d-jer5xKQ/s96-c/photo.jpg	103402530637959619603	\N	\N
13702	Sujay Bokil	sujaybokil1@gmail.com	https://lh6.googleusercontent.com/-TU2q_FIeuRw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcoGJZIwVz7VzuZf0CeCQTmKwNaNA/s96-c/photo.jpg	101908311592942095194	\N	\N
13484	Purav Bhargav Pandya ce18b046	ce18b046@smail.iitm.ac.in	https://lh6.googleusercontent.com/-AeSFzubGJcc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd1wIBHU5gffwIq3EF426KRFHsPbQ/s96-c/photo.jpg	116858837678187515139	\N	\N
14109	shanthi bhushan sivakumar	ssb100aa@gmail.com	https://lh6.googleusercontent.com/-W2NxLATs2do/AAAAAAAAAAI/AAAAAAAAHdU/xuVchiaaN1Q/s96-c/photo.jpg	103019045688394534925	\N	\N
13182	Piyush Agarwal	piyushagarwal0398@gmail.com	https://lh6.googleusercontent.com/-8Zt29n7FOL4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNGV4em8Oe1KNhJ5Z0VtEIWaO0OGg/s96-c/photo.jpg	116666622718086105584	\N	\N
13725	Adithya Ganesh	adithyaganesh14a14@gmail.com	https://lh5.googleusercontent.com/-HC_D-hmqHqE/AAAAAAAAAAI/AAAAAAAAACk/oPoBa_wP3EM/s96-c/photo.jpg	104876254277989979222	\N	\N
13613	Vinayathi Yerranagu	vinayathiyerranagu318@gmail.com	https://lh5.googleusercontent.com/-f6MJJ9MDelM/AAAAAAAAAAI/AAAAAAAABUU/IyBuulGrJyo/s96-c/photo.jpg	102818605285608644890	\N	\N
13543	Raghul Shreeram	s.raghulshreeram2000@gmail.com	https://lh5.googleusercontent.com/-oV6rX1mt_d8/AAAAAAAAAAI/AAAAAAAAAVI/CVxCF5zL3T4/s96-c/photo.jpg	108340065003624681178	\N	\N
13449	Monish Kumar V ce18b118	ce18b118@smail.iitm.ac.in	https://lh4.googleusercontent.com/-vjKWI33hE4w/AAAAAAAAAAI/AAAAAAAAAAc/u4u2yMzCZmc/s96-c/photo.jpg	113546016407135303566	\N	\N
13611	Rohit Deraj R na17b024	na17b024@smail.iitm.ac.in	https://lh6.googleusercontent.com/--KNFtm1dBrk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdY6SBPGzfBHeKHt_0pS5PGet0B3w/s96-c/photo.jpg	109188619298060523645	\N	\N
13627	breasha gupta	breasha2000@gmail.com	https://lh3.googleusercontent.com/-hCpq_d8uMKM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZuNJOBb7WbFhKle5qPq8QCUmBNQ/s96-c/photo.jpg	103736639878516984826	\N	\N
13797	N S Keerthi bt18m018	bt18m018@smail.iitm.ac.in	https://lh6.googleusercontent.com/-MlaizzCAygU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPS4Z-osq2TjoAzZlo6aytnKtJkpA/s96-c/photo.jpg	114118288202789491662	\N	\N
14005	Mayank Raj	me16b147@smail.iitm.ac.in	https://lh5.googleusercontent.com/-F1pzuQW1Xvo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcDhaFdsYbvCFHPmbL3lZ0LxQaltw/s96-c/photo.jpg	117979108882613694104	\N	\N
13550	sai N	saiunnamalai@gmail.com	https://lh4.googleusercontent.com/-vaHt4yxECno/AAAAAAAAAAI/AAAAAAAAWDw/jjAKunpUIS0/s96-c/photo.jpg	117874484285329294192	\N	\N
14066	Advait Vinay Dhopeshwarkar ce17b024	ce17b024@smail.iitm.ac.in	https://lh4.googleusercontent.com/-QDr0x5jL9VU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMdGYQCb0Litzm4NCrLc2OeLY_cmA/s96-c/photo.jpg	117920921016867287631	\N	\N
13904	Anshu Rathour	anshurathor8@gmail.com	https://lh6.googleusercontent.com/-We6TjL1A9SA/AAAAAAAAAAI/AAAAAAAAJYE/HW1prZ__iIo/s96-c/photo.jpg	107020637866794952560	\N	\N
13915	Komal Iyengar	komaliyengar@gmail.com	https://lh5.googleusercontent.com/-Aby1GsC8Oxc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP4RgdKThulObGlw7QECZDdWJr2pg/s96-c/photo.jpg	104490561986228753301	\N	\N
14156	sharath kothand	sharathkothand@gmail.com	https://lh4.googleusercontent.com/-75SsP1DEFd0/AAAAAAAAAAI/AAAAAAAAHbU/F7jOM5hc5m4/s96-c/photo.jpg	118048228050424097200	\N	\N
13878	Siddharth D P ee18b072	ee18b072@smail.iitm.ac.in	https://lh6.googleusercontent.com/-AZvo2SVn28U/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdwYcdIF9qla0_Tv_Fd8Yv9otW-1g/s96-c/photo.jpg	111673488765813015438	\N	\N
14122	Ujjal Nandy me17b085	me17b085@smail.iitm.ac.in	https://lh4.googleusercontent.com/-j-rpKm_Ni9s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOfJVYoAtnE4ZlqtFOWEvdtYI_6Og/s96-c/photo.jpg	109793064286665109593	\N	\N
14261	pushpak waskle	pushpakwaskle39@gmail.com	https://lh4.googleusercontent.com/-2Mf4h4OJkPo/AAAAAAAAAAI/AAAAAAAAPyQ/k1v-pFL8ArU/s96-c/photo.jpg	111720544730942682902	\N	\N
14269	Amarendra Kumar	amarendrak525@gmail.com	https://lh4.googleusercontent.com/-B5Kc_s-WJs0/AAAAAAAAAAI/AAAAAAAAA1k/y6uNn5pZ-Wc/s96-c/photo.jpg	101937276611031739312	\N	\N
14272	SHAIK ALTHAF	r151631@rguktrkv.ac.in	https://lh6.googleusercontent.com/-r84teHILEyk/AAAAAAAAAAI/AAAAAAAAAUc/XNsrvep-b8w/s96-c/photo.jpg	113591277455155100948	\N	\N
14317	Kaviya Rajkumar	kaviya0409@gmail.com	https://lh6.googleusercontent.com/-b-ht6eISzsA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdXoN2IDwQNhVMoGyIE7QCq41bFgA/s96-c/photo.jpg	115890582017119856079	\N	\N
14262	Lucky Sweety	luckysweety259@gmail.com	https://lh3.googleusercontent.com/-sREpD4iKDpc/AAAAAAAAAAI/AAAAAAAAJ0s/vDEyyFUro2s/s96-c/photo.jpg	101589422478585216731	\N	\N
13496	Mohit Singla cs17b113	cs17b113@smail.iitm.ac.in	https://lh3.googleusercontent.com/-KiZ55B4SE88/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM4JqsBJ6qBc34KoGgFuv8ELzAlAA/s96-c/photo.jpg	101907654598338293396	\N	\N
14401	Vipul Gaurav	vgaurav3011@gmail.com	https://lh4.googleusercontent.com/-BY5GhZUbxUQ/AAAAAAAAAAI/AAAAAAAABOw/WPyiI-mF_b0/s96-c/photo.jpg	101521652097057965274	\N	\N
14412	Deeksha R	deekshar15@gmail.com	https://lh4.googleusercontent.com/-SdD5CrlwF4c/AAAAAAAAAAI/AAAAAAAAOgs/Nu688UgD96g/s96-c/photo.jpg	113726068402775339149	\N	\N
14633	Sourav Sahoo ee17b040	ee17b040@smail.iitm.ac.in	https://lh6.googleusercontent.com/-j8LPOoglq7w/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNF7QpUkYJ9MZFSHxRo078CMwsgJQ/s96-c/photo.jpg	103626818376068643468	\N	\N
14659	Ram Kowshik	ramkowshik.rk@gmail.com	https://lh3.googleusercontent.com/-Y9MVqlryu5E/AAAAAAAAAAI/AAAAAAAAFbA/AeFDJbFVxoY/s96-c/photo.jpg	107140808833289035360	\N	\N
14378	Adarsh Jagtap	adarshjagtap2000@gmail.com	https://lh3.googleusercontent.com/-WNIMqAAr7JY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rebJN-8Cfgb7FGxOZL7ae-E_o5v-Q/s96-c/photo.jpg	113477294628654744659	\N	\N
14423	Harsh Shivhare	harsh.shivhare1998@gmail.com	https://lh3.googleusercontent.com/-hSeLFSLvFb0/AAAAAAAAAAI/AAAAAAAAAHk/K6lpjEk63cY/s96-c/photo.jpg	102703552648579370653	\N	\N
14463	Prithvi Jawahar	prithsjay@gmail.com	https://lh4.googleusercontent.com/-HBZSDog1k2Y/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcdtu8N4NVRUc3-w25XIEZzFjWEJg/s96-c/photo.jpg	108729366027135127866	\N	\N
14963	Aakarsh Chopra	alcatrazz.627@gmail.com	https://lh4.googleusercontent.com/-uvihmMCBcAE/AAAAAAAAAAI/AAAAAAAAdm0/hrC0Jymyt-0/s96-c/photo.jpg	105392264781439901850	\N	\N
14790	Anunay Khetan	anunay.khetan24@nmims.edu.in	https://lh5.googleusercontent.com/--SEtzUREvPo/AAAAAAAAAAI/AAAAAAAAAAo/-3W6Uu8VOQ8/s96-c/photo.jpg	105377586685653541429	\N	\N
14700	Sumit Kumar	mahto.ecell@gmail.com	https://lh3.googleusercontent.com/-jYuG6vqjD8I/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN5oaubnOqXGM4vB2DaHZ7hMYISUQ/s96-c/photo.jpg	113078466770221533079	\N	\N
14656	SHIVESH KUMAR	shiveshtarun@gmail.com	https://lh6.googleusercontent.com/-hnlrb7ia0-U/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfy0dM_iJ9nZn3FyWu7y6OfXmRGxQ/s96-c/photo.jpg	110174260954976084383	\N	\N
14591	Ravipati Sai Pranitha Chowdary	rsaipranithachowdary18@gmail.com	https://lh3.googleusercontent.com/-NMTShJZRswE/AAAAAAAAAAI/AAAAAAAAAlk/QfEz_7iH55A/s96-c/photo.jpg	107777212290619963576	\N	\N
14996	suraj paliwal	surajpaliwal96@gmail.com	https://lh5.googleusercontent.com/-wuprlLTQqQA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPSz4xGxgRCDpU_JuO8dlReb-6PUA/s96-c/photo.jpg	105969740549441975949	\N	\N
14664	HARSH DIPESH SHETH ce15b075	ce15b075@smail.iitm.ac.in	https://lh3.googleusercontent.com/-7QtWIR3cjxQ/AAAAAAAAAAI/AAAAAAAAGWY/CLY9wJLg7nU/s96-c/photo.jpg	117668160078649532199	\N	\N
14565	Mahasweta Dasgupta	mahasweta.ecell@gmail.com	https://lh4.googleusercontent.com/-_0hY_10MFxY/AAAAAAAAAAI/AAAAAAAAAAU/ZDqFJ0uJias/s96-c/photo.jpg	108496485977679015175	\N	\N
15143	Rahul Singla	rahulsingla131199@gmail.com	https://lh4.googleusercontent.com/-NC5mTqlC9w4/AAAAAAAAAAI/AAAAAAAAABY/cuwCJRjFSxc/s96-c/photo.jpg	104971261271364772625	\N	\N
14592	S.R.Nikitha be18b011	be18b011@smail.iitm.ac.in	https://lh6.googleusercontent.com/-nolF3o4zZ4s/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reeDRNQvCY3zJQn83BGrwkFUKXYqg/s96-c/photo.jpg	114864206938564902207	\N	\N
14415	Adarsh Patil	patiladarsh98032321212@gmail.com	https://lh3.googleusercontent.com/-titwUuQJ_TU/AAAAAAAAAAI/AAAAAAAACIc/RlfJ7GrpJeY/s96-c/photo.jpg	109376490111650622719	\N	\N
14944	DEEP SAHNI na16b110	na16b110@smail.iitm.ac.in	https://lh6.googleusercontent.com/-DvadCqnOm14/AAAAAAAAAAI/AAAAAAAAAGE/gInxrN-D3XE/s96-c/photo.jpg	100107002515350266130	\N	\N
14755	Vbreddy 007	vbreddy804@gmail.com	https://lh5.googleusercontent.com/-5VU8-tsyT1g/AAAAAAAAAAI/AAAAAAAAUjA/UCW9FNN42eY/s96-c/photo.jpg	110032815839257235598	\N	\N
14845	modassir ansari	modassirrr@gmail.com	https://lh6.googleusercontent.com/-BEgcb7IRF38/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNDTDrvfbWzk2ZtSu72jQGrUiKB7A/s96-c/photo.jpg	106805539441737421965	\N	\N
15012	Sanjana S Prabhu ee17b072	ee17b072@smail.iitm.ac.in	https://lh6.googleusercontent.com/-riuSkg9F3JY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rccCYyH_GkUSALGG3aWHYkEuOUaxQ/s96-c/photo.jpg	104348561115381214339	\N	\N
14701	Mukesh Kanth S na18b101	na18b101@smail.iitm.ac.in	https://lh5.googleusercontent.com/-CRQ351WDz6I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reMccyuYn5z2-De9SLl-0liPh4k3w/s96-c/photo.jpg	100429882498919065692	\N	\N
14866	Midhunvarman Baluchamy ee18b113	ee18b113@smail.iitm.ac.in	https://lh5.googleusercontent.com/-I0wBKy51PIk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc7j9lnRYN_kC63seX-Vw0silHuQw/s96-c/photo.jpg	102216187786719638066	\N	\N
15007	Nimisha Sharma ae17b113	ae17b113@smail.iitm.ac.in	https://lh4.googleusercontent.com/-W8KyZLCpMzs/AAAAAAAAAAI/AAAAAAAAB7g/JdcY3sBhPOU/s96-c/photo.jpg	105637238575566408188	\N	\N
1634	Baskaran Manimohan	baskaran@ahventures.in	https://lh6.googleusercontent.com/-R_pscFX1LGY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOnOjYw9yc5_QaMPrq1YAPJgaRhKw/s96-c/photo.jpg	104379184185174428302	\N	277
14937	VelURu VinOD	vinodvinny070@gmail.com	https://lh6.googleusercontent.com/-TzAE1X-juzk/AAAAAAAAAAI/AAAAAAAAxmw/nwtKmpOWfrs/s96-c/photo.jpg	111370167988093752199	\N	\N
15021	Swaroop N	nswaroopbtech1@gmail.com	https://lh4.googleusercontent.com/-c7FQeHahlQM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdABN0YrizuOyv_xXFZja2tN_j9xw/s96-c/photo.jpg	114900651924072623893	\N	\N
15022	Akanksha sharma	akanksha.sharma.nic@gmail.com	https://lh4.googleusercontent.com/-oKgF6EwzEqo/AAAAAAAAAAI/AAAAAAAAEds/0jWRN6t6u8I/s96-c/photo.jpg	108682568981573619294	\N	\N
15074	SUREDDY ABHISHEK me16b166	me16b166@smail.iitm.ac.in	https://lh3.googleusercontent.com/--5Gt4SHvrkI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPdF6gz3YQnLvS1cuAvzPkOjbFWTQ/s96-c/photo.jpg	118291383481609082734	\N	\N
15079	Sooryakiran P me17b174	me17b174@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Oh6wDpgT1uA/AAAAAAAAAAI/AAAAAAAAAAc/u-43DaI3LpE/s96-c/photo.jpg	114990232765248097863	\N	\N
15098	Keyur Dayaram Lo ce18b035	ce18b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-qDmBtJ7jPww/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfTVe7bAcEu-X2hBk8EoNxI3YBsFg/s96-c/photo.jpg	116708695537716690014	\N	\N
15164	Nancy Jijhotiya	nancyjijhotiya@gmail.com	https://lh4.googleusercontent.com/-DqRjDLSZ6NI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMECwLm8HuStuJTMlPxp-unjw5d8g/s96-c/photo.jpg	101052838935126041501	\N	\N
15116	yash goyal	yashdineshgoyal@gmail.com	https://lh6.googleusercontent.com/-SP7l3mZjKnM/AAAAAAAAAAI/AAAAAAAADE8/8T5HZt4e3Qo/s96-c/photo.jpg	112839692817362631777	\N	\N
14593	Ashutosh Patil me17b001	me17b001@smail.iitm.ac.in	https://lh5.googleusercontent.com/-90_3ZKmkICs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdWs39P89WqeTf6J484k3ml6Emh-g/s96-c/photo.jpg	108580434982066918605	\N	\N
14905	Nithish Venkatesh be18b026	be18b026@smail.iitm.ac.in	https://lh6.googleusercontent.com/-PA6qY-mdw3c/AAAAAAAAAAI/AAAAAAAAAAU/5XlSbBnBpVI/s96-c/photo.jpg	100971570005396746354	\N	\N
14584	Nidhi Shrivastava	nidhi.shrivastava26@gmail.com	https://lh3.googleusercontent.com/-LqoEdepDBPY/AAAAAAAAAAI/AAAAAAAABBA/A7mxmjwl9HE/s96-c/photo.jpg	104684351632584032808	\N	\N
15196	Rohit Pathak	pathakrohit879@gmail.com	https://lh5.googleusercontent.com/-89OI8aicDRg/AAAAAAAAAAI/AAAAAAAAANw/UEoG3R7bmNA/s96-c/photo.jpg	106864235843535730933	\N	\N
15201	ravi teja	ravitejad98@gmail.com	https://lh4.googleusercontent.com/-_lDtlubt3pE/AAAAAAAAAAI/AAAAAAAAAD4/kjNGfIjvWAI/s96-c/photo.jpg	113663342479235055911	\N	\N
15868	Kala bt18m015	bt18m015@smail.iitm.ac.in	https://lh3.googleusercontent.com/-EIh6GIomyGE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rels6yuFfoHliQ5WtNSD6Gh95rpyg/s96-c/photo.jpg	107698263262342388125	\N	\N
15527	Adithyan R	adithyanrkp@gmail.com	https://lh6.googleusercontent.com/-RwyAdlgEO30/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcNUUjICZTmjxPxGk5FFkgixDp1Lg/s96-c/photo.jpg	108093437797103881179	\N	\N
15165	Dakshana Indumathi hs17h021	hs17h021@smail.iitm.ac.in	https://lh3.googleusercontent.com/-CWpbZQj7KdU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reSLd301SDI9qHSsH2_Zyy57wwzjQ/s96-c/photo.jpg	111516434597847091452	\N	\N
15272	Shashank V ch17b119	ch17b119@smail.iitm.ac.in	https://lh6.googleusercontent.com/-a4bH6zZga0c/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMSrDVLMpjwHS-hcUbzYaDeLQiWKg/s96-c/photo.jpg	116325192833520695834	\N	\N
16110	Harshita Chopra	chopraharshita24@gmail.com	https://lh5.googleusercontent.com/-vNMk4HvmxxU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfUtgdN4HWt1A7VKETyMVLP9gRl0w/s96-c/photo.jpg	116247351025346764156	\N	\N
15458	agila senthil	agila.senthil11@gmail.com	https://lh5.googleusercontent.com/-TZxshFZppq8/AAAAAAAAAAI/AAAAAAAAAFA/bFYCatdHfWk/s96-c/photo.jpg	108827967019219649387	\N	\N
15067	Raghu Veer Tatineni	raghuveeriitm@gmail.com	https://lh6.googleusercontent.com/-rlYkPMa3UgU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdUzZasgh2pbMo54yvl3W3Gnh6SRQ/s96-c/photo.jpg	114468659310476432891	\N	\N
15655	priyanka sonawane	sonawanepriyanka38@gmail.com	https://lh3.googleusercontent.com/-as25eCB_d9E/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPvNwKq_kMxC5Qw7La0gWU8nt3Asw/s96-c/photo.jpg	111262646770972346368	\N	\N
15786	Ajaiy Ramasubramanian ae17b019	ae17b019@smail.iitm.ac.in	https://lh3.googleusercontent.com/-PV7aM8ClHoQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfVN0KG8iniKO-YU9-KVfm8Os4BfA/s96-c/photo.jpg	104533319500165504550	\N	\N
15765	Varun Sahay ce17b020	ce17b020@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rlG7TU7Hpa8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfIuDnGc_cFTcFAot2_KRYIBBfV3w/s96-c/photo.jpg	114962124492980809294	\N	\N
15344	srinivas marthand akella	smarthand.akella@gmail.com	https://lh6.googleusercontent.com/-_QzC2AtzWWA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMWUZ2FjbB7wEtEa8XOfFl1hEDhGQ/s96-c/photo.jpg	110147729374572380021	\N	\N
15309	jean paul	hackert156@gmail.com	https://lh4.googleusercontent.com/-ZzevygNbFeE/AAAAAAAAAAI/AAAAAAAAJYI/GiY_MuSfcYE/s96-c/photo.jpg	100091215008298175933	\N	\N
15339	SUBHASH ranjan	na16b037@smail.iitm.ac.in	https://lh3.googleusercontent.com/-DZdTgFlDoyc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdC6sfciO6DSdiHhN4CPJcf49VqRA/s96-c/photo.jpg	107391169496297798803	\N	\N
15279	General Secretary	generalsec.alak@gmail.com	https://lh6.googleusercontent.com/-b_sZXWLZHcM/AAAAAAAAAAI/AAAAAAAAAAc/x0L45LSm564/s96-c/photo.jpg	103388567827480574153	\N	\N
15280	Patibandla Krishna Vamsi ae17b036	ae17b036@smail.iitm.ac.in	https://lh4.googleusercontent.com/-ovt81edUG9M/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO8_dSWlNS5lsCfIbASauGCcilN-Q/s96-c/photo.jpg	100007341599144671991	\N	\N
15351	sanket kasbale	kasbalesanket21@gmail.com	https://lh3.googleusercontent.com/-PZWzV7wFULM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rexWJnrvdud29LI5VsveZidwBm4Qg/s96-c/photo.jpg	101973134345965974975	\N	\N
15870	neel parmar	neelparmar098@gmail.com	https://lh6.googleusercontent.com/-T_2VAswNVN0/AAAAAAAAAAI/AAAAAAAAACE/wrY8jt8oCNY/s96-c/photo.jpg	113326721099031890221	\N	\N
15239	vaibhav tarphe	vaibhavtarphe7@gmail.com	https://lh3.googleusercontent.com/-sWmb1t5d5iY/AAAAAAAAAAI/AAAAAAAADHU/ZNui485GsTg/s96-c/photo.jpg	112311579826220205379	\N	\N
15234	Raj Kumar Singh oe17m058	oe17m058@smail.iitm.ac.in	https://lh6.googleusercontent.com/-lAM9VtiGg14/AAAAAAAAAAI/AAAAAAAAABI/y0QQLKmcwSg/s96-c/photo.jpg	105889863618992805661	\N	\N
15520	harichandana cherukuri	harichandana.9999@gmail.com	https://lh5.googleusercontent.com/-8tpq_jLKcSo/AAAAAAAAAAI/AAAAAAAABoY/e0dbRIOOhSQ/s96-c/photo.jpg	107636850314884387300	\N	\N
15314	Tejas Anand Srivastava	tejas.sriv.44@gmail.com	https://lh6.googleusercontent.com/-AluUeObsvF4/AAAAAAAAAAI/AAAAAAAAAB8/txhEVYWQWz8/s96-c/photo.jpg	103349567730122948734	\N	\N
15853	DUGGANI ROHIT KUMAR ed16b009	ed16b009@smail.iitm.ac.in	https://lh4.googleusercontent.com/-4dVnpcybgis/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcqhG9okBvWWlDfVr0LcnsTDDCeCQ/s96-c/photo.jpg	112952408322513748665	\N	\N
15894	N.Harisankar Nagarajan	mm17b103@smail.iitm.ac.in	https://lh4.googleusercontent.com/-fR2rMb6v7Bk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reRxdOzVbPonVTCOWS2dvOXEBJHuA/s96-c/photo.jpg	103007964566549103489	\N	\N
15457	Jaisingh Daud	jaisinghdaud8308@gmail.com	https://lh4.googleusercontent.com/-JU0ixOuccuU/AAAAAAAAAAI/AAAAAAAAAcw/DEUm_gppk6I/s96-c/photo.jpg	105076259957419969308	\N	\N
15869	Jaimin Modi	jaimin.18bemeg007@gmail.com	https://lh6.googleusercontent.com/-aglnGQlnxxA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdcibfd790WESzRhjunxM1ZegKQJA/s96-c/photo.jpg	111958938459816957059	\N	\N
15821	sona kumarkumar002	sornakumar002@gmail.com	https://lh4.googleusercontent.com/-STEpEUGilSA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rezYEo0Gw14ZVWiRCTuHBg_OSB9bw/s96-c/photo.jpg	113995434481521167625	\N	\N
15962	Yash Kulthe	yashstevenfinn@gmail.com	https://lh4.googleusercontent.com/-GwUm7nV8y_U/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfTs5a7VaR1Fq1ShMVXVhJFJjb_Iw/s96-c/photo.jpg	109747320167467827913	\N	\N
15487	Sumanth R Hegde ee17b032	ee17b032@smail.iitm.ac.in	https://lh3.googleusercontent.com/-cwPSQg-1Q0I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re-jPKmCp69qfw0BMLw-cAVsinlTg/s96-c/photo.jpg	100506628714015360019	\N	\N
15885	THAMEEMMU K KOMATH	kthameem91@gmail.com	https://lh6.googleusercontent.com/-l2ciTy6yoXs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcFk2KBVeZ9mNoTUOxCkQMAP2QdHw/s96-c/photo.jpg	103742106521483093681	\N	\N
15824	Brundavanam Dinesh Kumar me17b046	me17b046@smail.iitm.ac.in	https://lh4.googleusercontent.com/-fQFo-2I9IIE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdn69PKp8BwZXLu1oXZP_JHsj9yjw/s96-c/photo.jpg	105471448741221920964	\N	\N
15818	Akiti Gunavardhan Reddy ch18b035	ch18b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-BzEPZPGSggk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfqRIdN1f4FJkhFo_BJNXYYgq9Y7Q/s96-c/photo.jpg	117676065019035894011	\N	\N
16422	Sahil Ansari me17b065	me17b065@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Qcq19crvWDQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcW56TTmy5oy4dIhy1XE6yskWTIIg/s96-c/photo.jpg	112577341060416034211	\N	\N
16427	G. Deepak me18b046	me18b046@smail.iitm.ac.in	https://lh3.googleusercontent.com/-97fr9wIK1ig/AAAAAAAAAAI/AAAAAAAAAAc/MIjYYRdfwmw/s96-c/photo.jpg	100062293771283967265	\N	\N
16792	Patnala Susmitha ae17b012	ae17b012@smail.iitm.ac.in	https://lh5.googleusercontent.com/-BnAzQtNYTug/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf0qeVWt8GzMEfi0nuSRiZHsGLyVQ/s96-c/photo.jpg	113301572741765960778	\N	\N
16331	Mukesh V me18b156	me18b156@smail.iitm.ac.in	https://lh4.googleusercontent.com/-n-p8anO5ud8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNJetbzGF5A7Eu4dLdCu8EciqF7Yg/s96-c/photo.jpg	109744159274623744110	\N	\N
16474	Thammineni Harshith Reddy ed18b036	ed18b036@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rOWXn4kbDsA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd43gCvGOcJk5M4NW4tex4yN9udVw/s96-c/photo.jpg	100935303792996603450	\N	\N
16507	RAVI JAIN	ravijainpro@gmail.com	https://lh3.googleusercontent.com/-xe6_QXl-xE4/AAAAAAAAAAI/AAAAAAAAAUM/klTLygAa-SM/s96-c/photo.jpg	116139004159248953879	\N	\N
16832	Falgun Phulbandhe	falgunphulbandhe06@gmail.com	https://lh4.googleusercontent.com/-FdJTWALYwTI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNLWH6yokXzfmhUGmLPIOJtnjxcHg/s96-c/photo.jpg	108442910388268961677	\N	\N
17131	Mayur Satpute	myr7pute@gmail.com	https://lh5.googleusercontent.com/-4VujdFH8-JI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdaRgPA_XkEe-dF_Mbsv1kyh1rRbA/s96-c/photo.jpg	115308042909963382834	\N	\N
16590	Aashish M	ragunathaashish@gmail.com	https://lh6.googleusercontent.com/-sZKZREf5elQ/AAAAAAAAAAI/AAAAAAAAAAc/wHmLigopjPc/s96-c/photo.jpg	111554553216462510738	\N	\N
16940	NISHA kumar	nishakbns@gmail.com	https://lh5.googleusercontent.com/-4DxniTHp7Wo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdv7rb7Jxh5vPLSa0IK1TjOD4Lihg/s96-c/photo.jpg	112784499723253825036	\N	\N
17142	Mrinal Bhaskar K me18b155	me18b155@smail.iitm.ac.in	https://lh4.googleusercontent.com/-qvgjb0216VY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdR0cMDcr0oI0-ZqXF3c8zFpIpbEQ/s96-c/photo.jpg	111654948696293074286	\N	\N
16847	Shankeshi Rahul me17b067	me17b067@smail.iitm.ac.in	https://lh3.googleusercontent.com/-zkq-kFXAJl4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfsQDRPpl-1ukiOIR7L09BzzGq2Qg/s96-c/photo.jpg	114334225426749652469	\N	\N
17219	N J HEMANTH KUMAR ae16b032	ae16b032@smail.iitm.ac.in	https://lh4.googleusercontent.com/-6S7heOypKk8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP66iO5knn5BdDzAamVCAUYmP68Ew/s96-c/photo.jpg	104718836887841018992	\N	\N
16622	Chathurya Challa ce17b113	ce17b113@smail.iitm.ac.in	https://lh5.googleusercontent.com/-96vWuziIIR0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZQsN1DAGosDu1dfv0SwgbUyRVXg/s96-c/photo.jpg	110026865942229726407	\N	\N
16631	Aishwarya Cholin	aishwarya.cholin@gmail.com	https://lh4.googleusercontent.com/-s_iPmKd3gsE/AAAAAAAAAAI/AAAAAAAAAL8/3rXpCp-UisE/s96-c/photo.jpg	106052007854326033612	\N	\N
16580	Neha Rana ch18b111	ch18b111@smail.iitm.ac.in	https://lh3.googleusercontent.com/-hCcsX4Xmpqg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMNd8F8VE5QSYUH1CBjNk9oLom3Jw/s96-c/photo.jpg	102645890726189369599	\N	\N
16979	Alfred K J	alfredkj7@gmail.com	https://lh5.googleusercontent.com/-ZVcpIEyCsYI/AAAAAAAAAAI/AAAAAAAAACE/lY_YTUvIbCU/s96-c/photo.jpg	103072076127132184671	\N	\N
16655	VENNA SIVA PAWAN ae16b016	ae16b016@smail.iitm.ac.in	https://lh6.googleusercontent.com/-3VZqtcynI2I/AAAAAAAAAAI/AAAAAAAAABE/WpJo5wvjXp8/s96-c/photo.jpg	111106753838981121071	\N	\N
16585	Joey dash	ae16b111@smail.iitm.ac.in	https://lh4.googleusercontent.com/-fsI2g_sHDdw/AAAAAAAAAAI/AAAAAAAAA2w/akRFZvKMbN4/s96-c/photo.jpg	117559934115571313893	\N	\N
16553	Sindhuja Dantuluri	sindhujadantuluri@gmail.com	https://lh5.googleusercontent.com/-674Hgq_zphI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNmQs6jVlrObsdLblx6r7Hxfd4z_w/s96-c/photo.jpg	114460674227562471128	\N	\N
16945	Dhananjay Virat ae18b003	ae18b003@smail.iitm.ac.in	https://lh4.googleusercontent.com/-xctW-MS0KNs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN_RDNrPc3rvwpxPoKm7oV-190RfQ/s96-c/photo.jpg	117191117879143045227	\N	\N
17347	SRINATH M	screamingskulls.sri@gmail.com	https://lh5.googleusercontent.com/-DC4eEgJYIm0/AAAAAAAAAAI/AAAAAAAABUc/PKDuDjSvA50/s96-c/photo.jpg	115511980295745235576	\N	\N
16642	Vignesh Kumar S ch18b118	ch18b118@smail.iitm.ac.in	https://lh6.googleusercontent.com/-4MZQsby9PQA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfmuD-CnSVkeDHBndhv8I_aDCVZEw/s96-c/photo.jpg	114676563882884899432	\N	\N
17393	Bipul Gupta mm18b017	mm18b017@smail.iitm.ac.in	https://lh3.googleusercontent.com/-NqgHFjvZmsk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMtvej_O7l9BS9TSvyL2G9zCrYx5w/s96-c/photo.jpg	108604979568748127567	\N	\N
17042	Abhishek Kumar Raj bs18b010	bs18b010@smail.iitm.ac.in	https://lh6.googleusercontent.com/-25UsnH3CMPY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNAfcIf3voj2WByye3jLL7Kj8ir3Q/s96-c/photo.jpg	110451448148325121158	\N	\N
15260	V.LAKSHMI Narayanan	lnarayanan34@gmail.com	https://lh6.googleusercontent.com/-FbL8eIVIHkI/AAAAAAAAAAI/AAAAAAAAAE8/VNRymAsRmEA/s96-c/photo.jpg	106520394041788378062	\N	\N
16771	Ganta sanjay	sanjaykumarganta321@gmail.com	https://lh6.googleusercontent.com/-b8ke_iTvrEU/AAAAAAAAAAI/AAAAAAAAOJs/b-anuRn8_Yo/s96-c/photo.jpg	103413670559273735347	\N	\N
17418	Shubham Goyal	shubhamgoyal.agra90@gmail.com	https://lh3.googleusercontent.com/-w1AKFKpn-Os/AAAAAAAAAAI/AAAAAAAAATA/BjSn3allWlw/s96-c/photo.jpg	116564363134490855745	\N	\N
16956	Mooizz	cs17b034@smail.iitm.ac.in	https://lh3.googleusercontent.com/-nN-ebLq6omI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOt1SYmBbKMjyKMcNjAp6ZGTZDuMA/s96-c/photo.jpg	108704163013899237434	\N	\N
17258	TECHSEC CAUVERY	techseccauvery@gmail.com	https://lh4.googleusercontent.com/-2DnCTYLr5lA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcebt8rQ-iwxB5YQIuXfR4kbYkSLw/s96-c/photo.jpg	105366476143622097769	\N	\N
17306	Manu Chauhan me18b060	me18b060@smail.iitm.ac.in	https://lh3.googleusercontent.com/-oh5zjm4ycnw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc18tFMnt4EPlfHkSJRzSZO69a1yw/s96-c/photo.jpg	109336905989992874826	\N	\N
17388	Niesy Times	tagoreitsmyworld111@gmail.com	https://lh4.googleusercontent.com/-o6l7vEhjHEI/AAAAAAAAAAI/AAAAAAAAAJs/ecvmSZL2QhY/s96-c/photo.jpg	101286071491115366059	\N	\N
17067	Aditya Gupta bs18b001	bs18b001@smail.iitm.ac.in	https://lh5.googleusercontent.com/-BB8T2BKfvF8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN3-SBuDeTKroWSxgFyr_d5BB0eTw/s96-c/photo.jpg	115433487120178068422	\N	\N
17427	dagada bhanu	dagadabhanu@gmail.com	https://lh4.googleusercontent.com/-p8Ogt3nvFLU/AAAAAAAAAAI/AAAAAAAAAA4/uyKs8NEQdNk/s96-c/photo.jpg	117908332937907735815	\N	\N
17484	D Nagarjuna	dnvnagarjunaaa@gmail.com	https://lh6.googleusercontent.com/-6fnPMY18-_c/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM4PHyiLq35NYvNyvuP7TelB-jk5w/s96-c/photo.jpg	104594709803863772446	\N	\N
20359	Chandra A Desai ae18b022	ae18b022@smail.iitm.ac.in	https://lh3.googleusercontent.com/-7qW8S25kUtA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reCBclfaKsZbxRQjGNaaVm8eA60Gw/s96-c/photo.jpg	106522512292842581656	\N	\N
17970	Poloju Kruthik Sai ed18b020	ed18b020@smail.iitm.ac.in	https://lh5.googleusercontent.com/-7bzGLuBlfSs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdyNJwZ6ikwsf-srhmd9bjynLo7fA/s96-c/photo.jpg	108763835762663930458	\N	\N
17701	Akshat Sharda ed18b041	ed18b041@smail.iitm.ac.in	https://lh6.googleusercontent.com/-IKqAdseJa4I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rccAckRVuxvnYfF6NqHC-y2eOwnlQ/s96-c/photo.jpg	105728784342910026116	\N	\N
17801	Mahima Bothra	mahima.bothra@sitpune.edu.in	https://lh4.googleusercontent.com/-VgKJjCIIHH4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcTmZuQyKSOotYTWX4GnHtdq9IhIQ/s96-c/photo.jpg	114936367563313121781	\N	\N
17749	Varun Kumar S ae18b044	ae18b044@smail.iitm.ac.in	https://lh3.googleusercontent.com/-5Fkv8G1tmZg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf-5xNkpx3WoP2Cqdr9fFpi_MRdXA/s96-c/photo.jpg	101944578273299352029	\N	\N
18354	Jai Nagle	jainagle28@gmail.com	https://lh5.googleusercontent.com/-eDFg68ox3Yk/AAAAAAAAAAI/AAAAAAAAAZM/h4obTxORSuo/s96-c/photo.jpg	106938518456953472362	\N	\N
18313	medha shukla	medhashukla97@gmail.com	https://lh6.googleusercontent.com/-oTXvIOCai4o/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPCOWcI0zhaWz56xkY0QGjKdACDEA/s96-c/photo.jpg	113736050608649390939	\N	\N
17720	Gurram Naveen Kumar ee17b010	ee17b010@smail.iitm.ac.in	https://lh4.googleusercontent.com/-icJ7q24RT6g/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPAZY9qE-xcGVjvlciwwPDE82l55Q/s96-c/photo.jpg	106412861907604390589	\N	\N
17709	Jayesh Kumar ed18b045	ed18b045@smail.iitm.ac.in	https://lh6.googleusercontent.com/-kzTtcPGtsuA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPuc4EMa64L7u3XbS_zPqk_AYXGBA/s96-c/photo.jpg	117437415408129738801	\N	\N
13691	DUGGIRALA ROHITH RAJ na16b021	na16b021@smail.iitm.ac.in	https://lh6.googleusercontent.com/-D86mFQF0ONE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOV1Ll_lzdAZA_w6-_7jBIx-OeMdw/s96-c/photo.jpg	110865832851443517161	\N	\N
18233	P Yeshwanth ee17b025	ee17b025@smail.iitm.ac.in	https://lh4.googleusercontent.com/-FpNfo2kNi_Q/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf8r7_3sdSupIO5NNcFF8_7eO4sDw/s96-c/photo.jpg	114298599139971688237	\N	\N
17613	Manognya Koolath	dgtbmbvrpkuku@gmail.com	https://lh3.googleusercontent.com/-z5CrDFJkuHA/AAAAAAAAAAI/AAAAAAAAAbI/lLATJqKSbBI/s96-c/photo.jpg	106629575846126937942	\N	\N
18290	Satyarthi Mishra	mishra.gablu9@gmail.com	https://lh5.googleusercontent.com/-eQY8754F3FI/AAAAAAAAAAI/AAAAAAAACC0/GV_I1VvMX4k/s96-c/photo.jpg	115248932068817934496	\N	\N
17557	Sumanth reddy	sumanthreddy1231@gmail.com	https://lh5.googleusercontent.com/-klEllRkatBE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNVLS5ox_19Uocx0prDDRY9JxVlrg/s96-c/photo.jpg	111188347595798707135	\N	\N
17593	Harshita Jain	mm16b105@gmail.com	https://lh6.googleusercontent.com/-keiZWDfV1M8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM0HqJ0VxYN2akbDR5JMQYsKVltMQ/s96-c/photo.jpg	115799443155105349456	\N	\N
17610	Vipul Chhabra	vipulchhabra555@gmail.com	https://lh6.googleusercontent.com/-QAfgEf5FqTQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPZu86vPmztm_dg8Bb31_0RQH4csA/s96-c/photo.jpg	100582633053159315898	\N	\N
17798	Vishav Rakesh Vig cs18b062	cs18b062@smail.iitm.ac.in	https://lh6.googleusercontent.com/-s5lzHURlbYE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc_Wtrnsh7dC6f14PBguNKa3lHsSg/s96-c/photo.jpg	117741399179967439398	\N	\N
17658	Ritvik Rishi cs18b057	cs18b057@smail.iitm.ac.in	https://lh6.googleusercontent.com/-ODqYbvWfeSQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc9QJOINaDz2DT9GR_XZ3NL0uey9A/s96-c/photo.jpg	105277617859997020173	\N	\N
18082	Utkarsh Ramesh Attela mm17b035	mm17b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-eAc5XXtkDLo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPtGbqt27dlb1ZUA587BrYQhAhSzQ/s96-c/photo.jpg	102790137285939618944	\N	\N
17702	Arul M	amurugan.m99@gmail.com	https://lh5.googleusercontent.com/-2uNtXhnAg4s/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfuoRHgKqvjCLC9_HULd0hUnyJjCQ/s96-c/photo.jpg	106998521804104200708	\N	\N
17678	Rahul Shankeshi	shankeshirahul1341@gmail.com	https://lh4.googleusercontent.com/-o1MGupJAdQw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd0gGWWKDlkkBstYUUhChgsCeZ33g/s96-c/photo.jpg	106306673607640422342	\N	\N
17938	Anjana K ce18m061	ce18m061@smail.iitm.ac.in	https://lh3.googleusercontent.com/-53rBQyKgmCE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc7FWmGJGRPnKhbq9ht2nOV5pNE6w/s96-c/photo.jpg	103731424788131632129	\N	\N
18355	Yogitha B M mm18b007	mm18b007@smail.iitm.ac.in	https://lh6.googleusercontent.com/-PypHtEJJkUM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdPph17rlji4W-S5UxYiPsz8xWASA/s96-c/photo.jpg	100588547910962681744	\N	\N
18411	Critic's Corner	zainab.riz.25@gmail.com	https://lh6.googleusercontent.com/-_miR-wQNwJA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOuRbS9_-FrxPLJw1gVawStvlA4kg/s96-c/photo.jpg	108556356234958183057	\N	\N
9805	ARAVAMUDHAN U	aravamudhan.u.2017.mech@rajalakshmi.edu.in	https://lh3.googleusercontent.com/-P4Fywvgh-gE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZn7v_znu614JoxFN6pwJnmhyCVg/s96-c/photo.jpg	102195777194996285654	\N	\N
18230	Narayana Jeevana Reddy ee17b022	ee17b022@smail.iitm.ac.in	https://lh6.googleusercontent.com/-YhkNroM74q8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNF2x13RvRXBSyCdBsWnPXnilNJ-w/s96-c/photo.jpg	112700648469597583626	\N	\N
18075	Naina Alex	naina.alex07@gmail.com	https://lh4.googleusercontent.com/-5xgUjUIUnoI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdi78utP9C7KtG2-hPifqIgey5XjA/s96-c/photo.jpg	105096418295296750167	\N	\N
18475	*# : } #* 0849	pratyushkumar1108@gmail.com	https://lh5.googleusercontent.com/-0M-HozFFCaY/AAAAAAAAAAI/AAAAAAAAAjc/nTjePdml1ys/s96-c/photo.jpg	109067105576989264497	\N	\N
18438	Mukund Varma T me18b157	me18b157@smail.iitm.ac.in	https://lh5.googleusercontent.com/-B9SorMpntys/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPl-ZeJKsdRxcpn5O_GG7r-uEBvyQ/s96-c/photo.jpg	103766762960350989371	\N	\N
18503	KAKARA DINESH ed16b014	ed16b014@smail.iitm.ac.in	https://lh3.googleusercontent.com/-LjPkV7QOc10/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP3-50YvKsdvRcCJWGFtWPqxK6a6w/s96-c/photo.jpg	108859269534227428590	\N	\N
18502	Khushi Shah	khushi8102000@gmail.com	https://lh3.googleusercontent.com/-ZXHeZI3IyVg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf1QGmrgtqINghoHYlvCM-dqGKiew/s96-c/photo.jpg	112767914135815011236	\N	\N
18588	SANDEEP GEORGE na15b023	na15b023@smail.iitm.ac.in	https://lh6.googleusercontent.com/-n__9eHVJzM8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcWrsDTiLSg220rdBXzPz-KcyP1vA/s96-c/photo.jpg	103485490581328043118	\N	\N
18688	Priyansh Kalawat ch17b016	ch17b016@smail.iitm.ac.in	https://lh3.googleusercontent.com/-9baL8GtLmsk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOVLWB7gNkKsx6z9MWxgeEhjIBlbQ/s96-c/photo.jpg	106652687558722558532	\N	\N
18728	Natuva Sai Sathwik Kumar me17b059	me17b059@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7jijuLAZC2k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reyBnYOGjJujB4BCZ3fEhNYGhQmEg/s96-c/photo.jpg	106897637662401533070	\N	\N
18376	Waseem Hussain	syed.w.hussain@st.niituniversity.in	https://lh6.googleusercontent.com/-PrtJIXKIk8o/AAAAAAAAAAI/AAAAAAAAATI/Ixu6OE6hYnA/s96-c/photo.jpg	104914948058055303827	\N	\N
19691	Sarath Raju Nair ch18b066	ch18b066@smail.iitm.ac.in	https://lh6.googleusercontent.com/-1kwapa1IOKM/AAAAAAAAAAI/AAAAAAAAAAc/2W7uh2w7G_0/s96-c/photo.jpg	117809046150519937646	\N	\N
19644	Gurajala Bhavitha Chowdary ee17b126	ee17b126@smail.iitm.ac.in	https://lh6.googleusercontent.com/-0fDM0GGN0oI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdSkRusuwxozZrDby5Dln0YFLRzfQ/s96-c/photo.jpg	109365219417101681548	\N	\N
18703	Gaurav Mahadev Tambade ch18b048	ch18b048@smail.iitm.ac.in	https://lh6.googleusercontent.com/-WwUHSZA20Bw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc0Y2Bus-6WM47OKfmJyPYrmgHHBw/s96-c/photo.jpg	104667207184638210763	\N	\N
19280	Mamata Lingappa Vaddodagi ee17b135	ee17b135@smail.iitm.ac.in	https://lh6.googleusercontent.com/-UBPwMNg5Iw8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rek0H0ieGexLTjtKJ-VYU1Xk6p6ew/s96-c/photo.jpg	117615406391981290590	\N	\N
19430	nishant paparkar	nishantpaparkar98@gmail.com	https://lh6.googleusercontent.com/-nt54RZDuyMw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPjaX-aOff1Sml57a4b9gBbYvZy6A/s96-c/photo.jpg	117437619686111413164	\N	\N
19521	Arunkumar Tamilselvan	arunkumartselvan@gmail.com	https://lh5.googleusercontent.com/-WDpr_0tZkQg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOVHzoU53H6gk4xdubk1xSvCOWEEg/s96-c/photo.jpg	101142872646572669147	\N	\N
19712	Balasubramaniam M C ee18b155	ee18b155@smail.iitm.ac.in	https://lh5.googleusercontent.com/-SkaCIIkS_38/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOqlKrApT77kl6m6Z_WASNyWUrt2A/s96-c/photo.jpg	110852755961220516170	\N	\N
18887	Aniket Bhoyar	aniket2bhoyar@gmail.com	https://lh6.googleusercontent.com/-0_I4wqvO6Tg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPm43ihOXrwjKje5vH6kaaEU8nU3A/s96-c/photo.jpg	102337992027001659603	\N	\N
19483	santhosh l	lsanthosh012@gmail.com	https://lh6.googleusercontent.com/-ZC2XL0vNulw/AAAAAAAAAAI/AAAAAAAAAA0/mbE92tUof_I/s96-c/photo.jpg	100911127677636231036	\N	\N
19096	Travel with Krishna Kumar	krishnagreat1@gmail.com	https://lh6.googleusercontent.com/-A1Afg51tdn0/AAAAAAAAAAI/AAAAAAAACqw/FPNd1s_Upzc/s96-c/photo.jpg	112313337700316144644	\N	\N
18801	Revanth M K ep17b008	ep17b008@smail.iitm.ac.in	https://lh6.googleusercontent.com/-No38nZDNz7o/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMWxAs2a_HjDglWsqB7sblJJQNWmg/s96-c/photo.jpg	111244159787042145700	\N	\N
20044	Surya Suresh	suryaallstars06@gmail.com	https://lh6.googleusercontent.com/-IJ_QyuD3s8M/AAAAAAAAAAI/AAAAAAAACk0/IjGwHgD861Q/s96-c/photo.jpg	112127390827729456273	\N	\N
19797	dany singala	singaladany@gmail.com	https://lh6.googleusercontent.com/-3uo8qAcb3Os/AAAAAAAAAAI/AAAAAAAAAS0/tVTUn885O2U/s96-c/photo.jpg	107063297132920862498	\N	\N
18999	Yashwant ae18b115	ae18b115@smail.iitm.ac.in	https://lh3.googleusercontent.com/-_qKky-RWbnc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMk7M0meNS7COtoP7kI-3clyIWstw/s96-c/photo.jpg	100879140504622169752	\N	\N
20136	Harsha	harshasunny1998@gmail.com	https://lh6.googleusercontent.com/-tMLDzPdOQDk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPX1vaEQ0xGofZpff6Q_tdE7sXI4A/s96-c/photo.jpg	111147619192315513583	\N	\N
19404	Prajeet Oza	prajeetoza08101999@gmail.com	https://lh6.googleusercontent.com/-WqcJEikn8cM/AAAAAAAAAAI/AAAAAAAABEY/tAXIsLls-Ek/s96-c/photo.jpg	103881707281584352472	\N	\N
19441	balaji evlo	balajievlo@gmail.com	https://lh3.googleusercontent.com/-jfO0R7665xQ/AAAAAAAAAAI/AAAAAAAAAD0/J8ySGRyXqus/s96-c/photo.jpg	106581333278827306337	\N	\N
19597	HARSHIT SHRIVASTAVA	harshitshrivastava0220@gmail.com	https://lh3.googleusercontent.com/-KWj03UzdeWo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN7ZnO7NHvANKR475Rmh5BUQz1XBQ/s96-c/photo.jpg	114026602230300339467	\N	\N
19782	sikandar kumar	ksikandar326@gmail.com	https://lh5.googleusercontent.com/-8awhGxPfFQ0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf4apSOAcorGRyrw_8mkZmkXq9hhw/s96-c/photo.jpg	114065040695019741051	\N	\N
20057	KISHORE S ee16b056	ee16b056@smail.iitm.ac.in	https://lh3.googleusercontent.com/-0SnC4wcLlA8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOEbHTp5ECe9qK8dWlL4j495Z_beg/s96-c/photo.jpg	115291249054184396904	\N	\N
19614	Kalepalli Yaswanth	kyaswanth.nani134@gmail.com	https://lh4.googleusercontent.com/-4BxFLJozHuk/AAAAAAAAAAI/AAAAAAAAP8I/mJnY7hjrqPM/s96-c/photo.jpg	109344380723582753140	\N	\N
19731	Debajyoti Biswas	ee14d302@ee.iitm.ac.in	https://lh5.googleusercontent.com/-vt4A-1vMZiM/AAAAAAAAAAI/AAAAAAAAACU/WsY_2rfVBpE/s96-c/photo.jpg	110925589402818603855	\N	\N
19877	VISHAL SINGH ed16b059	ed16b059@smail.iitm.ac.in	https://lh4.googleusercontent.com/-5iqkM5hjX54/AAAAAAAAAAI/AAAAAAAAAAA/SPiI6UxYkK0/s96-c/photo.jpg	114001870545129070750	\N	\N
20248	Akash kumar hs16h006	hs16h006@smail.iitm.ac.in	https://lh6.googleusercontent.com/-4QAXKsLDMHU/AAAAAAAAAAI/AAAAAAAAAAs/XZePaRdPgQE/s96-c/photo.jpg	103255886189575172045	\N	\N
19912	Girish Mahawar me18b107	me18b107@smail.iitm.ac.in	https://lh5.googleusercontent.com/-nnpuDVjdCnA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rehlpaJRM78XJZ2MNCdMf1E-xjQgg/s96-c/photo.jpg	111057843707706628162	\N	\N
20164	ADITI KHANDARE na16b101	na16b101@smail.iitm.ac.in	https://lh5.googleusercontent.com/-UoshJaBQfdg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfrgvVomsuI5vmihXs53kswxYDBkg/s96-c/photo.jpg	113868334961980318603	\N	\N
20231	Akash Surya	akashsuryak@gmail.com	https://lh6.googleusercontent.com/-8cn8MsbcjkU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd644YtUIMjSOUWvvlMd78qcmPFYw/s96-c/photo.jpg	109889406964683955247	\N	\N
20276	Mathurthi Amrutha Varshini ee17b019	ee17b019@smail.iitm.ac.in	https://lh4.googleusercontent.com/-f3OjIQbNz0w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfideLSzFANiAs0-ncdVVhljmvoAg/s96-c/photo.jpg	113270308068308693920	\N	\N
20076	Shashikant Singh ee18m063	ee18m063@smail.iitm.ac.in	https://lh6.googleusercontent.com/-iQr1pLDEnYI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd3ZP2_TVqxK92iXhkeW-H6dISknQ/s96-c/photo.jpg	110061169103924354522	\N	\N
20289	Krithika Dhanasekar	krithikaminions@gmail.com	https://lh5.googleusercontent.com/-Z5R21FVYapA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcBHOI7HKxy90palnyrvQuBVpRK2Q/s96-c/photo.jpg	114460255359960686690	\N	\N
20317	Balla Tanmayi	tanmayinomy1706@gmail.com	https://lh5.googleusercontent.com/-BFHnRoqerGo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMY3PdjweBLcb8GnOfNz0ajSJ1hhQ/s96-c/photo.jpg	108254744377935010731	\N	\N
20352	Kamesh Kanniappan	kamesh3799@gmail.com	https://lh3.googleusercontent.com/-gXhV2JClFTY/AAAAAAAAAAI/AAAAAAAAAbo/B-x3ECTuv1Q/s96-c/photo.jpg	102016362692018663817	\N	\N
20375	toram mounika	prashanthimounikatoram@gmail.com	https://lh5.googleusercontent.com/-Yix9DizYST0/AAAAAAAAAAI/AAAAAAAACwA/0oeTsXtDJE0/s96-c/photo.jpg	107705980388869672861	\N	\N
19014	Shreyas Sharad Wani ee18b031	ee18b031@smail.iitm.ac.in	https://lh5.googleusercontent.com/-LsNq0QpT4M0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOgNoJgdjdsOwX2FY_vba-SwFrJ2Q/s96-c/photo.jpg	112948527520079330665	\N	\N
21084	Subeer Nayak be18b030	be18b030@smail.iitm.ac.in	https://lh6.googleusercontent.com/-Wc0TEwrXhw4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re834GwQTHocVMJ7jXlsL-JjTr3Ig/s96-c/photo.jpg	110896153092092864357	\N	\N
20509	avichal agrawal	avichal2911@gmail.com	https://lh4.googleusercontent.com/-WE2FjgNH-D4/AAAAAAAAAAI/AAAAAAAAABI/bQLwebMnyEM/s96-c/photo.jpg	111249737724193533146	\N	\N
20502	Ikben Ghosh	ghoshikben0102@gmail.com	https://lh4.googleusercontent.com/-rcaIhwd6eo4/AAAAAAAAAAI/AAAAAAAAAvU/3Sb7J-dMldM/s96-c/photo.jpg	102358353258651799998	\N	\N
20474	YUKTI ce16b136	ce16b136@smail.iitm.ac.in	https://lh5.googleusercontent.com/-l1UCOvUvkkI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfLEnCYpFaV2tP9YsMQvz-_0wImFQ/s96-c/photo.jpg	101346850687390430152	\N	\N
21204	shaikat chakraborty	shaikatchakraborty@gmail.com	https://lh6.googleusercontent.com/-tQzvix12XwI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfuUT3ohu2T3JorOjZMHRzJfKA5wA/s96-c/photo.jpg	115768587578837624653	\N	\N
20989	Shikha Raj	shikharaj1105@gmail.com	https://lh5.googleusercontent.com/-2JWnlVtwdHc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPyV_6FXF8B1Py3MTfJvkakmLiAEQ/s96-c/photo.jpg	116530412916957561133	\N	\N
20479	Hari Ranjan Meena me18b108	me18b108@smail.iitm.ac.in	https://lh6.googleusercontent.com/-DJ9Z_0crZ1I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcDCD93jzUBjM3R1OE7eELJ9PD3Zw/s96-c/photo.jpg	100435892597443729390	\N	\N
20394	Maddineni Bhargava ee18b112	ee18b112@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jblYup2_zRI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re-2lHTRcBcgr9eUxufNTK6Ll83HA/s96-c/photo.jpg	115720717467371239169	\N	\N
20797	Murali T S	tsmurali1998@gmail.com	https://lh5.googleusercontent.com/-MqdSmf_rxdE/AAAAAAAAAAI/AAAAAAAAHGY/lm_Qxrzr-qw/s96-c/photo.jpg	116421020974357240608	\N	\N
20438	Praveen Daniel	praveendaniel107@gmail.com	https://lh6.googleusercontent.com/-k5lEcHpYrrs/AAAAAAAAAAI/AAAAAAAAEg8/OLZ21q-Msag/s96-c/photo.jpg	101723642987973735918	\N	\N
20742	Marlapalli Sai Jaswanth me17b025	me17b025@smail.iitm.ac.in	https://lh3.googleusercontent.com/-RqJuyV5mySQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf1njGcK6fWAz1yaT6tRmYWBasCoA/s96-c/photo.jpg	105792740625464197848	\N	\N
20665	Chaitanya P	pchaitanya0938@gmail.com	https://lh4.googleusercontent.com/-KZHuX5FWPic/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOGYSgu2nI8Dt77L1_QoyYbTl4law/s96-c/photo.jpg	107080380616313180851	\N	\N
21351	NIYAS A ch16b047	ch16b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-rkCwS07yg18/AAAAAAAAAAI/AAAAAAAAAmk/Pldy-835y1E/s96-c/photo.jpg	106946853683032263380	\N	\N
20966	Cheerla Susanth ch17b041	ch17b041@smail.iitm.ac.in	https://lh6.googleusercontent.com/--DZhYZ0NDmg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rccGtaIoa7i5ZCCyCyHtDf9DoooGQ/s96-c/photo.jpg	109875688119492220593	\N	\N
21252	Sona Sheril Antony ch17b071	ch17b071@smail.iitm.ac.in	https://lh6.googleusercontent.com/-yIneNHFdqzg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdesvunk1JXP6-CRV7_U809HQc2sg/s96-c/photo.jpg	117867040483756946449	\N	\N
21947	Uday Nair	udaynair2000@gmail.com	https://lh3.googleusercontent.com/-RM4zwDawyic/AAAAAAAAAAI/AAAAAAAAAG0/0i9S8E8c-WE/s96-c/photo.jpg	101470848680816951799	\N	\N
20810	NITESH KUMAR me16b063	me16b063@smail.iitm.ac.in	https://lh4.googleusercontent.com/-wauWw_Oplz4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc6cdGFgP2qGaATOPhha2rPRWqRxg/s96-c/photo.jpg	111592449927501447231	\N	\N
21125	PRAJJWAL KUMAR na16b115	na16b115@smail.iitm.ac.in	https://lh3.googleusercontent.com/-C1eyADkLwA8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reo-_qexzN-fi8_oqPEpbsc7pXuhA/s96-c/photo.jpg	114181895600121266149	\N	\N
21963	K Vikas Mahendar me18b146	me18b146@smail.iitm.ac.in	https://lh6.googleusercontent.com/--4EvFS5_pCM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reFE-J6tr1zW-jpg7Vhb6sfFHtViw/s96-c/photo.jpg	111325908744268034050	\N	\N
21048	Sanket Waghmare	sanketwaghmare033@gmail.com	https://lh4.googleusercontent.com/-ZwOXXD2bJ5s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMEMPzenI14WwzNFHF8I3cHuJXpqg/s96-c/photo.jpg	113696412226304739237	\N	\N
19625	Harshit Shrivastava ee18b037	ee18b037@smail.iitm.ac.in	https://lh6.googleusercontent.com/-_-spn-At8sY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd-hQEfQoYvFoliULPIJiiBFVz_Gw/s96-c/photo.jpg	106673190696374476111	\N	\N
21665	BANOTHU SHASHI KUMAR me16b007	me16b007@smail.iitm.ac.in	https://lh6.googleusercontent.com/-DyxEFGQQTu8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfGqerzAzGD21TbfIlSGygsldcr-g/s96-c/photo.jpg	109749255160356686705	\N	\N
21245	Sriram Ragunathan	srr1709@gmail.com	https://lh6.googleusercontent.com/-nM1nb0lZmIo/AAAAAAAAAAI/AAAAAAAAAQ4/JnlJuBLwD38/s96-c/photo.jpg	112876412127381726329	\N	\N
21360	Nitish Shah	nitishgupta784@gmail.com	https://lh6.googleusercontent.com/-mRweZ2l8TZs/AAAAAAAAAAI/AAAAAAAAA4A/xrY3fSSf2pw/s96-c/photo.jpg	117810709345028814872	\N	\N
21927	Sri Harsha	sriharshar1999@gmail.com	https://lh3.googleusercontent.com/-5KhcW0YSesk/AAAAAAAAAAI/AAAAAAAAAF4/Kt8fdVbvUWs/s96-c/photo.jpg	103796546597774896206	\N	\N
21956	Rajat Kumar	rajat4cricket@gmail.com	https://lh6.googleusercontent.com/-q5U_aRAtQYg/AAAAAAAAAAI/AAAAAAAAAMs/gKo4nrfrB0M/s96-c/photo.jpg	107461628160278570223	\N	\N
21979	Geetha krishna	pgeethakrishna@gmail.com	https://lh5.googleusercontent.com/-70h3OWfAalo/AAAAAAAAAAI/AAAAAAAADCY/BJX-hfa8t3w/s96-c/photo.jpg	115877582789598330117	\N	\N
21992	aayush bhutada	bhutada.aayush@gmail.com	https://lh3.googleusercontent.com/-ZPI1Ya0xgLw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZ9OmUVFLf8DoTq6Rw2CZolSRmZw/s96-c/photo.jpg	117494115772237022933	\N	\N
21995	RAG SANIL ae16b108	ae16b108@smail.iitm.ac.in	https://lh4.googleusercontent.com/-oxOTuDkP7zU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQODDb4SFB-ctMHYGFXXTAzn6I-mng/s96-c/photo.jpg	105691299700355446674	\N	\N
21999	Prasanna Shankarappa Abbigeri me17b121	me17b121@smail.iitm.ac.in	https://lh4.googleusercontent.com/-HCvfOyeTKUo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfZ-6i3tMXtx3CsFlYPQApq2L6oHw/s96-c/photo.jpg	106892782443561710330	\N	\N
21974	Rag Sanil	ragsanil456@gmail.com	https://lh5.googleusercontent.com/-_KHlL4UELFc/AAAAAAAAAAI/AAAAAAAAGAM/3TpAdwIgj4U/s96-c/photo.jpg	109854238168986987809	\N	\N
22018	R KAVIN KAILASH	rkavinkailash@gmail.com	https://lh3.googleusercontent.com/-r-v4_uKLNW0/AAAAAAAAAAI/AAAAAAAAEog/fI83DC7n_qg/s96-c/photo.jpg	115825834927273789916	\N	\N
21053	Santosh Kumar Mantripragada ce17b128	ce17b128@smail.iitm.ac.in	https://lh3.googleusercontent.com/-8H3FX1yDvN0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re6ORrGEc_S6q4DdfTmm3GkpYenOw/s96-c/photo.jpg	107482180927586997711	\N	\N
20640	Deepak Kumar	deepak3march98@gmail.com	https://lh5.googleusercontent.com/-ct0OvNiAboY/AAAAAAAAAAI/AAAAAAAAAFQ/8P8qN9eq2Pc/s96-c/photo.jpg	113469919102071155341	\N	\N
20368	Sreejanya R na17b033	na17b033@smail.iitm.ac.in	https://lh3.googleusercontent.com/-JvVg7YkFrTY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf4qosYLfBSwuCRgFCrC3YUBS5fPQ/s96-c/photo.jpg	105869193300848969627	\N	\N
22433	Saarthak Sandip Marathe me17b162	me17b162@smail.iitm.ac.in	https://lh4.googleusercontent.com/-9M3kz3B5rHQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcbd2Dm7b_dhlE46VEZi9JLtluuSQ/s96-c/photo.jpg	114495091859516183950	\N	\N
22525	Taneshq Verma me17b168	me17b168@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Gp3ED0Z7Iv4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPhaZ25WMunP_6POuoMZPYOzE9fJg/s96-c/photo.jpg	113492022217102262285	\N	\N
22034	Kethavath Surender Naik mm17b002	mm17b002@smail.iitm.ac.in	https://lh6.googleusercontent.com/-aPs3wHeTtns/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfLfkrR4kQlD6NqmtmKp0NzpwCSDA/s96-c/photo.jpg	112136155569381255577	\N	\N
22522	Darshan Maheshwari	darshanmaheshwari2000@gmail.com	https://lh6.googleusercontent.com/-QnwgZzRgfRo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rerEttdlKvkTO4FXZr1v-FCbZTdoQ/s96-c/photo.jpg	104450763274076701017	\N	\N
22193	VIVEK OOMMEN me16b176	me16b176@smail.iitm.ac.in	https://lh3.googleusercontent.com/-3r8Praj10Lk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcSaYwFTT3_zUai6mJguFm4ful8Ww/s96-c/photo.jpg	116009261508057191570	\N	\N
17961	Abhishek Reddy	abhishekreddyp17@gmail.com	https://lh6.googleusercontent.com/-rSf0xriPBUg/AAAAAAAAAAI/AAAAAAAAAA8/ug2pBbKMj2A/s96-c/photo.jpg	110009852962409606178	\N	\N
22094	Sameer Nandkishore Soni mm18b031	mm18b031@smail.iitm.ac.in	https://lh3.googleusercontent.com/-EtpzpLvL4x8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMynznB0R-C4IqB7CdSOBMHtCcKow/s96-c/photo.jpg	107915352569700271839	\N	\N
22412	sumanth devarasetty	sumanthdevarasetty@gmail.com	https://lh5.googleusercontent.com/-DmiynevQIHo/AAAAAAAAAAI/AAAAAAAAAFA/pvSiDcI5qOg/s96-c/photo.jpg	107836389792965014526	\N	\N
22321	Adithi K bt18m001	bt18m001@smail.iitm.ac.in	https://lh5.googleusercontent.com/-_gCHw_gFdk8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcTjtWCWezl98LzYCMPK33gquPZSQ/s96-c/photo.jpg	107625376588793983867	\N	\N
22672	Bais Akhilesh Anil me17b133	me17b133@smail.iitm.ac.in	https://lh5.googleusercontent.com/-hHJfxQLkCLk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOuSSJgbho7CzC9UI96ohCgs17R2A/s96-c/photo.jpg	117267055404556932067	\N	\N
22120	Karthik Sharma MSK	mskkarthik79@gmail.com	https://lh6.googleusercontent.com/-7luL_D4vEec/AAAAAAAAAAI/AAAAAAAAQvE/0xU_4wkBRjk/s96-c/photo.jpg	118225482088722822025	\N	\N
22113	Rohith M Athreya me17b033	me17b033@smail.iitm.ac.in	https://lh6.googleusercontent.com/-9X-1QjcJbOY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP8Qs8nDL0bhSWYDzjNPbAzh3g4MQ/s96-c/photo.jpg	112066593181711337536	\N	\N
22178	Prasad	mailtoprasadkrp@gmail.com	https://lh5.googleusercontent.com/--ExwcLrhPYY/AAAAAAAAAAI/AAAAAAAAClo/5Pf-2l6ND-M/s96-c/photo.jpg	105682417554191071301	\N	\N
22411	Manoj S me18b152	me18b152@smail.iitm.ac.in	https://lh6.googleusercontent.com/-EqYFOy_HhGg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfP0b7L7rAgfANJsUnQ-U7YkoL6FA/s96-c/photo.jpg	117553069435742054785	\N	\N
22377	Vamsi Krishna Mula	mulavamsikrishna96@gmail.com	https://lh5.googleusercontent.com/-ahTlENuy2r8/AAAAAAAAAAI/AAAAAAAAS1s/GHabn77S-hQ/s96-c/photo.jpg	110557781693948154226	\N	\N
22217	jeswant krishna	jeswantkrishna@gmail.com	https://lh3.googleusercontent.com/-TrGHjHzPsw4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfIdem_jw8_Gdsx4Z2qp62TgQTaiA/s96-c/photo.jpg	101204317216387759803	\N	\N
22476	Aayush Raj mm18b008	mm18b008@smail.iitm.ac.in	https://lh4.googleusercontent.com/-1D3qKgd7iK8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOFhrYt-vvTGyan7a90tlFbDkl8XQ/s96-c/photo.jpg	112393030428376886191	\N	\N
22545	S Naveen me18b166	me18b166@smail.iitm.ac.in	https://lh6.googleusercontent.com/-YTJ7LDBmHBY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reVafPRbQqEmnrnq-MCpl9hZX2AtQ/s96-c/photo.jpg	114159781783372500287	\N	\N
23019	Pinak Das	pinakdas975@gmail.com	https://lh3.googleusercontent.com/-hr5PyUkHrnc/AAAAAAAAAAI/AAAAAAAADEI/0abaiXsck2Y/s96-c/photo.jpg	104634840831330665715	\N	\N
22521	Kalisetti Sai Vishnu ch18b051	ch18b051@smail.iitm.ac.in	https://lh3.googleusercontent.com/-AIarXwqtnQw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMjMlVAcpVQFt-twS2zTXLEzw5hhQ/s96-c/photo.jpg	104926536466147692972	\N	\N
22567	Sai Mounika	saimounika.iitm@gmail.com	https://lh6.googleusercontent.com/-FiXgOd1aS3E/AAAAAAAAAAI/AAAAAAAAJxc/TgmGSQMT7L0/s96-c/photo.jpg	109487415983875666548	\N	\N
22378	Sathya Narayanan	itzsath@gmail.com	https://lh3.googleusercontent.com/-bW74s773E7k/AAAAAAAAAAI/AAAAAAAABWY/xFtMkf2_ZQM/s96-c/photo.jpg	114645348011786260170	\N	\N
22562	Kadhir N me18b147	me18b147@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rp8PMTgP5wA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdBa63HvW99P8z5KrbeHhzGallmXA/s96-c/photo.jpg	106557254269091722228	\N	\N
22536	YENUGU SIVA SAI KRISHNA ae16b115	ae16b115@smail.iitm.ac.in	https://lh5.googleusercontent.com/-rgjgqhNauk8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdwCqbkEZr3MSPFmD1B8oXv9y_8NQ/s96-c/photo.jpg	117116469784985259310	\N	\N
22938	Yeshwanth Yeshu	yeshu808@gmail.com	https://lh6.googleusercontent.com/-ferwXVONzVY/AAAAAAAAAAI/AAAAAAAAAlY/f0fH0cG3kow/s96-c/photo.jpg	110686490924474524488	\N	\N
22958	Bharath Sureshbabu	bharathsureshbabu1@gmail.com	https://lh3.googleusercontent.com/-tw9l1To5orU/AAAAAAAAAAI/AAAAAAAAFK4/KssERQ0sHfk/s96-c/photo.jpg	103379898408398890704	\N	\N
22800	Sagnik Datta ce18b122	ce18b122@smail.iitm.ac.in	https://lh3.googleusercontent.com/-ZlslvbcNsdw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPeYcpbT0wmZSosVFawHNCDI4uZdg/s96-c/photo.jpg	117953295521680922925	\N	\N
22755	udith m	udithm123@gmail.com	https://lh5.googleusercontent.com/-mCDvFtJ5IGs/AAAAAAAAAAI/AAAAAAAABLo/VjLfJ6H2Ia8/s96-c/photo.jpg	100341754789141716230	\N	\N
22135	L.P.MANIKANDAN me15b115	me15b115@smail.iitm.ac.in	https://lh5.googleusercontent.com/-IqmVuJjTg2o/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPlsbxXGjtJ0UPEAOzYfXQqM5a2UQ/s96-c/photo.jpg	109352364693906201046	\N	\N
22865	dharmana chandra mouli	dharmanachandramouli1999@gmail.com	https://lh6.googleusercontent.com/-2KVOCGPzV7g/AAAAAAAAAAI/AAAAAAAACCY/WHCzzr9Zc5w/s96-c/photo.jpg	104974498060929724022	\N	\N
22959	BHARATH S me15b015	me15b015@smail.iitm.ac.in	https://lh3.googleusercontent.com/-NYH4nc1f6EA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdjozLwH0eXDrOdm4B8hdzlaHW1uw/s96-c/photo.jpg	112641700725756825255	\N	\N
22990	Maniyala Yashwant ee17b107	ee17b107@smail.iitm.ac.in	https://lh6.googleusercontent.com/-38r44RWtLiY/AAAAAAAAAAI/AAAAAAAAAA0/Ey5-bX5TevY/s96-c/photo.jpg	108292690118262690170	\N	\N
23160	Gorantala Rohith Kumar ee18b008	ee18b008@smail.iitm.ac.in	https://lh5.googleusercontent.com/-7t_sh9qsdMc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNvHGutfIH3nTJy9xIu__JTcSDk3w/s96-c/photo.jpg	102189547402903864598	\N	\N
23361	Sri Anirudh Reddy Bolusani	ee17b043@smail.iitm.ac.in	https://lh3.googleusercontent.com/-yB_T-aKNQZg/AAAAAAAAAAI/AAAAAAAAAF0/htYTQ7fuo0s/s96-c/photo.jpg	113673177751333352404	\N	\N
23562	Vishal kumar	makeyourwish7@gmail.com	https://lh4.googleusercontent.com/-1SaPJ6MGrG4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc5JyT0BTw8Tf3A45neBSRmFfctzw/s96-c/photo.jpg	116011204695993253377	\N	\N
23852	Narendhiran R ch18b015	ch18b015@smail.iitm.ac.in	https://lh6.googleusercontent.com/-i2P6fN9SF84/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rePiQ26YTVLKCotAFe8e23Ig_Vo0Q/s96-c/photo.jpg	112959020768381661176	\N	\N
23895	Anmol Bansal	anmolbansal151999@gmail.com	https://lh4.googleusercontent.com/-xpU7IbZbX7k/AAAAAAAAAAI/AAAAAAAAAGU/23cwDMCUPKM/s96-c/photo.jpg	109862116486377951732	\N	\N
24141	Vivek Sharma me18s038	me18s038@smail.iitm.ac.in	https://lh3.googleusercontent.com/-onSx6MOZ_9E/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdMJu49pUMnUVzWjIVlw69Z6f-zRg/s96-c/photo.jpg	100970809889276910970	\N	\N
23740	Tushar Anand	anandtushar0@gmail.com	https://lh4.googleusercontent.com/-KbsxPzBwrts/AAAAAAAAAAI/AAAAAAAAAlo/gdiR94PbJsM/s96-c/photo.jpg	101438283653535686514	\N	\N
24798	Kaushik Surendran Chettiar me17b054	me17b054@smail.iitm.ac.in	https://lh3.googleusercontent.com/-y5Dm_Uf5yyU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfKLC5rj1oDyrvc31i0Kw_2D12x0A/s96-c/photo.jpg	106378460874227252041	\N	\N
23713	Razeem Ahmad Ali Mattathodi ed17b022	ed17b022@smail.iitm.ac.in	https://lh4.googleusercontent.com/-hjMPSZeK4J4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPMBeLWeUk2VcqJ-2IUSNjSfq5wlA/s96-c/photo.jpg	101207355282354584537	\N	\N
24008	Sagar Suryawanshi	suryawanshisagar97@gmail.com	https://lh6.googleusercontent.com/-vm5xq83DamM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rday9XhwHYcUQGyaj812rGD3Rupiw/s96-c/photo.jpg	106377076448856502613	\N	\N
23544	DIPAM JIGNESH SHAH ch15b078	ch15b078@smail.iitm.ac.in	https://lh4.googleusercontent.com/-FRPRDahXbRc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNz4UW8EvG6XVnDQFvDAa659JBckQ/s96-c/photo.jpg	110884617323037851906	\N	\N
24837	Perumalla Ritwik me18m097	me18m097@smail.iitm.ac.in	https://lh6.googleusercontent.com/-XWdYoMB5dhc/AAAAAAAAAAI/AAAAAAAAAAc/2-_mr_grnrE/s96-c/photo.jpg	107374093030287723532	\N	\N
24034	BAMBOM PERME ce16b024	ce16b024@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ih5aV8hutbE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf67nGYX2mwVSxamJjMjCruM9gHKg/s96-c/photo.jpg	107532999868296523502	\N	\N
24416	Joaquim Fernandes	joaquimfernandes104@gmail.com	https://lh5.googleusercontent.com/-BE08LsWhMKU/AAAAAAAAAAI/AAAAAAAAACY/zHZXLD8ySus/s96-c/photo.jpg	109337807907743319459	\N	\N
22825	Shaik Riyaz	skriyaz20699@gmail.com	https://lh5.googleusercontent.com/-Vrh53NLL7uM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reXru39Rqn5cEFRuqWypTL4W-tZ2A/s96-c/photo.jpg	100759552192333828461	\N	\N
23761	mridul rathore	rathoremridul32@gmail.com	https://lh4.googleusercontent.com/-wYW_M2gEGpY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMkDijf2WK070_H1l2WIOwthpSk5w/s96-c/photo.jpg	114164113258062776352	\N	\N
23784	Mohit Kumar ms17s013	ms17s013@smail.iitm.ac.in	https://lh3.googleusercontent.com/-x-ZjUr_LZ6s/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3resnmzkkahw10eGN0JXNri81gZQ4A/s96-c/photo.jpg	104682014066766388268	\N	\N
24994	Koyyana Nikhil Yadav ee17b014	ee17b014@smail.iitm.ac.in	https://lh3.googleusercontent.com/-MPZHSzsNzkA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcegTEh1_B4PfvEhv_YVaweIgc8cA/s96-c/photo.jpg	110583083225141718209	\N	\N
24077	Akshay Thomas	akshaythomas.p@gmail.com	https://lh3.googleusercontent.com/-1okMY2Hd6gc/AAAAAAAAAAI/AAAAAAAAA-o/KtuNquBPO2g/s96-c/photo.jpg	108973532333561486167	\N	\N
24963	Suraj Dange	surajdange1602@gmail.com	https://lh5.googleusercontent.com/-pomU3rdVUUU/AAAAAAAAAAI/AAAAAAAARXM/7UYT99d9MEE/s96-c/photo.jpg	117722541088958689814	\N	\N
16540	Harshit Jindal ch17b112	ch17b112@smail.iitm.ac.in	https://lh3.googleusercontent.com/-KH0gDrTZBvE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc5dpwNCJHsyAzsn_Y-8ikbjy65dQ/s96-c/photo.jpg	103242500128253530271	\N	\N
24204	YEGUVAPALLI THRELOK	thre6166@gmail.com	https://lh4.googleusercontent.com/-bI5lYM_HhXw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reXMdqINmsivXSgJxrQ_ZXSoADBGA/s96-c/photo.jpg	115919916983778122153	\N	\N
24613	Nishant Kumar Khedlekar ms18s010	ms18s010@smail.iitm.ac.in	https://lh4.googleusercontent.com/-l5DBVdDmWvs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMmlxxTKGUSKsDB3xksgtsUs4DqYA/s96-c/photo.jpg	114422993971584074304	\N	\N
24360	Neeharika Chinthalapalli	neehu.vani3@gmail.com	https://lh4.googleusercontent.com/-BQ_WLq9tT14/AAAAAAAAAAI/AAAAAAAAAXk/VfW8uSxy2YI/s96-c/photo.jpg	109853930299444486331	\N	\N
24341	Tony Fredrick	tfredrick112@gmail.com	https://lh4.googleusercontent.com/-0tTB_RekohU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcMLCNNtk-km7m8p9JLSEJBce0azw/s96-c/photo.jpg	105194294420005024985	\N	\N
24962	Mattapally Nikhil ee17b138	ee17b138@smail.iitm.ac.in	https://lh3.googleusercontent.com/-TVl_4Qtd-rw/AAAAAAAAAAI/AAAAAAAAAWg/uxoiH-i9mh0/s96-c/photo.jpg	116709489304696093648	\N	\N
22332	Tavva Alekhya ch18b116	ch18b116@smail.iitm.ac.in	https://lh6.googleusercontent.com/-X3NEc20NqPw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNvBoUAv7H6Lt1SZMLNLt7M8TRYOg/s96-c/photo.jpg	113713806575169641545	\N	\N
24526	P Sai Venkat Kushal ee17b141	ee17b141@smail.iitm.ac.in	https://lh6.googleusercontent.com/-Imd0GSr9DRY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfU2mCYQePPYwh6t0r79RG3idNkDQ/s96-c/photo.jpg	109709409847775998792	\N	\N
25013	Rakesh R	am14d006@smail.iitm.ac.in	https://lh4.googleusercontent.com/-iekii5bf8VE/AAAAAAAAAAI/AAAAAAAAAKE/STRr6jFic4U/s96-c/photo.jpg	113169541347174262384	\N	\N
25030	Lucky Sharma	asshutoshsharma@gmail.com	https://lh6.googleusercontent.com/-xWAZc1e_5r4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOvwfamL9gH6IXuTo2e_0hTFDn3ZQ/s96-c/photo.jpg	101106264716659583583	\N	\N
25103	AKANKSHA AJIT FULZELE ee15b071	ee15b071@smail.iitm.ac.in	https://lh5.googleusercontent.com/-GTW25ehWJPE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcrOLktY5EJtPVCbMo8HeGUNLw67w/s96-c/photo.jpg	105157880401213216108	\N	\N
25457	PANGA LAHARI cs16b105	cs16b105@smail.iitm.ac.in	https://lh5.googleusercontent.com/-eoe2q0dfw-U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPdFb5LQVSU0jEbXdgMy-NBGmBpFQ/s96-c/photo.jpg	112964373295196225922	\N	\N
25416	RAMU RAJU	kingramu0777@gmail.com	https://lh3.googleusercontent.com/-fP6TFfVQoN8/AAAAAAAAAAI/AAAAAAAAAfk/0G3LQTav8fI/s96-c/photo.jpg	117021699570065796472	\N	\N
25460	Kusumitha Kampara	kusumitha1999@gmail.com	https://lh3.googleusercontent.com/-vYNX7b_xm_s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNrv0XXXu3FgTkU-YjxvhHbo904jA/s96-c/photo.jpg	105128571150899208559	\N	\N
25496	Tanay Dwivedi	tanaydw.99@gmail.com	https://lh3.googleusercontent.com/-JoSWd3sBEK4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc9LN3MqG2feUoWKE3GXoTK3ndJpg/s96-c/photo.jpg	115973126818073760547	\N	\N
25006	Advait Walsangikar	awalsangikar@gmail.com	https://lh3.googleusercontent.com/-cUcMCD-nXpo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdQCjPuNgyIO49NdAhtiyRSpw4sFg/s96-c/photo.jpg	109658648941971927034	\N	\N
25487	Kaja Sai Manikanta me17s074	me17s074@smail.iitm.ac.in	https://lh5.googleusercontent.com/-b_Antk4yD2M/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOsieokTkzo1hVjKRmTa7foCR9xPQ/s96-c/photo.jpg	103582724679949481090	\N	\N
26154	Prashis Shirsat	prashisshirsat17@gmail.com	https://lh3.googleusercontent.com/-l4-FPnNmQPY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcGSc9_bMo-phQu_KJYEbSEu1Jgiw/s96-c/photo.jpg	104093527338529559700	\N	\N
26581	Abhishek Kumar ee18m076	ee18m076@smail.iitm.ac.in	https://lh3.googleusercontent.com/-YtCPlF2CyG4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcvvsp1gSVib3tDyqdBUwmQ1iYCyA/s96-c/photo.jpg	106968421421627012684	\N	\N
27165	Madhan Nadella	madhanmoni01@gmail.com	https://lh5.googleusercontent.com/-vcmjrlw8Kd8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcZsD8ivbnvQsLE-9BfjC5Kib5QQw/s96-c/photo.jpg	106697543274326521115	\N	\N
26261	Nandha Kumar S me18s050	me18s050@smail.iitm.ac.in	https://lh5.googleusercontent.com/-BptOZRtK53k/AAAAAAAAAAI/AAAAAAAAAAc/G17HBWYjjCo/s96-c/photo.jpg	107354349562927299129	\N	\N
27028	Jenna Smith	jennawilliamsmith@gmail.com	https://lh3.googleusercontent.com/-ttZcKc1TBEA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re9swOjpkcrntPYIda_ED5O2x4ebg/s96-c/photo.jpg	107191617387841036716	\N	\N
26232	Abhijeet Gajanan Ingle ae17b016	ae17b016@smail.iitm.ac.in	https://lh6.googleusercontent.com/-kmIU_k-wqOs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdhKmSQxaQMNthnfUqTLsZZFSN4cw/s96-c/photo.jpg	100427472165562945104	\N	\N
5341	Meenal Sanjay Kamalakar ce17b046	ce17b046@smail.iitm.ac.in	https://lh3.googleusercontent.com/-cw8LLKKZd7g/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcsRFPz7DtSUmqhOFgMJvcP8qeK4A/s96-c/photo.jpg	113973502411437413660	\N	\N
26463	Sathish R	sathishravikumaraswamysrk@gmail.com	https://lh3.googleusercontent.com/-YJ5Fkmh280M/AAAAAAAAAAI/AAAAAAAAErg/ZGw1oFDauBY/s96-c/photo.jpg	112949199454355147888	\N	\N
26776	Aaditya Sharma	sharmaaaditya378@gmail.com	https://lh3.googleusercontent.com/-frATPH71Q5o/AAAAAAAAAAI/AAAAAAAACCg/D4NqHI_a5Mg/s96-c/photo.jpg	106260862891379060047	\N	\N
24678	Students'Head E Cell head_ecell	head_ecell@smail.iitm.ac.in	https://lh6.googleusercontent.com/-8oIviyolKJo/AAAAAAAAAAI/AAAAAAAAAHc/CWlzrQ4x-38/s96-c/photo.jpg	106382963580686831393	\N	\N
25651	Dhyey Desai	dhyeydesai09@gmail.com	https://lh5.googleusercontent.com/-Lfv8HtfL4qI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3relmO_JqBdPNZKUJ_k3P2Yiodq_XA/s96-c/photo.jpg	100876230019394013623	\N	\N
26481	Manthan Solanki	manthansolanki19@gmail.com	https://lh6.googleusercontent.com/-Z7VxytwG5c0/AAAAAAAAAAI/AAAAAAAAADs/QIJq27VM_YY/s96-c/photo.jpg	112618428019925030389	\N	\N
26155	Dhruv Shah	ae17b107@smail.iitm.ac.in	https://lh3.googleusercontent.com/-RS0XXC9hoN0/AAAAAAAAAAI/AAAAAAAAAbg/7wx-LQVS_dg/s96-c/photo.jpg	106650680769126177630	\N	\N
25839	G PRADEEP ee16b050	ee16b050@smail.iitm.ac.in	https://lh6.googleusercontent.com/-rzeqYf6NhVg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMiuy7vDu6k9Kh1j6jUORfBL6ZeJQ/s96-c/photo.jpg	100265483523057320076	\N	\N
20731	Harvinder Solanki	harvindersolanki07@gmail.com	https://lh5.googleusercontent.com/-dTzYMs1GOUQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOcMNQhljtJkWrrHhiEY6yPOlNJJA/s96-c/photo.jpg	107214507937748421041	\N	\N
26752	Aman Gautam	aman.gautam34@gmail.com	https://lh6.googleusercontent.com/-aGK8QnG6P8k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfSUKoIlde-55JnjJaBE3xiFiFH1A/s96-c/photo.jpg	111418050118613804064	\N	\N
27135	Aman Agarwal	amanagarwal30121998@gmail.com	https://lh4.googleusercontent.com/-sVwU0LKIvGw/AAAAAAAAAAI/AAAAAAAAAFY/Ni2k3jtUGJw/s96-c/photo.jpg	109149479407133340377	\N	\N
26909	md tufail ahmad	tuufail786@gmail.com	https://lh3.googleusercontent.com/-SuZkFguC1Yo/AAAAAAAAAAI/AAAAAAAAB_8/CLJMezXWEms/s96-c/photo.jpg	104736555837409789469	\N	\N
27039	Anup Gurav	mm17b011@smail.iitm.ac.in	https://lh5.googleusercontent.com/-gE427ef9NYk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reYdg_5VrFCnbATqR6eIU05OBMHPg/s96-c/photo.jpg	104811365561245605458	\N	\N
26936	Sana Ismail	sanaismail2157@gmail.com	https://lh3.googleusercontent.com/-Vy0rXytZdsI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3repC1pya1rP2Tk9UkR5xzr6F5YJoA/s96-c/photo.jpg	106397610480480776616	\N	\N
26910	Abhinav Anand	abhinavanand1905@gmail.com	https://lh5.googleusercontent.com/-Ts18lR_k-bk/AAAAAAAAAAI/AAAAAAAAFHE/oBRIjMwSEaU/s96-c/photo.jpg	112049149719514009007	\N	\N
26839	Arihant Samar cs18b052	cs18b052@smail.iitm.ac.in	https://lh3.googleusercontent.com/-g1xcF9iIWjk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc0Opl1f_47rlL8dqNVz0vRAxzRXA/s96-c/photo.jpg	114372531126316025056	\N	\N
26500	Devashish Soni	hwb.devashishsoni@gmail.com	https://lh3.googleusercontent.com/-628__5apSpM/AAAAAAAAAAI/AAAAAAAAAAU/bgks0YCChtg/s96-c/photo.jpg	102402073813591617342	\N	\N
26545	Patel Vaibhavkumar Kirtibhai me17b176	me17b176@smail.iitm.ac.in	https://lh3.googleusercontent.com/-V0dva2b-4QQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reXwgt4O5JmUVZ7tgQWyXVFnR4pYQ/s96-c/photo.jpg	115363131130228230104	\N	\N
27236	Srujana Pillarichety	srujanapillarichety@gmail.com	https://lh5.googleusercontent.com/-bm54ZOK4yjc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOhpXWdYKcA51l9HIs6KcItTJ1ySA/s96-c/photo.jpg	106771827630157931759	\N	\N
27207	Narendra Singh Kushwaha	narendrasingh1998kushwaha@gmail.com	https://lh3.googleusercontent.com/-tVOmKIJbCUw/AAAAAAAAAAI/AAAAAAAAIC4/LGBTYp8Skss/s96-c/photo.jpg	109462656671413477932	\N	\N
27256	Info SynerSense	synersense@gmail.com	https://lh4.googleusercontent.com/-GGhEPAXtcXg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdMbn6sYrKBDrfEPku9OsBPbPj8Wg/s96-c/photo.jpg	105396769861562619378	\N	306
26165	Keshav Saini	keshavsaini.hun@gmail.com	https://lh3.googleusercontent.com/-_n_0EblOYls/AAAAAAAAAAI/AAAAAAAABvk/_cvBrEnSP7k/s96-c/photo.jpg	116969460420605090641	\N	\N
27317	Hitesh Pawar	hiteshpawar2705@gmail.com	https://lh6.googleusercontent.com/-B8G5YpDbZrU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPJZj81dkPDIZFP60ptr2L-LUlhMA/s96-c/photo.jpg	113898531098001531017	\N	\N
27360	Ashish Maknikar	asmaknikar@gmail.com	https://lh4.googleusercontent.com/-mxigrsSNJ5M/AAAAAAAAAAI/AAAAAAAABPM/P1YXZS66LMk/s96-c/photo.jpg	105981475021868380652	\N	\N
27594	Prallavit Devgade	ppdevgade@mitaoe.ac.in	https://lh6.googleusercontent.com/-6MBLrlQW1D4/AAAAAAAAAAI/AAAAAAAAACw/rf3KYlhe8Lc/s96-c/photo.jpg	106333256045300862628	\N	\N
27678	Suhas Pai cs17b116	cs17b116@smail.iitm.ac.in	https://lh4.googleusercontent.com/-_lBNyXxvSlk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcmohnih8JFBPafGZmNQ-TuGKd9Ww/s96-c/photo.jpg	104939767890573263935	\N	\N
27188	Surjeet Kumar Verma	surjeetverma2017@gmail.com	https://lh5.googleusercontent.com/-hxg16Hptyqw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdVREMS9ZpJinAr5UdH2lx6UEOQbg/s96-c/photo.jpg	107302960648089981349	\N	\N
27273	Apurva Itkarkar	itkarkarapurva@gmail.com	https://lh3.googleusercontent.com/-jqFUQhMtA8g/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNI8XMqrgEWa9trB4viHobXC84HFw/s96-c/photo.jpg	108995877968137167099	\N	\N
27647	Surbhi Garg bt18m027	bt18m027@smail.iitm.ac.in	https://lh3.googleusercontent.com/-bK9iU8fxC6M/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reReiPCMdt97KWgNMDWGSuG9FnsRw/s96-c/photo.jpg	103681198192226683449	\N	\N
28615	Yashasvi Misra	misrayashasvi292@gmail.com	https://lh4.googleusercontent.com/-_ld5xGLLIGk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfmHSai1Jjghkvz9yNn6ioPyfLb3Q/s96-c/photo.jpg	105129447643258192565	\N	\N
28194	Suhas Sathesh Rao me17b069	me17b069@smail.iitm.ac.in	https://lh5.googleusercontent.com/-nq3vT5_SOEQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfjM_-V0gFYiE-ph0vrw9TE8_PX4g/s96-c/photo.jpg	109375259884013763053	\N	\N
27914	Karthik Srinivasan	kodikarthik21@gmail.com	https://lh5.googleusercontent.com/-kAiEn6JTt3s/AAAAAAAAAAI/AAAAAAAACD4/wjLTyJBZHRg/s96-c/photo.jpg	117220098631782020186	\N	\N
28537	Bhanwar Lal Rawal ee18m020	ee18m020@smail.iitm.ac.in	https://lh5.googleusercontent.com/-J8DsN0jvv6w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdOQ9nYbVEpgwT-q8g4KcZlhxuevg/s96-c/photo.jpg	108612518526783380262	\N	\N
27750	Awik Dhar ch18b041	ch18b041@smail.iitm.ac.in	https://lh3.googleusercontent.com/-ZwlJXIxgvBo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNPCEHPoUrHBXyew1shUlqfoEG1LQ/s96-c/photo.jpg	115045186166643555681	\N	\N
28205	Harisankar Ramaswamy	hsankar94@gmail.com	https://lh5.googleusercontent.com/-wR2NZUoqGoM/AAAAAAAAAAI/AAAAAAAAAFw/_8nwJWoF-IU/s96-c/photo.jpg	118364658301318604496	\N	\N
27806	ARYAMAN THAKUR	aryaman.thakur999888@gmail.com	https://lh6.googleusercontent.com/-cFhTQmPC8-w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reF6DL1zhSnWPRYSldpEEGq3ndVrw/s96-c/photo.jpg	116843335163451067244	\N	\N
27847	Nitish Dobhal	nitishdobhal281@gmail.com	https://lh4.googleusercontent.com/-dBshanjI6Ss/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd9kHgHvtpt4BBJKlUIk82YOj6T5A/s96-c/photo.jpg	117666344407524188304	\N	\N
28100	RAMYAK SANGHVI	ramyaksanghvi@gmail.com	https://lh6.googleusercontent.com/-tbPUeDMH4kg/AAAAAAAAAAI/AAAAAAAAMg8/qKSCLM69KsE/s96-c/photo.jpg	114899068497843267952	\N	\N
28206	PRIYA YADAV	py10089@gmail.com	https://lh5.googleusercontent.com/-LhddOAazdR4/AAAAAAAAAAI/AAAAAAAADa8/2Kq3dYV0KsY/s96-c/photo.jpg	103815376056397201895	\N	\N
28783	Adithya Swaroop	ee17b115@smail.iitm.ac.in	https://lh4.googleusercontent.com/-37oCxLGFdj4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM5iBQSXEKIvrl-3zUeUHCv4Ak0Ww/s96-c/photo.jpg	111444722576795034356	\N	\N
28239	Internship E-Cell IIT Madras	intern_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-auOPKpcCSfc/AAAAAAAAAAI/AAAAAAAAAAs/f5l_Wtk6XR8/s96-c/photo.jpg	103563223572046648148	\N	\N
27909	Shivam Chandak	chandakshivam@gmail.com	https://lh5.googleusercontent.com/-8WI4go1_awY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reK5Q-o7-Cv-Kq36J0VEwlDbFzpyA/s96-c/photo.jpg	105471787389153334156	\N	\N
27854	Sovan Kar	iamsovankar@gmail.com	https://lh4.googleusercontent.com/-bTvtwBpI_BQ/AAAAAAAAAAI/AAAAAAAAAAU/gWIxMncbFGU/s96-c/photo.jpg	113266173583192039644	\N	\N
30750	priya suresh	priyasuresh434@gmail.com	https://lh6.googleusercontent.com/-wrGeIuS2yPY/AAAAAAAAAAI/AAAAAAAAaUY/AhmyvS-rxGw/s96-c/photo.jpg	100037774541223863716	\N	\N
28908	Chathurya Challa	challachathu@gmail.com	https://lh3.googleusercontent.com/-Bv12A4nU_XA/AAAAAAAAAAI/AAAAAAAAACs/XRadU8J8l0E/s96-c/photo.jpg	108499776031400240541	\N	\N
27999	Mohit Kushwah bs18b022	bs18b022@smail.iitm.ac.in	https://lh5.googleusercontent.com/-VeZ_NBIOOaU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc4gcY0czEo9jsPRVwXIhSVVHHooA/s96-c/photo.jpg	115429325526115543173	\N	\N
28113	LAKSHMAN KANTH BOYINA me16b021	me16b021@smail.iitm.ac.in	https://lh5.googleusercontent.com/-cYE3dEvfHbk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPpXRonqnS6EOyAWJXS_6K4M6tsCQ/s96-c/photo.jpg	114229644261800945706	\N	\N
28025	Dhananjay Katkar	katkarj@gmail.com	https://lh3.googleusercontent.com/--BJF26t-5ys/AAAAAAAAAAI/AAAAAAAAA_k/-UCOwxi7eL8/s96-c/photo.jpg	114988120529880919375	\N	\N
28020	Saarthak Marathe	saarthakmarathe1@gmail.com	https://lh3.googleusercontent.com/-Bg2eS-swuAU/AAAAAAAAAAI/AAAAAAAAA7g/nJwFtl3aVrQ/s96-c/photo.jpg	103934013085623006665	\N	\N
28276	Neerav Oraon ep18b010	ep18b010@smail.iitm.ac.in	https://lh5.googleusercontent.com/-Q-WO7YYANOc/AAAAAAAAAAI/AAAAAAAAAGs/4R0n-vKNa8s/s96-c/photo.jpg	117522885357146815824	\N	\N
28772	Shreyash Patidar	shreyash16patidar@gmail.com	https://lh4.googleusercontent.com/-IHq9g2QvgyU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQML_CyYbylW5ymKPQbpvWfkg1KscA/s96-c/photo.jpg	116542312738324327668	\N	\N
28928	Ashish Jacob Abraham	ashishjacob9@gmail.com	https://lh4.googleusercontent.com/--01y0EpKlkE/AAAAAAAAAAI/AAAAAAAAAKs/QQSO8J93QDc/s96-c/photo.jpg	101450182798146604393	\N	\N
28919	Ashish Jacob Abraham mm17b013	mm17b013@smail.iitm.ac.in	https://lh5.googleusercontent.com/-RCHaMvmqGP0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPaG11D_LjBdLA1j6OlTtWulduPpw/s96-c/photo.jpg	103694818377194007378	\N	\N
28991	Sheeba Elizabeth Reuban ch18b023	ch18b023@smail.iitm.ac.in	https://lh3.googleusercontent.com/-eIP4Fu7gkmc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO2UcrimgIzjAcJXUoYqyk9XAYAXQ/s96-c/photo.jpg	104256975787115165957	\N	\N
29026	Gunjan Mudgal	gunjanmudgal12@gmail.com	https://lh5.googleusercontent.com/-cLkAEM0tBQk/AAAAAAAAAAI/AAAAAAAAIcQ/OPSh9DBoKeU/s96-c/photo.jpg	109373480618194925149	\N	\N
28966	Nikilesh B ee17b112	ee17b112@smail.iitm.ac.in	https://lh5.googleusercontent.com/-IVS21u40xg8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reJb2hUwm2vUn2BR0l2mQE35RHA5A/s96-c/photo.jpg	107872733361138175010	\N	\N
29059	Jashwanth sai Yadlapally	yadlapallyjashwanthsai@gmail.com	https://lh5.googleusercontent.com/-q-UW2UZLf98/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfHO6PXpcTWffaRQuQmu3Wbr-2pMA/s96-c/photo.jpg	104453942492243173593	\N	\N
28652	Lite yagami	rjtbhndr@gmail.com	https://lh4.googleusercontent.com/-3JOu5L0_a_0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfrWH-NVR8pnqd-F96HRI6ghZPj1g/s96-c/photo.jpg	112903484933357443701	\N	\N
29103	Deepanshu Aggarwal	d.aggarwal276@gmail.com	https://lh4.googleusercontent.com/-6-bC8jOJdmw/AAAAAAAAAAI/AAAAAAAAE38/RljhgScq9nE/s96-c/photo.jpg	102591162228450335149	\N	\N
29062	Yadlapally Jashwanth Sai cs18b048	cs18b048@smail.iitm.ac.in	https://lh6.googleusercontent.com/-5CEEKXpLogE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfgxdz3kzzzjHGUrJ9yCvqus5PYCA/s96-c/photo.jpg	105554845638346109132	\N	\N
29158	Saini Srividya	sainisrividya6@gmail.com	https://lh4.googleusercontent.com/-cQEKsmyEfA4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reP8a8aD1pbPh2yDjPouWM2aN1l0w/s96-c/photo.jpg	100296111466514776944	\N	\N
29247	Sushanth Reddy	daram.sushanth2000@gmail.com	https://lh4.googleusercontent.com/-zm6bm4xiubE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdE7zJpgydsFpbil-ejG-8uJiioZQ/s96-c/photo.jpg	108745443239295634264	\N	\N
28246	Arunteja Reddy Gopireddy	aruntejagopireddy18@gmail.com	https://lh4.googleusercontent.com/-xGnJlnMSGlk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdBmNlUYlGUq5BiVvuH5W6cV-deTQ/s96-c/photo.jpg	113655434189423231739	\N	\N
29629	tarun bathwal	tarun.bathwal@gmail.com	https://lh3.googleusercontent.com/-vl3SdSDtAPI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPN6yuLVYaSySo4dogWzdsiK9JQ2w/s96-c/photo.jpg	104568218955685711298	\N	\N
16513	Harshal Shedolkar bt18m014	bt18m014@smail.iitm.ac.in	https://lh5.googleusercontent.com/-w2WJwGIKc2c/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcth3GsW8sYDgfZr5OTEpL5rYoCSg/s96-c/photo.jpg	101798089697138461999	\N	\N
30336	Devansh Jain	devanshjain293@gmail.com	https://lh6.googleusercontent.com/-GTKTFzgAJPU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc728mXEXuxdE_wiy6sV_J3-cWluw/s96-c/photo.jpg	104993826254420756174	\N	\N
29443	saithrishul kudumala	saithrishulkudumala@gmail.com	https://lh4.googleusercontent.com/-wmwXz5LJOIo/AAAAAAAAAAI/AAAAAAAAAAw/XweoS4aGkfY/s96-c/photo.jpg	100868456227333581488	\N	\N
30319	Rajat Singhal	cs17b042@smail.iitm.ac.in	https://lh6.googleusercontent.com/-rHxyAd0dWLE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPEgSh0efk0CGfeFcLpcZ9w6jD9Pw/s96-c/photo.jpg	109519412055323157832	\N	\N
30060	Hari Priya Palla na18b020	na18b020@smail.iitm.ac.in	https://lh3.googleusercontent.com/-tqKKlgpg0j0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcASKB9ZsmIAxctvkTsFomK__Dtqg/s96-c/photo.jpg	115819299473070317876	\N	\N
29151	Rishika Varma K cs18b045	cs18b045@smail.iitm.ac.in	https://lh6.googleusercontent.com/-9jh-a3kxZME/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMlONTL0Dmy1VOxB9Mp7Emev7BIUg/s96-c/photo.jpg	100243732331133126469	\N	\N
30469	Bhavesh sahu	bs22111999@gmail.com	https://lh4.googleusercontent.com/-TefIrhtPi1E/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf0QZp0cyXJfHmwGy4yBV6n9H95tw/s96-c/photo.jpg	114705015611565927812	\N	\N
30192	JAYALAKSHMI SRI SRUTHI DUVVURI	sruthiduvvuri3@gmail.com	https://lh5.googleusercontent.com/-C6RkwVe9l68/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reaEqlu8l5tbTMJ0qynfru63_kdvg/s96-c/photo.jpg	115378101767185398982	\N	\N
29806	Vishakha Agrawal	vishakhaagr09@gmail.com	https://lh6.googleusercontent.com/-SGhTy-enA6Q/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reu5d_77WawZ898wxj6ajpOFCxrYQ/s96-c/photo.jpg	100286415691765663285	\N	\N
30276	Chhaya Sharma ce18b028	ce18b028@smail.iitm.ac.in	https://lh5.googleusercontent.com/-L-854TRdDfs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfxST_mFWouqu_vzIy91X2buQ3Rwg/s96-c/photo.jpg	113888245761012053183	\N	\N
30003	Uma T.V.	uma.tv1699@gmail.com	https://lh4.googleusercontent.com/-IPV7jj8BvaY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPC9w0HKMC9lr4dUPuqqsHNCfLs3w/s96-c/photo.jpg	113963390817630213542	\N	\N
29755	S DHANUSH RAM 14MSE1125	sdhanush.ram2014@vit.ac.in	https://lh4.googleusercontent.com/-7kBNcSxeBiQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZ63_voIumAHteqeRlNqQb7A23YQ/s96-c/photo.jpg	108516706940208226941	\N	\N
29825	Dipesh Mahendrabhai Tandel cs18b054	cs18b054@smail.iitm.ac.in	https://lh3.googleusercontent.com/-YcG9DE9v7xI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfujAsoS4YpiXqDN7m2M5SWL24_jw/s96-c/photo.jpg	109380325252415730229	\N	\N
29662	Hari Prasad Varadarajan ed17b012	ed17b012@smail.iitm.ac.in	https://lh3.googleusercontent.com/-HxHJuFR1oYg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdViiGdKzScfd00bYvKxQHuGQ2rpg/s96-c/photo.jpg	107011537595407121485	\N	\N
30051	akshaya priya	akshayapriya1611@gmail.com	https://lh6.googleusercontent.com/-u2YXzQcxkXo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPlELqfSDovdinAlEku66ifigLyLg/s96-c/photo.jpg	110674105699847080840	\N	\N
27241	Pillarichety Srujana cs18b035	cs18b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-HG5PICuZRC4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdHSaJ6gL16jyt-4eFCovMQy4OTtQ/s96-c/photo.jpg	113833084535795360196	\N	\N
30301	S Jeeva me18b030	me18b030@smail.iitm.ac.in	https://lh6.googleusercontent.com/-29IwPDDZOc8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf80Ist1uqAqE7hlvw2d5hQQeSABA/s96-c/photo.jpg	101387875457663094752	\N	\N
29673	Shyamashrita Chatterjee	chatterjeeshyamashrita@gmail.com	https://lh3.googleusercontent.com/-U3HE_uW6fho/AAAAAAAAAAI/AAAAAAAAAbI/3ft6QpP3f0Q/s96-c/photo.jpg	114525950068404793740	\N	\N
29752	Dhanush Ram	sdhanushram96@gmail.com	https://lh3.googleusercontent.com/-hhAYiI8Mqpo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf6ak6MdV089QvGNmn4FXNcXLBNgg/s96-c/photo.jpg	109743691959278449583	\N	\N
30226	Mayank Singh	mayankayush173@gmail.com	https://lh3.googleusercontent.com/-Mk-ExuPdRgY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfV1kTpdD9TcXiNt9GUrxzW9yWAdQ/s96-c/photo.jpg	111063540894847667512	\N	\N
30227	Marirs Mama	sriram.kethireddy@gmail.com	https://lh6.googleusercontent.com/-3Sm2stRTPVM/AAAAAAAAAAI/AAAAAAAAAEg/u5hjON3tIi0/s96-c/photo.jpg	101117154862776106863	\N	\N
30599	Sanjay Raaj	sanjay.raaj.t@gmail.com	https://lh6.googleusercontent.com/--plNdHSAW0c/AAAAAAAAAAI/AAAAAAAAABk/fBNIIYWuGlg/s96-c/photo.jpg	101981507199442917246	\N	\N
30312	PREETHI SIVAKUMAR	preethi1398@gmail.com	https://lh5.googleusercontent.com/-swAtlZeXyKE/AAAAAAAAAAI/AAAAAAAAJMg/gB1QxnPl7GM/s96-c/photo.jpg	113373841263217521331	\N	\N
30596	Rowin Albert	rowinalbert@gmail.com	https://lh4.googleusercontent.com/-yb7xV2r8dcA/AAAAAAAAAAI/AAAAAAAANTo/vlWfKMHaIrc/s96-c/photo.jpg	110631595063399051560	\N	\N
30614	Vallamsetty Lokesh ee17b066	ee17b066@smail.iitm.ac.in	https://lh5.googleusercontent.com/-J6cgyn5WxBI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc_zgZLKZr3X6R1thopgRmVs5x2WQ/s96-c/photo.jpg	114068218062917305811	\N	\N
30633	SOUMYA KOLLIPARA	soumyakollipara@gmail.com	https://lh5.googleusercontent.com/-Y4t6HWbO0q4/AAAAAAAAAAI/AAAAAAAALSc/4Pav43IyxI0/s96-c/photo.jpg	107316691326563583876	\N	\N
30369	Maheshwar Kuchana	kmaheshwar1998@gmail.com	https://lh3.googleusercontent.com/-wOwKTTnZpN0/AAAAAAAAAAI/AAAAAAAAATA/4CXmzKSkvCA/s96-c/photo.jpg	110547291697641871185	\N	\N
30583	Vicky Kumar Sharma bt18m028	bt18m028@smail.iitm.ac.in	https://lh3.googleusercontent.com/-T16XQeXRmcM/AAAAAAAAAAI/AAAAAAAAAAc/q6qKpdeqxvU/s96-c/photo.jpg	111402924341024612788	\N	\N
30550	R Sailesh ae18b011	ae18b011@smail.iitm.ac.in	https://lh3.googleusercontent.com/-PC88MLQo0V8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOfPix-sZbk1LTxG6Q0Hj0dxYnKsw/s96-c/photo.jpg	101305269674174084117	\N	\N
30470	Samrat Mark	samratmark@gmail.com	https://lh3.googleusercontent.com/-6iREudq48Do/AAAAAAAAAAI/AAAAAAAAERQ/m5SoyHzfbb0/s96-c/photo.jpg	105641726480696282068	\N	\N
30665	ABHIJITH. T. S na16b016	na16b016@smail.iitm.ac.in	https://lh5.googleusercontent.com/-0MfIdp2QbOM/AAAAAAAAAAI/AAAAAAAABBE/4yVOd7H3ako/s96-c/photo.jpg	110177970648727277741	\N	\N
30694	Mugil Soorya	smugil28@gmail.com	https://lh4.googleusercontent.com/-Uy1CB6ozlDE/AAAAAAAAAAI/AAAAAAAAArw/jeIyVnXR7OQ/s96-c/photo.jpg	114227557694963116135	\N	\N
30701	Ebin Abraham	eby12abyham@gmail.com	https://lh6.googleusercontent.com/-z2ZPpuOyDaw/AAAAAAAAAAI/AAAAAAAAAr4/y6tGfp29xas/s96-c/photo.jpg	103207216063002712121	\N	\N
29344	Ayush Toshniwal	toshniwalayush8@gmail.com	https://lh6.googleusercontent.com/-EyhcIMKZ8t8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO5707D6FP9pQVtnrqyWIFW3fJY_w/s96-c/photo.jpg	109415117240233735834	\N	\N
31409	Nakul Mandhre	mandhrenakul8797@gmail.com	https://lh5.googleusercontent.com/-iEbve2zvv8E/AAAAAAAAAAI/AAAAAAAAAK0/C6DaT4GMqrQ/s96-c/photo.jpg	100888486472323143652	\N	\N
30763	Sriharan B S me18b089	me18b089@smail.iitm.ac.in	https://lh5.googleusercontent.com/--WPqqJfUJj4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd_RZKjMH2dwUei6sAaWQEKMT-QAQ/s96-c/photo.jpg	110739697356936056700	\N	\N
31331	SUBHRAKANTI DAS	subhrakantijgm@gmail.com	https://lh3.googleusercontent.com/-NaD-nqkRVmY/AAAAAAAAAAI/AAAAAAAAAAU/Kj-y6UqLun8/s96-c/photo.jpg	100012191509507254635	\N	\N
31293	chinna rock	chinnarock476@gmail.com	https://lh3.googleusercontent.com/-JsoHT5ZME5k/AAAAAAAAAAI/AAAAAAAAF7c/OWfl0QJqiqo/s96-c/photo.jpg	109618915614330966312	\N	\N
31317	sudharshan mani	sudharshanhari4@gmail.com	https://lh4.googleusercontent.com/-PAhl6xawrm8/AAAAAAAAAAI/AAAAAAAABDU/i9q1Bw_qznw/s96-c/photo.jpg	116239684292494076893	\N	\N
31354	Fazil Fz	fazilfazilfazil97@gmail.com	https://lh3.googleusercontent.com/-MKuIcjvc8S4/AAAAAAAAAAI/AAAAAAAADfk/eziqm1s3fRQ/s96-c/photo.jpg	116481189120918940278	\N	\N
30803	Sanjana Prabhu	sanjana.prabhu99@gmail.com	https://lh5.googleusercontent.com/-DsJQJGxvp9E/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOpFJqPLZaJJQwXHAbIQJtT2e7LHw/s96-c/photo.jpg	115958018513124626982	\N	\N
31611	sameer khan	samsksk23@gmail.com	https://lh3.googleusercontent.com/-VxKfmsgqon8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfqzqdIA0nR9wYjA6DcCsqv8k2U5w/s96-c/photo.jpg	100449272907606959639	\N	\N
31421	varad Thikekar	varadthikekar7@gmail.com	https://lh4.googleusercontent.com/-ax7lbuOsDNU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reuPV_0mm-_vztik699e7bUmR3Z7w/s96-c/photo.jpg	108562404006563394764	\N	\N
30876	Neethu S R ma18c020	ma18c020@smail.iitm.ac.in	https://lh3.googleusercontent.com/-Dfp6it8VG20/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd2bL3_b6F0TW8RaaJFmnfxsU8fKg/s96-c/photo.jpg	105035077380299958583	\N	\N
31534	Mahasoom Rizwan	mahasoomrizwan@gmail.com	https://lh3.googleusercontent.com/-etpiFINpv1A/AAAAAAAAAAI/AAAAAAAAq-E/62eSM_-bT9M/s96-c/photo.jpg	110975995114402452564	\N	\N
31143	Swapnil Gautam Bagate ee18b152	ee18b152@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Qe2n0cANbTQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMRsMut4YkEcD8zYf0NJSnd9XPGoQ/s96-c/photo.jpg	100426036979229502939	\N	\N
31161	RAHULRAJ	rahulraj.2017.it@rajalakshmi.edu.in	https://lh6.googleusercontent.com/-MGyo9-4fW_k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdUo_er_d92d9UjzKPi-pC8thHeJg/s96-c/photo.jpg	104721656847829616857	\N	\N
31288	Ramakrishnan Jayasekaran	jrkrishnan27@gmail.com	https://lh4.googleusercontent.com/-f-cchCv9rKA/AAAAAAAAAAI/AAAAAAAAABU/ANE9eL4jP_c/s96-c/photo.jpg	114817523383876433918	\N	\N
31258	Maheshwari S	maheshwari.s.2016.it@rajalakshmi.edu.in	https://lh6.googleusercontent.com/-RKLqHDvB9-g/AAAAAAAAAAI/AAAAAAAAWyw/Iphv28_7kx4/s96-c/photo.jpg	116107742058190876844	\N	\N
31261	mahima nalgonda	mahimahima147@gmail.com	https://lh6.googleusercontent.com/-RGq1crDcw1A/AAAAAAAAAAI/AAAAAAAAACI/l7v0rPh23h8/s96-c/photo.jpg	103933336112421689610	\N	\N
31353	ASWATHI RAJEEVAN	aswathirajeevan96@gmail.com	https://lh4.googleusercontent.com/-igD6pQwdNEI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rekjFBPzyh0R8xHZawOI03cS3_inQ/s96-c/photo.jpg	112287264203593620364	\N	\N
31352	Deepak Kumar	deepakodai@gmail.com	https://lh3.googleusercontent.com/-Kp5z4VUzUvo/AAAAAAAAAAI/AAAAAAAABVM/q9fuMnh0jdU/s96-c/photo.jpg	113934733771700894590	\N	\N
31318	Joshua Yuvan	joshuaedwinragul@gmail.com	https://lh4.googleusercontent.com/--77bBCA8ci4/AAAAAAAAAAI/AAAAAAAASNY/7qMtibZyjYc/s96-c/photo.jpg	109507225878783702985	\N	\N
31308	Hameed Hameed	moopenhameed8519@gmail.com	https://lh6.googleusercontent.com/-iQW89wHSFFs/AAAAAAAAAAI/AAAAAAAAIng/MmqXqJBRrHU/s96-c/photo.jpg	112505714881529466921	\N	\N
31581	murugan kutty	muruganlava135@gmail.com	https://lh3.googleusercontent.com/-7n-SZPq7W_E/AAAAAAAAAAI/AAAAAAAAAL8/NukexZ6TT8Y/s96-c/photo.jpg	114186203002331939794	\N	\N
31160	G K Hemanth Ram ee18b132	ee18b132@smail.iitm.ac.in	https://lh6.googleusercontent.com/-nBLyUc65v2c/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re1XqIinNB8UZLbDhqgAH-SkSnv_g/s96-c/photo.jpg	113978798657604321179	\N	\N
31565	Philip k Cherian	jithinphilip8@gmail.com	https://lh4.googleusercontent.com/-TDsxi1pp7TY/AAAAAAAAAAI/AAAAAAAAABk/u_e28N9G9DQ/s96-c/photo.jpg	116309397895817359481	\N	\N
31330	Duggirala Pavan Sairam ee18b048	ee18b048@smail.iitm.ac.in	https://lh6.googleusercontent.com/-TW4e8oeNSLg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc6evtLvv3PIoatFghZaTbehorNRg/s96-c/photo.jpg	117781477599627077599	\N	\N
31730	JATIN TIWARI	16211a1241@bvrit.ac.in	https://lh3.googleusercontent.com/-ryqILzQ8yso/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPX2tVy15Bcisu_px4Y-YTLa1c1Jw/s96-c/photo.jpg	104918609758142636078	\N	\N
31541	Poornii Noddy	poorniinoddy@gmail.com	https://lh3.googleusercontent.com/-3m4HaFEqh1s/AAAAAAAAAAI/AAAAAAAAAX4/Zq07cxRPZ7s/s96-c/photo.jpg	108497453376781852945	\N	\N
31420	preethi saravanan	preethisaravanan28@gmail.com	https://lh5.googleusercontent.com/-ErmI50RgruM/AAAAAAAAAAI/AAAAAAAAABo/6g-I2nUGE_M/s96-c/photo.jpg	103488078305005976029	\N	\N
31558	KEERTHI V C	keerthivc1999@gmail.com	https://lh3.googleusercontent.com/-oE7CGr0apCs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMZHdet_pg32L0iUhXiiU4t4dTzxg/s96-c/photo.jpg	111341297199545613038	\N	\N
31329	PATIL ANIKET SURESH me15b124	me15b124@smail.iitm.ac.in	https://lh4.googleusercontent.com/-zB0XBZGypRg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rceEqR9ZRyzvroaj_JlyWn03Yutew/s96-c/photo.jpg	110741549368883137465	\N	\N
31640	yuvan reDDy	yuvanshankar.reddy@gmail.com	https://lh5.googleusercontent.com/-DYUJF2PVa1I/AAAAAAAAAAI/AAAAAAAAE5E/lJqcvD_ghlA/s96-c/photo.jpg	100903650956250637024	\N	\N
31740	JANA SAICHARAN	16211a0579@bvrit.ac.in	https://lh6.googleusercontent.com/-MAX6OrnVBVE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdrGtVekQlr604g4pXBMbx0kYIK-Q/s96-c/photo.jpg	113427824936637840996	\N	\N
31739	panshul kumar	panshul.kushwaha@gmail.com	https://lh6.googleusercontent.com/-8T1svMxn804/AAAAAAAAAAI/AAAAAAAAAL4/ppfF2F7mjJQ/s96-c/photo.jpg	100524604573790733663	\N	\N
31741	Amulya Amsanpally	amulyaamsanpally15@gmail.com	https://lh4.googleusercontent.com/-xBHSSVQ1-tM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfwEbK5ILw6sUw6V2E9ILBJs4Q-OA/s96-c/photo.jpg	101203371747531185357	\N	\N
31703	raghuvaran sharma	varunrvs1998@gmail.com	https://lh4.googleusercontent.com/-ZW49RkecpP8/AAAAAAAAAAI/AAAAAAAAABc/yWEo3eOR5ww/s96-c/photo.jpg	110908060872101561853	\N	\N
31770	Shamira Sweet	shamira.sweetie@gmail.com	https://lh5.googleusercontent.com/-9WJl-RBuIe0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re26Nd6Sv2nPhDCBEnSnOVr5zX8uA/s96-c/photo.jpg	102191701944784594793	\N	\N
31808	Sai Vardhan Vankayala	vsdvardhan@gmail.com	https://lh6.googleusercontent.com/-WMCh3Hs9V9Q/AAAAAAAAAAI/AAAAAAAAP_o/-JX0zzF0I-k/s96-c/photo.jpg	107788240121980522888	\N	\N
31807	ANUSHA NALLI	anushanalli98@gmail.com	https://lh3.googleusercontent.com/-LbBsV_xP7Qw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdzLlCYNv7xau6GHnoVN4N6WB2yLA/s96-c/photo.jpg	101977943695203459345	\N	\N
32035	Jairam Satwik Reddy	reddyjairamsatwik@gmail.com	https://lh5.googleusercontent.com/-3azmuQ52m8w/AAAAAAAAAAI/AAAAAAAAAGE/6irIGJiNlFI/s96-c/photo.jpg	110709070786638999738	\N	\N
32524	Sankar Pannirukai Perumal	sankariit1999@gmail.com	https://lh5.googleusercontent.com/-pA94BYnaEhg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNWGO3yemBXkxVN6yHGpm_nwkrTZQ/s96-c/photo.jpg	114193926166367007704	\N	\N
32569	yalla reddy	yellareddy.nagem@gmail.com	https://lh4.googleusercontent.com/-H06qxC2xPRM/AAAAAAAAAAI/AAAAAAAAEec/beBARRXceu8/s96-c/photo.jpg	110258860955993442540	\N	\N
31572	Suresh Khetawat	sureshkhetawat962@gmail.com	https://lh3.googleusercontent.com/-ch6S1yLvCeM/AAAAAAAAAAI/AAAAAAAAAgc/9TuWM5Pw_Mc/s96-c/photo.jpg	117599913019367044159	\N	\N
31878	Abhiram Tarimala	tarimala.abhiram@gmail.com	https://lh5.googleusercontent.com/-3xMesoFYzwA/AAAAAAAAAAI/AAAAAAAAAAo/MG3lrvxdNnk/s96-c/photo.jpg	108034461483395868632	\N	\N
31818	Harshika Golkonda	harshika.golkonda76@gmail.com	https://lh3.googleusercontent.com/-jR5ICME7EWs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOJqaniAYdKfyvJrstK_0hpP_eR9w/s96-c/photo.jpg	106719939357621846168	\N	\N
31997	Pusala Sai Vivek ce18b047	ce18b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-PwPjTS_e3J0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQORDH0MrWbFDn_Bl8pmT1XLgR91BQ/s96-c/photo.jpg	117074336345478983632	\N	\N
32256	muthaiah s	muthaiah012@gmail.com	https://lh4.googleusercontent.com/-Ur5wbtRWibM/AAAAAAAAAAI/AAAAAAAACGE/11cFt-bVFsk/s96-c/photo.jpg	101207118991399661302	\N	\N
32417	Swetha Balram	swethabalram2410@gmail.com	https://lh4.googleusercontent.com/-HAWsbBmgZbA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPstL9nSpiO2nsQcVXukJe1V1yBHw/s96-c/photo.jpg	118235247777358642097	\N	\N
31912	animi gourav	animigouravrc@gmail.com	https://lh3.googleusercontent.com/-kxcESpN2tUQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rerNSHsWHTacYNmNSXAARnBEWSj2g/s96-c/photo.jpg	112003487079351151254	\N	\N
32040	Ashwith Sonu	ashwith.sonu1999@gmail.com	https://lh6.googleusercontent.com/-pe4Zp5LAyeY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcXDBZA0xbc4l8B_wa_sWz33Iy8zg/s96-c/photo.jpg	109932093479652910983	\N	\N
31925	MOHAN R	mohan.r.2016.mech@rajalakshmi.edu.in	https://lh4.googleusercontent.com/-KIWun6uaZV8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO2UjXsLJHzoMsJfCb4uAftR44N_w/s96-c/photo.jpg	105384267813869488602	\N	\N
32443	Cm “DeViL” HaCkER	mohammedlaeeq39@gmail.com	https://lh3.googleusercontent.com/-G22V4kSbDgo/AAAAAAAAAAI/AAAAAAAAUO0/bFAwhPrS9YY/s96-c/photo.jpg	102350455221991151858	\N	\N
32100	Monisha sundar	monishasundar35@gmail.com	https://lh4.googleusercontent.com/-Sv46Uyvi7V8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN7N-amwyU4vLFkAqiDyjkA6Ch3qw/s96-c/photo.jpg	108611939221151782017	\N	\N
31889	Jaya Veerabathiran2	jayaveerabathiran2000@gmail.com	https://lh4.googleusercontent.com/-lx0fkYIxD0k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdse4fZUjmUvKghl6j_aRob5RtQ2g/s96-c/photo.jpg	105368299530436984082	\N	\N
32065	Karishma Sulthana220f	karishmasulthana220f@gmail.com	https://lh3.googleusercontent.com/-0zqlqt9yd18/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPC0pL_xRWimPqCdHAB8rIJZdWdCA/s96-c/photo.jpg	101051984663811579290	\N	\N
32086	meenu priya	ohmkrishna1989@gmail.com	https://lh3.googleusercontent.com/-CX4HtoaviHc/AAAAAAAAAAI/AAAAAAAAAmM/vA7m9EkIp9A/s96-c/photo.jpg	118403157346615964994	\N	\N
32091	VINJAMURI SOLMON RAJU	17211a12b7@bvrit.ac.in	https://lh5.googleusercontent.com/-bMG3x6JidfY/AAAAAAAAAAI/AAAAAAAAADA/aWqqep_3a3E/s96-c/photo.jpg	114263084990181004463	\N	\N
32130	BATHIMURGE DHAVALIKA	16211a0418@bvrit.ac.in	https://lh6.googleusercontent.com/-mxJqntMQOLg/AAAAAAAAAAI/AAAAAAAAAAU/SOwVD7ahHxY/s96-c/photo.jpg	102337752411335677874	\N	\N
32789	Suchith mahajan	mahajan.saisuchith@gmail.com	https://lh5.googleusercontent.com/-vZxcbWfbRnQ/AAAAAAAAAAI/AAAAAAAAEiw/lY8WxPT-OXs/s96-c/photo.jpg	103246051290396859124	\N	\N
32026	Divya Prabakar	divyaprabakar97@gmail.com	https://lh4.googleusercontent.com/-o4oHnuz9cS8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNd73zZGhV4lgQ9kqpr9DsWStAIow/s96-c/photo.jpg	103160522592401353055	\N	\N
32432	HARRY LUCIFER	rianhsirah04@gmail.com	https://lh6.googleusercontent.com/-wT7ekanveYU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reN-SIwQrM99cZLkfBGrA3JgoJ3zQ/s96-c/photo.jpg	102360546003990525254	\N	\N
32581	rocky balboa	hussafh5253@gmail.com	https://lh3.googleusercontent.com/-RoTJVgibUz8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdafj0xF6cHwSuCZQh3ZvbHouEgfA/s96-c/photo.jpg	114957683442917804408	\N	\N
32103	VENKATA SIVA YASHWANT KUMAR DESU	16211a05v9@bvrit.ac.in	https://lh4.googleusercontent.com/-HfbORS3ZbuM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdNsy0nyyWReYPwhBkM3l8dxT0CMA/s96-c/photo.jpg	103384854572338898390	\N	\N
32549	manasa gonchigar	manasagn05@gmail.com	https://lh3.googleusercontent.com/-pxUC227PtHw/AAAAAAAAAAI/AAAAAAAAHZo/sF2Aafk8Kb4/s96-c/photo.jpg	110440598782266049609	\N	\N
32794	shivam rai	1809shivamrai@gmail.com	https://lh4.googleusercontent.com/-FigR1i9SDow/AAAAAAAAAAI/AAAAAAAAADk/5JtC06wCoDg/s96-c/photo.jpg	113912321613751055552	\N	\N
32515	Myzun shah	myzun74@gmail.com	https://lh4.googleusercontent.com/-BbslzODHYTA/AAAAAAAAAAI/AAAAAAAAAA0/QAUyAgP1-Vg/s96-c/photo.jpg	109259502533616809707	\N	307
28036	GOSANGI SAI VAMSHI KRISHNA me16b108	me16b108@smail.iitm.ac.in	https://lh5.googleusercontent.com/-NBc7lc_1ugQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdRC9hxd9szaYWu8qWbDmQd12-MFQ/s96-c/photo.jpg	105429541963527635739	\N	\N
32722	potturu ravishankar naidu	prsnayudu@gmail.com	https://lh4.googleusercontent.com/-IN_B20ArZI8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdl3UuGipeHqN6dl8NwMlxXaULnSQ/s96-c/photo.jpg	104706326988907598783	\N	\N
32600	Balaga Jhansi ce17b028	ce17b028@smail.iitm.ac.in	https://lh4.googleusercontent.com/--cMtL5XXDGg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rebaaG5MC6KHPdMDG-GikxQ6jE6VQ/s96-c/photo.jpg	116964737184564653833	\N	\N
32475	shivaprasad sunka	shivaprasad.sunka95@gmail.com	https://lh6.googleusercontent.com/-Lt3urtBcciI/AAAAAAAAAAI/AAAAAAAAAB4/Psw4ghi5UFQ/s96-c/photo.jpg	115893466469162485501	\N	\N
32858	Bhavishya Garg	bhavishyagarg02@gmail.com	https://lh4.googleusercontent.com/-LI5hUfWHpic/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcvGdKaNg8mjk2L5YROvbBgL1K-_A/s96-c/photo.jpg	107945827618686612359	\N	\N
32506	Kusma Sarangan	kusma1998@gmail.com	https://lh5.googleusercontent.com/-MyJWjiExOeU/AAAAAAAAAAI/AAAAAAAAAj0/I05Q4ivXBYA/s96-c/photo.jpg	108036690488109078326	\N	\N
32914	HariKaran V	harikaran.v.2017.aero@rajalakshmi.edu.in	https://lh3.googleusercontent.com/-yIjIaoe2124/AAAAAAAAAAI/AAAAAAAAAAo/AwEPpobbE6c/s96-c/photo.jpg	114125499907159457197	\N	\N
32895	Nelluri SnehitaChowdary	16wh1a0433@bvrithyderabad.edu.in	https://lh3.googleusercontent.com/-vydt7Pq3qaw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQObvzKDqlfoMRrEyC3SrTjdp9875g/s96-c/photo.jpg	100622507197575721798	\N	\N
33012	HR Manager	hr@wegot.in	https://lh6.googleusercontent.com/-SJrwapeGsBQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcGueQiKlM9SEg1LpzR_2ApyjzP5A/s96-c/photo.jpg	116990118273206494266	\N	308
32921	Elavarasan Dhoni	elavarasandhoni07@gmail.com	https://lh4.googleusercontent.com/-MqODLWZ5m60/AAAAAAAAAAI/AAAAAAAAAAw/mBmsQEF3wMQ/s96-c/photo.jpg	111667440765596819119	\N	\N
33001	ThirulogaSundhar Balakamatchi	thirulogasundhar@gmail.com	https://lh6.googleusercontent.com/-D__1uqGx4hc/AAAAAAAAAAI/AAAAAAAABgU/gxwoDufy4aE/s96-c/photo.jpg	111028326981029209404	\N	\N
33130	Elavarasan M	elavarasan2197@gmail.com	https://lh3.googleusercontent.com/-yWT3CdkWcOU/AAAAAAAAAAI/AAAAAAAAACQ/MGy4_4Mua2U/s96-c/photo.jpg	112311651424196547257	\N	\N
33141	LOKA RAMAKRISHNA REDDY	16211a05d4@bvrit.ac.in	https://lh3.googleusercontent.com/-U699V7Uix3k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd8yED2_q7D0fLzxMgkEmxDFbMWkw/s96-c/photo.jpg	101061940570555323156	\N	\N
33158	Dharmesh Khalkho	dharmeshkhalkho19@gmail.com	https://lh5.googleusercontent.com/-FtzhHhry798/AAAAAAAAAAI/AAAAAAAAADc/b9XzsHxkoXI/s96-c/photo.jpg	102009742594823010660	\N	\N
\.


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);


--
-- Name: internship_apply_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.internship_apply_table_id_seq', 130, true);


--
-- Name: internship_bookmark_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.internship_bookmark_table_id_seq', 1, false);


--
-- Name: joey_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.joey_user_id_seq', 33359, true);


--
-- Name: startup_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_details_id_seq', 308, true);


--
-- Name: startup_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_post_id_seq', 154, true);


--
-- Name: student_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_details_id_seq', 758, true);


--
-- Name: user_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_detail_id_seq', 33212, true);


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
-- Name: internship_apply_table internship_apply_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_apply_table
    ADD CONSTRAINT internship_apply_table_pkey PRIMARY KEY (id);


--
-- Name: internship_bookmark_table internship_bookmark_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_bookmark_table
    ADD CONSTRAINT internship_bookmark_table_pkey PRIMARY KEY (id);


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
-- Name: user__insert__public__internship_apply_table user__insert__public__internship_apply_table; Type: TRIGGER; Schema: hdb_views; Owner: postgres
--

CREATE TRIGGER user__insert__public__internship_apply_table INSTEAD OF INSERT ON hdb_views.user__insert__public__internship_apply_table FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__internship_apply_table();


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
-- Name: internship_apply_table internship_apply_table_internship_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_apply_table
    ADD CONSTRAINT internship_apply_table_internship_id_fkey FOREIGN KEY (internship_id) REFERENCES public.startup_post(id);


--
-- Name: internship_apply_table internship_apply_table_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internship_apply_table
    ADD CONSTRAINT internship_apply_table_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student_details(id);


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

