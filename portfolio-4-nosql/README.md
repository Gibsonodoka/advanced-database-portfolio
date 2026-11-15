# Portfolio 4 – NoSQL and Advanced Data Models

## Files
- `jsonb.sql` – document model using PostgreSQL JSONB
- `redis.txt` – key-value model using Redis
- `evidence/` – outputs
- `screenshots/` – JSONB and Redis runs

## Document model (PostgreSQL JSONB)
Each member profile is stored as one JSON document: name, church, branch, ministries and giving summary.

| Test | Result |
|---|---|
| Read one full profile | One row, no joins |
| Read nested fields | `profile->'name'->>'first'` |
| Search inside an array | Members in the Choir found with `@>` |
| Count per ministry | `jsonb_array_elements` |
| Flexible fields | Only visitors have a `visitor` section |
| Add a field | `baptised` added without changing the table |
| Index | GIN index used (Bitmap Index Scan) |

## Key-value model (Redis)
| Use | Commands |
|---|---|
| Top donors leaderboard | `ZADD`, `ZINCRBY`, `ZREVRANGE` |
| Check-in counter | `INCR`, `SADD`, `SCARD` |
| OTP code that expires | `SET ... EX`, `TTL` |
| Member cache | `HSET`, `HGETALL` |
| Prevent double payment | `SET ... NX` (second attempt returns nil) |

## Comparison
| | Relational tables | JSONB documents | Redis |
|---|---|---|---|
| Model | Rows and columns | JSON documents | Key-value |
| Schema | Fixed | Flexible | None |
| Best for | Donations, members | Member profiles | Counters, cache, OTP |
| Consistency | Strong (ACID) | Strong (ACID) | Weaker durability |

Donations stay in relational tables because money needs ACID transactions and fixed rules.

## Run
```
psql -d church_db -f jsonb.sql
redis-cli < redis.txt
```
