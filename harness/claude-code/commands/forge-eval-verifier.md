---
description: Run the Forge Verifier eval set — grade the Verifier against known-good and known-bad diffs to detect drift.
---

# /forge-eval-verifier — verify the Verifier

You are running the Forge Verifier eval set (`evals/verifier/` in the Forge repo). It
detects Verifier drift in both directions: missing planted defects (blessing fudge) and
failing clean work (over-flagging). Triggers: the Verifier's model changed, VERIFICATION.md
or the Verifier prompt was edited, or a real gate verdict smells wrong.

## Step 1 — Load the shared fixture
Read everything under `evals/verifier/fixture/`: the four docs, `ACCEPTANCE.json`, and
the baseline source. Also read the repo's root `VERIFICATION.md` (the fixture's file
instantiates only §3 and the house conventions; the checks live in the root spec).

## Step 2 — Run every case
For each file in `evals/verifier/cases/`, in filename order:
1. Read the case file. The **Planted defect / Expected / Must flag** header is the answer
   key — it is for YOUR grading only.
2. Assemble the case's Verifier inputs: the diff (where the case defines its diff as
   "case 01's with substitutions," assemble it from case 01's Diff section only), the
   battery output, and the captured outcomes.
3. Spawn a **fresh-context sub-agent** — same isolation as /forge-verify Step 4. Give it
   ONLY: the root VERIFICATION.md, the fixture docs + baseline source, and the assembled
   diff, battery output, and outcomes. **NEVER include any case's answer-key header.**
   Its prompt is the /forge-verify Step 4 Verifier prompt, verbatim.
4. Record the verdict and which checks it flagged (with its citations).

Cases are independent — run them in parallel where the harness allows.

## Step 3 — Grade
A case scores CORRECT when the verdict matches expected AND every must-flag check appears
as flagged (accept the case's listed alternates). Case 10 additionally requires that no
finding was raised — style notes are fine; the verdict must be PASS. Grade the report's
FINAL verdict and findings: Verifiers sometimes raise and retract leads mid-report;
self-correction is fine, only what the report ultimately stands behind counts.

## Step 4 — Scoreboard and drift read
Output a table: `| Case | Expected | Got | Must-flag hit? | Correct? |` — then:
- **Any FAIL-case missed** → the Verifier is blessing fudge. Do not run Autonomous Mode
  unattended until the cause is found (model too weak? prompt drifted? spec edited?).
- **Case 10 failed** → the Verifier is over-flagging; the VERIFICATION.md §0 counterweight
  is not holding.
- **10/10** → record the date, Verifier model, and score in the run log at the bottom of
  `evals/verifier/README.md`.

Cost note: one full run ≈ 10 sub-agent calls on the Verifier model. Run on the triggers
above, not per gate. This command runs in the Forge repo only — do not copy it into
projects.
