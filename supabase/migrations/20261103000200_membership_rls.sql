-- Membership/RLS baseline; review for your chosen auth provisioning before applying.
create table if not exists public.company_memberships(
 id uuid primary key default gen_random_uuid(),
 company_id uuid not null references public.companies(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check(role in('owner','admin','manager','staff','viewer')),
 created_at timestamptz not null default now(),
 unique(company_id,user_id)
);
create or replace function public.has_company_access(target_company uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.company_memberships m where m.company_id=target_company and m.user_id=auth.uid()) $$;
create or replace function public.is_company_admin(target_company uuid)
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.company_memberships m where m.company_id=target_company and m.user_id=auth.uid() and m.role in('owner','admin')) $$;
alter table public.company_memberships enable row level security;
drop policy if exists "members can read own memberships" on public.company_memberships;
create policy "members can read own memberships" on public.company_memberships for select using(user_id=auth.uid());
drop policy if exists "company admins manage memberships" on public.company_memberships;
create policy "company admins manage memberships" on public.company_memberships for all using(public.is_company_admin(company_id)) with check(public.is_company_admin(company_id));
alter table public.branches enable row level security;
drop policy if exists "tenant members access branches" on public.branches;
create policy "tenant members access branches" on public.branches for all using(public.has_company_access(company_id)) with check(public.has_company_access(company_id));\nalter table public.stock_items enable row level security;
drop policy if exists "tenant members access stock_items" on public.stock_items;
create policy "tenant members access stock_items" on public.stock_items for all using(public.has_company_access(company_id)) with check(public.has_company_access(company_id));\nalter table public.intake_batches enable row level security;
drop policy if exists "tenant members access intake_batches" on public.intake_batches;
create policy "tenant members access intake_batches" on public.intake_batches for all using(public.has_company_access(company_id)) with check(public.has_company_access(company_id));\nalter table public.yield_records enable row level security;
drop policy if exists "tenant members access yield_records" on public.yield_records;
create policy "tenant members access yield_records" on public.yield_records for all using(public.has_company_access((select b.company_id from public.intake_batches b where b.id=yield_records.batch_id))) with check(public.has_company_access((select b.company_id from public.intake_batches b where b.id=yield_records.batch_id)));\nalter table public.stock_movements enable row level security;
drop policy if exists "tenant members access stock_movements" on public.stock_movements;
create policy "tenant members access stock_movements" on public.stock_movements for all using(public.has_company_access(company_id)) with check(public.has_company_access(company_id));\nalter table public.audit_events enable row level security;
drop policy if exists "tenant members access audit_events" on public.audit_events;
create policy "tenant members access audit_events" on public.audit_events for all using(public.has_company_access(company_id)) with check(public.has_company_access(company_id));
