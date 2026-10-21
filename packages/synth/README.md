# assurekit-synth

Seeded synthetic financial test data for FinTech and credit-union QA. Part of [AssureKit](../../README.md), maintained by Malikan Inc.

**Status:** in development, first release planned as v0.1.0. See the [roadmap](../../ROADMAP.md).

## What it will generate (v0.1.0)

- Members with synthetic names, `@example.com` emails and fictional `555-01xx` phone numbers
- Accounts: share savings, checking, credit card, auto loan
- Card transactions with amounts in integer cents, merchant category codes and channels
- Labelled fraud patterns: card testing and account takeover
- JSONL or CSV output plus a `manifest.json` (seed, version, row counts, SHA-256 of each file)

## Guarantees

- **Reproducible:** the same seed and options produce byte-identical files.
- **No real PII:** no government ID numbers, no real card numbers, reserved domains and number ranges only.
- **No floats for money:** every amount is an integer number of cents.
