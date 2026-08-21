# Facit — endast för dig som håller i dagen

Ta bort den här mappen ur repot innan du delar det, eller lägg den i en egen branch.

---

## Nyckeltal i datan

| Mått | Värde |
|---|---|
| Fakturerat netto (45 rader, kreditfakturan inräknad) | **34 135 900** |
| Fakturerat brutto (exkl. kreditfaktura) | 34 393 100 |
| Direkta kostnader i `project_costs` som filen ser ut | **29 479 080** |
| Direkta kostnader utan dubblettbunten | **27 795 210** |
| Arbetskostnad från `timesheets` | 5 871 025 |
| Total kostnad, korrekt | **33 666 235** |
| Total kostnad, med dubbletterna | 35 350 105 |
| Rapporterade timmar | 9 521 (varav 8 saknar projekt) |

---

## Projektöversikt (korrekt, dubbletterna borträknade)

| Projekt | Status | Budget | Fakturerat | Kostnad | Marginal | Avvikelse |
|---|---|---:|---:|---:|---:|---:|
| P-1001 | Avslutad | 4 200 000 | 4 200 000 | 3 948 015 | 251 985 | −6 % |
| P-1002 | Avslutad | 2 650 000 | 2 809 100 | 2 941 490 | −132 390 | **+11 %** |
| P-1003 | Avslutad | 3 800 000 | 3 800 000 | 3 344 010 | 455 990 | −12 % |
| P-1004 | Avslutad | 6 400 000 | 6 976 000 | 7 551 990 | −575 990 | **+18 %** |
| P-1005 | Avslutad | 2 950 000 | 2 950 000 | 2 861 510 | 88 490 | −3 % |
| P-1006 | Avslutad | 980 000 | 742 400 | 1 215 190 | −472 790 | **+24 %** |
| P-1007 | Avslutad | 5 100 000 | 5 100 000 | 4 641 000 | 459 000 | −9 % |
| P-1008 | Avslutad | 1 450 000 | 1 493 500 | 1 537 000 | −43 500 | +6 % |
| P-1009 | Avslutad | 3 100 000 | 3 099 900 | 2 883 000 | 216 900 | −7 % |
| P-1010 | Pågående | 2 200 000 | 990 000 | 923 970 | 66 030 | — |
| P-1011 | Pågående | 750 000 | 825 000 | 412 490 | 412 510 | — |
| P-1012 | Pågående | 4 600 000 | 1 150 000 | 1 406 570 | −256 570 | — |

De tre pågående projekten går inte att jämföra mot full budget. P-1011 har
dessutom fakturerat 825 000 mot en budget på 750 000, vilket är exakt den sortens
rad en ekonomichef ringer om. Bra att ha i bakfickan om det blir tid över.

Med dubbletterna inräknade visar P-1004 kostnaden **9 235 860**, alltså 44 % över
budget. Det är siffran du ger honom i felsökningspasset.

---

## Övning 1 — SQL

**Uppgift 2, radantal:** customers 8, dim_customer_scd2 11, employees 10,
projects 12, invoices 45, project_costs 162, timesheets 1 271.

**Uppgift 5, kostnad per typ:**

| cost_type | Rader | Belopp |
|---|---:|---:|
| Material | 36 | 16 666 760 |
| Underentreprenör | 35 | 7 782 660 |
| Maskinhyra | 46 | 2 779 510 |
| Övrigt | 45 | 2 250 150 |

**Uppgift 6, flest timmar:** Sara Lindqvist 1 794 h, Nina Öberg 1 168 h,
Kent Molin 1 167 h. Sara är platschef och finns på nästan alla projekt, vilket
är en rimlig förklaring — låt honom komma på den själv.

**Uppgift 11:** varje projekt har exakt en kund och `customer_id` är unik i
`customers`. En många-till-en-join ändrar inte antalet rader från den vänstra
sidan. Det är samma egenskap som saknas i SCD2-övningen efter lunch.

**Uppgift 12:** 1 271 mot 1 270. En timrad saknar `project_id` (T71271,
2026-03-05, utbildning felregistrerad som projekttid). En `INNER JOIN` kastar
den utan att säga något. Med `LEFT JOIN` finns den kvar med null-värden.

**Uppgift 13:** P-1002, P-1004, P-1008 och P-1011 har fakturerat mer än budget.
För P-1011 beror det på att projektet pågår och att förskottsfakturering skett.

---

## Övning 2 — Modellering

**Uppgift 2:** `projects` är en dimension trots att `budget_amount` går att
summera. Budget beskriver projektet, inte en händelse. Nyanserat svar: i större
modeller bryts budget ofta ut till en egen fact-tabell med datum, just för att
kunna följa budget över tid. Om han kommer dit själv, beröm honom.

**Uppgift 4:** noll rader. Grain i `timesheets` är en anställd, en dag, ett
projekt.

**Uppgift 5:** `invoices` har grain en fakturarad, unik på `invoice_id`.
`project_costs` har grain en kostnadspost, unik på `cost_id` — men *inte* unik på
verifikat, datum, leverantör och belopp, vilket är hela poängen i övning 4.

**Uppgift 6:** 593 rader. Varje faktura paras med varje kostnad på samma projekt.

**Uppgift 7:** P-1006 har 5 fakturor och 9 kostnadsrader. 5 × 9 = 45 rader för ett
projekt som har 14 relevanta rader.

**Uppgift 9:** `LEFT JOIN` ger fortfarande 12 rader eftersom alla projekt har både
fakturor och kostnader. Rätt val ändå — en ny post i `projects` som ännu inte har
kostnader ska synas i rapporten med noll, inte försvinna.

**Uppgift 11:** delade dimensioner kallas conformed dimensions. Två fakta som
båda hänger på samma `dim_project` går att jämföra mot varandra i samma rapport.
Det är hela idén med ett gemensamt datalager i stället för en modell per rapport.

**Uppgift 12:** filtrerar man på anställd påverkas timmar men inte fakturerat,
eftersom `fact_invoice` saknar relation till `dim_employee`. Måttet visar då
totalen för hela filtret, vilket ser ut som ett fel men är korrekt beteende.
Det här är den vanligaste supportfrågan en Power BI-utvecklare får.

---

## Övning 3 — SCD type 2

**Kunder med flera versioner:** C101 (flytt Mölndal → Göteborg 2025-09-01),
C103 (Ida Andersson → Ida Svensson 2026-06-01), C106 (segment Privat → Företag
2025-04-01).

**Uppgift 3–4, C103:** 8 fakturor blir 16 rader. Summan går från **4 625 000** till
**9 250 000**.

Med korrekt join:

| Faktura | Datum | Kontaktperson | Belopp |
|---|---|---|---:|
| F50009 | 2025-04-10 | Ida Andersson | 1 163 400 |
| F50010 | 2025-04-17 | Ida Andersson | 888 500 |
| F50011 | 2025-06-12 | Ida Andersson | 954 200 |
| F50012 | 2025-10-09 | Ida Andersson | 793 900 |
| F50044 | 2026-04-15 | Ida Andersson | 210 000 |
| F50039 | 2026-04-20 | Ida Andersson | 239 400 |
| F50045 | 2026-07-10 | Ida Svensson | 165 000 |
| F50040 | 2026-07-17 | Ida Svensson | 210 600 |

**Uppgift 5, hela datamängden:** 45 rader → **64 rader**, 34 135 900 →
**44 693 300**. Ingen felkod, inget varningsmeddelande, rapporten går att
publicera. Låt tystnaden sjunka in en stund.

**Uppgift 9:** `NULL > DATE '2026-01-01'` ger null, inte sant. Varje jämförelse mot
null blir null, och `WHERE null` filtrerar bort raden. Alla fakturor efter senaste
versionens start hade försvunnit.

**Uppgift 10:** `is_current = true` ger rätt antal rader och rätt total, men fel
etikett på historiska rader. Alla gamla fakturor hamnar på Ida Svensson.
Totalsumman stämmer, vilket är precis varför felet överlever så länge — den enda
som märker något är den som letar efter Ida Andersson och inte hittar henne.

**Uppgift 12:** ingen teknisk lösning avgör detta. Vill verksamheten se
historiken som den var (type 2) eller som den är idag (type 1)? Många dimensioner
har båda: `segment_current` och `segment_historical` sida vid sida.

**Uppgift 13:** joinen görs en gång vid laddning i stället för i varje fråga.
Fact-raden får `customer_sk` och alla efterföljande joins blir vanliga
många-till-en-joins på en heltalsnyckel. Snabbare, och omöjligt att göra fel i.

---

## Övning 4 — Felsökning

**Felet:** tre kostnadsrader på P-1004 finns två gånger.

| voucher_no | Datum | Leverantör | Belopp | cost_id |
|---|---|---|---:|---|
| V2026-0001 | 2026-02-02 | Ahlsell | 1 379 370 | K90043, K90160 |
| V2026-0002 | 2026-01-20 | Renova | 99 790 | K90051, K90161 |
| V2026-0003 | 2026-02-05 | Byggsäkerhet AB | 204 710 | K90052, K90162 |

Totalt **1 683 870 kr** för mycket. Bakgrundsberättelsen: importbunten för
januari–februari 2026 kördes om efter ett avbrott, och den första körningen
rullades aldrig tillbaka.

**Uppgift 2:** `count(*)` och `count(DISTINCT cost_id)` ger båda 162. Primärnyckeln
är unik — dubbletterna har olika `cost_id` eftersom de laddades som nya rader.
Det är den viktigaste insikten i hela övningen: en primärnyckel skyddar mot
tekniska dubbletter, inte mot att samma verklighet laddas in två gånger.

**Uppgift 6:** vettigt svar är att rätta i laddningen och lägga ett ärende på
källsystemet. Om styrelsemötet är om två timmar rättar man i vyn och skriver upp
skulden. Om han svarar "DISTINCT i Power BI", fråga vad som händer med
ekonomiavdelningens egen Excel-export som läser samma tabell.

**Uppgift 8:** direkta kostnader går från 29 479 080 till **27 795 210**. P-1004
går från 9 235 860 till **7 551 990**, alltså från +44 % till +18 % mot budget.

**Uppgift 10:** T71270, P-1007, 2026-02-11, 38 timmar på en dag. Troligen en vecka
inrapporterad på ett datum. Effekt: 19 380 kr fel arbetskostnad, och alla
analyser per dag blir missvisande.

**Uppgift 11:** T71271, 8 timmar utbildning utan projekt. Försvinner tyst vid
`INNER JOIN`. Timmarna finns i lönesystemet men syns inte i projektuppföljningen.

**Uppgift 12:** F50043 på P-1006, −257 200 kr, kreditfaktura. Den som filtrerar
`amount > 0` får 34 393 100 i stället för 34 135 900. Rätt hantering beror på
vad verksamheten menar med omsättning — netto är oftast rätt, men periodiseringen
är en verklig fråga eftersom kreditfakturan är daterad 2026-02-10 och avser en
faktura från 2025.

**Uppgift 13:** pågående projekt har hunnit dra en del av kostnaden men jämförs mot
hela budgeten. Lösningen är antingen att filtrera bort dem, eller att jämföra mot
upparbetad andel (nedlagd tid eller nedlagd kostnad i förhållande till kalkyl).
Det senare är riktig byggekonomi och kräver att verksamheten definierar färdig­
ställandegrad. Bra fråga att lämna öppen — den är öppen i verkligheten också.

---

## Om han går snabbare än planerat

- Bygg `fact_timesheet` med arbetskostnad: `hours * hourly_cost` kräver join mot
  `employees`. Fråga sedan vad som händer när en anställd får ny timkostnad —
  och han har återuppfunnit behovet av SCD2 på egen hand.
- Räkna täckningsgrad per projekttyp: `Ombyggnad`, `Renovering`, `Nyproduktion`.
- Beräkna beläggning per anställd och månad.
- Lägg till `dim_date` i SQL i stället för DAX, med år, kvartal, månad och
  veckonummer.
