# Övning 3 — Historik och SCD type 2

**Tid:** 45 minuter
**Branch:** `feature/scd2`
**Spara i:** `sql/02_joins.sql`

Dagens viktigaste övning. Den handlar om ett fel som ser rätt ut hela vägen fram
till att någon jämför med ekonomisystemet.

## Bakgrund

Kunden C103, Svensk Villaservice AB, har kontaktpersonen Ida Andersson. Den
1 juni 2026 byter hon efternamn till Svensson. Affärssystemet skriver över raden.

1. Kolla vad källsystemet vet:

```sql
SELECT * FROM customers WHERE customer_id = 'C103';
```

Var tog Ida Andersson vägen? Om ingen sparade historiken — går den att få
tillbaka?

2. Kolla vad datalagret vet:

```sql
SELECT customer_sk, customer_id, contact_name, valid_from, valid_to, is_current
FROM dim_customer_scd2
WHERE customer_id = 'C103';
```

Två rader, samma `customer_id`, olika `customer_sk`.

- `customer_id` är **business key** och kommer från källsystemet.
- `customer_sk` är **surrogate key** och identifierar en version av kunden.

## Gör felet med flit

3. Joina fakturor mot dimensionen på enbart `customer_id`:

```sql
SELECT i.invoice_id, i.invoice_date, d.contact_name, i.amount
FROM invoices i
JOIN dim_customer_scd2 d ON d.customer_id = i.customer_id
WHERE i.customer_id = 'C103'
ORDER BY i.invoice_date;
```

Hur många fakturor har C103 egentligen? Hur många rader fick du?

4. Vad blir summan, och vad borde den vara?

```sql
SELECT sum(amount) FROM invoices WHERE customer_id = 'C103';
```

5. Kör samma felaktiga join på hela datamängden. Hur många rader och hur stor
   summa? Jämför med `SELECT count(*), sum(amount) FROM invoices;`.

6. Vilka kunder drabbas, och varför just de? Kolla:

```sql
SELECT customer_id, count(*) AS versioner
FROM dim_customer_scd2
GROUP BY customer_id
HAVING count(*) > 1;
```

## Gör det rätt

7. Lägg till datumvillkoret:

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

8. Kontrollera på hela datamängden: rader och summa ska nu matcha `invoices`
   exakt.

## Tänk efter

9. Varför behövs `COALESCE`? Testa vad som händer utan den:

```sql
SELECT NULL > DATE '2026-01-01';
```

10. Vad hade hänt om du i stället filtrerat på `is_current = true`? Testa. Vem
    hade fått fel siffra, och hade någon märkt det?

11. Fakturan F50044 är daterad 2026-04-15 och F50045 är daterad 2026-07-10.
    Vilken kontaktperson står på vilken efter den korrekta joinen? Är det rätt
    ur verksamhetens perspektiv?

12. En kund byter från segmentet `Privat` till `Företag`. Ska förra årets
    försäljning flytta med till det nya segmentet eller ligga kvar i det gamla?
    Det finns inget tekniskt rätt svar — det är en verksamhetsfråga, och den
    avgör hur dimensionen ska byggas.

13. I ett färdigt datalager gör man den här joinen en gång, vid laddning, och
    sparar `customer_sk` på fact-raden. Vad vinner man på det?

## Commit

```bash
git add sql/02_joins.sql
git commit -m "Add SCD type 2 join with validity window"
```
