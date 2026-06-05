# Supabase Setup

Hestia uses Supabase for Auth, Postgres data, RLS, Storage, Realtime, and Edge
Functions.

## Project Configuration

1. Create a Supabase project.
2. Copy the project URL into `SUPABASE_URL`.
3. Copy the publishable or anon key into `SUPABASE_ANON_KEY` locally and
   `SUPABASE_PUBLISHABLE_KEY` in GitHub Secrets.
4. Configure Apple Sign-In with the callback URL:

```text
https://YOUR_PROJECT.supabase.co/auth/v1/callback
```

5. Add the same values to `.env` and GitHub Actions secrets.

## App-Owned Tables

Table name constants live in `lib/core/constants/supabase_tables.dart`. Keep SQL
migrations, RLS policies, and Edge Function contracts aligned with those
constants.

Core app areas include:

- profiles and households,
- transactions, transfers, categories, bank accounts, cards, account members,
- goals and notifications,
- appointments and calendar sync metadata,
- cars, fuel entries, pets, pet measurements, and pet health records,
- shopping lists, shopping items, and shopping sessions,
- homes and location-enabled records.

## RLS Expectations

Every user-owned or household-owned table should enforce RLS. Policies should
allow access only when the signed-in user belongs to the relevant household or
has an explicit role for the resource. Admin-only behavior should be handled by
server-side Edge Functions, never by exposing service-role keys to the app.

## Edge Functions

`AuthRepositoryImpl.createUser` calls an `admin-create-user` Edge Function. That
function must:

- authenticate the caller,
- verify the caller is a superuser,
- create the Supabase Auth user with server-side credentials,
- return only safe profile fields to the app.

## Storage

Image uploads are centralized through `ImageUploadService`. Storage buckets and
policies should restrict writes to authenticated users and scope reads according
to the target feature.

## Migrations

Keep backend SQL migrations versioned outside `docs/`, then link them here when
they are added to the repo. Backend changes that alter app contracts must be
released with matching Dart DTO, mapper, repository, and documentation updates.
