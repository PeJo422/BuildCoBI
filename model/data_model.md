# Datamodell — BuildCo BI

Byggd i `powerbi/Project invoices.pbip` (semantisk modell i TMDL + PBIR-rapport).

## Grain

| Tabell | En rad representerar | Hur jag vet det |
|---|---|---|
| `invoices` | En fakturarad (del-/slutfaktura eller kreditfaktura) | `invoice_id` unikt |
| `project_costs` | En bokförd kostnadspost (verifikat). Grain = `voucher_no, cost_date, supplier, amount` — `cost_id` skyddar **inte** mot dubbletter | importbatchen kördes två gånger på P-1004 |
| `timesheets` | En rapporterad tidspost: en anställd, ett projekt, en dag, en aktivitet | `timesheet_id` unikt; 1 rad saknar projekt (T71271) |
| `projects` | Ett projekt | entitet, inte händelse → dimension |
| `employees` | En anställd | entitet → dimension |
| `dim_customer_scd2` | **En kundversion** (SCD type 2), identifierad av `customer_sk` | två rader för C101/C103/C106 |

## Stjärnschema

```
              dim_customer_scd2 ─────────┐
              (customer_sk)              │
                    ▲  ▲  ▲              │
   dim_date ─── invoices  project_costs  timesheets ─── employees
   (Date)         │           │            │  ▲          (employee_id)
                  └───── projects ──────────┘  │
                        (project_id)      (employee_id)
```

- **Alla tre faktatabeller bär `customer_sk`**, satt i Power Query vid laddning genom en
  point-in-time-join mot `dim_customer_scd2` (`invoice_date` / `cost_date` / `work_date`
  mellan `valid_from` och `valid_to`). `project_costs` och `timesheets` slår först upp
  `customer_id` från `projects` via `project_id`.
- `dim_customer_scd2` är **enda** kunddimensionen. Den tidigare `customers`-tabellen är
  borttagen.
- `projects` bär denormaliserade `customer_name` + `segment` (aktuell version) så att
  Budget/Fakturerat/Kostnad/Timmar kan brytas per kund/segment. `projects` har **ingen**
  egen relation till `dim_customer_scd2` (skulle ge tvetydig filterväg).
- 10 relationer, alla många-till-en, enkelriktade. Inga auto-datumtabeller.

## Fact-tabeller

| Fact | Grain | Nycklar | Mått |
|---|---|---|---|
| `invoices` | fakturarad | project_id, customer_sk, invoice_date | Fakturerat, Antal fakturor, Snittfaktura |
| `project_costs` | verifikat (deduplicerat i PQ) | project_id, customer_sk, cost_date | Kostnad |
| `timesheets` | tidspost | project_id, employee_id, customer_sk, work_date | Timmar, Personalkostnad, Fakturerbart värde |

## Dimensioner

| Dimension | Nyckel | Historik |
|---|---|---|
| `dim_customer_scd2` | `customer_sk` (surrogat) | SCD type 2, `valid_from`/`valid_to` |
| `projects` | `project_id` | Nej (+ denormaliserad aktuell kund) |
| `employees` | `employee_id` | Nej |
| `dim_date` | `Date` | — (`CALENDAR(2025-01-01, 2026-12-31)`) |

## SCD type 2 — kopplingen sker vid laddning

`dim_customer_scd2` har en rad per kundversion. Kopplingen till fact-raden görs **en gång**,
i Power Query:

```m
Table.AddColumn(föregående, "customer_sk", (rad) =>
    let Träffar = Table.SelectRows(dim_customer_scd2, (d) =>
            d[customer_id] = rad[customer_id]
        and rad[<datum>] >= d[valid_from]
        and (d[valid_to] = null or rad[<datum>] <= d[valid_to]))
    in try Träffar{0}[customer_sk] otherwise null)
```

Kunder med flera versioner: **C101** (stad Mölndal→Göteborg, 2025-09-01), **C103** (kontakt
Ida Andersson→Ida Svensson, 2026-06-01), **C106** (segment Privat→Företag, 2025-04-01).
"Privat" finns bara i historiken.

## Mått (`_Mått`)

```dax
Fakturerat        = SUM ( invoices[amount] )
Antal fakturor    = DISTINCTCOUNT ( invoices[invoice_id] )
Snittfaktura      = DIVIDE ( [Fakturerat], [Antal fakturor] )
Kostnad           = SUM ( project_costs[amount] )                    -- materiel/UE/maskiner
Budget            = SUM ( projects[budget_amount] )
Marginal          = [Fakturerat] - [Kostnad]
Budgetavvikelse % = DIVIDE ( [Kostnad] - [Budget], [Budget] )

Timmar             = SUM ( timesheets[hours] )
Personalkostnad    = SUMX ( timesheets, timesheets[hours] * RELATED ( employees[hourly_cost] ) )
Fakturerbart värde = SUMX ( timesheets, timesheets[hours] * RELATED ( employees[hourly_rate] ) )
Fakturerbara timmar= CALCULATE ( SUM ( timesheets[hours] ), timesheets[is_billable] = TRUE () )
Beläggningsgrad    = DIVIDE ( [Fakturerbara timmar], [Timmar] )
Total kostnad      = [Kostnad] + [Personalkostnad]
Total marginal     = [Fakturerat] - [Total kostnad]

Fakturerat (endast aktuell kundversion) = CALCULATE ( [Fakturerat], dim_customer_scd2[is_current] = TRUE () )
Antal kostnadsrader    = COUNTROWS ( project_costs )
Antal unika kostnads-id = DISTINCTCOUNT ( project_costs[cost_id] )
```

`Kostnad` / `Marginal` hålls medvetet till `project_costs` (matchar övning 4). Personalkostnad
visas separat via `Total kostnad` / `Total marginal`.

## Städning i Power Query

- `project_costs[amount]` var **text** → tal (`"en-US"`-kultur på `Table.TransformColumnTypes`,
  eftersom modellkulturen `sv-SE` annars tolkar `.` som tusental).
- Dubbletter i `project_costs` tas bort (`Table.Distinct` på verifikatnyckeln). Var felet i
  övning 4: P-1004 låg +44 % över budget pga att importbatchen kördes två gånger (1 683 870 kr).
- `invoices[invoice_date]` var text → datum.
- 7 automatiska lokala datumtabeller borttagna; auto-datum/tid av (`__PBI_TimeIntelligenceEnabled = 0`).

## Rapport (mörkt tema `BuildCoDark`, nav-panel till vänster)

| Sida | Svarar på | Övningar |
|---|---|---|
| **Projektekonomi** | Budget/fakturerat/kostnad/marginal per projekt; budgetavvikelse; kostnad per kostnadstyp; projektledarbudget | 1 (Q4/Q5/Q9/Q13), 2 (Q8), 4 (Q13) |
| **Utveckling över tid** | Fakturerat + kostnad per månad/kvartal; Budget saknar datum | 1 (Q7) |
| **Kund & segment** | Fakturerat per kund/segment/projekttyp; historiktabell fakturarad→kundversion; korrekt SCD2 vs "endast aktuell" | 1 (Q3), 3 (Q3/Q6/Q10/Q11) |
| **Anställda & tid** | Timmar per anställd/roll/avdelning; beläggningsgrad; personalkostnad per projekt; "fakturerat per roll"-fällan | 1 (Q6/Q10), 2 (Q12) |
| **Datakvalitet** | Dubbla kostnadsrader; timrader >12h; timmar utan projekt; kreditfaktura (negativt belopp) | 1 (Q12), 4 (Q1/Q4/Q10/Q11/Q12) |

## Kända begränsningar

- `Budget` saknar datum → kan inte brytas ned per månad.
- Pågående projekt (P-1010/1011/1012) jämförs mot hela budgeten och ser lönsamma ut.
- Kreditfakturan F50043 på P-1006 (−257 200) påverkar omsättning och snittfaktura.

## Öppna frågor till verksamheten

- Räknas en kreditfaktura in i omsättningen för perioden den avser eller den period den ställdes ut?
- Ska pågående projekt jämföras mot hela budgeten eller mot upparbetad andel?
- Vad gör vi med timmar som saknar projekt? (T71271)
