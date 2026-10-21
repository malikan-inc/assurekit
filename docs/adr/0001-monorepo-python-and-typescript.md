# ADR 0001: One monorepo, Python and TypeScript packages

- Status: accepted
- Date: 2026-10-16

## Context

AssureKit needs browser and API test tooling (strongest in TypeScript with Playwright) and AI evaluation tooling (strongest in Python). Splitting into many repositories would scatter releases, issues and CI.

## Decision

Keep every package in one repository. Python packages live in a uv workspace; TypeScript packages join a pnpm workspace from v0.3.0. Packages share one results format (`schemas/results.schema.json`) instead of sharing code across languages.

## Consequences

- One roadmap, one changelog, one CI view, one release tag per version.
- CI runs a Python job and, from v0.3.0, a Node job.
- Packages stay independently installable; a team can adopt one without the rest.
