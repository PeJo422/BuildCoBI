import csv, random, datetime as dt
from collections import defaultdict

random.seed(20260821)
OUT = "/home/claude/buildco-bi/data/raw/"

# ---------------- customers ----------------
# customer_id, customer_name, org_number, contact_name, city, segment, created_date
customers = [
    ("C101", "Nordvik Fastigheter AB",      "556213-4471", "Lars Nordvik",     "Göteborg", "Företag",  "2019-03-12"),
    ("C102", "Kommunfastigheter Väst",      "212000-1355", "Anna Bergqvist",   "Borås",    "Offentlig","2018-01-05"),
    ("C103", "Svensk Villaservice AB",      "556904-2213", "Ida Svensson",     "Kungsbacka","Företag", "2021-06-30"),
    ("C104", "Hallberg Industri AB",        "556117-8890", "Peter Hallberg",   "Trollhättan","Företag","2017-11-02"),
    ("C105", "BRF Ekliden",                 "769621-4402", "Marie Sjögren",    "Mölndal",  "Förening", "2022-02-14"),
    ("C106", "Karlssons Åkeri AB",          "556788-1120", "Jonas Karlsson",   "Alingsås", "Företag",  "2020-09-01"),
    ("C107", "Region Väst Fastighet",       "232100-0131", "Henrik Lund",      "Göteborg", "Offentlig","2016-04-20"),
    ("C108", "Almgren Handel AB",           "556344-9982", "Sofia Almgren",    "Partille", "Företag",  "2023-01-16"),
]

# ---------------- dim_customer SCD2 ----------------
# customer_sk, customer_id, customer_name, contact_name, city, segment, valid_from, valid_to, is_current
scd = [
    (1001, "C101", "Nordvik Fastigheter AB", "Lars Nordvik",   "Mölndal",    "Företag",  "2024-01-01", "2025-08-31", "false"),
    (1002, "C101", "Nordvik Fastigheter AB", "Lars Nordvik",   "Göteborg",   "Företag",  "2025-09-01", "",          "true"),
    (1003, "C102", "Kommunfastigheter Väst", "Anna Bergqvist", "Borås",      "Offentlig","2024-01-01", "",          "true"),
    (1004, "C103", "Svensk Villaservice AB", "Ida Andersson",  "Kungsbacka", "Företag",  "2024-01-01", "2026-05-31","false"),
    (1005, "C103", "Svensk Villaservice AB", "Ida Svensson",   "Kungsbacka", "Företag",  "2026-06-01", "",          "true"),
    (1006, "C104", "Hallberg Industri AB",   "Peter Hallberg", "Trollhättan","Företag",  "2024-01-01", "",          "true"),
    (1007, "C105", "BRF Ekliden",            "Marie Sjögren",  "Mölndal",    "Förening", "2024-01-01", "",          "true"),
    (1008, "C106", "Karlssons Åkeri AB",     "Jonas Karlsson", "Alingsås",   "Privat",   "2024-01-01", "2025-03-31","false"),
    (1009, "C106", "Karlssons Åkeri AB",     "Jonas Karlsson", "Alingsås",   "Företag",  "2025-04-01", "",          "true"),
    (1010, "C107", "Region Väst Fastighet",  "Henrik Lund",    "Göteborg",   "Offentlig","2024-01-01", "",          "true"),
    (1011, "C108", "Almgren Handel AB",      "Sofia Almgren",  "Partille",   "Företag",  "2024-01-01", "",          "true"),
]

# ---------------- employees ----------------
# employee_id, first_name, last_name, role, department, hourly_cost, hourly_rate, employment_start, is_active
employees = [
    ("E01","Marcus","Ek",        "Projektledare","Projekt",   720, 1150,"2018-08-13","true"),
    ("E02","Sara",  "Lindqvist", "Platschef",    "Produktion",680, 1050,"2019-02-04","true"),
    ("E03","Johan", "Persson",   "Snickare",     "Produktion",520,  845,"2017-05-22","true"),
    ("E04","Emil",  "Håkansson", "Snickare",     "Produktion",510,  845,"2021-09-06","true"),
    ("E05","Nina",  "Öberg",     "Elektriker",   "Installation",590, 975,"2020-03-16","true"),
    ("E06","Ali",   "Rahimi",    "Elektriker",   "Installation",575, 975,"2022-01-10","true"),
    ("E07","Tobias","Grahn",     "Kalkylator",   "Kalkyl",     640,  980,"2019-11-25","true"),
    ("E08","Lovisa","Berg",      "Snickare",     "Produktion", 505,  845,"2023-04-03","true"),
    ("E09","Kent",  "Molin",     "Maskinförare", "Produktion", 560,  920,"2016-06-01","false"),
    ("E10","Amanda","Ström",     "Projektledare","Projekt",    700, 1150,"2022-08-15","true"),
]
emp_cost = {e[0]: e[5] for e in employees}

# ---------------- projects ----------------
# project_id, project_name, customer_id, project_manager_id, city, project_type,
# start_date, end_date, budget_amount, status
projects = [
    ("P-1001","Kontorsombyggnad Lindholmen","C101","E01","Göteborg","Ombyggnad","2025-01-13","2025-06-27", 4200000,"Avslutad"),
    ("P-1002","Skolkök Sjöbo",              "C102","E10","Borås","Renovering","2025-02-03","2025-09-12", 2650000,"Avslutad"),
    ("P-1003","Villa Kolla Parkstad",       "C103","E01","Kungsbacka","Nyproduktion","2025-03-10","2025-11-28", 3800000,"Avslutad"),
    ("P-1004","Lagerhall Stallbacka",       "C104","E10","Trollhättan","Nyproduktion","2025-04-07","2026-02-27", 6400000,"Avslutad"),
    ("P-1005","Stambyte Ekliden hus A",     "C105","E01","Mölndal","Renovering","2025-05-05","2025-12-19", 2950000,"Avslutad"),
    ("P-1006","Fasadrenovering Alingsås",   "C106","E10","Alingsås","Renovering","2025-08-18","2026-01-30",  980000,"Avslutad"),
    ("P-1007","Vårdcentral Angered etapp 1","C107","E01","Göteborg","Ombyggnad","2025-09-01","2026-04-24", 5100000,"Avslutad"),
    ("P-1008","Butiksanpassning Partille",  "C108","E10","Partille","Ombyggnad","2025-10-06","2026-03-13", 1450000,"Avslutad"),
    ("P-1009","Stambyte Ekliden hus B",     "C105","E01","Mölndal","Renovering","2026-01-12","2026-06-26", 3100000,"Avslutad"),
    ("P-1010","Kontorsombyggnad etapp 2",   "C101","E10","Göteborg","Ombyggnad","2026-02-02","",          2200000,"Pågående"),
    ("P-1011","Garage Kungsbacka",          "C103","E01","Kungsbacka","Nyproduktion","2026-03-02","",      750000,"Pågående"),
    ("P-1012","Vårdcentral Angered etapp 2","C107","E10","Göteborg","Ombyggnad","2026-05-04","",         4600000,"Pågående"),
]

# hur mycket projektet faktiskt kostar i förhållande till budget
cost_factor = {
    "P-1001": 0.94, "P-1002": 1.11, "P-1003": 0.88, "P-1004": 1.18,
    "P-1005": 0.97, "P-1006": 1.24, "P-1007": 0.91, "P-1008": 1.06,
    "P-1009": 0.93, "P-1010": 0.42, "P-1011": 0.55, "P-1012": 0.21,
}
# hur mycket som fakturerats i förhållande till budget
invoice_factor = {
    "P-1001": 1.00, "P-1002": 1.06, "P-1003": 1.00, "P-1004": 1.09,
    "P-1005": 1.00, "P-1006": 1.02, "P-1007": 1.00, "P-1008": 1.03,
    "P-1009": 1.00, "P-1010": 0.45, "P-1011": 0.60, "P-1012": 0.25,
}

def d(s): return dt.date.fromisoformat(s)
TODAY = d("2026-08-21")

def workdays(start, end, n):
    days = []
    cur = start
    span = (end - start).days
    while len(days) < n:
        off = random.randint(0, max(span, 1))
        day = start + dt.timedelta(days=off)
        if day.weekday() < 5:
            days.append(day)
    return sorted(days)

# ---------------- timesheets ----------------
activities = ["Stomme","Inredning","El","Rivning","Projektledning","Kalkyl","Besiktning","Mark"]
role_activity = {
    "Projektledare": ["Projektledning","Besiktning"],
    "Platschef": ["Projektledning","Stomme","Besiktning"],
    "Snickare": ["Stomme","Inredning","Rivning"],
    "Elektriker": ["El"],
    "Kalkylator": ["Kalkyl"],
    "Maskinförare": ["Mark","Rivning"],
}
emp_role = {e[0]: e[3] for e in employees}

timesheets = []
ts_id = 70001
labor_cost = defaultdict(float)
for p in projects:
    pid, _, _, pm, _, _, sd, ed, budget, status = p
    start = d(sd)
    end = d(ed) if ed else TODAY
    n_rows = max(12, int(budget / 30000))
    crew = [pm, "E02"] + random.sample(["E03","E04","E05","E06","E08","E09","E07"], 3)
    seen = set()
    tries = 0
    picked = []
    while len(picked) < n_rows and tries < n_rows * 40:
        tries += 1
        day = start + dt.timedelta(days=random.randint(0, max((end-start).days, 1)))
        if day.weekday() >= 5:
            continue
        emp = random.choice(crew)
        if (day, emp) in seen:
            continue
        seen.add((day, emp))
        picked.append((day, emp))
    for day, emp in sorted(picked):
        act = random.choice(role_activity[emp_role[emp]])
        hours = random.choice([4, 6, 7, 8, 8, 8, 9, 10])
        billable = "false" if act in ("Kalkyl",) else "true"
        timesheets.append((f"T{ts_id}", pid, emp, day.isoformat(), hours, act, billable))
        labor_cost[pid] += hours * emp_cost[emp]
        ts_id += 1

# medveten datakvalitetsavvikelse: en rad med orimligt antal timmar
timesheets.append((f"T{ts_id}", "P-1007", "E03", "2026-02-11", 38, "Stomme", "true"))
labor_cost["P-1007"] += 38 * emp_cost["E03"]
ts_id += 1
# och en rad utan projekt (frånvaro felregistrerad på tid)
timesheets.append((f"T{ts_id}", "", "E08", "2026-03-05", 8, "Utbildning", "false"))
ts_id += 1

# ---------------- project_costs ----------------
suppliers = {
    "Material": ["Beijer Byggmaterial","Optimera","Woody Bygghandel","Ahlsell"],
    "Underentreprenör": ["VVS Väst AB","Golvteam Göteborg","Målericentrum AB","Plåtslageriet i Borås"],
    "Maskinhyra": ["Cramo","Ramirent","Hyrmaskiner Väst"],
    "Övrigt": ["Renova","Securitas","Byggsäkerhet AB"],
}
mix = [("Material",0.55),("Underentreprenör",0.28),("Maskinhyra",0.10),("Övrigt",0.07)]

costs = []
cost_id = 90001
voucher_seq = defaultdict(int)
direct_cost_actual = defaultdict(float)

def voucher(day):
    voucher_seq[day.year] += 1
    return f"V{day.year}-{voucher_seq[day.year]:04d}"

for p in projects:
    pid, _, _, _, _, _, sd, ed, budget, status = p
    start, end = d(sd), (d(ed) if ed else TODAY)
    target_total = budget * cost_factor[pid]
    direct_target = max(target_total - labor_cost[pid], budget * 0.15)
    for ctype, share in mix:
        amount_left = direct_target * share
        n = random.randint(2, 5)
        days = workdays(start, end, n)
        parts = [random.uniform(0.6, 1.4) for _ in range(n)]
        s = sum(parts)
        for i, day in enumerate(days):
            amt = round(amount_left * parts[i] / s, -1)
            costs.append((f"K{cost_id}", pid, day.isoformat(), ctype,
                          random.choice(suppliers[ctype]), amt, voucher(day), "false"))
            direct_cost_actual[pid] += amt
            cost_id += 1

# MEDVETET FEL: verifikatbunt V2026-xxxx för P-1004 laddad två gånger.
dupe_source = [c for c in costs if c[1] == "P-1004" and c[2] >= "2026-01-01"]
dupes = []
for c in dupe_source:
    dupes.append((f"K{cost_id}", c[1], c[2], c[3], c[4], c[5], c[6], "false"))
    direct_cost_actual[c[1]] += c[5]
    cost_id += 1
costs.extend(dupes)
costs.sort(key=lambda r: (r[2], r[0]))

# ---------------- invoices ----------------
invoices = []
inv_id = 50001
for p in projects:
    pid, _, cid, _, _, _, sd, ed, budget, status = p
    start, end = d(sd), (d(ed) if ed else TODAY)
    total = budget * invoice_factor[pid]
    n = 4 if status == "Avslutad" else 2
    parts = [random.uniform(0.8, 1.2) for _ in range(n)]
    s = sum(parts)
    days = workdays(start + dt.timedelta(days=20), end, n)
    for i, day in enumerate(days):
        amt = round(total * parts[i] / s, -2)
        due = day + dt.timedelta(days=30)
        st = "Betald" if due < TODAY - dt.timedelta(days=10) else "Obetald"
        invoices.append((f"F{inv_id}", pid, cid, day.isoformat(), due.isoformat(),
                         amt, st, "Delfaktura"))
        inv_id += 1

# kreditfaktura på P-1006 (felaktig delfaktura krediterad)
credit_target = [i for i in invoices if i[1] == "P-1006"][1]
invoices.append((f"F{inv_id}", "P-1006", "C106", "2026-02-10", "2026-03-12",
                 -round(credit_target[5], 2), "Betald", "Kreditfaktura"))
inv_id += 1
# faktura till C103 före och efter namnbytet 2026-06-01 (för SCD2-övningen)
invoices.append((f"F{inv_id}", "P-1011", "C103", "2026-04-15", "2026-05-15", 210000, "Betald", "Delfaktura"))
inv_id += 1
invoices.append((f"F{inv_id}", "P-1011", "C103", "2026-07-10", "2026-08-09", 165000, "Obetald", "Delfaktura"))
inv_id += 1
invoices.sort(key=lambda r: (r[3], r[0]))

# ---------------- skriv filer ----------------
def write(name, header, rows):
    with open(OUT + name, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"{name}: {len(rows)} rader")

write("customers.csv", ["customer_id","customer_name","org_number","contact_name","city","segment","created_date"], customers)
write("dim_customer_scd2.csv", ["customer_sk","customer_id","customer_name","contact_name","city","segment","valid_from","valid_to","is_current"], scd)
write("employees.csv", ["employee_id","first_name","last_name","role","department","hourly_cost","hourly_rate","employment_start","is_active"], employees)
write("projects.csv", ["project_id","project_name","customer_id","project_manager_id","city","project_type","start_date","end_date","budget_amount","status"], projects)
write("timesheets.csv", ["timesheet_id","project_id","employee_id","work_date","hours","activity","is_billable"], timesheets)
write("project_costs.csv", ["cost_id","project_id","cost_date","cost_type","supplier","amount","voucher_no","is_reversed"], costs)
write("invoices.csv", ["invoice_id","project_id","customer_id","invoice_date","due_date","amount","status","invoice_type"], invoices)

# ---------------- nyckeltal för facit ----------------
print("\n--- NYCKELTAL ---")
inv_total = sum(i[5] for i in invoices)
inv_excl_credit = sum(i[5] for i in invoices if i[7] != "Kreditfaktura")
print(f"Fakturerat totalt (inkl kredit): {inv_total:,.0f}")
print(f"Fakturerat exkl kreditfaktura : {inv_excl_credit:,.0f}")

# fan-out: joina fakturor mot SCD2 på customer_id utan datumvillkor
versions = defaultdict(int)
for r in scd:
    versions[r[1]] += 1
fanout = sum(i[5] * versions[i[2]] for i in invoices)
print(f"Fakturerat med felaktig SCD2-join: {fanout:,.0f}  (diff {fanout-inv_total:,.0f})")
print("Antal fakturarader korrekt:", len(invoices), " efter fel join:", sum(versions[i[2]] for i in invoices))

cost_total = sum(c[5] for c in costs)
cost_clean = sum(c[5] for c in costs if c[0] not in {d0[0] for d0 in dupes})
print(f"\nKostnad totalt (med dubbletter): {cost_total:,.0f}")
print(f"Kostnad utan dubblettbunten    : {cost_clean:,.0f}")
print(f"Dubbletter: {len(dupes)} rader, {sum(x[5] for x in dupes):,.0f} kr, projekt P-1004")
print("Dubblerade verifikat:", sorted({x[6] for x in dupes}))

labor_total = sum(t[4]*emp_cost[t[2]] for t in timesheets if t[1])
print(f"\nArbetskostnad från timesheets: {labor_total:,.0f}")
print(f"Timmar totalt: {sum(t[4] for t in timesheets):,}")

print("\n--- PROJEKTKALKYL (korrekt, exkl dubbletter, exkl kreditfaktura netto) ---")
print(f"{'projekt':<10}{'budget':>12}{'fakturerat':>14}{'kostnad':>14}{'marginal':>12}{'avvik%':>9}")
for p in projects:
    pid = p[0]
    b = p[8]
    fak = sum(i[5] for i in invoices if i[1] == pid)
    dc = sum(c[5] for c in costs if c[1] == pid and c[0] not in {d0[0] for d0 in dupes})
    lc = labor_cost[pid]
    tot = dc + lc
    print(f"{pid:<10}{b:>12,.0f}{fak:>14,.0f}{tot:>14,.0f}{fak-tot:>12,.0f}{(tot/b-1)*100:>8.1f}%")
