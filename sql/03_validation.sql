-- =====================================================================
-- 03 — Validering och vyer till Power BI
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tester. Var och en ska returnera noll rader.
-- ---------------------------------------------------------------------

-- 1. Dubbletter i project_costs (samma verifikat, datum, leverantör, belopp)


-- 2. Timrader som pekar på ett projekt som inte finns


-- 3. Orimliga timmar på en dag


-- 4. Fakturor med datum utanför projektets löptid


-- ---------------------------------------------------------------------
-- Vyer som Power BI läser
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_dim_project AS
SELECT project_id, project_name, customer_id, project_manager_id,
       city, project_type, status, start_date, end_date, budget_amount
FROM projects;

CREATE OR REPLACE VIEW vw_fact_invoice AS
SELECT invoice_id, project_id, customer_id, invoice_date, amount, invoice_type
FROM invoices;

-- vw_fact_project_cost: skriv den själv, och se till att den inte
-- innehåller dubblettbunten.

-- vw_fact_timesheet: timmar och arbetskostnad per rad.
-- Tips: hours * hourly_cost kräver en join mot employees.
