# BuildCo BI — dag 1

Sex timmar, en deltagare, ett repo. Han bygger, förstör, felsöker och förstår varför saker fungerar.

---

## Målet med dagen

Efter dagen ska han kunna säga följande med egna ord och mena det:

> "Så här går data från ett verksamhetssystem till en BI-rapport, så här modellerar man den, så här skriver man SQL för att analysera den, och så här kan historik göra att en helt vanlig JOIN ger fel svar."

Han ska inte kunna BI efter dagen. Han ska förstå vad yrket går ut på, ha ett repo med commits och veta vad han behöver lära sig härnäst.

Tre saker han tar med sig hem:

1. Ett riktigt Git-repo med minst sex commits och en mergad pull request.
2. En SQL-fil som han själv skrivit och som faktiskt returnerar rätt siffra.
3. En Power BI-rapport där han hittat och rättat ett fel.

---

## Före dagen (30 min för dig)

| Sak | Kommentar |
|---|---|
| PostgreSQL 14+ lokalt | Docker eller installerad. Databas `buildco`. |
| DBeaver eller pgAdmin | DBeaver är enklare för en nybörjare. |
| Power BI Desktop | Installerat och startat en gång, annars går första kvarten åt till uppdateringar. |
| Git + GitHub-konto | `git config user.name` och `user.email` satta i förväg. |
| Repot | Ladda in datan enligt `sql/00_setup_postgres.sql` och verifiera att `SELECT count(*) FROM invoices;` ger 45. |

**Ta bort `facit/` innan du delar repot med honom**, eller lägg den i en egen branch som du behåller. Halva poängen med dagen försvinner om svaren ligger bredvid uppgifterna.

Kör igenom övning 3 (SCD2) och 4 (dubbletterna) själv en gång. De två passen är dagens kärna och du vill inte leta efter rätt kolumnnamn framför honom.

---

## Datasetet

Sju CSV-filer i `data/raw/`. Ett påhittat byggföretag med tolv projekt mellan januari 2025 och augusti 2026.

| Tabell | Rader | En rad = |
|---|---|---|
| `customers` | 8 | en kund, som den ser ut idag i affärssystemet |
| `dim_customer_scd2` | 11 | en version av en kund, giltig under en period |
| `employees` | 10 | en anställd |
| `projects` | 12 | ett projekt med budget och status |
| `invoices` | 45 | en fakturarad mot ett projekt |
| `project_costs` | 162 | en kostnadspost med verifikationsnummer |
| `timesheets` | 1 271 | en anställd, en dag, ett projekt |

Uppdraget han får:

> "Ledningen vill se vilka projekt som är lönsamma, vilka som går över budget och vad som driver avvikelserna."

### Vad som ligger medvetet fel i datan

Detta är till dig, inte till honom.

1. **SCD2-fällan.** `dim_customer_scd2` har två versioner av C101, C103 och C106. En join på enbart `customer_id` dubblar deras fakturor: 45 rader blir 64, och 34,1 Mkr blir 44,7 Mkr.
2. **Dubblettbunten.** Tre kostnadsrader på projekt P-1004 finns två gånger (verifikat V2026-0001, V2026-0002, V2026-0003). Samma belopp, samma datum, samma leverantör, olika `cost_id`. 1 683 870 kr för mycket. P-1004 ser ut att ligga 44 % över budget när det egentligen ligger 18 % över.
3. **Utstickare i tid.** En timrad på 38 timmar samma dag (P-1007, 2026-02-11).
4. **Föräldralös rad.** En timrad utan `project_id` (utbildning felregistrerad som projekttid). Den försvinner tyst vid en INNER JOIN.
5. **Kreditfaktura.** P-1006 har en faktura med negativt belopp. Den som filtrerar bort negativa belopp får fel omsättning.

Nummer 1 och 2 är planerade övningar. Nummer 3–5 är där om han hittar dem, och de är bra att ta upp om det blir tid över.

---

## Schema

| Tid | Pass | Format |
|---|---|---|
| 09:00–09:20 | Vad är BI egentligen | Whiteboard, ingen dator |
| 09:20–09:50 | Repot och Git | Terminal |
| 09:50–10:30 | Rådata och SQL | SQL |
| 10:30–10:45 | Fika | — |
| 10:45–11:30 | Datamodell och grain | Whiteboard + SQL |
| 11:30–12:15 | Ida och SCD2 | SQL, dagens viktigaste pass |
| 12:15–12:45 | Lunch | Prata om yrket, inte tekniken |
| 12:45–13:35 | Power BI och DAX | Power BI Desktop |
| 13:35–14:10 | "Rapporten är fel" | Felsökning + PR |
| 14:10–14:35 | Hur blir det här ett riktigt system | Whiteboard |
| 14:35–15:00 | Vad du behöver lära dig härnäst | Whiteboard + sista commit |

Om något drar över: korta ned 14:10-passet och håll 11:30 och 13:35 orörda. De två är dagen.

---

## 09:00–09:20 — Vad är BI egentligen

Ingen dator uppe. Rita på tavlan:

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

Sätt scenariot:

> "BuildCo har tolv projekt igång. VD vill veta vilka som går över budget, varför, och hur prognosen ser ut."

Ställ frågorna och låt honom svara. Han kan verksamheten bättre än han tror, och det är hela poängen med att börja här:

- Var finns informationen idag?
- Vem matar in den, och när?
- Vad betyder "kostnad"? Är en beställd men ej levererad materialleverans en kostnad?
- Vad betyder "projekt"? Räknas en tilläggsbeställning som samma projekt?
- När blir en kostnad en kostnad — vid beställning, leverans, fakturadatum eller bokföringsdatum?
- Hur vet vi att siffran stämmer?

Håll det kort. Tjugo minuter, sedan vidare.

Det här passet finns för att visa att BI börjar i verksamheten. Nio av tio gånger när en rapport visar fel siffra ligger orsaken i något av svaren ovan, inte i DAX.

---

## 09:20–09:50 — Repot och Git

**Mål:** han har ett repo på GitHub med struktur och en första commit.

Han gör det själv i terminalen, du läser inte upp kommandona utan skriver dem på tavlan och låter honom skriva av.

```bash
mkdir buildco-bi && cd buildco-bi
git init
```

Sedan strukturen. Låt honom skapa mapparna manuellt, det tar två minuter och han kommer ihåg dem bättre:

```
buildco-bi/
├── README.md
├── docs/
├── data/raw/          <- CSV-filerna
├── data/processed/
├── sql/
├── model/
├── powerbi/
└── exercises/
```

```bash
git add .
git commit -m "Initial project setup"
git branch -M main
git remote add origin git@github.com:<han>/buildco-bi.git
git push -u origin main
```

Fyra begrepp, inget mer: **working directory → staging area → commit → remote**. Rita det:

```
filer på disk  --git add-->  staged  --git commit-->  historik  --git push-->  GitHub
```

Låt honom köra `git status` mellan varje steg. Det är där det klickar.

Om `.gitignore` inte finns, skapa den nu:

```
*.pbix
*.csv.bak
.DS_Store
```

`.pbix`-filer är binära och blir tunga i Git. Nämn att Power BI-filer sällan versionshanteras som kod, och att det är en av anledningarna till att branschen rör sig mot textbaserade format som TMDL.

**Commit:** `Initial project setup`

---

## 09:50–10:30 — Rådata och SQL

**Mål:** han skriver egna frågor mot riktiga tabeller och läser svaret kritiskt.

Ny branch först:

```bash
git checkout -b feature/sql-exploration
```

Ladda datan (`sql/00_setup_postgres.sql`) och börja bredast möjligt:

```sql
SELECT * FROM projects;
SELECT * FROM invoices LIMIT 20;
SELECT * FROM timesheets LIMIT 20;
```

Fråga direkt: **"Vad är en rad här?"** Ställ frågan för varje tabell. Han kommer svara fel på `timesheets` första gången, vilket är bra.

Gå igenom i den här ordningen och låt honom skriva varje fråga själv:

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

Sju koncept räcker: `SELECT`, `WHERE`, `GROUP BY`, `SUM`, `COUNT`, `JOIN`, alias. Inte fyrtio.

Låt honom lösa uppgifterna i `exercises/01_sql.md` och spara frågorna i `sql/01_exploration.sql`.

Två saker att peta på när de dyker upp:

- När han skriver `SELECT project_name, sum(amount) ... GROUP BY project_id` och Postgres klagar — förklara varför istället för att bara rätta. Allt i SELECT som inte är aggregerat måste finnas i GROUP BY.
- När han joinar `projects` mot `customers` och får 12 rader: fråga varför det inte blev fler. Svaret (varje projekt har exakt en kund) är förberedelsen för nästa pass.

**Commit:** `Add SQL exploration queries`

---

## 10:30–10:45 — Fika

Ingen SQL vid fikabordet.

---

## 10:45–11:30 — Datamodell och grain

**Mål:** han kan skilja på fact och dimension och kan svara på vad en rad representerar.

```bash
git checkout main && git merge feature/sql-exploration
git checkout -b feature/data-model
```

Rita stjärnschemat på tavlan:

```
              dim_customer
                    │
 dim_date ──── fact_invoice ──── dim_project
                    │
              dim_employee
```

**Fact** = något som hände. Faktura skickad, kostnad bokförd, timme rapporterad.
**Dimension** = det du vill dela upp händelsen efter. Kund, projekt, datum, anställd.

Enkelt test han kan använda i verkligheten: kan du summera kolumnen och få något meningsfullt? Då är det troligen ett mått i en fact. Vill du filtrera eller gruppera på den? Då är den en dimension.

Sedan grain. Ställ frågan rakt av:

> "Vad representerar EN rad i `project_costs`? Och i `timesheets`?"

Låt honom kolla själv:

```sql
SELECT project_id, employee_id, work_date, count(*)
FROM timesheets
GROUP BY project_id, employee_id, work_date
HAVING count(*) > 1;
```

Noll rader betyder att grain är *en anställd, en dag, ett projekt*. Det svaret har han nu bevisat istället för gissat.

Gör samma sak på `invoices` och `project_costs`.

Rita sedan upp den centrala fällan innan den drabbar honom:

```
projects (12 rader)
   ├── invoices        (45 rader)
   ├── project_costs  (162 rader)
   └── timesheets   (1 271 rader)
```

Fråga: "Vad händer om jag joinar alla tre på `project_id` i en och samma fråga?" Låt honom gissa, kör sedan:

```sql
SELECT count(*)
FROM projects p
JOIN invoices i ON i.project_id = p.project_id
JOIN project_costs c ON c.project_id = p.project_id;
```

Resultatet blir orimligt stort. Varje faktura paras ihop med varje kostnad på samma projekt. Det är fan-out, och det är samma mekanism som sänker honom i nästa pass — bara med historik som orsak istället för tre fakta i samma fråga.

Regeln han ska ta med sig: **aggregera varje fact för sig, joina sedan ihop resultaten.**

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

Låt honom rita sin modell i `model/data_model.md`. Handritad och fotad duger, men ASCII i filen är bättre eftersom den då hamnar i Git.

**Commit:** `Add first draft of data model`

---

## 11:30–12:15 — Ida och SCD2

**Dagens viktigaste pass.** Ta hela tiden, korta hellre något efter lunch.

```bash
git checkout -b feature/scd2
```

Berätta historien först, utan kod:

> "Kunden C103 har kontaktpersonen Ida Andersson. Första juni 2026 gifter hon sig och heter Ida Svensson. Affärssystemet uppdaterar raden. Nästa dag ringer en säljare och undrar varför försäljningen till Ida Andersson försvann från förra årets rapport."

Visa vad som händer i källsystemet:

```sql
SELECT * FROM customers WHERE customer_id = 'C103';
```

Här står bara Ida Svensson. Historiken är överskriven. Om ingen sparar den går den inte att få tillbaka.

Visa sedan hur datalagret löser det:

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

Två begrepp här, och de är lätta att blanda ihop:

- **Business key** — `customer_id`. Kommer från källsystemet, identifierar kunden.
- **Surrogate key** — `customer_sk`. Sätts av datalagret, identifierar *en version av* kunden.

Låt honom nu göra fel med flit:

```sql
SELECT i.invoice_id, i.invoice_date, d.contact_name, i.amount
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id
WHERE i.customer_id = 'C103'
ORDER BY i.invoice_date;
```

Åtta fakturor blir sexton rader. Varje faktura kopplas mot båda versionerna av Ida. Summan går från 4 625 000 till 9 250 000.

Kör samma sak på hela datamängden och låt honom se skadan:

```sql
SELECT count(*) AS rader, sum(i.amount) AS summa
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id;
```

45 rader blir 64. 34 135 900 blir 44 693 300. Ingen kolumn ser konstig ut, ingen felkod dyker upp, rapporten går att publicera. Det är därför den här sortens fel överlever ända fram till ledningsgruppen.

Sedan rätt version:

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

Nu står fakturorna från 2025 och april 2026 på Ida Andersson, och juli 2026 på Ida Svensson. Åtta rader, 4 625 000 kr.

Diskutera den där `COALESCE`-detaljen. `valid_to` är null för den aktuella versionen, och ett datumjämförelse mot null blir aldrig sant. Många datalager använder därför `9999-12-31` istället för null. Båda varianterna finns i verkligheten och han kommer att stöta på båda.

Poängen han ska formulera själv innan ni går till lunch: *i ett riktigt datalager joinar man inte fakta mot dimensioner på business key, utan på surrogatnyckeln som redan pekar på rätt version.* SCD2-joinen med datumvillkor är hur man sätter den nyckeln från början.

Uppgifterna finns i `exercises/03_scd_type2.md`. Låt honom spara sina frågor i `sql/02_joins.sql`.

**Commit:** `Add SCD type 2 join with validity window`

---

## 12:15–12:45 — Lunch

Prata om jobbet, inte tekniken.

Berätta vad du faktiskt gör en vanlig vecka. SQL, Power BI, dbt, Git, Azure, möten, kravdiskussioner, felsökning, PR-granskning, tester, modellering. Var ärlig med proportionerna.

En stor del av BI-arbetet är att svara på frågan "varför är den här siffran fel?". Det står inte i någon LinkedIn-profil, men det är sant, och han kommer att märka det redan om en timme.

Nämn också att verksamhetskunskap är den delen som tar längst tid att bygga upp och som han redan har. SQL kan man lära sig på tre månader. Att veta varför en projektledare bokför en kostnad i fel period tar tre år.

---

## 12:45–13:35 — Power BI och DAX

**Mål:** han ser hela kedjan SQL → modell → mått → visual.

```bash
git checkout main && git merge feature/scd2
git checkout -b feature/powerbi
```

Bygg vyerna i Postgres först (`sql/03_validation.sql` innehåller skelettet):

```sql
CREATE OR REPLACE VIEW vw_fact_invoice AS
SELECT invoice_id, project_id, customer_id, invoice_date, amount, invoice_type
FROM invoices;

CREATE OR REPLACE VIEW vw_dim_project AS
SELECT project_id, project_name, customer_id, city, project_type, status, budget_amount
FROM projects;
```

Importera vyerna till Power BI Desktop. Modellvyn först, innan något visuellt byggs. Låt honom dra relationerna själv och peka på riktningen och kardinaliteten (1:n, enkelriktad). Det är samma stjärnschema han ritade före lunch, nu med musen.

Skapa en datumtabell — det är det första man gör i varje Power BI-modell:

```dax
dim_date =
CALENDAR ( DATE ( 2025, 1, 1 ), DATE ( 2026, 12, 31 ) )
```

Markera den som datumtabell och koppla den till `invoice_date`.

Sedan tre mått. Skriv dem tillsammans och förklara `DIVIDE` istället för `/`:

```dax
Fakturerat = SUM ( vw_fact_invoice[amount] )

Antal fakturor = DISTINCTCOUNT ( vw_fact_invoice[invoice_id] )

Snittfaktura = DIVIDE ( [Fakturerat], [Antal fakturor] )
```

Låt honom bygga fyra visuals:

1. Kort: total fakturering
2. Stapel: fakturering per projekt
3. Linje: fakturering per månad
4. Tabell: projekt, budget, fakturerat

Sedan det viktigaste momentet i passet: låt honom klicka på en stapel och se att alla andra visuals filtreras. Fråga varför det fungerar. Svaret är relationerna i modellen, inte visualen. Ett mått i Power BI räknas om i den filterkontext det hamnar i, och den kontexten kommer från modellen.

```
SQL  →  modell  →  DAX  →  visual
```

Om han har tid: lägg till `Budget = SUM ( vw_dim_project[budget_amount] )` och låt honom upptäcka att budget inte kan brytas ned per månad. Budget saknar datum. Det är en helt vanlig och nyttig insikt.

Spara som `powerbi/buildco.pbix`. Den ligger i `.gitignore`, så låt honom istället dokumentera måtten i `powerbi/README.md`.

**Commit:** `Document Power BI measures and model setup`

---

## 13:35–14:10 — "Rapporten är fel"

**Mål:** han felsöker en avvikelse på riktigt, hittar orsaken och rättar den via en pull request.

Ge honom rollen rakt av, utan förvarning:

> "Du är BI-utvecklare på BuildCo. Ekonomichefen ringer. Din rapport visar att projekt P-1004 har kostat 9 235 860 kr, alltså 44 % över budget. Ekonomisystemet säger 7 551 990 kr. Platschefen är förbannad. Vad är fel?"

Säg inte vad felet är. Låt honom leta. Om han fastnar i mer än tio minuter, ge en ledtråd i taget i den här ordningen:

1. "Är det alla projekt eller bara ett?"
2. "Jämför antal rader, inte bara summan."
3. "Titta på verifikationsnumren."

Verktygen han behöver:

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

Svaret: tre kostnadsrader finns två gånger. Samma verifikat, samma datum, samma leverantör, samma belopp, olika `cost_id`. Importbunten för januari–februari 2026 kördes två gånger efter en misslyckad körning. 1 683 870 kr för mycket.

Låt honom skriva ett test som fångar felet i framtiden:

```sql
-- Ska returnera noll rader
SELECT voucher_no, cost_date, supplier, amount, count(*)
FROM project_costs
GROUP BY voucher_no, cost_date, supplier, amount
HAVING count(*) > 1;
```

Det där är i princip vad `dbt test` gör åt dig, vilket är en bra brygga till nästa pass.

Diskutera sedan var felet borde rättas, för det är den frågan en BI-utvecklare får varje vecka:

- I rapporten (`DISTINCT` i Power BI) — snabbast, döljer felet, sämst.
- I SQL-vyn — bättre, men alla andra som läser tabellen får fortfarande fel.
- I laddningen till datalagret — dedupliceringen görs en gång och gäller alla.
- I källsystemet — bäst, men tar tre veckor och kräver att någon annan prioriterar det.

I verkligheten gör man ofta två av dem samtidigt: rättar i laddningen nu och lägger ett ärende på källsystemet.

Rättningen:

```sql
CREATE OR REPLACE VIEW vw_fact_project_cost AS
SELECT DISTINCT ON (voucher_no, cost_date, supplier, amount)
       cost_id, project_id, cost_date, cost_type, supplier, amount, voucher_no
FROM project_costs
ORDER BY voucher_no, cost_date, supplier, amount, cost_id;
```

**Nu gör ni pull request-momentet i lugn och ro:**

```bash
git checkout -b fix/duplicate-cost-rows
# redigera sql/03_validation.sql
git add sql/03_validation.sql
git commit -m "Fix duplicated cost rows from re-run import batch"
git push -u origin fix/duplicate-cost-rows
```

Sedan på GitHub: öppna pull request, skriv en beskrivning som en riktig utvecklare hade skrivit (vad var fel, hur upptäcktes det, hur är det rättat, hur vet vi att det inte kommer tillbaka), och granska den tillsammans. Merga.

Låt honom sedan uppdatera i Power BI och se att siffran ändras till 7 551 990. Kedjan från felanmälan till rättad rapport är nu komplett, och han har gjort varje steg själv.

**Commit + PR:** `Fix duplicated cost rows from re-run import batch`

---

## 14:10–14:35 — Hur blir det här ett riktigt system

Rita hela kedjan igen, nu med verktygsnamn:

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

Peka på var han varit idag. Han har gjort staging (CSV → Postgres), transformation (vyerna), datalagerlogik (SCD2-joinen), semantisk modell (Power BI-modellen) och test (dubblettkontrollen). Verktygen är mindre, stegen är samma.

Sedan arbetsflödet, som han redan har provat:

```
feature branch → commit → push → pull request → granskning → test → merge → produktion
```

Nämn att i ett team med dbt körs testerna automatiskt när pull requesten öppnas. Om dubblettkontrollen misslyckas går ändringen inte att merga. Det är samma test han skrev för tjugo minuter sedan, bara automatiserat.

Berätta till sist att BI-roller ser olika ut och att han inte behöver välja idag:

- **Power BI-tung roll** — rapporter, DAX, nära verksamheten. Kortast väg in.
- **Data warehouse / SQL-tung roll** — modellering, laddningar, prestanda.
- **Analytics engineer** — dbt, SQL, modellering, mitt emellan de två ovan. Växer snabbast.

---

## 14:35–15:00 — Vad du behöver lära dig härnäst

Rita kartan:

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

Och hans väg, som börjar med det han redan kan:

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

Var tydlig med tre saker:

1. Han behöver lära sig **SQL, datamodellering och Power BI**. Inte trettioåtta tekniker.
2. Python, machine learning och statistik ligger senare. AI gör det lätt att trolla fram avancerad kod, och den som gör det innan han förstår datan lär sig trycka på knappar utan att förstå problemet.
3. Verksamhetskunskapen han redan har är den del som tar längst tid att bygga för andra.

Avsluta med repot. Låt honom skriva `README.md` färdig med egna ord:

> "Ett BI-projekt där jag modellerar projekt-, kostnads- och tidsdata från ett byggföretag. Innehåller SQL för utforskning och validering, en dimensionell modell med SCD type 2, och en Power BI-rapport."

Det är en mening han kan säga i en anställningsintervju, och den är sann.

**Sista commit:** `Update README with project description`

---

## Om något går fel under dagen

| Situation | Gör så här |
|---|---|
| Postgres krånglar vid start | Kör på DuckDB istället, `read_csv_auto` direkt mot CSV-filerna. Syntaxen är nästan identisk. |
| Power BI vägrar ansluta | Exportera vyerna till CSV och importera dem. Modelleringspoängen är densamma. |
| Han fastnar i SQL-syntax | Skriv frågan tillsammans en gång, låt honom skriva nästa själv. Blanda inte in AI-verktyg idag — han ska bygga upp känslan för vad frågan gör. |
| Ni ligger 30 min efter | Korta 14:10-passet till tio minuter och hoppa över datumtabellen i Power BI. |
| Ni ligger 30 min före | Ta utstickarna i datan: 38-timmarsraden, den föräldralösa timraden och kreditfakturan. Alla tre är riktiga BI-problem. |

---

## Efter dagen

Repot är kursen. Nästa steg som naturliga branches:

- `feature/dim-date` — bygg en riktig datumdimension i SQL istället för DAX
- `feature/margin-analysis` — lönsamhet per projekt, kund och projekttyp
- `feature/forecast` — prognos på pågående projekt baserat på upparbetad tid
- `feature/dbt-init` — flytta vyerna till dbt-modeller med tester

En commit per sak han lär sig. Om ett halvår har han en historik som visar exakt hur han utvecklats, och den är mer övertygande än vilket kursintyg som helst.
