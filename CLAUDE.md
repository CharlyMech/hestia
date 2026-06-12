# Hestia — agent guide

Flutter app (Cupertino + [forui](https://pub.dev/packages/forui) design system),
BLoC state management, Supabase backend with edge functions.

## Architecture rules (MUST follow)

### Data flow (one direction)
```
UI → bloc event → repository → service → Supabase client (+ edge functions if required)
   → service → DTO → mapper → domain model → bloc state → UI
```
- UI only **consumes bloc state** and **emits events**. No repository/service calls from widgets except the read-only lookup loads already established in form widgets.
- Layers: `lib/presentation` (UI + blocs) → `lib/domain` (entities + repository interfaces) → `lib/data` (services, DTOs in `lib/data/dtos`, mappers in `lib/data/mappers`, repository impls).
- DTO ↔ JSON is the DB column contract. The DTO is the source of truth for `supabase/migrations`.

### Edge-function-first (performance)
Any write with **side effects** — balance recompute, fan-out, derived/aggregate
state, multi-row atomic operations — MUST live in a Supabase edge function, not
in the client and not as a fat SQL trigger. The client `functions.invoke(...)`
and uses the response.
- `create-transaction` / `delete-transaction` / `create-transfer` recompute
  `bank_accounts.current_balance` server-side. `transaction_service.dart` invokes
  them; never insert into `transactions`/`transfers` directly from the client.
- DB triggers stay thin: `last_update` touch, balance **safety net**, reminder
  **enqueue** into `scheduled_notifications`. `process-reminders` (pg_cron) does
  the FCM fan-out via the `notify` function.
- See `supabase/README.md` and `supabase/SETUP.md`.

### Colors
All hex→Color conversions use `hexToColor(hexString)` from
`lib/core/utils/theme_utils.dart`. Never `Color(int.parse(x.replaceFirst('#', '0xff')))`
or local `_c()`/`_parse()` helpers.

### Spacing in Row / Column
Use the `spacing:` property for the gap between siblings — do NOT insert
`SizedBox(width/height: …)` as a separator. When ONE gap must differ from the
rest, wrap the more-separated child in `Padding(padding: EdgeInsets.only(top: …))`.
`SizedBox` is only for sizing an actual child, never as a spacer.
(Legacy `SizedBox` spacers are migrated incrementally — apply this rule to every
Row/Column you touch.)

### Text inputs
Text inputs use forui `FTextField` / `FTextFormField`. Every input that is **not**
numeric, email, or password sets `textCapitalization: TextCapitalization.sentences`
(or `.words` for names). Numeric/email/password fields use `.none`.
(Existing `CupertinoTextField`s already carry the correct `textCapitalization`;
migrate them to forui `FTextField` as you touch them.)

### Naming convention — Supabase vs Dart

Supabase (DB columns, JSON keys, edge function bodies) = **snake_case**.
Dart (fields, variables, params) = **camelCase**.
Mappers (`lib/data/mappers/`) are the boundary — they translate between the two.
Never use snake_case in Dart code or camelCase in SQL/JSON.

### Refresh indicators — Cupertino only

All pull-to-refresh uses `CupertinoSliverRefreshControl` inside a
`CustomScrollView`. Never use the Material `RefreshIndicator` widget.

- `CupertinoPushedRouteShell(onRefresh: ...)` handles this automatically
  when `childIsScrollable: false` (default).
- `SliverPushedRouteShell(onRefresh: ...)` places the control as the first
  sliver (before the pinned `SliverAppBar`).

### Buttons

Use `AnimatedButton` (spring-physics pressable container) for all tappable
elements. Never use `CupertinoButton(` directly — it has been fully migrated.
`CupertinoButton.filled(...)` is the only remaining exception (primary action
buttons in forms).

### Glass FAB

The transaction FAB uses `GlassFab` from
`lib/presentation/widgets/common/glass_fab.dart`:
`ClipOval → BackdropFilter(blur 22)`, accent fill alpha 0.6, hairline white
border 0.25. Never use `liquid_glass_easy` (removed from pubspec).

### Money model

Payment cards exist (`payment_cards` table). Each `bank_account` can have 0..N
cards; at most one is `is_primary` per account (partial unique index).
`transactions.payment_card_id` is optional (nullable FK → `payment_cards`).
The `CardNetwork` enum covers: visa, mastercard, amex, maestro, unionpay,
discover, other.

## Data model (quick reference)

Tables (see `supabase/migrations/0002_tables.sql` for columns):
`profiles`, `households`, `household_members`, `financial_institutions`,
`bank_accounts`, `account_members`, `payment_cards`, `categories`,
`transaction_sources`, `transactions`, `transfers`, `financial_goals`,
`goal_contributions`, `cars`, `car_members`, `car_maintenance_records`,
`fuel_entries`, `pets`, `pet_health_records`, `pet_measurements`, `homes`,
`shopping_lists`, `shopping_list_items`, `shopping_sessions`, `appointments`,
`appointment_pets`, `google_credentials`, `notifications`,
`notification_settings`, `device_tokens`, `scheduled_notifications`,
`app_versions`.

- **Timestamps are unix seconds (`bigint`)** everywhere EXCEPT `appointments`,
  which uses `timestamptz` (the appointment service serialises ISO-8601 strings).
- `transactions`: `bank_account_id` (required), `payment_card_id` (optional),
  `transaction_source_id`, `category_id`, `amount`, `currency`,
  `type` (income|expense|adjustment), `latitude`/`longitude`,
  `pet_id`/`car_id`/`home_id`.
- `transaction_sources` carry an optional location (lat/lng/address) — a source
  IS its place.
- RLS scopes rows by household membership (`is_household_member`); per-user tables
  (`notifications`, `device_tokens`, `notification_settings`) scope by `auth.uid()`.

## Common widgets
- `showAppBottomSheet(...)` + `AppSheetShell` — `lib/presentation/widgets/common/bottom_sheet.dart`. All pickers/forms-in-sheets use this.
- `AnimatedPillTabs` — `lib/presentation/widgets/common/animated_pill_tabs.dart` — segmented selectors.
- `CupertinoPushedRouteShell` — pushed-route chrome; `onRefresh` for Cupertino pull-to-refresh, `isLoading` for Skeletonizer, `childIsScrollable` when caller owns the scroll view.
- `SliverPushedRouteShell` — entity detail pages with collapsing header; `onRefresh` (first sliver), `isLoading` for Skeletonizer.
- `GlassFab` — `lib/presentation/widgets/common/glass_fab.dart` — glass circular FAB.
- Fixed-center-pin location picker — `transaction_map_picker_screen.dart` (reused by appointments).

## Verifying
`flutter analyze` must be clean. To run the backend, follow `supabase/SETUP.md`.
