create table public.users (
  id uuid primary key default gen_random_uuid(),
  username text not null unique,
  password_digest text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sessions (
  id bigserial primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
