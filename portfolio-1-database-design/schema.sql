DROP SCHEMA IF EXISTS cms CASCADE;
CREATE SCHEMA cms;
SET search_path = cms;

CREATE TABLE church (
    church_id   serial PRIMARY KEY,
    name        varchar(100) NOT NULL UNIQUE,
    city        varchar(50)  NOT NULL,
    created_at  timestamp    NOT NULL DEFAULT now()
);

CREATE TABLE branch (
    branch_id  serial PRIMARY KEY,
    church_id  int NOT NULL REFERENCES church(church_id) ON DELETE CASCADE,
    name       varchar(100) NOT NULL,
    address    varchar(200),
    UNIQUE (church_id, name)
);

CREATE TABLE member (
    member_id      serial PRIMARY KEY,
    branch_id      int NOT NULL REFERENCES branch(branch_id),
    first_name     varchar(50) NOT NULL,
    last_name      varchar(50) NOT NULL,
    email          varchar(100) UNIQUE,
    phone          varchar(15),
    gender         char(1) CHECK (gender IN ('M','F')),
    date_of_birth  date,
    status         varchar(10) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE','VISITOR')),
    joined_on      date NOT NULL DEFAULT current_date
);

CREATE TABLE ministry (
    ministry_id  serial PRIMARY KEY,
    church_id    int NOT NULL REFERENCES church(church_id) ON DELETE CASCADE,
    name         varchar(50) NOT NULL,
    UNIQUE (church_id, name)
);

CREATE TABLE member_ministry (
    member_id    int NOT NULL REFERENCES member(member_id) ON DELETE CASCADE,
    ministry_id  int NOT NULL REFERENCES ministry(ministry_id) ON DELETE CASCADE,
    role         varchar(10) NOT NULL DEFAULT 'MEMBER' CHECK (role IN ('MEMBER','LEADER')),
    PRIMARY KEY (member_id, ministry_id)
);

CREATE TABLE service (
    service_id    serial PRIMARY KEY,
    branch_id     int NOT NULL REFERENCES branch(branch_id),
    service_type  varchar(10) NOT NULL CHECK (service_type IN ('SUNDAY','MIDWEEK','SPECIAL')),
    service_date  timestamp NOT NULL
);

CREATE TABLE attendance (
    service_id     int NOT NULL REFERENCES service(service_id) ON DELETE CASCADE,
    member_id      int NOT NULL REFERENCES member(member_id) ON DELETE CASCADE,
    checked_in_at  timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (service_id, member_id)
);

CREATE TABLE fund (
    fund_id    serial PRIMARY KEY,
    church_id  int NOT NULL REFERENCES church(church_id) ON DELETE CASCADE,
    name       varchar(50) NOT NULL,
    balance    numeric(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    UNIQUE (church_id, name)
);

CREATE TABLE donation (
    donation_id  serial PRIMARY KEY,
    member_id    int REFERENCES member(member_id),
    fund_id      int NOT NULL REFERENCES fund(fund_id),
    amount       numeric(12,2) NOT NULL CHECK (amount > 0),
    method       varchar(10) NOT NULL CHECK (method IN ('CASH','CARD','TRANSFER')),
    reference    varchar(30) UNIQUE,
    donated_at   timestamp NOT NULL DEFAULT now()
);

CREATE FUNCTION zhim_record_donation(p_member int, p_fund int, p_amount numeric, p_method varchar, p_reference varchar)
RETURNS int LANGUAGE plpgsql AS $$
DECLARE v_id int;
BEGIN
    INSERT INTO cms.donation (member_id, fund_id, amount, method, reference)
    VALUES (p_member, p_fund, p_amount, p_method, p_reference)
    RETURNING donation_id INTO v_id;
    UPDATE cms.fund SET balance = balance + p_amount WHERE fund_id = p_fund;
    RETURN v_id;
END $$;

CREATE FUNCTION zhim_attendance_count(p_member int, p_days int)
RETURNS bigint LANGUAGE sql AS $$
    SELECT count(*) FROM cms.attendance
    WHERE member_id = p_member AND checked_in_at > now() - make_interval(days => p_days);
$$;
