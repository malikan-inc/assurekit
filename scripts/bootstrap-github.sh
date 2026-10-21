#!/usr/bin/env bash
# Creates AssureKit labels, dated milestones and the v0.1.0 and v0.2.0 issues.
# Run once from the repository root after `gh auth login` and the first push.
# Safe to re-run: existing labels are updated, open milestones get the due dates below,
# closed milestones and existing issues are left alone.
set -euo pipefail

gh repo view --json nameWithOwner -q .nameWithOwner >/dev/null || {
  echo "Run this inside the cloned repository after the first push." >&2
  exit 1
}

echo "== Labels"
label() { gh label create "$1" --color "$2" --description "$3" --force >/dev/null; echo "  $1"; }
label "pkg:synth"    "1d76db" "assurekit-synth"
label "pkg:eval"     "5319e7" "assurekit-eval"
label "type:feature" "0e8a16" "New capability"
label "type:test"    "fbca04" "Tests and quality gates"
label "type:docs"    "c5def5" "Documentation"
label "type:release" "b60205" "Release work"

echo "== Milestones"
milestone() {
  local title="$1" due="$2" desc="$3" num state
  read -r num state < <(gh api "repos/{owner}/{repo}/milestones?state=all&per_page=100" \
    -q ".[] | select(.title == \"$title\") | \"\(.number) \(.state)\"") || true
  if [[ -z "${num:-}" ]]; then
    gh api -X POST "repos/{owner}/{repo}/milestones" \
      -f title="$title" -f due_on="${due}T23:59:59Z" -f description="$desc" >/dev/null
    echo "  $title created, due $due"
  elif [[ "$state" == "open" ]]; then
    gh api -X PATCH "repos/{owner}/{repo}/milestones/$num" \
      -f due_on="${due}T23:59:59Z" -f description="$desc" >/dev/null
    echo "  $title updated, due $due"
  else
    echo "  $title closed, left unchanged"
  fi
}
milestone "v0.1.0" "2027-02-28" "Synthetic data: assurekit-synth"
milestone "v0.2.0" "2027-03-14" "LLM evaluation: assurekit-eval"
milestone "v0.3.0" "2027-03-28" "Reference app: AssureBank, flows, contracts (G1)"
milestone "v0.4.0" "2027-04-11" "Seams and red team (G2)"
milestone "v0.5.0" "2027-04-25" "Evidence bundle"
milestone "v1.0.0" "2027-05-09" "General availability (G3)"

echo "== Issues"
# usage: issue <milestone> <labels> <title>  (body on stdin)
issue() {
  local ms="$1" labels="$2" title="$3"
  if gh issue list --state all --limit 500 --json title -q '.[].title' | grep -Fxq "$title"; then
    echo "  exists: $title"
    cat >/dev/null
  else
    gh issue create --milestone "$ms" --label "$labels" --title "$title" --body-file - >/dev/null
    echo "  created: $title"
  fi
}

issue v0.1.0 "pkg:synth,type:feature" "S-01 Seeded random source (rng.py)" <<'EOF'
Implement `SeededRng` in `packages/synth/src/assurekit_synth/rng.py` (starter code in docs/IMPLEMENTATION_PLAN.md).

Acceptance:
- [ ] Same seed gives the same sequence; different seeds differ
- [ ] `derive(name)` streams are independent of parent use and differ by name
- [ ] `uuid4()` is reproducible and version 4
- [ ] 100% branch coverage for rng.py
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-02 Money helpers (integer cents)" <<'EOF'
Implement `dollars_to_cents(str)` and `format_cents(int)` in `money.py`.

Acceptance:
- [ ] Rejects floats-as-strings with more than two decimals, NaN, Infinity and non-numbers
- [ ] Property test: format then parse round-trips for any integer
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-03 Record models and reference data" <<'EOF'
Frozen, slotted dataclasses in `models.py`: `Member`, `Account`, `CardTransaction`, `FraudLabel`; enums for account type, channel and fraud pattern. Static reference data in `reference.py`: synthetic first and last names, US state codes, a short list of public merchant category codes (MCC), fictional merchant names.

Acceptance:
- [ ] Every money field is `int` cents; every timestamp is an ISO-8601 UTC string
- [ ] `to_dict()` gives a stable key order for serialisation
- [ ] No real company names in merchants
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-04 Member generator" <<'EOF'
`generate_members(rng, count, start)` returning members with synthetic name, `@example.com` email, `555-01xx` phone, state, join date and risk segment.

Acceptance:
- [ ] Member IDs are stable for a seed (`MBR-` + zero-padded index)
- [ ] Test: all emails end with `@example.com`; all phones match `^555-01\d\d$`
- [ ] Test: no field matches an SSN-like pattern `\d{3}-\d{2}-\d{4}`
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-05 Account generator" <<'EOF'
`generate_accounts(rng, members)`: every member gets share savings; checking, credit card and auto loan by probability. Opening balances in cents by account type.

Acceptance:
- [ ] Each account belongs to exactly one existing member
- [ ] Credit card accounts carry a credit limit; loan accounts a principal
- [ ] Card numbers are not generated; cards use a synthetic token (`tok_...`)
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-06 Normal card-transaction generator" <<'EOF'
`generate_transactions(rng, accounts, start, days)`: per-card daily spending rate, MCC chosen by weight, amount from `lognormal_cents` with a per-MCC median, channel (in-store, online, contactless), timestamps inside the window.

Acceptance:
- [ ] Timestamps never use the current time; all fall inside `[start, start + days)`
- [ ] Transactions sorted by timestamp, then ID
- [ ] Hypothesis test: amounts are positive ints for any seed
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-07 Fraud pattern: card testing" <<'EOF'
Inject card-testing cases: a burst of 5-20 small (100-500 cents) online authorisations at one merchant within minutes, mostly declined, followed by one large purchase. Every injected row is labelled with `fraud_pattern="card_testing"` and a shared `fraud_case_id`.

Acceptance:
- [ ] Number of affected cards matches `--fraud-rate` within a tested tolerance
- [ ] Non-fraud rows are never labelled; fraud rows always are
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-08 Fraud pattern: account takeover" <<'EOF'
Inject account-takeover cases: a new device ID and a state different from the member's home, then several high-value online purchases within hours. Labelled `fraud_pattern="account_takeover"`.

Acceptance:
- [ ] Each case shows the device and geography shift in the data, so a detector could learn it
- [ ] Labels consistent with S-07 rules
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-09 Writers: JSONL, CSV and manifest" <<'EOF'
Write `members`, `accounts`, `transactions` and `fraud_labels` as JSONL (default) or CSV. Write `manifest.json` with tool version, `OUTPUT_FORMAT_VERSION`, seed, options, row counts and SHA-256 per file.

Acceptance:
- [ ] UTF-8, `\n` line endings, sorted JSON keys, no timestamps of the run itself
- [ ] Re-running with the same options gives identical bytes (test compares hashes)
EOF

issue v0.1.0 "pkg:synth,type:feature" "S-10 Command-line interface" <<'EOF'
`assurekit-synth --members N --seed S --fraud-rate R --start YYYY-MM-DD --days D --format jsonl|csv --out DIR`. Enable the `[project.scripts]` entry in `packages/synth/pyproject.toml`; add `__main__.py`.

Acceptance:
- [ ] `--help` documents every option
- [ ] Bad input exits with code 2 and a clear message
- [ ] Test calls `main([...])` directly and checks output files
EOF

issue v0.1.0 "pkg:synth,type:test" "S-11 Golden-hash determinism and PII guard tests" <<'EOF'
Store expected SHA-256 hashes for `--members 50 --seed 42` in `tests/golden/seed42.json`. Add a helper script to regenerate it on purpose.

Acceptance:
- [ ] Golden test passes on Python 3.12 and 3.13 in CI
- [ ] PII guard scans all generated output for SSN-like and 16-digit card-like patterns
- [ ] Coverage stays at or above 85%
EOF

issue v0.1.0 "pkg:synth,type:release" "S-12 Docs and release v0.1.0" <<'EOF'
Follow the release checklist in docs/IMPLEMENTATION_PLAN.md.

Acceptance:
- [ ] Package README shows a working example
- [ ] CHANGELOG has a dated [0.1.0] section; CITATION.cff version and date updated
- [ ] Tag v0.1.0 pushed; GitHub Release created by the release workflow
- [ ] Quick start verified from a fresh clone
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-01 assurekit-eval package skeleton" <<'EOF'
Create `packages/eval` (src layout, `assurekit_eval`, py.typed, README) and wire it into the uv workspace, mypy files, coverage sources, isort first-party list and release build.

Acceptance:
- [ ] `uv sync --locked` and CI green with both packages
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-02 Golden dataset format and loader" <<'EOF'
JSONL cases: `id`, `input`, optional `context_docs` (id + version + text), `expected` (`must_include`, `must_not_include`, `cite_doc_version`, `should_refuse`), `risk_tags`. Pydantic v2 models and a loader with line-numbered errors. Ship `datasets/assurebank-policy-qa.jsonl`: 20 synthetic fee-schedule questions where v2 of the schedule supersedes v1.

Acceptance:
- [ ] Invalid lines report file and line number
- [ ] Sample dataset loads and validates in a test
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-03 Provider interface and offline mock provider" <<'EOF'
`Provider` protocol: `generate(case) -> Response(text, cited_docs, model_id, latency_ms)`. `MockProvider` returns canned responses from a fixtures file keyed by case ID, including deliberately wrong ones, so every metric has passing and failing examples offline.

Acceptance:
- [ ] No network access in any default test
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-04 Deterministic metrics" <<'EOF'
`contains_all`, `contains_none`, `exact_match`, `citation_version_match`, `refusal_detected`, `pii_leak` (SSN-like, card-like, email outside example.com).

Acceptance:
- [ ] Each metric returns a typed result with value and explanation
- [ ] Parametrised tests with passing and failing cases for each
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-05 Groundedness overlap metric" <<'EOF'
Deterministic groundedness proxy: share of answer content tokens found in the cited context documents, with a stop-word list. Document that it is a proxy, not a judge.

Acceptance:
- [ ] Unit tests for fully grounded, partly grounded and ungrounded answers
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-06 Judge interface and mock judge" <<'EOF'
`Judge` protocol: `judge(case, response) -> Verdict(label, score, rationale)`. `MockJudge` driven by fixtures for offline CI.

Acceptance:
- [ ] Judge results are recorded with judge model ID and prompt version
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-07 Judge calibration report" <<'EOF'
Compare judge verdicts with human labels (JSONL): agreement rate, Cohen's kappa, precision and recall per label, confusion matrix. A judge whose kappa is below the configured threshold (default 0.6) is reported as untrusted and cannot gate a release.

Acceptance:
- [ ] Kappa implementation tested against hand-computed examples
- [ ] Report written as JSON and Markdown
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-08 Evaluation runner and thresholds" <<'EOF'
Run a dataset through a provider, metrics and optional trusted judges. A TOML thresholds file (read with the standard-library `tomllib`) decides pass or fail per metric and overall.

Acceptance:
- [ ] Exit code 0 when all thresholds pass, 1 when any fails
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-09 Reporters: results JSON and JUnit" <<'EOF'
Write results in `assurekit.results/v1` (validated against `schemas/results.schema.json` in tests) and JUnit XML so any CI shows failures.

Acceptance:
- [ ] Schema validation test passes for a full run
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-10 Command-line interface" <<'EOF'
`assurekit-eval run --dataset FILE --provider mock --thresholds FILE --out DIR` and `assurekit-eval calibrate --judgements FILE --labels FILE`.

Acceptance:
- [ ] `--help` documents every option; tests call `main([...])`
EOF

issue v0.2.0 "pkg:eval,type:feature" "E-11 Optional live provider adapter" <<'EOF'
An Amazon Bedrock provider behind an optional extra (`assurekit-eval[bedrock]`). Tests marked `@pytest.mark.live` and skipped unless enabled.

Acceptance:
- [ ] CI never needs credentials
EOF

issue v0.2.0 "pkg:eval,type:release" "E-12 Docs and release v0.2.0" <<'EOF'
Follow the release checklist in docs/IMPLEMENTATION_PLAN.md.

Acceptance:
- [ ] Tutorial: run the sample policy-QA evaluation offline in under 2 minutes
- [ ] Dated [0.2.0] CHANGELOG section; GitHub Release created
EOF

echo "Done."
