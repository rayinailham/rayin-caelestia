Caelestia CLI override files
============================

These files mirror local patches applied to the installed Caelestia Python CLI.
They keep the wallpaper-derived palette dark-only, preserve saturated subject
accents, and use a larger thumbnail for color extraction.

Copy this tree over the installed `caelestia` Python package after reinstalling
the CLI if the package update overwrites the local runtime changes.

Base: caelestia-cli 1.1.3 (rebased 2026-11-14 from 1.0.8; the old hypr.py Lua hack was dropped because 1.1.3 supports Lua natively).
