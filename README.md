# Project Forge

A model-agnostic methodology for building software with AI — plan in chat, execute in a
coding harness, and never trust "done" without independent verification.

Forge exists to kill one failure mode: **"looks done but isn't"** — an AI implementer
confidently reports a milestone complete, and three milestones later the fudged detail
surfaces as a real bug in cold, expensive-to-fix context. The fix is structural: separate
building from verifying, gate every milestone through an independent Verifier in a fresh
context, and keep multi-session builds coherent with structured handoffs.

## Start here

| File | What it is |
|---|---|
| [PROJECT_FORGE.md](PROJECT_FORGE.md) | **The anchor.** Principles, workflow, tiers, document templates, the Verifier gate. If the docs ever disagree, this one wins. |
| [VERIFICATION.md](VERIFICATION.md) | The gate spec — eight checks, one spec with two readers (the executor's self-check and the independent Verifier). |
| [FORGE_AUTONOMOUS_MODE.md](FORGE_AUTONOMOUS_MODE.md) | The autonomous profile: what changes when running with minimal human gating — the run loop, stop rules, tripwires. |
| [harness/](harness/README.md) | Reference implementation of the Forge harness for Claude Code — gate command, hooks, deny baseline. Copied in at Milestone 0. |
| [evals/verifier/](evals/verifier/README.md) | The eval set that verifies the Verifier itself — drift detection in both directions. |
| [CHANGELOG.md](CHANGELOG.md) | Version history. The canonical version lives in PROJECT_FORGE.md. |

## Using it

Drop `PROJECT_FORGE.md` into a Claude.ai Project (or any capable chat model) and plan
there; execute in Claude Code or another harness. The methodology is model-agnostic by
design — harness-specific material is quarantined into clearly-marked appendices and the
`harness/` folder, and the core never depends on it.

`PARKED_RESEARCH.md` is the triaged research backlog: what's been adopted into the
methodology, what's parked with thresholds, and what was studied and rejected.

## License

MIT — see [LICENSE](LICENSE).
