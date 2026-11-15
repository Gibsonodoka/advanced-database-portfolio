# Portfolio 2 – Query Optimisation

## Files
- `seed.sql` – sample data (30,000 members, 312,632 attendance rows, 200,000 donations)
- `queries.sql` – 5 queries with `EXPLAIN ANALYZE`
- `indexes.sql` / `drop_indexes.sql`
- `evidence/before_indexes.txt`, `evidence/after_indexes.txt`
- `screenshots/` – seed, before and after plans

## Results
| Query | Before (ms) | After (ms) | Plan change |
|---|---:|---:|---|
| Q1 Members by last name | 1.70 | 0.57 | Seq Scan → Bitmap Index Scan |
| Q2 Member attendance (90 days) | 4.62 | 0.07 | Primary key scan → Index Only Scan |
| Q3 Monthly donations per fund | 67.28 | 18.59 | Seq Scan → Index Only Scan |
| Q4 Member's latest donations | 12.80 | 0.08 | Seq Scan → Index Scan |
| Q5 Top 10 donors | 123.47 | 79.09 | Seq Scan → Index Only Scan |

## Analysis
- **Q2, Q4:** biggest gain. They return a few rows for one member, so an index on `member_id` avoids reading the whole table.
- **Q3:** the index includes `amount`, so PostgreSQL reads only the index (Index Only Scan).
- **Q5:** small gain because it still adds up thousands of donations. A summary table or materialised view would help more.
- **Cost of indexes:** they use disk space and slow down inserts and updates. This is acceptable because the system is mostly reads (reports).

Times differ on each machine.

## Run
```
psql -d church_db -f drop_indexes.sql
psql -d church_db -f queries.sql > evidence/before_indexes.txt
psql -d church_db -f indexes.sql
psql -d church_db -f queries.sql > evidence/after_indexes.txt
```
