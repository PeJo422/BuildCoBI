# Power BI — BuildCo

`.pbix` ligger i `.gitignore`. Dokumentera modellen här istället, så att den går
att bygga upp igen från repot.

## Datakälla

PostgreSQL, databas `buildco`. Importera vyerna, inte tabellerna:

- `vw_dim_project`
- `vw_fact_invoice`
- `vw_fact_project_cost`
- `vw_fact_timesheet`

Import framför DirectQuery så länge datamängden är den här lilla.

## Datumtabell

```dax
dim_date =
CALENDAR ( DATE ( 2025, 1, 1 ), DATE ( 2026, 12, 31 ) )
```

Markera som datumtabell och relatera till `vw_fact_invoice[invoice_date]`.
Utan en egen datumtabell fungerar ingen tidsjämförelse ordentligt.

## Relationer

| Från | Till | Kardinalitet | Riktning |
|---|---|---|---|
| `vw_fact_invoice[project_id]` | `vw_dim_project[project_id]` | många-till-en | enkel |
| `vw_fact_invoice[invoice_date]` | `dim_date[Date]` | många-till-en | enkel |
| `vw_fact_project_cost[project_id]` | `vw_dim_project[project_id]` | många-till-en | enkel |

Dubbelriktade relationer är frestande och nästan alltid fel så länge modellen är
ett rent stjärnschema.

## Mått

```dax
Fakturerat = SUM ( vw_fact_invoice[amount] )

Antal fakturor = DISTINCTCOUNT ( vw_fact_invoice[invoice_id] )

Snittfaktura = DIVIDE ( [Fakturerat], [Antal fakturor] )

Kostnad = SUM ( vw_fact_project_cost[amount] )

Budget = SUM ( vw_dim_project[budget_amount] )

Marginal = [Fakturerat] - [Kostnad]

Budgetavvikelse % = DIVIDE ( [Kostnad] - [Budget], [Budget] )
```

`DIVIDE` framför `/` eftersom division med noll annars ger fel i visualen.

## Kända begränsningar

- `Budget` saknar datum och kan inte brytas ned per månad.
- Pågående projekt jämförs mot hela budgeten, vilket får dem att se lönsamma ut.
- Kreditfakturan på P-1006 påverkar både antal fakturor och snittfaktura.

## Kontroll mot SQL

Innan rapporten visas för någon annan: kör samma summa i SQL och jämför.

```sql
SELECT sum(amount) FROM invoices;   -- ska matcha måttet Fakturerat
```
