# Contributing to AssureKit

Thanks for helping. AssureKit is maintained by Malikan Inc. and released under the Apache-2.0 licence; by contributing you agree your contribution is licensed the same way.

## Ground rules

- **Synthetic data only.** Never commit real member, customer or employer data, credentials or configuration.
- **Money is integers.** Amounts are integer cents.
- **Tests with every change.** CI must be green before merge.
- **Small pull requests.** One issue per pull request where possible.

## Development setup

```bash
uv sync               # installs the workspace and dev tools into .venv
uv run pytest         # tests
uv run ruff check .   # lint
uv run ruff format .  # format
uv run mypy           # type check
```

## Commits and branches

- Branch names: `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/): `feat(synth): add card-testing fraud pattern`.
- Reference the issue in the pull request description (`Closes #12`).

## Releases

Maintainers cut releases by tag (`vX.Y.Z`) after updating [CHANGELOG.md](CHANGELOG.md). The release workflow builds packages and publishes the GitHub Release.
