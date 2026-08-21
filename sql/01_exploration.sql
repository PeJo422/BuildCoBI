-- =====================================================================
-- 01 — Utforskning
-- Skriv dina egna frågor här. Uppgifterna finns i exercises/01_sql.md.
-- =====================================================================

-- Titta på tabellerna först. Fråga dig för varje tabell: vad är en rad?

SELECT * FROM projects;
SELECT * FROM invoices LIMIT 20;
SELECT * FROM timesheets LIMIT 20;
SELECT * FROM project_costs LIMIT 20;


-- 1. Hur många rader finns i varje tabell?

-- 2. Vilka projekt är pågående?

-- 3. Fakturerat belopp per projekt, störst först.

-- 4. Antal kostnadsrader och total kostnad per kostnadstyp.

-- 5. Rapporterade timmar per anställd. Vem har flest?

-- 6. Projekt med kundnamn (JOIN mot customers).

-- 7. Fakturerat per månad under 2026.
--    Tips: date_trunc('month', invoice_date)
