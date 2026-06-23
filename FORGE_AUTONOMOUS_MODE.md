# FORGE — Autonomous Mode

> A Forge profile for running a build with as little manual checking as possible.
> Model-agnostic. Project-agnostic. Drop into a Claude Project's knowledge to brief
> Claude on how to operate when the goal is maximum executor autonomy with automated
> safety nets instead of a human at every gate.
>
> Read this alongside `PROJECT_FORGE.md` (the base methodology). This file only
> describes what *changes* in Autonomous Mode; everything in the base methodology
> still holds unless overridden here.

---

## 1. What Autonomous Mode is (and the honest trade)

Classic Forge puts a **non-negotiable human stop-and-wait gate between every
milestone.** Autonomous Mode relaxes that gate — the executor runs through multiple
milestones without you reviewing each one — and replaces your eyes with two things:

1. **An independent Verifier** that gates each milestone in a fresh, contaminated-free
   context. If it passes, the run auto-proceeds. If it fails, the run stops.
2. **Tripwires** that halt the run regardless of Verifier verdict, on the classes of
   action that are unrecoverable or that you've said you want to see.

Be clear-eyed about the trade: you are buying speed and unattended runtime by
accepting that some defects will land in the codebase before you see them. The
Verifier catches *most* of what your review would have caught — it's spec-matching,
regression-checking, and scope-policing — but it cannot catch everything, and it
shares the executor's blind spots on genuinely novel design judgement. The mitigation
is not "trust harder." It's: make the *irreversible* set as small as possible and
keep a human stop on it, so the worst an unattended run can do is produce work that's
*wrong* (recoverable: revert the commit) rather than *destructive* (unrecoverable).

If you only enforce one thing from this document, enforce the tripwires in §4.

---

## 2. The autonomous run loop

This is the core change. Instead of `build → stop → human reviews → human approves →
next`, the loop becomes:

```
For each milestone in the run:
  1. Read the milestone's acceptance criteria, its DO-NOT-BUILD list, and its autonomy
     tag (§2a: auto-verifiable or needs-human-check)
  2. Build only that milestone
  3. Self-verify against every acceptance criterion (executor's own check)
  4. Run the independent Verifier (/forge-verify) in fresh context
  5. Branch on the verdict:
       PASS / PASS-WITH-NOTES → commit, update HANDOFF.md (log any notes), then branch
                                on the milestone's autonomy tag:
                                  auto-verifiable   → AUTO-PROCEED to next milestone
                                  needs-human-check → STOP for human review, even on PASS
                                (PASS-WITH-NOTES with a severity-high note → treat as FAIL)
       FAIL                   → STOP. Write the failure + diagnosis to HANDOFF.md. Wait.
  6. If a tripwire (§4) is hit at any point → STOP immediately, write HANDOFF.md, wait.
End loop → STOP, write a run summary to HANDOFF.md, wait for human review of the batch.
```

The human gate hasn't disappeared — it's become **conditional**. It fires on Verifier
failure, on a tripwire, on any milestone you tagged `needs-human-check` (§2a), and at the
end of the run. The rest of the time the executor proceeds on the Verifier's say-so. You review a *batch* of completed milestones at the
end, by using the deployed result and reading the accumulated HANDOFF.md, not by
reading code milestone-by-milestone.

**Run length is a dial you set, not the executor.** Tell it how far to run: "build
through milestone N then stop," or "run until a Verifier FAIL or you've completed 3
milestones, whichever first." Open-ended "build everything" runs are where autonomous
agents burn budget and drift. Bound the run.

---

## 2a. Decide what's safe to run unattended (planning triage)

Not every milestone deserves the same trust. The whole point of Autonomous Mode is to run
unattended where a machine can honestly sign off — and to pull you in where it can't. That
decision is made **in planning, not mid-run**, and recorded on each milestone so the executor
has an explicit instruction instead of a guess.

Tag every milestone one of two ways:

- **`auto-verifiable`** — the acceptance criteria can be *proven by machine*: a test exercises
  the rule, and the outcome is observable and captured automatically (see VERIFICATION.md
  Check 8 for what "observable outcome" means beyond the browser). On a Verifier PASS the run
  auto-proceeds. This is the default and should be most milestones — if you can't make a
  milestone auto-verifiable, that's usually a sign its criteria aren't concrete enough yet.
- **`needs-human-check`** — something real can't be proven by the Verifier alone, so the run
  **stops for your review even on a PASS.** Reach for this when a milestone involves:
    - subjective quality a screenshot can't settle (does the UX actually feel right, is the
      copy on-brand);
    - a real external side effect (a live payment, an email actually sent, a third-party
      integration hitting the real service);
    - genuine design judgment, or a first-of-its-kind pattern the rest of the build will copy;
    - anything you simply want to see with your own eyes before more is built on top of it.

Two distinctions worth holding:
- This is **not** a tripwire. Tripwires (§4) stop on *irreversible* actions regardless of
  verdict; `needs-human-check` stops on *unverifiable-by-machine* milestones regardless of
  verdict. One guards against damage, the other against bad judgment slipping through. A
  milestone can be both.
- Keep the `needs-human-check` set **small and honest.** Every one is a place the run pauses
  for you — the very cost you're using Autonomous Mode to avoid. Tag the milestones that
  genuinely need your eyes, make the rest concretely auto-verifiable, and let the loop run.

This tag lives next to the milestone's criteria in MILESTONES.md (PROJECT_FORGE.md template),
so it loads with the milestone.

---

## 3. Stop rules become a first-class section of CLAUDE.md

Autonomous executors share a failure mode: they keep working until something stops
them — grinding on a stuck problem, gold-plating, wandering outside scope. In
Autonomous Mode there's no human watching to say "that's enough," so the stop rules
have to be written down and loaded every session. Put this section in CLAUDE.md (which
the executor always loads), with per-milestone specifics next to the criteria in
MILESTONES.md:

```markdown
## STOP RULES — these override all other instructions
- A milestone is COMPLETE when every acceptance criterion is PASS and the Verifier
  has run. In Autonomous Mode you may proceed to the next milestone ONLY on a
  Verifier PASS or PASS-WITH-NOTES. On FAIL, STOP and write HANDOFF.md.
- DO-NOT-BUILD list: each milestone names what is explicitly out of scope. Building
  it is a failure even if the code is good. New ideas go to PARKED.md, unbuilt.
- Attempt budget: if the same problem fails 3 distinct fix attempts, STOP, write the
  blocker to HANDOFF.md, do not try a 4th approach or invent a workaround.
- No "while I'm here" work: no refactors, dependency upgrades, or polish outside the
  current milestone's criteria.
- Effort sanity check: if a milestone is costing far more than its size implies,
  STOP and report rather than grinding.
- Run boundary: do not exceed the run length the human set for this session.
```

---

## 4. Tripwires — the irreversible set (NON-NEGOTIABLE)

These halt the run *regardless* of how confident the executor is or what the Verifier
says. They exist because the cost of getting them wrong is unrecoverable, and an
unattended run is exactly when an irreversible mistake does the most damage. Put this
in CLAUDE.md verbatim and treat it as the hard floor of Autonomous Mode:

```markdown
## TRIPWIRES — STOP and wait for explicit human approval before any of these
- Any destructive or irreversible database operation: schema migrations that drop or
  alter columns/tables, deletes without a tested rollback, data backfills.
- Any git history rewrite: force-push, rebase of shared branches, hard reset, branch
  deletion.
- Deleting or overwriting files outside the current milestone's expected output.
- Changing secrets, environment config, access control, or anything touching auth.
- Spending money: provisioning paid resources, raising plan tiers, anything billable.
- Modifying production / anything a real user or stakeholder is currently touching.
When you hit a tripwire: STOP, describe exactly what you intend to do and why, write
it to HANDOFF.md, and wait. Do not proceed on assumed approval.
```

Tune this list to the project — but err toward *more* tripwires, not fewer. Every
item you add here is a place where an unattended mistake stays cheap.

---

## 5. The Verifier is the gate now — so make it strong

In classic Forge the Verifier is a second opinion and *you* are the gate. In
Autonomous Mode the Verifier *is* the gate, so its independence matters more, not less:

- **Fresh context, every time.** It must not inherit the executor's reasoning or its
  "make this work" framing. It sees only: PROJECT_SCOPE, ARCHITECTURE, the milestone's
  acceptance criteria, and the actual diff. The whole value is what it *doesn't* know.
- **A separate, lighter instance is fine and preferred.** Verification is spec
  pattern-matching and regression-hunting, not deep architecture — a cheaper, faster
  model does it well and keeps unattended runs affordable. The point is the *separation*,
  not the horsepower.
- **Adversarial stance.** Its job is to find the fudge, not to bless the work. Its
  verdict vocabulary is PASS / PASS-WITH-NOTES / FAIL, always with line references —
  no vibes, no "looks good."
- **It must police scope and regression**, not just correctness: did the executor
  touch anything outside the milestone? Did it break a previously-working feature?
  These are the defects that quietly accumulate across an unattended multi-milestone run.

VERIFICATION.md is a single spec with two readers: the executor runs it as its own
self-check before declaring done, and the independent Verifier runs it again at the
gate. Same checklist, independent eyes.

---

## 6. Retrofitting onto a project that's already underway

Classic Forge assumes you start from zero. Applying Autonomous Mode to a project
that's **already several milestones deep** has one extra requirement, and it's the
single place worth spending your scarce attention: **establish ground truth before
you let it run unattended.**

The risk is specific. An autonomous run is only as safe as the documents the Verifier
checks against. If ARCHITECTURE.md doesn't reflect what's actually been built, the
Verifier can't catch a regression or a scope violation — it's checking against
fiction. So before the first autonomous run, do a one-time **adoption phase**:

```
ADOPTION (one-time, before any autonomous run):
  1. Inventory reality. Have the executor read the existing codebase and produce a
     plain-language map of what currently exists: features, data models, the routes,
     the external services it talks to, the conventions actually in use.
  2. Reverse-engineer the Forge docs FROM the code, not from memory or intention:
       - ARCHITECTURE.md  ← what the system actually is right now
       - PROJECT_SCOPE.md ← what it's for + an explicit out-of-scope list
       - MILESTONES.md    ← mark milestones 1–N as DONE (current state), then plan
                            the REMAINING milestones with testable criteria + DO-NOT-
                            BUILD lists
       - VERIFICATION.md  ← the dual-reader spec
       - CLAUDE.md        ← base harness + STOP RULES (§3) + TRIPWIRES (§4)
       - HANDOFF.md       ← seed it with the current state as the starting handoff
  3. ** You read these docs once.** This is the one manual checkpoint that earns its
     keep: ~30–60 minutes confirming the reverse-engineered architecture and the
     remaining-milestone plan match your intent. If the map is wrong, every
     autonomous run after it inherits the error. If it's right, the Verifier now has
     real ground to check against and you can step back.
  4. Establish a baseline: ensure the project builds, tests pass (or document which
     don't and why), and commit a clean checkpoint so the first autonomous run has a
     known-good point to revert to.
  5. THEN start the autonomous run loop (§2) on the remaining milestones.
```

Yes, this is "checking something manually" — once, at the boundary, on the documents
rather than the code. It's the highest-leverage hour you'll spend, because it's what
makes all the *un*checked runs afterward safe enough to do. Skipping it doesn't save
you time; it just moves the cost to a worse moment later.

---

## 7. What stays exactly the same

- **Plan in chat, execute in the harness.** The split is discipline, not a model
  crutch; it stays.
- **The harness carries over:** the mid-build report-only check hook, the
  `/forge-verify` gate command, HANDOFF.md (curated human-readable narrative) plus the
  auto-written snapshot of mechanical state, all hooks in OS-safe form.
- **Deploy early and review on the deployed result**, not localhost — so a batch
  review is "use the running app + read HANDOFF.md," reviewable from anywhere.
- **Smaller milestones still beat bigger ones** for everything except your review
  frequency. Autonomous Mode lets you review *less often*; it does not ask you to make
  each unit of work bigger or vaguer. Tight, testable criteria are what make the
  Verifier-as-gate trustworthy.
- **The two gremlins still apply:** over-research (don't re-plan what's already built —
  inventory it and move) and shiny-new-idea (new ideas go to PARKED.md, not the run).
