# AssureKit Roadmap

Maintained by Malikan Inc. Target dates are planning dates. When a release ships, its actual date is recorded in [CHANGELOG.md](CHANGELOG.md) and on the GitHub Releases page; a slipped date is updated here, never back-filled.

Last updated: 2026-10-21

## Release plan

| Release | Target date | Theme | Scope | Exit gate |
| --- | --- | --- | --- | --- |
| v0.1.0 | 2027-02-28 | Synthetic data | `assurekit-synth`: seeded members, accounts and card transactions; card-testing and account-takeover fraud patterns; JSONL/CSV output with manifest; CLI; CI | CI green on `main`; same seed gives byte-identical output; quick start works from a clean clone |
| v0.2.0 | 2027-03-14 | LLM evaluation | `assurekit-eval`: golden-dataset format, deterministic metrics, LLM-judge interface with calibration report, offline mock provider, JSON and JUnit reporters; shared results schema v1 | Full eval suite runs offline in CI with no API keys |
| v0.3.0 | 2027-03-28 | Reference app | AssureBank local mode (API, web UI, ledger, policy chatbot stub, fraud scoring); `@assurekit/flows` login and transfer; `@assurekit/contracts` | **G1:** AssureBank starts with one command and its flows pass in CI |
| v0.4.0 | 2027-04-11 | Seams and red team | Three fault switches; seam test packs with OpenTelemetry trace assertions; `assurekit-redteam`; governed agent definitions; CycloneDX ML-BOM export | **G2:** CI catches all three fault switches |
| v0.5.0 | 2027-04-25 | Evidence | `@assurekit/evidence`: control-mapped, signed evidence bundle; framework mapping packs (identifiers only); AWS deployment of AssureBank | Every CI run on `main` emits a verifiable bundle |
| v1.0.0 | 2027-05-09 | General availability | Hardening, documentation site, OpenSSF Scorecard, demo walkthrough | **G3:** an outside engineer completes the quick start unaided |

## Schedule changes

| Date | Change | Reason |
| --- | --- | --- |
| 2026-10-21 | All release targets moved 17 weeks later: v0.1.0 from 2026-11-01 to 2027-02-28, v1.0.0 from 2027-01-10 to 2027-05-09 | <!-- TODO: add reason --> |

## After v1.0.0

- `@assurekit/mobile`: native iOS and Android flows through Appium, behind the same flow interface
- Additional model-provider and evaluator adapters
- NACHA ACH and ISO 20022 payment-message generators in `assurekit-synth`
- Production monitoring recipes: drift detection and online evaluation on sampled traces

## How the roadmap relates to AssureStack

| AssureStack stage | AssureKit modules that support it |
| --- | --- |
| Assess | ML-BOM export, maturity scorecard templates |
| Design | Test-intent format, risk and control tags |
| Automate | `@assurekit/flows`, `@assurekit/contracts`, `assurekit-synth` |
| Evaluate | `assurekit-eval`, `assurekit-redteam` |
| Monitor | Trace assertions reused on production samples |
| Transfer | Documentation, AssureBank tutorials, evidence bundle |
