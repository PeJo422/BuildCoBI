-- =====================================================================
-- BuildCo BI — ladda rådata till PostgreSQL
--
-- Kör i psql från repots rot:
--   createdb buildco
--   psql -d buildco -f sql/00_setup_postgres.sql
--
-- \copy körs klientsidan och läser filerna relativt din arbetskatalog.
-- Står du inte i repots rot får du "No such file or directory".
-- =====================================================================

DROP TABLE IF EXISTS customers, dim_customer_scd2, employees,
                     projects, timesheets, project_costs, invoices;

-- Rålagret har medvetet inga foreign keys. Källdata är sällan så snäll,
-- och en laddning som stannar på en trasig rad hjälper ingen kl 05:00.

CREATE TABLE customers (
    customer_id   text PRIMARY KEY,
    customer_name text,
    org_number    text,
    contact_name  text,
    city          text,
    segment       text,
    created_date  date
);

CREATE TABLE dim_customer_scd2 (
    customer_sk   integer PRIMARY KEY,   -- surrogatnyckel: en version av kunden
    customer_id   text,                  -- business key: kunden i källsystemet
    customer_name text,
    contact_name  text,
    city          text,
    segment       text,
    valid_from    date,
    valid_to      date,                  -- null = versionen gäller fortfarande
    is_current    boolean
);

CREATE TABLE employees (
    employee_id      text PRIMARY KEY,
    first_name       text,
    last_name        text,
    role             text,
    department       text,
    hourly_cost      numeric(10,2),      -- vad timmen kostar BuildCo
    hourly_rate      numeric(10,2),      -- vad timmen faktureras för
    employment_start date,
    is_active        boolean
);

CREATE TABLE projects (
    project_id         text PRIMARY KEY,
    project_name       text,
    customer_id        text,
    project_manager_id text,
    city               text,
    project_type       text,
    start_date         date,
    end_date           date,             -- null = pågående
    budget_amount      numeric(14,2),
    status             text
);

CREATE TABLE timesheets (
    timesheet_id text PRIMARY KEY,
    project_id   text,
    employee_id  text,
    work_date    date,
    hours        numeric(6,2),
    activity     text,
    is_billable  boolean
);

CREATE TABLE project_costs (
    cost_id     text PRIMARY KEY,
    project_id  text,
    cost_date   date,
    cost_type   text,
    supplier    text,
    amount      numeric(14,2),
    voucher_no  text,                    -- verifikationsnummer från ekonomisystemet
    is_reversed boolean
);

CREATE TABLE invoices (
    invoice_id   text PRIMARY KEY,
    project_id   text,
    customer_id  text,
    invoice_date date,
    due_date     date,
    amount       numeric(14,2),
    status       text,
    invoice_type text
);

\copy customers          FROM 'data/raw/customers.csv'          WITH (FORMAT csv, HEADER true, NULL '');
\copy dim_customer_scd2  FROM 'data/raw/dim_customer_scd2.csv'  WITH (FORMAT csv, HEADER true, NULL '');
\copy employees          FROM 'data/raw/employees.csv'          WITH (FORMAT csv, HEADER true, NULL '');
\copy projects           FROM 'data/raw/projects.csv'           WITH (FORMAT csv, HEADER true, NULL '');
\copy timesheets         FROM 'data/raw/timesheets.csv'         WITH (FORMAT csv, HEADER true, NULL '');
\copy project_costs      FROM 'data/raw/project_costs.csv'      WITH (FORMAT csv, HEADER true, NULL '');
\copy invoices           FROM 'data/raw/invoices.csv'           WITH (FORMAT csv, HEADER true, NULL '');

-- Kontroll. Förväntat antal rader:
--   customers 8, dim_customer_scd2 11, employees 10, projects 12,
--   timesheets 1271, project_costs 162, invoices 45
SELECT 'customers' AS tabell, count(*) FROM customers
UNION ALL SELECT 'dim_customer_scd2', count(*) FROM dim_customer_scd2
UNION ALL SELECT 'employees',         count(*) FROM employees
UNION ALL SELECT 'projects',          count(*) FROM projects
UNION ALL SELECT 'timesheets',        count(*) FROM timesheets
UNION ALL SELECT 'project_costs',     count(*) FROM project_costs
UNION ALL SELECT 'invoices',          count(*) FROM invoices
ORDER BY 1;

-- ---------------------------------------------------------------------
-- Fallback om Postgres strular: DuckDB läser CSV utan att ladda något.
--
--   INSTALL httpfs; -- behövs inte lokalt
--   CREATE VIEW invoices AS SELECT * FROM read_csv_auto('data/raw/invoices.csv');
--
-- Syntaxen i övningarna fungerar i stort sett oförändrad.
-- ---------------------------------------------------------------------
