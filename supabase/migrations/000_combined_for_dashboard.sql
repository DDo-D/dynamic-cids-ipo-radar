-- Paste this entire file in Supabase SQL Editor if CLI db push fails.
-- https://supabase.com/dashboard/project/qghquidouqdrjxdjyrgy/sql/new

create table if not exists public.settings (
  key text primary key,
  value text
);

create table if not exists public.fetch_logs (
  id bigserial primary key,
  fetched_at timestamptz,
  status text,
  http_code integer,
  response_length integer,
  response_hash text,
  error_message text
);

create table if not exists public.anchors (
  id bigserial primary key,
  prev_anchor double precision,
  anchor_new double precision,
  anchor_final double precision,
  calculated_at timestamptz
);

create table if not exists public.ipo_items (
  id bigserial primary key,
  company_name text,
  subscription_period text,
  subscription_start_date text,
  listing_date date,
  underwriter text,
  offer_price_text text,
  inst_demand_text text,
  lockup_text text,
  float_ratio double precision,
  float_amount double precision,
  estimated_market_cap double precision,
  adjusted_r double precision,
  cids double precision,
  cids10 double precision,
  signal text,
  decision text,
  reason_line1 text,
  reason_line2 text,
  reason_line3 text,
  source_url text,
  updated_at timestamptz,
  unique (company_name, subscription_period)
);

create index if not exists idx_ipo_items_source_url on public.ipo_items (source_url);
create index if not exists idx_fetch_logs_fetched_at on public.fetch_logs (fetched_at desc);
create index if not exists idx_ipo_items_listing_date on public.ipo_items (listing_date asc);
