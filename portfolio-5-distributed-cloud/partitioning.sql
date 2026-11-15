SET search_path = cms;
DROP TABLE IF EXISTS donation_by_church;

CREATE TABLE donation_by_church (
    donation_id  int,
    church_id    int NOT NULL,
    member_id    int,
    amount       numeric(12,2) NOT NULL,
    donated_at   timestamp NOT NULL
) PARTITION BY LIST (church_id);

CREATE TABLE donation_church_1 PARTITION OF donation_by_church FOR VALUES IN (1);
CREATE TABLE donation_church_2 PARTITION OF donation_by_church FOR VALUES IN (2);
CREATE TABLE donation_church_3 PARTITION OF donation_by_church FOR VALUES IN (3);

INSERT INTO donation_by_church
SELECT d.donation_id, f.church_id, d.member_id, d.amount, d.donated_at
FROM donation d JOIN fund f USING (fund_id);

ANALYZE donation_by_church;

SELECT tableoid::regclass AS partition, count(*) FROM donation_by_church GROUP BY 1 ORDER BY 1;

EXPLAIN SELECT sum(amount) FROM donation_by_church WHERE church_id = 2;

SELECT church_id, sum(amount) FROM donation_by_church GROUP BY church_id ORDER BY church_id;
