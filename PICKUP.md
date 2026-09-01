# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** Step 1 (Foundations) was built and witnessed on the running stack, with one witness still owed (the native desktop run — blocked on a Windows setting only the owner should flip).

---

## Read this first (30 seconds)

**Step 1 of 16 is done and witnessed** — with one exception named in "Owed measurements". `docker compose up` from cold serves a DB-connected `GET /health`; a second `down`/`up` does the same; the Flutter **web** build renders that response over real HTTP through CORS. The **native** Windows run is built but unwitnessed: it needs Windows Developer Mode (owner action, see "Blocked").

**Next: Step 2 — the AI Interaction Module.** It needs `GOOGLE_AI_API_KEY` and `OPENROUTER_API_KEY` in `.env` (both currently empty) before its acceptance criteria can be witnessed. The code can be written without them.

---

## Repository layout

Three git repositories: the `dating-app` superproject, with `server` and `ux` as submodules.

```
dating_app_ai\                      ← superproject
├── .gitmodules, .gitignore, .env.example, .env (git-ignored, real secrets)
├── docker-compose.yml, Dockerfile      (S1-D1/D2 — api + db, root by owner decision)
├── user_perspective.md                 (source of truth)
├── project_description.md              (architecture + decision log)
├── technical_details.md                (stack)
├── development_principles.md           (the how — stable § numbers, never renumber)
├── communication_protocol.md           (the wire between the two repos)
├── IMPLEMENTATION_PLAN.md              (16-step build order)
├── PICKUP.md, DEFECTS.md               (§24, §21)
├── server\                         ← submodule
│   ├── README.md, pyproject.toml, alembic.ini, .gitignore
│   ├── app\        main.py · config.py · db.py · errors.py · logging_setup.py
│   ├── config\     ai.yaml            (the ai: block verbatim; slots unfilled)
│   ├── migrations\ env.py + versions\0001_pgvector_extension.py
│   ├── probes\     README.md          (the probe contract; no probes yet)
│   └── ai_interaction.md, module_1_data_collection.md, trait_persona.md,
│       candidate_matching.md, date_simulation.md, chat.md, data_hygiene.md
└── ux\                             ← submodule
    ├── README.md, pubspec.yaml         (Flutter 3.47.2 project, S1-U1)
    ├── lib\  main.dart · app\{app,theme,router,layout_shell}.dart
    │         core\api\api_client.dart · features\debug\health_screen.dart
    ├── test\ widget_test.dart          (passes)
    └── ux_architecture.md, new_user_creation.md, profile_settings.md,
        main_dashboard.md, simulate_date_page.md, simulation_results.md,
        chat_selection.md
```

**Where things get written** (unchanged): infra + shared docs → superproject root; Python/probes/migrations → `server\`; Flutter → `ux\`. Compose lives at the **root** (owner decision, 2026-09-01, revision recorded in `communication_protocol.md` §2).

---

## Current state — honest

| Area | State | Evidence |
|---|---|---|
| Specification | **Locked**, 21 documents | The `.md` files themselves |
| Docker stack | **Witnessed** — cold `up` → DB-connected `/health` 200; second `down`/`up` → same; db unreachable from host by topology (`Test-NetConnection` port 5432 → False); `psql` from inside `api` reaches `db` | This session, 2026-09-01 |
| Dependency resolve (S1-B9) | **Witnessed** — the full `pyproject.toml` set installs together in the image; no pins needed | Docker build log |
| Migrations | **Witnessed** — Alembic async wiring; revision `0001` applied; `vector` in `pg_extension` | `psql` output |
| Error envelope | **Witnessed** — 404/405 return `{"error":{"code","message"}}`; `/docs` renders | curl output |
| Health failure path | **Witnessed** — db stopped → 503 `database_unavailable` + structured error log; db restarted → 200 again | api logs |
| Structured logging | **Witnessed** — JSON lines with event fields; unresolved AI routes logged loudly on every boot | api logs |
| Flutter app | **Built; web witnessed** — web build rendered `{status: ok, database: connected}` fetched from the api container through CORS. Native Windows run **built, not yet witnessed** (blocked, see below). Widget test passes; `flutter analyze` clean | Browser screenshot this session |
| AI Interaction Module | **Does not exist** — Step 2 builds it from scratch | Directory listing |
| Database tables | None beyond `alembic_version` — Step 3 | `psql` output |
| Probes | `probes\README.md` (the contract) exists; **no probes written, none pass** | Directory listing |

## What was just finished (Step 1, all tickets)

- **S1-D1…D6:** `docker-compose.yml` (api + db, db on internal network only, healthcheck + `depends_on: service_healthy`), root `Dockerfile` (context `./server`, dev bind mount so a reload is a save), `.env.example`, root `.gitignore` covering `.env`. Real `.env` generated with random `JWT_SECRET` and DB password; AI keys left empty. S1-D5: the uncontainerized Flutter app is already the named trade in `communication_protocol.md` §2 — confirmed, nothing new to record.
- **S1-B1…B6, B9:** FastAPI app with DB-checking `/health` + CORS (dev regex: any localhost port — local-only phase, decision log #11); the error-envelope handler set (`app/errors.py`, feature code raises `ApiError`); JSON-line logging substrate (`app/logging_setup.py` → `log_event()`); Alembic async wiring with `0001` = `CREATE EXTENSION vector`; `app/config.py` loading `.env` settings *and* `config/ai.yaml` (the `ai:` block verbatim, `free-model-of-choice` slots unfilled, `unresolved_routes()` logged loudly at startup); probes README. Migrations run automatically before uvicorn in the compose command.
- **S1-U1…U6:** Flutter 3.47.2 project (`dating_app_ux`, platforms android/ios/windows/web); the locked dependency set; Material 3 light+dark from one seed, system-following; `LayoutShell` (720px column above 840px); one dio `apiClientProvider` with `API_BASE_URL` dart-define (default `http://localhost:8000`); the throwaway `/` health screen (retire in Step 4).
- **D-002 appended** to `DEFECTS.md`: `flutter create` scaffolded into the superproject root because it was pointed at `.` in a stale working directory. Caught immediately, cleaned, re-run in `ux/`. Lesson: give generators explicit paths, diff the tree after they run.

## What is next

**Step 2 — AI Interaction Module** (`IMPLEMENTATION_PLAN.md` S2-B1…B9, S2-P1). Build every file `ai_interaction.md` §1 names, even the not-yet-implemented ones (D-001's lesson: a stub announces itself, an absent file doesn't). Its acceptance criteria need real provider calls → **owner must put the two API keys in `.env` first**. Provisional models are fine — the routing slots stay unfilled by design.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Native desktop witness (Step 1 AC3, native half) | **Owner:** enable Windows **Developer Mode** (Settings → System → For developers), then `C:\src\flutter\bin\flutter.bat run -d windows` in `ux\` | Flutter plugins need symlink support. Changing a system setting is the owner's call, not the assistant's. Recorded as owed measurement O-4 |
| Step 2 acceptance criteria | **Owner:** `GOOGLE_AI_API_KEY` + `OPENROUTER_API_KEY` into `.env` | Code can be written meanwhile; witnesses can't run |
| Filling the `free-model-of-choice` routing slots | **Owner decision, deferred by design** | Unchanged — chosen after the gates |
| The paid-balance question | **Owner**, decided from quota-fit numbers | Unchanged (`ai_interaction.md` §3) |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Unchanged (decision log #11) |

## Traps that will bite you resuming cold

1. **Three git repositories, not one.** A change spanning both submodules is three commits: `server`, `ux`, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.
2. **`docker compose down`/`up` is NOT a cold start** — the `db_data` volume survives. A true from-cold witness needs `docker compose down -v`. The Step 1 witness did both orders: genuinely cold first `up`, then `down`/`up` consuming the surviving volume.
3. **Flutter is not on PATH.** The SDK lives at `C:\src\flutter` (installed 2026-09-01 from the official Google release, v3.47.2 stable). Use `C:\src\flutter\bin\flutter.bat`, or add `C:\src\flutter\bin` to PATH. Android SDK is not installed — web and (after Developer Mode) Windows desktop are the dev targets.
4. **`.env` at the root is real and git-ignored** — it holds the generated DB password the running volume was initialized with. Regenerating it after the volume exists breaks the DB connection; change either together (`down -v` + new `.env`) or neither.
5. **The `questions` table has a forward reference** (`module_1_data_collection.md` A3): `questions.trait_id` references `traits`, defined later in the document. Create `traits` first or add the FK after both exist. The document is a specification, not an execution order.
6. **`profile_embeddings` is defined twice and the copies agree** — build the two-vector form (`kind IN ('identity','preference')`, PK `(user_id, kind)`).
7. **The 200-character minimum applies to dispute answers too** (§18).
8. **Dispute questions are outside pool progress** (§13) — they never count toward `answered_pool`.
9. **Calibration chat and match chat share a widget by decision, but their rules differ** — flagging on/off, metadata on/off (§13).
10. **Three orderings are mechanisms, not style** (§19): checkpoint before advancing the turn; log counts before the deletion cascade; bump `traits_hash` only after the trait write commits; validate before any repair prompt.
11. **An all-`keep` extraction run must leave everything fresh** (A5.1, decision log #10).
12. **The 30-message date cap counts environment rows as messages** (§18).
13. **Model slots are unfilled on purpose** — startup logs them as `ai_routes_unresolved`; that warning is correct behaviour, not a bug to fix.
14. **Decided things stay decided** (§23). Appendix B of the plan is not a backlog.

## Owed measurements (§4)

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-1 | `opt_in` observed changing behaviour — a user in and out of someone else's candidate pool | Step 4 | Step 9 AC4 | **Anticipated**, not yet incurred |
| O-2 | `probe_answer_edit.py`'s pinned-snapshot assertion | Step 6 | Step 9 (S9-P2) | **Anticipated**, not yet incurred |
| O-3 | Matching witnessed against properly seeded demo profiles | Step 9 | Step 15 | **Anticipated**, not yet incurred |
| O-4 | **The native (Windows desktop) run rendering `/health` over real HTTP** — web was witnessed, native was not: the build stops at Flutter's Developer-Mode/symlink requirement | Step 1, **2026-09-01** | Owner enables Developer Mode; then `flutter run -d windows` in `ux\` and see the health screen | **Owed** |

## Probe status (§2)

`server\probes\` exists with the contract README. **No probes written. None pass.** The map (unchanged): `probe_structured_guard.py` → Step 2 · `probe_pool_expansion.py` → 5 · `probe_answer_edit.py` → 6/9 · `probe_onboarding.py` → 7 · `probe_matching_filters.py` → 9 · `probe_simulation_resume.py` → 11 · `probe_judge.py` → 12 · `probe_deletion.py`, `probe_demo_seeding.py` → 15.

## Module build order

1 ~~Foundations~~ **(done; O-4 owed)** · 2 AI Interaction · 3 Schema + reconciliation · 4 Accounts · 5 Questions & answers · 6 Trait extraction · 7 Persona & snapshots · 8 UX profile + **fidelity gate** · 9 Candidate matching · 10 UX dashboard & reveal · 11 Date simulation + **quota gate opens** · 12 Judge & scores + **quota gate closes** · 13 UX results · 14 Chat · 15 Data hygiene · 16 Witness sweep. Safely parallel (two people only): 2 ∥ 3 · 8 ∥ 9 · 10 ∥ 11.

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **Open** |
| Quota fit | Step 11 → 12 | **Open** |

The 2026-08-31 hand-validation of persona fidelity does not close the fidelity gate (wrong model).

## Where the decisions live

- **What to build:** `user_perspective.md` → `project_description.md` → the module plans in `server\` and `ux\`.
- **How to build it:** `development_principles.md` (stable § numbers).
- **The wire:** `communication_protocol.md`. · **Order:** `IMPLEMENTATION_PLAN.md`. · **What went wrong:** `DEFECTS.md`.
