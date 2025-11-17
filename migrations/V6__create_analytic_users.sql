CREATE ROLE analytic NOLOGIN;

GRANT CONNECT ON DATABASE books_data TO analytic;
GRANT USAGE ON SCHEMA public TO analytic;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytic;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analytic;

DO $$
    DECLARE
        analysts text[] := string_to_array('${ANALYST_NAMES}', ',');
        u text;
    BEGIN
        FOREACH u IN ARRAY analysts LOOP
                EXECUTE format('CREATE USER %I WITH PASSWORD %L', u, u || '_pass');
                EXECUTE format('GRANT analytic TO %I', u);
            END LOOP;
    END
$$ LANGUAGE plpgsql;