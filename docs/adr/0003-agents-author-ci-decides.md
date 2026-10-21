# ADR 0003: AI agents author tests; deterministic CI decides releases

- Status: accepted
- Date: 2026-10-16

## Context

Playwright ships planner, generator and healer agents, and coding assistants write much of the test code. A healer that edits a failing test can also hide a real defect.

## Decision

- Agents run at authoring time in the IDE. Their output reaches `main` only through a human-approved pull request.
- The release gate runs plain test code with no model in the loop, except the AI evaluation suites, which run against pinned datasets and, in CI, a deterministic mock provider.
- A CI check rejects any agent change that removes or weakens an assertion.
- Healer changes are limited to locator drift and timing. A suspected product defect becomes a bug report, not a skipped test.

## Consequences

- Release decisions are reproducible and explainable.
- Agent productivity is kept, and every agent change leaves a reviewable record.
