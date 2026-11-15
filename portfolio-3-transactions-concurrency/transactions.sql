SET search_path = cms;

\echo '1. COMMIT'
SELECT balance FROM fund WHERE fund_id = 1;
BEGIN;
SELECT zhim_record_donation(1, 1, 1000, 'CARD', 'TX-COMMIT');
COMMIT;
SELECT balance FROM fund WHERE fund_id = 1;

\echo '2. ROLLBACK'
BEGIN;
SELECT zhim_record_donation(1, 1, 9000, 'CARD', 'TX-ROLLBACK');
ROLLBACK;
SELECT balance FROM fund WHERE fund_id = 1;
SELECT count(*) FROM donation WHERE reference = 'TX-ROLLBACK';

\echo '3. ATOMICITY: second step fails, first step is undone'
BEGIN;
SELECT zhim_record_donation(1, 1, 2000, 'CARD', 'TX-ATOMIC');
UPDATE fund SET balance = balance - 999999999 WHERE fund_id = 2;
COMMIT;
SELECT count(*) FROM donation WHERE reference = 'TX-ATOMIC';

\echo '4. SAVEPOINT'
BEGIN;
SELECT zhim_record_donation(1, 1, 300, 'CASH', NULL);
SAVEPOINT sp1;
SELECT zhim_record_donation(1, 1, -50, 'CASH', NULL);
ROLLBACK TO SAVEPOINT sp1;
SELECT zhim_record_donation(1, 1, 400, 'CASH', NULL);
COMMIT;
SELECT amount FROM donation WHERE member_id = 1 AND method = 'CASH' ORDER BY donation_id DESC LIMIT 2;

\echo '5. DUPLICATE REFERENCE REJECTED'
SELECT zhim_record_donation(1, 1, 1000, 'CARD', 'TX-COMMIT');
