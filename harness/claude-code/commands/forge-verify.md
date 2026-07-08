---
description: Run the Forge milestone gate — full battery, outcome capture, independent Verifier, Gate Report.
---

# /forge-verify — the milestone gate

You are running the Forge gate for the current milestone. This is the FINAL step of a
milestone. Follow docs/VERIFICATION.md exactly. Do not skip a step; do not proceed past
the gate without explicit human approval.

## Step 1 — Run the deterministic battery (VERIFICATION.md §3)
Run the build, lint, test, and e2e commands exactly as listed in docs/VERIFICATION.md §3.
Capture real output. If a command is missing from §3, STOP and report — do not invent one.

## Step 2 — Capture observable outcomes
Confirm the e2e run captured the observable outcome for each acceptance criterion to
verification-shots/M[X]/ — a screenshot for UI, stdout + exit code for a CLI, the
artifact for a batch job. Deterministic capture only; do not drive the app by hand.
Where docs/VERIFICATION.md §3 requires it (any project with a deployed URL), the
captures include the real browser load of the deployed URL, origin asserted.

## Step 3 — Assemble the Verifier's input (nothing more, nothing less)
Collect exactly:
- docs/PROJECT_SCOPE.md
- The FULL current architecture: docs/ARCHITECTURE.md plus every architecture node it
  links to — assembled deterministically, never a traversed selection (VERIFICATION.md §0)
- The current milestone's acceptance criteria + DO-NOT-BUILD list from docs/MILESTONES.md
- docs/ACCEPTANCE.json (Tier 2+)
- docs/VERIFICATION.md
- The milestone diff (git diff <milestone-start-commit>..HEAD), the battery output from
  Step 1, and the captured outcomes from Step 2

## Step 4 — Launch the independent Verifier
Launch a SUB-AGENT in a fresh context with ONLY the Step 3 inputs. Do not include your
plan, your reasoning, or this conversation — the whole value is what it doesn't know.
For any milestone with a UI surface the sub-agent must be vision-capable (it reads the
captured screenshots). Its prompt, verbatim:

> You are the Forge Verifier. You did not write this code. Your job is to find the
> fudge, not to bless the work — but flag only what affects correctness, a stated
> acceptance criterion, or the Check 5 floor; everything else is a note at most,
> never grounds to withhold PASS. Run the eight checks in VERIFICATION.md IN ORDER
> against the inputs provided. Output the Gate Report in the exact format of
> VERIFICATION.md §2. Verdict vocabulary: PASS / PASS-WITH-NOTES / FAIL, always with
> file:line references. Before writing the report, re-check every file:line citation
> against the actual diff — a wrong reference invalidates the finding. If you cannot
> cite it, it did not pass.

## Step 5 — Report and STOP
- Present the Verifier's Gate Report verbatim. Do not soften it.
- Append the milestone's debt-ledger entries (Check 7) to HANDOFF.md; refresh HANDOFF.md.
- Classic Forge: STOP and wait for human review regardless of verdict.
- Autonomous Mode: branch per FORGE_AUTONOMOUS_MODE.md §2 (PASS on an auto-verifiable
  milestone → proceed; needs-human-check or FAIL → STOP).
