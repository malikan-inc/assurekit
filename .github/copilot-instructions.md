# AssureKit — instructions for AI coding assistants

AssureKit is Malikan Inc.'s open-source toolkit for testing applications, data and AI together in FinTech and credit-union release pipelines. Follow these rules for every suggestion.

## Hard rules

- Never use real personal, member or financial data. Generate synthetic values only: emails at `example.com`, phone numbers `555-0100` to `555-0199`, no government ID numbers, no real card numbers.
- Money is always integer cents (`amount_cents: int`). Never `float` for money.
- All randomness flows from an explicit seed through `assurekit_synth.rng`. Never call `random.random()` or `uuid4()` directly in generators; same seed must give byte-identical output.
- No network calls in unit tests. Model providers are mocked unless a test is marked `@pytest.mark.live`.

## Python conventions

- Python 3.12+, type hints everywhere, `mypy --strict` clean.
- Formatting and linting by Ruff (line length 100).
- Frozen dataclasses with `slots=True` for records.
- Standard library first; add a dependency only with a reason in the pull request.
- Tests live in `packages/<name>/tests/`, use pytest, and name the behaviour: `test_same_seed_gives_identical_output`.

## Commits

Conventional Commits with a package scope: `feat(synth): ...`, `test(eval): ...`, `docs: ...`.

## When unsure

Ask in the pull request rather than guessing. Prefer a smaller, well-tested change.
