SET search_path = cms;
SELECT setseed(0.5);
TRUNCATE church RESTART IDENTITY CASCADE;

INSERT INTO church (name, city) VALUES
 ('Grace Chapel', 'Lagos'),
 ('Living Word Church', 'Abuja'),
 ('Hope Assembly', 'Enugu');

INSERT INTO branch (church_id, name)
SELECT c, b FROM generate_series(1,3) c, unnest(ARRAY['Main Branch','North Branch']) b;

INSERT INTO member (branch_id, first_name, last_name, email, phone, gender, date_of_birth, status, joined_on)
SELECT 1 + (i % 6),
       (ARRAY['John','Mary','Peter','Grace','David','Esther','Paul','Ruth','James','Sarah'])[1 + floor(random()*10)::int],
       (ARRAY['Okafor','Adeyemi','Eze','Bello','Nwosu','Ibrahim','Okon','Musa','Obi','Ade'])[1 + floor(random()*10)::int],
       'member' || i || '@example.com',
       '0800' || lpad(i::text, 7, '0'),
       CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END,
       date '1960-01-01' + floor(random()*15000)::int,
       (ARRAY['ACTIVE','ACTIVE','ACTIVE','INACTIVE','VISITOR'])[1 + floor(random()*5)::int],
       current_date - floor(random()*1500)::int
FROM generate_series(1, 30000) i;

INSERT INTO ministry (church_id, name)
SELECT c, m FROM generate_series(1,3) c, unnest(ARRAY['Choir','Ushering','Youth','Children']) m;

INSERT INTO member_ministry (member_id, ministry_id, role)
SELECT m.member_id, (b.church_id - 1) * 4 + 1 + (m.member_id % 4),
       CASE WHEN random() < 0.1 THEN 'LEADER' ELSE 'MEMBER' END
FROM member m JOIN branch b USING (branch_id)
WHERE m.member_id % 2 = 0;

INSERT INTO service (branch_id, service_type, service_date)
SELECT b, t, date_trunc('week', now()) - make_interval(weeks => w) + o
FROM generate_series(1,6) b, generate_series(1,104) w,
     (VALUES ('SUNDAY', interval '6 days 9 hours'), ('MIDWEEK', interval '2 days 18 hours')) x(t, o);

INSERT INTO attendance (service_id, member_id, checked_in_at)
SELECT s.service_id, m.member_id, s.service_date + random() * interval '30 minutes'
FROM service s JOIN member m ON m.branch_id = s.branch_id
WHERE random() < 0.05;

INSERT INTO fund (church_id, name)
SELECT c, f FROM generate_series(1,3) c, unnest(ARRAY['Tithe','Offering','Building']) f;

INSERT INTO donation (member_id, fund_id, amount, method, reference, donated_at)
SELECT m, (ch - 1) * 3 + 1 + floor(random()*3)::int,
       (100 * ceil(random()*500))::numeric,
       meth,
       CASE WHEN meth = 'CASH' THEN NULL ELSE 'REF-' || i END,
       now() - random() * interval '730 days'
FROM (SELECT i,
             1 + floor(random()*30000)::int AS m,
             (ARRAY['CASH','CARD','TRANSFER'])[1 + floor(random()*3)::int] AS meth
      FROM generate_series(1, 200000) i) s
JOIN LATERAL (SELECT b.church_id AS ch FROM member mm JOIN branch b USING (branch_id) WHERE mm.member_id = s.m) c ON true;

UPDATE fund f SET balance = d.total
FROM (SELECT fund_id, sum(amount) total FROM donation GROUP BY fund_id) d
WHERE d.fund_id = f.fund_id;

VACUUM ANALYZE;

SELECT 'members' AS item, count(*) FROM member
UNION ALL SELECT 'services', count(*) FROM service
UNION ALL SELECT 'attendance', count(*) FROM attendance
UNION ALL SELECT 'donations', count(*) FROM donation;
