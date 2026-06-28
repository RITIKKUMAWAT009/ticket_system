-- SQL Seed Script for Ticket Management System
-- Run after Prisma migrations: psql $DATABASE_URL -f prisma/seed.sql

-- Districts
INSERT INTO districts (id, name) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'Jaipur'),
  ('d1000000-0000-0000-0000-000000000002', 'Jodhpur')
ON CONFLICT (name) DO NOTHING;

-- Tehsils
INSERT INTO tehsils (id, "districtId", name) VALUES
  ('t1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001', 'Jaipur City'),
  ('t1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001', 'Amber'),
  ('t1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000002', 'Jodhpur City')
ON CONFLICT ("districtId", name) DO NOTHING;

-- Projects
INSERT INTO projects (id, "tehsilId", name, description) VALUES
  ('p1000000-0000-0000-0000-000000000001', 't1000000-0000-0000-0000-000000000001', 'Water Supply', 'Municipal water supply complaints'),
  ('p1000000-0000-0000-0000-000000000002', 't1000000-0000-0000-0000-000000000001', 'Road Maintenance', 'Road repair and maintenance complaints'),
  ('p1000000-0000-0000-0000-000000000003', 't1000000-0000-0000-0000-000000000002', 'Electricity', 'Power supply related complaints')
ON CONFLICT ("tehsilId", name) DO NOTHING;

-- Admin user
INSERT INTO users (id, "mobileNumber", "fullName", "fatherName", email, gender, role, "createdAt") VALUES
  ('u1000000-0000-0000-0000-000000000001', '9999999999', 'System Admin', 'Admin Father', 'admin@ticket.gov.in', 'MALE', 'ADMIN', NOW())
ON CONFLICT ("mobileNumber") DO NOTHING;

-- Support agents
INSERT INTO users (id, "mobileNumber", "fullName", "fatherName", email, gender, role, "createdAt") VALUES
  ('u1000000-0000-0000-0000-000000000002', '8888888888', 'Support Agent One', 'Agent Father', 'agent1@ticket.gov.in', 'MALE', 'SUPPORT_AGENT', NOW()),
  ('u1000000-0000-0000-0000-000000000003', '7777777777', 'Support Agent Two', 'Agent Father', 'agent2@ticket.gov.in', 'FEMALE', 'SUPPORT_AGENT', NOW())
ON CONFLICT ("mobileNumber") DO NOTHING;

-- Sample citizen
INSERT INTO users (id, "mobileNumber", "fullName", "fatherName", email, "aadhaarNumber", gender, role, "createdAt") VALUES
  ('u1000000-0000-0000-0000-000000000004', '9876543210', 'Rahul Sharma', 'Rajesh Sharma', 'rahul@example.com', '123456789012', 'MALE', 'CITIZEN', NOW())
ON CONFLICT ("mobileNumber") DO NOTHING;

-- Sample ticket
INSERT INTO tickets (id, "ticketNumber", "citizenId", "districtId", "tehsilId", "projectId", remarks, status, priority, "assignedAgentId", "createdAt", "updatedAt") VALUES
  ('tk100000-0000-0000-0000-000000000001', 'TKT-20260001', 'u1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001', 't1000000-0000-0000-0000-000000000001', 'p1000000-0000-0000-0000-000000000001', 'No water supply in Ward 12 for 3 days', 'ASSIGNED', 'HIGH', 'u1000000-0000-0000-0000-000000000002', NOW(), NOW())
ON CONFLICT ("ticketNumber") DO NOTHING;
