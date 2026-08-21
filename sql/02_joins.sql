-- =====================================================================
-- 02 — Joins, grain och historik
-- Uppgifterna finns i exercises/02_modeling.md och 03_scd_type2.md.
-- =====================================================================

-- ---------------------------------------------------------------------
-- A. Fan-out: vad händer när två fakta joinas i samma fråga?
-- ---------------------------------------------------------------------

-- Gissa svaret innan du kör.
SELECT count(*)
FROM projects p
JOIN invoices i      ON i.project_id = p.project_id
JOIN project_costs c ON c.project_id = p.project_id;

-- Skriv om frågan så att varje fact aggregeras för sig först.
-- Tips: WITH ... AS ( ... )


-- ---------------------------------------------------------------------
-- B. SCD type 2
-- ---------------------------------------------------------------------

-- Så här ser kunden ut i källsystemet:
SELECT * FROM customers WHERE customer_id = 'C103';

-- Så här ser den ut i datalagret:
SELECT customer_sk, customer_id, contact_name, valid_from, valid_to, is_current
FROM dim_customer_scd2
WHERE customer_id = 'C103';

-- 1. Joina invoices mot dim_customer_scd2 på enbart customer_id.
--    Hur många rader blir det? Vad blir summan?

-- 2. Lägg till datumvillkoret så att varje faktura får rätt version.

-- 3. Räkna om på hela datamängden och jämför rader och summa före/efter.
