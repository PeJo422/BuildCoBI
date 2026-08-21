# Övning 4 — Rapporten är fel

**Tid:** 35 minuter
**Branch:** `fix/duplicate-cost-rows`
**Spara i:** `sql/03_validation.sql`

## Ärendet

Ekonomichefen ringer.

> "Din rapport visar att P-1004 Lagerhall Stallbacka har kostat 9 235 860 kr.
> Det är 44 % över budget. Ekonomisystemet säger 7 551 990 kr. Platschefen är
> förbannad och vi har styrelsemöte på torsdag."

Du har rapporten, datan och SQL. Hitta felet.

## Så här jobbar du

Börja brett och smalna av. Skriv ned varje steg — det är den delen som gör dig
snabbare nästa gång.

1. Är det bara P-1004 eller flera projekt?

```sql
SELECT project_id, count(*) AS rader, sum(amount) AS kostnad
FROM project_costs
GROUP BY project_id
ORDER BY kostnad DESC;
```

2. Jämför alltid antal rader, inte bara summor. En summa som är för hög beror
   nästan alltid på för många rader, inte på för stora belopp.

```sql
SELECT count(*), count(DISTINCT cost_id) FROM project_costs;
```

Vad säger det, och vad säger det inte?

3. Leta efter poster som förekommer flera gånger med olika `cost_id`:

```sql
SELECT voucher_no, cost_date, supplier, amount, count(*) AS antal
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;
```

4. Hur stort är felet?

5. Skriv ett test som fångar samma fel automatiskt i framtiden. Det ska
   returnera noll rader när datan är ren.

## Rätta felet

6. Var ska felet rättas? Fyra alternativ, alla används i verkligheten:

| Var | Konsekvens |
|---|---|
| I Power BI | Snabbast. Nästa person som läser tabellen får fortfarande fel. |
| I SQL-vyn | Rätt i rapporten, fel kvar i tabellen. |
| I laddningen till datalagret | Görs en gång, gäller alla som läser datan. |
| I källsystemet | Bäst, men kräver att någon annan prioriterar det. |

Motivera ditt val. Vad hade du gjort om styrelsemötet var om två timmar, och
vad hade du gjort om det var om två veckor?

7. Bygg vyn:

```sql
CREATE OR REPLACE VIEW vw_fact_project_cost AS
SELECT DISTINCT ON (voucher_no, cost_date, supplier, amount)
       cost_id, project_id, cost_date, cost_type, supplier, amount, voucher_no
FROM project_costs
ORDER BY voucher_no, cost_date, supplier, amount, cost_id;
```

8. Kontrollera att summan nu stämmer mot ekonomisystemet.

9. Uppdatera i Power BI och se att P-1004 landar på 18 % över budget.

## Leta vidare

Datan innehåller fler saker som en BI-utvecklare hade reagerat på. Hitta minst
två:

10. Finns det timrader med orimligt många timmar på en dag?

11. Finns det timrader utan projekt? Vad händer med dem i en `INNER JOIN`?

12. Finns det fakturor med negativt belopp? Vad är det, och ska de räknas med i
    omsättningen?

13. Jämför pågående och avslutade projekt mot budget. Varför ser pågående
    projekt så lönsamma ut, och hur skulle du lösa det?

## Pull request

```bash
git checkout -b fix/duplicate-cost-rows
git add sql/03_validation.sql
git commit -m "Fix duplicated cost rows from re-run import batch"
git push -u origin fix/duplicate-cost-rows
```

Öppna en pull request på GitHub och skriv beskrivningen som om någon annan ska
granska den om ett halvår:

- Vad var fel
- Hur upptäcktes det
- Hur är det rättat
- Hur vet vi att det inte kommer tillbaka

Merga sedan.

## Att kunna svara på efteråt

- Varför är `count(*)` det första du kollar när en summa är för hög?
- Vad är skillnaden mellan att dölja ett fel och att rätta det?
- Varför räcker inte primärnyckeln `cost_id` som skydd mot dubbletter?
