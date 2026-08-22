# Resurser

En karta över var du lär dig vad, i ungefär den ordning det är vettigt att ta sig igenom dem.
Du behöver inte kunna allt innan du går vidare — dataområdet är för stort för den strategin.

---

## Förstå landskapet

**Microsoft Learn — Azure Data Fundamentals (DP-900)**
https://learn.microsoft.com/en-us/training/courses/dp-900t00

Microsofts introduktionskurs till datakoncept. Gratis, tar 1–2 dagar att gå igenom.
Täcker OLTP vs OLAP, relationella databaser, data warehouse, data lakes och grundläggande molndata.
Bra startpunkt för att få ett gemensamt språk med folk i branschen, och DP-900 är en certifiering du kan ta som ett tidigt kvitto på grundkunskaper.

**Fivetran — What is the Modern Data Stack?**
https://www.fivetran.com/blog/what-is-the-modern-data-stack

Förklarar hur de olika kategorierna i en modern dataplattform hänger ihop: ingestion, storage, transformation, orchestration, BI. Läs den när du undrar var ett nytt verktyg hör hemma.

**dbt Labs — What is Analytics Engineering?**
https://www.getdbt.com/blog/what-is-analytics-engineering

Förklarar rollen som finns mellan data engineering och BI — den rollen du troligen siktar mot.

---

## SQL

**SQLBolt**
https://sqlbolt.com

Kortaste vägen till fungerande SQL. Interaktiva lektioner med direkt feedback, bra som allra första praktiska träning.
Täcker SELECT, WHERE, JOIN, GROUP BY, HAVING, subqueries.

**SQLZoo**
https://sqlzoo.net

Interaktiv träning med fler uppgifter och mer variation än SQLBolt. Kör den parallellt eller direkt efter.
Täcker aggregationer, window functions och mer komplexa joins.

**Mode SQL Tutorial**
https://mode.com/sql-tutorial

SQL med fokus på dataanalys. Tar dig längre än grunderna: fönsterfunktioner, CTE, analytiska frågeställningar.
Läs den när grunderna sitter och du vill skriva frågor som faktiskt löser affärsproblem.

**pgexercises.com**
https://pgexercises.com

PostgreSQL-specifika övningar, från enkla selects till avancerade joins och aggregeringar.
Samma databasmotor du använde i workshopen.

---

## Datamodellering

**Kimball Group — Data Warehouse & BI Resources**
https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/

Originalresurserna från Ralph Kimball, mannen som definierade stjärnschema, fact, dimension och grain.
Lite daterade i stilen men fortfarande den auktoritativa källan. Artikeln om SCD är den du läst i praktiken.

**Kimball Group — Slowly Changing Dimensions**
https://www.kimballgroup.com/2008/09/slowly-changing-dimensions/

Originalartikeln om SCD type 1, 2 och 3. Det du jobbade med i workshopen, förklarat av den som uppfann begreppen.

**dbt Labs — Dimensional Modeling**
https://www.getdbt.com/blog/dimensional-modeling

Modernare introduktion till Kimballs principer med exempel från hur det ser ut i ett dbt-projekt.

---

## Data Engineering

**Microsoft Learn — Data Engineer Career Path**
https://learn.microsoft.com/en-us/training/career-paths/data-engineer

Karta över data engineer-rollen och vilka färdigheter som krävs. Bra för att förstå var BI-rollen slutar och data engineering börjar.

**dbt Labs — Data Engineering Best Practices**
https://www.getdbt.com/blog/data-engineering

Praktiska principer för att bygga pipelines som håller: idempotency, inkrementella laddningar, felhantering, monitoring.

---

## dbt

**dbt Learn — officiell kurs**
https://learn.getdbt.com/catalog

Gratis kurser från dbt Labs. Börja med dbt Fundamentals (ca 5 timmar).
Täcker sources, staging, marts, `ref()`, tester och dokumentation. Gör den efter att SQL sitter.

**dbt Developer Hub**
https://docs.getdbt.com

Den officiella dbt-dokumentationen. Används som referens när du bygger riktiga dbt-projekt.
Bra ordnat, lätt att söka i.

**dbt Data Tests**
https://docs.getdbt.com/docs/build/data-tests

Specifikt om hur tester fungerar i dbt. Läs den i samband med Modul 5 i fortsatt-plan.md.

---

## Power BI och DAX

**Microsoft Learn — Power BI**
https://learn.microsoft.com/en-us/training/powerplatform/power-bi

Microsofts egna kurser, gratis. Börja med Power BI Desktop-spåret.
Täcker Power Query, datamodeller, relationer, DAX, mått och rapportdesign.

**DAX Guide**
https://dax.guide

Komplett referens för alla DAX-funktioner med exempel och förklaringar.
Bra att söka i när du fastnar på en specifik funktion.

**SQLBI — DAX Patterns**
https://www.daxpatterns.com

Samling av återkommande mönster i DAX: YTD, rankningar, rörliga medelvärden, budgetjämförelser.
Läs när grunderna i DAX sitter och du vill lösa verkliga rapportproblem.

**SQLBI — YouTube**
https://www.youtube.com/@SQLBI

Alberto Ferrari och Marco Russo förklarar datamodellering och DAX bättre än de flesta.
Gratis, hög kvalitet. Börja med "Introducing DAX"-serien.

---

## Python

**Python Official Tutorial**
https://docs.python.org/3/tutorial

Den officiella tutorialen. Torr men korrekt. Bra referens att ha som bokmärke.

**DataCamp**
https://www.datacamp.com

Brett utbildningsbibliotek med interaktiva kurser inom SQL, Python, data analytics och data engineering.
Kostar pengar men är välstrukturerat och praktiskt. Bra om du lär dig bäst med guidad övning.
Fokusera på: Python fundamentals, pandas, och SQL-kurserna om du inte redan kan dem.

**Kaggle**
https://www.kaggle.com

Gratis datasets, notebooks och tävlingar. Bra för att öva hela kedjan från rådata till analys på verkliga problem.
Börja med Kaggle Learn-kurserna, sedan öva på valfritt dataset.

---

## Git

**Pro Git**
https://git-scm.com/book/en/v2

Hela boken finns gratis online. Kapitel 1–3 täcker allt du behöver som ensam utvecklare.
Kapitel 5 är relevant när du jobbar i team.

**GitHub Skills**
https://skills.github.com

Interaktiva övningar för GitHub-workflow: branching, pull requests, code review.

**Learn Git Branching**
https://learngitbranching.js.org

Visualisering av vad som händer i Git när du branchar, mergar och rebasar.
Klicka dig igenom de första fem övningarna så förstår du merge och rebase på riktigt.

---

## Datakvalitet

**dbt Data Tests**
https://docs.getdbt.com/docs/build/data-tests

Hur du skriver och kör datakvalitetstester i dbt.

**Data Quality koncept att kunna:**
- Not null och uniqueness — grundskyddet
- Referential integrity — fakturan pekar på ett projekt som finns
- Accepted values — status är alltid Pågående eller Avslutad, aldrig något annat
- Freshness — datan är inte tre dagar gammal utan att någon märkt det
- Business rules — en timrad har max 12 timmar per dag

---

## Data Governance

**Microsoft Purview**
https://learn.microsoft.com/en-us/purview

Microsofts plattform för data governance, katalogisering och dataspårning.
Lär dig koncepten först (lineage, ägarskap, klassificering), sedan verktyget.

---

## Bra att prenumerera på

**Data Engineering Weekly**
https://dataengineeringweekly.com

Ett nyhetsbrev per vecka med en artikel om vad som händer i branschen. Lagom dos.

**Locally Optimistic**
https://locallyoptimistic.com

Blogg av analytics engineers och data-folk. Artiklar om karriär, verktyg och hur saker faktiskt fungerar — inte bara hur de ser ut i marknadsföringsmaterial.

---

## Begrepp du ska kunna förklara

Oavsett verktyg — om du kan förklara de här med egna ord är du på god väg:

| Begrepp | Varför det spelar roll |
|---|---|
| OLTP vs OLAP | Förklarar varför du inte kör rapporter mot produktionsdatabasen |
| ETL vs ELT | Avgör var transformationslogiken bor |
| Fact vs dimension | Grunden i all datamodellering |
| Grain | Det vanligaste källan till fel i en BI-rapport |
| Surrogate key vs business key | Varför SCD2 kräver en extra nyckel |
| SCD type 1, 2, 3 | Tre sätt att hantera att verkligheten förändras |
| Batch vs streaming | Skillnaden mellan nattlig rapport och realtidsövervakning |
| Full load vs incremental | Avgör hur lång tid en pipeline tar och hur mycket den kostar |
| Data lineage | Vet du varifrån en siffra i rapporten kommer? |
| Idempotency | Kan du köra samma pipeline två gånger utan att datan dubbleras? |

---

## Vad du siktar mot

```
Business question
   ↓
Källsystem
   ↓
Ingestion
   ↓
Storage
   ↓
Transformation
   ↓
Datamodell
   ↓
Datakvalitet
   ↓
Semantisk modell
   ↓
BI / analys
   ↓
Affärsbeslut
```

Det är den kedjan du jobbar med. Verktygen byts ut. Grundproblemen består.

