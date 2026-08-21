# BuildCo BI

Ett BI-projekt byggt kring ett påhittat byggföretag. Projekt-, kostnads- och tidsdata
modelleras från rådata till en Power BI-rapport.

**Uppdraget från ledningen:**

> "Vi vill se vilka projekt som är lönsamma, vilka som går över budget och vad som
> driver avvikelserna."

## Innehåll

```
buildco-bi/
├── data/raw/          CSV-export från affärssystemet
├── data/processed/    mellansteg (ligger utanför Git)
├── sql/               laddning, utforskning, joins, validering
├── model/             datamodell och grain-dokumentation
├── powerbi/           mått, modellsetup, kända problem
├── exercises/         övningarna för dag 1
└── docs/              dagsplan och lärplan
```

## Kom igång

```bash
createdb buildco
psql -d buildco -f sql/00_setup_postgres.sql
```

Kontrollen sist i filen ska ge 45 fakturor, 162 kostnadsrader och 1 271 timrader.

## Källtabeller

| Tabell | Rader | En rad = |
|---|---|---|
| `customers` | 8 | en kund som den ser ut idag |
| `dim_customer_scd2` | 11 | en version av en kund, giltig under en period |
| `employees` | 10 | en anställd |
| `projects` | 12 | ett projekt med budget och status |
| `invoices` | 45 | en fakturarad mot ett projekt |
| `project_costs` | 162 | en kostnadspost med verifikationsnummer |
| `timesheets` | 1 271 | en anställd, en dag, ett projekt |

## Arbetssätt

En branch per sak, en commit per steg, pull request innan något hamnar i `main`.

```
feature branch → commit → push → pull request → granskning → merge
```
