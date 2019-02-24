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
public	student_details	user	insert	{"set": {}, "check": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "resume_url", "roll_num", "user_hid"]}	\N	f
public	student_details	user	update	{"set": {}, "filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "is_paid", "payment_id", "payment_link", "resume_url", "roll_num", "user_hid"]}	\N	f
public	startup_details	user	select	{"filter": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}, "columns": ["id", "startup_name", "about", "website", "logo_url", "user_h_id", "is_verified", "poc_name", "contact_number", "email_id"], "allow_aggregations": true}	\N	f
public	student_details	user	select	{"filter": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}, "columns": ["id", "full_name", "roll_num", "college", "branch", "cgpa", "contact_number", "alt_contact_number", "alt_email", "resume_url", "is_paid", "payment_link", "payment_id", "user_hid", "payment_request_id"], "allow_aggregations": true}	\N	f
public	internship_apply_table	user	insert	{"set": {}, "check": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["internship_id", "resume_url", "status", "student_id"]}	\N	f
public	internship_apply_table	user	select	{"filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["id", "internship_id", "resume_url", "status", "student_id"], "allow_aggregations": true}	\N	f
public	internship_apply_table	user	update	{"set": {}, "filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}, "columns": ["internship_id", "resume_url", "status", "student_id"]}	\N	f
public	startup_post	user	select	{"filter": {"startupDetailsBystartupDetailsId": {"joeyUserByuserHId": {"auth_token": {"_eq": "X-HASURA-USER-AUTH-TOKEN"}}}}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "rev_rank", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance", "user_hid"], "allow_aggregations": true}	\N	f
public	internship_apply_table	user	delete	{"filter": {"studentDetailsBystudentId": {"joeyUserByuserHid": {"auth_token": {"_eq": "X-Hasura-User-Auth-Token"}}}}}	\N	f
public	student_details	anonymous	select	{"filter": {}, "columns": ["alt_contact_number", "alt_email", "branch", "cgpa", "college", "contact_number", "full_name", "id", "is_paid", "payment_id", "payment_link", "payment_request_id", "resume_url", "roll_num"], "allow_aggregations": true}	\N	f
public	startup_post	anonymous	select	{"filter": {}, "columns": ["accomodation", "address", "attachement_url", "description", "duration", "id", "interns_number", "internship_profile", "internship_title", "location", "other_incentives", "research_park_startup", "rev_rank", "skill_requirement", "specific_requirement", "startup_details_id", "status", "stipend", "travel_allowance"], "allow_aggregations": true}	\N	f
public	startup_details	anonymous	select	{"filter": {}, "columns": ["about", "contact_number", "email_id", "id", "is_verified", "logo_url", "poc_name", "startup_name", "website"], "allow_aggregations": true}	\N	f
public	internship_apply_table	anonymous	select	{"filter": {}, "columns": ["id", "student_id", "internship_id", "resume_url", "status"], "allow_aggregations": true}	\N	f
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
2228	109266082501365237941	eabe5a95237593b22f58beebcfe7fef3024808ca	user
1780	113564221505157815723	6f727eea4093d36a8e8b0432e88db612996f744b	user
1448	116445166814243602711	b29ab84c615454cbb09c1f267b3cd7b9d13ba428	user
1640	100916162979211575903	f9765bdfd4dd4cd341e6550b66f0146882a747a2	user
2145	109683991238473547277	5029b8c090c2d07aa47c598a1e1defa5ce9fb28e	user
1754	115802938042318956916	b674633c5b63389b71008c81c5dda817a68c15ec	user
1969	110274344916933599324	015872ef1201e021d42820541af13c84a1291c29	user
1403	113824673222077196247	817987f0fc2d8a1d371e4c9ee96380292ec93752	user
1563	103563223572046648148	2d8296c5a0e7faf8753b3be63c3bcf1d7b1d572f	user
2198	101396729595279031815	65e27b093759182a8ae7735a13e027eb8b3959f3	user
1513	106774401436596091547	068ebd2ad761a6ff502ac10dd9aba7d82d9076e4	user
2158	101107640131204357570	02d2e086ca1811e1565a0e9bf3f71a9ef8299fdb	user
1794	117013339697530495306	8faf2b46f743a04ac25e4136b63cd60105dfd036	user
1288	116040530755962342318	ee4db3e99e05154bf3a6d7983f2c294825c2303b	user
2097	104821578026829852225	9aea0e91ca2e00c23367ea34c304c239450264f7	user
1822	114503787094540282981	03f062b70b8af4c524125c5f73630e9010c66fb9	user
1348	107156601039704846020	27d1484e1eed33d68ef42c3b2484721700d8db56	user
1625	101818747050100224079	b5d937df3481ea2f2c12f5476131e95a21fdc9d0	user
1488	110553366885836969408	15799520a3e4c832b0458f8fe6c8efc2fa0fc8cf	user
1648	104379184185174428302	f84cea14aed36c5e451b00df01ff98f20d60a6d4	user
1324	110011265617786100962	86db390561f62b33023706ecd34bbdf3a1a08354	user
2379	103319782156851133364	b8480f5ccb088025e3ea846d8de32f8a84ebca18	user
1807	114749538391689307031	a5ec4819edacde892af8d425a394849509b253ad	user
1549	116836169810745668980	9faa8273ca4cf97d7cd8c7471c0a2dc602108541	user
2196	106289280886691331250	557d2096b4fd010c14f1a478b4bde138a6d09e3d	user
4470	103752593630791624652	1cddc4e69a327ba5d10992a7480f3bbd526ebcfd	user
2203	115342870212009600095	7ffe0bc79bb86abde7a93d2bf5d4ce2017fc1753	user
2229	101056800285643890923	62cc014a960e6c15316745c4b0ba5aa3fa463678	user
2201	111320166102807820736	2ac6875fdd5900a06bdb0ccf25b5ee8b9af54efa	user
1899	115375476385745576962	310ba0c88112a264768a6cc880fea55d5fd2a824	user
1894	107813869731075135750	393246bd9cbeb137680eeb4aa53f02e05461078c	user
2221	111687598935683751002	8e76b0ff585c630f7af0312dce478711d235d621	user
1565	107530024622485449869	e0056b98a100c1bf4b0da9a11ab70547e9570ca6	user
2230	107564555087017130990	e0659b971ade013f39c9eba4dea03ed8387aac1f	user
2231	110959428559525986265	013c71a4bb21ba77e63007e72deb5873b47d5639	user
1659	110447218383396106962	8eb96a0bd3c2ebb05ed79b7e2538a74dca2d4c84	user
4037	106783215449844945185	60269ccb9daf57d2a40791c8d73cfc2556817673	user
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
4886	110088160541028725569	63d17d33140c084f902801df314965d813556b52	user
1314	110540228254791393418	5cfcda204609953401e5cbd78ae1d1a494a1144d	user
2279	113375788251733149094	c206c99d107710492be2d7fd4b054649eb1b9c89	user
2291	115020366769667334416	4a784c0ed2f3ed00772b01509cf16f215c6f2524	user
2430	105500817840272313799	ad7475300889c0b3d99b92b647fbe003ea912a4b	user
4670	113501286160076496682	d88461b4461641a030d971d102cd10b6fdd0c93c	user
2312	113035858086387927034	eeda45c16bdabc33ef1ce30c7c4697e8b9a4c927	user
2317	114537148790063843816	9004b588d5db5841548519756d816fc1bf87e511	user
2318	103083422834575225895	01a795fbfbcbeb30a1e0ceb42a3d8767f0ee3562	user
2322	114818886750636854304	0850bee49091bb9298a3f4be8862085e6aa0a435	user
2528	114839727532236749919	1af22599e2f457b15f4219650de79209d40a5bfd	user
3259	101532661979094815998	8c40ac959f4dbd9fd535b6aeaa0b92d0f683f13b	user
4858	102312700975952431360	a76858ac296deb7dac17b80bc87c3d9f11a24999	user
4875	101142874371716107680	82d9bdd1a2f54b82a8691cd873a72950a995e0c0	user
1415	118208723166374240159	68cda695c8be4fd4fab3ce4d2b0fa051fddc0a9e	user
4897	103517082880442482622	72949b444a77a99f4e283e7557b2995a5061ddf8	user
2310	116687833430096689153	2828b7ca8465a1b0d25cf4b0336e770ebb62b119	user
4965	102139067499961218783	d071172e937dfb5aa34c5834ef9f1912b9b6e8c3	user
2391	106907442348505117600	d2e535189721952ba0b5123d1933956569798ccb	user
4780	105648143853551093911	f9d4f36e7dd74cb181d5ed06a41d30a95ba9f77a	user
4881	106151943570612705662	d2ae25da2aebf9c2ab42c76ecf76fd37752613f4	user
2541	117537405273454723771	f2d659a419b759c84328872ae3ad95c2eeea4c32	user
2531	105791111294087052325	61990eab933551838df908e7575a467d7db40b9d	user
2129	104089503500603657430	e6512b35071283b0447f4ad09ab3d35cec3f7e02	user
2298	108454550000095213572	10bd4b1f7339499e84659692af0b59b669bc3167	user
2566	107266261851940045387	90761b8116211735abd04c33af5980e473e5f2aa	user
2395	110988755828086628184	38d045da5fef112c1835e34ac68c2c5526b33d7c	user
4787	116786289933147386527	b2652a629323008bdd3befb19a12c5b152535a0e	user
2568	117045864410082434432	3e27eecc224c794e393231ce46331026fc1c75db	user
4061	112396581591786005083	c73bdd6911ce6367079d2dd0cecd7785f0941ca4	user
2412	105502414900621283479	f262daaa32284105150241e7c5e7671032d9ada0	user
2442	105528835513377079359	afbdbccfb47ea533b54b67de987be46e438b46af	user
1546	103656407720006034171	c0874923c1d77cc1febb64b8abb6c2c2ac0421cb	user
4874	116739830006062100225	2418b77f9ed304be15b147a4edcf36892958782f	user
2533	117306459721549242620	453a51d1d765337f6f83b489534d51ffb0188b4c	user
5081	116987835442491396459	6dcc94207af557e164897fa3b0f5e9fd40415959	user
4937	117068008597284134843	e4dfa983f07438bb7191da8af6b1ef3bbbeaa090	user
5094	108716062842174923272	a189a6b2ecbc4d68f19e71ad9e8f3d2347465b8f	user
2473	112150566284259074738	4946515a09dac64ba3cc977b5720211a3fd5656d	user
2508	114268811780135391116	6d9370a531046537b914e809d43861b88eec0e29	user
4178	112955715421977386894	0cc917c0b235865c4c4d97d9de72622652ca544e	user
2576	103765838603107363304	bb83c6f518ba4c9ee1e3afe8ce9463a80f9c923a	user
8680	101682012856295676880	cc4130b3e29b2e5f8cf5630206ed884f042ac738	user
5018	101452552670608521565	6484d771037e65493b2c58cd985ccfc7b31c970f	user
2583	103007413487745509743	037f71dee0257b07840e6980dab8b4d20f790477	user
3149	105135735319080728525	467d5e522cb7180c3180ad409e30e9b4cf464cb1	user
4853	101807814707039385860	6395d98214a3538df376cc01a36bf78f47b5a72f	user
1308	103441912139943416551	79c47914813bca669a68794b527546267ab0bf15	user
4873	113046604995058376278	d88eddb319fe30a83426da4d977e80aa832bce74	user
4889	114832114521563248786	58d68b10de4cdcf65c3ba34947abfcb84182e33a	user
2451	100680093250543498335	cd551351798cf90ef1644cf86a29e57839d8c901	user
4867	106346546956435892842	e4f0c5cf3888bad485f7449eaec9f5c1e55725d9	user
4935	117005101380398480170	a489c9bfcb6103e37bbf727769ff5c9c8a87dce4	user
4880	105718181361808782027	83598d94e649cc0a2315497c508d02d5d86c1d94	user
4936	112693133093914151701	70b2009de3ef87edb8c8333bbd30cc18fcb58637	user
4896	100180464561448951684	244419e25c7149e09b689025a2df6f9c862c7987	user
4930	102052775561051041362	a916fa71e04c605004407d29929a15269a6b4541	user
5005	110086250388526798686	0e0fdcbd75e364e4c757b15fcd07e4c4e370f626	user
4962	113814269201509832881	db94e67d402e940e832ae91063a06dea4ea3eba7	user
4577	104162540670104310859	bf8ea1771db449f6c35702d94a34aa3d9c774318	user
5051	109694605773547105071	d9be11e23ee6287e0691bedf2bef16f6083517ad	user
5052	104402072932888164460	43842112b617d6dcf8c66e1cacfb708fee97e2d8	user
4872	110035970755160527050	68529cf5077e07352dcedbae6613a3a257dd3d1c	user
5060	109528850140803698362	b8ea99b459ac9922d797b38831172963b57c5a74	user
5013	101052355478693521918	f238952ed6a6e329e0f794bd584ed2824408c728	user
5097	116204895236238903886	0dce44d09a18a6a094289d0d1facd073606dbfda	user
5120	104171369330644075313	f037fe3509054c1ba3eac04b83d1a6044eb8bace	user
5155	113583843316589152036	a3737312077c6b3bc41d21d4817f471e3956e6f2	user
5010	108046082470898711935	a11b0832447bf8b4d638ee6df4b481c69df7559e	user
5136	116474837895993246041	99c59cbcbfd0ea52071a4d41a235b4c6a2c0c1bd	user
4927	111558464273085465448	a800cd783c27ba90a7a93c3041551f1e0ec38143	user
5164	105392709235674293466	f9d014b7b25ab15bb8051dde6517c9292b8c0e2e	user
5215	117732606660029053405	0f0d9d0c35522b88d2b53c5668b4ccc9d3b81989	user
5184	100046381709706919563	77e4d730833afa98734301f047f3f93ff1099a75	user
5233	104341823850477467850	629c6fcd11fea212a0615869f907dba7867da923	user
5230	100174145732475175347	754ff93c88f53bf824562ec8c4dab99c762348b4	user
6392	100006462132328751764	45d96eeb2f92c8c4808c815e6b8c95cd6962acae	user
5300	101285149807471176908	9f9ee075cfac6f2b1cd5f5eec18ced96fa9b4a33	user
5254	101475449072728420854	1fc1ad56eca16895e05f29055a77cf071fa42036	user
5425	101887063519379114033	ba809739f63960e0ec36c3218594f9d8927019b6	user
6969	114093894912804568558	b96e4429e257d01e3cb2c033c929f45f4b39270f	user
6421	101491417144470081112	faf03428ff8c2c11cdbbb731b008bf873b8b1043	user
6000	102748409040120330310	a2e439ecc0c528753d3a551a3b0ee8afc8844a8c	user
5127	101411725174892658523	e9112c01cd5343e7a5cdb7f116830bd61fa5713b	user
5702	100166136587028365869	f8be58c05fbb4aa0493917db755e5efbf9f5ef64	user
5450	107434291759433018037	0c9fcb00835b509b1823cfb4a151339e82297523	user
5350	116111249617413389973	ca984d2fd367f3140b043a840f82a9a9c33e7589	user
5644	107489933466838356493	9fb41fe55b0625861b92b29206cbb697376cc320	user
6280	108536031230585647935	dda7af81bfd039f6f6cbf2a0518163623336867c	user
5983	109289325891115045173	f4cc0179e274034417006788eee2bee360306906	user
5313	104615193672641411565	17911859aac0b5facfd57ea6d1f0b3a8b440720f	user
5920	111140359246612411654	18df6e3e785c413a0bf885a68b4927207f1af8cc	user
5488	105735616610991386244	7c1ef158cc7ed9b6cc0e30d8431cc6013f4e7855	user
6642	103923783699459229771	c9054f3ac31d9e868ce1fcbb1ec93817f84430de	user
6186	100373514490827653919	e08cc6eeebb2599370068b0f7bb384ed1176d120	user
5409	117437871277613629999	b27b164a9b62b4435c7f8a0d6c244f6cfebea65d	user
5457	114351628888398386175	d2dc13c4e517f958b38960bcec3b35ea691c494f	user
5695	114121932947581881721	63ec9156691ce014527439e5120d48cdb68e2577	user
5966	103702551939099288693	b9531b67327249add11e8ce396372b2039c630f3	user
5363	113973502411437413660	f0ead0bd36e2e7c07e36d79834e81e1656f30130	user
5416	112154048075183298220	fbae56d34acee30571f8ff4e5e314a5ad18fe476	user
5400	100323225494928384224	d783d364f7be5a630a94eaace3e8abe212b77eb1	user
6139	105122427801569397480	5ff9e6b838e4de2d3083d3236ee9d90634cee4c2	user
6140	114360394443508391157	11c2b2513f6c0200e658c5a6d6e58b9a338c3a80	user
6468	110408636199196777944	12e69d15834840f46a30fdf1d0acec18d1d90259	user
5531	117356223086180674242	224d385730ae6308e266cc46ba03908f90c5aba8	user
5500	115382621843699309946	65f42b485e6cd252ac3d4a71973de2d6e375fba6	user
5692	107827922432577522549	7098df7a8db24cd5c94d79bc2585715aee669741	user
5933	106540878792009138011	edb8351b655672b97d0e12ee11bdadfc788d2e66	user
6244	100870213224601082705	6c08d7f83b15a268fec42769ada5d430a2b16a76	user
5462	106478730192157907359	d68c96e127de90d7736072b7c2d1ed6c37c83857	user
6496	101633193710942170825	b47a18e71920b2bc9598a052bda98bf228afb37d	user
6536	112870414950478249881	51f8907527afd2659f17ffca3c940d067adfa0a8	user
5967	107147930685919857188	de8e38458739d7f79ea55c25c28d68e19ce76400	user
6111	110606774466678924370	f56e273000af3d1f2d5a300fbced6ee9dcf4895f	user
6263	114704333810864603254	9190a60afc1cf1e264b8e01a7b6824363ec105f1	user
6256	108848347453031165545	cffeb0f9828284ec9064833ab9b55e52ed9e407b	user
6387	100629454340115098641	1a60e2b96e9fc41dee6b0e1489558b8b5634e17e	user
6465	105001332348729167995	e8306d8a1bb0c0031273bda0854157d6858c8438	user
6303	112872968935980064890	cf4cbc6cd3b339d75647742085bb03daa829dda7	user
6573	113681390068745417997	00b85ce32d571ab9419791454ff8d048da6cb7f8	user
6077	107301028745384927900	556052d962cd0ae02cd9ca95c684cac5c9a6f596	user
6825	112857156281300752937	ecdc12735f88e5d09787213663e1c5824e1ab609	user
6328	105534379261061050947	2b202a740d362a9fd93e46dcb49fefd19a38964c	user
5681	111128207069265376383	ef58a03c724ac9ec98d6e8840c4a64071eef6e6e	user
6513	116428881593753626712	f6e49088dffd525764f9de38e0e21300ce270c8e	user
6543	108210163016263470552	ed4428aab9605c5c1e24f4df634ae9561f0b7541	user
6235	108773897194648952785	dc08967c0a98853e493305a9a5a7bcede02defeb	user
6838	110757805238250702422	4ac01123c4ed3d338f8ff704b7689282e29d4d9f	user
6477	101398156657528003471	4b64f6157a690f62fee697c3aa1f66e21591af35	user
6673	115248078929890303214	d475d41295ad05e2a2cbecd8fa320534c8e9967c	user
6556	109157931691641267125	2846f5659129591a82a94c1ef701b56ef80a2fae	user
5747	118240680244675482931	53fbc66a03d9d2d8226edd45b9599413e2b5171d	user
6728	117479216273329852537	7ff155e3b90fe2f93a849749869df10c93eee4fc	user
6719	107177554755735141269	8a9f6b09054ceda4ef58d6ded8c9d10c5ad85a68	user
6253	114840229803252179382	1eb8b76e6b9d1b4054c17f5da188c681cd3df28c	user
6707	104863773335365538808	e74ecc4b917cc9be3372c64586697b262c61e7cd	user
5976	107413706842790560056	7178fca063f4c587d2c9646cb35cefea3537f1e6	user
6690	115339962081142646939	e35be12deec1173fd40611b7ee9c61c6274ed2d8	user
6883	112472980945916590575	8bcd87baaac8bfa17f7819473c086933dd80c7fe	user
6578	117966690353831815134	85bca4064a25bead68ad84576f04732f395b5436	user
6922	117968929471255721604	866c2c2667fd92c5a4b42d9a014a44c85fb54682	user
6933	113712306728446985892	a860219b124bf3ddd688a1cc4887cfeab4d526af	user
6970	107456246453619734809	20b4bbb1be46ed9f85f11181f5a1a4cbece583c7	user
6966	113538741896053160350	e8d7f5ccb6620752e3a6847300b6024a9808dd0a	user
6953	101180110198873131231	21b8808e8a57e2b367827824a7f3b971e39d8b07	user
6950	113529269457401139010	e0eddaac65269940af73dc7c46e06ead46e12385	user
7005	108551370712006348201	6e232c002559920343dc22a9a2794b944de722a6	user
6169	102269853381680672389	77ce944dfbb033b956f38243d4313bf2533cb416	user
5263	106447284908872676152	a44333798b2433a37c44bba88edf7708d999b53c	user
6399	107726028519801979477	533229732e8e8d3509fbb5cd4e0e0c293946d9a6	user
8747	109583020944427160732	86f7106e9ef724e49b2831abcbbb27412d815d43	user
8564	101171591693354500761	37f3aee5dbb4d4f7cc175559d74dec5a1a7a936e	user
7138	111066027705891320913	03a83df23abe581ca93efb7e0df7b6e43ae53258	user
7173	117764114579954744999	d623427a7cb0c9ce759dc1fc2f5282e8e7c25f29	user
7091	102663222527337708902	1fbd2b5f8bc076503a0100f391cefb1c5ac41956	user
7426	111640459531281754733	61aea1b1780c463bfa563027c73b21d80936fa3a	user
7893	100341530229780615772	df8f013bcf799dd9863b3051c05839b2aefef624	user
7520	104425878332120909243	412e6effe370fed62c6daca28ea80fdb1c86e248	user
7295	114369799590663114921	0a1ec4428270b02747b24abdcfd37e99e653e93b	user
7062	116528854078263730275	96af5c612e6c813a9b4219523c30b0bf9f14ef96	user
8482	103612128499527056792	3decf7f9d634279b604bd273341cf7eeed4d5ec3	user
7361	115801243251886489865	7428e3cefc93f7005a59de6dc126081ca12536e2	user
7744	112565833256553704360	a30fbfc553f387befdb8785db57e9cc853f1984d	user
8078	112203812328864098110	13864e54484c48f3c31b8bd5a9434190fe9f52c2	user
8210	117773863857662055608	669f5ce9dfd7e295044d0021c7dd6958c47d120d	user
7407	115215758125593906638	c291330c4a4a780a768e5dbafa213205d8c1c723	user
7362	105187746276593629594	100fc8f591edc1c2090c855bb35de69579bf80bd	user
7408	106538374742209182977	1673e5c90ff78c214b8d34fcbbf554049c2c384d	user
7419	114574453579413335824	255f762d1d2c6fbfe1bd4addbd9e28068480267e	user
7420	109557453092405104728	5a0615eb54b2a982d81c3aa498c3164e8d06b75c	user
7421	102187519138824292606	68194072e45a32f1ff260a83257da1d9056e23b2	user
7309	106891091144539984258	7985cd5eb01f88d263c83ad5f73399f87c6963f0	user
8073	113464349539753011433	060f7a8a6e389bf5a8eea6657e3e3199c6556e44	user
7467	111567725646650165125	5f1f1d4d6451709ee0e23a8cb306a28f028dfb02	user
7076	103273107959465057265	16d8ef3faefe8bbf01f5f84acfde9a619c13150e	user
8278	108345004535686987028	7e7bf4e61d96155a2d499e740d97d4b5d6410df0	user
8452	104003420105956436392	c48b7438842578db240d63731b1473a952be4e9d	user
7170	113597979260889639153	a2f12b0d9313ce88236bae7c5f084a79970ef8f9	user
7670	109614878105074181482	a75bd4ed8b10d1780d770ada10f7b7c24035742f	user
8399	111703803711058182719	2491873d90505bff61e69ef1f3cba54e591638e4	user
7814	114740917522394709774	9057baadb69dd9a82766e93d1384209736ed4177	user
4834	101827448437274338234	b1a2b8185ed3675ed1c1bb91d7452dd53bc21a8e	user
7236	114748309222522139021	e2761fbaa5a932a910102b4434c43d3be7f348e8	user
8328	100317160726643486440	decea83fe792661bd72ecaa6b3843d4bd760f985	user
7086	107198149074547760918	748fd686c66696eda093ea3f4ec49103c8c9db1f	user
7543	109098813558670849559	9678d586e8e6113e469869edcb6c706589e99fd2	user
7048	106053419849481655127	dccceb27dfdaaa87bfa13490eb7b525bd5245922	user
7829	104220784359784029268	57d45f9fa9db4d714fccaabfb92232a30181288e	user
7452	103398500054194363991	81c4aa92e92ea11ca336274df657105145cbc8c8	user
7356	117692580625665353891	7614dc50c703b65feec2a3b79a99946fc958e015	user
7215	116481244449985283889	d918eb51df4d660dc508faf0e0b4736bf1c51af8	user
8758	104547213757131706346	96ed1b48ad1ef1ae1580a63c38e88d5fc6dc0269	user
8289	111983544338321266182	2a039f0056fc88b5d99d5a02aaedc779357e61f2	user
7588	114591386611984022174	05a12b6dbc701c60d0b109f3ac89429d4cd708cb	user
7879	107393448684071128659	e0d7fdc820d82e6870f3873daa3b8197ec7931e4	user
7669	105433782240224469335	c8673e66a06650854622353a56b02cc77d860e43	user
7507	117310687405189973052	eefc8d85bbdf20d9f848cb7705e241ac2c2bbfb7	user
7478	114326744260308541754	567eaa57d7aef90ee8c2fe2a98c6547d12b27358	user
7445	114885547058071668870	6d90b750c111ac6f75e757075f8f47c558c20a0c	user
7828	115039944234930695540	0826d371afde9a314ff539e8dba503ccf3f182c1	user
7707	118406601333681717065	e93096f31a718d499cac8b8601dca12ab6135dd1	user
8056	105506572235545868243	88fbd111b3d42f4a103b911c5b59474a1cf62a99	user
8253	102330392737983603678	cebc7b08b8f9e6111a4ed8260034c95513655665	user
7306	101307535630091801474	1b75a0d519d1def2208768025b73d1d1920c19e7	user
7823	102658268322549131527	688864af751a3aee82b84e2fd5a832df12242d78	user
8263	116189371214953919032	c3dc8990fc24d6c9e11ac91812d50464a9c2266a	user
8366	118244727025742575334	4ee012550df985fe42cf423b149e5745240f1240	user
8252	104063535906637928892	e0992ca9a334c494d4a7befc463803787b4b61c2	user
7888	110931047755608602680	03a000299037d023f2c25f73d92a10793c0cc82f	user
8150	117368038713753317104	5c8e7202751c0c3697ad9a4b5e34694d68eb6be1	user
8092	106335102413062346097	2587dbe9ef41f0dd3e5aac9ac239464973e3e0d0	user
7942	109441309750837717539	60ecd37aa7c3b861f910fd39cc7b93da548207bc	user
7151	100444374512123718431	9cbc6b464360d30b7359ea8c46e9fa0f52954cb2	user
8032	105620503580613926309	95c2329e4dc29d048e55396b34f764d7e07919b1	user
8085	115420891548775866632	36ee6034fbad7debffce2a1fb92044cff66fdcf6	user
8135	100427482293316682936	a8e467f56c830a4b200fa3047000a67cf161e3b2	user
8219	108947651890682672904	15967d4dbfe4d774bbb2b315240235373260c470	user
7969	106596281639246034885	e4fbc49ba699e8a8415c279fad8f8d1d50fc7ac2	user
8232	100967102642433990682	2736a0541097ac3ae221094d7776c63386c29def	user
8249	104237264283215661649	d6edc1a21adaaf2cd6fa84d83b852f790a5abd88	user
7353	109121374241590014827	0845d360de31e0f82813f09ea5442e49ac619068	user
7638	114591124276679160265	450ece533826680e807295b05322aa002a7619fd	user
8388	116369894268542139381	a13394e587899d32a0ac27cc5a4640dc0f8b7e2a	user
8373	113236801941654391084	44df51225c02645d66359e88a66b77c2a02f686e	user
8425	114218010316466093767	0f401964a5dd210b8c564108960221b9899d3a6f	user
9940	103108124271782832702	036669bafb1797d9f6d5c694d72bdf2b0694eb00	user
7615	116837958596212598480	6104fd7f3f2dfad35f8b23d37b3724a5f75160c7	user
9020	106635592932027981078	95974733e086f606931acf74ad7854c28c8950d5	user
9548	116759539753758122369	59a53135982b0c45fe6ebcf768ad492738e2facc	user
10147	112998653258877975475	9ad9302a6bfb6b1f9fca4c839e2d08c1ce3c3cc0	user
8824	102006920462605638334	74a68834246e457d7e25a537fe10864773404696	user
9602	112654001619380731452	f759c8e3cd6c55ecef00a22bb2d958423cf432a6	user
9146	111335512155779191240	edda86397e9756c2fa2d71df9139fd2466b9d8a2	user
8663	101964436097463168367	357f46deed7069bc921fab1393e8201ee8b6ec22	user
9841	102823766561575238807	865d5f583817a9ba074b809970b8d1aeca631231	user
9935	116533323679531504829	59216b70ec35207c862337167062db4be1c29fe3	user
10074	107225841050163511047	abacf5600c20e18f7130aa68801296aa3f62f77a	user
8943	105702456308731098062	1a54183bf2b0c4a1950e4f76f1e000ed91258b2b	user
9941	115433360587726830200	d5e951eb7c90a1473dcbb70cb9a5c11331cba870	user
9770	108496699258995503222	a314ba8d92ab3eaa449a78b7d0eebb7e4f8fc547	user
9001	102627795555924271019	62c8a9a7d42d6b57194df19036cbd0c1a74cdc10	user
9161	102719715304204500462	2d56cbd4e40ddf46ee28704a6b9278f3dd3de7c4	user
10439	115330146506587527272	9d5f53f63f80ae07ffd7ce251824bf6d7fa80a30	user
9737	116478683189057283291	d7dfa4bfde8c6fba73f2ee3263dcedcbdd947acc	user
8153	104564285080152210085	096af418edb51258111e31681af08b6215616b52	user
9877	111171075972860896041	c0cdaa8eabcee84048f52575ef783e3c15ebb74f	user
8996	110283615455900532725	68e69b63e22c35b6dd32f4f5a6a15544c6ccbe27	user
9882	114352721177624111587	ee26565fa818d84478d4daa2d361310029bdf56d	user
9088	107870943386419228789	a29a6c7e3e5da6db30fc073d9eb7da032fcda41e	user
10025	109352785883855242466	224bef82fa96f9c27340d5b912c218dae52d7636	user
10598	105765378409248116613	d8f47defb7fc15f70f54d8473a18fd7915c2b8f5	user
9273	107033203380308127028	d6f9d7016b55e5739bedad4ab38e3aaad4208b23	user
10594	108283492057740057468	d0b0210515c8c827faa17c7053da67e8f19bef15	user
9507	102378491167760853351	3cd521b85d319b2e57f9d59814b3e0fc153a38e6	user
10563	103131193577480666827	efa730e7bcf57aad2e17988af9b1cfad61ff6ccf	user
9431	101172755541818547188	be32d1e7961ae81e30268e4a253a45e816d3a134	user
10717	111054950123693497601	59cf958584a2e55c8d0b1e62b1f91b0e8f3f486a	user
9569	108382685221057954981	620b0ade95692d00559e11b1ce8c08f42744244b	user
10773	116522826000331691456	549f852821b8a6411696f56deffe73a40f4f9e21	user
9730	104662693858655380465	6d592a9c51eb87851751ce016228e03a4eb383ae	user
9907	105102379391896692236	9145c332768374c067b6d0780672d627dac95813	user
9932	110659738883261836733	c02c90ac0cef594349d18fe87ef0b0d902ee9d2c	user
10668	117276624581419753619	05a997769269d5a7692300e901c716845e7fca4b	user
10321	100876071657723299498	16b7bc798a44bbdcdf51808ce5aa58d8dc153b34	user
10774	111790252858780067280	de78576d62cbe1bbc75a007f9b86094c84e6ad93	user
10629	116365908916402634741	ff1b6411b46dcc65a323e5198315f8c4af9acdae	user
10762	105703282986440185552	7cbd40f2a980acbb89fc86e303801421ca16d362	user
8347	101719078540936693965	86d8a6344cde3f87d97cc9a873d189cfdb187e61	user
8620	103628381857359898368	cccee176e9e2c18891a3e0bd34178d7d18ad05cb	user
8859	109432364385136243098	9a0bb914271cc81fa23b3b76f3ccff69a3f1c69f	user
9377	110018183307703015999	9554e5f4c7b07a5e7c318dfb1d90ca3562be9f12	user
9892	111710272164921687698	05e8e6fd23f1e853d19d5e5f5b1a592df4ba4ed1	user
6710	101927668361428071197	1b926ec32d4c890310cf5acc8e364f6732fd6803	user
10104	101988431255785683948	703ef0fb7bda853ed7844934cd5b85625691eed7	user
9641	104294280397208849479	5f7855dc046bcd4576d338b482583431a83368eb	user
10000	108733883465772823484	8bdb9efe0989723d0e31ae793912f750bbbeb491	user
9071	101626955168185208012	7a632da66085e1b9d082563ace95d42d49cd276e	user
9485	106355600612411521354	2996324834cb267f219ec311698e0c79a74b404e	user
8799	111873789583675808617	5bc6de8d6dcd870f2ff3274bc5bd9cd403d02f02	user
9357	102952072459497959474	8ceb010866cca4f75f2dd0969ded1d919eb9ad71	user
7055	114582343462323173676	78d1f4f6dd4f82a9a77584060c79aa9513080d0c	user
9581	106806052669784234976	a0cce4e973f8865043282ffdcb6e7d715459537f	user
9580	113468750706613363716	170fa95095ed52f9e943d88b7e261db1b6970119	user
8505	111203068180225244060	bbf0ebb8e91c7821a336ad1f168fab4974329218	user
10403	112188830982780019541	144580b82f0abbc39a9680dae378ab11038697ea	user
9837	106348211089456308863	f68787be5daa0c9feebf23085503fdddf268ab92	user
9385	110271268844549390100	2d37c4aba809ae6949eabe50d0dff0606d3c6c6d	user
4906	116457314552526686941	a18c59cba662b7105fca41a4fcc1ed48fbd44199	user
9657	104523922747918185043	4cbed3013af14b8a0cd12bcb9087bd67e5434c33	user
8611	106653443315295232533	972bd0f8076b599b0553b194b350b30aae95c827	user
10404	109473029886699548381	cde162dfdcd2bb3289d738107b3196ef7a808d61	user
9268	113069714899047220836	fbba370b940c1a693eb4471d7e401f35d1f61ed1	user
9838	102195777194996285654	677fada1a68d165c8c5ccb2f5689873e23a1a489	user
8928	104196509524819380284	ad94b2818443af11979aca710d81ebeb3b4aa179	user
9494	103308922454507465852	189a51fa6e1ebf202a04d736551c0e1a335aa8cf	user
9418	104181085677236457428	7e6db6f7d043ef39a82d7b6b3c1b4689d8bf0529	user
9103	104971464362178380321	5ad3a1aa13a24d9f84881f0b8c4d1fe7829a0918	user
9438	101171188455426530274	aecdc4fafca4a02c8f89b0cec41369e6fc354406	user
9658	104768237535269074850	b4247d515af6e7956c826f565a1ee70131c84068	user
9378	109722948945101591188	e6570e6f882c6b8c547642feca156013a0b685a8	user
10584	108977537476281644524	9e213a6c90bebc86170ac227c17f37a1c6ba3e4a	user
9707	102341274763983527312	99a97bde5d44cf4959edbf15fcf4484f6852fa85	user
10176	105576284422817967929	992eb71d765076355270e293f03a78992c74d4b7	user
9865	116667899528785398547	1e40c159583f1aa3e01e00c43c5eb3c7b17ca7e4	user
10400	117857658398501576041	fe2d3949342c237e6e655fef963b189f8d8dfb94	user
10520	100903677923974025368	b23030a924cfc95975dac85e11a3c40ec70f3bf0	user
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
238	ION Energy INC	Our planet is going through a fundamental shift away from fossil fuels. ION Energy's mission is to accelerate this shift by building cutting-edge energy storage products and services. Founded by a team of PhD Engineers from Stanford, Penn State and IIT with decades of experience in advanced electronics and battery systems, our groundbreaking patented technology acts as the core of high performance applications like Electric Vehicles, Telecom Towers, Data centres & More.Our cutting-edge BMS capabilities bundled with proprietary software & cloud analytics platforms drastically improves battery performance & enables real-time fleet management.We are looking to build deep meaningful partnerships with high-growth potential companies to help them become industry leaders in the inevitably growing Li-ION battery market. To partner with us, reach out at hello@ionenergy.co or visit www.ionenergy.co for more information.We're still in search of top talent as we disrupt the battery industry. Know any ambitious and fun-loving people in software, engineering, or operations that want to make new moves in 2019?Refer them at work@ionenergy.co	https://www.ionenergy.co/	https://www.ionenergy.co/wp-content/uploads/2018/05/IONlogo_250.png	117013339697530495306	t	Valentina Dsouza	9945328921	valentina@ionenergy.co
232	ScrapKaroCash	“ScrapKaroCash” is a scrap facilitator and scrap procurer service under waste management Clean Technology where customers will not only get an option to sell their scrap but also redeem coupons; inspired by Digital India, SBM (Swachh Bharat Mission)It’s working on listed domains:-1- B2C 2- B2B 3- Trade4- Compost.5- SBM.As of now we’ve lifted more than 150mT of scrap having 150+ active & Key clients.Recognition and Achievements made by this startup till today’s date are mentioned below :-1- IMPORT EXPORT LICENSE IEC- AAHCC0310R2- Attended as a Delegate in INDIA- ITALY technology summit valedictory session held by Indian PM Honourable Shri Narendra Modi and Italy PM Dr. H. E. Conte at Hotel Taj, New Delhi, 29-30 October, 2018.3- Invited for a summit held in Moscow with Indian, Russian embassies at 10-14 December, 20184- BITS PILANI shortlisted all over India, top 50 startups.5-  Invited by PM Honourable Shri               Narendra Modi for video conferencing  live broadcasted on 06 June, 2018 at DD  News.6- MINISTRY OF CORPORATE AFFAIRS     CIN- U74999UP2017PTC0937317- Shortlisted  in IIM Lucknow at UP Startup Conclave 8-MINISTRY OF COMMERCE & INDUSTRY (DIPP8978)9- Article published on Dainik Jagran Lucknow, 16th September,201810-Letter of Recommendation by Indian Army MAJ. Gen. K.N. Mirji.11- GSTIN (09AAHCC0310R1ZJ)12- Avail the benefits of MUDRA in the form of CC.13-Letter of Recommendation by KLS GIT, PRINCIPAL.14- Shortlisted for annual business plan competition organised by IIM, Lucknow.	https://www.scrapkarocash.com	https://www.scrapkarocash.com/wp-content/uploads/2018/05/cropped-WhatsApp-Image-2018-05-24-at-17.23.07-1.jpeg	110447218383396106962	t	Manvendra Pratap Singh	9480494001	manvendra@scrapkarocash.com
230	White Data Systems India Private Limited 	White Data Systems India Private Limited (WDSI) is a private limited company, incorporated in April 2015, which seeks to improve reliability and Quality of service through innovative and integrated technology solutions to the Road Freight & Transport Sector through its i-Loads platform.  WDSI provides a holistic and comprehensive range of services, providing tangible benefits to truck operators, booking agents, brokers and load providers at an optimal price. Being a TVS Logistics subsidiary and having cholamandalam as our investor provides us the expertise to deliver at a superior quality to our clients and also grow at a higher pace.	www.iloads.in	https://www.iloads.in/Images/home/logo.png	110505594872527456493	t	chitra	9940158710	chitra.c@iloads.in
234	iB Hubs	B Hubs is a PAN India startup hub which provides end-to-end assistance to startups. We are working towards nurturing a culture of innovation and entrepreneurship in every nook and corner of India. Till date, iB Hubs has supported more than 100 startups across India. iB Hubs is an initiative of iB Group - a vibrant team of 200+ individuals, majorly comprising of alumni of premier institutions like IIMs, IITs, NITs and BITS and corporate alumni of major MNCs. iB Hubs regularly offers internships/jobs to students from premier national institutes like IITs, IIITs, NITs, BITS etc in various domains like Cyber Security, IoT, Software Development, Management, etc.. 	ibhubs.co	https://d1ov0p6puz91hu.cloudfront.net/logos/iBhubs_logo.svg	105373738578694994605	t	Sowmya Bezawada	8008900903	hr@ibhubs.co
235	ProYuga Advanced Technologies Limited	ProYuga Advanced Technologies Ltd. develops transformative products in Virtual, Augmented and Mixed Reality.ProYuga has launched its first product iB Cricket, a new format of cricket, in the presence of Shri Ram Nath Kovind, Hon'ble President. iB Cricket is a vSport which provides the world's most immersive Virtual Reality cricket experience.iB Cricket is developed by a team of young graduates from premier institutes like IITs, IIMs, IIIT Hyderabad, etc. For more details, visit our website.	proyuga.tech	https://s3-ap-southeast-1.amazonaws.com/ibhubs-media-files/iBHubs+_+Startups/proyuga.svg	102540152476572591754	t	Sowmya Bezawada	8008900903	hr@proyuga.tech
285	Invention Labs Engineering Products Pvt. Ltd	At Invention Labs, we build technology products that enable and empower people with disabilities and their caregivers. Founded by an IIT Madras alum, we work out of the IIT Madras Research Park. We are a dedicated team of passionate social entrepreneurs who love our work because we are improving the lives of people with disabilities using cutting edge technology.Our flagship product is Avaz - a picture and text based communication app that helpschildren with autism communicate. Used by thousands of children around the world, it has won numerous prestigious awards, including the National Award from the President of India and the MIT TR35 from MIT. It was also the subject of a TED talk.	www.avazapp.com	https://www.nayi-disha.org/sites/default/files/photos/Avaz%20icon.png	105500817840272313799	t	Narayanan	9566095596	narayananr@avazapp.com
243	Vidyukta Technology Solutions Pvt Ltd	Vidyukta Technology Solutions is founded by IITM alumni, to develop products using new ideas in Deep Learning.		https://www.solidbackgrounds.com/images/1920x1080/1920x1080-white-solid-color-background.jpg	108825759819157028428	t	Sirish Somanchi	9849309056	sirishks@yahoo.com
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
296	ThinkPhi	Our mission is to be earth’s most sustainable company. We hope to get there by building products and solutions that accelerate the use of sustainable resources.  Our products focus on creating Outdoor Sustainable Spaces in and around your home and business. We are the inventors of the original "Ulta Chaata", a patented system that is an outdoor shade which harvests rainwater and generates solar power. From the Ulta Chaata came Model 1080, the world's most advance shade.  In 2019 we launched the HALO series which has various applications that enable intelligent outdoor space applications.  We believe that organisations and individuals can influence behavioural change through the use of our simple products that help conserve earth’s natural resources.  Our founding team started the company with a small team of Designers, Architects, and Engineers. Over time the team discovered that 30% of outdoor spaces around campuses is under utilised. Our future as a company is to provide usable, connected, and sustainable spaces.	www.thinkphi.com	https://drive.google.com/open?id=1oQuvFhTI5_lB5JImdD8VOYHzrGjiDAZDHXf86eGBEuA	105502414900621283479	t	Shubhangi	9833153900 	shubhangi.r@thinkphi.com
284	Vayujal Technologies Pvt. Ltd.	844 million people in the world – one in ten – do not have access to clean water due to a number of factors, such as repeated droughts, lack of natural supply, metal and biological contamination, anthropogenic activities, and poor or inadequate infrastructure.\n\nVayuJal Technologies Pvt. Ltd. develops Atmospheric Water Generators (AWGs) to combat the problem at the global level and to provide affordable, clean and healthy water to everyone facing a water shortage or a water contamination problem, through environmentally sustainable technological solutions. Developed AWG units will provide healthy mineralized water for drinking and normal clean water for other purposes, through a combination of its patented surface engineering technology, energy efficient unit design and mineralization technology, at a cost 20 times lesser than the current bottled mineral water costs.\n\nThese units may also run on off-grid solar panel systems to produce water in remote areas, wherever needed, thus providing affordable clean water to everyone, everywhere. Such machines will enable independent access to clean water for each individual facing water shortage issues in urban, rural, industrial, commercial, or remote regions due to multiple issues. Additionally, these variable capacity machines may fulfil water requirements for specific applications such as irrigation, construction sites, army tanks, etc.	www.vayujal.com	http://www.vayujal.com/	107266261851940045387	t	Ramesh Kumar	8939017761	rameshsoni2100@gmail.com
287	FinanceKaart.com 	FinanceKaart.com is a leading comprehensive online marketplace for financial products & services which helps consumers to compare & apply different financial products & avail doorstep services free of cost without visiting to any bank branches.\nWith its blended Phy-gital approach FinanceKaart.com is addressing the needs & working as a financial matchmaker for the entire ecosystem with its unique algorithm.\nFinanceKaart.com is a venture of Renaissance Global Marketing and consulting Pvt.Ltd which is a DIPP recognised Fintech startup with  Certificate No. - DIPP30154	www.financekaart.com 		103007413487745509743	t	Ganga R. Gupta 	9889916009 	info@financekaart.com 
224	Propelld	Propelld is re-thinking education lending from the ground up. Education, even though one of the most talked of subjects in the country, still suffers from a lack of financial access for the 80%ile of income population who don’t have the income means to qualify for loans from traditional Banks. Propelld, with its approach of accountable education lending by using future income as the key metric, has emerged as the top-most lender in this space. With a client base boasting of more than 100 Institutes & 800 centres across India and the who’s who of Education Providers within just 12 months of operations, Propelld’s fast growth has attracted Pre-Series A investment from top Tier A VCs of the Indian Eco-system. With a changing education and hiring landscape, the Govt. push towards skilling and the focus of employees on re-skilling, Propelld stands on the cusp as the leader in the exciting space of vertically integrated education loans.	www.propelld.com	https://i.ibb.co/qsYf7hf/Propelld-Final-Lower-Size.png	107530024622485449869	t	Victor Senapaty	9920175773	victor@propelld.com
277	Ah! Ventures	ah! Ventures is a growth catalyst that brings together promising businesses and investors by creating wealth creation opportunities for both. Our unique model serves both investors and entrepreneurs through a unique blend of customised services, skill, and industry and domain experience.For investors, we offer a bundle of services that are geared to help you not just locate promising investment opportunities, but also evaluate them in a manner that eliminates doubt, and facilitates savvy decision making. Through our continued involvement in the businesses invested in, and our transparency in all dealings, we provide your investment with that extra edge in security and growth.For entrepreneurs, we help you create an environment geared for explosive growth through services that benefit every facet of your business - from funding to recruitment to office space. When you come to us, we go through a detailed program that evaluates your business not just for where you stand today, but for what you can be, given all we have to offer. All our services are geared to help you function at a higher level of efficiency and growth, giving you an edge over competition, and helping you create new benchmarks in quality and performance.	http://www.ahventures.in/	http://www.clubah.com/images/logo.jpg	104379184185174428302	t	Baskaran Manimohan	9543282005	baskaran@ahventures.in
286	My Ally	Great companies change the world, one problem at a time. And great companies begin with great teams.What if we told you that you could build a thousand great companies by helping them build great teams?My Ally's AI Recruiting Assistant leverages cutting edge NLP and ML to automate Recruiting Processes for Hiring Teams around the world. We manage the entire interview scheduling process - including communicating with candidates - with better-than-human speed and accuracy.	https://www.myally.ai/	https://d1qb2nb5cznatu.cloudfront.net/startups/i/570288-a27b6774d94ad9d4d5827b45c0432dc7-medium_jpg.jpg?buster=1538687080	103765838603107363304	t	Patrick	8498081691	pat@myally.ai
300	FixNix	We are world's 1st pure play SaaS regTech startup "FixNix"​, our award winning Risk Orchestration Platform to streamline Governance, Risk & Compliance process via workflows, along with predictive analytics models to predict & data lake to handle unstructured data.	https://fixnix.co/	https://www.google.com/imgres?imgurl=https%3A%2F%2Ffixnix.co%2Fwp-content%2Fuploads%2F2018%2F04%2Ffixnix-grc.png&imgrefurl=https%3A%2F%2Ffixnix.co%2F&docid=nSWoG48KM7GIhM&tbnid=sOT7tOWD-JlXSM%3A&vet=10ahUKEwiA89C-0dPgAhXCXisKHfYuDzsQMwhAKAAwAA..i&w=1024&h=732&bih=754&biw=1536&q=fixnix&ved=0ahUKEwiA89C-0dPgAhXCXisKHfYuDzsQMwhAKAAwAA&iact=mrc&uact=8	114839727532236749919	t	Prasanna Venkatesh	9962645350	prasanna@fixnix.co
302	Test	Cool			114818886750636854304	t	Saurabh	8559931413	saurabhjain2702@gmail.com
242	Planetworx Technologies Pvt Ltd	Planetworx Technologies is a US incorporated and Bangalore based 2 year old B2B startup with a GDPR compliant audience insights SaaS platform called Trapyz (www.trapyz.com). Planetworx is an alumnus of industry leading accelerators like CISCO Launchpad, Pitney Bowes and now part of Airbus Bizlab program. Trapyz enables behavioural and intent-based segmenting of in-market audiences by analyzing multiple device sensor data. They work with app platforms to enrich consumer data and create additional revenue streams by monetising data for right targeting of consumers. The platform monetizes non-PII data by creating interest profiles based on real world visitation patterns and in-app intents (No personally identifiable information like phone number, e-mail ID or a device ID is captured or used). Our vision is to make digital marketing more consumer friendly without infringing privacy. The mission is to be the one-stop shop to map offline consumer journeys by leveraging multi-dimensional data in the real world.	www.trapyz.com	https://trapyz.com/assets/logo-brand.svg	114749538391689307031	t	Ranganathan	9886562627	ranga@planetworx.in
303	Accomox	cool			103441912139943416551	t			
\.


--
-- Data for Name: startup_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_post (id, user_hid, internship_title, description, attachement_url, internship_profile, duration, stipend, interns_number, location, research_park_startup, skill_requirement, specific_requirement, accomodation, travel_allowance, other_incentives, address, startup_details_id, status, rev_rank) FROM stdin;
112	101107640131204357570	Front-end Developer	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.		Developer (Front-end)	Minimum 8 - 12 weeks	15000	3	Hyderabad	No	FRONT - END DEVELOPMENT (WEB & HYBRID APPS) - preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	Preferably with React  (with React Native) or Angular JS (with Native Script), HTML 5, Grid CSS, Javascript frameworks, JSON, REST API, Sass, HTTPS, Webpack/Babel, bootstrap, Materialize, SSH, FTP, BIT Bucket etc.	No (Many good PG accommodations available at reasonable cost around the campus)	No	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
70	107530024622485449869	Backend Web Application Development Internship	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.\nNature of Work:\nSAAS Product for Training institutes & Financial Institutions\nMicro-services based architecture for scalable solution supporting various use cases\nData stream platform around Institutes, students and Financial Institutes\nProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889420/ecell/uelbmaccgipjgicnpfsi.docx	Backend Web Application Developer	8 weeks	20000	2	Bengaluru	No	Bachelor’s and/or Master’s degree, preferably in CS, or equivalent experience.\n·        Good understanding of data structures and algorithms.\n·        Experience coding in any one of the following C++, Java, C#, Nodejs, Python.\n·        Experience building highly-available distributed systems on cloud infrastructure will be plus.\n·        Exposure to architectural pattern of a large, high-scale web application.	NA	No	No	Informal dress code, other perks of working in a pre-series A funded startup	#365 shared office, 3rd floor, 5th sector, Outer ring road, HSR layout, Bengaluru - 560102	224	live	1
101	111133250649424423782	Online Marketing-Interns	 Customer retention, reactivation, website personalization, retargeting, social media, referral marketing, and other marketing and promotional activities. Identify, design, and analyze new brand-appropriate online marketing initiatives and partnerships. 		Online Marketing-Interns	10-12 Weeks	8000-10000 Per month	3	Jaipur	No	 Expert level knowledge of Facebook Ads Manager , Google adwords is a pre-requisite.	Passionate about digital tools of product marketing, exploring new ways of online marketing with tech acumen	No	NO	NO	J-469-471 RIICO Industrial area, Sitapura, Jaipur-302022	237	live	1
76	102476915533780948091	Software Intern	Will have to work on live project of integrating toys with learning.		Software trainee	8 weeks	7000 INR	1	Jaipur	No	Machine Learning, Artificial Intelligence.	Should have good knowledge in machine learning.	NO	NO	NO	F 20-A, Malviya Industrial Area, Jaipur - 302017	231	live	1
74	102540152476572591754	Sports Writer	We’re looking for adept content writers with good knowledge and passion for sports and an excellent knack for writing in the sports genre.\n	https://res.cloudinary.com/saarang2017/image/upload/v1550041130/ecell/bjz9mrp5y55jbudpksvz.pdf	Sports Writer	Minimum 2 months	Rs. 8000/- to Rs.10.000/-	2	Hyderabad	No	A knack for fresh and conceptual thinking, researching and writing sports articles.\nPassionate about sports and the power of sports.\nWell-versed in sports jargon and a natural talent at wielding them.\nShould be adaptive and flexible to learn and produce content in various mediums and platforms, and in styles and sizes.\nA flair for integrating visual elements in the content.\nA bent for creativity and conceptual thinking to support in strategizing and executing the content marketing plans for campaigns/promotional events.\nShould be a team player and be able to deliver the projects effectively on tight deadlines.\nShould possess integrity and the zeal to grow.\n	-	No	No	Informal dress code and lunch will be provided for 6 days	30,31, West Wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\nMaps Link: \nhttps://goo.gl/maps/Vpnw18n49M22	235	live	1
122	107429974676687296166	Data Engineer	Selected intern's day-to-day responsibilities include: \n\n1. Creating and sharing reports and dashboards\n2. Working with cross-functional teams the reporting process including data acquisition and cleaning, report and dashboard creation and visualization\n3. Working on system refinement, testing out newer technologies, etc.\n4. Brainstorm on ideas on how 		Data Engineer	3 Months	5000	2	Mumbai	No	Good Grip Over Excel Formulas & Pivot Tables\nBasic Understanding of SQL is preferred not mandatory\nLogical Thinking\nProblem Solver\nEager to Learn	No	No	No	Certificate, Startup culture	801, Jai Antriksh, Makwana Road, Marol, Andheri (E), Mumbai - 400059	253	live	1
93	101326090802695787002	Graphic Designer	Created web based or app based graphics or logo for any active website or app. Please include any active link or store link for any contributions. Knows his way around in graphics software like Photoshop, Illustrator, Adobe XD or Sketch.\n•\tStrong aesthetic skills with the ability to combine various colors, fonts and layouts\n•\tAttention to visual details\n•\tAbility to collaborate with a team.\n•\tRefine images, fonts and layouts using graphic design software\n•\tStay up-to-date with industry developments and tools\n		Designer	Minimum 4 weeks - Maximum 6 weeks	10,000 PM Minimum	2	Indore, Madhya Pradesh	No	Proficient in any of these softwares\n1. Adobe Illustrator\n2. Adobe Photoshop\n3. Adobe XD\nBasic knowledge of colors, gradients and fonts.	Adobe Illustrator\nAdobe Photoshop	No	No	5 days a week, informal dress code	Plot No 156\nScheme no 78 Part 2,beside Sai girls hostel\nNear vrindavan hotel\nIndore, (M.P.)	245	live	1
98	110274344916933599324	Software Developer Intern	“If it scares you, it might be a good thing to try.” – Seth Godin\n\nIf you want to join the force which is going to change the entire dynamics of App(Mobile/Web/IoT) development and App experience, you are banging the right door! Drive the Feature-as-a-Service(FaaS) revolution. \n\nWe Dream Big : We Work Hard. We Challenge : We AchieveInterns \n\nLooking for hardcore dev interns (preferably computer-science background) with a minimum commitment period of 4 months. Interns will be straight placed into our core development team. The exposure, experience, and energy which you get will be topnotch. \n\n		Developer	Minium 4 months	15000	2	Bangalore	No	Backend: Java, Spring-Boot, Python, Knowledge of REST framework & micro-services\nFrontend: Angular 2+, HTML5, CSS, Bootstrap, experience in UX design will be an added advantage. \n\nYou can apply if you have either of frontend or backend skills.	No	No	No	Informal dress code, 6 days a week	BackBuckle.io, Kstart Respace, Second Floor, Ascendas Park Square Mall, ITPB Main Road, Whitefield, Bengaluru, 560066	252	live	1
103	111133250649424423782	Intern-Data analytics	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n		Intern-Data analytics	10-12 weeks	10000-12000 Per month	2-4	Jaipur	Yes	Business/Data Analyst:\n \n•         Database design and implementation enhancements\n•         Primary on day to day schema changes and database maintenance\n•         Help developers to optimize queries, stored procedure and database design\n•         Assists in developing and implementing best practices for DR and Backups\n•         Assists in evaluating and selecting equipment, services and vendors \n•         Assist in Defining and implementing maintenance plan for the database systems  \n\nRequirements: \n•         Solid understanding of database design principals.\n•          SQL 8.3, 8.4 or hands on exposure of Excel. \n•         Good understanding of query execution plans \n•         Good SQL scripts skill including SPs, PSQL scripting - Good performance tuning skills \n•         Ability to proactively identify, troubleshoot and resolve live database systems issues. \n•         Knowledge of disaster recovery principles and practices, including planning, testing, backup/restore \n•         Experience in replication. Hands-on experience on database administration, backup recovery and troubleshooting in co-location environments. \n•         Ability to thrive in a fast-paced, deadline-sensitive environment \n\n	no	no	no	no	J 469-471 RIICO Industrial Area,Near chatrala Circle, Sitapura Jaipur-302022	237	live	1
114	101107640131204357570	Android / IOS Developer	Android APP development: B2C apps - KotlinIOS Development: B2C apps - Xcode / Swift/Objective Cwith understanding on constraint layouts, dagger, etc.		Android / IOS Developer	Minimum 8 - 12 weeks	15000	4	Hyderabad	No	Android APP development: B2C apps - KotlinIOS Development: B2C apps - Xcode / Swift/Objective Cwith understanding on constraint layouts, dagger, XML, etc.	NA	NA (Many affordable PGs around the campus)	NA	5000 (Bonus on successful completion of each assignment), 6 days a week, 8 hours work day, informal dress code	Cos-X, T-Hub, IIIT Campus, Gachibowli, Hyderabad - 500032.	260	live	1
119	101396729595279031815	Operations & Analysis	Intern Job Description for Operations post\nHandling end to end Campus ambassador hiring\nUtilize the campus ambassador for getting the work done\nUnderstanding the existing operations to identify and streamline the processes by eliminating the wastes.\nSkills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n		Operations & Analysis	2-3 Months	5000 - 10000 INR + Incentives	3-5	Work from Home, Mumbai Office	Yes	Skills Required\nFluency in English and Hindi languages\nInternet savvy\nMS. Office knowledge (Ms.Excel, Word, Powerpoint) is must\nGood communication skills\nCome up with Out Box thinking for giving task to campus ambassador\nFresher with intensive internship experience working in a startup\n	Ms. Office well versed	NO	NO	Informal Dress Code	Chatur Ideas, 101, Kuber, Andheri Link Road, Andheri (W), Mumbai – 400053.	262	live	1
144	114503787094540282981	Application Development 	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nDesign and build advanced applications\nAbility to work with data structures, No-SQL		Application Development 	8 weeks	20000	2	Bangalore	no	Python, Angular, PostgreSQL, Android	None	No	No		9th Main, Indiranagar, Bangalore	244	live	1
145	114503787094540282981	Data Scientist	B.Tech/M.Tech degree in ECE/Others from reputed institutes like IIT / NIT / BITS\nComputer vision and deep learning solutions, including image classification, object detection, segmentation, and equivalent computer vision-based vision tasks\nExperience with common data science toolkits, such as R, Weka, NumPy, etc \n		Data Scientist	8 weeks	20000	2	Bangalore	no	Experience with common data science toolkits, such as R, Weka, NumPy, etc \n	no	no	no		9th Main, Indiranagar. Bangalore	244	live	1
133	111320166102807820736	Website Developer	Develop new user-facing features\nBuild reusable code and libraries for future use\nEnsure the technical feasibility of UI/UX designs\nOptimize application for maximum speed and scalability\nLay the groundwork for web-based assets (e.g., web pages, HTML emails, and campaign landing pages)\nTake care of the ongoing activities of the websites. (i.e. blog post, articles etc.)\nDevelop the new pages and functionality as per the business demand\nEstablish coding guidelines and provide technical guidance for other team members\nDevelop innovative, reusable Web-based tools for activism and community building\nMaintenance and administration of website file repository\nHandle website deployment and build process		Web Developer Intern	10 weeks	10000	2	Gurgaon	NO	Experience developing div based or table less web pages from graphical mock-ups and raw images\nExpert in modern JavaScript MV-VM/MVC frameworks (Vue.js, Meteor.js, Angular.js, Node.js Development most preferred)\nHands on experience in delivering medium to complex level applications\nProficiency with Object Oriented JavaScript, ES6 standards, HTML5, CSS, Typescript, MongoDB.\nExperience in developing Responsive pages using Bootstrap or equivalent\nStrong in programming concepts OOPs, modularization, object creation within loops etc and test driven approach\nFlair to bring in unit test cases (e.g Jest, Chai, Mocha ,Jasmine (or a well-reasoned alternative)\nExperience in JavaScript build tools like Webpack, Grunt, Gulp\nFundamental understanding of Cloud, Docker and Kubernetes environments\nCreating configuration, build, and test scripts for Continuous Integration environments (Jenkins or Equivalent)\nExperience in all phases of website development lifecycle\nBe able to understand high-level concept & direction and develop web experience/web pages from scratch\nMust be proficient at resolving cross-browser compatibility issues.\nExperience on cross Device Mobile web development\nShould have knowledge of Web Developing tools like Firebug, FTP etc.\nAbility to juggle multiple projects/priorities & deadline-driven\nStrong problem identification and problem solving skills\nExcellent communication skills, Ability to work effectively as a team member, across project teams, and independently	NA	NO	NO	Informal Dress-code, flexible hours, certificate upon completion	Peacock Solar, C/o Sangam Ventures,  5th Floor, Plot 146, Sector 44, Gurgaon  - 122002	263	live	1
134	110988755828086628184	Design & Creative	About LeanAgri (https://www.leanagri.com/):\nLeanAgri is an IIT-Madras startup developing solutions in the agri-tech sector. With support from prestigious institutions like ICRISAT (International Crop Research Institute for Semi-Arid Tropics, UN Organization), we are offering technical assistance to farmers and farmer organizations.\n\nAbout the Internship:\nSelected intern's day-to-day responsibilities include: \n\n1. Designing in-app screens, delivering design requirements by the Product team.\n2. Delivering day-to-day design requirements - posters, pamphlets, banners\n3. Capturing and creating testimonial and product videos\n\n# of Internships available: 1\n\nSkill(s) required: Adobe Photoshop and Video Editing\n\nPerks:\nCertificate, Informal dress code.	https://res.cloudinary.com/saarang2017/image/upload/v1550749612/ecell/upelmu6f0bsvejhvezzc.pdf	Design & Creatives	2 Months ( 9 Weeks)	8000	1	Pune	No	Adobe Photoshop \nVideo Editing and Creatives (VFX & Media)	Should have prior experience in Design and VFX.	No	No	Informal Dress Code	LeanAgri, Teerth Complex, Baner, Pune, Maharashtra - 411045	276	live	1
120	101907162894505620447	AI Engineer for YogiFi - The Future Technology of Holistic Wellness	Looking for young and dynamic engineers to work on our award-winning deep-tech technology product at CES 2019 show.  We are looking for engineers with hands-on exposure to ML & AI algorithms. Knowledge with deep Learning libraries like Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy highly desirable. \n\n\n		Data Scientist, Artificial Intelligence 	4-8 weeks 	15000	1	Bangalore	no	Python, Keras, Tensorflow, Pandas, Matplotlib, Numpy, sci-kit learn, scipy 	Desirable to have prior exposure of working with IoT products. 	Own	Own	Informal dress code, flexible work hours	WELLNESYS TECHNOLOGIES Pvt Ltd.,\n2nd Floor, Institute of Inspiring Innovation Business Labs,\n10th B Main Rd, 4th Block, Jayanagar, Bangalore 560041	268	live	1
79	115802938042318956916	ML intern	As a Machine Learning intern you will be working on cutting edge technologies in machine learning and natural language processing. Suited for somebody who enjoys working on complex data mining and analysis problems.\n\nYou will be responsible for designing and developing solutions for one or more of the following \n- automated chatbots and building innovative customer service solutions. \n- predictive inventory management\n- ML recommended surge pricing, delivery pricing.		Machine Learning	6 to 8 weeks	18000 p.m.	2	Bangalore	no	Python, Pandas, Numpy, Machine Learning, Scikit-learn, Natural language processing	Experience in data mining and analysis , Deep Learning will be a added advantage and allow quick ramp-up	No	3rd AC train reimburse	informal dress code, 5 days a week	Current Address \nNo. 248, Nagawara Junction, Thanisandra Main Road, Outer Ring Rd, \nNear Manyata Tech Park, Nagavara, Bengaluru, Karnataka 560045\n\nFrom March 1st 2019\nBubblespace Coworking\n824, HRBR 1 Block,, HRBR Layout 1st Block, Extension, \nKalyan Nagar, Bengaluru, Karnataka 560043	233	live	1
81	106123538173898449055	Software	To play a critical role in the development of software interface of various automation products\nTo develop & deploy reliable code based on the requirement\nTo perform end-to-end testing of the software products\nTo extensively research on the latest trends in technology and recommend improvement \n\nwill be an internal part of core IT team.		Software	8-12 weeks	25000	8	noida	no	python, java, javascript, html, angular, PHP	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
82	106123538173898449055	Automation	Managing the development of controls related aspect for all automation products\nTo play a critical role in procurement, calibration, testing and deployment of control related tools like Sensors, PLCs, Scanners, relays and other related hardware\nTo play a critical role in designing of SCADA, PLC logics, Communication mechanism etc.\n\nStudents from Electronics, Instrumentation and Electrical specialization only are eligible for this.		Automation	8-12 weeks	25000	6	noida	no	Basic of their specialization	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
83	106123538173898449055	Mechanical	To play a critical role in design of all automation related products by providing artistic design and converting it into engineering design\nTo create 2-D & 3-D diagram of various products and create final product renderings\nTo ensure production of the products as per the drawing and ensure all engineering related aspect w.r.t. design are taken care of\nTo assist in deployment of all products related to mechanical project at site		Mechanical	8-12 weeks	25000	4	noida	no	Knowledge of basics of mechanical	NA	no	no	NA	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
80	106123538173898449055	Navigation	This will be a specialized role which will comprise of designing algorithms in SLAM for the mobile robotics vertical of Addverb.\n\nThis is open for all specialization where the candidate has done projects in robotics.		Robotics	8-12 weeks	25000	5	noida	no	Robotics skill	should have previous experience in robotics	no	no	no	Addverb Technologies Pvt Ltd\nGround Floor, D-108, Sector-2, Noida	201	live	1
78	108825759819157028428	Machine Learning Intern	Job Description:\n  The current product development involves working on new ideas in Deep Learning, using tools such as Tensorflow. The Intern will be provided training in AI / ML libraries and software development techniques.		Machine Learning Intern	2 months	60000 INR	1-2	Hyderabad or Remote-work (work-from-home)	No	Primary requirements:\n  - Expertise in Java, Python or C++\n  - Expertise in Algorithms and Data structures\n  - Ability to understand and implement ideas described in Research journal papers\n  - Good problem solving and communication skills, along with a positive attitude	Secondary requirements:\n  - Prefer experience in NLP, Image processing, Speech recognition, Chatbots\n  - Prefer knowledge of Tensorflow, scikit-learn, Spark, MongoDB, AWS or GCP\n  - Good to have knowledge of Data science and Data mining concepts, R programming and Statistical methods	No	No	To be announced	#301-A, Amsri Residency, Shyam Karan Road, Leela Nagar, Ameerpet, Hyderabad - 500016	243	live	1
121	101818747050100224079	Developer for developing one stop solution for shipping documentation <>automaxis	For the paper based documentation issues in cross border trade in pharma industry, automaxis is a blockchain platform for digital, secure & speedy transfer of these documents by bringing trust in the network & the transfer of ownership on real time.		Developer	7-8 Weeks	5000	3-4	Hyderabad	No	Python, Node JS etc	NA	No	No	Perks for good performances, Informal dress-code complete startup work life!	T-Hub, Catalyst,\nIIIT-H,\nGachibowli,\nHyderabad-500032	228	live	1
71	106407488023143571708	Full stack developer, Java, Machine Learning, Android, Web development, QA	KareXpert is a Pioneer in designing technology platform with a Patient centric approach to make “Patient Continuity” a reality in Indian Healthcare. We are the only technology Company to design patented “Advanced Health Cloud Technology Stack” which connects Patients with all the care Providers -Hospitals, Nursing homes, Clinics, Doctors, Pharmacy shops, Diagnostic labs, Imaging Center, Blood Bank, Organ Bank, and Ambulance. Our Innovative Solutions are compatible to run on any Smart device-Mobile, Tablet, Laptop, Desktop via Mobile App & Web App.		Full stack developer, Java, Machine Learning, Android, Web development, QA	8 weeks	No stipend	4	Gurgaon	no	Core Java,, OOPS Concept, Spring, Hibernate, Html5, CSS, Angular6, Mysql, android framework, SDLC, STLC	B. Tech CS and IT branch only	no	no	n/a	Karepert Technologies Pvt. Ltd.\n405 Universal Trade Tower, 4th Floor, Block - S, Sohna Road, Sector 49, Gurugram, Haryana, 122018	229	live	1
110	105373738578694994605	Director pf Photography	The Director of Photography will be responsible for studio/outdoor shoot of videos like corporate interviews, corporate events, documentaries, etc.		Director pf Photography	Minimum of 2 months	Rs. 10,000/- to Rs. 20,000/- per month	2	Hyderabad	No	1. Thorough knowledge of continuity.\n2. Hands-on experience on any DSLR camera (like Canon 5D, etc.).\n3. Creativity and passion in film and cinematography.\n4. The ability to listen to others and to work well as part of a team.\n5. Good written and verbal communication.\n6. Attention to detail.\n7. Time management skills.\n8. Ability to deliver with in deadlines.\n9. Integrity and the zeal to grow.\n	Nothing	No	No	Lunch will be provided	30,31, West wing, First Floor, Brigade Towers, Financial District, Nanakram Guda, Hyderabad, Telangana 500032\n	234	live	1
126	104379184185174428302	Associate	- We are working on various live projects in the domains of Venture Funding, Investment Banking, Community Management, Database Enhancement, Event Creation & Management, Co-working, Marketing, Social & Digital Media Management, Content Creation, Software Development, Application Development		Analyst	Minimum 8 weeks	0	25	Mumbai	No	- MS Excel, MS PowerPoint, MS Word, Analytical skills\n- Undergraduates or PG students from any discipline interested in the above areas\n- Looking for people to start immediately, duration will vary with projects\n- Internship type (Part time/ Full time/ Virtual internship) - All three available\n	No	No	No	Informal dress code, Flexible working hours	B-402, Kemp Plaza, Ram Nagar, Malad West, Mumbai, Maharashtra - 400064	277	live	1
148	115375476385745576962	Software Developer	Vision: \nTo redefine the student living experience in India by creating technology-enabled co-living spaces that are tailored to suit their needs and aspirations. \n\nWho we are: \nStanza Living is one of the fastest growing start-ups in India that’s focused on building an exceptional co-living brand for students that they spontaneously connect with. We are a full-stack business and want to build a brand that is first identified and remembered for its quality, a brand whose quality speaks for itself. \nWe want to take away the stress of accommodation-hunting from students and redefine that space with high- quality and professionally managed co-living spaces. We want to offer students something beyond cramped and stuffy rooms, non-existent infrastructure, poor maintenance and a pitiful state of affairs – Stanza Living residences are places where students want to come back to every day, a place that will give them a sense of belonging, of fraternity and of comfort. \nWe’ve already embarked on the journey towards the first phase of being LEGENDARY!\n\n Why Join Us? \n• A phenomenal work environment, with tremendous growth opportunities \n• Opportunity to shape a potential Indian unicorn \n• To learn and grow in a flat office structure that appreciates ownership and respects individual opinions \n• Opportunity to work on cutting-edge technology solutions \n• A place where hard work & smart work is always rewarded \n• Direct impact of the work you do on thousands of college students in India \n• Forever fuelling the hustler, the dreamer, the revolutionary in you \nDesired Skills\nGood with Data Structures and Algorithms, OO Design Patterns,\nJavaEE (Spring,Hibernate), MYSQL, MongoDB\nGood knowledge of Computer Networking and Operating System concepts, Amazon Web services\nComfortable working with front end (Web) technologies - JavaScript / JQuery,\nExposure to Angular, Angular-Ionic, React, React Native will be a plus,\nExposure to Artificial Intelligence/Machine Learning fundamentals will be a plus		SDE	4 weeks	15000	2-3	New Delhi	No	Java, Data Structure, Algorithm, Spring, Hibernate	Desired Skills\n\nGood with Data Structures and Algorithms, OO Design Patterns,\nJavaEE (Spring, Hibernate), MYSQL, MongoDB\nGood knowledge of Computer Networking and Operating System concepts, Amazon Web services\nComfortable working with front end (Web) technologies - JavaScript / JQuery,\nExposure to Angular, Angular-Ionic, React, React Native will be a plus,\nExposure to Artificial Intelligence/Machine Learning fundamentals will be a plus	No	No	5 days working, informal dress code	Stanza Living, 6th Floor, OSE Tower, 5B, Hotel Aloft, Aerocity, New Delhi - 110037	249	live	1
69	107530024622485449869	Frontend Web Application Development Intern	Propelld is founded by IITM alumni of the class of 2011 from Mandak and Godav.Nature of Work:SAAS Product for Training institutes & Financial InstitutionsMicro-services based architecture for scalable solution supporting various use casesData stream platform around Institutes, students and Financial InstitutesProprietary analytics engines to use data for business decisions	https://res.cloudinary.com/saarang2017/raw/upload/v1549889353/ecell/ymh5rp6ebameawdimgd4.docx	Frontend Web Application Developer	8 weeks	20000	1	Bengaluru	No	•\tBachelor’s and/or Master’s degree, preferably in CS, or equivalent experience•\tComfortable coding in JavaScript and Typescript.•\tExperience with modern JavaScript libraries and tooling (e.g. React, Redux, Webpack is a plus)•\tFluency in HTML, CSS, and related web technologies•\tDemonstrated knowledge of Computer Science fundamentals•\tFamiliarity with web best practices (e.g., browser capabilities, unit, and integration testing)•\tDemonstrated design and UX sensibilities (Hands on Photoshop, XD is a plus )	NA	No	No	Informal Dress Code, Perks of a pre-series A funded Startup	#365 Shared office, 3rd floor, 5th sector, Outer ring road, HSR Layout, Bengaluru - 560102	224	live	1
77	117013339697530495306	2019 Summer Intern - Engineering	We are looking to hire enthusiastic university students with a passion for embedded software development and a willingness to learn, to work in various departments across the company in one of the following areas:\n\nPursuing the challenges of bringing up a new development board\nHow to build, test and debug full software stacks on hardware that hasn’t yet been manufactured\nGaining a deeper understanding of system architecture and performance (CPU or GPU)   \nHow to scale a solution for a single developer into an automated real-time regression farm \n\nThen this is a phenomenal opportunity for you! \n\nAt ION Energy we are building the world’s most advanced battery management and intelligence platform. ION was founded by a team of PhD's with decades of experience in advanced electronics and battery systems. Our groundbreaking and patented BMS technology acts as the core of high-performance applications like Electric Vehicles, Telecom Towers, DataCentres & More.\n \nWhat will you be accountable for? \nAs a Intern, you will be placed in a development team at ION’s R&D office situated in Mumbai suburbs, where you will have a dedicated mentor, and be able to get to grips with the problems ranging across many embedded areas. \nYou will work on the development and testing of kernels, device drivers, development tools, and build & test frameworks whilst being supported by and learning from the rest of the team.\nWhilst a lot of our work does involve Open Source software, many tasks require working with development platforms, or simulated hardware environments where features are being developed and tested before the physical devices have been built, so the problems you will be expected to understand and pursue are ones that are yet unknown to the general community.\n\nThis is you : \nCurrently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field\nEnjoy problem solving and working closely with hardware\nWant to become proficient in system programming\nHave sound C/C++ or shell programming\nHave a good understanding of computer architecture and operating systems and want to apply it to the real world.\n\nBenefits\nYour particular stipend will depend on position and type of employment and may be subject to change. Your package will be confirmed on offer of employment. ION Energy’s benefits program provides all interns an opportunity to become permanent employees based on performance and business needs and a platform to stay innovative and create a positive working environment. 	https://res.cloudinary.com/saarang2017/image/upload/v1550052981/ecell/b6nle3jwjrkkugrfjaiv.pdf	Engineering Intern	Minimum 6weeks	15000 INR	2-3	Mumbai	No	- Currently enrolled in a bachelor’s or master’s program, on track to earn a degree in electronics engineering, or a related field\n- Enjoy problem solving and working closely with hardware\n- Want to become proficient in system programming\n- Have sound C/C++ or shell programming\n- Have a good understanding of computer architecture and operating systems and want to apply it to the real world.\n	- College Projects in Embedded Systems and Electronics\n- Understanding of Electrical Engineering Fundamentals\n- General Enthusiasm to learn 	No	No	Informal Dress code, Dedicated mentor, Office location easily accessed by Mumbai metro and close to domestic airport, Free tea/coffee, Office parties. 	ION Energy INC\n703-704 Wellington Business Park, 2, Hasan Pada Road, Marol, Mumbai, Maharashtra 400059	238	live	1
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
72	110447218383396106962	SKC_IT	All the selected and qualified SKC_IT interns will be assigned under live project. 1- Web Designer : He/she will be responsible for developing a live dynamic website. Credentials pertaining to hosting and server details will be provided later. 2- App Developer : You have the inclination but don’t find the right platform to showcase your coding skills . Don’t worry, Sit back ! “ScrapKaroCash” is here. 3- Creative Content Writer : A Writer who is worthy enough to express it’s requirement in a innovative & creative way. 4- Software Developer :  A techie who’s smart to understand company work flow and give us URL address. Yes! We need a coder who not only understand the complexity of the work flow but also provide us solution in an effective way.	https://res.cloudinary.com/saarang2017/image/upload/v1549979932/ecell/dbuvatv9bjvltunwqglg.jpg	•Web Designer • App Developer • Creative Content Writer •Software Developer	8 weeks	• Creative Content Writer- Certificate will be provided, No stipend. For others INR  ₹ 25,000/- on successfully project completion distribution fairly. Moreover certification will be provided to them.	8-10	Work From Home	No	PHPSEOHTML/CSSJava ScriptPhotoshopWord PressUI designerContent WriterC#Cross-Platform App Development	• Analytical Skills -Most successful websites are functional but consumer behaviors are changing therefore to meet their expectations design, coding, and development skills will always evolve to satisfy the ever-changing consumer.Therefore, web developers need a strong understanding of consumers. Especially web consumers.• Responsive Design.	NA	NA	NA	GIT Incubation Center,Udyambagh, BelagaviKarnataka	232	live	1
\.


--
-- Data for Name: student_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_details (id, full_name, roll_num, college, branch, cgpa, contact_number, alt_contact_number, alt_email, resume_url, is_paid, payment_link, payment_id, user_hid, payment_request_id) FROM stdin;
37	Mritunjoy Das	AE16B111	\N	\N	\N	9435840783	\N	\N	\N	t	https://www.instamojo.com/@joeydash/cfbc308320e540a9bd38a95474a8a240	\N	112396581591786005083	cfbc308320e540a9bd38a95474a8a240
38	Meghana E	16wh1a1216	\N	\N	\N	7093256911	\N	\N	\N	f	https://www.instamojo.com/@joeydash/723998f4859f4a7eaea67bfb5673e707	\N	103752593630791624652	723998f4859f4a7eaea67bfb5673e707
23	Neeraj	Jadhavar	\N	\N	\N	7776081403	\N	\N	\N	f	https://www.instamojo.com/@joeydash/ed3c7c7d31fa4fd7a0af702429468f5d	\N	101532661979094815998	ed3c7c7d31fa4fd7a0af702429468f5d
39	Abhishek Tigga	ee17b101	\N	\N	\N	8290993926	\N	\N	\N	f	https://www.instamojo.com/@joeydash/01bf19f7147545fb84a3e3364df833e9	\N	104162540670104310859	01bf19f7147545fb84a3e3364df833e9
40	Thirumala Reddy Manisha Reddy	16wh1a05b6	\N	\N	\N	8328258020	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0ddd5805cf6945f391d94165d6427805	\N	113501286160076496682	0ddd5805cf6945f391d94165d6427805
41	Om Kotwal	EE17B120	\N	\N	\N	7506606195	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e6431540502a4dfa9b6c00fdb3951d02	\N	105648143853551093911	e6431540502a4dfa9b6c00fdb3951d02
42	Siddhant Toknekar	ED18B031	\N	\N	\N	9130213213	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0e6e76bde19847559cb0194e5ba0b929	\N	116786289933147386527	0e6e76bde19847559cb0194e5ba0b929
27	Saurabh Jain	ME16B071	IITM	Mechanical Engineering	9.37	8559931413	9940312393	me16b071@smail.iitm.ac.in	\N	t	https://www.instamojo.com/@joeydash/5bf424c3354b48f4ba939f2ed2750c18	MOJO9223J05A71988827	107156601039704846020	5bf424c3354b48f4ba939f2ed2750c18
28	Mukund Khandelwal	ME16B152	\N	\N	\N	7000338552	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fbeb89711ec8431c9e0915664455dc82	\N	103158308128328545694	fbeb89711ec8431c9e0915664455dc82
29	Akshit	Ee17b103	\N	\N	\N	7228901202	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3c40c54203be4693bc676e540a927ec8	\N	110540228254791393418	3c40c54203be4693bc676e540a927ec8
30	Samyak Jain	EE17B116 	\N	\N	\N	7999675599	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9c364ef51e6d466f9c62bc85a6f81979	\N	103656407720006034171	9c364ef51e6d466f9c62bc85a6f81979
32	Saurabh	ME16B071	\N	\N	\N	9940312393	\N	\N	\N	f	https://www.instamojo.com/@joeydash/396d9f2e58794550a0a2572eb13c4aef	\N	110553366885836969408	396d9f2e58794550a0a2572eb13c4aef
36	Akshat Nagar	ee17b122	\N	\N	\N	8962705800	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7fc523c209a44da9bb8475798ca65359	\N	112955715421977386894	7fc523c209a44da9bb8475798ca65359
43	Sai Rohitth Chiluka 	ED18B027 	\N	\N	\N	9381582625	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f383e30d72de4cb8b971a57b1a5ee528	\N	101827448437274338234	f383e30d72de4cb8b971a57b1a5ee528
44	Monika Nathawat	NA18B027	\N	\N	\N	9214406296	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fd2c2783ef11460aae7ee17a57f3dde0	\N	101807814707039385860	fd2c2783ef11460aae7ee17a57f3dde0
45	T B Ramkamal	EE18B153	\N	\N	\N	7550168631	\N	\N	\N	f	https://www.instamojo.com/@joeydash/50a1ee8d42bb4f9baf78f43555035277	\N	106346546956435892842	50a1ee8d42bb4f9baf78f43555035277
46	Rohan Narayan 	EP18B028	\N	\N	\N	8129510549	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6a8e81bdaac740369b5b69110875352e	\N	110035970755160527050	6a8e81bdaac740369b5b69110875352e
47	Sukrit Kumar Gupta	CE16B013	\N	\N	\N	9454199718	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1c3dc1aab86147008dba4a3e7a76377d	\N	113046604995058376278	1c3dc1aab86147008dba4a3e7a76377d
48	Shashank M Patil 	Ch18b022	\N	\N	\N	6362748509	\N	\N	\N	f	https://www.instamojo.com/@joeydash/40a8a150efd54e3c8fb850218240f848	\N	114832114521563248786	40a8a150efd54e3c8fb850218240f848
49	Amarnath Prasad	AE18B001	\N	\N	\N	8972637830	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2840a37faa7f418eacb8295a2cc25569	\N	110088160541028725569	2840a37faa7f418eacb8295a2cc25569
50	Aditya Parag Rindani	ME18B037	\N	\N	\N	7506072729	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c36b0f823a4044a78131a05ddf06edc7	\N	106151943570612705662	c36b0f823a4044a78131a05ddf06edc7
51	Prajeet Oza	MM17B024	\N	\N	\N	8767888916	\N	\N	\N	f	https://www.instamojo.com/@joeydash/957d2ddf4829467281c64796bd71d6e6	\N	100180464561448951684	957d2ddf4829467281c64796bd71d6e6
52	Aditya kommineni 	Ee17b047	\N	\N	\N	8309801301	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9b09a887b0a94286bcaaf229661a3a13	\N	103517082880442482622	9b09a887b0a94286bcaaf229661a3a13
53	Subhankar Chakraborty	EE17B031	\N	\N	\N	8328960847	\N	\N	\N	f	https://www.instamojo.com/@joeydash/186d26f66f8840c298150a7779506041	\N	116457314552526686941	186d26f66f8840c298150a7779506041
54	Divika Agarwal	Ch17b043	\N	\N	\N	9167879798	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9998d92d7c914273980d4002652d8f0f	\N	102052775561051041362	9998d92d7c914273980d4002652d8f0f
55	Rutvik Baxi	Ed18b050	\N	\N	\N	8866419419	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8ddb6621a8834d8a941019cb7e5398fc	\N	117005101380398480170	8ddb6621a8834d8a941019cb7e5398fc
56	Amrit Sharma	EP18B015	\N	\N	\N	8586824098	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9ce682100d6c435688436ff39515cb6f	\N	117068008597284134843	9ce682100d6c435688436ff39515cb6f
57	Siddharth Lotia	18101046	\N	\N	\N	9406020745	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2e4a66e68d9e487bb2f6eeec8d07fefc	\N	113814269201509832881	2e4a66e68d9e487bb2f6eeec8d07fefc
58	Neel Balar	Ed18b019	\N	\N	\N	9663329307	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f31a6c2943ae4359b83f529c6f7e60b3	\N	110086250388526798686	f31a6c2943ae4359b83f529c6f7e60b3
59	Harshita Ojha	Bs17b012 	\N	\N	\N	9009800655	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d1906d410bd34c8698419e0847d2d6cf	\N	101052355478693521918	d1906d410bd34c8698419e0847d2d6cf
60	Sourabh Thakur	Ch17b022	\N	\N	\N	7062940762	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8daaa9eb1cb3454c847a21fe292fcbf3	\N	108046082470898711935	8daaa9eb1cb3454c847a21fe292fcbf3
61	Pranav Dayanand Pawar	MM17B003	\N	\N	\N	9521379785	\N	\N	\N	f	https://www.instamojo.com/@joeydash/819f779c46ef42f38f9ff8ad34cd5ef4	\N	102139067499961218783	819f779c46ef42f38f9ff8ad34cd5ef4
62	Parth Doshi	BE17B024	\N	\N	\N	8884647279	\N	\N	\N	f	https://www.instamojo.com/@joeydash/026dbe681bba42d4b8b656dfe9f991ca	\N	109694605773547105071	026dbe681bba42d4b8b656dfe9f991ca
63	KASHYAP AVS	ED17B026	\N	\N	\N	7337421279	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a2538cc394b54752b71ac17072756a9c	\N	112693133093914151701	a2538cc394b54752b71ac17072756a9c
65	SREE VISHNU KUMAR V 	ED18B032	\N	\N	\N	7904754979	\N	\N	\N	f	https://www.instamojo.com/@joeydash/90ca614ee6f5441bafa59edbd53450b4	\N	116987835442491396459	90ca614ee6f5441bafa59edbd53450b4
66	Unnat Gaud	ch18b004	\N	\N	\N	9930881423	\N	\N	\N	f	https://www.instamojo.com/@joeydash/36727675088040d59d31f59b2a4862ea	\N	108716062842174923272	36727675088040d59d31f59b2a4862ea
68	Ayush Toshniwal	EE17B157 	\N	\N	\N	8975051167	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9bedd873bb1d4f60b923be97eaecd0b4	\N	101411725174892658523	9bedd873bb1d4f60b923be97eaecd0b4
69	Abhinav Azafd	ED17B001	\N	\N	\N	8504894849	\N	\N	\N	f	https://www.instamojo.com/@joeydash/28239a0f44e041ddb2fd82e86b15da0a	\N	116474837895993246041	28239a0f44e041ddb2fd82e86b15da0a
71	Alexander David	MM17B009	\N	\N	\N	8903458216	\N	\N	\N	f	https://www.instamojo.com/@joeydash/476f004917a44f48a177e7a7bfa72de6	\N	100046381709706919563	476f004917a44f48a177e7a7bfa72de6
73	SUBHASIS PATRA	1741012100	\N	\N	\N	8328861067	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f418232799c2444a9a1db930820f0b12	\N	100174145732475175347	f418232799c2444a9a1db930820f0b12
64	harigovind	ed17b042	iitm	engineering design	8.6	9496663228	null	ed17b042@smail.iitm.ac.in	\N	t	https://www.instamojo.com/@joeydash/d3e1ab6a89684211966f7fe1209cfebb	MOJO9224A05A48151378	109528850140803698362	d3e1ab6a89684211966f7fe1209cfebb
81	Meenal	CE17B046	\N	\N	\N	7798570786	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dacfd77952da411c89b62832f2ee61e6	\N	113973502411437413660	dacfd77952da411c89b62832f2ee61e6
82	A  T Nathaniel Nirmal	110117018	\N	\N	\N	9789975621	\N	\N	\N	f	https://www.instamojo.com/@joeydash/57d9267dd6ca4f219f7fdcc6c3273fef	\N	100323225494928384224	57d9267dd6ca4f219f7fdcc6c3273fef
83	Prashant Jay	ED17B021	\N	\N	\N	7891425196	\N	\N	\N	f	https://www.instamojo.com/@joeydash/da2c08424d4f417c8496a914cd29109e	\N	117437871277613629999	da2c08424d4f417c8496a914cd29109e
70	Pranjali Vatsalaya 	EE17B144 	\N	\N	\N	9840914404	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e42db52051c74ae39aed437bebffc2a7	\N	111558464273085465448	e42db52051c74ae39aed437bebffc2a7
67	Aryan Pandey	ch17b105	IITM	Chemical Engineering	8.61	9840919511	9873481644	ch17b105@smail.iitm.ac.in	\N	t	https://www.instamojo.com/@joeydash/6e8d03b65c1c4fc494c623298450bb2c	MOJO9224Z05A48151320	104171369330644075313	6e8d03b65c1c4fc494c623298450bb2c
72	Neil Ghosh	ME17B060	\N	\N	\N	9527087532	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d5180fb94e944324b4b805450f547c10	\N	117732606660029053405	d5180fb94e944324b4b805450f547c10
74	PRADEEPA. K	311117205043	\N	\N	\N	9840899059	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1d8d2153e8a24f6cb92ccc5eeb2e112b	\N	104341823850477467850	1d8d2153e8a24f6cb92ccc5eeb2e112b
75	PRADUMN KARAGI	Be18b009	\N	\N	\N	8947027067	\N	\N	\N	f	https://www.instamojo.com/@joeydash/86623f535f8e4c7fab40c91ff38a0343	\N	101475449072728420854	86623f535f8e4c7fab40c91ff38a0343
77	Nikit bassi	NA	\N	\N	\N	9592995946	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4a80828f3a5c4c6da7518e23067fe9fa	\N	101285149807471176908	4a80828f3a5c4c6da7518e23067fe9fa
78	Vundela Sasidhar Reddy	ED18B056	\N	\N	\N	7093556234	\N	\N	\N	f	https://www.instamojo.com/@joeydash/231619e968484c2db09db4ba2608c281	\N	104615193672641411565	231619e968484c2db09db4ba2608c281
79	RISHABH SHAH	ME18B029	\N	\N	\N	7567607501	\N	\N	\N	f	https://www.instamojo.com/@joeydash/35c0b0125cd44397a79e93222095cea6	\N	106447284908872676152	35c0b0125cd44397a79e93222095cea6
84	Karil Garg 	Bs18b018 	\N	\N	\N	9549639468 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bc06d8ed26cc4606a74a6a211af38864	\N	114351628888398386175	bc06d8ed26cc4606a74a6a211af38864
85	Goutham Zampani 	CE14B062	\N	\N	\N	9790469254	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3d06ff23824042bbb3368081e8881088	\N	107434291759433018037	3d06ff23824042bbb3368081e8881088
86	Aniswar Srivatsa Krishnan	CS18B050	\N	\N	\N	6383393474	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b0a05fc2a6914762a73424eaeaf99dae	\N	101887063519379114033	b0a05fc2a6914762a73424eaeaf99dae
87	Niharika Srivastav	I056	\N	\N	\N	9619176070	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bdcc668c18364cb19676c17e76fa9e3d	\N	115382621843699309946	bdcc668c18364cb19676c17e76fa9e3d
89	Abhranil Chakrabarti	CH17B034	\N	\N	\N	9082120679	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b0075bf8551e43d7b9647a7a0bf4ae55	\N	105735616610991386244	b0075bf8551e43d7b9647a7a0bf4ae55
91	Siddharth Dey	Me18b075	\N	\N	\N	8018971019	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a6c42b208c044fae8f1205d0cf742545	\N	106478730192157907359	a6c42b208c044fae8f1205d0cf742545
93	Taher Poonawala	mm17b032	\N	\N	\N	9619790376	\N	\N	\N	f	https://www.instamojo.com/@joeydash/528b4f309bb240dcaf0c48da1fdbcd4b	\N	117356223086180674242	528b4f309bb240dcaf0c48da1fdbcd4b
80	Srishti Adhikary	AE18B012	IITM	Aerospace Engineering	9.22	8904404266	7397243527	7.0111SA2000ms@gmail.com	\N	t	https://www.instamojo.com/@joeydash/6b4dab56f419456f9833fe1fea3dfedf	MOJO9224E05D48151542	116111249617413389973	6b4dab56f419456f9833fe1fea3dfedf
94	Gagan Srivastav	Ee17b042	\N	\N	\N	9490825193	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5827ecc897ee4b2a99ddbde27879e0df	\N	107489933466838356493	5827ecc897ee4b2a99ddbde27879e0df
95	Ram kiran	me17b149	\N	\N	\N	9182743080	\N	\N	\N	f	https://www.instamojo.com/@joeydash/702dbafb92724c66844c3a5c2ca81a50	\N	111128207069265376383	702dbafb92724c66844c3a5c2ca81a50
96	NITIN CHAUHAN	ME15B122	\N	\N	\N	9999393960	\N	\N	\N	f	https://www.instamojo.com/@joeydash/47fbd1f29afd49b98090cc6e715c0c2d	\N	100166136587028365869	47fbd1f29afd49b98090cc6e715c0c2d
97	Davis Andherson F	ED17B037	\N	\N	\N	9941389689	\N	\N	\N	f	https://www.instamojo.com/@joeydash/cff9f16465ab4c00b88e25d3e76da558	\N	107827922432577522549	cff9f16465ab4c00b88e25d3e76da558
98	Aayush Atalkar	10	\N	\N	\N	8237189043	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b55dfa281779463a840ec1170309a916	\N	114121932947581881721	b55dfa281779463a840ec1170309a916
99	Yerra Jai Ganesh	Me17b075	\N	\N	\N	9494211910	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3ec1649b6c5742d8b13a69a766308d3d	\N	118240680244675482931	3ec1649b6c5742d8b13a69a766308d3d
100	Aditya Raj	1RV17CS010	\N	\N	\N	7277113307	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fae1139c7e5445aaba1cc6f9c8f9d850	\N	111140359246612411654	fae1139c7e5445aaba1cc6f9c8f9d850
101	Yashwanth	Me18b006	\N	\N	\N	7993621838	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d74246b32a634c77b852b5b2b4d8e6fa	\N	106540878792009138011	d74246b32a634c77b852b5b2b4d8e6fa
102	Rahul Jain	CH18B019	\N	\N	\N	9530181131	\N	\N	\N	f	https://www.instamojo.com/@joeydash/57206d35559f4c69a885cadc7af8c27b	\N	107147930685919857188	57206d35559f4c69a885cadc7af8c27b
103	Bablu Devsingh Sitole	me18b103	\N	\N	\N	8370079960	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d7869543535d4e2a8d84b326473be6af	\N	103702551939099288693	d7869543535d4e2a8d84b326473be6af
104	J.A.Dhanush Aadithya	ED17B010	\N	\N	\N	9176168935	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a207265e12bb42ae836686353ed04dc2	\N	109289325891115045173	a207265e12bb42ae836686353ed04dc2
105	Sai Krishna kota	Ce17b054	\N	\N	\N	9182246163	\N	\N	\N	f	https://www.instamojo.com/@joeydash/226449895ac147f3b565d45e8f2317c4	\N	102748409040120330310	226449895ac147f3b565d45e8f2317c4
107	Neel Changani	K009	\N	\N	\N	9819660821	\N	\N	\N	f	https://www.instamojo.com/@joeydash/33e5ff51ac30465d8d8c1eac445a0fd1	\N	114360394443508391157	33e5ff51ac30465d8d8c1eac445a0fd1
108	Sriujanm	17CE1081	\N	\N	\N	9403254410	\N	\N	\N	f	https://www.instamojo.com/@joeydash/584cba27c9a844c19f3a125fa1e60bcb	\N	105122427801569397480	584cba27c9a844c19f3a125fa1e60bcb
109	Varun Choudhary 	CE15B96	\N	\N	\N	7023582684	\N	\N	\N	f	https://www.instamojo.com/@joeydash/53f8a2b904c4421486d350c3dbd4523b	\N	110606774466678924370	53f8a2b904c4421486d350c3dbd4523b
110	Raman Kumar	BS16B028	\N	\N	\N	8096866804	\N	\N	\N	f	https://www.instamojo.com/@joeydash/71b52f16cd7f45eea29ab990eb994b6a	\N	100373514490827653919	71b52f16cd7f45eea29ab990eb994b6a
106	Kandra Pavan	ME18B148	IITM	Mechanical Engineering	9.71	7358034555	9498302250	null	\N	t	https://www.instamojo.com/@joeydash/f65e4c602f8046c3a28210ad21bd21de	MOJO9224U05D48151813	107301028745384927900	f65e4c602f8046c3a28210ad21bd21de
111	Rohit Mahendran	16me118	\N	\N	\N	9047548111	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b37e0c83d8054273a26b5b5cf4d9fc1a	\N	108773897194648952785	b37e0c83d8054273a26b5b5cf4d9fc1a
112	Nithin Uppalapati	EE18B035	\N	\N	\N	6303458453	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9b08b92721704e2fa667aa75d87099ea	\N	108848347453031165545	9b08b92721704e2fa667aa75d87099ea
113	shreyas shandilya	ed16b029	\N	\N	\N	7985153872	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6ebb49d163b34e02a42d685c7d6689cf	\N	114840229803252179382	6ebb49d163b34e02a42d685c7d6689cf
114	Siddharth JP	NA16B118	\N	\N	\N	9840681502	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4bbfc8b7e34f4124ab2890b195e00634	\N	108536031230585647935	4bbfc8b7e34f4124ab2890b195e00634
115	K Vamshi Krishna	me18m039	\N	\N	\N	8106294939	\N	\N	\N	f	https://www.instamojo.com/@joeydash/81b5615f5eaf46cf94a40a8c7e776134	\N	112872968935980064890	81b5615f5eaf46cf94a40a8c7e776134
116	Shashwath	ED16B028	\N	\N	\N	9036011556	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bd0283887dd7480ba010e2d418fbdb2e	\N	100006462132328751764	bd0283887dd7480ba010e2d418fbdb2e
117	Bharat Jayaprakash	ED16B007	\N	\N	\N	8369695129	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dfe82f2345264c868589588c5050bb63	\N	100629454340115098641	dfe82f2345264c868589588c5050bb63
118	Sikhakollu Venkata Pavan Sumanth 	Ee18b064 	\N	\N	\N	7032020575	\N	\N	\N	f	https://www.instamojo.com/@joeydash/10dd74a3cb1546a9a5b7d455723174bf	\N	105534379261061050947	10dd74a3cb1546a9a5b7d455723174bf
120	Mitte Siddartha sai	Cs18b028	\N	\N	\N	9133464549	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bf40c1be1e2049358a8ed3a808fb927d	\N	105001332348729167995	bf40c1be1e2049358a8ed3a808fb927d
122	shubham jain	Me16b165	\N	\N	\N	8486217292	\N	\N	\N	f	https://www.instamojo.com/@joeydash/228be1bbfc46416e9b3cac50f31f1e63	\N	101398156657528003471	228be1bbfc46416e9b3cac50f31f1e63
129	Varad Joshi	me17b038	\N	\N	\N	9511639134	\N	\N	\N	f	https://www.instamojo.com/@joeydash/79a292e4b83d493db29a7a701540a71c	\N	117966690353831815134	79a292e4b83d493db29a7a701540a71c
127	V Vishnu Kiran	CS18B067	IIT Madras	Computer science	10	7338712646	9840017313	cs18b067@smail.iitm.ac.in	\N	t	https://www.instamojo.com/@joeydash/0fd28307c37c43b38941f75804a92948	MOJO9224A05D48152097	113681390068745417997	0fd28307c37c43b38941f75804a92948
135	Mokshagna Sai Teja Komatipolu	2015104062	\N	\N	\N	9941989881	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e13e3ab8a79a4bee9efb3c8aa0574f21	\N	103923783699459229771	e13e3ab8a79a4bee9efb3c8aa0574f21
136	S Sidhartha Narayan 	EP18B030 	\N	\N	\N	7010892474	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c02dd2add4bd41fe9d7e49f268864363	\N	110757805238250702422	c02dd2add4bd41fe9d7e49f268864363
137	Devraj	me15b100	\N	\N	\N	9468865064	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9ec1831f5c0843fc9fcad183a54e61f4	\N	107413706842790560056	9ec1831f5c0843fc9fcad183a54e61f4
138	Rudram	ed16b024	\N	\N	\N	9940334981	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2e7cc4416c094e3694f2df1f0e98b5ad	\N	113712306728446985892	2e7cc4416c094e3694f2df1f0e98b5ad
119	Arjun RK	18bec1120	\N	\N	\N	9003052629	\N	\N	\N	f	https://www.instamojo.com/@joeydash/08a5a3e6818e448c911198bc92f50b9e	\N	114704333810864603254	08a5a3e6818e448c911198bc92f50b9e
121	Viswanath Tadi	cs18b047	\N	\N	\N	9398821800	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0f5f358482bc4a85af7f26423cc7bb50	\N	110408636199196777944	0f5f358482bc4a85af7f26423cc7bb50
123	Ameya Rajesh Ainchwar	ME18B122	\N	\N	\N	9892525841	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7f62cf4e740e41beb620b46ebaf9fa25	\N	101633193710942170825	7f62cf4e740e41beb620b46ebaf9fa25
124	Adriza Mishra	BS18B013	\N	\N	\N	9717279799	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3fe2206da0734590b8c82e3192d34790	\N	116428881593753626712	3fe2206da0734590b8c82e3192d34790
125	Naga sai	Ch18b053	\N	\N	\N	6303305778	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2fb87f44938b4745b5ac9e5995ccdcd5	\N	112870414950478249881	2fb87f44938b4745b5ac9e5995ccdcd5
126	Aditya Parag Rindani	ME18B037	\N	\N	\N	7506072729	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3d0eec45aa224808896a6ddc4aa9601f	\N	108210163016263470552	3d0eec45aa224808896a6ddc4aa9601f
128	Yuvraj Singh	CS18B064	\N	\N	\N	7988056690	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9af616cb7c504b51b07c2e81e4c1b4a7	\N	101491417144470081112	9af616cb7c504b51b07c2e81e4c1b4a7
130	Mansi Choudhary	EE17B053	\N	\N	\N	8332957411	\N	\N	\N	f	https://www.instamojo.com/@joeydash/955bc106cd684244be5968a4e682cbbd	\N	115248078929890303214	955bc106cd684244be5968a4e682cbbd
131	Suraj Reddy	Bs18B015	\N	\N	\N	9381571532	\N	\N	\N	f	https://www.instamojo.com/@joeydash/88e5286aea88469d8308dc1ab3acbb8f	\N	115339962081142646939	88e5286aea88469d8308dc1ab3acbb8f
132	Poulomi Kha 	bs16b026	\N	\N	\N	9619502945	\N	\N	\N	f	https://www.instamojo.com/@joeydash/19330d1a3cb942a3a1a1192d33ad3465	\N	104863773335365538808	19330d1a3cb942a3a1a1192d33ad3465
134	Akilesh Kannan	ee18b122	\N	\N	\N	9840372545	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0b9acf0adbad40edb9dd057a019b4484	\N	107177554755735141269	0b9acf0adbad40edb9dd057a019b4484
139	Sudheendra	CS18B006	\N	\N	\N	9989434913	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e5dbd932e53242cca49ca57dae209e5f	\N	101180110198873131231	e5dbd932e53242cca49ca57dae209e5f
141	Kashish Kumar	CE17M079	\N	\N	\N	9971797184	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dbe7237040e44f9692dd4c58083e0c85	\N	108551370712006348201	dbe7237040e44f9692dd4c58083e0c85
142	Saluru Durga Sandeep	ME16B125	\N	\N	\N	9500195784	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fda6466aec15452cbcd4bb82e5e88e92	\N	106053419849481655127	fda6466aec15452cbcd4bb82e5e88e92
143	Krishna Gopal Sharma	CS18B021	\N	\N	\N	9887744162	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9878ded171d342918beaeec608a3d5d0	\N	114582343462323173676	9878ded171d342918beaeec608a3d5d0
144	Krishna Tejaswi 	ep17b018	\N	\N	\N	8985763064	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2b2338a2c5344bb7b4de5ab5e882f4f1	\N	107198149074547760918	2b2338a2c5344bb7b4de5ab5e882f4f1
145	Padidam Venkata Nitesh Kumar 	Ce16b006	\N	\N	\N	9032904382	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c650258b03ae4e63b8e19100378b12ff	\N	103273107959465057265	c650258b03ae4e63b8e19100378b12ff
146	Avasarala Krishna Koustubha 	ME18B126 	\N	\N	\N	9676776292 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4efb19a522514c74bd8ff66db38279b7	\N	100444374512123718431	4efb19a522514c74bd8ff66db38279b7
147	Anurag harsh	3616001	\N	\N	\N	9962905726	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d5df4a9b2a954ab8ab8d24c849f87024	\N	117764114579954744999	d5df4a9b2a954ab8ab8d24c849f87024
148	Ramanan S	EE18B145	\N	\N	\N	8825894252	\N	\N	\N	f	https://www.instamojo.com/@joeydash/2ab2872f3afd4a27a0aa52af07fd10e7	\N	113597979260889639153	2ab2872f3afd4a27a0aa52af07fd10e7
149	Viknesh S	ee17b073	\N	\N	\N	9003171125	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6af9151e017a44c4909e1b355721a561	\N	111066027705891320913	6af9151e017a44c4909e1b355721a561
150	Lakshna	ed16b044	\N	\N	\N	9500195719	\N	\N	\N	f	https://www.instamojo.com/@joeydash/308702cdf03449c68abb5010afdbb02e	\N	101307535630091801474	308702cdf03449c68abb5010afdbb02e
151	KORRAPATI H P BHARADWAJ	EE16B112	\N	\N	\N	9500182950	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7e6a23be812d43f9b9402e9561556913	\N	116481244449985283889	7e6a23be812d43f9b9402e9561556913
152	E SAMEER KUMAR	ME17B048	\N	\N	\N	6380241248	\N	\N	\N	f	https://www.instamojo.com/@joeydash/09068ab9fced4065a44d477e64c913f3	\N	115801243251886489865	09068ab9fced4065a44d477e64c913f3
153	Kaivalya Rakesh Chitre 	me17b018 	\N	\N	\N	8779693065	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c8026f1ff6be406590e51469d965bd13	\N	109121374241590014827	c8026f1ff6be406590e51469d965bd13
154	Neha Swaminathan	BE18B008	\N	\N	\N	6379698944	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8cf1f677161c4b7da3c6e7aadfbb3106	\N	109557453092405104728	8cf1f677161c4b7da3c6e7aadfbb3106
155	Basu Jindal	ME18B008	\N	\N	\N	6352487497	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3d4b6f4be6d54f2c8f9805fb23ccb8da	\N	111640459531281754733	3d4b6f4be6d54f2c8f9805fb23ccb8da
156	T Bala Sundar 	CS17B1062	\N	\N	\N	8247646440	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c33263919f754d1eb936518ca7b02757	\N	114885547058071668870	c33263919f754d1eb936518ca7b02757
157	G Venkata Sai Anooj	ME17B049	\N	\N	\N	7675888538	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a6d6a5443f94468a888e4e896e65f2db	\N	105187746276593629594	a6d6a5443f94468a888e4e896e65f2db
158	Shubham Kanekar	mm17b019	\N	\N	\N	9822229994	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5800a51fb41d473abb57ae7f0533398a	\N	117310687405189973052	5800a51fb41d473abb57ae7f0533398a
159	Mohammed Sanjeed	ED17B047	\N	\N	\N	8921957265	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f247d5898545468da8725d44b811b8d0	\N	114326744260308541754	f247d5898545468da8725d44b811b8d0
160	Sunanda Vishnu Somwase	8041	\N	\N	\N	9021393816	\N	\N	\N	f	https://www.instamojo.com/@joeydash/377b1567fb0647b18062b239625d4759	\N	102269853381680672389	377b1567fb0647b18062b239625d4759
161	Samad faraz	170106049	\N	\N	\N	8402036342	\N	\N	\N	f	https://www.instamojo.com/@joeydash/82b6147246bc4cd09f4e810a10d953dc	\N	104425878332120909243	82b6147246bc4cd09f4e810a10d953dc
162	Yogeshwar	18BEC1084	\N	\N	\N	9940017676	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1f8b8f53463d4b0ca3a263b4ee8bf341	\N	109098813558670849559	1f8b8f53463d4b0ca3a263b4ee8bf341
163	Saye Sharan	ME16B177	\N	\N	\N	7358739081	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f8f6d4a3085748a3acaa4ecab24a34ee	\N	114591386611984022174	f8f6d4a3085748a3acaa4ecab24a34ee
164	Devansh	BT16MEC035	\N	\N	\N	8272845556	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d6e3313828aa4f6cae3aeaa6a02bb6db	\N	111567725646650165125	d6e3313828aa4f6cae3aeaa6a02bb6db
140	Dhruvjyoti Bagadthey	ee17b156	IITM	Electrical engineering	9.91	8902377455	9831799051	djbagadthey@gmail.com	\N	t	https://www.instamojo.com/@joeydash/7edd948c179a4f4cbd795b81f9169b43	MOJO9224Z05A48152770	114093894912804568558	7edd948c179a4f4cbd795b81f9169b43
172	Skanda Swaroop TH	ME16B130	\N	\N	\N	9176330618	\N	\N	\N	f	https://www.instamojo.com/@joeydash/51f7efe07286446da4bc2061a80a18e4	\N	114591124276679160265	51f7efe07286446da4bc2061a80a18e4
173	P. Satya Sai Nithish	ME16B157	\N	\N	\N	9677210586	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dcffdc328fb84337ab4a79dca06cfe5f	\N	105433782240224469335	dcffdc328fb84337ab4a79dca06cfe5f
174	RA Keerthan	CH17B078	\N	\N	\N	7299024061	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4c8cc13c26c24d7d8eec791e2278ec43	\N	118406601333681717065	4c8cc13c26c24d7d8eec791e2278ec43
176	Sushma	ED17B016	\N	\N	\N	9182802442	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b79f81f8b15541e1a74367118f339d2d	\N	115039944234930695540	b79f81f8b15541e1a74367118f339d2d
177	Krishnakanth R	EE17B015	\N	\N	\N	9080486390	\N	\N	\N	f	https://www.instamojo.com/@joeydash/984bc67544ec479d9bee232a24977e51	\N	102658268322549131527	984bc67544ec479d9bee232a24977e51
179	Omender Mina	Mm18b025	\N	\N	\N	7230993266	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7890f25ed3204a6bafbd6b6fb1712c1b	\N	104220784359784029268	7890f25ed3204a6bafbd6b6fb1712c1b
182	Abhi	C072	\N	\N	\N	7048138715	\N	\N	\N	f	https://www.instamojo.com/@joeydash/12f8b22b95a041e482aae613bbfadcec	\N	109441309750837717539	12f8b22b95a041e482aae613bbfadcec
183	Gorthy Sai Shashank	ME17B141	\N	\N	\N	9840932156	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e5257615b66d4584b7f47f879d1974ab	\N	105620503580613926309	e5257615b66d4584b7f47f879d1974ab
186	Vihaan Akshaay Rajendiran	ME17B171	\N	\N	\N	7708809996	\N	\N	\N	f	https://www.instamojo.com/@joeydash/01709c148381436a9a9d5049ae504805	\N	113464349539753011433	01709c148381436a9a9d5049ae504805
187	Karthik Bachu	ME17B053	\N	\N	\N	8074928621	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e9d06e63ae274da3b6b68fe9674754f9	\N	112203812328864098110	e9d06e63ae274da3b6b68fe9674754f9
189	Sourav H	412415106094	\N	\N	\N	7358225765	\N	\N	\N	f	https://www.instamojo.com/@joeydash/25874ec57d05405cac23f8c5271711b1	\N	117368038713753317104	25874ec57d05405cac23f8c5271711b1
190	Srijan Kumar Upadhyay 	NA17B034	\N	\N	\N	9575162116	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7bb61260afb54e569cf31621ccfbdba6	\N	117773863857662055608	7bb61260afb54e569cf31621ccfbdba6
191	Denish Dhanji Vaid	EE17B159	\N	\N	\N	8879936887	\N	\N	\N	f	https://www.instamojo.com/@joeydash/895b395e68ac47e099230096810240b3	\N	100967102642433990682	895b395e68ac47e099230096810240b3
193	Turkesh Pote	29	\N	\N	\N	9769274603	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1b12d1d55eb5483da129c8e66e1a1f85	\N	108345004535686987028	1b12d1d55eb5483da129c8e66e1a1f85
194	Sushwath	ED17B036	\N	\N	\N	8897100392	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f8224b2241cf4b5586e4d70997152cca	\N	102330392737983603678	f8224b2241cf4b5586e4d70997152cca
195	Sidharth A P	CS17M045	\N	\N	\N	8086274662	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f402626ad27c4a7e99a62b3a88cc41f3	\N	111983544338321266182	f402626ad27c4a7e99a62b3a88cc41f3
197	Srihari	K.S	\N	\N	\N	9080530055	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b3df0a7059904b888dbdde1223779607	\N	101719078540936693965	b3df0a7059904b888dbdde1223779607
198	Vikas Singh	150180107061	\N	\N	\N	9639614942	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e2d8cfc97fb842999ebd3398731680a7	\N	100317160726643486440	e2d8cfc97fb842999ebd3398731680a7
199	Aman Basheer A	ED17B032	\N	\N	\N	9497602271	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f5482cf696fd46d6b2f52f07693f4707	\N	111703803711058182719	f5482cf696fd46d6b2f52f07693f4707
201	Abhishek Kumar	17BBA1631	\N	\N	\N	9570717114	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8663a87c09fd4fbd9874a3c2d6ac50c0	\N	114218010316466093767	8663a87c09fd4fbd9874a3c2d6ac50c0
202	Sambit Tarai	ed16b026	\N	\N	\N	9940308429	\N	\N	\N	f	https://www.instamojo.com/@joeydash/456d194112f64e9197d36243df9b2846	\N	104003420105956436392	456d194112f64e9197d36243df9b2846
175	Avvari Sai SSV Bharadwaj	CS17B007	IITM	Computer Science and Engineering	8.44	7382091743	9440779557	avvaribp@gmail.com	\N	t	https://www.instamojo.com/@joeydash/a0e3ead36f564321b7aaa8c4c3442ec1	MOJO9224D05N48152807	116528854078263730275	a0e3ead36f564321b7aaa8c4c3442ec1
203	Mohammed Khandwawala	EE16B117	Indian Institute of Technology Madras	Electrical Engineering	8.51	9940329022	null	mohammedkhandwawala100@gmail.com	\N	t	https://www.instamojo.com/@joeydash/f529ec681dde4e3888a77ab43530ae36	MOJO9224F05A48153125	118244727025742575334	f529ec681dde4e3888a77ab43530ae36
178	Harshitha Mothukuri	ASM17PGDM011	\N	\N	\N	9948125533	\N	\N	\N	f	https://www.instamojo.com/@joeydash/33f7d80c51eb4ebea036505a05bd5a3e	\N	114740917522394709774	33f7d80c51eb4ebea036505a05bd5a3e
180	Unman Nibandhe	ME18B035	\N	\N	\N	8007691177	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b9d424671ce74971b02a7e9eb1e92f60	\N	107393448684071128659	b9d424671ce74971b02a7e9eb1e92f60
181	Aaysha Anser Babu 	ae18b014 	\N	\N	\N	8301967536	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e2f0879938114788b87d465edf0f8415	\N	110931047755608602680	e2f0879938114788b87d465edf0f8415
133	Jonathan Ve Vance	ED17B014	IITM	Engineering Design	8.71	9497568098	8921041726	jonathanvevance@gmail.com	\N	t	https://www.instamojo.com/@joeydash/8749bb860c0440948a90e47687c666aa	MOJO9224D05A48152443	101927668361428071197	8749bb860c0440948a90e47687c666aa
171	Jebby Arulson	ae17b028	IITM	AEROSPACE ENGINEERING	9.13	7299247992	9941424233	jebbyarulson@gmail.com	\N	t	https://www.instamojo.com/@joeydash/8720be91d4ed4956ba30a7c1a2e145b8	MOJO9224G05N48152458	116837958596212598480	8720be91d4ed4956ba30a7c1a2e145b8
184	Souridas A	ae18b046	\N	\N	\N	9656123558	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c549d4a3dd924f269ad6860ec2d4a9cb	\N	106596281639246034885	c549d4a3dd924f269ad6860ec2d4a9cb
185	Bhashwar Ghosh	EP17B019	\N	\N	\N	9455708982	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1397b93db8264ef18a817a5be89d5831	\N	105506572235545868243	1397b93db8264ef18a817a5be89d5831
192	Aditya Balachander	EE18B101	\N	\N	\N	9940518320	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6abc2bcc4d8548a1a43ba4244ee482d9	\N	116189371214953919032	6abc2bcc4d8548a1a43ba4244ee482d9
196	Tadikamalla Chetana Tanmayee	ce18b125	\N	\N	\N	9948335818 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c1703e3506d948a0b6884ff6e7f1be50	\N	107726028519801979477	c1703e3506d948a0b6884ff6e7f1be50
200	Mohil	ME16B117	\N	\N	\N	8793038793	\N	\N	\N	f	https://www.instamojo.com/@joeydash/efaed96176754f95a8c61e32fdd63f6a	\N	104564285080152210085	efaed96176754f95a8c61e32fdd63f6a
204	Ananya Shetty	PH18B007	\N	\N	\N	9892974022	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6d96def546004636b0024a7d0556bcc7	\N	103612128499527056792	6d96def546004636b0024a7d0556bcc7
205	Santhosh	ASM17PGDM014	\N	\N	\N	9963989698	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b28f07335a374c7e8c806f32a8e719f3	\N	111203068180225244060	b28f07335a374c7e8c806f32a8e719f3
206	Alaparthi. Lohitha 	Bs18b008	\N	\N	\N	8919602965 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fc9be256ce1b471293054f5fb9d4074f	\N	101171591693354500761	fc9be256ce1b471293054f5fb9d4074f
207	Ahad Modak	052	\N	\N	\N	9930438173	\N	\N	\N	f	https://www.instamojo.com/@joeydash/ac01db11bd29483e9901cf1073aa58ee	\N	106653443315295232533	ac01db11bd29483e9901cf1073aa58ee
208	Abhimanyu Swaroop	MM17B008	\N	\N	\N	9819915368	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1fe773be6d694fdba134d0ac5bb48b32	\N	101964436097463168367	1fe773be6d694fdba134d0ac5bb48b32
209	Chinmay Kulkarni	14426	\N	\N	\N	9404028919	\N	\N	\N	f	https://www.instamojo.com/@joeydash/be1c25c92b764705836095943c1c99e8	\N	104547213757131706346	be1c25c92b764705836095943c1c99e8
210	Teja	AE16B104	\N	\N	\N	9494133978	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f22306d5d58743dc80626542249eea7e	\N	109432364385136243098	f22306d5d58743dc80626542249eea7e
211	Aayush Raj	MM18B008	\N	\N	\N	9767210407	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bfbec96fd8624417b375da54ca2bcb8e	\N	104196509524819380284	bfbec96fd8624417b375da54ca2bcb8e
212	Aditya singh mahala 	CE17B023 	\N	\N	\N	9840870610 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/aa66c9180e7e4f3b8bf08a7c9f54542d	\N	105702456308731098062	aa66c9180e7e4f3b8bf08a7c9f54542d
213	Abhishek Bakolia	EE16B101	\N	\N	\N	9462735198	\N	\N	\N	f	https://www.instamojo.com/@joeydash/9ae73a07137149b6a54dcbca5a9d41cb	\N	110283615455900532725	9ae73a07137149b6a54dcbca5a9d41cb
214	Yuvraj Singh	CS18B064	\N	\N	\N	7988056690	\N	\N	\N	f	https://www.instamojo.com/@joeydash/899cdef68f9d4f0a8ba01f2af0d549a2	\N	106635592932027981078	899cdef68f9d4f0a8ba01f2af0d549a2
215	HANUSHAVARDHINI.S	HS18H019	\N	\N	\N	6383841254	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5ceb0019172c4c8aa63227e2ae270b5f	\N	101626955168185208012	5ceb0019172c4c8aa63227e2ae270b5f
216	Varun Awasthi	CH18B028	\N	\N	\N	7798948567	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b8efea263bd046e190a5a4f604b3d990	\N	102627795555924271019	b8efea263bd046e190a5a4f604b3d990
217	Siddharth Kapre	ch16b065	\N	\N	\N	6361095619	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4faf9ff6bc0d47179ff74b5892050743	\N	102719715304204500462	4faf9ff6bc0d47179ff74b5892050743
218	Kiran Skk	Bs17b107	\N	\N	\N	8660061270	\N	\N	\N	f	https://www.instamojo.com/@joeydash/31e471813380435ca08d2c4ab11da6c1	\N	107033203380308127028	31e471813380435ca08d2c4ab11da6c1
219	Abhishek Sekar 	EE18B067 	\N	\N	\N	9884918855 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5588403a5d4245bf8d07b0fec8831074	\N	113069714899047220836	5588403a5d4245bf8d07b0fec8831074
220	Sashank	ME18B160	\N	\N	\N	9381131601	\N	\N	\N	f	https://www.instamojo.com/@joeydash/41c42ef58af541829f5858a176a10619	\N	110018183307703015999	41c42ef58af541829f5858a176a10619
221	Atharva Mashalkar	CE18B136	\N	\N	\N	7620099155	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b15ab4a175dd4313a8c02c885bc18264	\N	109722948945101591188	b15ab4a175dd4313a8c02c885bc18264
222	Kailash Lakshmikanth	BE18B004	\N	\N	\N	6380044291	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a9ed7dde5e724110beeb0c48f1147a06	\N	110271268844549390100	a9ed7dde5e724110beeb0c48f1147a06
223	Vibodh pankaj	EE18B159	\N	\N	\N	9885277781	\N	\N	\N	f	https://www.instamojo.com/@joeydash/a0f3349f621c45faad4e3497574a97d6	\N	104181085677236457428	a0f3349f621c45faad4e3497574a97d6
224	Sri Sindhu Gunturi	CS18B058 	\N	\N	\N	7702626727	\N	\N	\N	f	https://www.instamojo.com/@joeydash/e82cc361645646fc8a699290e2fec571	\N	101172755541818547188	e82cc361645646fc8a699290e2fec571
225	Aniket Charjan 	17ME02018 	\N	\N	\N	8888502370 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1f8baccb780242a4af00dd3c089fe70b	\N	101171188455426530274	1f8baccb780242a4af00dd3c089fe70b
226	ADITYA TODKAR	55	\N	\N	\N	9404382819	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f4da64163bc7477c9ac7f556c78c0052	\N	106355600612411521354	f4da64163bc7477c9ac7f556c78c0052
227	Shankar lal	Ce16b125	\N	\N	\N	7822025458	\N	\N	\N	f	https://www.instamojo.com/@joeydash/defa6b00a53a4733b1e6a6ecb6e6bdcd	\N	102378491167760853351	defa6b00a53a4733b1e6a6ecb6e6bdcd
228	Sivasubramaniyan Sivanandan	EE17B029	\N	\N	\N	9003222378	\N	\N	\N	f	https://www.instamojo.com/@joeydash/63f29e7fd1764a228a6226ff0bf21e66	\N	116759539753758122369	63f29e7fd1764a228a6226ff0bf21e66
229	Nandhini	110117058	\N	\N	\N	8825624134	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b3ea554aeb0b4e20aac6ffc55ea1af71	\N	103308922454507465852	b3ea554aeb0b4e20aac6ffc55ea1af71
230	Naveen Kumaar S	ME17B028	\N	\N	\N	8838169339	\N	\N	\N	f	https://www.instamojo.com/@joeydash/870e43b8cce6496998bead853f553f03	\N	113468750706613363716	870e43b8cce6496998bead853f553f03
231	Nithin Babu	EE18B021	\N	\N	\N	9566112265	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c08a3c4e29a34f14a1e93060cb344228	\N	104294280397208849479	c08a3c4e29a34f14a1e93060cb344228
232	Nischith shadagopan m n	CS18B102	\N	\N	\N	9886548048	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8607d4ff03a4420f9602d865e4849af4	\N	104768237535269074850	8607d4ff03a4420f9602d865e4849af4
188	Nishant Patil	EE17B023	IITM	Electrical Engineering 	9	9087100334	null	null	\N	t	https://www.instamojo.com/@joeydash/dd03fccce95e443286d8026c793f98fe	MOJO9224205A48153197	100427482293316682936	dd03fccce95e443286d8026c793f98fe
236	Bolisetty N V S R Mahesh	ME16B137	\N	\N	\N	9493823170	\N	\N	\N	f	https://www.instamojo.com/@joeydash/592b37a2a4ba445883fd51c72a8ce577	\N	104662693858655380465	592b37a2a4ba445883fd51c72a8ce577
238	Aravamudhan	171101506	\N	\N	\N	9176985869	\N	\N	\N	f	https://www.instamojo.com/@joeydash/f3d19ca8eac646448a02562f4376b3da	\N	102195777194996285654	f3d19ca8eac646448a02562f4376b3da
240	Adnan Faisal	17MI31003	\N	\N	\N	9748730688	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8679766c42c44997a9d5422ab65808cd	\N	102823766561575238807	8679766c42c44997a9d5422ab65808cd
246	Rithvik Anil	ME16B123	\N	\N	\N	9884304490	\N	\N	\N	f	https://www.instamojo.com/@joeydash/17bad409f4c84841939182f59ea600f7	\N	108733883465772823484	17bad409f4c84841939182f59ea600f7
239	Anirudh Chavali	ME17B007	IITM	Mechanical engineering	8.88	9080958460	7207803252	wdp4.20043kjm@gmail.com	\N	t	https://www.instamojo.com/@joeydash/cc8f4a6eef02438284ca7d61bbd59261	MOJO9224P05D48153408	106348211089456308863	cc8f4a6eef02438284ca7d61bbd59261
247	Yash Gupta	1MS16CV111	\N	\N	\N	8105946633	\N	\N	\N	f	https://www.instamojo.com/@joeydash/fec91de9e53b45c4841d809384846288	\N	104971464362178380321	fec91de9e53b45c4841d809384846288
248	Shubham Subhas Danannavar	ED17B024	\N	\N	\N	9940038097	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dff63fec83394471bbf62f40b3183e20	\N	101988431255785683948	dff63fec83394471bbf62f40b3183e20
249	Sahil Kumar 	ME17B066 	\N	\N	\N	9082380294 	\N	\N	\N	f	https://www.instamojo.com/@joeydash/3867d53d5f114eab87201a5462e480d2	\N	112998653258877975475	3867d53d5f114eab87201a5462e480d2
251	D.Pavan Kumar Singh	Ae17b003	\N	\N	\N	6360063723	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5b776c791a3c4db0918c06254adf3aad	\N	100876071657723299498	5b776c791a3c4db0918c06254adf3aad
252	Avasarala Krishna Koustubha	ME18B126	\N	\N	\N	9676776292	\N	\N	\N	f	https://www.instamojo.com/@joeydash/8709c2aca0c648e19000a9b541be51c7	\N	104063535906637928892	8709c2aca0c648e19000a9b541be51c7
259	SRIKANTH MALYALA	CE16B040	\N	\N	\N	9092929824	\N	\N	\N	f	https://www.instamojo.com/@joeydash/dc07ae64b0f7405997de6beba4982910	\N	117276624581419753619	dc07ae64b0f7405997de6beba4982910
260	Suhas Kumar	EE17B109	\N	\N	\N	9949510388	\N	\N	\N	f	https://www.instamojo.com/@joeydash/50817e639d3d46d283526c3bdf40d6a9	\N	116522826000331691456	50817e639d3d46d283526c3bdf40d6a9
234	Sourav Bose	ASM17PGDM004	\N	\N	\N	9836948966	\N	\N	\N	f	https://www.instamojo.com/@joeydash/6b32909ec74148dc8feede8740b64d91	\N	104523922747918185043	6b32909ec74148dc8feede8740b64d91
235	Sarva M Sumanth	15G01A0585	\N	\N	\N	7780374216	\N	\N	\N	f	https://www.instamojo.com/@joeydash/cd10670e55f24ce89f3b21c9be5fb2a5	\N	102341274763983527312	cd10670e55f24ce89f3b21c9be5fb2a5
237	Niraj Kumar	17085049	\N	\N	\N	8083305109	\N	\N	\N	f	https://www.instamojo.com/@joeydash/d197deccf0db45bb8a402910a830e2b4	\N	108496699258995503222	d197deccf0db45bb8a402910a830e2b4
241	SAI SREE HARSHA	ME16B132	\N	\N	\N	9940325889	\N	\N	\N	f	https://www.instamojo.com/@joeydash/bbf8937871824ae9b5b498faf080f250	\N	111710272164921687698	bbf8937871824ae9b5b498faf080f250
242	VS Shyam	MM18B114	\N	\N	\N	8903404956	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0f048f7af55e4b18bdc73501446ff4f6	\N	116533323679531504829	0f048f7af55e4b18bdc73501446ff4f6
243	Pruthvi Raj R G	EE17B114	\N	\N	\N	8217387210	\N	\N	\N	f	https://www.instamojo.com/@joeydash/c6f8e91d77d64d40b12c558aa5bd52f2	\N	116667899528785398547	c6f8e91d77d64d40b12c558aa5bd52f2
244	Tejas Tayade	ME17B072	\N	\N	\N	7021467871	\N	\N	\N	f	https://www.instamojo.com/@joeydash/1e03e9f40c784292a7158618cfd96a08	\N	115433360587726830200	1e03e9f40c784292a7158618cfd96a08
245	Rishbha	ME16B162	\N	\N	\N	9500191210	\N	\N	\N	f	https://www.instamojo.com/@joeydash/940fd86efafb469c89a84aa4d5221fdb	\N	103108124271782832702	940fd86efafb469c89a84aa4d5221fdb
250	Sreenadhuni Kishan Rao	ED18B033	\N	\N	\N	9381404355	\N	\N	\N	f	https://www.instamojo.com/@joeydash/b1579a2397ed4c5e8842d99cf4c19543	\N	105576284422817967929	b1579a2397ed4c5e8842d99cf4c19543
253	Atharv Tiwari	18CHE163	\N	\N	\N	7709760009	\N	\N	\N	f	https://www.instamojo.com/@joeydash/7716539db17c4c8e95065484d0a1e25f	\N	112188830982780019541	7716539db17c4c8e95065484d0a1e25f
254	Saurav Jaiswal	16SCS2235	\N	\N	\N	9546852272	\N	\N	\N	f	https://www.instamojo.com/@joeydash/0c36d97956624747a42d2fd55e218d7d	\N	103131193577480666827	0c36d97956624747a42d2fd55e218d7d
255	Shankar T	412415205092	\N	\N	\N	9003175919	\N	\N	\N	f	https://www.instamojo.com/@joeydash/affa54d9adc844e1952c2966cf9ce3f0	\N	108977537476281644524	affa54d9adc844e1952c2966cf9ce3f0
256	Ramita Jawahar 	ME18B164 	\N	\N	\N	9500007218	\N	\N	\N	f	https://www.instamojo.com/@joeydash/21f76882d976497086c6271dca91cb84	\N	105765378409248116613	21f76882d976497086c6271dca91cb84
257	Om Shri Prasath	EE17B113	\N	\N	\N	8072112173	\N	\N	\N	f	https://www.instamojo.com/@joeydash/628627c483de49159a8022d95307c879	\N	108283492057740057468	628627c483de49159a8022d95307c879
258	Gayathri Guggilla 	EE14B086	\N	\N	\N	9790463669	\N	\N	\N	f	https://www.instamojo.com/@joeydash/5be53d49c2f144418270c4ae397c1034	\N	116365908916402634741	5be53d49c2f144418270c4ae397c1034
261	Aakash Kumar Katha	bs15b001	\N	\N	\N	9940143290	\N	\N	\N	f	https://www.instamojo.com/@joeydash/4c3328d86f3c4aa381249d0a37eaa9f8	\N	111790252858780067280	4c3328d86f3c4aa381249d0a37eaa9f8
\.


--
-- Data for Name: user_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_detail (id, name, email, image_url, user_h_id, startup_name, startup_id) FROM stdin;
1648	Joey Dash	joydassudipta@gmail.com	https://lh3.googleusercontent.com/-hjMQ9VBKHIw/AAAAAAAAAAI/AAAAAAAAFDk/ePiRR90JHaM/s96-c/photo.jpg	118208723166374240159	\N	277
1499	Hemant Ahirwar	hemantahirwar1@gmail.com	https://lh6.googleusercontent.com/-5ZZuFm2wgZM/AAAAAAAAAAI/AAAAAAAAAaw/TCx1OJbyvoI/s96-c/photo.jpg	106774401436596091547	\N	\N
1634	Baskaran Manimohan	baskaran@ahventures.in	https://lh6.googleusercontent.com/-R_pscFX1LGY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOnOjYw9yc5_QaMPrq1YAPJgaRhKw/s96-c/photo.jpg	104379184185174428302	\N	277
3965	SAURABH JAIN me16b071	me16b071@smail.iitm.ac.in	https://lh6.googleusercontent.com/-CRJj8Y-YaT0/AAAAAAAAAAI/AAAAAAAABOA/Vt5lacfmzFk/s96-c/photo.jpg	110553366885836969408	\N	\N
4386	Joey Dash	joeydash@saarang.org	https://lh3.googleusercontent.com/-fqOTgBE-kMg/AAAAAAAAAAI/AAAAAAAAAAc/g8JI3E0AcEw/s96-c/photo.jpg	103441912139943416551	\N	\N
4759	Om Kotwal	omkotwal14@gmail.com	https://lh4.googleusercontent.com/-Hz0BCz7SRqs/AAAAAAAAAAI/AAAAAAAAAB8/0qENic0HOdM/s96-c/photo.jpg	105648143853551093911	\N	\N
4853	Amarnath Prasad	amrnth007@gmail.com	https://lh4.googleusercontent.com/-BtTRd84R6SA/AAAAAAAAAAI/AAAAAAAAHeo/_uoH9Ji7LA4/s96-c/photo.jpg	116739830006062100225	\N	\N
4851	Rohan Rajmohan	rohanrrajmohan@gmail.com	https://lh5.googleusercontent.com/-nD3Xkwt-QV8/AAAAAAAAAAI/AAAAAAAAAf4/yN3lglHnzu0/s96-c/photo.jpg	110035970755160527050	\N	\N
1533	Hari Kishore P na18b019	na18b019@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7ar-bG4aw2w/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP2J9tbNK64Sf_yvE5lfHaOM-0LZQ/s96-c/photo.jpg	103546078731885007120	\N	\N
4852	SUKRIT KUMAR GUPTA	sukrit.dakshana15@gmail.com	https://lh6.googleusercontent.com/-i-kvWY0-JPY/AAAAAAAAAAI/AAAAAAAABKo/ZnUODV8w8wI/s96-c/photo.jpg	113046604995058376278	\N	\N
4905	Pranjali Vatsalaya	pranjali.vats888@gmail.com	https://lh5.googleusercontent.com/-ZkOiAsrR3MM/AAAAAAAAAAI/AAAAAAAAAhY/f-VlLcQcAVg/s96-c/photo.jpg	111558464273085465448	\N	\N
4858	Madhav Maheshwari	madhavmaheshwari79@gmail.com	https://lh6.googleusercontent.com/-aiYP4fg0zcM/AAAAAAAAAAI/AAAAAAAAHXs/l0fZj3PIr60/s96-c/photo.jpg	105718181361808782027	\N	\N
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
1880	Web Operations webops_ecell	webops_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-E2NF3HyXPss/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcmocOCuwTndSyNEml4gQ63sU6UFw/s96-c/photo.jpg	107813869731075135750	\N	\N
2189	Arokia Doss	arokia.d@srivishnu.edu.in	https://lh4.googleusercontent.com/-DDz9gu_vriY/AAAAAAAAAAI/AAAAAAAABqM/idtU5Q7OJao/s96-c/photo.jpg	115342870212009600095	\N	\N
2144	Sv J	srvajw@gmail.com	https://lh4.googleusercontent.com/-l5qFWbey1rk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN1SpZGyHHiMzehgUD_dC6jGboCOQ/s96-c/photo.jpg	101107640131204357570	\N	260
2083	iB Hubs Careers	careers@ibhubs.co	https://lh6.googleusercontent.com/-75N50cGyVXk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNxgeooH6nnrKGB9PHmOXDJO0UbXw/s96-c/photo.jpg	104821578026829852225	\N	\N
1885	Vibhor Kumar	vibhor.kumar@stanzaliving.com	https://lh5.googleusercontent.com/-B99IWpQLIFs/AAAAAAAAAAI/AAAAAAAAACw/qAjsXSzuFSM/s96-c/photo.jpg	115375476385745576962	\N	249
1914	Chandresh Vaghanani	chandresh@allevents.in	https://lh5.googleusercontent.com/-XMRGJqKg4fY/AAAAAAAAAAI/AAAAAAAAAzs/fMNjYRw3Xyo/s96-c/photo.jpg	109249031263145344654	\N	251
1908	Varun Chopra	chopravarun01@gmail.com	https://lh6.googleusercontent.com/-YxfnlUFwfPs/AAAAAAAAAAI/AAAAAAAAKwU/N3HuaVdpmeo/s96-c/photo.jpg	101189951357074482183	\N	\N
2224	Muralidhar Somisetty	muralidhars@wellnesys.com	https://lh6.googleusercontent.com/-mOvpU4EPmPE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMztpS4us1LBpvIDUIfKw-CnBeJiw/s96-c/photo.jpg	101907162894505620447	\N	268
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
4867	Shashank M Patil ch18b022	ch18b022@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Q31UIRBygVE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP7uDZ1lvghCfgvH30pcvo8gy0a0w/s96-c/photo.jpg	114832114521563248786	\N	\N
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
2428	Shubhangi Rastogi	shubhangi.r@thinkphi.com	https://lh5.googleusercontent.com/-kHHY6N0wlSE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOBLhJl46iMX7LNhis8Vm80-mYAqA/s96-c/photo.jpg	105502414900621283479		296
2376	MANIGANDLA KARTHIK	16211a05j2@bvrit.ac.in	https://lh5.googleusercontent.com/-f6iU1f21BEk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQORyDNhrJLPQ3lxVY4xL5H5obv0Eg/s96-c/photo.jpg	106907442348505117600	\N	\N
2851	samyak jain	jsamyak39@gmail.com	https://lh3.googleusercontent.com/-IRVlAqiNknI/AAAAAAAAAAI/AAAAAAAAFFo/hTFdbvXZFRM/s96-c/photo.jpg	103656407720006034171	\N	\N
2298	PAPPU GEETHA RANI	16wh5a0410@bvrithyderabad.edu.in	https://lh3.googleusercontent.com/-GZw2cyt73_U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPGNLkAJvzSucIidE4-PoOeTMsiOA/s96-c/photo.jpg	113035858086387927034	\N	\N
2303	Vivek Mishra	vivek.mishra@vphrase.com	https://lh4.googleusercontent.com/-5C0M5iSUyG8/AAAAAAAAAAI/AAAAAAAAACE/Xz8f72YmXrU/s96-c/photo.jpg	114537148790063843816	\N	\N
2304	Pranav Prabhakar	pranav@mistay.in	https://lh3.googleusercontent.com/-5uerjcW7oUA/AAAAAAAAAAI/AAAAAAAAAB0/x0O3-PL0r4w/s96-c/photo.jpg	103083422834575225895	\N	\N
3353	Mukund Khandelwal	mukundkhandelwal387@gmail.com	https://lh4.googleusercontent.com/-lIfx29SyK-Y/AAAAAAAAAAI/AAAAAAAAA64/vl76NErdncM/s96-c/photo.jpg	103158308128328545694	\N	\N
2676	Saurabh Jain	saurabhjain2799@gmail.com	https://lh5.googleusercontent.com/-ShuQsG1kJo0/AAAAAAAAAAI/AAAAAAAAGNM/cDVsuw9I11w/s96-c/photo.jpg	107156601039704846020	\N	\N
4040	God Save me	cubetechnologyindia@gmail.com	https://lh6.googleusercontent.com/-tFsQlO6T_kg/AAAAAAAAAAI/AAAAAAAAH2g/sHEhA6WtvE0/s96-c/photo.jpg	112396581591786005083	\N	\N
3027	Tapish Garg	tapishgarg0@gmail.com	https://lh5.googleusercontent.com/-zORyO3Aa-hI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcFdVYomZ1zNdT1I7HuqgDeGD8b0A/s96-c/photo.jpg	113824673222077196247	\N	\N
2546	Saurabh Jain	saurabhjain2702@gmail.com	https://lh4.googleusercontent.com/-v1tXSEetuRw/AAAAAAAAAAI/AAAAAAAAABw/AF3c_Gme-Hw/s96-c/photo.jpg	114818886750636854304	\N	302
2284	Thilagar Thangaraju	thilagar.thangaraju@gmail.com	https://lh6.googleusercontent.com/-aMY57O0b6bk/AAAAAAAAAAI/AAAAAAAAAEE/Djkwp2pcCTk/s96-c/photo.jpg	108454550000095213572	\N	273
3034	Akshit Bagde	akshit2000.bagde@gmail.com	https://lh3.googleusercontent.com/-VpGqtlLEyIE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfi8OzQcj4nn9mn0KwsinomWv2T6Q/s96-c/photo.jpg	110540228254791393418	\N	\N
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
4556	Abhishek Tigga ee17b101	ee17b101@smail.iitm.ac.in	https://lh6.googleusercontent.com/-gDsu2xZf7EU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNnvFpEs_7o8qSH1hIIZHviLQTRGA/s96-c/photo.jpg	104162540670104310859	\N	\N
4813	rohitth c	rohitthc123456789@gmail.com	https://lh6.googleusercontent.com/-LfwONza6Kfg/AAAAAAAAAAI/AAAAAAAAAHQ/-1N61P-AXmA/s96-c/photo.jpg	101827448437274338234	\N	\N
3242	Neeraj Jadhavar	jadhavarneeraj@gmail.com	https://lh4.googleusercontent.com/-S2D7fLT0Jwk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reEABUNVtX_7zg4wZkuxgCYi-y8UQ/s96-c/photo.jpg	101532661979094815998	\N	\N
4868	Subhankar Chakraborty	subhankarchakraborty48@gmail.com	https://lh4.googleusercontent.com/-eDM9QFooYTo/AAAAAAAAAAI/AAAAAAAAAok/VZa4nuEJn80/s96-c/photo.jpg	101142874371716107680	\N	\N
4839	Chinmay Raut	rautchinmay19@gmail.com	https://lh5.googleusercontent.com/-E2drtF1MNgs/AAAAAAAAAAI/AAAAAAAAIOQ/v-noUbfVQ9c/s96-c/photo.jpg	102312700975952431360	\N	\N
4991	Harshita Ojha bs17b012	bs17b012@smail.iitm.ac.in	https://lh5.googleusercontent.com/-c5nffVLnB2I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcHwGuXS4KLSUlO_OM7ZRelkgF5Bg/s96-c/photo.jpg	101052355478693521918	\N	\N
4832	Monika Nathawat	monikanathawat666@gmail.com	https://lh3.googleusercontent.com/-SGg1MH1lu2Y/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdNyJXs_JL_bkZZQu0Dx5DzGqEpig/s96-c/photo.jpg	101807814707039385860	\N	\N
4884	Subhankar Chakraborty	subhankarchakraborty415@gmail.com	https://lh4.googleusercontent.com/-AJUJeHaIczk/AAAAAAAAAAI/AAAAAAAAAIk/rA7Pc86hQgY/s96-c/photo.jpg	116457314552526686941	\N	\N
4913	Rutvik Baxi	rutvikbaxi@gmail.com	https://lh4.googleusercontent.com/-qD21S2sRe20/AAAAAAAAAAI/AAAAAAAAAAo/YboBpLAakk0/s96-c/photo.jpg	117005101380398480170	\N	\N
4846	T B Ramkamal ee18b153	ee18b153@smail.iitm.ac.in	https://lh5.googleusercontent.com/-6fhrQN3etyw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO1xMa8AyJ1lHlEuByXcacxz3QPPQ/s96-c/photo.jpg	106346546956435892842	\N	\N
4874	Prajeet Oza	prajeet0810@gmail.com	https://lh6.googleusercontent.com/-z7mXYFQSydY/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMznvdo8QJPoBK2GeXmEXbP_6vkew/s96-c/photo.jpg	100180464561448951684	\N	\N
4996	Mitanshu Khurana	khurana.mitanshu@gmail.com	https://lh4.googleusercontent.com/-tq1Wp8w37_Q/AAAAAAAAAAI/AAAAAAAAAWk/Lyet4XwgwQU/s96-c/photo.jpg	101452552670608521565	\N	\N
4157	Akshat Nagar	akshatnagarakioo@gmail.com	https://lh4.googleusercontent.com/-a5-koFrAuWI/AAAAAAAAAAI/AAAAAAAAABg/jJIs_3DVi-0/s96-c/photo.jpg	112955715421977386894	\N	\N
4875	Kommineni Aditya ee17b047	ee17b047@smail.iitm.ac.in	https://lh5.googleusercontent.com/-Qd4N03TfxxQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPA-WkcLd1b7qrdGO_gH_tXwQuZOw/s96-c/photo.jpg	103517082880442482622	\N	\N
4940	Siddharth Lotia	siddharthlotia04@gmail.com	https://lh3.googleusercontent.com/-QRfNeFgmI5M/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN01P0o5gfe6fyVo2gBRg_gAyxEcQ/s96-c/photo.jpg	113814269201509832881	\N	\N
5059	Sree Vishnu Kumar V ed18b032	ed18b032@smail.iitm.ac.in	https://lh6.googleusercontent.com/-_dmj1I-c-tg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfsjl7jCunCDbwgf8uBCWRouZfcZQ/s96-c/photo.jpg	116987835442491396459	\N	\N
5105	Ayush Atul Toshniwal ee17b157	ee17b157@smail.iitm.ac.in	https://lh5.googleusercontent.com/-qUv43xfQuPs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcLi68vNy5BsuVVoojBjHOt86JC6w/s96-c/photo.jpg	101411725174892658523	\N	\N
4649	Thirumala ReddyManishaReddy	16wh1a05b6@bvrithyderabad.edu.in	https://lh4.googleusercontent.com/-OCf5-yzk838/AAAAAAAAAAI/AAAAAAAAACE/ed_TW_5AyEg/s96-c/photo.jpg	113501286160076496682	\N	\N
2436	E-Cell IIT Madras	pr_ecell@smail.iitm.ac.in	https://lh4.googleusercontent.com/-kRHk2N5_ISQ/AAAAAAAAAAI/AAAAAAAAAQQ/Pb00b9CWRhw/s96-c/photo.jpg	100680093250543498335	\N	\N
5072	Gaud Unnat ch18b004	ch18b004@smail.iitm.ac.in	https://lh4.googleusercontent.com/-dCNFZ6ZXw64/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN7cPEcNwemfZufOsqEhdfpqQyx1Q/s96-c/photo.jpg	108716062842174923272	\N	\N
5030	Harshal Raaj Patnaik	harshalraajpatnaik@gmail.com	https://lh5.googleusercontent.com/-FanCVpyjwh4/AAAAAAAAAAI/AAAAAAAAAJ0/22X6ypU_Kj4/s96-c/photo.jpg	104402072932888164460	\N	\N
4908	Divika Sanjay Agarwal ch17b043	ch17b043@smail.iitm.ac.in	https://lh6.googleusercontent.com/-8d9SKmoXN6I/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNIhNOQr309K7WRUWVGu3hQCElKuQ/s96-c/photo.jpg	102052775561051041362	\N	\N
5142	Sanjay V	cy18c038@smail.iitm.ac.in	https://lh6.googleusercontent.com/-PGg88uSrHEo/AAAAAAAAAAI/AAAAAAAAAAU/K8E7w4PjIIU/s96-c/photo.jpg	105392709235674293466	\N	\N
4915	Amrit Sharma ep18b015	ep18b015@smail.iitm.ac.in	https://lh4.googleusercontent.com/-GvZPi24Y-Q0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPAa9SqUrWM3KgZQ9PK8iRGejfB3Q/s96-c/photo.jpg	117068008597284134843	\N	\N
4983	neel balar	neelbalar7@gmail.com	https://lh6.googleusercontent.com/-FZf73yMdHgs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reJT7vr4hvjVX8YqS5O4V1yub69ig/s96-c/photo.jpg	110086250388526798686	\N	\N
4864	Amarnath Prasad ae18b001	ae18b001@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Oe5Fp-9tW2M/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdUzfTedDAEjkkIhUFBdlu_0gUZoQ/s96-c/photo.jpg	110088160541028725569	\N	\N
5098	aryan pandey	aryanp35@gmail.com	https://lh4.googleusercontent.com/-Y-QpxPMvBDM/AAAAAAAAAAI/AAAAAAAAAmE/daYKVts9Si8/s96-c/photo.jpg	104171369330644075313	\N	\N
4943	Pranav Pawar	pranavpawar3@gmail.com	https://lh4.googleusercontent.com/-c-s9-pk0ZqU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcHO4CUA4NI32rDj0Up-sEj-TbMtA/s96-c/photo.jpg	102139067499961218783	\N	\N
4914	Ava Venkata Sai Kashyap ed17b026	ed17b026@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jklFt8gKaoc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfxB3vkgonLNciCMOk4VXWUr79GYw/s96-c/photo.jpg	112693133093914151701	\N	\N
5075	akriti ahuja	dhitu.ahuja@gmail.com	https://lh5.googleusercontent.com/-9EYOqnlRuMY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdlLkZhRGtCgFbmhTOh0Jg0VFqt5g/s96-c/photo.jpg	116204895236238903886	\N	\N
5133	Meesa Shivaram Prasad cs18b056	cs18b056@smail.iitm.ac.in	https://lh5.googleusercontent.com/-jtkhydQIMZ0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd1NuUSKwXrEZY7HAdHZc8r9nv26w/s96-c/photo.jpg	113583843316589152036	\N	\N
5038	HARIGOVIND RAMASWAMY	hgovind98@gmail.com	https://lh6.googleusercontent.com/-vMHyCHfqhRg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOiC-TbJHuDrwOt11v6YBTzxzNmoA/s96-c/photo.jpg	109528850140803698362	\N	\N
5029	Parth Keyur Doshi be17b024	be17b024@smail.iitm.ac.in	https://lh3.googleusercontent.com/-kOpGoSbb_nQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcBaK8MJI7HJ93JDS_aZWn5_12wtA/s96-c/photo.jpg	109694605773547105071	\N	\N
5114	ABHINAV AZAD	abhiazadz@gmail.com	https://lh4.googleusercontent.com/-jOcefTJxbE8/AAAAAAAAAAI/AAAAAAAANhY/ReNBiPkRme8/s96-c/photo.jpg	116474837895993246041	\N	\N
5162	Alexander David D mm17b009	mm17b009@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ET3DUr_u06I/AAAAAAAAAAI/AAAAAAAAABE/LQJ_eZ44KUk/s96-c/photo.jpg	100046381709706919563	\N	\N
5193	Neil Ghosh me17b060	me17b060@smail.iitm.ac.in	https://lh6.googleusercontent.com/-ZtxyOPISnMk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reKGxmg0i7hMIAMHnyJ-dQ_dHZ_AA/s96-c/photo.jpg	117732606660029053405	\N	\N
5208	Subhasis Patra	subhasispatra23@gmail.com	https://lh5.googleusercontent.com/-xIJPdiHHmfY/AAAAAAAAAAI/AAAAAAAAAWs/aQge91HGbbg/s96-c/photo.jpg	100174145732475175347	\N	\N
5211	PRADEEPA K 17IT	pradeepa.21it@licet.ac.in	https://lh3.googleusercontent.com/-6LqduwnNrdY/AAAAAAAAAAI/AAAAAAAAADU/8P6WIbgrtcM/s96-c/photo.jpg	104341823850477467850	\N	\N
5232	Pradumn Karagi be18b009	be18b009@smail.iitm.ac.in	https://lh3.googleusercontent.com/-l8-i12-EQSY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdS8_Bg13FQm2YgdrWChD9nB9Llkg/s96-c/photo.jpg	101475449072728420854	\N	\N
5291	Sasidhar Reddy	sasidharv10@gmail.com	https://lh5.googleusercontent.com/-I-Ge0KyMM1Q/AAAAAAAAAAI/AAAAAAAACME/_NnP8OEiAKk/s96-c/photo.jpg	104615193672641411565	\N	\N
5509	Taher Murtaza Poonawala mm17b032	mm17b032@smail.iitm.ac.in	https://lh3.googleusercontent.com/-X5vBb_dQyDA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcGWlFKvIgVcuXoj0otNQVtqIPV2Q/s96-c/photo.jpg	117356223086180674242	\N	\N
5670	Davis Andherson F ED17B037	ed17b037@smail.iitm.ac.in	https://lh5.googleusercontent.com/-mLhwVFB4ou0/AAAAAAAAAAI/AAAAAAAAAS0/OvGRYaw1Xr0/s96-c/photo.jpg	107827922432577522549	\N	\N
4990	Sourabh Thakur	sourabhthakurbhl@gmail.com	https://lh3.googleusercontent.com/-XpAH7WAp6ik/AAAAAAAAAAI/AAAAAAAAMFo/4C-uSLzfkKY/s96-c/photo.jpg	108046082470898711935	\N	\N
5435	Karil Garg bs18b018	bs18b018@smail.iitm.ac.in	https://lh5.googleusercontent.com/-9WS0UvUDeB8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNZwYu3p_HGGspwkGNcWzVbbFkuRw/s96-c/photo.jpg	114351628888398386175	\N	\N
5723	ganesh yerra	yjaiganesh99@gmail.com	https://lh5.googleusercontent.com/-8rYG9koSaG4/AAAAAAAAAAI/AAAAAAAAF0w/DKpDfWpigWs/s96-c/photo.jpg	118240680244675482931	\N	\N
5341	Meenal Sanjay Kamalakar ce17b046	ce17b046@smail.iitm.ac.in	https://lh3.googleusercontent.com/-cw8LLKKZd7g/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcsRFPz7DtSUmqhOFgMJvcP8qeK4A/s96-c/photo.jpg	113973502411437413660	\N	\N
5394	RITHIC KUMAR N RITHIC KUMAR N	coe18b044@iiitdm.ac.in	https://lh4.googleusercontent.com/-J5iqXuINTd4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOu8OVy173oph0TMipOUJRNs3eg8Q/s96-c/photo.jpg	112154048075183298220	\N	\N
5387	prashant jay	prashantjayoficial@gmail.com	https://lh4.googleusercontent.com/-NSLYIAB_190/AAAAAAAAAAI/AAAAAAAAABI/sq_uSIvbcfg/s96-c/photo.jpg	117437871277613629999	\N	\N
5378	Nathaniel Nirmal	nathanielat@gmail.com	https://lh3.googleusercontent.com/-ymDP-1KmfbM/AAAAAAAAAAI/AAAAAAAABwM/xoJ4DpMgtpo/s96-c/photo.jpg	100323225494928384224	\N	\N
5478	Niharika Srivastav	niharikas869@gmail.com	https://lh6.googleusercontent.com/-L2CkcrmW74s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNHuH4m-MNpOPpc5x7U1Ssnb9r6ww/s96-c/photo.jpg	115382621843699309946	\N	\N
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
5674	aayush atalkar	aayushatalkar@gmail.com	https://lh4.googleusercontent.com/-PAtzLCWQ1aI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfN2iFvmOVDqy7nSbL0GjI_ktcXhQ/s96-c/photo.jpg	114121932947581881721	\N	\N
5898	Aditya Raj	adityarazz129@gmail.com	https://lh5.googleusercontent.com/-bS18EqXJilk/AAAAAAAAAAI/AAAAAAAAAXA/_m4aj4GC07E/s96-c/photo.jpg	111140359246612411654	\N	\N
5958	dhanush ja	dhanushja3@gmail.com	https://lh3.googleusercontent.com/-gxrcmoE4OVw/AAAAAAAAAAI/AAAAAAAAAQ0/duwJwyC6Bjc/s96-c/photo.jpg	109289325891115045173	\N	\N
5911	Avula Yashwanth Reddy me18b006	me18b006@smail.iitm.ac.in	https://lh3.googleusercontent.com/-dd-5uZG8C4E/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMS6AeHXWHrgAYL1fewh2i_cAhjIQ/s96-c/photo.jpg	106540878792009138011	\N	\N
5328	Srishti Adhikary ae18b012	ae18b012@smail.iitm.ac.in	https://lh6.googleusercontent.com/-AdPd59me20w/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcsbaww5oqiyDedSuN2AAsSQoT7qA/s96-c/photo.jpg	116111249617413389973	\N	\N
5659	RAM KIRAN	ramkiran432@gmail.com	https://lh6.googleusercontent.com/-8nSWboxOhaM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reFIcAk2H3JQe3SA1QEYT97sWKq2Q/s96-c/photo.jpg	111128207069265376383	\N	\N
6164	Raman Kumar	ramankumarrks3720@gmail.com	https://lh4.googleusercontent.com/-d6ePxjH95os/AAAAAAAAAAI/AAAAAAAAARo/HcOLidb0d14/s96-c/photo.jpg	100373514490827653919	\N	\N
6118	NeEl ChAnGaNi	neel1499@gmail.com	https://lh6.googleusercontent.com/-Gy7QBpvzxh4/AAAAAAAAAAI/AAAAAAAAABs/dtetrteU8eY/s96-c/photo.jpg	114360394443508391157	\N	\N
6090	Varun Choudhary	varunrolaniya.vc@gmail.com	https://lh6.googleusercontent.com/-e4lfeESvOFw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNrTHqy0Oy9i0svsBbj_7UVvC514A/s96-c/photo.jpg	110606774466678924370	\N	\N
6213	Rohit Mahendran	rohitmahendran@gmail.com	https://lh5.googleusercontent.com/-vGPeoOFuQoo/AAAAAAAAAAI/AAAAAAAAAPo/hqxeLPhzWmg/s96-c/photo.jpg	108773897194648952785	\N	\N
6147	Sunanda Somwase	sunandasomwase@gmail.com	https://lh4.googleusercontent.com/-nDRIiVkPZ88/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reecCqn37LKZwx48xSzlrK1HRw0Zg/s96-c/photo.jpg	102269853381680672389	\N	\N
6222	Dhawal Samel	dhawalsamel99@gmail.com	https://lh3.googleusercontent.com/-6tWTsrPqtE4/AAAAAAAAAAI/AAAAAAAAAVM/K-UL86kvC0w/s96-c/photo.jpg	100870213224601082705	\N	\N
6231	shreyas shandilya	shandilya.shreyas@gmail.com	https://lh5.googleusercontent.com/-O-c993EAvuk/AAAAAAAAAAI/AAAAAAAAK8I/-q41nQXlsXg/s96-c/photo.jpg	114840229803252179382	\N	\N
5954	Devraj Babeli	me15b100@smail.iitm.ac.in	https://lh3.googleusercontent.com/-XPedVL3wdQM/AAAAAAAAAAI/AAAAAAAAAd0/gqSBy9g0pSU/s96-c/photo.jpg	107413706842790560056	\N	\N
6472	Ameya Ainchwar	ameya.potter7@gmail.com	https://lh6.googleusercontent.com/-UleH8WwJ_FI/AAAAAAAAAAI/AAAAAAAAPjs/La-VSOjF_l4/s96-c/photo.jpg	101633193710942170825	\N	\N
8318	Srihari K.S	kssrihari2000@gmail.com	https://lh3.googleusercontent.com/-LRbMeiuiYQs/AAAAAAAAAAI/AAAAAAAAYqU/2sZt1sqdRYw/s96-c/photo.jpg	101719078540936693965	\N	\N
6057	kandra pavan	kandrapavan@gmail.com	https://lh5.googleusercontent.com/-KbpmNa6iyVE/AAAAAAAAAAI/AAAAAAAAAsE/KQxfLd52zzw/s96-c/photo.jpg	107301028745384927900	\N	\N
6234	Uppalapati Nithin Chowdary ee18b035	ee18b035@smail.iitm.ac.in	https://lh5.googleusercontent.com/-usXS_ub7LAI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf-_XhmyrwPtkFAxYd9O_H5izyilQ/s96-c/photo.jpg	108848347453031165545	\N	\N
6241	Hunch D	rkarjun02052001@gmail.com	https://lh6.googleusercontent.com/-QuRR6JKVHlo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdBYVajPz0cwR7JVhnUbIhoovZWIQ/s96-c/photo.jpg	114704333810864603254	\N	\N
6281	K Vamshi Krishna me18m039	me18m039@smail.iitm.ac.in	https://lh4.googleusercontent.com/-9YbdNsTCJ60/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNlAh4MVg3HtdOHupA2M80YtkIo6Q/s96-c/photo.jpg	112872968935980064890	\N	\N
6258	SIDDHARTH J P na16b118	na16b118@smail.iitm.ac.in	https://lh3.googleusercontent.com/-DouPxSl6YaQ/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPqmecnxwZVnNs9SlY58IZWJ4AvPg/s96-c/photo.jpg	108536031230585647935	\N	\N
6512	Kunuku Naga Sai ch18b053	ch18b053@smail.iitm.ac.in	https://lh4.googleusercontent.com/-2h7VWoPyDR0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOhXKurs3v3Bsdz_WrdC8gEXTGldg/s96-c/photo.jpg	112870414950478249881	\N	\N
6444	Viswanath Tadi cs18b047	cs18b047@smail.iitm.ac.in	https://lh5.googleusercontent.com/-DMfm2MkCfho/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcY1vmtBzMCbjCmfLTQOY51kB9Tbg/s96-c/photo.jpg	110408636199196777944	\N	\N
6519	Aditya Parag Rindani me18b037	me18b037@smail.iitm.ac.in	https://lh3.googleusercontent.com/-zO-AbVfG4cE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfUJDsHFlrNzXlwXDK6tzxukmy5bQ/s96-c/photo.jpg	108210163016263470552	\N	\N
6666	Chamakura Suraj Reddy bs18b015	bs18b015@smail.iitm.ac.in	https://lh4.googleusercontent.com/-c1x2jyRfMNk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNasrqNFuMW6FCh_iB4Xco1bmLgQw/s96-c/photo.jpg	115339962081142646939	\N	\N
6943	Dhruvjyoti Bagadthey ee17b156	ee17b156@smail.iitm.ac.in	https://lh4.googleusercontent.com/-jHuUleOlxiM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd9LWSE6jSykxc41lfHXg0I6RyY2Q/s96-c/photo.jpg	114093894912804568558	\N	\N
6370	Shashwath Sargovi Bacha	shashwathsb1998@gmail.com	https://lh3.googleusercontent.com/-_xVPHJdztUM/AAAAAAAAAAI/AAAAAAAAAFQ/_V310an66qc/s96-c/photo.jpg	100006462132328751764	\N	\N
5241	Rishabh shah	shahrishabh14@gmail.com	https://lh4.googleusercontent.com/-J6r_OnRj4nQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rejDPzUXBHoFx8H4kSps3woyACC_w/s96-c/photo.jpg	106447284908872676152	\N	\N
6365	Bharat Jam	bharatwrrr@gmail.com	https://lh4.googleusercontent.com/-6CU1RytlxV8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO1DHzfN0fYq1mxYZuGjqLZLA_6ow/s96-c/photo.jpg	100629454340115098641	\N	\N
6814	Sidhartha Narayan	sidharthanarayan.s@gmail.com	https://lh4.googleusercontent.com/-so5mziAyzcU/AAAAAAAAAAI/AAAAAAAAZOc/O8KHs-mVe9M/s96-c/photo.jpg	110757805238250702422	\N	\N
6618	mokshagna saiteja	mokshagnasaiteja517@gmail.com	https://lh5.googleusercontent.com/-sxETCjv_rc0/AAAAAAAAAAI/AAAAAAAAABs/UFB94FA5u9Q/s96-c/photo.jpg	103923783699459229771	\N	\N
6441	Mitte Siddartha Sai cs18b028	cs18b028@smail.iitm.ac.in	https://lh3.googleusercontent.com/-gAuG_6Cn1Rc/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rej1XxD6GXemNqI_LHp0OfVqsbRAg/s96-c/photo.jpg	105001332348729167995	\N	\N
6801	S Sidhartha Narayan ep18b030	ep18b030@smail.iitm.ac.in	https://lh3.googleusercontent.com/-HsNOVDVgwvk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdF5JqiIsPW_GmFruDskzUtanmwQw/s96-c/photo.jpg	112857156281300752937	\N	\N
6306	Sikhakollu Venkata Pavan Sumanth ee18b064	ee18b064@smail.iitm.ac.in	https://lh4.googleusercontent.com/-dVwuWsgAZWg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdOs0kZjJoBcA6Uf6zPOGmfdsn1Cw/s96-c/photo.jpg	105534379261061050947	\N	\N
6489	Adriza Mishra bs18b013	bs18b013@smail.iitm.ac.in	https://lh4.googleusercontent.com/-B19uHcTDDc4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMrNxRFt35HF0SFTVFW85bTEmCqRA/s96-c/photo.jpg	116428881593753626712	\N	\N
6704	Guna Sekhar	gunasekharggs14@gmail.com	https://lh6.googleusercontent.com/-pBeI-V22RMU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdVVquFhvfrnVj8fJZViN9n96OvOw/s96-c/photo.jpg	117479216273329852537	\N	\N
6683	POULOMI KHA bs16b026	bs16b026@smail.iitm.ac.in	https://lh3.googleusercontent.com/-YeAmKTVM9Rw/AAAAAAAAAAI/AAAAAAAAA30/vd-JmgyTj-I/s96-c/photo.jpg	104863773335365538808	\N	\N
6532	Mamata L V	mamatalvaddodagi@gmail.com	https://lh4.googleusercontent.com/-XWvrug97U6A/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdX-t4mhmXX61HXYi_k6jtrSdyrMg/s96-c/photo.jpg	109157931691641267125	\N	\N
6399	Yuvraj Singh	yuvraj7345@gmail.com	https://lh3.googleusercontent.com/-bz-E2Ngeooc/AAAAAAAAAAI/AAAAAAAAAAU/mi8roXort4Q/s96-c/photo.jpg	101491417144470081112	\N	\N
6896	anshul suryan	anshulsuryan97@gmail.com	https://lh3.googleusercontent.com/-Xq4roz07ZWg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfQaAChmDeptn2FSs2lOE6YKT2nXg/s96-c/photo.jpg	117968929471255721604	\N	\N
7024	SALURU DURGA SANDEEP me16b125	me16b125@smail.iitm.ac.in	https://lh3.googleusercontent.com/-mB1r98QB9IE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNmSbmviWV6oaBkBz6s7s1imyrpUA/s96-c/photo.jpg	106053419849481655127	\N	\N
6857	SHUBHAM MAURYA	subhamrawjnv@gmail.com	https://lh6.googleusercontent.com/-6k5Fi9dULQs/AAAAAAAAAAI/AAAAAAAAAKo/QX7r2Oqt8js/s96-c/photo.jpg	112472980945916590575	\N	\N
6649	Mansi Choudhary ee17b053	ee17b053@smail.iitm.ac.in	https://lh5.googleusercontent.com/-s3N_q5PaKeU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reVwpDnvWrp9OraMT13GqhBf56ZoQ/s96-c/photo.jpg	115248078929890303214	\N	\N
6453	Shubham Jain	shubham.sj2310@gmail.com	https://lh3.googleusercontent.com/-Z5VTOMhMqYQ/AAAAAAAAAAI/AAAAAAAALGE/-9cAtTbNomk/s96-c/photo.jpg	101398156657528003471	\N	\N
6547	Vishnu Kiran	nv.vishnukiran00@gmail.com	https://lh5.googleusercontent.com/-Kf5jJ4450rw/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcbVjsN6konNarg5Xlh-E_rvLLsvQ/s96-c/photo.jpg	113681390068745417997	\N	\N
6554	Varad Joshi me17b038	me17b038@smail.iitm.ac.in	https://lh3.googleusercontent.com/-H_qvYxefJPQ/AAAAAAAAAAI/AAAAAAAAAmI/hUieBJ5GaIw/s96-c/photo.jpg	117966690353831815134	\N	\N
6907	Rudram Piplad	ed16b024@smail.iitm.ac.in	https://lh5.googleusercontent.com/-JsSkNLQv5b0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNJgq-FiEjRZFmBSVzvbxQv2m_DuA/s96-c/photo.jpg	113712306728446985892	\N	\N
6940	Gude Sai Ganesh me17b012	me17b012@smail.iitm.ac.in	https://lh4.googleusercontent.com/-6yRWmv1xvNc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMbcCJSY4d8B0FacwNwEeNEnmvZAw/s96-c/photo.jpg	113538741896053160350	\N	\N
6944	korrayi jagadeesh	korrayijagadeesh21@gmail.com	https://lh6.googleusercontent.com/-_mrZqzQd4mo/AAAAAAAAAAI/AAAAAAAAABA/998ggPcctuU/s96-c/photo.jpg	107456246453619734809	\N	\N
6927	Buddhavarapu Venkata Surya Sudheendra cs18b006	cs18b006@smail.iitm.ac.in	https://lh3.googleusercontent.com/-3ngH0fhM4d8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfgPvEe-ACorJU_02b412eXArYDZg/s96-c/photo.jpg	101180110198873131231	\N	\N
6377	Vasavi Gandham	vasavi.g71@gmail.com	https://lh4.googleusercontent.com/-xAPDnwsSUnU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re9oBS-q2Bihfmj9pDOuJtmEHp-ag/s96-c/photo.jpg	107726028519801979477	\N	\N
6695	Akilesh Kannan	akileshkannan@gmail.com	https://lh5.googleusercontent.com/-Xx9oQvzko-0/AAAAAAAAAAI/AAAAAAAABA0/jAh2eA2LZUU/s96-c/photo.jpg	107177554755735141269	\N	\N
6979	Kashish Kumar ce17m079	ce17m079@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ktOrBJNZQvk/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPfFUEWysnZrzf_iurJXacXoW7qGQ/s96-c/photo.jpg	108551370712006348201	\N	\N
7029	Krishna Gopal Sharma cs18b021	cs18b021@smail.iitm.ac.in	https://lh3.googleusercontent.com/-oidk_duqK0s/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQM9aJgrIeEq_kCB4TFCD8YQIYHL9w/s96-c/photo.jpg	114582343462323173676	\N	\N
7036	Sai Bharadwaj Avvari	saibharadwajavvari9@gmail.com	https://lh6.googleusercontent.com/-4dF13U_ujpA/AAAAAAAAAAI/AAAAAAAAAMc/P7UrFwIbjFU/s96-c/photo.jpg	116528854078263730275	\N	\N
6924	Utkarsh Mishra	utkarshm065@gmail.com	https://lh3.googleusercontent.com/-s4ssEPvnRDs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3revqoUaQ5k4ymlR3Qn2tBblTsfsxw/s96-c/photo.jpg	113529269457401139010	\N	\N
7065	PEDAPUDI JASHWANTH SATYA SRINIVAS ee15b049	ee15b049@smail.iitm.ac.in	https://lh3.googleusercontent.com/-acrqHVbLY8g/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfXJD6L6AWVdZNsmMhLyNwbMaPi4Q/s96-c/photo.jpg	102663222527337708902	\N	\N
5622	Bandela Gagan Sreevastav Reddy ee17b042	ee17b042@smail.iitm.ac.in	https://lh4.googleusercontent.com/-959eKkwt2NM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reyt3P-MMpIiPuoo3tjJURkOXlazw/s96-c/photo.jpg	107489933466838356493	\N	\N
7418	Bala Sundar	balasundar333@gmail.com	https://lh4.googleusercontent.com/-UQ9tUxZCGL8/AAAAAAAAAAI/AAAAAAAAAP8/P1FRzWK-gY4/s96-c/photo.jpg	114885547058071668870	\N	\N
7380	Basu Jindal	bjbasujindal@gmail.com	https://lh6.googleusercontent.com/-zfvcbsOx6T0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdULr2Gdo_O_zuoNhdng_m2obAHtQ/s96-c/photo.jpg	115215758125593906638	\N	\N
7381	DEDDY JOBSON ee15b125	ee15b125@smail.iitm.ac.in	https://lh6.googleusercontent.com/-7Qx4HCSpCAI/AAAAAAAAAAI/AAAAAAAAAHo/natt2vX9a1U/s96-c/photo.jpg	106538374742209182977	\N	\N
7392	Ravi Gupta	ravi.gupta2323@gmail.com	https://lh6.googleusercontent.com/-6Hxoca7nEno/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMkfeXYpDiZBMNN82r2ByV4sxlWIQ/s96-c/photo.jpg	114574453579413335824	\N	\N
7393	Neha Swaminathan be18b008	be18b008@smail.iitm.ac.in	https://lh3.googleusercontent.com/-PqKloPMPwVI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reJ26RZDrW9SaZapWYhiciteawRsg/s96-c/photo.jpg	109557453092405104728	\N	\N
7284	Ranjith Ramamurthy Tevnan ee18b146	ee18b146@smail.iitm.ac.in	https://lh4.googleusercontent.com/-7ZO6Q0Ip8ko/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPC_8D4D_FYGf3JaUroHKfkXZRKsg/s96-c/photo.jpg	106891091144539984258	\N	\N
7143	Ramanan S ee18b145	ee18b145@smail.iitm.ac.in	https://lh6.googleusercontent.com/-SE_9T4cTlwU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf8Tw6QhdxpcDGflq8pCQY5nV0kmg/s96-c/photo.jpg	113597979260889639153	\N	\N
7212	KUMUD MITTAL ed16b043	ed16b043@smail.iitm.ac.in	https://lh6.googleusercontent.com/-Al2Yk_O-s0U/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQO5Q3cl4yCLNKOTsT3Rvxq95-2P6A/s96-c/photo.jpg	114748309222522139021	\N	\N
7394	Indraneel Chavhan	indraneelchavhan@gmail.com	https://lh3.googleusercontent.com/-We92GF5Q74w/AAAAAAAAAAI/AAAAAAAAAFE/Nj5xcGLfojs/s96-c/photo.jpg	102187519138824292606	\N	\N
7190	KORRAPATI HANUMATH PRANAV BHARADWAJ ee16b112	ee16b112@smail.iitm.ac.in	https://lh3.googleusercontent.com/-O6Cy_eqXAO0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOZVS9R3JjMh6oZmDYzkaJG4sbnQA/s96-c/photo.jpg	116481244449985283889	\N	\N
7059	Krishna Tejaswi	krishnatejaswi99@gmail.com	https://lh4.googleusercontent.com/-rkMflFZKiMc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNZluJCgdjWUuLxNSetxKyhQnOk3g/s96-c/photo.jpg	107198149074547760918	\N	\N
7423	Sanjeed I	msanjeed5@gmail.com	https://lh6.googleusercontent.com/-GeU8go3JMM0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOjqylnoYLi5-lM8_kOZDVXJFlLsw/s96-c/photo.jpg	103398500054194363991	\N	\N
7326	Kaivalya Rakesh Chitre me17b018	me17b018@smail.iitm.ac.in	https://lh5.googleusercontent.com/-HMymrdbPt6k/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reOavk5r7A4tzKK_cOi9gvcQTwmKw/s96-c/photo.jpg	109121374241590014827	\N	\N
7147	ANURAG HARSH	anuragharsh113@gmail.com	https://lh4.googleusercontent.com/--1ov1G4BYbM/AAAAAAAAAAI/AAAAAAAAAxw/nOs9KlOBWMs/s96-c/photo.jpg	117764114579954744999	\N	\N
7329	Sarath B	sbsrth@gmail.com	https://lh5.googleusercontent.com/-kLLfbh_ONrM/AAAAAAAAAAI/AAAAAAAAALo/5KkV-AbgMJw/s96-c/photo.jpg	117692580625665353891	\N	\N
7125	Avasarala Krishna Koustubha me18b126	me18b126@smail.iitm.ac.in	https://lh3.googleusercontent.com/-HdCs4z3TVr4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZR1u6YDvLGzRYoXDVNxyqE1Rq4Q/s96-c/photo.jpg	100444374512123718431	\N	\N
7050	Nitesh Padidam	niteshpadidam@gmail.com	https://lh5.googleusercontent.com/-MAdvxId8Ewc/AAAAAAAAAAI/AAAAAAAAAAk/7raQQuE3jQI/s96-c/photo.jpg	103273107959465057265	\N	\N
7269	sameer kumar	sameere997@gmail.com	https://lh5.googleusercontent.com/-R_3csDSKFtI/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQP7PHxnbdDAMbkSvgAQmfxPWQu-pg/s96-c/photo.jpg	114369799590663114921	\N	\N
7280	M LAKSHNA ed16b044	ed16b044@smail.iitm.ac.in	https://lh4.googleusercontent.com/-mh5J9bUOdKg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc0nGgSC1WCvHRK2HumFR1BPMGjYA/s96-c/photo.jpg	101307535630091801474	\N	\N
7451	Mohammed Sanjeed ed17b047	ed17b047@smail.iitm.ac.in	https://lh4.googleusercontent.com/-0sb1zcB8oHc/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMaHUDgZevEYx31rripkuWBD_OSnA/s96-c/photo.jpg	114326744260308541754	\N	\N
7399	Basu Jindal me18b008	me18b008@smail.iitm.ac.in	https://lh3.googleusercontent.com/-og-fhCxe3Ls/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc9UW_AN1EMfVPO_6KKZ_lNqFPdlw/s96-c/photo.jpg	111640459531281754733	\N	\N
7609	Skanda Swaroop	swaroopskanda98@gmail.com	https://lh3.googleusercontent.com/-PlpvuNNnuX0/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re90AtRKlaRmyNBlKHI7CuHl855bA/s96-c/photo.jpg	114591124276679160265	\N	\N
7335	Anooj Gandham	anoojchill@gmail.com	https://lh6.googleusercontent.com/-0dkBZQMFuYM/AAAAAAAAAAI/AAAAAAAAA88/LF85C58Zbzg/s96-c/photo.jpg	105187746276593629594	\N	\N
7480	Shubham Kanekar	kanekarsk@gmail.com	https://lh3.googleusercontent.com/-0LpaPsYZ-PI/AAAAAAAAAAI/AAAAAAAABZg/5Yg8TEu49AQ/s96-c/photo.jpg	117310687405189973052	\N	\N
7561	SAYE SHARAN me16b177	me16b177@smail.iitm.ac.in	https://lh5.googleusercontent.com/-nYFpmev0Fxs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reh3BoXm-oiQ9SiHxRcyr41dwKFJQ/s96-c/photo.jpg	114591386611984022174	\N	\N
7493	Faraz Farooqui	farazfarooqui08@gmail.com	https://lh5.googleusercontent.com/-wM26vIRq5Sw/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQODy_u8hooQwFcMakf4ipFJBQoSSg/s96-c/photo.jpg	104425878332120909243	\N	\N
7516	YOGAEESHWAR SURIYANARAYANAN	yogaganapathy.suri@gmail.com	https://lh6.googleusercontent.com/-W3uZxmW7c24/AAAAAAAAAAI/AAAAAAAAAE0/8H70esPHzJs/s96-c/photo.jpg	109098813558670849559	\N	\N
6686	Jonathan Ve Vance ed17b014	ed17b014@smail.iitm.ac.in	https://lh3.googleusercontent.com/-NPsYUXAHceA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf_Kz5g1zMSRFZQMuny9JiEUVzsKw/s96-c/photo.jpg	101927668361428071197	\N	\N
7440	DEVANSH SINGH	devanshsingh110@gmail.com	https://lh6.googleusercontent.com/-U5QsPqVYjYs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rePkVpm1Ifqm1XBCE7xYyByQ0LNiA/s96-c/photo.jpg	111567725646650165125	\N	\N
7588	Jebby Arulson ae17b028	ae17b028@smail.iitm.ac.in	https://lh6.googleusercontent.com/-L-W9GD42pbU/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdYgE4NRKcaqxiZgLBK6t0WDijg_w/s96-c/photo.jpg	116837958596212598480	\N	\N
7642	nithish satya sai	nithishlonglast999@gmail.com	https://lh3.googleusercontent.com/-jc4w88zllWg/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rf3Yi2S2cnSuL7dxPRQ7UhEh0hqFg/s96-c/photo.jpg	105433782240224469335	\N	\N
7643	Yash Goyal ed17b057	ed17b057@smail.iitm.ac.in	https://lh4.googleusercontent.com/-oTFf4qJlayk/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3regObtI-K3CUqWnfSKCk2oucK0ndg/s96-c/photo.jpg	109614878105074181482	\N	\N
7866	Sirusala Niranth Sai 4-Yr B.Tech. Electronics Engg., IIT(BHU), Varanasi	sirusalansai.ece18@itbhu.ac.in	https://lh3.googleusercontent.com/-0yRav1sEYko/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcNwoJn2HvGkvilQjIy-yjv1BhJNA/s96-c/photo.jpg	100341530229780615772	\N	\N
8003	me17b141@smail.iitm.ac.in	me17b141@smail.iitm.ac.in	https://lh3.googleusercontent.com/--AV2_-gVVN8/AAAAAAAAAAI/AAAAAAAAAAA/N2OrThJ44H4/s96-c/photo.jpg	105620503580613926309	\N	\N
7852	Unman Uday Nibandhe me18b035	me18b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-fFwjeNNH2ys/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdcq2PzLFkTBgmzPCdXUexfcMV7UA/s96-c/photo.jpg	107393448684071128659	\N	\N
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
8056	Rajas Milind Neve me17b062	me17b062@smail.iitm.ac.in	https://lh5.googleusercontent.com/-ktatzZu8lA4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcJxzTRPxVWlrXvEfqTgSAjPeWWcg/s96-c/photo.jpg	115420891548775866632	\N	\N
7915	AbhI ShAh	abhishah4001@gmail.com	https://lh6.googleusercontent.com/-vf5DaTWZJ30/AAAAAAAAAAI/AAAAAAAANbs/LmpkCztFSsE/s96-c/photo.jpg	109441309750837717539	\N	\N
8190	Vaid Denish	vaiddenish11@gmail.com	https://lh6.googleusercontent.com/-ruFTICaH5N8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOUExWC1PRoVBCSMNv3ffHMQaAdnQ/s96-c/photo.jpg	108947651890682672904	\N	\N
8049	Karthik Bachu me17b053	me17b053@smail.iitm.ac.in	https://lh4.googleusercontent.com/-5ajiEhWpvJQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rehAXOIAflI-XolvabGtdr-VOhxTw/s96-c/photo.jpg	112203812328864098110	\N	\N
8063	ROHIT JEJANI ae15b035	ae15b035@smail.iitm.ac.in	https://lh6.googleusercontent.com/-3lFxJtqBbrE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reZipgHFmQzy8WGfuNgm2uH-3FwLA/s96-c/photo.jpg	106335102413062346097	\N	\N
8106	Nishant Patil	nishant.jnv@gmail.com	https://lh5.googleusercontent.com/-IA0WnDKdFR4/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQOKN2VtXZ9UZ2W_TnKcfgUtCb2h6w/s96-c/photo.jpg	100427482293316682936	\N	\N
8260	Sidharth Areeparambath	sidhartharamana@gmail.com	https://lh3.googleusercontent.com/-8Sl6agNpC6s/AAAAAAAAAAI/AAAAAAAABUc/lrHzg_2z2II/s96-c/photo.jpg	111983544338321266182	\N	\N
7942	Souridas A	souridas510@gmail.com	https://lh3.googleusercontent.com/-JlB331yuU5E/AAAAAAAAAAI/AAAAAAAAACU/F6qoSu3NBD8/s96-c/photo.jpg	106596281639246034885	\N	\N
7112	S Viknesh ee17b073	ee17b073@smail.iitm.ac.in	https://lh6.googleusercontent.com/-afIiwMSPDZQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZ6e5NfEX_I3yktqcu-yMKLF-nFg/s96-c/photo.jpg	111066027705891320913	\N	\N
8121	Sourav Hemachandran	souravhemachandhran@gmail.com	https://lh4.googleusercontent.com/-v45s8W0QLwo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMQL6mh3hLVUlMGvcfVDv0Xj1-wIw/s96-c/photo.jpg	117368038713753317104	\N	\N
8234	Aditya Balachander ee18b101	ee18b101@smail.iitm.ac.in	https://lh4.googleusercontent.com/--KrZaB5IKS8/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNYFRTT0bCqlUHyab-suMXeUhHPSg/s96-c/photo.jpg	116189371214953919032	\N	\N
8201	Denish Dhanji Vaid ee17b159	ee17b159@smail.iitm.ac.in	https://lh3.googleusercontent.com/-1fyQqfKNPR8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdLLsyP-SuHXwaGfg4pXLld5Roh9Q/s96-c/photo.jpg	100967102642433990682	\N	\N
8223	avasarala koustubha	ak.koustu@gmail.com	https://lh5.googleusercontent.com/-yJ0duaPAojQ/AAAAAAAAAAI/AAAAAAAAEs4/2fY5J8mPcbc/s96-c/photo.jpg	104063535906637928892	\N	\N
8249	Turkesh pote	turkeshpote@gmail.com	https://lh6.googleusercontent.com/-I9yD13rzt38/AAAAAAAAAAI/AAAAAAAABDY/5r-RWQ_Aw_U/s96-c/photo.jpg	108345004535686987028	\N	\N
8224	Bondala Sushwath ed17b036	ed17b036@smail.iitm.ac.in	https://lh3.googleusercontent.com/-oX3JBfX87yE/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNAWMfGnxlihk-HeaXRYjImoX5XLA/s96-c/photo.jpg	102330392737983603678	\N	\N
8299	Vikas Singh	singhvikas086@gmail.com	https://lh6.googleusercontent.com/-8xe5iE_R7fQ/AAAAAAAAAAI/AAAAAAAAAOQ/Bi2YIRMFJnc/s96-c/photo.jpg	100317160726643486440	\N	\N
8124	Mohil Chaudhari	mohilchau@gmail.com	https://lh5.googleusercontent.com/-u0RDuDIcDhg/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNvWj0CsN6aku6CcrWxsIcFX0h8qQ/s96-c/photo.jpg	104564285080152210085	\N	\N
4859	Aditya Rindani	aditya0070.ar@gmail.com	https://lh6.googleusercontent.com/-o8s0hrFYnls/AAAAAAAAAAI/AAAAAAAAD-8/omW82l_PGsM/s96-c/photo.jpg	106151943570612705662	\N	\N
8344	Guntupalli Sai Vinay ce17b019	ce17b019@smail.iitm.ac.in	https://lh4.googleusercontent.com/-Se9Tqka4hTA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPGcbNgfM8EmOA2Vxa5NfYF1-U1QQ/s96-c/photo.jpg	113236801941654391084	\N	\N
8359	Shahan Mohammadi	shahanmohammadi@gmail.com	https://lh5.googleusercontent.com/-wASUxoal3Wo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3refr2_QPPun4eGQeh4M8gkNH4wUuA/s96-c/photo.jpg	116369894268542139381	\N	\N
8396	ABHISHEK SINGH	abskbdl@gmail.com	https://lh3.googleusercontent.com/-24I0ev7NNJY/AAAAAAAAAAI/AAAAAAAAAew/BoKlVquHNyA/s96-c/photo.jpg	114218010316466093767	\N	\N
7334	E Sameer Kumar me17b048	me17b048@smail.iitm.ac.in	https://lh5.googleusercontent.com/-uGFDGwEGQgs/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdEGfGqcLK2ut8FGmfZEQWkvh-BVw/s96-c/photo.jpg	115801243251886489865	\N	\N
8423	Sambit Tarai	sambitarai17@gmail.com	https://lh4.googleusercontent.com/-5D-HRoarg3E/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNkgIKv1myEiFSpWQfSS4L4Gcbvjw/s96-c/photo.jpg	104003420105956436392	\N	\N
8830	BOBBA TEJASWARA REDDY ae16b104	ae16b104@smail.iitm.ac.in	https://lh3.googleusercontent.com/-U0MQGk3rznY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdNU36DRZOrszNqxpVsx6GouGJI_A/s96-c/photo.jpg	109432364385136243098	\N	\N
8967	abhishek bakolia	abhishekbakolia22@gmail.com	https://lh5.googleusercontent.com/-VerhyeVZvaE/AAAAAAAAAAI/AAAAAAAAAAo/FkFwJOOqQMQ/s96-c/photo.jpg	110283615455900532725	\N	\N
8718	venkatesh kataraki	venkataraki@gmail.com	https://lh6.googleusercontent.com/-rBDawQwfFyM/AAAAAAAAAAI/AAAAAAAAAB8/xv2PalE1KYk/s96-c/photo.jpg	109583020944427160732	\N	\N
8795	dhanveer raj	dhanveer1512raj@gmail.com	https://lh6.googleusercontent.com/-nBpG8alNIrY/AAAAAAAAAAI/AAAAAAAAAR4/INrH13lUYOQ/s96-c/photo.jpg	102006920462605638334	\N	\N
8535	Lohitha Chowdary	lohithaalaparthi@gmail.com	https://lh5.googleusercontent.com/-rKXS1Ao7YUs/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNQycoVOke1FSH_I7eSo2-zoCrYQw/s96-c/photo.jpg	101171591693354500761	\N	\N
9116	Shriram Elangovan	shri99elango@gmail.com	https://lh6.googleusercontent.com/-uRr-rIx3OO0/AAAAAAAAAAI/AAAAAAAANBQ/eToO1-w3UHs/s96-c/photo.jpg	111335512155779191240	\N	\N
8582	Ahad Modak	ahadmodak786@gmail.com	https://lh4.googleusercontent.com/-8mFKAab6fyQ/AAAAAAAAAAI/AAAAAAAANXU/-tdiBNEaeoE/s96-c/photo.jpg	106653443315295232533	\N	\N
8729	Chinmay Kulkarni	chindiksal@gmail.com	https://lh6.googleusercontent.com/-yZ-gpujkMFI/AAAAAAAAAAI/AAAAAAAAABE/udF1BYMvYFI/s96-c/photo.jpg	104547213757131706346	\N	\N
8770	Ravi Krishnan	ravikrishnan3@gmail.com	https://lh5.googleusercontent.com/-1wk4Y9KJhL0/AAAAAAAAAAI/AAAAAAAAAMk/AqAfELmA3wM/s96-c/photo.jpg	111873789583675808617	\N	\N
8337	MOHAMMED KHANDWAWALA ee16b117	ee16b117@smail.iitm.ac.in	https://lh3.googleusercontent.com/-7zf3vM31Gfo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3re0eDk07gw6EaKUr0Y5Xmb3QbOu6w/s96-c/photo.jpg	118244727025742575334	\N	\N
8591	Abhimanyu Swaroop mm17b008	mm17b008@smail.iitm.ac.in	https://lh4.googleusercontent.com/-0fMLMpwFbF4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfhT9iR6mHHvoOolev_bXFIBqKuhQ/s96-c/photo.jpg	103628381857359898368	\N	\N
9347	Sashaank Nimmagadda	sashank.n.1711@gmail.com	https://lh3.googleusercontent.com/-ONdlxFj9dRI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reYCjvAXt1a_dJE9kJmi2r5tP8Bmw/s96-c/photo.jpg	110018183307703015999	\N	\N
9131	SIDDHARTH KAPRE ch16b065	ch16b065@smail.iitm.ac.in	https://lh6.googleusercontent.com/-hfaP3Yeta5I/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdLJjqNfVDKcHzxFvK69OExxIwFIA/s96-c/photo.jpg	102719715304204500462	\N	\N
9059	Vallabi A hs18h042	hs18h042@smail.iitm.ac.in	https://lh3.googleusercontent.com/-yaM9-Jfumu4/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcIlDB15tD2bFaGsLNrqJEFdV0GCA/s96-c/photo.jpg	107870943386419228789	\N	\N
8371	Aman Basheer A	ed17b032@smail.iitm.ac.in	https://lh6.googleusercontent.com/-IulD6J4udTY/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcXa6rp-_eA36wl8vjv_ktGs0I1CA/s96-c/photo.jpg	111703803711058182719	\N	\N
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
9516	Sivasubramaniyan Sivanandan ee17b029	ee17b029@smail.iitm.ac.in	https://lh6.googleusercontent.com/-c3E65eD10JI/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfeCj7yAIxArZh2ixBrXdugO9vQtA/s96-c/photo.jpg	116759539753758122369	\N	\N
8651	R Aditya be18b029	be18b029@smail.iitm.ac.in	https://lh3.googleusercontent.com/-EIalQ3r2LR0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNM55YhBfQ28gxuY0J-HFHMEcjKHg/s96-c/photo.jpg	101682012856295676880	\N	\N
9464	nandhini swaminathan	nandhiniiswaminathan@gmail.com	https://lh4.googleusercontent.com/-XnfmXted7p8/AAAAAAAAAAI/AAAAAAAAD7s/GHuimlfeMdc/s96-c/photo.jpg	103308922454507465852	\N	\N
9537	Kalash Verma	kalashverma1212@gmail.com	https://lh5.googleusercontent.com/-xfAqwZ48Vi8/AAAAAAAAAAI/AAAAAAAAWME/ZT5yDBlYlzE/s96-c/photo.jpg	108382685221057954981	\N	\N
9705	Satyajit Sahu	satyajitsahu2000@gmail.com	https://lh6.googleusercontent.com/-1LK3eW3Yb4k/AAAAAAAAAAI/AAAAAAAAAEQ/RVBRpzap1Bc/s96-c/photo.jpg	116478683189057283291	\N	\N
9844	Bharath Srinivasan	anibmw.audi@gmail.com	https://lh5.googleusercontent.com/-MY3jLfOdD7k/AAAAAAAAAAI/AAAAAAAAAGI/42fCa4cJaJA/s96-c/photo.jpg	114352721177624111587	\N	\N
9675	sumanth sarva	sumanthsarvasms@gmail.com	https://lh4.googleusercontent.com/-3lnJxU_phLQ/AAAAAAAAAAI/AAAAAAAALMs/-j0bY6J7uJQ/s96-c/photo.jpg	102341274763983527312	\N	\N
9609	Nithin Babu	nithinchennai123@gmail.com	https://lh6.googleusercontent.com/-1taC-D4HjFU/AAAAAAAAAAI/AAAAAAAAALo/_QJcdNBcCoc/s96-c/photo.jpg	104294280397208849479	\N	\N
9570	SOURAV SAMANTA	souravsamanta541996@gmail.com	https://lh3.googleusercontent.com/-5dB4s7OITTU/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNoqNoYlDW0yFVaqj96TwliHhW4NQ/s96-c/photo.jpg	112654001619380731452	\N	\N
9548	naveen kumaar srinivasan	s.nav2enias@gmail.com	https://lh4.googleusercontent.com/-4qnibQABLq0/AAAAAAAAAAI/AAAAAAAADN4/_4D9UPhPQeo/s96-c/photo.jpg	113468750706613363716	\N	\N
9738	Niraj Kumar	nir8083@gmail.com	https://lh3.googleusercontent.com/-VgNCXDiE1kM/AAAAAAAAAAI/AAAAAAAAAWU/tJYEG53OWog/s96-c/photo.jpg	108496699258995503222	\N	\N
10034	karuna Karan	sathuvachari18@gmail.com	https://lh4.googleusercontent.com/-YaDeMlKlfgU/AAAAAAAAAAI/AAAAAAAAAFk/ytOvbbpf8UA/s96-c/photo.jpg	107225841050163511047	\N	\N
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
9805	ARAVAMUDHAN U	aravamudhan.u.2017.mech@rajalakshmi.edu.in	https://lh3.googleusercontent.com/-P4Fywvgh-gE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdZn7v_znu614JoxFN6pwJnmhyCVg/s96-c/photo.jpg	102195777194996285654	\N	\N
9806	chavali anirudh	chavaliani0123@gmail.com	https://lh6.googleusercontent.com/-qkPpEvsg7K0/AAAAAAAAAAI/AAAAAAAAlvA/WXhhZpPhZnk/s96-c/photo.jpg	106348211089456308863	\N	\N
10064	Shubham Danannavar	shubhamsd4@gmail.com	https://lh3.googleusercontent.com/-xww-KlhqlUA/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdEtpN6qT3nBpIGdoV4kBCP9GVjAQ/s96-c/photo.jpg	101988431255785683948	\N	\N
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
10478	SHUBHAM KUMAR	subhamkumar2510@gmail.com	https://lh6.googleusercontent.com/-o2dLioD5_iQ/AAAAAAAAAAI/AAAAAAAAAwA/uTVAFJ9PfWs/s96-c/photo.jpg	100903677923974025368	\N	\N
10360	lemon reddy	lemonreddy87@gmail.com	https://lh5.googleusercontent.com/-H5B0aKkN_SA/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQNmV4H4VeqrKo_Nl0wPCxklOXIBag/s96-c/photo.jpg	117857658398501576041	\N	\N
10363	Atharv Tiwari	atharv.tiwari02@gmail.com	https://lh6.googleusercontent.com/-WaN6h64fP2g/AAAAAAAAAAI/AAAAAAAAF54/z2PcarfM9uk/s96-c/photo.jpg	112188830982780019541	\N	\N
10399	Vignesh P	pvignesh3991@gmail.com	https://lh3.googleusercontent.com/-jIbf-dW11z0/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQMONeVuYE5OqEk2TwQwuV8diQEtRQ/s96-c/photo.jpg	115330146506587527272	\N	\N
10732	AAKASH KUMAR KATHA bs15b001	bs15b001@smail.iitm.ac.in	https://lh4.googleusercontent.com/-K8dMFhVQurk/AAAAAAAAAAI/AAAAAAAAESk/ZRozBilFGKs/s96-c/photo.jpg	111790252858780067280	\N	\N
10551	Om Shri Prasath	ee17b113@smail.iitm.ac.in	https://lh5.googleusercontent.com/-qfTPzqOVLVo/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rc8dkq6Px9now8eGahgiWJ8XIeP9A/s96-c/photo.jpg	108283492057740057468	\N	\N
10720	Suhas Morisetty	morisettysuhas@gmail.com	https://lh3.googleusercontent.com/-E1ik6oCFqU8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfa-LF-YsO1vY2icuMeUW-w0DxLug/s96-c/photo.jpg	105703282986440185552	\N	\N
10540	Shankar Thyagarajan	shankar15498@gmail.com	https://lh5.googleusercontent.com/-VtaOHAPrqsU/AAAAAAAAAAI/AAAAAAAABos/oR_45D_jcQA/s96-c/photo.jpg	108977537476281644524	\N	\N
9697	BOLISETTY N V S RAGHAVENDRA MAHESH me16b137	me16b137@smail.iitm.ac.in	https://lh3.googleusercontent.com/-SsO2kKIqids/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3reHaGa6EvKmFllHK3bFwd_GpJ4dKA/s96-c/photo.jpg	104662693858655380465	\N	\N
10675	S Vishal ch18b020	ch18b020@smail.iitm.ac.in	https://lh6.googleusercontent.com/-4sF3iUp5rYo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQPXuONgE9jpeQedfD8i9kNO-Ll2Ew/s96-c/photo.jpg	111054950123693497601	\N	\N
10626	Malyala Srikanth	malyala2srikanth@gmail.com	https://lh5.googleusercontent.com/-p4Qx39cVWFM/AAAAAAAAAAI/AAAAAAAACDo/JRLO2XkMzCc/s96-c/photo.jpg	117276624581419753619	\N	\N
10521	Saurav Jaiswal	sauravjaiswal999@gmail.com	https://lh3.googleusercontent.com/-NRYwSi-xg38/AAAAAAAAAAI/AAAAAAAAAGc/0ANlIy1bv2s/s96-c/photo.jpg	103131193577480666827	\N	\N
10556	John Smith	ramitajawahar2000@gmail.com	https://lh5.googleusercontent.com/-_TMHKS_BfEo/AAAAAAAAAAI/AAAAAAAAAAA/ACevoQN-xQvbw4e7CeGFFG0moPg35alW4A/s96-c/photo.jpg	105765378409248116613	\N	\N
10731	Morisetty Venkata Anoop Suhas Kumar ee17b109	ee17b109@smail.iitm.ac.in	https://lh5.googleusercontent.com/-snivsPIquOE/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rdlUbvX--gofXj91UtwkeKJejHlyg/s96-c/photo.jpg	116522826000331691456	\N	\N
10587	Gayathri Guggilla	gayathri.guggila@gmail.com	https://lh6.googleusercontent.com/-2NpN31FBEnQ/AAAAAAAAAAI/AAAAAAAAbWY/Qimsy0aAr48/s96-c/photo.jpg	116365908916402634741	\N	\N
\.


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);


--
-- Name: internship_apply_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.internship_apply_table_id_seq', 47, true);


--
-- Name: internship_bookmark_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.internship_bookmark_table_id_seq', 1, false);


--
-- Name: joey_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.joey_user_id_seq', 10900, true);


--
-- Name: startup_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_details_id_seq', 303, true);


--
-- Name: startup_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startup_post_id_seq', 148, true);


--
-- Name: student_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_details_id_seq', 263, true);


--
-- Name: user_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_detail_id_seq', 10858, true);


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

