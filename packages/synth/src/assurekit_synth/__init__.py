"""Seeded synthetic financial test data for FinTech and credit-union QA."""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("assurekit-synth")
except PackageNotFoundError:  # pragma: no cover - only in a source tree without install
    __version__ = "0.0.0"

__all__ = ["__version__"]
