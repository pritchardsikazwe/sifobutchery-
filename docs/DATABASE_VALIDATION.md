# Database validation plan — SifoButchery

Status: schema draft only; not applied to any database.

## Required before production
- Apply migrations to a disposable Supabase/PostgreSQL project first.
- Verify two-company isolation for batches, stock, yields, movements, and audit records.
- Add consistency checks for branch/company ownership across all references.
- Validate yield totals against batch weight and define handling of trim, waste, and by-products.
- Ensure stock balances are derived from posted movements and adjustments are auditable.
- Verify staff roles cannot manage company membership; only owner/admin can.
- Review RLS policy recursion, SECURITY DEFINER function ownership/search_path, and privilege grants.
- Add automated SQL migration tests before marking this PR ready.
