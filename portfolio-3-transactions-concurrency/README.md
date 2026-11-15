# Portfolio 3 – Transactions and Concurrency

## Files
- `transactions.sql` – commit, rollback, atomicity, savepoint, duplicate check
- `concurrency.py` – two sessions running at the same time
- `evidence/` – outputs
- `screenshots/` – transactions and concurrency runs

## Transactions
| Test | Result |
|---|---|
| COMMIT | Donation saved, balance increased |
| ROLLBACK | Nothing saved |
| Atomicity | Second step failed, so the first step was also undone |
| Savepoint | Bad row skipped, good rows saved |
| Duplicate reference | Rejected by the unique constraint |

## ACID
- **Atomicity:** all steps succeed or none do.
- **Consistency:** constraints stop invalid data (negative amount, negative balance).
- **Isolation:** shown below.
- **Durability:** after COMMIT, data is written to the WAL and survives a crash.

## Concurrency
| Test | Result |
|---|---|
| Lost update (read then write) | Balance 1100 or 1200 instead of 1300 (one update is lost) |
| Fix: `balance = balance + x` | Correct (1300) |
| Fix: `SELECT ... FOR UPDATE` | Second session waits, correct (1300) |
| READ COMMITTED | Second read sees new value (non-repeatable read) |
| REPEATABLE READ | Both reads the same |
| Opposite lock order | Deadlock detected, one transaction rolled back |
| Same lock order | No deadlock |

## Run
```
psql -d church_db -f transactions.sql
pip install psycopg2-binary
python3 concurrency.py
```
Change `DSN` in `concurrency.py` to match your database.
