# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** the repository restructure finished and the earlier partial code scaffold was removed for a clean start. There is now no application code in either submodule.

---

## Read this first (30 seconds)

This project is **fully planned and not yet built**. Twenty-one specification documents are locked, the 16-step build order is written, and **no application code exists**. Nothing has ever been observed running (`§1`).

If you are about to report on this project, the correct words are "planned, not yet built". Not "in progress", not "underway", and certainly not "working".

Start at Step 1 of [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md). The slate is clean and the plan assumes exactly that.

---

## Repository layout

Three git repositories: the `dating-app` superproject, with `server` and `ux` as submodules.

```
dating_app_ai\                      ← superproject
├── .gitmodules
├── user_perspective.md                 (source of truth)
├── project_description.md              (architecture + decision log)
├── technical_details.md                (stack)
├── development_principles.md           (the how — stable § numbers, never renumber)
├── communication_protocol.md           (the wire between the two repos)
├── IMPLEMENTATION_PLAN.md              (16-step build order)
├── PICKUP.md                           (this file — §24)
├── DEFECTS.md                          (the shared ledger — §21)
├── server\                         ← submodule
│   ├── README.md, pyproject.toml
│   └── ai_interaction.md, module_1_data_collection.md, trait_persona.md,
│       candidate_matching.md, date_simulation.md, chat.md, data_hygiene.md
└── ux\                             ← submodule
    ├── README.md
    └── ux_architecture.md, new_user_creation.md, profile_settings.md,
        main_dashboard.md, simulate_date_page.md, simulation_results.md,
        chat_selection.md
```

**Where things get written:**

| Kind of file | Goes in | Repo |
|---|---|---|
| Specs, roadmap, principles, `PICKUP.md`, `DEFECTS.md` | superproject root | `dating-app` |
| **Docker and other infrastructure** — `docker-compose.yml`, `Dockerfile`, `.env.example`, `.gitignore` | superproject root | `dating-app` |
| Server module plans, Python code, `probes\`, `scripts\`, `seeds\`, Alembic migrations, `pyproject.toml` | `server\` | `server` |
| UX module plans, the Flutter project and all Dart code | `ux\` | `ux` |

Compose lives at the **root**, not in `server\` — owner decision, 2026-09-01. The superproject is the only repo that can describe a deployment spanning both submodules. `communication_protocol.md` §2 carries the dated revision; what Compose orchestrates (`api` + `db` only, no containerized UI) is unchanged.

---

## Current state — honest

| Area | State | Evidence |
|---|---|---|
| Specification | **Locked**, 21 documents, decisions dated and named inline | The `.md` files themselves |
| Build roadmap | **Written**, 16 steps | `IMPLEMENTATION_PLAN.md` |
| Repo structure | **Complete** — superproject + both submodules, each holding its own module plans | Directory listings, `.gitmodules` |
| Docker stack | **Does not exist** — no `docker-compose.yml`, no `Dockerfile`, no `.env.example` | Directory listing |
| Database | **Does not exist** — no migrations, no Alembic config, no tables | Directory listing |
| FastAPI app | **Does not exist** — no `app/`, no application object, no endpoints | Directory listing |
| AI Interaction Module | **Does not exist** — built from scratch in Step 2 | Directory listing |
| Flutter app | **Does not exist** — `ux\` holds module plans and a README only | Directory listing |
| Probes | **None written**, none pass | `server\probes\` does not exist |
| Anything witnessed on a running stack | **Nothing** | There is no running stack |

The only code-adjacent artifact in either submodule is `server\pyproject.toml`, which lists the intended dependencies. Whether they install cleanly together has not been checked.

---

## What was just finished

- **Repository restructure complete.** The `dating-app` superproject holds the specs, the roadmap, and the two project documents; `server` and `ux` are submodules and each now carries its own module plans. This also resolved an earlier problem where the shared documents were tracked by no repository at all — §21 and §24 both want them at a project root, and now there is one.
- **Clean slate for the code.** The earlier partial scaffold was removed. Step 2 builds the AI Interaction Module from nothing, against the locked interface in `server\ai_interaction.md`.
- **Compose relocated to the superproject root** (owner decision, 2026-09-01), with the revision named inline in `communication_protocol.md` §2 per §23 rather than left to drift silently. `IMPLEMENTATION_PLAN.md` tickets S1-D1…D3 follow, and S1-D6 was added for a root `.gitignore` — a submodule's ignores do not cover the root, and the root's do not reach inside a submodule, so nothing was covering `.env`.
- `IMPLEMENTATION_PLAN.md` — the 16-step roadmap, derived strictly from the locked specs. Server and UX steps are interleaved so each server module is witnessed through the screen that consumes it.
- Two judgment calls recorded there and worth repeating: the **fidelity-transfer gate closes in Step 8** (it needs the calibration chat) and the **quota-fit gate opens in Step 11 and closes in Step 12** (it needs real call volume). Both must be shut before the first real analysis — they are not end-of-project tasks.
- `DELETE /me` was deliberately deferred from Step 4 to Step 15 so its cascade is verified whole rather than grown piecemeal.

---

## What is next

**Step 1 — Foundations: the stack, the wire, and the honesty artifacts.** Tickets S1-D1…D6, S1-B1…B8, S1-U1…U6 in `IMPLEMENTATION_PLAN.md`.

Done when `docker compose up` from cold serves a DB-connected `GET /health`, a **second** `down`/`up` does the same, and the Flutter app renders that response over real HTTP — natively and as a web build.

Nothing blocks starting it right now.

---

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Filling the `free-model-of-choice` routing slots | **Owner decision, deferred by design** | Not a blocker for Steps 1–7. Provisional models are enough to exercise the paths in Step 2. |
| The paid-balance question | **Owner**, decided from the quota-fit numbers | `ai_interaction.md` §3. Do not pre-empt it. |
| Hosting / external access, CORS and auth posture | **Owner, explicitly deferred** | Decision log #11: local-only this phase, revisited *with* the hosting decision, not piecemeal before it |

Nothing else is blocked. Everything else is unbuilt, which is a different thing.

---

## Traps that will bite you resuming cold

1. **Three git repositories, not one.** The superproject tracks the specs and a *pointer* to each submodule's commit. A change spanning both submodules is three commits: `server`, `ux`, then the superproject pointer bump. A submodule left un-bumped means someone cloning the superproject gets yesterday's code with today's specs. `§21` still applies across all three — **one** shared `DEFECTS.md`, at the superproject root, and a UX defect caused by a server contract is recorded once and cross-referenced.

2. **A submodule's `.gitignore` does not cover the root, and the root's does not reach inside a submodule.** With `.env` living at the root next to Compose, this is how a secret gets committed. S1-D6 exists for exactly this.

3. **The `questions` table has a forward reference.** In `module_1_data_collection.md` A3, `CREATE TABLE questions` declares `trait_id UUID REFERENCES traits(id)`, but `traits` is defined *later* in the document. A migration that runs the blocks in written order will fail. Create `traits` first, or add the foreign key after both tables exist. The document is correct as a specification; it is not an execution order.

4. **`profile_embeddings` is defined twice and the copies agree.** `module_1_data_collection.md` A3 already carries the **revised** two-vector form (`kind IN ('identity','preference')`, PK `(user_id, kind)`), restated in `candidate_matching.md` §3. Build the two-vector version.

5. **The 200-character minimum applies to dispute answers too**, not only baseline and pool (`§18` — the scope is written down precisely because a rule written for one case is a trap in the case it did not consider).

6. **Dispute questions are outside pool progress.** They are per-user, AI-generated, and must not count toward `answered_pool` (`§13`). Assuming all questions behave like pool questions is a named trap.

7. **Calibration chat and match chat share a widget by decision, but their rules differ** — flagging on/off, metadata on/off (`§13`). Do not let one inherit the other's behaviour.

8. **Three orderings are mechanisms, not style** (`§19`): checkpoint the message row *before* advancing the simulation turn; log the per-table counts *before* the deletion cascade; bump `traits_hash` *only after* the trait write commits. Validate against the schema *before* any repair prompt.

9. **An all-`keep` extraction run must leave everything fresh.** Only an `update`/`retract`/`add` changes `traits_hash`. Marking embeddings and snapshots stale on a no-op re-run is the drift bug this design exists to prevent (A5.1, decision log #10).

10. **The 30-message date cap counts environment rows as messages** (`§18`).

11. **Model slots are unfilled on purpose.** Do not fill them by guessing to make something run. Two gates stand before the first real analysis, and both need real numbers.

12. **Decided things stay decided** (`§23`). The out-of-scope list in `IMPLEMENTATION_PLAN.md` Appendix B is not a backlog — each item has a named trade. Reopening one requires new information and a dated, inline revision where the old decision stood.

---

## Owed measurements (`§4`)

The queue goes to zero. Nothing here is a claim that something works — these are debts recorded *in advance*, from the roadmap, so they cannot be forgotten when the step that incurs them passes.

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-1 | `opt_in` observed changing behaviour — a user in and out of someone else's candidate pool. Step 4 can only witness the toggle writing to the database, not the difference it makes. | Step 4 | Step 9 AC4 | **Anticipated**, not yet incurred |
| O-2 | `probe_answer_edit.py`'s pinned-snapshot assertion — that a snapshot pinned in a past analysis does not change when the user edits an answer. Cannot be asserted until analyses exist. | Step 6 | Step 9 (S9-P2) | **Anticipated**, not yet incurred |
| O-3 | Matching witnessed against a pool of properly seeded demo profiles rather than hand-registered test users. Step 9 runs before demo seeding exists. | Step 9 | Step 15 | **Anticipated**, not yet incurred |

When a step incurs one of these, change its status to **Owed** and date it. When the closing step passes, delete the row and say so in "What was just finished".

---

## Probe status (`§2`)

The minimum probe set, one per locked mechanism, all living in `server\probes\`. **None exist. None pass.**

| Probe | Proves | Delivered in | Status |
|---|---|---|---|
| `probe_structured_guard.py` | Repair attempts, then the typed give-up; no silent default downstream | Step 2 | Not written |
| `probe_pool_expansion.py` | Batches of 5 in `pool_order`, mid-batch resume, `pool_exhausted` payload | Step 5 | Not written |
| `probe_answer_edit.py` | Holistic re-extraction, `trait_events`, staleness cascade, confirmed traits survive | Step 6 / 9 | Not written |
| `probe_onboarding.py` | Register → BQ1–BQ5 with an edit → extract → compile; traits and snapshot exist | Step 7 | Not written |
| `probe_matching_filters.py` | Every hard-filter exclusion, per-step pool counts, `partial` and `no_candidates` | Step 9 | Not written |
| `probe_simulation_resume.py` | Kill mid-date, restart, continue from the checkpoint | Step 11 | Not written |
| `probe_judge.py` | Rerun tolerance; `date_score` recomputed by hand matches stored | Step 12 | Not written |
| `probe_deletion.py` | Cascade counts, survivor tombstones, global questions survive | Step 15 | Not written |
| `probe_demo_seeding.py` | Reconciliation rebuilds demo traits through the real pipeline | Step 15 | Not written |

---

## Module build order

Full detail in `IMPLEMENTATION_PLAN.md`; Appendix A there carries the dependency table.

1 Foundations · 2 AI Interaction · 3 Schema + reconciliation · 4 Accounts · 5 Questions & answers · 6 Trait extraction · 7 Persona & snapshots · 8 UX profile + **fidelity gate** · 9 Candidate matching · 10 UX dashboard & reveal · 11 Date simulation + **quota gate opens** · 12 Judge & scores + **quota gate closes** · 13 UX results · 14 Chat · 15 Data hygiene · 16 Witness sweep

**Safely parallel** (only with two people): 2 ∥ 3 · 8 ∥ 9 · 10 ∥ 11.

## Gate register (`ai_interaction.md` §3)

Both must be **closed with recorded numbers** before the first real analysis is trusted.

| Gate | What closes it | Closes in | Status |
|---|---|---|---|
| Fidelity transfer | Chat with your own persona through the *actually routed* `date_simulation` model; count the lines you would never say; record the model, message count, and flag count | Step 8 | **Open** |
| Quota fit | ~190 calls/analysis against the chosen providers' per-minute *and* per-day caps as a spreadsheet, then one full end-to-end run confirming the real count | Step 11 → 12 | **Open** |

The 2026-08-31 hand-validation of persona fidelity was performed on a model that is **not necessarily** the one that will be routed for simulation. It does not close the fidelity gate.

## Where the decisions live

- **What to build:** `user_perspective.md` (source of truth) → `project_description.md` (architecture + the 13-item decision log) → the module plans in `server\` and `ux\`.
- **How to build it:** `development_principles.md`. Section numbers are stable and cited throughout; never renumber them.
- **The wire between the repos:** `communication_protocol.md`.
- **Order of work:** `IMPLEMENTATION_PLAN.md`.
- **What went wrong before:** `DEFECTS.md`.
