-- AI Attribution Block: AI-assisted schema verification SQL script for D1 Expand Accounts.
-- Checks that additive columns and concurrent index exist and are valid.

SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'accounts'
  AND column_name IN ('kyc_tier', 'kyc_verified_at');

-- Verify index validity
SELECT
  relname,
  indisvalid
FROM pg_index i
JOIN pg_class c ON c.oid = i.indexrelid
WHERE c.relname = 'idx_accounts_kyc_status_pending';
