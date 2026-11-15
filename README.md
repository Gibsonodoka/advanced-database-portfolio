# MIT 8103 Advanced Database Systems Portfolio – Church Management System

**Student:** Odoka Uwhetu Gibson | **Student ID:** 301923155

**GitHub:** https://github.com/Gibsonodoka/advanced-database-portfolio

## Case Study
| Item | Description |
|---|---|
| Organisation | A church management system used by several churches, each with branches |
| Nature of business | Manages church members, services, attendance and donations |
| Users | Church admins, pastors, finance officers, ushers, members |
| Main data | Churches, branches, members, ministries, services, attendance, funds, donations |
| Key operations | Register members, record attendance, record donations, view reports |

All data is sample data.

## Structure
| Folder | Topic |
|---|---|
| portfolio-1-database-design | Database design, ER diagram, normalisation |
| portfolio-2-query-optimisation | Queries, indexes, execution plans |
| portfolio-3-transactions-concurrency | Transactions and concurrency |
| portfolio-4-nosql | Document model (JSONB) and key-value model (Redis) |
| portfolio-5-distributed-cloud | Replication, partitioning, cloud |
| docs | AI declaration, reflection |

## Tools
PostgreSQL 16 (including JSONB), Redis, Python 3 (psycopg2).

## How to run
```
createdb church_db
psql -d church_db -f portfolio-1-database-design/schema.sql
psql -d church_db -f portfolio-2-query-optimisation/seed.sql
```
Then follow the README in each folder. Screenshots of every run are in each `screenshots/` folder.
