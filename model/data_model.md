# Datamodell — BuildCo BI

Fyll i den här filen under dagen. Skriv grain innan du ritar relationer.

## Grain

| Tabell | En rad representerar | Hur jag vet det |
|---|---|---|
| `invoices` | | |
| `project_costs` | | |
| `timesheets` | | |
| `projects` | | |

Kontrollen som bevisar grain ser ut så här:

```sql
SELECT <kolumnerna du tror utgör grain>, count(*)
FROM <tabell>
GROUP BY <kolumnerna>
HAVING count(*) > 1;
```

Noll rader betyder att du gissade rätt.

## Stjärnschema

```
              dim_customer
                    │
 dim_date ──── fact_invoice ──── dim_project
                    │
              dim_employee
```

Rita in `fact_project_cost` och `fact_timesheet` själv. Fundera på vilka
dimensioner de delar med `fact_invoice`, och vilka de inte delar.

## Fact-tabeller

| Fact | Grain | Mått |
|---|---|---|
| `fact_invoice` | | |
| `fact_project_cost` | | |
| `fact_timesheet` | | |

## Dimensioner

| Dimension | Nyckel | Historik |
|---|---|---|
| `dim_project` | | |
| `dim_customer` | `customer_sk` | SCD type 2 |
| `dim_employee` | | |
| `dim_date` | | |

## Anteckningar om historik

`dim_customer` har två versioner av kund C101, C103 och C106. En faktura ska
kopplas till den version som gällde på fakturadatumet:

```sql
JOIN dim_customer_scd2 d
  ON d.customer_id = i.customer_id
 AND i.invoice_date >= d.valid_from
 AND i.invoice_date <  COALESCE(d.valid_to, DATE '9999-12-31') + 1
```

I ett färdigt datalager sker den här kopplingen en gång, när fact-raden laddas.
Fact-tabellen sparar `customer_sk` och rapporten joinar sedan på surrogatnyckeln.

## Öppna frågor till verksamheten

- Räknas en kreditfaktura in i omsättningen för perioden den avser eller den
  period den ställdes ut?
- Ska pågående projekt jämföras mot hela budgeten eller mot upparbetad andel?
- Vad gör vi med timmar som saknar projekt?
