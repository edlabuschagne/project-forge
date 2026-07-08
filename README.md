# Project Forge

A model-agnostic methodology for building software with AI — plan in chat, execute in a
coding harness, and never trust "done" without independent verification.

Forge exists to kill one failure mode: **"looks done but isn't"** — an AI implementer
confidently reports a milestone complete, and three milestones later the fudged detail
surfaces as a real bug in cold, expensive-to-fix context. The fix is structural: separate
building from verifying, gate every milestone through an independent Verifier in a fresh
context, and keep multi-session builds coherent with structured handoffs.

It's built for anyone building with AI — from people who've never written a line of code
to engineers who architect systems for a living. To watch the gate catch real defects on
a real build (a fabricated deploy screenshot; a production site that sat blank behind
four green checks), read the launch write-up:
[The AI said it was done. It wasn't. Three times.](https://dev.to/elabuschagne/the-ai-said-it-was-done-it-wasnt-three-times-5l1)

## Start here

| File | What it is |
|---|---|
| [PROJECT_FORGE.md](PROJECT_FORGE.md) | **The anchor.** Principles, workflow, tiers, document templates, the Verifier gate. If the docs ever disagree, this one wins. |
| [VERIFICATION.md](VERIFICATION.md) | The gate spec — eight checks, one spec with two readers (the executor's self-check and the independent Verifier). |
| [FORGE_AUTONOMOUS_MODE.md](FORGE_AUTONOMOUS_MODE.md) | The autonomous profile: what changes when running with minimal human gating — the run loop, stop rules, tripwires. |
| [harness/](harness/README.md) | Reference implementation of the Forge harness for Claude Code — gate command, hooks, deny baseline. Copied in at Milestone 0. |
| [evals/verifier/](evals/verifier/README.md) | The eval set that verifies the Verifier itself — drift detection in both directions. |
| [PARKED_RESEARCH.md](PARKED_RESEARCH.md) | The triaged research backlog — adopted, parked with thresholds, or studied and rejected. |
| [CHANGELOG.md](CHANGELOG.md) | Version history. The canonical version lives in PROJECT_FORGE.md. |

## Using it

There is nothing to install — Forge is a set of documents, not a tool.

1. Drop `PROJECT_FORGE.md` into your planning chat (a Claude.ai Project, or any capable
   chat model) and share your idea. It briefs the model to run a structured planning
   session and draft your project's document set.
2. Move the drafted docs into your build repo and run **Milestone 0** — the bootstrap
   that sets up the repo, toolchain, and harness. In Claude Code, copy the reference
   `harness/` folder in rather than re-deriving it.
3. Build one milestone at a time. Every milestone ends at the gate: full battery,
   captured observable outcomes, and an independent Verifier in a fresh context.
   No evidence, no pass.
4. Want minimal human gating? Read `FORGE_AUTONOMOUS_MODE.md` first — especially
   the tripwires.

The methodology is model-agnostic by design — harness-specific material is quarantined
into clearly-marked appendices and the `harness/` folder, and the core never depends on it.

## License

MIT — see [LICENSE](LICENSE).