# CLAUDE.md — Project Forge

This repo **is** the Forge methodology. It is not a project built with Forge — it is where
Forge is authored and versioned. Read this before editing anything here.

## What Forge is

Project Forge is a model-agnostic, AI-assisted development methodology for planning software
in chat and executing it in a coding harness. It exists to kill the "looks done but isn't"
failure mode by separating building from verifying and keeping multi-session builds coherent
through structured handoffs. The full statement of the methodology is in `PROJECT_FORGE.md`.

## The three docs and how they relate

- **`PROJECT_FORGE.md` — the anchor.** The base methodology: principles, workflow, tiers,
  document templates, the Verifier gate, core principles. Everything else extends this.
- **`VERIFICATION.md` — the gate spec.** The checklist with two readers (the executor's
  self-check and the independent Verifier at the gate). It expands the gate that
  `PROJECT_FORGE.md` introduces.
- **`FORGE_AUTONOMOUS_MODE.md` — the autonomous profile.** Describes only what *changes*
  when running with minimal human gating; the base methodology still holds unless this file
  overrides it. Read it alongside `PROJECT_FORGE.md`, not instead of it.

If the three ever disagree, `PROJECT_FORGE.md` is the anchor and wins.

## Canonical version

The canonical methodology version lives in **`PROJECT_FORGE.md`** (the `**Forge vX.Y**` line
near the top). `CHANGELOG.md` records the history of changes. The methodology is currently at
**v1.9**. When citing or bumping the version, treat `PROJECT_FORGE.md` as the single source of
truth; update `CHANGELOG.md` in the same change.

## Standing working rule — permanent, every session

**Before writing or editing ANY file in this repo, show the proposed change as a diff and
wait for explicit approval. Propose, then pause. Never write unprompted.**

This applies to every file — the methodology docs, this file, the changelog, everything — and
for the entire life of this repo, not just one session. When in doubt, propose and wait.
