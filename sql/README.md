# SQL Deployment Instructions

## Connection template
```
mysql --host=<mysql-host> --user=<username> --password=<password> --database=la_codex
```

## Apply migrations
```
mysql --host=<mysql-host> --user=<username> --password=<password> --database=la_codex < sql/create.sql
mysql --host=<mysql-host> --user=<username> --password=<password> --database=la_codex < sql/seed.sql
```

## Rollback
```
mysql --host=<mysql-host> --user=<username> --password=<password> --database=la_codex < sql/rollback.sql
```
