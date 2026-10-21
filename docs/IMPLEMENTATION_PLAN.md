# AssureKit implementation plan

Owner: Malikan Inc. · Started: 2026-10-16 · Companion to [ROADMAP.md](../ROADMAP.md)

This plan takes AssureKit from an empty folder in VS Code to v1.0.0 on 2027-05-09. The first two releases are broken down to the issue level; later releases are outlined and get the same breakdown at the start of their phase.

**Capacity assumption:** about 12–15 hours a week (four weekday evenings plus one weekend block). If a phase slips, move its target date in ROADMAP.md and say why. Never back-fill dates. On 2026-10-21 all release targets moved 17 weeks later; see the Schedule changes table in ROADMAP.md.

---

## 1. What the repository must show, and what produces it

| Evidence | What produces it | First available |
| --- | --- | --- |
| Dated releases that match the business plan, starting with v0.1.0, plus a changelog | Git tag → release workflow → GitHub Release with built packages; dated CHANGELOG sections; a Zenodo DOI for each release | v0.1.0, 2027-02-28, then every two weeks |
| Commit history spread over weeks and months | One branch and pull request per issue, three to five working sessions a week, signed commits | First push, this week |
| A working module with tests and passing automated builds | `assurekit-synth` with CI on Python 3.12 and 3.13 and coverage of at least 85%, then `assurekit-eval` | v0.1.0 |
| An open-source licence | `LICENSE` (Apache-2.0) and `NOTICE` in the first commit | First commit |
| README naming Malikan Inc. and AssureKit, explaining the purpose and linking to the roadmap, under a Malikan organization | `README.md`, repository under the Malikan GitHub organization | First push |

The value of this record is that it is genuine. Commit as you actually work. Never backdate commits, rewrite history to look older, or batch a week of work into one commit. GitHub records push times and CI run times independently of commit dates.

---

## 2. Before the first commit

- [ ] **Employer clearance.** You work at a credit union and AssureKit targets credit unions. Get written outside-activity clearance under your employer's policies. Build only on a personal computer and personal accounts, with no employer code, data, configuration or time.
- [ ] **Attorney check.** Confirm with your attorney which repository artifacts they want as exhibits (release pages, CI history, commit graph, Zenodo records) and how to capture them.
- [ ] **GitHub organization.** Create the `malikan-inc` organization at github.com/organizations/plan (Free plan); the repository is `malikan-inc/assurekit`. Add the Malikan website and a contact email to the organization profile, and later verify the Malikan domain under the organization's settings.
- [ ] **Business plan alignment.** Use the same release dates in the business plan as in ROADMAP.md.

---

## 3. Workstation setup (about 1 hour)

### Install tools

macOS (Homebrew):

```bash
brew install git gh uv
brew install --cask visual-studio-code
uv python install 3.13 3.12
```

Windows (PowerShell, then use **Git Bash** for the scripts in this repository):

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id astral-sh.uv -e
winget install --id Microsoft.VisualStudioCode -e
uv python install 3.13 3.12
```

From v0.3.0 you will also need Node.js 24 LTS, pnpm (`corepack enable pnpm`) and Docker Desktop. From v0.5.0, the AWS CLI.

### Sign in and set your identity

```bash
gh auth login                                   # GitHub.com, HTTPS, browser
git config --global user.name  "Ian Diakonov"
git config --global user.email "<the email verified on your GitHub account>"
git config --global init.defaultBranch main
```

### Sign your commits (recommended)

Signed commits show as **Verified** on GitHub, which strengthens the authorship record.

```bash
ssh-keygen -t ed25519 -C "assurekit signing"    # accept the default path
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "AssureKit signing"
```

---

## 4. Create the repository (day 1, about 1 hour)

1. Unzip the starter scaffold into your projects folder and open it: `code assurekit`. Accept the prompt to install the recommended extensions.
2. Install and check everything locally:

   ```bash
   uv sync
   uv run ruff check . && uv run ruff format --check . && uv run mypy && uv run pytest --cov
   ```

   Then open the **Testing** panel in VS Code; it discovers the tests in `packages/`.
3. First commit and push:

   ```bash
   git init
   git add .
   git commit -m "chore: initial AssureKit scaffold with Apache-2.0 licence and CI"
   gh repo create malikan-inc/assurekit --public --source . --push \
     --description "Open-source release assurance for FinTechs and credit unions: test the app, the data and the AI in one pipeline."
   ```

4. Repository settings on GitHub:
   - **About:** add topics `testing`, `qa`, `fintech`, `credit-union`, `ai-evaluation`, `synthetic-data`, `playwright`.
   - **Rules → Rulesets → New branch ruleset** for `main`: require a pull request (0 approvals, since you work alone), require status checks `Python 3.12` and `Python 3.13`, block force pushes.
   - **Security:** enable private vulnerability reporting, Dependabot alerts and secret scanning.
   - **Actions → General:** keep Actions enabled; `release.yml` requests the `contents: write` permission it needs to publish releases.
5. Create labels, dated milestones and the v0.1.0 and v0.2.0 issues:

   ```bash
   bash scripts/bootstrap-github.sh
   ```

6. **Zenodo (do this before v0.1.0).** Sign in at zenodo.org with GitHub, open **GitHub** in your Zenodo account and switch on `malikan-inc/assurekit`. Every GitHub Release from then on gets an archived, citable DOI with its own date. Add the DOI badge to the README after the first release.
7. Confirm the first CI run is green under the **Actions** tab.

---

## 5. Daily workflow in VS Code

One issue, one branch, one pull request:

```bash
git switch -c feat/s01-rng            # branch per issue
# write the test first, then the code; run tests from the Testing panel or:
uv run pytest packages/synth -q
uv run ruff format . && uv run ruff check --fix . && uv run mypy
git add -A && git commit -m "feat(synth): add seeded random source"   # small commits
git push -u origin HEAD
gh pr create --fill --body "Closes #1"
gh pr checks --watch && gh pr merge --squash --delete-branch
git switch main && git pull
```

- **End every working session with a pushed commit,** even if the issue is not finished (push the branch, keep the PR as draft).
- **Copilot:** `.github/copilot-instructions.md` gives Copilot the project rules (seeded randomness, integer cents, no real data). In Copilot Chat, attach the files the change touches with `#file:` and ask for one function plus its tests at a time. Read every line before committing.
- **Commit messages:** Conventional Commits with a scope, for example `feat(synth): …`, `test(eval): …`, `docs: …`, `ci: …`.
- **Changelog:** add a line under **Unreleased** in the same pull request as any user-visible change.

---

## 6. v0.1.0 — `assurekit-synth` (2026-10-17 to 2027-02-28)

### Package layout

```text
packages/synth/
├── pyproject.toml
├── README.md
├── src/assurekit_synth/
│   ├── __init__.py            # __version__, OUTPUT_FORMAT_VERSION = 1
│   ├── __main__.py            # python -m assurekit_synth           (S-10)
│   ├── rng.py                 # SeededRng                           (S-01)
│   ├── money.py               # integer-cent helpers                (S-02)
│   ├── models.py              # Member, Account, CardTransaction…   (S-03)
│   ├── reference.py           # names, states, MCCs, merchants      (S-03)
│   ├── generators/
│   │   ├── members.py         #                                     (S-04)
│   │   ├── accounts.py        #                                     (S-05)
│   │   └── transactions.py    #                                     (S-06)
│   ├── fraud/
│   │   ├── card_testing.py    #                                     (S-07)
│   │   └── account_takeover.py#                                     (S-08)
│   ├── pipeline.py            # generate_dataset(options) -> Dataset
│   ├── writers.py             # JSONL, CSV, manifest.json           (S-09)
│   └── cli.py                 # assurekit-synth                     (S-10)
└── tests/
    ├── golden/seed42.json     #                                     (S-11)
    └── test_*.py
```

### Schedule

| Issue | Work | Target |
| --- | --- | --- |
| S-01 | Seeded random source | Oct 17 |
| S-02 | Money helpers | Oct 18 |
| S-03 | Record models and reference data | Oct 21 – Nov 1 |
| S-04 | Member generator | Nov 2–15 |
| S-05 | Account generator | Nov 16–29 |
| S-06 | Normal card-transaction generator | Nov 30 – Dec 20 |
| S-07 | Fraud pattern: card testing | Dec 21 – Jan 3 |
| S-08 | Fraud pattern: account takeover | Jan 4–17 |
| S-09 | Writers and manifest | Jan 18–31 |
| S-10 | Command-line interface | Feb 1–14 |
| S-11 | Golden-hash determinism and PII guard tests | Feb 15–21 |
| S-12 | Docs and release v0.1.0 | Feb 22–28 |

Acceptance criteria for each issue are in the GitHub issues created by the bootstrap script.

### S-01 and S-02 starter code

These pass `ruff`, `mypy --strict` and `pytest` on Python 3.12 and 3.13 with 100% coverage. Type them in (or paste and read them), then commit each issue separately.

`packages/synth/src/assurekit_synth/rng.py`

```python
"""Seeded randomness. Every random choice in assurekit-synth flows through this module."""

from __future__ import annotations

import hashlib
import math
import random
import uuid
from collections.abc import Sequence


class SeededRng:
    """A reproducible random source that derives independent child streams by name.

    Child streams keep each generator stable when another generator changes:
    adding a field to transactions must not change the members a seed produces.
    """

    def __init__(self, seed: int) -> None:
        self.seed = seed
        self._random = random.Random(seed)

    def derive(self, name: str) -> SeededRng:
        """Return an independent stream for one generator or one record."""
        digest = hashlib.sha256(f"{self.seed}:{name}".encode()).digest()
        return SeededRng(int.from_bytes(digest[:8], "big"))

    def randint(self, low: int, high: int) -> int:
        """Integer in [low, high], both ends included."""
        return self._random.randint(low, high)

    def random(self) -> float:
        """Float in [0.0, 1.0)."""
        return self._random.random()

    def chance(self, probability: float) -> bool:
        """True with the given probability."""
        if not 0.0 <= probability <= 1.0:
            raise ValueError(f"probability must be in [0, 1], got {probability}")
        return self._random.random() < probability

    def choice[T](self, items: Sequence[T]) -> T:
        """One item, uniformly."""
        return self._random.choice(items)

    def weighted_choice[T](self, items: Sequence[T], weights: Sequence[float]) -> T:
        """One item, with the given relative weights."""
        if len(items) != len(weights):
            raise ValueError("items and weights must have the same length")
        return self._random.choices(items, weights=weights, k=1)[0]

    def lognormal_cents(self, median_cents: int, sigma: float) -> int:
        """A positive amount in cents, log-normally spread around a median."""
        if median_cents <= 0:
            raise ValueError("median_cents must be positive")
        value = self._random.lognormvariate(math.log(median_cents), sigma)
        return max(1, round(value))

    def uuid4(self) -> uuid.UUID:
        """A reproducible version-4 UUID (never use uuid.uuid4() in generators)."""
        return uuid.UUID(int=self._random.getrandbits(128), version=4)
```

`packages/synth/tests/test_rng.py`

```python
import uuid

import pytest
from hypothesis import given
from hypothesis import strategies as st

from assurekit_synth.rng import SeededRng


def test_same_seed_gives_same_sequence() -> None:
    a, b = SeededRng(42), SeededRng(42)
    assert [a.randint(0, 10**9) for _ in range(100)] == [b.randint(0, 10**9) for _ in range(100)]


def test_different_seeds_differ() -> None:
    assert SeededRng(1).randint(0, 10**9) != SeededRng(2).randint(0, 10**9)


def test_derived_streams_are_independent_of_parent_use() -> None:
    parent = SeededRng(42)
    before = parent.derive("members").randint(0, 10**9)
    parent.randint(0, 10)  # consuming the parent must not move a derived stream
    after = parent.derive("members").randint(0, 10**9)
    assert before == after


def test_derived_streams_differ_by_name() -> None:
    rng = SeededRng(42)
    assert rng.derive("members").randint(0, 10**9) != rng.derive("accounts").randint(0, 10**9)


def test_uuid4_is_reproducible_and_version_4() -> None:
    value = SeededRng(7).uuid4()
    assert value == SeededRng(7).uuid4()
    assert value.version == 4
    assert isinstance(value, uuid.UUID)


def test_weighted_choice_rejects_mismatched_lengths() -> None:
    with pytest.raises(ValueError):
        SeededRng(1).weighted_choice(["a", "b"], [1.0])


def test_chance_rejects_bad_probability() -> None:
    with pytest.raises(ValueError):
        SeededRng(1).chance(1.5)


@given(seed=st.integers(min_value=0, max_value=2**63), median=st.integers(1, 1_000_000))
def test_lognormal_cents_is_positive_int(seed: int, median: int) -> None:
    value = SeededRng(seed).lognormal_cents(median, 0.8)
    assert isinstance(value, int)
    assert value >= 1


def test_helpers_stay_in_range() -> None:
    rng = SeededRng(3)
    assert 0.0 <= rng.random() < 1.0
    assert rng.chance(1.0) is True
    assert rng.chance(0.0) is False
    assert rng.choice(["a", "b", "c"]) in {"a", "b", "c"}
    assert rng.weighted_choice(["x", "y"], [0.0, 1.0]) == "y"


def test_lognormal_cents_rejects_non_positive_median() -> None:
    with pytest.raises(ValueError):
        SeededRng(1).lognormal_cents(0, 0.5)
```

`packages/synth/src/assurekit_synth/money.py`

```python
"""Money helpers. Amounts are always integer cents; floats never touch money."""

from decimal import Decimal, InvalidOperation


def dollars_to_cents(amount: str) -> int:
    """Convert a decimal string such as "12.34" to 1234 cents.

    Takes a string, not a float, so no binary rounding error can enter.
    Rejects more than two decimal places.
    """
    try:
        value = Decimal(amount)
    except InvalidOperation as exc:
        raise ValueError(f"not a decimal amount: {amount!r}") from exc
    if not value.is_finite():
        raise ValueError(f"not a finite amount: {amount!r}")
    cents = value * 100
    if cents != cents.to_integral_value():
        raise ValueError(f"more than two decimal places: {amount!r}")
    return int(cents)


def format_cents(cents: int) -> str:
    """Format 123456 as "$1,234.56" and -5 as "-$0.05"."""
    sign = "-" if cents < 0 else ""
    dollars, remainder = divmod(abs(cents), 100)
    return f"{sign}${dollars:,}.{remainder:02d}"
```

`packages/synth/tests/test_money.py`

```python
import pytest
from hypothesis import given
from hypothesis import strategies as st

from assurekit_synth.money import dollars_to_cents, format_cents


@pytest.mark.parametrize(
    ("text", "cents"),
    [("0", 0), ("0.01", 1), ("12.34", 1234), ("-5.5", -550), ("1000000", 100_000_000)],
)
def test_dollars_to_cents(text: str, cents: int) -> None:
    assert dollars_to_cents(text) == cents


@pytest.mark.parametrize("text", ["1.234", "abc", "NaN", "Infinity", ""])
def test_dollars_to_cents_rejects_bad_input(text: str) -> None:
    with pytest.raises(ValueError):
        dollars_to_cents(text)


@pytest.mark.parametrize(
    ("cents", "text"),
    [(0, "$0.00"), (5, "$0.05"), (-5, "-$0.05"), (123456, "$1,234.56")],
)
def test_format_cents(cents: int, text: str) -> None:
    assert format_cents(cents) == text


@given(st.integers(min_value=-(10**12), max_value=10**12))
def test_round_trip(cents: int) -> None:
    text = format_cents(cents).replace("$", "").replace(",", "")
    assert dollars_to_cents(text) == cents
```

### Design notes for S-03 to S-11

**Models (S-03).** `@dataclass(frozen=True, slots=True)` records. Suggested fields:

| Record | Fields |
| --- | --- |
| `Member` | `member_id`, `first_name`, `last_name`, `email`, `phone`, `state`, `joined_on`, `segment` |
| `Account` | `account_id`, `member_id`, `type` (share_savings, checking, credit_card, auto_loan), `opened_on`, `balance_cents`, `credit_limit_cents`, `card_token` |
| `CardTransaction` | `txn_id`, `account_id`, `card_token`, `ts`, `amount_cents`, `mcc`, `merchant`, `channel`, `state`, `device_id`, `approved`, `is_fraud`, `fraud_case_id` |
| `FraudLabel` | `fraud_case_id`, `pattern`, `account_id`, `first_ts`, `last_ts`, `txn_ids` |

**Spending profile (S-06).** Keep the table in `reference.py` so it is easy to review:

| MCC | Category | Median (cents) |
| --- | --- | --- |
| 5411 | Grocery stores | 6,500 |
| 5541 | Service stations | 4,500 |
| 5812 | Restaurants | 3,500 |
| 4121 | Taxis and rideshare | 1,800 |
| 5999 | Miscellaneous retail | 2,500 |
| 5732 | Electronics stores | 15,000 |

Number of transactions per card per day: `weighted_choice([0, 1, 2, 3], [0.35, 0.35, 0.2, 0.1])`. Time of day: random seconds from midnight UTC on that day.

**Order of generation (pipeline).** Members, then accounts, then normal transactions, then each fraud injector on its own stream (`rng.derive("fraud:card_testing")`), then sort by `(ts, txn_id)`. Each generator calls `rng.derive(<its name>)` once at the top and never touches the parent stream.

**Determinism (S-09, S-11).** JSON with `sort_keys=True`, `ensure_ascii=False`, `separators=(",", ":")`, newline `\n`; files opened with `newline=""` for CSV. The manifest records options and hashes, never the run time. The golden test generates `--members 50 --seed 42` into `tmp_path` and compares hashes with `tests/golden/seed42.json`; `scripts/update_golden.py` rewrites the file on purpose, and that pull request must also bump `OUTPUT_FORMAT_VERSION` and note it in the changelog.

**PII guard (S-11).** One test scans every output file and fails on `\b\d{3}-\d{2}-\d{4}\b` (SSN-like), `\b\d{16}\b` (card-like) or any email not ending in `@example.com`.

**CLI (S-10).** `argparse`; `main(argv: list[str] | None = None) -> int`; defaults `--members 100 --seed 42 --fraud-rate 0.02 --start 2026-01-01 --days 30 --format jsonl`. Uncomment `[project.scripts]` in `packages/synth/pyproject.toml`.

### Copilot prompts that work well

- *S-03:* "Using #file:rng.py and the field table in #file:IMPLEMENTATION_PLAN.md, write models.py with frozen, slotted dataclasses and a `to_dict()` that keeps field order. Then write tests."
- *S-04:* "Write `generate_members(rng: SeededRng, count: int, start: date) -> list[Member]` in generators/members.py. Use `rng.derive('members')`. Emails must be `@example.com`, phones `555-01xx`. Add tests for those rules and for same-seed equality."
- *S-07:* "Write `inject_card_testing(rng, accounts, transactions, rate) -> tuple[list[CardTransaction], list[FraudLabel]]` following issue S-07's acceptance criteria. Do not modify existing rows."

---

## 7. v0.2.0 — `assurekit-eval` (2027-03-01 to 2027-03-14)

### Schedule

| Issue | Work | Target |
| --- | --- | --- |
| E-01 | Package skeleton and workspace wiring | Mar 1 |
| E-02 | Golden dataset format, loader, sample policy-QA dataset | Mar 2 |
| E-03 | Provider interface and offline mock provider | Mar 3 |
| E-04 | Deterministic metrics | Mar 4–5 |
| E-05 | Groundedness overlap metric | Mar 6 |
| E-06 | Judge interface and mock judge | Mar 7 |
| E-07 | Judge calibration report | Mar 8 |
| E-08 | Runner and thresholds | Mar 9 |
| E-09 | Results JSON and JUnit reporters | Mar 10 |
| E-10 | Command-line interface | Mar 11 |
| E-11 | Optional live provider adapter | Mar 12 |
| E-12 | Docs and release v0.2.0 | Mar 13–14 |

### Wiring the second package (E-01)

In the root `pyproject.toml`:

```toml
[project]
dependencies = ["assurekit-synth", "assurekit-eval"]

[tool.uv.sources]
assurekit-synth = { workspace = true }
assurekit-eval = { workspace = true }

[tool.uv.workspace]
members = ["packages/synth", "packages/eval"]

[tool.ruff.lint.isort]
known-first-party = ["assurekit_synth", "assurekit_eval"]

[tool.mypy]
files = ["packages/synth/src", "packages/eval/src"]

[tool.pytest.ini_options]
markers = ["live: calls a real model provider; skipped in CI"]
addopts = "-ra --strict-markers --import-mode=importlib -m 'not live'"

[tool.coverage.run]
source_pkgs = ["assurekit_synth", "assurekit_eval"]
```

Add `jsonschema` to the dev dependency group (schema validation in tests) and `pydantic>=2` to `packages/eval/pyproject.toml`. In `.github/workflows/release.yml`, add a second build line: `uv build --package assurekit-eval --out-dir dist`. Run `uv lock` and commit the lock file.

### Package layout

```text
packages/eval/src/assurekit_eval/
├── dataset.py         # pydantic models + JSONL loader         (E-02)
├── providers/
│   ├── base.py        # Provider protocol, Response           (E-03)
│   ├── mock.py        # fixtures-driven, offline              (E-03)
│   └── bedrock.py     # optional extra, live only             (E-11)
├── metrics/
│   ├── deterministic.py                                       (E-04)
│   └── groundedness.py                                        (E-05)
├── judges/
│   ├── base.py        # Judge protocol, MockJudge             (E-06)
│   └── calibration.py # agreement, kappa, confusion matrix    (E-07)
├── runner.py          # dataset × provider × metrics → results (E-08)
├── thresholds.py      # TOML via tomllib                      (E-08)
├── reporters.py       # results JSON v1, JUnit XML            (E-09)
└── cli.py             # assurekit-eval run | calibrate        (E-10)
datasets/assurebank-policy-qa.jsonl                            (E-02)
```

### Design notes

- **Sample dataset (E-02).** Write two synthetic fee schedules, `fees-v1` and `fees-v2` (v2 supersedes v1). Twenty questions whose correct answers exist only in v2. This is the seed of the `OUTDATED_POLICY_DOC` seam test in v0.4.0.
- **Mock provider (E-03).** A fixtures file maps case IDs to responses, including deliberately wrong ones (cites v1, leaks a fake SSN, fails to refuse), so every metric is exercised offline.
- **Calibration (E-07).** Cohen's kappa for judge versus human labels, where `p_o` is the observed agreement and `p_e` the agreement expected by chance from each rater's label frequencies:

  ```math
  \kappa = \frac{p_o - p_e}{1 - p_e}
  ```

  A judge below the threshold (default 0.6) is reported as untrusted and cannot gate a release.
- **Thresholds (E-08).** Example `thresholds.toml`:

  ```toml
  [metrics]
  citation_version_match = { min_pass_rate = 0.95 }
  pii_leak = { max_fail_count = 0 }
  groundedness_overlap = { min_mean = 0.7 }
  ```

---

## 8. Release checklist (every release)

1. All issues in the milestone closed; CI green on `main`.
2. On a `release/vX.Y.Z` branch:
   - Set the version in every `packages/*/pyproject.toml` to `X.Y.Z` (all packages share the repository version).
   - CHANGELOG: rename **Unreleased** to `## [X.Y.Z] - <today>`, add a fresh empty **Unreleased** above it, update the compare links at the bottom.
   - CITATION.cff: set `version` and `date-released`.
   - README status table and ROADMAP (add "shipped <date>" to the release row; update "Last updated").
3. Pull request, merge when green.
4. Tag and push:

   ```bash
   git switch main && git pull
   git tag -a vX.Y.Z -m "AssureKit vX.Y.Z"      # signed automatically if tag.gpgsign is on
   git push origin vX.Y.Z
   ```

5. Watch the **release** workflow; check the GitHub Release has the wheel, the source archive and the changelog notes.
6. Check Zenodo minted a DOI; add or update the README badge.
7. Fresh-clone test of the README quick start in a new folder.
8. Bump packages to the next development version (`X.Y+1.0.dev0`) in a follow-up commit.
9. Optional: post a short release note on LinkedIn linking to the release page.

**Optional, from v0.2.0: PyPI.** Create a PyPI account, add a *pending trusted publisher* for `malikan-inc/assurekit` and workflow `release.yml`, then add a publish job using `pypa/gh-action-pypi-publish` with `id-token: write`. Public download pages give a second, independent dated record.

---

## 9. v0.3.0 to v1.0.0 (outline; detail each at the start of its phase)

| Release | Target | Main work | Exit gate |
| --- | --- | --- | --- |
| v0.3.0 | Mar 28 | **AssureBank local mode:** TypeScript on Node 24; Hono API (the same handlers later run on AWS Lambda); React + Vite web UI; repository interface with an in-memory store; policy chatbot stub using keyword retrieval over the v1/v2 fee documents; fixed-weight fraud score with a version string; OpenTelemetry with a file span exporter for CI. **`@assurekit/flows`:** Playwright fixtures, `login()` and `transferFunds()` business tasks, role and test-id locators only (enforced with `eslint-plugin-playwright`). **`@assurekit/contracts`:** OpenAPI 3.1 document for AssureBank, response validation, breaking-change check with `oasdiff`. Add a pnpm workspace and a Node job to CI. | **G1:** `pnpm dev` starts AssureBank; flows pass in CI |
| v0.4.0 | Apr 11 | Three fault switches as environment flags; seam tests that read the span file by correlation ID; `assurekit-redteam` (Python) probes tagged with OWASP IDs; governed agent definitions in `packages/agents` (run `npx playwright init-agents --loop=vscode`, then add the ADR 0003 rules); CycloneDX ML-BOM for the fraud model and the chatbot | **G2:** CI fails each fault switch at the expected gate |
| v0.5.0 | Apr 25 | `@assurekit/evidence`: collect results JSON, JUnit, SARIF and SBOM; map tags to control IDs from YAML mapping packs (identifiers only); sign the bundle with Sigstore in GitHub Actions; AWS CDK deployment of AssureBank | Every CI run on `main` produces a bundle that verifies |
| v1.0.0 | May 9 | Documentation site on GitHub Pages; OpenSSF Scorecard workflow and badge; demo video of the fault switches; an outside engineer runs the quick start | **G3:** quick start completed unaided by someone who did not build it |

---

## 10. Weekly rhythm

| When | What |
| --- | --- |
| Mon–Thu evening, about 2 h | One issue or part of one; end with a pushed commit |
| Weekend, about 4 h | The largest issue of the week, or release work |
| Friday, 15 min | Close finished issues, check the milestone burndown, update ROADMAP.md if a date moves |
| Each release | Release checklist (section 8) |

## 11. Definition of done (every issue)

- [ ] Tests written first or alongside, and passing on Python 3.12 and 3.13
- [ ] `ruff`, `ruff format --check` and `mypy --strict` clean
- [ ] Coverage at or above 85%
- [ ] Synthetic data only
- [ ] CHANGELOG line under **Unreleased** for user-visible changes
- [ ] Pull request merged with green CI, issue closed
