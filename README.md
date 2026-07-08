# World Cup Predictions

Prediction game for the 2026 FIFA World Cup.

Production: https://world-cup-predictions-r63i.onrender.com

## What it does

- Username/password accounts using Rails-native auth.
- Users predict fixture scores.
- Knockout draw predictions can include a penalty shootout winner.
- Fixtures lock after kickoff.
- Admins can edit results and update results from football-data.org.
- Leaderboards show points for the standard rules and the `VAR Robbed Me` ruleset.
- Fixture detail pages show everyone’s predictions and point breakdowns.
- Group, round, and matchday pages.
- Dark mode by default with browser-local theme toggle.
- Country flags and football-data aliases are stored in the database.

## Scoring summary

Standard scoring stacks:

- correct result / advancing team
- correct goal difference
- exact final score

Knockout extras:

- `90' Draw`: bonus if you predicted a draw and the game was drawn after regulation but decided in extra time or penalties
- `90' Score`: bonus if your draw score exactly matched the regulation-time score
- `Penalty shootout`: bonus if you predicted a draw and picked the correct shootout winner

See `/rules` in the app for the current detailed rules.

## Tech stack

- Ruby 3.4.3
- Rails 8.1
- PostgreSQL
- Tailwind CSS via `tailwindcss-rails`
- Render web service
- Supabase Postgres in production
- football-data.org API for result imports

## Local setup

Install Ruby 3.4.3 and PostgreSQL, then:

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

Open:

```text
http://localhost:3000
```

Run tests:

```bash
bin/rails test
```

If the test DB does not exist:

```bash
bin/rails db:create RAILS_ENV=test
bin/rails test
```

Build CSS manually:

```bash
bin/rails tailwindcss:build
```

## Configuration

Important environment variables:

```bash
DATABASE_URL=postgresql://...
RAILS_MASTER_KEY=...
API_KEY=football-data-api-key
```

`API_KEY` is optional locally, but required for automatic/admin result imports.

## Data setup

Seed data imports fixtures from:

```text
db/data/fixtures.csv
```

The fixture CSV was sourced from:

```text
https://fixturedownload.com/results/fifa-world-cup-2026
```

It also seeds:

- default leaderboards/rules
- countries
- country aliases

Run:

```bash
bin/rails db:seed
```

Make a user admin from Rails console:

```bash
bin/rails console
User.find_by!(username: "your_username").update!(admin: true)
```

## Result imports

Manual import for one date:

```bash
DATE=2026-06-14 API_KEY=... bin/rails football_data:update_results
```

In production, results can be updated by:

- visiting today’s fixtures page when `API_KEY` is configured
- clicking the admin `Update results` button

Render free tier has no cron here, so there is no scheduled background import.

## Render deployment

This repo includes `render.yaml`.

Render service settings:

```yaml
runtime: ruby
plan: free
buildCommand: bundle install && bundle exec rails assets:precompile
startCommand: bundle exec rails db:migrate && bundle exec rails server
```

Required Render environment variables:

```text
RAILS_ENV=production
RAILS_MASTER_KEY=<Rails master key>
DATABASE_URL=<Supabase/Postgres connection URL>
API_KEY=<football-data.org token>
```

Production uses:

- `DATABASE_URL` for Postgres
- in-process memory cache
- async Active Job adapter

After pushing to `main`, Render auto-deploys.

Useful production checks:

- `/up` health check
- `/rules`
- `/leaderboards/standard`
- `/leaderboards/var-robbed-me`

## Notes

- Do not commit secrets.
- Country/alias changes may need a service restart because country lookup is cached.
- Fixture times are stored in Pacific time and displayed in the browser’s local timezone.
