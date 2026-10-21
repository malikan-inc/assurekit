# ADR 0002: Synthetic data is seeded and byte-reproducible

- Status: accepted
- Date: 2026-10-16

## Context

Tests built on random data fail in ways nobody can reproduce. Financial test data must also never contain real personal information.

## Decision

- Every random choice flows through `assurekit_synth.rng.SeededRng`. Generators take child streams with `derive(name)`, so changing one generator does not shift another's output.
- Same seed and options produce byte-identical files on every supported Python version. A golden-hash test in CI enforces this.
- Output never contains the current time; dates are anchored to a `--start` option.
- Amounts are integer cents. Identifiers, names, emails (`example.com`) and phone numbers (`555-0100` to `555-0199`) are synthetic by construction.
- `OUTPUT_FORMAT_VERSION` is bumped, and the change noted in the changelog, whenever the output for an existing seed changes on purpose.

## Consequences

- Any failure can be reproduced from its seed.
- Generator changes need a deliberate golden-hash update, which makes accidental drift visible in review.
