# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** Step 2 (AI Interaction Module) is **built** — every file `ai_interaction.md` §1 names, plus probe, tests, and startup wiring — but its live-call acceptance criteria are **not witnessed**: both API keys are still empty in `.env`.

---

## Read this first (30 seconds)

**Step 1 is done and witnessed** (one owed native-run witness, O-4). **Step 2 is built, not yet witnessed** — the honest words per §6. The whole `app/ai/` layer exists, hot-loads on the running stack, passes 8 unit tests and ruff, and its two *refusal* paths (missing key → typed `AIError`; unfilled model slot → typed `RouteUnresolvedError`) **were** witnessed on the real deployment. What was NOT witnessed: any real model call. `probe_structured_guard.py` and `probe_ai_smoke.py` are written and waiting.

**To unblock Step 2's witnesses: put `GOOGLE_AI_API_KEY` and `OPENROUTER_API_KEY` into `.env`**, then run the two probes (commands below). Until then, do not start Step 3 work *claiming* Step 2 is done — Step 3 is schema-only and independent (the plan allows 2 ∥ 3), so building Step 3 next is legitimate; closing Step 2 is not.

---

## Repository layout

Three git repositories: the `dating-app` superproject, with `server` and `ux` as submodules.

```
dating_app_ai\                      ← superproject
├── docker-compose.yml, Dockerfile, .env.example, .env (git-ignored), .gitignore
├── the five specs + IMPLEMENTATION_PLAN.md + PICKUP.md + DEFECTS.md
├── server\                         ← submodule
│   ├── pyproject.toml (explicit package decl — D-003), alembic.ini, .gitignore
│   ├── app\
│   │   ├── main.py · config.py · db.py · errors.py · logging_setup.py
│   │   ├── ai\      base.py · google.py · openrouter.py · registry.py
│   │   │            routing.py · structured.py · resilience.py   (all 8 of §1's files exist)
│   │   └── schemas\ __init__.py (registry) · agent_response.py (loud stub, Step 7)
│   ├── config\ai.yaml              (google slots: gemini-2.5-flash PROVISIONAL;
│   │                                openrouter slots: unfilled by design)
│   ├── migrations\  versions\0001_pgvector_extension.py
│   ├── probes\      probe_structured_guard.py (S2-P1) · probe_ai_smoke.py (AC helper)
│   ├── tests\       test_structured_guard.py (8 tests, green)
│   └── the seven server module plans
└── ux\                             ← submodule
    ├── Flutter 3.47.2 app (lib\app, lib\core\api, lib\features\debug) + widget test
    └── the seven UX module plans
```

## Current state — honest

| Area | State | Evidence |
|---|---|---|
| Step 1 stack | **Witnessed** (2026-09-01): cold up → DB-connected 200; second down/up; topology; envelope; failure path | Prior session, recorded in git history |
| Step 2 `app/ai/` layer | **Built, not yet witnessed** — all files of `ai_interaction.md` §1; hot-loaded by the running api; startup validation green | Container logs: `provider_built` ×2, `router_ready` |
| Step 2 refusal paths | **Witnessed** — missing key → typed `AIError`; unresolved slot → `RouteUnresolvedError`, both on the real deployment | In-container run, 2026-09-01 |
| Step 2 unit tests | **8 pass** in-container (Guard: first-try / fences / repair-carries-error / 3-attempt give-up with raw output; Router: startup rejects unknown provider & missing task, unresolved→typed error, resolve) | pytest output |
| Step 2 live-call ACs (AC1, AC2, AC3, AC4, AC6) | **NOT witnessed — blocked on API keys** | `.env` keys empty |
| AC5 grep proof | **Witnessed**: concrete providers imported only by `app/ai/registry.py`; model-JSON parsed only in `structured.py` | grep output this session |
| Lint | ruff clean (`EXE002` ignored — bind-mount artifact) | in-container run |
| Image build | Re-verified green after the D-003 packaging fix | build log |
| Probes | `probe_structured_guard.py` **written, never run green**. `probe_ai_smoke.py` (helper) same | Directory listing |

## What was just finished

- **S2-B1…B9 all built.** `base.py` (protocol, `GenRequest`/`GenResult`/`VersionedSchema`, `TaskName` ×8, `CallOutcome` ×5, typed error hierarchy incl. `StructuredOutputError.raw_output`); `google.py` (google-genai, native `response_json_schema`, embeddings, safety→`RefusedError`, 429→`RateLimitedError`); `openrouter.py` (httpx, native `json_schema` with remembered per-model fallback to prompt-embedded, upstream-error tunneling handled, `embed` = typed error since embeddings are pinned to google); `registry.py` (the only instantiation point; boots without keys, logging loudly); `routing.py` (startup-fails on incoherent config; unfilled slot → typed error, never a guess); `structured.py` (the one Guard: validate→repair→3 attempts→typed give-up, fence stripping, prompt-embedded fallback); `resilience.py` (backoff, per-provider `RateLimiter`, `MAX_ATTEMPTS=3`, the mandatory `ai_call` line + `ai_call_retry` detail lines); `app/schemas/` registry + a **loud** `agent_response.py` stub (D-001: an absent file hides better than a stubbed one).
- **Wiring:** lifespan builds providers + `TaskRouter` at startup — config incoherence kills boot, per S2-B5.
- **Provisional model choice recorded:** google routes set to `gemini-2.5-flash` (the spec's `gemini-flash` is not a callable id). Provisional per the plan's own terms; final choice belongs to the gates. OpenRouter slots untouched.
- **D-003 found and closed** (see `DEFECTS.md`): setuptools auto-discovery broke the build the moment `probes/`/`tests/` gained `.py` files; explicit `include = ["app*"]` now pinned; full image rebuild re-verified.
- Logging decision worth knowing: `execute()` emits ONE `ai_call` line per provider call with the final outcome (`ok`/`rate_limited`/`refused`/`gave_up`) plus `ai_call_retry` lines per intermediate failure; the Guard adds `ai_call` lines with `malformed`/`gave_up` after validation. All five §5 outcomes have exactly one home.

## What is next

1. **Witness Step 2** the moment keys land in `.env` (docker compose restart api first, so the env reaches the container):
   - `docker compose exec api python probes/probe_structured_guard.py` → must print GREEN (3 malformed, 1 gave_up, no silent default).
   - `docker compose exec api python probes/probe_ai_smoke.py <free-openrouter-model>` → both providers answer, embedding is 768-dim. The OpenRouter model argument is *for the probe only* — do not fill the routing slots for it.
   - AC4: change `trait_extraction`'s model in `config/ai.yaml`, restart, watch the log line name the new model, change it back.
   - AC6 (a real 429 retried with backoff → typed error) may occur naturally under free-tier quotas during the smoke run; if not seen, record it as an owed measurement.
2. **Step 3 — Core schema and startup reconciliation** (S3-B1…B7). Independent of Step 2's witnesses; may start immediately. Mind traps 5 and 6 below.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Step 2 witnesses (AC1–AC4, AC6, S2-P1 green) | **Owner:** the two API keys into `.env` | Everything else about Step 2 is done |
| Native desktop witness (O-4) | **Owner:** enable Windows Developer Mode, then `flutter run -d windows` in `ux\` | Unchanged from last session |
| OpenRouter `free-model-of-choice` slots | **Owner decision, deferred by design** | Probe takes a model as an argument precisely so the slots stay unfilled |
| Paid-balance question | **Owner**, from the quota-fit numbers | Unchanged |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Unchanged (decision log #11) |

## Traps that will bite you resuming cold

1. **Three git repositories.** Submodule commit(s) first, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.
2. **`docker compose down`/`up` is NOT a cold start** — the `db_data` volume survives. True cold = `down -v`.
3. **Flutter is not on PATH**: use `C:\src\flutter\bin\flutter.bat` (SDK installed 2026-09-01). Android SDK absent; targets are web and (after Developer Mode) Windows desktop.
4. **`.env` holds the DB password the volume was initialized with** — regenerate both together or neither.
5. **The `questions` table has a forward reference** (`module_1_data_collection.md` A3): create `traits` before `questions`, or add the FK after both exist.
6. **`profile_embeddings`: build the two-vector form** (`kind IN ('identity','preference')`, PK `(user_id, kind)`) — the revised copy, restated in `candidate_matching.md` §3.
7. **Editing `.env` does not reach a running container** — compose reads it at container start; `docker compose up -d` / restart after key changes.
8. **`ai_routes_unresolved` + two `provider_built … api_key_present: false` warnings at boot are correct behaviour**, not bugs — they disappear only when the owner supplies keys and fills slots.
9. **The 200-character minimum applies to dispute answers too** (§18); **dispute questions are outside pool progress** (§13).
10. **Calibration chat and match chat share a widget but differ** in flagging/metadata rules (§13).
11. **Load-bearing orderings** (§19): checkpoint before advancing; counts before cascade; validate before repair; `traits_hash` only after the trait write commits.
12. **An all-`keep` extraction run leaves everything fresh** (A5.1); **the 30-message cap counts environment rows** (§18).
13. **Ruff's `EXE002` is suppressed on purpose** — through the Windows bind mount every file looks executable; do not "fix" it by chmod.
14. **Decided things stay decided** (§23).

## Owed measurements (§4)

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-1 | `opt_in` observed changing pool membership | Step 4 | Step 9 AC4 | **Anticipated** |
| O-2 | Pinned-snapshot assertion in `probe_answer_edit.py` | Step 6 | Step 9 (S9-P2) | **Anticipated** |
| O-3 | Matching vs properly seeded demo profiles | Step 9 | Step 15 | **Anticipated** |
| O-4 | Native (Windows) run rendering `/health` | Step 1, 2026-09-01 | Owner: Developer Mode + `flutter run -d windows` | **Owed** |
| O-5 | **Every Step 2 live-call AC**: generation via both providers with §5 log lines (AC1); 768-dim embedding (AC2); `probe_structured_guard.py` green (AC3); model-swap-by-config observed in the log line (AC4); a real 429 retried then typed (AC6) | Step 2, 2026-09-01 | Keys in `.env` → run the two probes + the AC4 config flip | **Owed** |

## Probe status (§2)

| Probe | Status |
|---|---|
| `probe_structured_guard.py` | **Written, never run green** (needs GOOGLE_AI_API_KEY) |
| `probe_ai_smoke.py` (helper, not in the §2 minimum set) | Written, never run green |
| All others (`pool_expansion`, `answer_edit`, `onboarding`, `matching_filters`, `simulation_resume`, `judge`, `deletion`, `demo_seeding`) | Not written — delivered in Steps 5–15 |

## Module build order

1 ~~Foundations~~ **(done; O-4)** · 2 AI Interaction **(built; O-5 — witnesses blocked on keys)** · 3 Schema + reconciliation ← **next buildable** · 4 Accounts · 5 Questions & answers · 6 Trait extraction · 7 Persona & snapshots · 8 UX profile + **fidelity gate** · 9 Matching · 10 UX dashboard · 11 Simulation + **quota gate opens** · 12 Judge + **quota gate closes** · 13 UX results · 14 Chat · 15 Data hygiene · 16 Witness sweep.

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **Open** |
| Quota fit | Step 11 → 12 | **Open** |

## Where the decisions live

- **What:** `user_perspective.md` → `project_description.md` → module plans. **How:** `development_principles.md`.
- **Wire:** `communication_protocol.md`. **Order:** `IMPLEMENTATION_PLAN.md`. **What went wrong:** `DEFECTS.md` (D-001…D-003).
