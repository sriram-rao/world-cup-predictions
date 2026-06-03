alter table public.fixtures
  add column home_score integer check (home_score >= 0),
  add column away_score integer check (away_score >= 0);

alter table public.users
  add column admin boolean not null default false;
