# BuildCo BI — dag 1

Sex timmar, ett repo, ett fiktivt byggföretag. Du kommer bygga, förstöra, felsöka och förstå varför saker fungerar som de gör.

---

## Målet med dagen

Efter idag ska du kunna förklara, med egna ord:

> "Så här går data från ett verksamhetssystem till en BI-rapport, så här modellerar man den, så här skriver man SQL för att analysera den, och så här kan historik göra att en helt vanlig JOIN ger fel svar."

Du behöver inte kunna BI efter dagen. Du ska förstå vad yrket går ut på, ha ett eget repo med commits, och veta vad du behöver lära dig härnäst.

Tre saker du går härifrån med:

1. Ett riktigt Git-repo med minst sex commits och en mergad pull request.
2. En SQL-fil du själv skrivit som faktiskt returnerar rätt siffra.
3. En Power BI-rapport där du hittat och rättat ett fel på egen hand.

---

## Uppdraget

Du jobbar med data från **BuildCo**, ett påhittat byggföretag. Tolv projekt, januari 2025 till augusti 2026. Uppdraget från ledningen:

> "Vi vill se vilka projekt som är lönsamma, vilka som går över budget, och vad som driver avvikelserna."

Sju tabeller med rådata, i `data/raw/`:

| Tabell | Rader | En rad = |
|---|---|---|
| `customers` | 8 | en kund, som den ser ut idag |
| `dim_customer_scd2` | 11 | en version av en kund, giltig under en period |
| `employees` | 10 | en anställd |
| `projects` | 12 | ett projekt med budget och status |
| `invoices` | 45 | en fakturarad mot ett projekt |
| `project_costs` | 162 | en kostnadspost med verifikationsnummer |
| `timesheets` | 1 271 | en anställd, en dag, ett projekt |

Datan innehåller fel. Inte pedagogiskt tillrättalagda fel — samma sorts fel som dyker upp i en riktig verksamhet: dubblerade importer, historik som skrivs över, en och annan felregistrerad rad. Du kommer hitta några av dem själv under dagen.

---

## Schema

| Tid | Pass |
|---|---|
| 09:00–09:20 | Vad är BI egentligen |
| 09:20–09:50 | Repot och Git |
| 09:50–10:30 | Rådata och SQL |
| 10:30–10:45 | Fika |
| 10:45–11:30 | Datamodell och grain |
| 11:30–12:15 | Ida och SCD2 |
| 12:15–12:45 | Lunch |
| 12:45–13:35 | Power BI och DAX |
| 13:35–14:10 | "Rapporten är fel" |
| 14:10–14:35 | Hur blir det här ett riktigt system |
| 14:35–15:00 | Vad du behöver lära dig härnäst |

Passet 11:30–12:15 och passet 13:35–14:10 är dagens kärna. Om något drar ut på tiden är det de två som ska hinnas med, resten går att korta.

---

## 09:00–09:20 — Vad är BI egentligen

Ingen dator uppe än. Rita gärna med på papper.

```
Verksamhet
   ↓
Källsystem          (affärssystem, tidrapportering, ekonomi)
   ↓
Ingestion           (hämta ut data, schemalagt)
   ↓
Staging             (rådata, orörd, en kopia)
   ↓
Data warehouse      (modellerad, historik, definitioner)
   ↓
Semantisk modell    (mått, relationer)
   ↓
Power BI            (rapport)
   ↓
Beslut
```

Scenariot: BuildCo har tolv projekt igång. VD vill veta vilka som går över budget, varför, och hur prognosen ser ut.

Fundera på de här frågorna innan ni går vidare — du kommer märka att du redan har en känsla för svaren, för det handlar om verksamhet, inte teknik:

- Var finns informationen idag?
- Vem matar in den, och när?
- Vad betyder "kostnad"? Är en beställd men ej levererad materialleverans en kostnad?
- Vad betyder "projekt"? Räknas en tilläggsbeställning som samma projekt?
- När blir en kostnad en kostnad — vid beställning, leverans, fakturadatum eller bokföringsdatum?
- Hur vet man att en siffra i en rapport faktiskt stämmer?

Det här passet finns för att BI börjar i verksamheten, inte i Power BI. Nio av tio gånger en rapport visar fel siffra ligger orsaken i något av svaren ovan, inte i en DAX-formel.

---

## 09:20–09:50 — Repot och Git

**Mål:** du har ett repo på GitHub med struktur och en första commit.

```bash
mkdir buildco-bi && cd buildco-bi
git init
```

Kör `git status` efter varje kommando nedan. Läs vad det faktiskt står — det är så du lär dig vad varje steg gör.

Skapa strukturen:

```
buildco-bi/
├── README.md
├── docs/
├── data/raw/          <- lägg CSV-filerna här
├── data/processed/
├── sql/
├── model/
├── powerbi/
└── exercises/
```

```bash
git add .
git commit -m "Initial project setup"
```

Fyra tillstånd att hålla koll på:

```
filer på disk  --git add-->  staged  --git commit-->  historik  --git push-->  GitHub
```

Koppla till GitHub:

```bash
git branch -M main
git remote add origin git@github.com:<ditt-användarnamn>/buildco-bi.git
git push -u origin main
```

Lägg till en `.gitignore` som håller ute Power BI-filer, som är binära och blir tunga i Git:

```
*.pbix
*.csv.bak
.DS_Store
```

**Commit:** `Initial project setup`

Ny branch för nästa pass:

```bash
git checkout -b feature/sql-exploration
```

---

## 09:50–10:30 — Rådata och SQL

**Mål:** du skriver egna frågor mot riktiga tabeller och läser svaret kritiskt.

Ladda datan enligt `sql/00_setup_postgres.sql`. Börja bredast möjligt:

```sql
SELECT * FROM projects;
SELECT * FROM invoices LIMIT 20;
SELECT * FROM timesheets LIMIT 20;
```

Fråga dig själv för varje tabell: **vad är egentligen en rad här?** Gissa innan du är säker — det är okej att ha fel första gången, `timesheets` lurar de flesta.

Gå igenom i den här ordningen, och skriv varje fråga själv:

```sql
-- COUNT: hur mycket data har vi
SELECT count(*) FROM invoices;

-- WHERE: filtrera
SELECT * FROM projects WHERE status = 'Pågående';

-- GROUP BY + SUM: aggregera
SELECT project_id, sum(amount) AS fakturerat
FROM invoices
GROUP BY project_id
ORDER BY fakturerat DESC;

-- JOIN: sätt ihop
SELECT p.project_name, c.customer_name, p.budget_amount
FROM projects p
JOIN customers c ON p.customer_id = c.customer_id;
```

Sju koncept räcker för idag: `SELECT`, `WHERE`, `GROUP BY`, `SUM`, `COUNT`, `JOIN`, alias.

Övningarna finns i `exercises/01_sql.md`. Spara frågorna i `sql/01_exploration.sql` allt eftersom.

Två saker att lägga märke till när de dyker upp:

- Om Postgres klagar på att en kolumn måste finnas i `GROUP BY` — allt i `SELECT` som inte är aggregerat (`sum`, `count` osv) måste finnas i `GROUP BY`. Databasen vet inte vilket värde den ska visa om du bett den slå ihop flera rader till en.
- När du joinar `projects` mot `customers` och får exakt 12 rader tillbaka: fundera på varför det inte blev fler. Håll den tanken kvar, den kommer tillbaka efter lunch.

**Commit:** `Add SQL exploration queries`

---

## 10:30–10:45 — Fika

Lämna SQL:en en stund.

---

## 10:45–11:30 — Datamodell och grain

**Mål:** du kan skilja på fact och dimension, och kan svara exakt på vad en rad representerar.

```bash
git checkout main && git merge feature/sql-exploration
git checkout -b feature/data-model
```

Stjärnschema:

```
              dim_customer
                    │
 dim_date ──── fact_invoice ──── dim_project
                    │
              dim_employee
```

**Fact** = något som hände. Faktura skickad, kostnad bokförd, timme rapporterad.
**Dimension** = det du vill dela upp händelsen efter. Kund, projekt, datum, anställd.

Enkelt test: kan du summera kolumnen och få något meningsfullt? Troligen ett mått i en fact. Vill du filtrera eller gruppera på den istället? Troligen en dimension.

Sedan grain. Ställ frågan till dig själv:

> "Vad representerar EN rad i `project_costs`? Och i `timesheets`?"

Skriv ned din gissning innan du kollar. Bevisa den sedan:

```sql
SELECT project_id, employee_id, work_date, count(*)
FROM timesheets
GROUP BY project_id, employee_id, work_date
HAVING count(*) > 1;
```

Noll rader tillbaka betyder att du gissade rätt — det är precis så här grain avgörs på riktigt, inte genom att slå upp en definition. Gör samma sak för `invoices` och `project_costs`.

Testa sedan vad som händer när du joinar tre fact-tabeller i samma fråga:

```sql
SELECT count(*)
FROM projects p
JOIN invoices i ON i.project_id = p.project_id
JOIN project_costs c ON c.project_id = p.project_id;
```

Resultatet blir orimligt stort. Varje faktura paras ihop med varje kostnad på samma projekt — det kallas fan-out, och det är samma mekanism som ställer till det i nästa pass, fast där är det historik som orsakar det istället för tre fakta i en fråga.

Regeln att ta med sig: **aggregera varje fact för sig, joina sedan ihop resultaten.**

```sql
WITH kostnad AS (
    SELECT project_id, sum(amount) AS total_kostnad
    FROM project_costs GROUP BY project_id
),
fakturerat AS (
    SELECT project_id, sum(amount) AS total_fakturerat
    FROM invoices GROUP BY project_id
)
SELECT p.project_name, p.budget_amount, f.total_fakturerat, k.total_kostnad
FROM projects p
LEFT JOIN kostnad k ON k.project_id = p.project_id
LEFT JOIN fakturerat f ON f.project_id = p.project_id;
```

Rita din modell i `model/data_model.md`. Handritad och fotad går bra, men ASCII rakt i filen är bättre — då hamnar den i Git och blir en del av historiken.

**Commit:** `Add first draft of data model`

---

## 11:30–12:15 — Ida och SCD2

**Dagens viktigaste pass.**

```bash
git checkout -b feature/scd2
```

Bakgrunden: kunden C103, Svensk Villaservice AB, har kontaktpersonen Ida Andersson. Den 1 juni 2026 gifter hon sig och byter efternamn till Svensson. Affärssystemet uppdaterar raden direkt.

Kolla vad källsystemet vet nu:

```sql
SELECT * FROM customers WHERE customer_id = 'C103';
```

Bara Ida Svensson står där. Historiken är överskriven — om ingen sparat den går den inte att få tillbaka.

Kolla vad datalagret vet:

```sql
SELECT customer_sk, customer_id, contact_name, valid_from, valid_to, is_current
FROM dim_customer_scd2
WHERE customer_id = 'C103';
```

```
customer_sk | customer_id | contact_name  | valid_from | valid_to   | is_current
------------|-------------|---------------|------------|------------|-----------
1004        | C103        | Ida Andersson | 2024-01-01 | 2026-05-31 | false
1005        | C103        | Ida Svensson  | 2026-06-01 | (null)     | true
```

Två begrepp, lätta att blanda ihop:

- **Business key** — `customer_id`. Kommer från källsystemet, identifierar kunden.
- **Surrogate key** — `customer_sk`. Sätts av datalagret, identifierar *en version av* kunden.

Gör nu felet med flit:

```sql
SELECT i.invoice_id, i.invoice_date, d.contact_name, i.amount
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id
WHERE i.customer_id = 'C103'
ORDER BY i.invoice_date;
```

Åtta fakturor blir sexton rader. Varje faktura kopplas mot båda versionerna av Ida.

Kör samma sak på hela datamängden och se skadan:

```sql
SELECT count(*) AS rader, sum(i.amount) AS summa
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id;
```

Jämför med vad `invoices` faktiskt innehåller. Ingen kolumn ser konstig ut, ingen felkod dyker upp, rapporten går att publicera precis som den är. Det är exakt därför den här typen av fel kan hinna ända fram till en ledningsgrupp innan någon märker något.

Nu rätt version:

```sql
SELECT i.invoice_id, i.invoice_date, d.contact_name, i.amount
FROM invoices i
JOIN dim_customer_scd2 d
      ON d.customer_id = i.customer_id
     AND i.invoice_date >= d.valid_from
     AND i.invoice_date <  COALESCE(d.valid_to, DATE '9999-12-31') + 1
WHERE i.customer_id = 'C103'
ORDER BY i.invoice_date;
```

Fakturorna från 2025 och april 2026 hamnar nu på Ida Andersson, juli 2026 på Ida Svensson.

Fundera på varför `COALESCE` behövs. Testa:

```sql
SELECT NULL > DATE '2026-01-01';
```

`valid_to` är null för den aktuella versionen, och ett datum jämfört mot null blir aldrig sant. Det är därför många datalager använder `9999-12-31` istället för null. Båda varianterna finns i verkligheten.

Poängen att formulera själv innan lunch: *i ett riktigt datalager joinar man inte fakta mot dimensioner på business key, utan på surrogatnyckeln som redan pekar på rätt version.* Datumvillkoret ovan är hur den nyckeln sätts från början.

Övningarna finns i `exercises/03_scd_type2.md`. Spara frågorna i `sql/02_joins.sql`.

**Commit:** `Add SCD type 2 join with validity window`

---

## 12:15–12:45 — Lunch

Fråga gärna kursledaren vad en vanlig arbetsvecka faktiskt innehåller — SQL, Power BI, Git, möten, kravdiskussioner, felsökning, testning, modellering. Och hur stor del av jobbet som handlar om att svara på frågan "varför är den här siffran fel?". Det brukar vara en större del än man tror.

---

## 12:45–13:35 — Power BI och DAX

**Mål:** du ser hela kedjan SQL → modell → mått → visual, med egna händer.

```bash
git checkout main && git merge feature/scd2
git checkout -b feature/powerbi
```

Bygg vyerna i Postgres först (skelettet finns i `sql/03_validation.sql`):

```sql
CREATE OR REPLACE VIEW vw_fact_invoice AS
SELECT invoice_id, project_id, customer_id, invoice_date, amount, invoice_type
FROM invoices;

CREATE OR REPLACE VIEW vw_dim_project AS
SELECT project_id, project_name, customer_id, city, project_type, status, budget_amount
FROM projects;
```

Importera vyerna till Power BI Desktop. Börja i modellvyn, innan du bygger något visuellt. Dra relationerna själv och tänk igenom riktning och kardinalitet (1:n, enkelriktad) — det är samma stjärnschema du ritade före lunch, nu med musen.

Skapa en datumtabell — det är nästan alltid det första steget i en Power BI-modell:

```dax
dim_date =
CALENDAR ( DATE ( 2025, 1, 1 ), DATE ( 2026, 12, 31 ) )
```

Markera den som datumtabell och koppla till `invoice_date`.

Tre mått att skriva:

```dax
Fakturerat = SUM ( vw_fact_invoice[amount] )

Antal fakturor = DISTINCTCOUNT ( vw_fact_invoice[invoice_id] )

Snittfaktura = DIVIDE ( [Fakturerat], [Antal fakturor] )
```

`DIVIDE` istället för `/` — annars ger division med noll ett fel i visualen.

Bygg fyra visuals:

1. Kort: total fakturering
2. Stapel: fakturering per projekt
3. Linje: fakturering per månad
4. Tabell: projekt, budget, fakturerat

Klicka sedan på en stapel och se att alla andra visuals filtreras samtidigt. Fundera på varför det fungerar — svaret ligger i relationerna i modellen, inte i visualen. Ett mått räknas om utifrån den filterkontext det hamnar i, och den kontexten kommer från modellen du byggde.

```
SQL  →  modell  →  DAX  →  visual
```

Om det finns tid: lägg till `Budget = SUM ( vw_dim_project[budget_amount] )` och se vad som händer när du försöker bryta ned den per månad. Den går inte att bryta ned, eftersom budget saknar datum. Bra sak att ha snubblat på.

Spara som `powerbi/buildco.pbix`. Filen ligger i `.gitignore`, så dokumentera måtten i `powerbi/README.md` istället.

**Commit:** `Document Power BI measures and model setup`

---

## 13:35–14:10 — "Rapporten är fel"

**Mål:** du felsöker en avvikelse på riktigt, hittar orsaken och rättar den via en pull request.

Rollen du får:

> "Du är BI-utvecklare på BuildCo. Ekonomichefen ringer. Din rapport visar att projekt P-1004 har kostat betydligt mer än väntat. Ekonomisystemet säger en helt annan, lägre siffra. Platschefen är förbannad. Vad är fel?"

Verktygen du behöver:

```sql
-- 1. Vilket projekt sticker ut?
SELECT project_id, count(*) AS rader, sum(amount) AS kostnad
FROM project_costs
GROUP BY project_id
ORDER BY kostnad DESC;

-- 2. Finns samma verifikat flera gånger?
SELECT voucher_no, cost_date, supplier, amount, count(*) AS antal
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;

-- 3. Hur mycket är för mycket?
SELECT sum(amount) AS dubblerat_belopp
FROM project_costs
WHERE voucher_no IN ('V2026-0001','V2026-0002','V2026-0003');
```

Skriv sedan ett test som fångar samma fel i framtiden:

```sql
-- Ska returnera noll rader
SELECT voucher_no, cost_date, supplier, amount, count(*)
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;
```

Fundera på var felet borde rättas — det är en fråga en BI-utvecklare ställer sig varje vecka:

- I rapporten (`DISTINCT` i Power BI) — snabbast, döljer felet, sämst i längden.
- I SQL-vyn — bättre, men alla andra som läser tabellen får fortfarande fel.
- I laddningen till datalagret — görs en gång, gäller alla.
- I källsystemet — bäst, men tar tid och kräver att någon annan prioriterar det.

Rättningen:

```sql
CREATE OR REPLACE VIEW vw_fact_project_cost AS
SELECT DISTINCT ON (voucher_no, cost_date, supplier, amount)
       cost_id, project_id, cost_date, cost_type, supplier, amount, voucher_no
FROM project_costs
ORDER BY voucher_no, cost_date, supplier, amount, cost_id;
```

**Nu gör du pull request-momentet:**

```bash
git checkout -b fix/duplicate-cost-rows
# redigera sql/03_validation.sql
git add sql/03_validation.sql
git commit -m "Fix duplicated cost rows from re-run import batch"
git push -u origin fix/duplicate-cost-rows
```

Öppna sedan en pull request på GitHub. Skriv beskrivningen som om någon annan ska granska den om ett halvår: vad var fel, hur upptäcktes det, hur är det rättat, hur vet vi att det inte kommer tillbaka. Merga.

Uppdatera i Power BI och se att siffran ändras. Kedjan från felanmälan till rättad rapport är nu komplett, och du har gjort varje steg själv.

**Commit + PR:** `Fix duplicated cost rows from re-run import batch`

---

## 14:10–14:35 — Hur blir det här ett riktigt system

Hela kedjan igen, nu med verktygsnamn:

```
Affärssystem / tidrapportering
        │
        ▼
   Azure Data Factory        (ingestion, schemalagd)
        │
        ▼
      Raw / landing          (orörd kopia, historik sparas)
        │
        ▼
      Staging                (typer, namn, ingen affärslogik)
        │
        ▼
        dbt                  (transformationer, tester, dokumentation)
        │
        ▼
   Data warehouse            (dim_ och fact_, SCD2)
        │
        ▼
   Semantisk modell          (mått, relationer)
        │
        ▼
      Power BI
```

Du har idag gjort staging (CSV → Postgres), transformation (vyerna), datalagerlogik (SCD2-joinen), semantisk modell (Power BI-modellen) och test (dubblettkontrollen). Verktygen i ett riktigt företag är fler och större, men stegen är samma.

Arbetsflödet du redan har provat:

```
feature branch → commit → push → pull request → granskning → test → merge → produktion
```

I ett team som använder dbt körs testerna automatiskt när en pull request öppnas. Om dubblettkontrollen misslyckas går ändringen inte att merga — samma test du skrev för en stund sedan, bara automatiserat.

BI-roller ser olika ut, och du behöver inte välja idag:

- **Power BI-tung roll** — rapporter, DAX, nära verksamheten. Kortast väg in.
- **Data warehouse / SQL-tung roll** — modellering, laddningar, prestanda.
- **Analytics engineer** — dbt, SQL, modellering, mitt emellan de två ovan. Rollen som växer snabbast just nu.

---

## 14:35–15:00 — Vad du behöver lära dig härnäst

```
                    BI / DATA
                        │
        ┌───────────────┼────────────────┐
        │               │                │
       SQL       Datamodellering      Power BI
        │               │                │
        └───────────────┼────────────────┘
                        │
                       DAX
                        │
               ┌────────┴────────┐
               │                 │
              dbt              Azure
               │                 │
               └────────┬────────┘
                        │
                 Data engineering
                        │
                Python / statistik
                        │
                  Data science
```

Din väg härifrån, som börjar med det du redan kan:

```
BYGG / VERKSAMHET
        ↓
KALKYL / EXCEL / POWER QUERY
        ↓
SQL
        ↓
POWER BI
        ↓
DATAMODELLERING
        ↓
BI / DATA ANALYST
        ↓
dbt / Python / statistik
        ↓
ANALYTICS ENGINEERING
```

Tre saker värda att komma ihåg:

1. Det du behöver lära dig först är **SQL, datamodellering och Power BI**. Inte trettioåtta olika tekniker samtidigt.
2. Python, machine learning och statistik ligger senare. AI gör det lätt att trolla fram avancerad kod, men den som gör det innan datan är förstådd lär sig trycka på knappar utan att förstå problemet.
3. Verksamhetskunskapen du redan har är den delen som tar längst tid att bygga upp för de flesta andra som går in i det här yrket. Du börjar inte på noll.

Skriv färdigt `README.md` i repot med egna ord om vad projektet är. Något i stil med:

> "Ett BI-projekt där jag modellerar projekt-, kostnads- och tidsdata från ett byggföretag. Innehåller SQL för utforskning och validering, en dimensionell modell med SCD type 2, och en Power BI-rapport."

Det är en mening du faktiskt kan säga i en anställningsintervju, och den är sann.

**Sista commit:** `Update README with project description`

---

## Efter dagen

Repot är ditt att fortsätta bygga på. Naturliga nästa steg, en branch i taget:

- `feature/dim-date` — bygg en riktig datumdimension i SQL istället för i DAX
- `feature/margin-analysis` — lönsamhet per projekt, kund och projekttyp
- `feature/forecast` — prognos på pågående projekt baserat på upparbetad tid
- `feature/dbt-init` — flytta vyerna till dbt-modeller med tester

En commit per sak du lär dig. Om ett halvår har du en historik som visar exakt hur du utvecklats — det är mer övertygande än vilket kursintyg som helst.

Fyll gärna i `docs/learning-plan.md` under dagen och efteråt. Skriv med egna ord, inte kursledarens.
