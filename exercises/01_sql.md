# Övning 1 — SQL

**Tid:** 40 minuter
**Branch:** `feature/sql-exploration`
**Spara i:** `sql/01_exploration.sql`

Skriv varje fråga själv. Att läsa SQL och att skriva SQL är två olika förmågor,
och bara den ena är den du behöver.

## Utforska

1. Titta på alla sju tabellerna. Skriv för varje tabell en mening om vad en rad
   representerar. Skriv meningen som en kommentar i SQL-filen.

2. Hur många rader finns i varje tabell?

3. Vilka projekt har status `Pågående`? Vilka kunder tillhör de?

## Aggregera

4. Fakturerat belopp per projekt, störst först.

5. Total kostnad och antal kostnadsrader per `cost_type`.

6. Antal rapporterade timmar per anställd. Vem har flest?

7. Fakturerat per månad. Använd `date_trunc('month', invoice_date)`.

## Joina

8. Lista projekt tillsammans med kundnamn och budget.

9. Vilken projektledare ansvarar för flest projekt, och för hur stor total budget?

10. Timmar per projekt, med projektnamn i resultatet.

## Tänk efter

11. Kör frågan i uppgift 8. Varför blev det exakt 12 rader?

12. Kör den här:

```sql
SELECT count(*) FROM timesheets;
SELECT count(*) FROM timesheets t JOIN projects p ON p.project_id = t.project_id;
```

Talen skiljer sig åt med ett. Varför? Vad hände med den raden, och vem hade
märkt det om den innehållit riktiga pengar?

13. Vilka projekt har fakturerat mer än sin budget?

## Fastnar du

Ett fel du garanterat kommer att se:

```
ERROR:  column "p.project_name" must appear in the GROUP BY clause
        or be used in an aggregate function
```

Allt i `SELECT` som inte är inuti `sum()`, `count()` eller liknande måste finnas
i `GROUP BY`. Databasen kan inte veta vilket projektnamn du vill se om du bett
den slå ihop flera rader.

## Commit

```bash
git add sql/01_exploration.sql
git commit -m "Add SQL exploration queries"
```
