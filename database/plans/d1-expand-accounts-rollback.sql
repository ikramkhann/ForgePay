-- AI Attribution Block: AI-assisted rollback contingency SQL script for D1 Expand Accounts.
-- Strictly executed ONLY during pre-switch phase under change management approval.

SET lock_timeout = '5s';
SET statement_timeout = '30s';

-- Drop non-blocking index first
DROP INDEX CONCURRENTLY IF EXISTS idx_accounts_kyc_status_pending;

-- Drop additive column if contract has not proceeded
ALTER TABLE accounts DROP COLUMN IF EXISTS kyc_tier;
ALTER TABLE accounts DROP COLUMN IF EXISTS kyc_verified_at;
