# Portfolio 5 – Distributed and Cloud Database

## Files
- `replication.sh` – primary and replica, lag, failover
- `partitioning.sql` – donations split by church
- `evidence/` – outputs
- `screenshots/` – partitioning and replication runs

## Replication
| Test | Result |
|---|---|
| Replica created | In recovery mode, streaming from primary |
| Write on primary | Visible on replica |
| Write on replica | Rejected (read-only) |
| Replica paused | Primary has the row, replica does not (lag) |
| Replica resumed | Replica catches up |
| Primary stopped | Replica promoted and accepts writes |

## Partitioning
Donations are partitioned by `church_id`. A query for one church scans only that church's partition (partition pruning). In a sharded system each partition would be on a separate server.

## CAP theorem
- **Synchronous replication:** consistent, but writes stop if the replica is down.
- **Asynchronous replication (used here):** always available, but the replica may be a little behind.

Donations should be read from the primary. Reports can be read from the replica.

## Cloud deployment
1. Create a free PostgreSQL database (e.g. Neon or Supabase).
2. Run `schema.sql` and `seed.sql` on it.
3. Run a query from `queries.sql`.
4. Create a read replica and run `SELECT pg_is_in_recovery();`.
5. Take screenshots of each step (hide passwords).

## Run
```
psql -d church_db -f partitioning.sql
./replication.sh
```
Set `PGBIN`, `DATA`, `PRIMARY`, `REPLICA` in `replication.sh` to match your machine.
