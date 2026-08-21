-- =====================================================================
-- FACIT — lösningar till samtliga övningar
-- Endast för den som håller i dagen.
-- =====================================================================


-- =====================================================================
-- Övning 1 — SQL
-- =====================================================================

-- 2. Radantal per tabell
SELECT 'customers' AS tabell, count(*) FROM customers
UNION ALL SELECT 'dim_customer_scd2', count(*) FROM dim_customer_scd2
UNION ALL SELECT 'employees',         count(*) FROM employees
UNION ALL SELECT 'projects',          count(*) FROM projects
UNION ALL SELECT 'timesheets',        count(*) FROM timesheets
UNION ALL SELECT 'project_costs',     count(*) FROM project_costs
UNION ALL SELECT 'invoices',          count(*) FROM invoices
ORDER BY 1;

-- 3. Pågående projekt med kund
SELECT p.project_id, p.project_name, c.customer_name, p.budget_amount
FROM projects p
JOIN customers c ON c.customer_id = p.customer_id
WHERE p.status = 'Pågående'
ORDER BY p.budget_amount DESC;

-- 4. Fakturerat per projekt
SELECT project_id, sum(amount) AS fakturerat
FROM invoices
GROUP BY project_id
ORDER BY fakturerat DESC;

-- 5. Kostnad per typ
SELECT cost_type, count(*) AS rader, sum(amount) AS kostnad
FROM project_costs
GROUP BY cost_type
ORDER BY kostnad DESC;

-- 6. Timmar per anställd
SELECT e.employee_id, e.first_name, e.last_name, sum(t.hours) AS timmar
FROM timesheets t
JOIN employees e ON e.employee_id = t.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY timmar DESC;

-- 7. Fakturerat per månad
SELECT date_trunc('month', invoice_date)::date AS manad,
       sum(amount) AS fakturerat
FROM invoices
GROUP BY 1
ORDER BY 1;

-- 9. Projektledare med flest projekt
SELECT e.first_name, e.last_name,
       count(*) AS antal_projekt,
       sum(p.budget_amount) AS total_budget
FROM projects p
JOIN employees e ON e.employee_id = p.project_manager_id
GROUP BY e.first_name, e.last_name
ORDER BY antal_projekt DESC;

-- 10. Timmar per projekt
SELECT p.project_id, p.project_name, sum(t.hours) AS timmar
FROM timesheets t
JOIN projects p ON p.project_id = t.project_id
GROUP BY p.project_id, p.project_name
ORDER BY timmar DESC;

-- 12. Den försvunna raden
SELECT count(*) AS alla FROM timesheets;                               -- 1271
SELECT count(*) AS efter_join
FROM timesheets t JOIN projects p ON p.project_id = t.project_id;      -- 1270

SELECT * FROM timesheets WHERE project_id IS NULL;                     -- T71271

-- 13. Fakturerat över budget
SELECT p.project_id, p.status, p.budget_amount, sum(i.amount) AS fakturerat
FROM projects p
JOIN invoices i ON i.project_id = p.project_id
GROUP BY p.project_id, p.status, p.budget_amount
HAVING sum(i.amount) > p.budget_amount
ORDER BY 1;


-- =====================================================================
-- Övning 2 — Grain och fan-out
-- =====================================================================

-- 4. Grain i timesheets: noll rader = en anställd, en dag, ett projekt
SELECT project_id, employee_id, work_date, count(*)
FROM timesheets
GROUP BY project_id, employee_id, work_date
HAVING count(*) > 1;

-- 5. Grain i project_costs på affärsnivå. Här kommer tre rader tillbaka,
--    och det är dagens andra planterade fel.
SELECT voucher_no, cost_date, supplier, amount, count(*)
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;

-- 6. Fan-out: 593 rader
SELECT count(*)
FROM projects p
JOIN invoices i      ON i.project_id = p.project_id
JOIN project_costs c ON c.project_id = p.project_id;

-- 8. Korrekt: aggregera varje fact för sig
WITH kostnad AS (
    SELECT project_id, sum(amount) AS total_kostnad
    FROM project_costs
    GROUP BY project_id
),
fakturerat AS (
    SELECT project_id, sum(amount) AS total_fakturerat
    FROM invoices
    GROUP BY project_id
),
tid AS (
    SELECT t.project_id,
           sum(t.hours) AS timmar,
           sum(t.hours * e.hourly_cost) AS arbetskostnad
    FROM timesheets t
    JOIN employees e ON e.employee_id = t.employee_id
    GROUP BY t.project_id
)
SELECT p.project_id,
       p.project_name,
       p.status,
       p.budget_amount,
       coalesce(f.total_fakturerat, 0)             AS fakturerat,
       coalesce(k.total_kostnad, 0)
         + coalesce(ti.arbetskostnad, 0)            AS kostnad,
       coalesce(f.total_fakturerat, 0)
         - coalesce(k.total_kostnad, 0)
         - coalesce(ti.arbetskostnad, 0)            AS marginal,
       ti.timmar
FROM projects p
LEFT JOIN kostnad    k  ON k.project_id  = p.project_id
LEFT JOIN fakturerat f  ON f.project_id  = p.project_id
LEFT JOIN tid        ti ON ti.project_id = p.project_id
ORDER BY marginal;


-- =====================================================================
-- Övning 3 — SCD type 2
-- =====================================================================

-- Kunder med flera versioner: C101, C103, C106
SELECT customer_id, count(*) AS versioner
FROM dim_customer_scd2
GROUP BY customer_id
HAVING count(*) > 1;

-- FEL: join på business key utan datumvillkor. 64 rader, 44 693 300.
SELECT count(*) AS rader, sum(i.amount) AS summa
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id;

-- RÄTT: version som gällde på fakturadatumet. 45 rader, 34 135 900.
SELECT count(*) AS rader, sum(i.amount) AS summa
FROM invoices i
JOIN dim_customer_scd2 d
      ON d.customer_id = i.customer_id
     AND i.invoice_date >= d.valid_from
     AND i.invoice_date <  COALESCE(d.valid_to, DATE '9999-12-31') + 1;

-- C103 med rätt kontaktperson per faktura
SELECT i.invoice_id, i.invoice_date, d.contact_name, i.amount
FROM invoices i
JOIN dim_customer_scd2 d
      ON d.customer_id = i.customer_id
     AND i.invoice_date >= d.valid_from
     AND i.invoice_date <  COALESCE(d.valid_to, DATE '9999-12-31') + 1
WHERE i.customer_id = 'C103'
ORDER BY i.invoice_date;

-- Så här sätts surrogatnyckeln vid laddning. Efter det joinar rapporten
-- bara på customer_sk, och felet ovan kan inte uppstå igen.
CREATE OR REPLACE VIEW vw_fact_invoice AS
SELECT i.invoice_id,
       i.project_id,
       i.customer_id,
       d.customer_sk,
       i.invoice_date,
       i.amount,
       i.invoice_type
FROM invoices i
LEFT JOIN dim_customer_scd2 d
       ON d.customer_id = i.customer_id
      AND i.invoice_date >= d.valid_from
      AND i.invoice_date <  COALESCE(d.valid_to, DATE '9999-12-31') + 1;

-- LEFT JOIN framför JOIN: en faktura till en kund som saknas i dimensionen
-- ska synas i rapporten, inte försvinna. Kontrollera att ingen fastnar:
SELECT count(*) FROM vw_fact_invoice WHERE customer_sk IS NULL;   -- 0


-- =====================================================================
-- Övning 4 — Felsökning och validering
-- =====================================================================

-- 1. Vilket projekt sticker ut
SELECT project_id, count(*) AS rader, sum(amount) AS kostnad
FROM project_costs
GROUP BY project_id
ORDER BY kostnad DESC;

-- 2. Primärnyckeln är unik, vilket inte hjälper här
SELECT count(*), count(DISTINCT cost_id) FROM project_costs;      -- 162, 162

-- 3. Dubbletterna
SELECT voucher_no, cost_date, supplier, amount, count(*) AS antal,
       string_agg(cost_id, ', ' ORDER BY cost_id) AS ids
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1
ORDER BY amount DESC;

-- 4. Felets storlek: 1 683 870
SELECT sum(amount * (antal - 1)) AS for_mycket
FROM (
    SELECT amount, count(*) AS antal
    FROM project_costs
    GROUP BY voucher_no, cost_date, supplier, amount
    HAVING count(*) > 1
) d;                                                              -- 1 683 870

-- 7. Rättad vy
CREATE OR REPLACE VIEW vw_fact_project_cost AS
SELECT DISTINCT ON (voucher_no, cost_date, supplier, amount)
       cost_id, project_id, cost_date, cost_type, supplier, amount, voucher_no
FROM project_costs
ORDER BY voucher_no, cost_date, supplier, amount, cost_id;

-- 8. Kontroll: 29 479 080 -> 27 795 210
SELECT (SELECT sum(amount) FROM project_costs)        AS fore,
       (SELECT sum(amount) FROM vw_fact_project_cost) AS efter;

-- P-1004: 9 235 860 -> 7 551 990 inklusive arbetskostnad
SELECT (SELECT sum(amount) FROM project_costs        WHERE project_id = 'P-1004')
     + (SELECT sum(t.hours * e.hourly_cost) FROM timesheets t
        JOIN employees e ON e.employee_id = t.employee_id
        WHERE t.project_id = 'P-1004') AS med_dubbletter,
       (SELECT sum(amount) FROM vw_fact_project_cost WHERE project_id = 'P-1004')
     + (SELECT sum(t.hours * e.hourly_cost) FROM timesheets t
        JOIN employees e ON e.employee_id = t.employee_id
        WHERE t.project_id = 'P-1004') AS utan_dubbletter;


-- ---------------------------------------------------------------------
-- Tester. Var och en ska returnera noll rader när datan är ren.
-- ---------------------------------------------------------------------

-- T1: dubbletter i kostnader
SELECT voucher_no, cost_date, supplier, amount, count(*)
FROM vw_fact_project_cost
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;

-- T2: timrader som pekar på okänt projekt
SELECT t.*
FROM timesheets t
LEFT JOIN projects p ON p.project_id = t.project_id
WHERE p.project_id IS NULL;                        -- T71271

-- T3: orimliga timmar
SELECT * FROM timesheets WHERE hours > 12;         -- T71270, 38 h

-- T4: fakturor utanför projektets löptid
SELECT i.invoice_id, i.invoice_date, p.start_date, p.end_date
FROM invoices i
JOIN projects p ON p.project_id = i.project_id
WHERE i.invoice_date < p.start_date
   OR (p.end_date IS NOT NULL AND i.invoice_date > p.end_date + 60);

-- T5: negativa belopp
SELECT * FROM invoices WHERE amount < 0;           -- F50043, kreditfaktura

-- T6: fakturasumman ska matcha måttet i Power BI
SELECT count(*) AS rader, sum(amount) AS fakturerat FROM invoices;
-- 45, 34 135 900


-- ---------------------------------------------------------------------
-- Vyer till Power BI, färdiga
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_dim_project AS
SELECT project_id, project_name, customer_id, project_manager_id,
       city, project_type, status, start_date, end_date, budget_amount
FROM projects;

CREATE OR REPLACE VIEW vw_dim_employee AS
SELECT employee_id, first_name || ' ' || last_name AS employee_name,
       role, department, hourly_cost, hourly_rate, is_active
FROM employees;

CREATE OR REPLACE VIEW vw_fact_timesheet AS
SELECT t.timesheet_id, t.project_id, t.employee_id, t.work_date,
       t.hours, t.activity, t.is_billable,
       t.hours * e.hourly_cost AS arbetskostnad,
       CASE WHEN t.is_billable THEN t.hours * e.hourly_rate ELSE 0 END AS debiterbart
FROM timesheets t
JOIN employees e ON e.employee_id = t.employee_id;
