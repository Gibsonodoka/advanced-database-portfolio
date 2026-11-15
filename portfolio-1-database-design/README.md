# Portfolio 1 – Database Design

## Files
- `er-diagram.png` – ER diagram
- `schema.sql` – tables, keys, constraints, functions
- `test_constraints.sql` – tests that break the rules
- `test_constraints_output.txt` – output
- `screenshots/` – tables and constraint tests

## Entities
church, branch, member, ministry, member_ministry, service, attendance, fund, donation

## Relationships
- A church has many branches, ministries and funds (1:N)
- A branch has many members and services (1:N)
- Members and ministries are many-to-many, resolved by `member_ministry`
- Members and services are many-to-many, resolved by `attendance`
- A fund receives many donations (1:N)

## Constraints
| Type | Example |
|---|---|
| Primary key | `member_id`, composite `(service_id, member_id)` |
| Foreign key | `member.branch_id` → `branch` |
| Unique | `member.email`, `donation.reference` |
| Check | `amount > 0`, `balance >= 0`, allowed `gender`, `status`, `method` |

## Functions
- `zhim_record_donation()` – saves a donation and updates the fund balance
- `zhim_attendance_count()` – counts a member's attendance in the last N days

## Normalisation
**Unnormalised:** one donation sheet with member name, phone, branch, branch address and several fund names/amounts in one cell.

- **1NF:** one value per cell, one row per donation.
- **2NF:** member details depend only on the member, fund details only on the fund, so they move to `member` and `fund`.
- **3NF:** branch address depends on the branch, not the member, so it moves to `branch`.

Every non-key column depends only on its table's key, so the design is in 3NF (also BCNF).
`fund.balance` is stored for fast reads and is always updated in the same transaction as the donation.

## Run
```
psql -d church_db -f schema.sql
psql -d church_db -f test_constraints.sql
```
