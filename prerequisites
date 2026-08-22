# Förberedelser före workshopdagen

---

## Verktyg att installera

### Git
https://git-scm.com/download/win

Standardinställningar håller.

Verifiera att det fungerade:
```bash
git --version
```

---

### VS Code
https://code.visualstudio.com

Standardinställningar håller.

**Extensions** — installeras inne i VS Code med `Ctrl+Shift+X`, sök på namnet:

- `SQLTools` — av Matheus Teixeira
- `SQLTools PostgreSQL/Cockroach Driver` — av Matheus Teixeira

---

### Power BI Desktop
https://powerbi.microsoft.com/desktop

Kräver ett Microsoft-konto vid första start. Skapa ett i förväg om du inte har ett, annars går första kvarten åt till det på workshopdagen.

---

### GitHub-konto
https://github.com

Skapa ett konto och notera användarnamnet.

---

## Anslutning till databasen

Du får en connection string av kursledaren före dagen. Den ser ut så här:

```
postgresql://neondb_owner:<lösenord>@ep-xxx.eu-central-1.aws.neon.tech/neondb?sslmode=require
```

Lägg till den i SQLTools i VS Code:

1. `Ctrl+Shift+P`
2. Sök på `SQLTools: Add New Connection`
3. Välj PostgreSQL
4. Klistra in uppgifterna

Testa att det fungerar genom att köra:

```sql
SELECT 1;
```

Får du tillbaka `1` utan felmeddelande är du klar.

---

## Klona repot

```bash
git clone https://github.com/PeJo422/BuildCoBI.git
cd BuildCoBI
```

Öppna mappen i VS Code och kontrollera att du ser mapparna `data/`, `sql/`, `exercises/` osv.

---

## Kontroll dagen före

- [ ] `git --version` fungerar i terminalen
- [ ] VS Code öppnas
- [ ] SQLTools kan köra `SELECT 1;` mot databasen utan fel
- [ ] Power BI Desktop öppnar startskärmen
- [ ] Repot är klonat och mapparna syns i VS Code
