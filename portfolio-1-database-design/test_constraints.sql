SET search_path = cms;

INSERT INTO church (name, city) VALUES ('Grace Chapel', 'Lagos');
INSERT INTO branch (church_id, name) VALUES (1, 'Main Branch');
INSERT INTO fund (church_id, name) VALUES (1, 'Tithe');
INSERT INTO member (branch_id, first_name, last_name, email) VALUES (1, 'John', 'Doe', 'john@example.com');

INSERT INTO donation (member_id, fund_id, amount, method) VALUES (1, 1, -500, 'CASH');
INSERT INTO member (branch_id, first_name, last_name) VALUES (99, 'Jane', 'Doe');
INSERT INTO member (branch_id, first_name, last_name, email) VALUES (1, 'Jane', 'Doe', 'john@example.com');
INSERT INTO member (branch_id, first_name, last_name, gender) VALUES (1, 'Jane', 'Doe', 'X');
INSERT INTO donation (member_id, fund_id, amount, method) VALUES (1, 1, 1000, 'CHEQUE');

SELECT zhim_record_donation(1, 1, 5000, 'CARD', 'REF-001');
SELECT name, balance FROM fund;
