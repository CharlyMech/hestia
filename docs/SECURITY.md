# Security Policy

## Supported Versions

Only the latest release from `main`, which is the current TestFlight build, is
supported with security fixes.

## Reporting a Vulnerability

Do not open a public issue for security vulnerabilities.

Report privately by using GitHub Security Advisories or by contacting the
maintainer directly. Include:

- Description and impact.
- Steps to reproduce.
- Affected app version or commit.
- Proof of concept, if available.
- Suggested remediation, if known.

## Response

- Acknowledgement should happen within a few days.
- Confirmed issues receive a fix plan and expected timeline.
- Public disclosure should wait until a fix is available and testers have had a
  reasonable update window.

## Scope

In scope:

- Flutter app source.
- Supabase schema, RLS policies, and Edge Functions.
- Authentication and account management flows.
- TestFlight release pipeline and signing configuration.

Out of scope:

- Supabase, Firebase, MagicLane, Apple, GitHub, and other third-party platform
  vulnerabilities. Report those to the relevant vendor.
