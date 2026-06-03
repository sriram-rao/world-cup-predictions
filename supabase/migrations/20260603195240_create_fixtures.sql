create extension if not exists "pgcrypto";

create table public.fixtures (
  id uuid primary key default gen_random_uuid(),
  match_number integer not null unique,
  round_number text not null,
  match_date timestamptz not null,
  location text not null,
  home_team text not null,
  away_team text not null,
  group_name text,
  home_score integer check (home_score >= 0),
  away_score integer check (away_score >= 0)
);
