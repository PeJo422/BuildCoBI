# Övning 0 — Repot

**Tid:** 30 minuter

Du bygger ett repo som du kommer att fortsätta jobba i efter idag. Varje sak du
lär dig blir en commit.

## 1. Skapa repot

```bash
mkdir buildco-bi && cd buildco-bi
git init
```

Kör `git status`. Läs vad det står. Gör det efter varje kommando nedan.

## 2. Skapa strukturen

```
buildco-bi/
├── README.md
├── docs/
├── data/raw/
├── data/processed/
├── sql/
├── model/
├── powerbi/
└── exercises/
```

Lägg CSV-filerna i `data/raw/`.

## 3. Första commit

```bash
git add .
git commit -m "Initial project setup"
```

Fyra tillstånd, håll ordning på dem:

```
filer på disk  --git add-->  staged  --git commit-->  historik  --git push-->  GitHub
```

## 4. Koppla till GitHub

Skapa ett tomt repo på GitHub (ingen README, ingen .gitignore — du har redan
båda).

```bash
git branch -M main
git remote add origin git@github.com:<ditt-användarnamn>/buildco-bi.git
git push -u origin main
```

## 5. Branch för dagens första uppgift

```bash
git checkout -b feature/sql-exploration
```

## Att kunna svara på efteråt

- Vad är skillnaden mellan `git add` och `git commit`?
- Vad händer om du gör `git commit` utan att ha gjort `git add`?
- Varför ligger `*.pbix` i `.gitignore`?
- Vad gör `git checkout -b`?

## Commit-meddelanden

Skriv vad ändringen gör, inte att du gjorde en ändring.

```
Bra:   Add SCD type 2 join with validity window
Bra:   Fix duplicated cost rows from re-run import batch
Dåligt: update
Dåligt: fix
Dåligt: asdf
```

Om ett halvår är historiken det enda som berättar vad du gjorde och varför.
