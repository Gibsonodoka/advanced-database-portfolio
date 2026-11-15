SET search_path = cms;
DROP TABLE IF EXISTS member_profile;

CREATE TABLE member_profile (
    member_id  int PRIMARY KEY,
    profile    jsonb NOT NULL
);

INSERT INTO member_profile VALUES
(1, '{"name": {"first": "John", "last": "Doe"}, "church": "Grace Chapel", "branch": "Main Branch", "status": "ACTIVE",
      "ministries": [{"name": "Choir", "role": "MEMBER"}, {"name": "Youth", "role": "LEADER"}],
      "giving": {"year": 2026, "total": 150000, "count": 12}}'),
(2, '{"name": {"first": "Mary", "last": "Smith"}, "church": "Grace Chapel", "branch": "North Branch", "status": "ACTIVE",
      "ministries": [{"name": "Ushering", "role": "MEMBER"}],
      "giving": {"year": 2026, "total": 80000, "count": 8}}'),
(3, '{"name": {"first": "Peter", "last": "Brown"}, "church": "Hope Assembly", "branch": "Main Branch", "status": "VISITOR",
      "ministries": [], "giving": {"year": 2026, "total": 0, "count": 0},
      "visitor": {"invited_by": "Mary Smith", "first_visit": "2026-10-04"}}');

CREATE INDEX idx_profile ON member_profile USING gin (profile);

\echo '1. Full profile of one member'
SELECT jsonb_pretty(profile) FROM member_profile WHERE member_id = 1;

\echo '2. Read nested fields'
SELECT profile->'name'->>'first' AS first_name, profile->>'church' AS church,
       (profile->'giving'->>'total')::numeric AS total_giving
FROM member_profile;

\echo '3. Members in the Choir'
SELECT profile->'name'->>'first' AS first_name
FROM member_profile WHERE profile @> '{"ministries": [{"name": "Choir"}]}';

\echo '4. Members per ministry'
SELECT m->>'name' AS ministry, count(*) AS members
FROM member_profile, jsonb_array_elements(profile->'ministries') m
GROUP BY 1 ORDER BY 2 DESC;

\echo '5. Total giving per church'
SELECT profile->>'church' AS church, sum((profile->'giving'->>'total')::numeric) AS total
FROM member_profile GROUP BY 1;

\echo '6. Flexible fields: only visitors have a visitor section'
SELECT profile->'name'->>'first' AS first_name, profile->'visitor' AS visitor
FROM member_profile WHERE profile ? 'visitor';

\echo '7. Add a new field without changing the table'
UPDATE member_profile SET profile = profile || '{"baptised": true}' WHERE member_id = 1;
SELECT profile->'name'->>'first' AS first_name, profile->>'baptised' AS baptised FROM member_profile;

\echo '8. Query plan using the GIN index'
SET enable_seqscan = off;
EXPLAIN SELECT member_id FROM member_profile WHERE profile @> '{"status": "ACTIVE"}';
