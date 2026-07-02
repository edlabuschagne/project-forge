# VERIFICATION.md — [Project Name]

> **Base template** (genericised from a battle-tested Forge gate). Fill the
> `[bracketed]` spots per project; delete guidance you don't need.
>
> **One spec, two readers.** The **executor** runs this as its own self-check before
> declaring a milestone done. The **independent Verifier** runs the *same* checklist
> again at the gate — in a fresh context, having never seen the executor's reasoning.
> Same checklist, independent eyes. In Autonomous Mode the Verifier IS the gate:
> PASS / PASS-WITH-NOTES auto-proceeds (unless the milestone is tagged needs-human-check,
> §2a there); FAIL stops the run (see FORGE_AUTONOMOUS_MODE.md).

---

## 0. What the Verifier sees (and must NOT see)

The Verifier gets a **fresh context** with only:
- `PROJECT_SCOPE.md`, the **full current architecture** (`ARCHITECTURE.md` plus every
  architecture node it links to, assembled deterministically — the Verifier never
  traverses the memory map to pick nodes; it always receives the complete built-state
  picture), the **current milestone's acceptance criteria + DO-NOT-BUILD list**
  from `MILESTONES.md`, the `ACCEPTANCE.json` ledger (Tier 2+), and this file.
- The **actual diff** for the milestone (files changed, tests added) — e.g. `git diff`
  against the milestone's start commit.

It must **not** inherit the executor's chat, plan, or "make this work" framing. The whole
value is what it doesn't know. Use a separate, lighter model instance — verification is
spec pattern-matching and regression-hunting, not deep architecture; the *separation*
matters more than the horsepower. **For any milestone with a UI surface the Verifier must
also be vision-capable** (Check 8 — a capability requirement, not a model name). Adversarial
stance: **its job is to find the fudge, not to bless the work.**
Adversarial about the *spec*, though — not inventive: a reviewer prompted to find gaps
will report some even when the work is sound. Flag only what affects correctness, a
stated acceptance criterion, or the Check 5 floor; style preferences and hypothetical
hardening are notes at most — never findings, never grounds to withhold PASS.

Verdict vocabulary — **always with file:line references, never vibes:**
- **PASS** — every acceptance criterion met, no scope violation, no regression, gates green.
- **PASS-WITH-NOTES** — met, but with logged debt or minor notes. Auto-proceeds **unless**
  a note is severity-high (then treat as FAIL).
- **FAIL** — a criterion unmet, a DO-NOT-BUILD item built, a regression, a tripwire crossed,
  or a gate red.

### Why the Verifier never traverses the memory map

The memory map (`KNOWLEDGE.md`, PROJECT_FORGE.md) exists to keep the **builder's** working
context lean across many agentic-loop iterations — load the map, traverse to the 1–3 nodes
a task needs. That economy is **builder-side only.** The Verifier is not the builder: it
runs once per gate, in fresh context, on a lighter model. Traversal would force a
navigation judgment ("which architecture nodes does this diff touch?") onto the very entity
whose value is being dumb, deterministic, and adversarial — and a missed node is a silent
"checking against fiction" failure (FORGE_AUTONOMOUS_MODE.md §6 territory). So at the gate
the Verifier always receives the **full** current architecture, assembled deterministically
— never a selected subtree. If the full set ever overflows a cheap model's context, that is
a signal the architecture doc is bloated and needs the map-maintenance the methodology
already prescribes — not a reason to make the Verifier navigate.

---

## 0a. When the Verifier fires (staging)

The Verifier is not a single end-of-milestone event. It can fire at named checkpoints, so
problems surface while context is still warm and cheap to fix:
- **Checkpoint A — after planning the milestone approach.** Before building, sanity-check
  the plan against PROJECT_SCOPE.md and ARCHITECTURE.md. Catches wrong-direction work early.
- **Checkpoint B — after a complex implementation step.** For genuinely complex milestones
  only — verify the hard part in isolation before building on top of it.
- **Checkpoint C — at the gate (always).** The full run, via `/forge-verify`. Non-negotiable.

For Tier 1 / simple milestones, Checkpoint C alone is enough. Add A and B as complexity rises.

---

## 1. The eight checks (run in order)

### Check 1 — Acceptance criteria (correctness)
For **each** criterion in the current milestone: cite the criterion, cite the code/test
that satisfies it, state PASS/FAIL. A criterion with no corresponding test or behavioural
proof is **not** satisfied — "it should work" is a FAIL. Rules involving data, security, or
state must be proven **behaviourally** (a test that actually exercises the rule), not by
existence checks — code being present is not proof it works. The automated battery must have
**actually run** — "tests pass" with no run output is treated as a FAIL, not a pass.
**Ledger discipline (Tier 2+):** work from `ACCEPTANCE.json`, not prose claims. Every
criterion flipped to `passes: true` must be backed by the evidence it cites — verify the
citation, don't trust the flip; a flip with empty or wrong evidence is a FAIL. Any change
outside the `passes`/`evidence` fields — criteria removed, reworded, reordered, or added —
is tampering: **FAIL regardless of code quality.**

### Check 2 — Architecture conformance
Does the change follow ARCHITECTURE.md patterns, or did it invent one? Inventing a pattern
where the architecture already specifies one is a FAIL. Security-sensitive code (auth checks,
access control, secret handling) must follow the documented hardened form, not a looser
improvisation. Frontend: design tokens over hardcoded colours/sizes/spacing; reuse existing
component patterns; honour the project's banned escape hatches.
[List this project's house conventions here — naming, data-access patterns, the hardened
security form, etc.]

### Check 3 — Scope policing (did it build outside the lines?)
- Did the diff touch **any file/module/table outside the milestone's expected output**? Flag it.
- Did it build **anything on the milestone's DO-NOT-BUILD list**? **FAIL even if the code is good.**
- "While I'm here" work — refactors, dependency upgrades, polish, renames outside the
  criteria → FAIL. New ideas go to PARKED.md, unbuilt.

### Check 4 — Regression (did it break something that worked?)
- Did a previously-passing criterion from M1–M(n-1) break? Spot-check the adjacent surface.
- Were existing security rules, access controls, or data constraints weakened or dropped?
  The **guardrail/enforcement baseline** is protected security state too: silently removing or
  loosening a tripwire control — in Claude Code, a `permissions.deny`/`ask` rule or a tripwire
  hook (FORGE_AUTONOMOUS_MODE.md appendix) — is weakening security and counts as a regression.
- Build clean (0 errors)? Lint 0 errors (warnings acceptable)?
- Re-run the **full prior test suite** after any change touching shared logic, the data
  layer, or security — all prior suites still green, plus the new milestone's.
- End-to-end flow still green (browser e2e for web; the platform's equivalent otherwise).

### Check 5 — The "never shortcut" floor (non-negotiable)
These are **FAIL if cut, regardless of leanness (§5):**
- **Input validation** — required args guarded, types enforced, friendly errors.
- **Security** — auth/authz server-side, no secrets in code or commits, no injection
  surface, access controls intact.
- **Accessibility** — tap targets, labels, keyboard/focus basics on new UI.
- **Data-loss safety** — no destructive op without a tested rollback; no unguarded
  cascade-delete paths.

### Check 6 — Tripwire audit (STOP conditions)
Confirm the change did **not** silently cross a CLAUDE.md TRIPWIRE without an explicit human
approval recorded in HANDOFF.md: changes to auth, access control, or secrets; destructive or
irreversible data operations; git history rewrites; spending money / provisioning paid
resources; anything touching production. Crossing one unapproved = **FAIL + STOP**.
**Autonomous Mode:** also confirm the run's session-start **guard-presence check** was performed
and its result recorded — a known-denied operation proven blocked before any building. An
unattended run whose guards were never confirmed loaded is a **FAIL** regardless of verdict.
(Claude Code form: the startup canary, FORGE_AUTONOMOUS_MODE.md appendix.)

### Check 7 — Debt ledger (collect every `forge-debt:` marker)
Grep the **whole diff** for `forge-debt:` markers and assemble them into this milestone's
ledger (§4). A **marked** shortcut is a decision log entry (record it). An **unmarked**
shortcut is hidden debt → **PASS-WITH-NOTES at best, FAIL if it touches the §1 Check 5 floor.**

### Check 8 — Observable-outcome verification (the eyes) — every milestone
Tests prove the behaviour someone thought to assert; they do not prove the *result* is right —
that the screen looks correct, the output reads correctly, the file came out as intended.
Check 4 runs the suite — this check **looks at the result.** For each acceptance criterion,
open the outcome captured for its state (§3), in whatever form fits the platform:
- **A UI (web or desktop)** → the screenshot. Confirm it shows what the criterion says the
  user should see — not an error, empty state, broken layout, placeholder, or unstyled flash —
  and that the state is reachable by the path a real user takes, not only by direct
  navigation. (Requires a vision-capable Verifier, §0.)
- **A CLI / script** → the captured stdout/stderr and exit code. Confirm both match what the
  criterion specifies.
- **A batch job / generated file** → the produced artifact. Confirm its contents are what the
  criterion describes.
**A criterion whose captured outcome contradicts it is a FAIL, not a note** — code "passing"
while the result is wrong is the "looks done but isn't" defect that hides longest in an
unattended run.

---

## 2. Output format

```
## Verifier Report — Milestone [X] ([name])
Verdict: PASS | PASS-WITH-NOTES | FAIL

### Check 1 — Acceptance criteria
- [criterion] — PASS/FAIL — <file:line or test name> — <one line>
### Check 2 — Architecture conformance — PASS/FAIL — <refs>
### Check 3 — Scope policing — PASS/FAIL — <files outside scope / DO-NOT-BUILD hits>
### Check 4 — Regression — build: <ok/err> · lint: <0 err?> · tests: <green?> · e2e: <green?>
### Check 5 — Never-shortcut floor — PASS/FAIL — <refs>
### Check 6 — Tripwire audit — none crossed | CROSSED: <which> (approved in HANDOFF? y/n)
### Check 7 — Debt ledger — <N forge-debt markers collected, listed below>
### Check 8 — Observable-outcome verification — PASS/FAIL — <criterion → outcome path → what it shows>

### Debt ledger (this milestone)
- forge-debt: <text> — <file:line> — severity low/med/high

### Severity-high notes (if any) → escalate to FAIL
### Bottom line: <what passes, what fails, what the human must look at>
```

No prose blessing without line references. **If you cannot cite it, it did not pass.**

---

## 3. Running the gates (commands)

- **Build:** `[build command]` → must exit 0.
- **Lint:** `[lint command]` → 0 errors (warnings acceptable).
- **Tests:** `[test command]` → all green.
- **End-to-end / integration:** `[e2e command]` → green. (Browser e2e for web; the platform's
  equivalent otherwise — a scripted UI driver, a CLI invocation harness, an integration test.)
- **Outcome capture:** the e2e run captures the observable outcome at each acceptance-criterion
  state to `verification-shots/M[X]/<criterion>.<ext>` — a screenshot (`.png`) for a UI,
  captured stdout + exit code (`.txt`) for a CLI, the generated artifact for a batch job.
  Deterministic capture only — no agent driving the run, so the model spends tokens on
  *looking* (Check 8), never on plumbing.
- **Security checks:** never "verified" via a privileged/admin path that bypasses the
  access-control layer — that bypasses the very thing you're testing. Prove behaviourally,
  the way a real unprivileged user would hit it.

---

## 4. Debt ledger at handoff

At the end of every milestone (and every autonomous-run batch), collect **all** `forge-debt:`
markers from the diff into a ledger and append it to HANDOFF.md. Each entry: the marker text,
`file:line`, and a severity (low = cosmetic/perf-at-scale; med = correctness-under-edge-cases;
high = touches the §1 Check 5 floor → blocks PASS). Marked shortcuts are a decision log;
unmarked shortcuts are hidden debt.

**Cumulative debt budget.** The ledger is a **running total across the run**, not
per-milestone. The autonomous loop — **not** the Verifier, which sees only one diff and can't
judge the pile — checks the cumulative total before each new milestone; if it crosses
`[N]` open entries or `[M]` medium-severity entries, **STOP for human triage even on a PASS.**
See FORGE_AUTONOMOUS_MODE.md §3.

---

## 5. Leanness floor check

Before blessing new code, confirm the executor honoured the leanness order — **and** that
leanness was never used as an excuse to cut a §1 Check 5 item:
1. Not built if not needed yet (YAGNI) — flag speculative generality / unused params.
2. Standard library before a dependency. **No new dependency without explicit approval**
   (an unsanctioned new package = scope violation → FAIL).
3. Platform/native feature before a hand-roll.
4. Reuse what's installed before adding.
5. One line if it can be one line.

Leanness is a *quality* lens, not a licence to skip validation, security, accessibility, or
data-loss safety — those are never lean-able.

---

> **Note on adoption.** When retrofitting this gate onto a project that's already several
> milestones deep, establish ground truth first (reverse-engineer the Forge docs from the
> code, read them once, commit a known-good baseline) before any unattended run. The full
> adoption procedure lives in FORGE_AUTONOMOUS_MODE.md §6.
