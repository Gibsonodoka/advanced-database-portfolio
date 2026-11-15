SET search_path = cms;
DROP INDEX IF EXISTS idx_member_lastname, idx_attendance_member, idx_donation_fund_date, idx_donation_member_date, idx_donation_date;
VACUUM ANALYZE;
