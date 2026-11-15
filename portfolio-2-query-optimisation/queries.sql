SET search_path = cms;
SET max_parallel_workers_per_gather = 0;

\echo 'Q1 Find members by last name in a branch'
EXPLAIN ANALYZE
SELECT member_id, first_name, last_name FROM member
WHERE last_name = 'Okafor' AND branch_id = 1;

\echo 'Q2 Attendance of one member in the last 90 days'
EXPLAIN ANALYZE
SELECT count(*) FROM attendance
WHERE member_id = 1234 AND checked_in_at > now() - interval '90 days';

\echo 'Q3 Monthly donations per fund in the last 12 months'
EXPLAIN ANALYZE
SELECT f.name, date_trunc('month', d.donated_at) AS month, sum(d.amount)
FROM donation d JOIN fund f USING (fund_id)
WHERE f.church_id = 1 AND d.donated_at > now() - interval '12 months'
GROUP BY f.name, month ORDER BY month, f.name;

\echo 'Q4 Latest 20 donations of one member'
EXPLAIN ANALYZE
SELECT donation_id, amount, method, donated_at FROM donation
WHERE member_id = 1234 ORDER BY donated_at DESC LIMIT 20;

\echo 'Q5 Top 10 donors this year'
EXPLAIN ANALYZE
SELECT m.first_name, m.last_name, t.total, rank() OVER (ORDER BY t.total DESC)
FROM (SELECT member_id, sum(amount) AS total FROM donation
      WHERE donated_at >= date_trunc('year', now()) GROUP BY member_id) t
JOIN member m USING (member_id)
ORDER BY t.total DESC LIMIT 10;
