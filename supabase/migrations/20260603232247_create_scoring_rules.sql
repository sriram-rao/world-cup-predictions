create table public.scoring_rules (
  id uuid primary key default gen_random_uuid(),
  outcome_points integer not null default 1 check (outcome_points >= 0),
  goal_difference_points integer not null default 2 check (goal_difference_points >= 0),
  exact_score_points integer not null default 2 check (exact_score_points >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
