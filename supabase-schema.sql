-- Run this in Supabase SQL Editor only after reviewing it.
-- This schema intentionally does not automatically credit deposits or promise returns.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

create type public.request_status as enum ('pending','approved','rejected','paid','cancelled');

create table if not exists public.deposit_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount_usd numeric(12,2) not null check (amount_usd >= 10 and amount_usd <= 1000),
  network text not null default 'USDT TRC20' check (network = 'USDT TRC20'),
  tx_hash text not null,
  proof_path text,
  status public.request_status not null default 'pending',
  admin_note text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table if not exists public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount_usd numeric(12,2) not null check (amount_usd > 0),
  destination_address text not null,
  network text not null default 'USDT TRC20' check (network = 'USDT TRC20'),
  status public.request_status not null default 'pending',
  admin_note text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table if not exists public.ledger_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount_usd numeric(12,2) not null,
  entry_type text not null check (entry_type in ('deposit','withdrawal','verified_profit','task_reward','referral_reward','adjustment')),
  description text not null,
  related_request_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  reward_usd numeric(12,2) not null default 0 check (reward_usd >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.task_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id uuid not null references public.tasks(id) on delete cascade,
  proof_path text,
  status public.request_status not null default 'pending',
  admin_note text,
  created_at timestamptz not null default now()
);

create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references auth.users(id) on delete cascade,
  referred_user_id uuid not null unique references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','eligible','rewarded','rejected')),
  created_at timestamptz not null default now(),
  check (referrer_id <> referred_user_id)
);

alter table public.profiles enable row level security;
alter table public.deposit_requests enable row level security;
alter table public.withdrawal_requests enable row level security;
alter table public.ledger_entries enable row level security;
alter table public.tasks enable row level security;
alter table public.task_submissions enable row level security;
alter table public.referrals enable row level security;

-- Users can read/update their own profile, but cannot assign their own ID.
create policy "read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "insert own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "read own deposits" on public.deposit_requests for select to authenticated using (auth.uid() = user_id);
create policy "submit own deposits" on public.deposit_requests for insert to authenticated with check (auth.uid() = user_id and status = 'pending');

create policy "read own withdrawals" on public.withdrawal_requests for select to authenticated using (auth.uid() = user_id);
create policy "submit own withdrawals" on public.withdrawal_requests for insert to authenticated with check (auth.uid() = user_id and status = 'pending');

create policy "read own ledger" on public.ledger_entries for select to authenticated using (auth.uid() = user_id);
create policy "read active tasks" on public.tasks for select to authenticated using (active = true);
create policy "read own task submissions" on public.task_submissions for select to authenticated using (auth.uid() = user_id);
create policy "submit own task submissions" on public.task_submissions for insert to authenticated with check (auth.uid() = user_id and status = 'pending');
create policy "read own referrals" on public.referrals for select to authenticated using (auth.uid() = referrer_id or auth.uid() = referred_user_id);

-- IMPORTANT:
-- Do not grant users direct UPDATE rights on request statuses or ledger entries.
-- Admin actions must use a trusted server-side function/API with role checks and audit logs.
-- Configure private Storage buckets and policies before accepting payment-proof uploads.
-- Add admin role management through a trusted server-side process; never trust a client-side
-- is_admin flag. Review local financial-services, consumer-protection, AML/KYC, and crypto rules.
