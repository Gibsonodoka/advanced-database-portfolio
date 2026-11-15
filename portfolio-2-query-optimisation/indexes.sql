SET search_path = cms;
CREATE INDEX idx_member_lastname ON member (last_name, branch_id);
CREATE INDEX idx_attendance_member ON attendance (member_id, checked_in_at);
CREATE INDEX idx_donation_fund_date ON donation (fund_id, donated_at) INCLUDE (amount);
CREATE INDEX idx_donation_member_date ON donation (member_id, donated_at DESC);
CREATE INDEX idx_donation_date ON donation (donated_at) INCLUDE (member_id, amount);
VACUUM ANALYZE;
