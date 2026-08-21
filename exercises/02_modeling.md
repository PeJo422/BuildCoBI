# Övning 2 — Datamodell och grain

**Tid:** 45 minuter
**Branch:** `feature/data-model`
**Spara i:** `model/data_model.md` och `sql/02_joins.sql`

## Fact eller dimension

1. Gå igenom de sju tabellerna. Vilka är fakta (något hände) och vilka är
   dimensioner (något du vill dela upp fakta efter)? Motivera kort.

2. `projects` innehåller `budget_amount`, som går att summera. Gör det
   `projects` till en fact-tabell? Resonera.

## Grain

3. Vad representerar en rad i `timesheets`? Skriv ned din gissning innan du
   kollar.

4. Bevisa den:

```sql
SELECT project_id, employee_id, work_date, count(*)
FROM timesheets
GROUP BY project_id, employee_id, work_date
HAVING count(*) > 1;
```

Noll rader betyder att du gissade rätt. Får du rader betyder det att din
beskrivning av grain är fel, inte att datan är trasig.

5. Gör samma sak för `invoices` och `project_costs`. Vilken kombination av
   kolumner utgör grain i vardera?

## Fan-out

6. Gissa hur många rader den här frågan ger, kör den sedan:

```sql
SELECT count(*)
FROM projects p
JOIN invoices i      ON i.project_id = p.project_id
JOIN project_costs c ON c.project_id = p.project_id;
```

7. Rita på papper vad som hände med ett enskilt projekt. Ta P-1006, som har få
   rader:

```sql
SELECT count(*) FROM invoices      WHERE project_id = 'P-1006';
SELECT count(*) FROM project_costs WHERE project_id = 'P-1006';
```

8. Skriv om frågan så att den ger ett rimligt svar: en rad per projekt med
   budget, fakturerat och kostnad. Aggregera varje fact för sig först.

```sql
WITH kostnad AS (
    ...
),
fakturerat AS (
    ...
)
SELECT ...
```

9. Använd `LEFT JOIN` i stället för `JOIN` i din lösning. Blev antalet rader
   annorlunda? Vilket är rätt här, och varför?

## Rita modellen

10. Rita stjärnschemat i `model/data_model.md`. Utgå från `fact_invoice` och
    lägg till `fact_project_cost` och `fact_timesheet`.

11. Vilka dimensioner delar de tre fact-tabellerna? Vad kallas det när två fakta
    delar dimension, och varför är det bra?

12. `fact_timesheet` har `employee_id`, men `fact_invoice` har det inte. Vad
    händer om du filtrerar rapporten på anställd och tittar på fakturerat belopp?

## Commit

```bash
git add model/data_model.md sql/02_joins.sql
git commit -m "Add first draft of data model"
```
