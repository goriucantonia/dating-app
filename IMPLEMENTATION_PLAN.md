# Implementation Plan — 16-Step Build Roadmap

Status: drafted 2026-09-01 from the locked planning set. **This document invents nothing.** Every task, cap, threshold, endpoint, and state name below is traceable to one of: `user_perspective.md` (source of truth), `project_description.md` (architecture + decision log), `technical_details.md` (stack), `communication_protocol.md` (the wire), `development_principles.md` (the *how*), the server module plans (`module_1_data_collection.md`, `ai_interaction.md`, `trait_persona.md`, `candidate_matching.md`, `date_simulation.md`, `chat.md`, `data_hygiene.md`), and the UX module plans (`ux_architecture.md`, `new_user_creation.md`, `profile_settings.md`, `main_dashboard.md`, `simulate_date_page.md`, `simulation_results.md`, `chat_selection.md`).

Where a task exists only because a principle demands it, the principle number is cited (`§7`, `§17`, …). Section numbers in `development_principles.md` are stable and must not be renumbered.

---

## How to read this document

- **Ticket IDs.** `S<step>-B<n>` = server/backend, `S<step>-U<n>` = UX/frontend, `S<step>-D<n>` = DevOps/Docker, `S<step>-P<n>` = probe (`§2`).
- **Sequential by default.** Each step assumes every prior step is *witnessed*, not merely written (`§1`). Two pairs can overlap safely and are marked so.
- **"Done" is the ten-point Definition of Done** at the bottom of `development_principles.md`. The per-step Acceptance Criteria below are the *step-specific* half of it; the standing half applies to every step and is not repeated sixteen times.

### Repository layout — where every ticket's output goes

Three git repositories: the `dating-app` superproject at `dating_app_ai/`, with `server` and `ux` as submodules.

| Ticket type | Destination | Repo |
|---|---|---|
| `S<n>-D*` — DevOps/Docker: `docker-compose.yml`, `Dockerfile`, `.env.example`, `.gitignore` | **superproject root** | `dating-app` |
| `S<n>-B*` — Python: `app/`, `migrations/`, `alembic.ini`, `pyproject.toml`, `seeds/`, `scripts/` | `server/` | `server` |
| `S<n>-P*` — probes | `server/probes/` | `server` |
| `S<n>-U*` — Flutter/Dart, the whole app | `ux/` | `ux` |
| Specs, this plan, `PICKUP.md`, `DEFECTS.md` | **superproject root** | `dating-app` |

Bare relative paths in the tickets below (`probes/`, `app/ai/base.py`, `scripts/scan_dead_data.py`, `seeds/demo_profiles.yaml`) are **relative to `server/`** unless the ticket says otherwise. Infrastructure paths are relative to the superproject root.

A change spanning both submodules is three commits: `server`, `ux`, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.

### Standing obligations (apply to all 16 steps — `development_principles.md`)

| Obligation | Principle |
|---|---|
| The log line ships in the same commit as the feature, including the refusal and failure paths | §7 |
| Every flag/gate is observed behaving differently in both settings before it counts as built | §8 |
| Every retry/loop ships with its give-up condition in the same commit, and the give-up is watched firing once | §17 |
| Anything stateful is witnessed on its **second** run, not just its first | §1 |
| Report status in the words the evidence supports — "built, not yet witnessed" until it is | §6 |
| New trades named in the decision log or the owning module plan | §20 |
| Defects appended to `DEFECTS.md`; `PICKUP.md` updated as part of the work | §21, §24 |
| Layman's terms in every explanation and every piece of UI copy | §26 |

### Current state at the time of writing (verified, not assumed — §13)

**There is no application code.** The slate is clean and every step below assumes it.

- Superproject root: the five specs, this plan, `PICKUP.md`, `DEFECTS.md`. **No Docker files, no `.env.example`, no `.gitignore`.**
- `server/`: `README.md`, `pyproject.toml` (intended dependencies, never installed or checked), and the seven server module plans. **No `app/`, no database, no migrations, no FastAPI application object, no `probes/`.**
- `ux/`: `README.md` and the seven UX module plans. **No Flutter project.**
- Nothing has ever been witnessed running (`§1`). The honest status of the whole system today is *planned, not yet built*.

### Probe map (`§2` — the minimum probe set, and the step that delivers each)

| Probe | Delivered in |
|---|---|
| `probe_structured_guard.py` | Step 2 |
| `probe_pool_expansion.py` | Step 5 |
| `probe_answer_edit.py` | Step 6 (written), Step 9 (its pinned-snapshot assertion enabled) |
| `probe_onboarding.py` | Step 7 |
| `probe_matching_filters.py` | Step 9 |
| `probe_simulation_resume.py` | Step 11 |
| `probe_judge.py` | Step 12 |
| `probe_deletion.py` | Step 15 |
| `probe_demo_seeding.py` | Step 15 |

### Gate register (`ai_interaction.md` §3 — both must close before the first real analysis)

| Gate | Opened by | Closed in |
|---|---|---|
| **Fidelity transfer check** — re-validate persona voice on the *actually routed* `date_simulation` model | Calibration chat exists | Step 8 |
| **Quota fit check** — ~190 calls/analysis vs the chosen providers' per-minute *and* per-day caps | Simulation call volume is known | Step 11 (spreadsheet), confirmed by the full run in Step 12 |

---

# Step 1 — Foundations: the stack, the wire, and the honesty artifacts

**Goal.** A `docker compose up` brings `api` + `db` alive, a Flutter app on the owner's machine reaches the API over real HTTP, and the project's bookkeeping artifacts (`PICKUP.md`, `DEFECTS.md`, `probes/`) exist so the discipline in `development_principles.md` has somewhere to live from commit one.

### Technical Tasks — DevOps/Docker

- **S1-D1** `docker-compose.yml` **at the superproject root**: exactly two services, `api` (FastAPI, build context `./server`) and `db` (Postgres + pgvector image). `db` is on the compose-internal network only — never a published port to the host app (`communication_protocol.md` §2). `api` publishes `8000`. *(Location revised 2026-09-01 by owner decision — the superproject is the only repo that can describe a deployment spanning both submodules. `communication_protocol.md` §2 carries the dated revision; what Compose orchestrates is unchanged.)*
- **S1-D2** `Dockerfile` **at the superproject root**, building `api` from `./server` (Python 3.11+), with the server source bind-mounted in dev so a reload is a save, not a rebuild.
- **S1-D3** `.env.example` **at the superproject root**, naming every variable the config reads: `GOOGLE_AI_API_KEY`, `OPENROUTER_API_KEY`, `DATABASE_URL`, `JWT_SECRET`. Real `.env` git-ignored.
- **S1-D6** `.gitignore` at the superproject root covering `.env` and build artefacts; note that a submodule's own ignores do not cover the root, and the root's do not reach inside a submodule.
- **S1-D4** Healthcheck on `db`; `api` waits for it. A cold `docker compose up` must reach a serving API without a human retry.
- **S1-D5** Confirm the Flutter app is **not** containerized this phase, and record it as the named trade it already is (`communication_protocol.md` §2).

### Technical Tasks — Server/Backend

- **S1-B1** `app/main.py`: the FastAPI application object, `GET /health` (checks its own DB connection, not just liveness), and CORS enabled for the Flutter-web origin (`communication_protocol.md` §2).
- **S1-B2** The single error envelope as an exception handler pair: `{"error": {"code": ..., "message": ...}}` for every non-2xx, with `code` a stable machine string and `message` already layman-readable (`communication_protocol.md` §5, `§26`).
- **S1-B3** Structured logging setup (one line per decision, machine-parseable fields) — the substrate every later `§7` obligation writes into.
- **S1-B4** `alembic.ini` + `migrations/` initialised and wired to the async engine; `CREATE EXTENSION IF NOT EXISTS vector` as the first migration. No tables yet.
- **S1-B5** `app/config.py` — settings loading, including the `ai:` block of `ai_interaction.md` §3 verbatim (providers, pinned `embeddings`, `routing`) from a YAML file, with the `free-model-of-choice` slots **deliberately unfilled** and a startup log line saying which routes are unresolved.
- **S1-B9** Verify `pyproject.toml`'s dependency set actually installs together in the `api` image — it lists the intended packages but has never been resolved. Pin what needs pinning; a failed resolve on day one is cheaper than on day forty.
- **S1-B6** Create `server/probes/` with a README stating the contract: a probe drives a mechanism end-to-end against the real deployment and prints a verdict a human can read (`§2`).

### Technical Tasks — UX/Frontend

- **S1-U1** `flutter create` the app in `ux/`, targeting mobile + desktop + web from one codebase (`technical_details.md`).
- **S1-U2** Dependencies per `ux_architecture.md` §1: `flutter_riverpod`, `go_router`, `dio`, `freezed`/`json_serializable`, `flutter_secure_storage`, `fl_chart`.
- **S1-U3** Material 3 theming: light + dark from one seed colour, system-following (`ux_architecture.md` §1.6).
- **S1-U4** The layout shell: phone-first; above 840px width, content constrained to a centered ~720px column (`ux_architecture.md` §1.7).
- **S1-U5** `ApiClient` on dio with **one** configured base URL (`http://localhost:8000` in dev) as the app's single piece of environment configuration.
- **S1-U6** A throwaway debug screen that calls `GET /health` and renders the result — the first proof that the wire in `communication_protocol.md` is real and not a diagram.

### Technical Tasks — Project artifacts

- **S1-B7** `PICKUP.md` at the project root with its sections seeded: state, just finished, next, blocked-and-on-whom, traps, **Owed measurements** (`§4`, `§24`), the module build order (this document), and which probes currently pass.
- **S1-B8** `DEFECTS.md` at the project root: numbered, append-only, one shared ledger for both repos (`§21`).

### Acceptance Criteria

1. `docker compose up` from cold, on a machine with no prior volumes, serves `GET /health` returning a DB-connected 200 — observed, not inferred.
2. `docker compose down && up` a second time serves the same 200 (`§1`: the second run is part of the witness).
3. The Flutter app, run natively **and** as a web build, renders the health response fetched over real HTTP from the api container.
4. `psql` from inside the `api` container reaches `db`; the same connection attempt from the host app is impossible by network topology, not by convention.
5. A deliberately raised error returns the exact `{"error":{"code","message"}}` envelope, and `/docs` renders the OpenAPI page.
6. `PICKUP.md` and `DEFECTS.md` exist and describe the true state.

### Dependencies

- **External:** Docker Desktop installed; Flutter SDK installed; Python 3.11+.
- **Preceding steps:** none. This is the root of the tree.
- **Not required yet:** AI provider API keys (Step 2), model selection (deferred to the gates).

---

# Step 2 — AI Interaction Module: the foundational service

**Goal.** Every future AI call in this system has exactly one road to travel: `task name → router → provider → Structured Output Guard → validated dict or a typed error`. Build the whole layer, so no feature module ever parses JSON or imports a concrete provider (`§16`).

Built from nothing against the locked interface in `server/ai_interaction.md` §1–§5. **Write every file named in that document's §1 layout, even the ones you are not implementing yet** — a file with a `NotImplementedError` and a TODO announces its own incompleteness; a file that is simply absent does not (`DEFECTS.md` D-001).

### Technical Tasks — Server/Backend

- **S2-B1** `app/ai/base.py` — the `AIProvider` protocol from `ai_interaction.md` §2, the `GenRequest`/`GenResult`/`VersionedSchema` value types, the `TaskName` literal covering all eight routed tasks, the `CallOutcome` literal (`ok | malformed | rate_limited | refused | gave_up`), and the typed error hierarchy: `AIError` (carrying task/provider/model), `TransientAIError`, `RateLimitedError`, `RefusedError`, `StructuredOutputError` (carrying the raw output). Typed errors are the contract with the resilience layer — SDK exceptions must never escape the module.
- **S2-B2** `app/ai/google.py` against the `google-genai` SDK: `generate`, native structured output via `response_schema`, and `embed`. Map SDK rate-limit errors to `RateLimitedError` and safety blocks to `RefusedError`.
- **S2-B3** `app/ai/openrouter.py` against the OpenAI-compatible REST surface with `httpx`: native `response_format: json_schema` where the model supports it, falling back so the Guard embeds the schema in the prompt where it does not (`ai_interaction.md` §4.1).
- **S2-B4** `app/ai/registry.py` — builds provider instances from config, `name -> instance`. Nothing else may instantiate a provider.
- **S2-B5** `app/ai/routing.py` — `TaskRouter`, resolving `task -> (provider, model)` from config. Fails at startup, not mid-date: every routed provider must exist, and every task whose model slot is still a placeholder is logged loudly so an unfilled route is never a surprise.
- **S2-B6** `app/ai/structured.py` — the single choke point, in the locked order (`§19`: **validate before any repair prompt**): native mode first → validate against the versioned JSON schema (`jsonschema`) → on failure one repair prompt carrying the validation error → **max 3 attempts total** → raise `StructuredOutputError` with the raw output. Never a silent default (`§10`).
- **S2-B7** `app/ai/resilience.py` — exponential backoff on 429/5xx, per-provider rate limiters, retries capped at 3 (`§17`), typed exceptions out.
- **S2-B8** The mandatory per-call log line (`ai_interaction.md` §5): `task, provider, model, attempt, latency_ms, outcome`.
- **S2-B9** `app/schemas/` — the schema registry holding `VersionedSchema` instances; `agent_response.v1` is added here in Step 7.

### Technical Tasks — Probe

- **S2-P1** `probes/probe_structured_guard.py` — force malformed output with a deliberately hostile schema/model combination; watch the repair attempts, then the typed give-up; assert nothing downstream received a silent default (`§2`).

### Technical Tasks — UX/Frontend

- None. This step is server-only.

### Acceptance Criteria

1. A real generation call succeeds through **both** providers against real APIs, with the `§5` log line present for each.
2. A real embedding call returns a 768-dimension vector from the pinned embedding model.
3. `probe_structured_guard.py` prints a human-readable verdict showing: attempt 1 malformed → repair → attempt 2 malformed → repair → attempt 3 → `StructuredOutputError` raised with raw output logged. The give-up has been **observed firing** (`§17`, `§8`).
4. Changing a model in the routing YAML and restarting changes the model named in the log line — with no code edit anywhere (`ai_interaction.md` §3, locked item 2).
5. `grep` proves no module outside `app/ai/` imports `google.py` or `openrouter.py`, and no module outside `structured.py` parses model JSON (`§16`).
6. A rate-limit response from a free model is observed being retried with backoff and then surfacing as a typed error, not a crash.

### Dependencies

- **Preceding:** Step 1 (config loading, logging substrate, running container).
- **External:** `GOOGLE_AI_API_KEY` and `OPENROUTER_API_KEY` in `.env`; at least one working free OpenRouter model and one Google model to exercise the paths — **provisional, not the final selection** (model choice is deferred to the gates by owner decision).

---

# Step 3 — Core schema and startup reconciliation

**Goal.** The Module 1 tables exist exactly as locked in `module_1_data_collection.md` A3, and BQ1–BQ5 + PQ01–PQ30 arrive in the database through the reconciliation pass — never through a "it shipped with us" shortcut (`§12`).

### Technical Tasks — Server/Backend

- **S3-B1** Alembic migration creating `users`, `questions`, `answers`, `traits`, `trait_events`, `profile_embeddings` — verbatim from A3, including every CHECK constraint, the `interested_in TEXT[]`, `is_demo`, and the three-origin `questions` table (`baseline` / `pool` / `dispute`) with `pool_order`, `code`, and `trait_id`.
- **S3-B2** `profile_embeddings` is created in its **revised** form from `candidate_matching.md` §3: `kind IN ('identity','preference')`, primary key `(user_id, kind)`, `vector(768)`, `embedding_model`, `traits_hash`. Do not create the superseded single-vector version.
- **S3-B3** SQLAlchemy async models mirroring the migration one-to-one. Text + CHECK rather than native enums, per the named trade in A3.
- **S3-B4** Seed data as committed fixtures: BQ1–BQ5 verbatim from A2 (codes, `probe_area`, exact text) and PQ01–PQ30 verbatim from A5.3 (codes, `pool_order` 1–30, `probe_area`, exact text). Verbatim means character-for-character — these lists are locked.
- **S3-B5** `reconcile()` — step 1 of the four-step pass in `data_hygiene.md` §2: compare desired question rows against actual on **every boot**, insert what is missing, update drifted text, log what it seeded and what it found already correct. Steps 2–4 of the pass land in Steps 15 and 11.
- **S3-B6** Wire `reconcile()` into application startup and make it invocable from a management script.
- **S3-B7** `traits_hash` helper: a deterministic hash over a user's trait set, computed in one place. `§19` — it is bumped **only after** the trait write commits, so staleness can never claim freshness. Nothing consumes it yet; it exists here because the trait tables do.

### Technical Tasks — UX/Frontend

- None.

### Acceptance Criteria

1. First boot on an empty database logs 35 questions seeded; `SELECT count(*) FROM questions WHERE user_id IS NULL` returns 35.
2. **Second boot logs a no-op** and inserts nothing — the state-consuming run required by `§1`.
3. Deleting one pool row and rebooting restores exactly that row and logs the repair (reconciliation, not a fresh-install path).
4. Every CHECK constraint is proven by a rejected insert: an answer under 200 characters, an `age_pref_max < age_pref_min`, a `pool` question with a NULL `pool_order`, a `dispute` question with a NULL `trait_id`, an `interested_in` of length zero.
5. `pgvector` accepts a 768-dimension insert into `profile_embeddings` and rejects a wrong-dimension one.
6. The seeded question text is diffed against `module_1_data_collection.md` and is identical.

### Dependencies

- **Preceding:** Step 1 (Alembic wiring, `vector` extension, running `db`).
- **Note:** independent of Step 2 — Steps 2 and 3 may run in parallel if two people are working.

---

# Step 4 — Accounts: registration, login, and `/me`

**Goal.** A person can create an account with the exact A1 form, receive a JWT, and read/update their own profile — with the 18+ gate, the mutual-fit fields, and the `opt_in` toggle all real from the first commit.

### Technical Tasks — Server/Backend

- **S4-B1** `POST /auth/register` — the A1 form exactly: `email` (unique, format only, no verification this phase), `password` (min 8, bcrypt to `password_hash`), `display_name` (1–50), `birth_date` (must yield age ≥ 18; **age computed, never stored**), `gender`, `interested_in` (≥1), `age_pref_min`/`age_pref_max`, `city`/`country` (informational — distance filtering is deferred, columns kept), `opt_in` (default **off**).
- **S4-B2** `POST /auth/login` → JWT. These two are the **only** unauthenticated endpoints (`communication_protocol.md` §3).
- **S4-B3** JWT bearer dependency for every other route; `401` on a dead session. No refresh tokens this phase (named trade).
- **S4-B4** `GET /me` and `PATCH /me` — profile fields, preferences, and the `opt_in` toggle.
- **S4-B5** `422` validation with field-level detail in the single error envelope for every A1 rule, so the client can mirror them (`communication_protocol.md` §5).
- **S4-B6** `DELETE /me` is **not** built here — it belongs to Data Hygiene (Step 15) where its cascade can be verified whole rather than grown piecemeal.

### Technical Tasks — UX/Frontend

- **S4-U1** `AuthRepository` (dio + hand-written, freezed models, per `ux_architecture.md` §1.3) — no OpenAPI codegen this phase, by named trade.
- **S4-U2** JWT storage: `flutter_secure_storage` on mobile/desktop, carefully-scoped localStorage on web. A dio interceptor attaches the bearer and routes every `401` to `/login` — **one** interceptor, one place (`§16`).
- **S4-U3** `/register` as three short steps — account → about you → who you're looking for (`new_user_creation.md` §1) — with client-side validation mirroring every server CHECK so errors land at the field, not after submit.
- **S4-U4** The opt-in toggle on the registration form: default off, one-line description, and registration never blocks on it.
- **S4-U5** `/login`.
- **S4-U6** go_router with typed routes and the guard skeleton: unauthenticated → `/login`. The second guard (baseline questionnaire incomplete → `/onboarding/questions`) is added in Step 5. Both guards live in this one place (`§16`).
- **S4-U7** Retire the Step 1 debug health screen.

### Acceptance Criteria

1. Register → login → `GET /me` succeeds end-to-end over real HTTP against the running stack from the Flutter app.
2. A birth date yielding age 17 is rejected server-side **and** blocked client-side; the server rejection is the one that counts.
3. A duplicate email returns the error envelope with a stable `code`, rendered by the UI as its `message` verbatim.
4. Killing the app and reopening it restores the session from secure storage without re-login.
5. An expired or tampered token produces `401` → the interceptor lands on `/login` — observed, not assumed.
6. `PATCH /me` flips `opt_in` and the change is visible in the database. Both settings of the flag are observed (`§8` — its behavioural difference is witnessed in Step 9, and until then this is an owed measurement in `PICKUP.md`, §4).

### Dependencies

- **Preceding:** Step 3 (the `users` table), Step 1 (Flutter shell, error envelope).

---

# Step 5 — Questions and answers: save, resume, expand, exhaust, edit

**Goal.** The questionnaire loop is complete and durable: five baseline questions one per page with autosave, batches of five from the curated pool, a graceful `pool_exhausted` state, and every past answer editable through the identical upsert path.

### Technical Tasks — Server/Backend

- **S5-B1** `GET /questions` — everything answerable by this user (baseline + pool + their own dispute questions), each with answered/unanswered state and the answer text when present. This one endpoint drives save/resume **and** the edit view (A4).
- **S5-B2** `GET /questions/next-batch` — up to 5 unanswered **pool** questions ordered by `pool_order`, plus `progress: {answered_pool, total_pool}`. The answer set *is* the cursor; there is no assignment table.
- **S5-B3** `pool_exhausted`: when all 30 are answered, return `{status: 'pool_exhausted', questions: [], progress: {answered_pool: 30, total_pool: 30}}` — a **normal payload with a status field, not a 4xx** (`communication_protocol.md` §5; A5.4).
- **S5-B4** `PUT /answers/{question_id}` — one upsert path for the first write and every later edit, `updated_at` bumped on edit. The 200-character minimum applies to baseline, pool, **and** dispute answers (`§18` — the scope is written down because a rule written for one case is a trap in the case it did not consider).
- **S5-B5** Answer-edit logging (`§7`): old/new length, and the trait IDs whose `source_answer_ids` include the edited answer.
- **S5-B6** Dispute questions do **not** count toward `answered_pool` — they are per-user and outside pool progress (`§13`: this is one of the named traps; do not assume all questions behave like pool questions).

### Technical Tasks — UX/Frontend

- **S5-U1** `/onboarding/questions`: one question per page, `1 of 5` progress, large multiline field, a character counter that turns from muted to confirmed at 200, and the A2 voice nudge under the field.
- **S5-U2** Autosave: `PUT /answers/{question_id}` on page advance **and** on a 2-second idle debounce, so closing mid-sentence loses at most a couple of words (named trade: a few extra PUTs, chosen over a save button users forget).
- **S5-U3** Resume: `GET /questions` drives "first unanswered question" on return; the go_router guard sends any signed-in user with unanswered baseline questions here (`ux_architecture.md` §1.2 — the "nothing works without it" gate, in one place).
- **S5-U4** The pre-questionnaire interstitial, verbatim in spirit: "5 questions, about 10 minutes. Write like you talk — the AI learns your voice from this. Nothing works without it."
- **S5-U5** `/profile/expand`: the "Answer 5 more questions" action with pool progress ("15 of 30 answered"), reusing the **same** one-per-page widget and autosave as onboarding (`§16` — not a second implementation).
- **S5-U6** The exhausted state replacing the CTA: "You've answered everything — your profile is as deep as it gets for now. Keep it sharp by editing old answers." Styled as an achievement, no error styling.
- **S5-U7** Editing past answers: every answered question listed with its answer and an edit action into the same one-question editor. Copy states that edits change future matches, not past results.
- **S5-U8** The four states — loading / content / empty / error-with-retry — on every async screen here (`ux_architecture.md` §1.5, global and non-optional).

### Technical Tasks — Probe

- **S5-P1** `probes/probe_pool_expansion.py` — batches of 5 in `pool_order`; abandon a batch mid-way and resume to the same remaining questions; drive to exhaustion and verify the exact `pool_exhausted` payload (`§2`).

### Acceptance Criteria

1. Answer BQ1 and BQ2, **kill the app**, reopen: the user lands on BQ3 with BQ1–BQ2 preserved (`§1` — the second run consumes the state).
2. `probe_pool_expansion.py` prints a green verdict covering all six batches, the abandoned-batch resume, and the exhausted payload.
3. A 199-character answer is rejected with `422` server-side and blocked client-side.
4. Requesting a batch after question 30 returns the defined `pool_exhausted` payload — and the UI shows the achievement state, not an empty list or an error.
5. An edit to a past answer changes `answers.updated_at` and travels the identical upsert path as the original write (proven by the request log, not by reading the code).
6. Six batches × 5 = 30 exactly; batch 7 is the exhausted state.

### Dependencies

- **Preceding:** Step 3 (questions/answers tables, seeded pool), Step 4 (auth, so answers belong to someone).
- **Note:** the extract-on-batch-completion chain is stubbed here and wired in Step 6; `/profile/expand` is reachable but the trait display it sits beside arrives in Step 8.

---

# Step 6 — Trait extraction: verdict-based, holistic, with provenance

**Goal.** Answers become structured trait rows carrying confidence, status, and provenance — reconciled holistically on every run via explicit per-row `keep`/`update`/`retract`/`add` verdicts, so a user's confirmations never evaporate (decision log #10).

### Technical Tasks — Server/Backend

- **S6-B1** `POST /profile/extract` — reads **all** answered questions and the user's **existing trait rows** (id, label, description, status), and requires the model to return a verdict per existing row plus `add` entries for genuinely new traits. Rows are matched **by id, never by re-matching wording** (A5.1).
- **S6-B2** The extraction JSON schema, versioned, routed through the Structured Output Guard from Step 2. No JSON parsing in this module.
- **S6-B3** Apply verdicts: `update`/`retract` write `trait_events` (`retract` sets `status='retracted'` — **never a silent delete**); `add` inserts with `confidence`, `status='inferred'`, `source_answer_ids`, `extracted_by`.
- **S6-B4** Staleness cascade, in the locked order (`§19`): trait write commits **first**, then `traits_hash` is bumped. Only an `update`/`retract`/`add` changes the hash — **an all-`keep` run leaves embeddings and the persona snapshot fresh** rather than marking them stale for nothing.
- **S6-B5** Concurrency give-up (`§17`): at most one extraction per user at a time; a request during a run queues **exactly one** follow-up, never a pile-up.
- **S6-B6** `GET /traits` — the profile with `confidence` and `status`, the payload the UI's dispute controls read.
- **S6-B7** `POST /traits/{id}/dispute` — mark `disputed`, AI-generate **one** follow-up question (`origin='dispute'`, linked by `trait_id`) so the next extraction corrects rather than re-infers, and write the `trait_event`.
- **S6-B8** Confirm action: `status='confirmed'` + `trait_event`. No code path may treat an `inferred` trait as confirmed (`§9`).
- **S6-B9** Extraction may legitimately produce **no trait** from a thin answer, and that decline is logged and counted (`§10`).
- **S6-B10** Logging (`§7`): provider, model, input answer IDs, produced/updated/retracted traits, and on the failure path the raw model output.

### Technical Tasks — Probe

- **S6-P1** `probes/probe_answer_edit.py` — edit an old answer; verify holistic re-extraction, the `trait_events` written, and that embeddings and the snapshot go stale. Assert that a **confirmed** trait survives an unrelated edit. Its remaining assertion — that a pinned snapshot in a past analysis did **not** change — is enabled in Step 9 when analyses exist, and is recorded in `PICKUP.md` as an owed measurement until then (`§4`).
- **S6-P2** The drift alarm: a no-edit re-run must produce all-`keep` (or near it); `trait_events` volume on a no-edit re-run is the alarm (A5.1). Assert it in the probe.

### Technical Tasks — UX/Frontend

- None here — the trait display is Step 8, after snapshots exist so the header can show persona state in one pass.

### Acceptance Criteria

1. Five real baseline answers produce trait rows across the locked categories, each with non-empty `source_answer_ids` and a populated `extracted_by`.
2. Re-running extraction with **no** changes produces all-`keep`, writes no `trait_events`, and leaves `traits_hash` untouched — the second-run witness (`§1`).
3. Confirm a trait, then edit an unrelated answer and re-extract: the confirmed trait is still `confirmed`, with its provenance and dispute history intact. This is the load-bearing assertion of decision log #10.
4. A dispute creates exactly one `origin='dispute'` question linked by `trait_id`, and the trait shows `disputed`.
5. A retracted trait is present in the table with `status='retracted'`, not absent.
6. Two rapid extract requests result in one run plus one queued follow-up — never two concurrent runs (`§17` give-up observed).
7. A deliberately thin answer produces the logged "no trait" decline rather than an invented trait (`§10`).

### Dependencies

- **Preceding:** Step 2 (Guard + routing), Step 3 (traits/trait_events/answers), Step 5 (answers to extract from).

---

# Step 7 — Persona compilation, snapshots, and `agent_response.v1`

**Goal.** Trait rows become an immutable, versioned persona snapshot — the only thing dates and chat are ever allowed to consume — and the response schema every AI agent must obey is frozen in code.

### Technical Tasks — Server/Backend

- **S7-B1** Alembic migration: `persona_snapshots`, `calibration_sessions`, `calibration_messages` verbatim from `trait_persona.md` §4.
- **S7-B2** Register `agent_response.v1` in `app/schemas/agent_response.py` exactly as frozen in `trait_persona.md` §3 — `reply`, `state_of_mind`, `emotional_state`, `connection` (0–100), `satisfaction` (0–100), **`wants_to_end`**. Every snapshot stores the schema version it was built for.
- **S7-B3** `PersonaCompiler`, two-part assembly:
  - *Code-assembled, no AI call:* hard facts, trait rows grouped by category, and **3–5 verbatim excerpts** from the user's own answers chosen by length and probe-area spread. No model paraphrase between the user's writing and the mimicry (trade #1 — paraphrase would launder out the voice).
  - *One structured AI call:* the behaviour digest (tense moments, flirting, supporting, opening up) synthesised from situational answers, through the Guard, model recorded in `digest_model`.
- **S7-B4** Snapshots are **immutable and per-user versioned**; recompiling creates v(n+1) and old transcripts keep pointing at their own version. Status `compiling → ready | failed`; a failed compilation records the error and **leaves the previous snapshot current**.
- **S7-B5** `PersonaService.get_current_snapshot()` returning `None` is a hard gate (`§11`): that user cannot be simulated, so they are never offered as a candidate — never simulated degraded.
- **S7-B6** Auto-trigger compilation after extraction finishes; also expose it on demand.
- **S7-B7** `POST /persona/compile` (returns `{snapshot_id, status}` immediately — start-then-poll) and `GET /persona/current` (status + metadata). **The raw system prompt never leaves the server** — it embeds the user's raw intimate answers (`communication_protocol.md` §6, `trait_persona.md` §7.5).
- **S7-B8** Calibration endpoints: `POST /calibration/sessions`, `POST /calibration/sessions/{id}/messages` (one AI call, same `agent_response.v1`, metadata stored but not shown), `POST /calibration/messages/{id}/flag` ("I'd never say that" + optional correction).
- **S7-B9** Flags feed the **next** compilation as explicit negative examples ("never phrase things like: …").
- **S7-B10** Staleness detection: compare the snapshot's `traits_hash` to the live one; expose it on `GET /persona/current` so the UI can show "profile changed — persona will rebuild".
- **S7-B11** Logging (`§7`): trait count, source answer IDs, digest model, outcome; calibration flags log which snapshot they criticise.

### Technical Tasks — Probe

- **S7-P1** `probes/probe_onboarding.py` — register, answer BQ1–BQ5 **with an edit mid-way**, extract, compile; verify traits and a `ready` snapshot exist with provenance (`§2`).

### Technical Tasks — UX/Frontend

- **S7-U1** The post-BQ5 "Building your profile…" screen: calls `POST /profile/extract`, then `POST /persona/compile`, polling snapshot status. The loading copy names the real stage from the two job statuses — "Reading your answers… Extracting traits… Building your persona…" — **never a fake timer** (`new_user_creation.md` §2).
- **S7-U2** Extraction failure → error state with retry, and copy that says the answers are safe and only the processing is retried.
- **S7-U3** Route to `/profile` on success (the screen itself is Step 8).

### Acceptance Criteria

1. A complete onboarding run produces a `ready` snapshot v1 whose `system_prompt` contains verbatim excerpts of the user's own answers.
2. `probe_onboarding.py` prints a green verdict end-to-end on the running stack.
3. Editing an answer → re-extract → recompile produces snapshot **v2**; v1 still exists, unchanged, and is still readable.
4. A user with **no** ready snapshot returns `None` from `get_current_snapshot` — and this is the gate that Step 9 proves excludes them from candidacy (`§8`, `§11`).
5. A forced digest failure leaves the snapshot `failed` with an `error`, and the **previous** snapshot remains current — observed, not reasoned about.
6. `GET /persona/current` never contains the system prompt, verified against the raw response body (`communication_protocol.md` §6).
7. A calibration flag is stored against the correct snapshot and appears as a negative example in the next compilation's prompt.

### Dependencies

- **Preceding:** Step 6 (trait rows + `traits_hash`), Step 2 (Guard), Step 3 (schema base).

---

# Step 8 — UX: profile, traits, calibration, settings — and the fidelity gate

**Goal.** The user can see what the AI thinks it knows about them, correct it in one tap, deepen it, and talk to their own AI double. This step also closes the **fidelity transfer gate**, because calibration chat is the instrument that closes it.

### Technical Tasks — UX/Frontend

- **S8-U1** `/profile` trait display: cards grouped by the six categories, `label` prominent, `description` below.
- **S8-U2** **A guess must look like a guess** (`§9`): `inferred` renders with a dotted border and "AI's read, not confirmed"; `confirmed` solid; `disputed` amber with "being corrected". Confidence renders as a subtle 3-step strength dot, **not a percentage** (named trade — "0.62 confident you're stubborn" reads as absurd theater).
- **S8-U3** Card actions in one tap: "That's right" → confirm; "That's wrong" → dispute, which tells the user a follow-up question was added and deep-links to it. Optimistic updates with rollback — single-row writes are the one place optimism is safe.
- **S8-U4** Header showing persona snapshot state: "Persona v3 · up to date" or "Profile changed — persona will rebuild", with a manual rebuild action (auto-rebuild after each completed batch; no silent background rebuilds mid-calibration — named trade).
- **S8-U5** Auto-refresh the trait list after any extraction completes.
- **S8-U6** `/profile/calibration` — the shared chat widget with the banner "This is your AI double. Talk to it. If a line doesn't sound like you, long-press and flag it." Long-press → "I'd never say that" → optional "what would you say instead?" → flag endpoint. Flagged bubbles show a mark; a footer counts flags and offers "Rebuild persona with these corrections."
- **S8-U7** Build the **shared chat widget** here, once, with its config surface (flagging on/off, metadata on/off) — the same widget Step 14 uses for match chat (`chat_selection.md` decision 3; `§16`). Note the trap in `§13`: the two chats **share the widget by decision but differ in flagging and metadata rules** — do not let one inherit the other's behaviour.
- **S8-U8** `/settings`: opt-in toggle with its one-line description, account fields and preferences editing, theme. The **Delete account** control is built in Step 15 with its server counterpart.
- **S8-U9** Wire `/profile/expand` (built in Step 5) into the profile navigation, now that traits and the staleness header exist to react to it.

### Technical Tasks — Server/Backend

- **S8-B1** Whatever the trait payload still lacks for the display — `confidence` and `status` must be part of the payload, not derived client-side (`ux_architecture.md` §3).

### Technical Tasks — Gate

- **S8-G1** **Fidelity transfer check** (`ai_interaction.md` §3, gate 2). Persona voice was hand-validated once on 2026-08-31, but on a model that is not necessarily the one routed for `date_simulation`. Route calibration through the **actual** `date_simulation` model, chat with your own persona, and count the lines you'd never say. Record the result in `PICKUP.md` as evidence, not as an impression. Until this is recorded, no date the simulation produces should be trusted.

### Acceptance Criteria

1. An inferred trait is visually distinguishable from a confirmed one at a glance, on both light and dark themes.
2. Confirm and dispute each complete in one tap; a forced server error rolls the card back to its prior state.
3. Disputing a trait deep-links to the generated follow-up question, which is answerable and re-extracts on submit.
4. The staleness header flips to "Profile changed" after an answer edit, and back to "up to date" after a rebuild — both settings of the flag observed (`§8`).
5. The calibration chat produces persona replies through the real snapshot and the real pipeline — **no special "calibration mode" prompt** (named trade: what you flag is exactly what a date agent would have said).
6. A flag is visible on the bubble, counted in the footer, and demonstrably present in the next compilation.
7. **The fidelity gate is recorded closed in `PICKUP.md`**, naming the model tested, the number of messages, and the count of "I'd never say that" lines.

### Dependencies

- **Preceding:** Step 7 (snapshots, calibration endpoints), Step 6 (traits, dispute), Step 5 (expansion UI to link).
- **External:** a provisional `date_simulation` model selected well enough to test the gate against.

---

# Step 9 — Candidate matching: embeddings, hard filters, and the analysis object

**Goal.** "Find the right person" produces up to three honestly-chosen candidates — or says plainly that there is nobody — and the `analyses` row becomes the single object the UI will poll for the rest of the journey.

### Technical Tasks — Server/Backend

- **S9-B1** Alembic migration: `analyses` (with `progress JSONB` reserved for Step 11) and `analysis_candidates`, verbatim from `candidate_matching.md` §3.
- **S9-B2** Deterministic embedding-input serialisation: the `identity` vector from interest / quality / flaw / behavioural / conversational-style rows, and the `preference` vector from `partner_preference` rows — both category-ordered `label: description` lines. Deterministic means the same trait set always produces byte-identical input.
- **S9-B3** Re-embed on staleness: compare `profile_embeddings.traits_hash` to the live hash and re-embed **both** vectors via `AIProvider.embed` before matching. Never compare a stale vector (`§11`).
- **S9-B4** The hard-filter pre-pass in pure SQL, all five conditions from §2: `opt_in = TRUE` and not the requester; mutual gender fit in both directions; mutual age fit in both directions (age computed from `birth_date`); a **`ready` persona snapshot**; a fresh-enough embedding. Distance is **not** filtered — columns exist, decision deferred.
- **S9-B5** The two-vector mutual score, verbatim: `fit(R→C) = cosine(R.preference, C.identity)`, `fit(C→R) = cosine(C.preference, R.identity)`, `compatibility = mean`. Exact brute-force cosine over the filtered set — **no ANN index** at this pool size (named trade #2).
- **S9-B6** Reasons **computed in code, never generated**: `shared_interests` as the case-folded token intersection of `interest` trait labels; `reason_summary` assembled from the sub-scores. A fabricated "you both love hiking" is the canonical failure this forbids (`§10`, trade #3).
- **S9-B7** Honest pool handling: 3+ → top 3, `pool_status='full'`; 1–2 → those, `'partial'`; 0 → status `no_candidates`, `pool_status='empty'`, message "There is no one to match you with yet." Never padded with ineligible users.
- **S9-B8** `analysis_candidates.snapshot_id` freezes the candidate's persona **at match time** (trade #4).
- **S9-B9** `POST /analyses` (background job, returns immediately with status `matching`), `GET /analyses/{id}` (the single polling target), `GET /analyses` (history, newest first).
- **S9-B10** One active analysis per user → `409`, which the protocol treats as **state, not failure** (`communication_protocol.md` §5; `§17` give-up).
- **S9-B11** Logging (`§7`), non-negotiable: pool size after **each** filter step (opt-in → mutual-gender → mutual-age → snapshot-ready), the three scores per selected candidate, and on `no_candidates` **which filter emptied the pool**. That last line is the debugging tool for "why am I getting no matches" — `§5` says fix the blindness before the bug, and this is the blindness.

### Technical Tasks — Probe

- **S9-P1** `probes/probe_matching_filters.py` — users positioned on each side of every hard filter (gender mismatch, one-directional interest, age out of range, opt-in off, no snapshot); verify each exclusion **and** the logged per-step pool counts; verify the `partial` and `no_candidates` states (`§2`).
- **S9-P2** Enable the deferred assertion in `probe_answer_edit.py`: a snapshot pinned in a past analysis does **not** change when the user edits an answer (`§14` — the answer-edit staleness cascade is a named accretion risk). Clear the owed measurement from `PICKUP.md` (`§4`).

### Technical Tasks — UX/Frontend

- None — Step 10 consumes this.

### Acceptance Criteria

1. `probe_matching_filters.py` prints a green verdict covering all five exclusions, `partial`, and `no_candidates`.
2. The per-step pool counts appear in the logs for **every** run, including successful ones.
3. A `no_candidates` run logs which filter emptied the pool, and the answer is checkable by hand against the database.
4. Toggling `opt_in` off removes a user from someone else's candidate pool on the next run, and back on restores them — the flag's behaviour observed both ways (`§8`).
5. A user with no `ready` snapshot never appears as a candidate, in any run (`§11` gate observed).
6. `shared_interests` on a real match is verifiable by hand against both users' interest trait labels — every entry actually present in both.
7. A second `POST /analyses` while one is running returns `409` with the state-not-error envelope.
8. `compatibility` recomputed by hand from the two stored fits equals the stored value.

### Dependencies

- **Preceding:** Step 7 (the snapshot gate), Step 6 (`traits_hash`), Step 2 (`embed`), Step 3 (`profile_embeddings`).
- **External:** enough seeded/real profiles to populate a pool. Demo profiles arrive properly in Step 15 — until then, hand-registered test users carry this step, and that shortcut is noted in `PICKUP.md`.

---

# Step 10 — UX: dashboard and the matches reveal

**Goal.** The app's one big button works, history is the spine of the home screen, and the reveal shows exactly what matching computed — nothing generated, nothing padded.

### Technical Tasks — UX/Frontend

- **S10-U1** The **one** `Poller` primitive (`ux_architecture.md` §1.4): polls `GET /analyses/{id}` at 3s, backs off to 10s after 2 minutes, stops on terminal states, and **survives screen navigation** so leaving and returning never spawns a second loop (`§16` — a second polling implementation is a defect, not a convenience).
- **S10-U2** `/` hero — "Find the Right Person": `POST /analyses` → navigate to `/analyses/:id`.
- **S10-U3** Hero states: *ready*; *already running* → the hero **morphs into a live progress card** subscribed to the shared Poller (the server's 409 pre-empted client-side and presented as "your analysis is running", never as a rejection); *not eligible yet* → names the actual blocker and links to it ("Finish your 5 questions first").
- **S10-U4** Latest result card when the newest analysis is `complete`: top match name + score + "continue where you left off".
- **S10-U5** Analysis history from `GET /analyses`, newest first, with status chips (`matched / simulating / complete / no_candidates / failed`), top candidate + score when complete, and an empty state for new users.
- **S10-U6** `no_candidates` as a calm, honest card — "No one in the pool fits your filters yet" — not an error, not a retry spinner.
- **S10-U7** `/analyses/:id` **one route, phase-switched by status** (named trade: the analysis is one server object with one lifecycle; splitting it invents client state the server does not have). Phase 1 `matching`: "Checking who fits…".
- **S10-U8** Phase 2 `matched` — the reveal: candidate cards with a light stagger, name, age, **Demo chip when `is_demo`**, compatibility as a percentage, `shared_interests` chips and the one-line `reason_summary`. Nothing on the card is generated copy.
- **S10-U9** The `Demo` chip as a shared component used **everywhere a user is rendered** — `is_demo` must never be dropped by a widget (`ux_architecture.md` §1.6; `communication_protocol.md` §6: always present when a user is rendered).
- **S10-U10** `pool_status='partial'` → the same reveal with 1–2 cards plus a plain banner: "Only N people fit your filters right now — simulating with them." `no_candidates` → honest empty screen, **no simulate button**.
- **S10-U11** Candidate Breakdown: cards expand to the candidate's **trait labels by category** — descriptions stay private to them (`communication_protocol.md` §6).
- **S10-U12** "Start Simulated Dates" → `POST /analyses/{id}/simulate` (wired live in Step 11). Explicit button, **not auto-chained** — the reveal is a decision point (named trade).
- **S10-U13** Deep links land correctly in any phase, including after the app was killed.

### Technical Tasks — Server/Backend

- **S10-B1** Confirm the candidate payload carries `is_demo` and trait **labels only** — verified against the raw response body, since this is a wire privacy rule, not a UI convention.

### Acceptance Criteria

1. Trigger an analysis, close the app, reopen it: the dashboard hero shows the in-flight card and the deep link into `/analyses/:id` lands in the right phase (`§1`, second run).
2. Navigating dashboard → analysis → dashboard produces exactly **one** polling loop, proven by the request log.
3. A `partial` pool renders the banner and the reduced card set; `no_candidates` renders the calm card with no simulate button.
4. A demo profile shows the Demo chip on every surface that renders it — reveal card, breakdown, history.
5. The raw JSON for a candidate contains no `description` fields and no raw answers — checked on the wire, not in the widget.
6. Every screen in this step has all four states (loading / content / empty / error-with-retry) and each has been seen.

### Dependencies

- **Preceding:** Step 9 (analyses + candidates), Step 4 (auth + router).

---

# Step 11 — Date simulation: scenarios, the turn loop, events, checkpoints, resume

**Goal.** Two personas hold a real conversation, every message is checkpointed before the turn advances, environmental events interrupt them, and killing the server mid-date does not lose the date. This is the module `§15` was written about: the wire is free-tier model APIs, and the design is shaped by that fact.

### Technical Tasks — Gate

- **S11-G1** **Quota fit check** (`ai_interaction.md` §3, gate 1) — before running the first full pipeline. Calls-per-analysis (~190 at 2 dates/candidate) against the chosen providers' **per-minute and per-day** caps, as a spreadsheet, and the paid-balance decision made from it. Record in `PICKUP.md`. The spreadsheet opens the gate; the end-to-end run in Step 12 closes it.

### Technical Tasks — Server/Backend

- **S11-B1** Alembic migration: `dates`, `date_messages`, and `analyses.progress JSONB`, verbatim from `date_simulation.md` §3.
- **S11-B2** Scenario generation — one structured AI call per candidate: input `shared_interests` + both users' interest traits; output **2 distinct settings**, each `{setting_name, description, sensory_details, possible_events[4-6]}`.
- **S11-B3** The **empty-intersection fallback**: when `shared_interests` is empty, the prompt receives both interest lists and must produce one setting anchored in each person's interests (one "hers", one "his"). This was flagged open in `candidate_matching.md` and closed in `date_simulation.md` §2 — do not leave it to chance.
- **S11-B4** The turn loop per date, in the locked order:
  1. Compose context: the agent's **frozen snapshot's** system prompt + scenario description + date-role preamble + the full transcript so far (30 messages fits any context window — **no summarisation inside a date**).
  2. One structured call → `agent_response.v1` through the Guard.
  3. **Persist the message row (checkpoint) *before* advancing the turn** (`§19` — this ordering is a mechanism, never to be "simplified").
  4. Event injection **before each turn**: roll p = 0.15, **max 3 events per date, never two in a row**; on a hit insert an `environment` row from the scenario's `possible_events`, visible to both agents.
  5. Natural ending: when both agents' latest `wants_to_end` are true, run **one final closing exchange** and stop; otherwise stop at the cap.
- **S11-B5** Caps, exactly: **2 dates per candidate, max 6 per analysis, 30 messages per date** — and the 30-message cap **counts environment rows as messages** (`§18`, the scope is written down).
- **S11-B6** Per-turn give-up ladder (`§17`): 3 attempts with backoff → the date is marked `incomplete` at its last checkpointed message → the pipeline moves to the next date. **The analysis never dies because one date did.**
- **S11-B7** In-process asyncio tasks, **no Celery/Redis** (named trade); sequential dates; a **global semaphore of 2** concurrent pipelines across all users.
- **S11-B8** Resume semantics, idempotent by construction: on pipeline (re)start, `pending` → run from scratch; `running` → continue from `max(seq)` (the transcript **is** the state); `complete`/`incomplete` without an evaluation → judge it (Step 12).
- **S11-B9** Reconciliation step 3 (`data_hygiene.md` §2): on boot, re-launch any analysis stuck in `matching`/`simulating`.
- **S11-B10** `progress` JSONB updated after every stage with **real stage names** ("Simulating date 2 of 6 — at the car meet…").
- **S11-B11** Endpoints: `POST /analyses/{id}/simulate` (409 unless the analysis is `matched`), `GET /analyses/{id}/dates`, `GET /dates/{id}/transcript` — the transcript endpoint is the **one place** both agents' per-turn state metadata is deliberately exposed (decision log #4; `communication_protocol.md` §6).
- **S11-B12** Logging (`§7`): every turn's date_id/seq/provider/model/attempt/outcome; **every event-injection roll and the chosen event**; how each date ended (`mutual_wants_to_end` vs `cap`); every `analyses.status` transition with its reason. The test: from logs alone, reconstruct why any date ended or failed as it did — without a debugger.

### Technical Tasks — Probe

- **S11-P1** `probes/probe_simulation_resume.py` — start an analysis, **kill the server mid-date**, restart, verify continuation from the checkpoint (not a restart of the date) and a final complete analysis (`§2`).

### Technical Tasks — UX/Frontend

- None — Step 13 consumes this. The Step 10 "Start Simulated Dates" button becomes live here.

### Acceptance Criteria

1. A full simulation runs on the stack against real models and produces up to 6 dates with real transcripts.
2. `probe_simulation_resume.py`: the server is killed mid-date, restarts, and the date **continues from its last checkpointed message**. Watched, not inferred (`§1` — this is the product, not a corner case).
3. Event injection is observed: the roll appears in the logs, an `environment` row exists, the agents' next turns react to it, and the **max-3 and no-consecutive** rules are both observed holding (`§8`, `§14`).
4. A date ends by mutual `wants_to_end` at least once, and by cap at least once — both endings logged with which mechanism fired.
5. A forced 3-attempt failure marks that date `incomplete` at its last good message and the pipeline continues to the next date (`§17` observed).
6. The empty-intersection fallback is exercised with a candidate sharing zero interest labels, producing two settings anchored one in each person's interests.
7. The global semaphore of 2 is observed limiting concurrency with three analyses queued.
8. The quota-fit spreadsheet exists in `PICKUP.md` with real numbers.

### Dependencies

- **Preceding:** Step 9 (matched analyses with frozen snapshots), Step 7 (`agent_response.v1`), Step 2 (Guard + resilience).
- **External:** the `scenario_generation` and `date_simulation` model slots filled with real models; the fidelity gate from Step 8 recorded.

---

# Step 12 — The judge pipeline and match scores

**Goal.** Completed transcripts become explainable numbers: four criteria from a strictly-instructed judge, the final score **computed in code**, and every score carrying the model and rubric version that produced it.

### Technical Tasks — Server/Backend

- **S12-B1** Alembic migration: `date_evaluations` and `candidate_scores`, verbatim from `date_simulation.md` §3.
- **S12-B2** `judge_rubric.v1` as versioned rubric text in the schema registry.
- **S12-B3** One structured judge call per completed date, at **low temperature**, receiving the transcript **plus both users' trait labels only** — not the full trait text (named trade #5: the judge scores what happened on the date, not what the profiles predicted).
- **S12-B4** Judge output: `trait_alignment`, `conversational_flow`, `mutual_engagement`, `clash_severity` (0–100 each), plus `clicked_subjects[]`, `clashes[{user_trait, candidate_trait, moment}]`, `per_peer_summary`, `verdict_summary`.
- **S12-B5** **The number is computed in code, never asked from the model:**
  `date_score = 0.30·trait_alignment + 0.30·conversational_flow + 0.25·mutual_engagement + 0.15·(100 − clash_severity)`.
- **S12-B6** `candidate_score = mean(date_scores)`, with **incomplete-but-judged dates weighted 0.5**.
- **S12-B7** The incomplete-date policy, exact (`§14` names it as an accretion risk): an `incomplete` date with **≥10 messages** is judged and flagged `is_partial`; **under 10 messages** it is excluded from scoring and shown as failed.
- **S12-B8** The judge must be able to **decline**: an empty `clashes` array is a valid verdict, and a clash is reported only with a citable moment (`§10` — "be specific" without a way to refuse is an instruction to fabricate).
- **S12-B9** Store `judge_provider`, `judge_model`, `rubric_version` on every evaluation.
- **S12-B10** Drive `analyses.status` to `complete` (or `failed`), with the transition and its reason logged.
- **S12-B11** `DateDigest.digest(analysis_id, candidate_user_id)` — a compact factual summary from the evaluations, **no new AI call**. Chat consumes this and never reads raw `date_messages`.

### Technical Tasks — Probe

- **S12-P1** `probes/probe_judge.py` — the same transcript judged twice, scores within tolerance; and `date_score` **recomputed by hand** from the stored criteria matching the stored value (`§2`).

### Technical Tasks — Gate

- **S12-G1** **Close the quota-fit gate**: one full end-to-end analysis (matching → 6 dates → judging → complete) completed against the real providers without exhausting a daily cap. Record the actual call count against the spreadsheet estimate in `PICKUP.md`.

### Acceptance Criteria

1. `probe_judge.py` prints green on both assertions — rerun tolerance and hand-recomputed score.
2. A completed analysis has `candidate_scores` for every candidate, arithmetically checkable by hand from the `date_evaluations`.
3. An incomplete date with 12 messages is judged, flagged `is_partial`, and weighted 0.5 in its candidate's score — checked by hand.
4. An incomplete date with 6 messages is **excluded** from scoring and surfaces as failed. Both sides of the ≥10 boundary observed (`§18`).
5. At least one judged date returns an **empty** `clashes` array and this is accepted as a valid verdict, not retried into producing something (`§10`).
6. Every stored evaluation carries its judge model and `judge_rubric.v1`.
7. **One full analysis end-to-end has been witnessed on the running stack** — the quota gate closed with real numbers.

### Dependencies

- **Preceding:** Step 11 (completed transcripts), Step 2 (Guard).
- **External:** the `judging` model slot filled.

---

# Step 13 — UX: simulation progress, transcript viewer, results dashboard

**Goal.** The tens-of-minutes wait becomes the most engaging part of the product, and the results explain themselves — every score one tap from the checks that produced it.

### Technical Tasks — UX/Frontend

- **S13-U1** `/analyses/:id` phase 3 `simulating`: multi-stage progress fed by the server's `progress` JSONB through the shared Poller — **real stage names, never a fake percentage bar**.
- **S13-U2** A checklist grid of the (up to) 6 dates: pending / running / complete / **incomplete-with-reason**.
- **S13-U3** **Completed dates unlock immediately** — transcripts are readable while later dates still run (named trade: the data is already checkpointed, so this is free, and it turns a dead wait into the product's best moment).
- **S13-U4** The prominent affordance: "You can leave — this keeps running." On `complete`, a local notification (mobile/desktop) and an in-app banner linking to results. Note: this is a **local** notification — there is no push channel from the server (`communication_protocol.md` §1).
- **S13-U5** `failed` analysis → an error state **naming the stage that died**, with a retry that calls `/simulate` again and copy that says what is true: "picks up where it stopped."
- **S13-U6** `/dates/:id` transcript viewer: user's agent right-aligned, candidate's left, **environment events as centered context blocks** ("🌩 A sudden downpour sends everyone under the awning").
- **S13-U7** The **metadata toggle** — a global app-bar switch, default **on**, adding a badge row per bubble (emotional state, state of mind, connection %, satisfaction %). Off = clean read, on = the spectacle. The toggle state persists per user (`§8`: both settings must be observed).
- **S13-U8** Natural-ending footer stating how the date ended: "They both felt it was a natural place to stop" vs "Time was up" — the server logs it, the UI says it.
- **S13-U9** `?seq=` deep-link anchoring in the transcript.
- **S13-U10** `/analyses/:id/results`: candidates ordered by `final_score`; **tapping a score reveals its composition** — the four rubric criteria and their weights, verbatim from `judge_rubric.v1` (named trade: it exposes that the weights are opinions, and that is the point).
- **S13-U11** Per candidate, per date: setting name, date score, `is_partial` badge with "scored from a partial date — weighted half", clicked-subjects chips, and **clashes as plain sentences naming both traits**: "Your *impatience* rubbed against their *need to think things through* when the food was late."
- **S13-U12** Satisfaction curves with `fl_chart`: both peers' `satisfaction` and `connection` over message sequence, **event markers on the timeline**, scrub-to-message, and tap-through to the transcript anchored at that `seq`.
- **S13-U13** Failed/excluded dates listed with their reason — absent data labeled absent, never smoothed over.
- **S13-U14** During `simulating`, the transcript viewer is reachable for completed dates with a "dates still running" banner instead of the analytics header — same widgets, partial data, honestly framed.
- **S13-U15** Results fetch once on `complete` (terminal state — no polling); transcripts fetch lazily per date and cache in memory for the session.

### Technical Tasks — Server/Backend

- **S13-B1** Confirm `GET /dates/{id}/transcript` is readable for a completed date **while the analysis is still `simulating`** — the endpoint contract the whole early-access design rests on.

### Acceptance Criteria

1. Start a simulation, leave the app entirely, return: progress reflects real server state and no work was lost.
2. Date 1's transcript is opened and read while dates 2–6 are still running.
3. The metadata toggle is flipped both ways, the badges appear and disappear, and the setting survives an app restart (`§8`, `§1`).
4. An `incomplete` date is labeled as incomplete in **both** the viewer and the analytics, with its reason.
5. A score tapped shows the four criteria and weights; the arithmetic shown matches the stored `date_score`.
6. Scrubbing a satisfaction curve to message 14 and tapping through lands on message 14 of the transcript.
7. An event marker on the curve corresponds to an actual `environment` row at that sequence.
8. A `failed` analysis names the stage that died and its retry visibly **resumes** rather than restarting.

### Dependencies

- **Preceding:** Step 12 (evaluations + scores), Step 11 (transcripts + progress), Step 10 (the Poller and the phase-switched route).

---

# Step 14 — Chat: selection and the live conversation

**Goal.** The user picks their one person, and talks to an AI persona that knows the simulated dates happened and never pretends they were lived.

### Technical Tasks — Server/Backend

- **S14-B1** Alembic migration: `chat_sessions` and `chat_messages`, verbatim from `chat.md` §3, including `UNIQUE (analysis_id)` — one selection per analysis.
- **S14-B2** `POST /analyses/{id}/select {candidate_user_id}` — valid only on a `complete` analysis, for one of its candidates, once. Creates the session, **pins the candidate's matched snapshot** (the same one the dates ran against — the user chats with the person whose transcripts they read), and compiles the date digest once via `DateDigest` (no AI call).
- **S14-B3** `409` when the analysis is not `complete` or already selected — state, not failure.
- **S14-B4** `POST /chat/sessions/{id}/messages` — plain async request–response: persist the user message, one AI call through the Guard with `agent_response.v1`, persist and return the persona reply. No background job, no polling. **No streaming this phase** (named trade).
- **S14-B5** **Metadata stored, stripped from the response by contract** (`communication_protocol.md` §6, `chat.md`): internal state is written to `chat_messages.state` and never appears in any chat payload.
- **S14-B6** The system prompt extension, both parts: (1) the date digest; (2) the standing instruction that these were **simulations the human was not present for** — refer to them as "our simulated date", never as a lived shared memory, and never invent details beyond the digest. This is the anti-gaslighting rule from `user_perspective.md` and it is verbatim contract, not tone guidance.
- **S14-B7** Compaction (`§17` — chats are unbounded where dates are capped): a rolling **last-40-verbatim window plus a running summary**; on overflow, one structured call folds the **oldest 20** into the summary, stored with `compacted_upto_seq`. Runs inline before the reply call when needed.
- **S14-B8** `GET /chat/sessions`, `GET /chat/sessions/{id}/messages?after_seq=` (paged, no `state` field), `POST /chat/sessions/{id}/end`.
- **S14-B9** Session lifecycle: multiple sessions may exist over time; a new analysis + selection makes a new session. "One selection per analysis" does **not** mean one chat ever (`§18` — the boundary is written down).
- **S14-B10** A Structured-Output give-up returns an explicit "couldn't reply, try again" error — **never a silently degraded plain-text fallback** — and logs the raw output.
- **S14-B11** Logging (`§7`): session/seq/provider/model/attempt/outcome per reply; the folded range and summary length per compaction.

### Technical Tasks — UX/Frontend

- **S14-U1** Selection control on the results dashboard footer: "Choose [name]" with a confirm sheet stating the deal in two lines — "You'll chat with an AI version of [name] that remembers your simulated dates. [Name] won't be notified — real conversations aren't part of this phase." (named trade: one extra tap on the climactic action, because this is where the not-notified honesty must land).
- **S14-U2** After selecting, the other candidates' buttons become "already chose [name]" — **visible, not hidden**, so the constraint is legible.
- **S14-U3** `/chat` session list: active first then ended, each row with match name, Demo chip where applicable, last message preview, and a link back to the originating analysis.
- **S14-U4** `/chat/:sessionId` using the **shared chat widget from Step 8**, configured with flagging **off** and metadata **off** — the server sends no metadata here (`§13`: the two chats share the widget by decision but their rules differ).
- **S14-U5** Header: match name plus a persistent, quiet "AI persona" tag — immersive, never deceptive (named trade). Tapping the header opens a sheet with their trait labels, the date digest, and a link to the original transcripts.
- **S14-U6** Reply latency styled as a typing indicator that starts when the request fires and resolves into the bubble. Send failure → the message stays in the composer marked unsent with a retry — **user text is never dropped**. The server's give-up error renders as exactly that, in-thread.
- **S14-U7** Send is strictly sequential per session (composer disabled while a reply is pending); the user bubble renders immediately, the persona side never optimistically.
- **S14-U8** History pages backward via `?after_seq=` on scroll-up.
- **S14-U9** Navigation controls in the overflow menu: End chat (confirm; the row moves to ended and history stays readable), Improve my profile (→ `/profile/expand`), Start a new analysis (→ dashboard hero — allowed while a chat stays active, because chatting and re-analysing are independent).

### Acceptance Criteria

1. Selection creates exactly one session; a second selection on the same analysis returns `409` rendered as state.
2. The persona's first replies reference the simulated dates **as simulations** — verified by reading real replies, not by reading the prompt.
3. The raw chat response body contains **no** `state` field — checked on the wire (`communication_protocol.md` §6).
4. A conversation driven past 60 messages triggers compaction; the folded range is logged, the summary is stored, and replies stay coherent across the fold (`§1` — the second run consuming the state).
5. A forced structured-output give-up produces the explicit in-thread "couldn't reply, try again", the user's text survives in the composer, and the retry works.
6. Ending a session moves it to ended and leaves the history readable.
7. Starting a new analysis while a chat is active is permitted and produces a separate session on selection.
8. The chat widget shows no metadata badges and no flag affordance, while calibration still shows both — the shared widget's two configurations observed side by side (`§13`).

### Dependencies

- **Preceding:** Step 12 (`complete` analyses + `DateDigest`), Step 8 (the shared chat widget), Step 13 (the results footer where selection lives).

---

# Step 15 — Data hygiene: deletion, demo seeding, reconciliation, dead-data scan

**Goal.** Close the cross-cutting obligations: an account deletes completely and its cross-user holes are honestly labeled; demo profiles exist through the **real** pipeline; the reconciliation pass is whole; and dead data is scriptably visible.

### Technical Tasks — Server/Backend

- **S15-B1** `DELETE /me` — one transaction, `DELETE FROM users WHERE id = …`, relying on the cascade graph. **Verify the graph, do not assume it** (`§13`): answers, dispute questions, traits, trait events, both embeddings, persona snapshots, calibration sessions and messages, analyses and candidates, dates and messages and evaluations and scores, chat sessions and messages. Baseline and pool questions are global rows and **must survive**.
- **S15-B2** `§19` ordering: log the **per-table row counts before** the cascade runs — the deletion trace without retaining the data. Return those counts to the client as the receipt.
- **S15-B3** The two cross-user effects, implemented and surfaced rather than hidden: dates/chats where the deleted user was the candidate disappear from other users' analyses and chat lists; `analysis_candidates` cascade so an old analysis may show 2 of 3, with the row surviving and the gap honestly labeled.
- **S15-B4** `seeds/demo_profiles.yaml` — demo users as form fields + five baseline answers each, `is_demo = TRUE`, keyed by a stable seed key.
- **S15-B5** Demo seeding through the **real code path** — registration + answer upsert + extraction + compilation + embedding. **No shortcut inserts** (`§12`). Demo profiles get real traits, real snapshots, real embeddings, real provenance.
- **S15-B6** The full four-step reconciliation pass in its locked order: (1) BQ1–BQ5 and PQ01–PQ30; (2) demo profiles, including re-running extraction/compilation/embedding for any demo user missing them; (3) re-launch analyses stuck in `matching`/`simulating`; (4) **embedding-model consistency check** — every `profile_embeddings.embedding_model` must equal the pinned config value; mismatches logged loudly and queued for re-embedding, never silently compared.
- **S15-B7** `scripts/scan_dead_data.py` (`§22`): report users with zero answers older than 30 days, `failed` snapshots and analyses, orphaned `running` dates. **Report only** — deleting real users' data is always a human decision.
- **S15-B8** A dead-**code** pass per repo alongside it (`§22`).

### Technical Tasks — UX/Frontend

- **S15-U1** `/settings` → Delete account: a **two-step confirm** that states what deletion does, including the cross-user effect in plain words ("your simulated dates disappear from your friends' results too"), then shows the server's returned counts as the final receipt.
- **S15-U2** Tombstone rendering wherever a counterpart was deleted — "this person removed their account" — on dangling analyses (dashboard, results) and chat sessions. **The list explains rather than 404s** (`ux_architecture.md` §3).
- **S15-U3** Verify the Demo chip renders on demo profiles everywhere they now appear, with real seeded data behind them.

### Technical Tasks — Probes

- **S15-P1** `probes/probe_deletion.py` — a user entangled everywhere (a candidate in someone's analysis, in an active chat) deletes; verify the cascade counts, the **survivor's tombstones**, and that global questions survived (`§2`, `§14`).
- **S15-P2** `probes/probe_demo_seeding.py` — wipe a demo user's traits, reboot, and verify reconciliation rebuilt them **through the real pipeline** (provenance present, not shortcut rows) (`§2`).

### Acceptance Criteria

1. `probe_deletion.py` and `probe_demo_seeding.py` both print green verdicts on the running stack.
2. Deletion counts are logged **before** the cascade and returned to the client; the numbers match a hand count taken beforehand.
3. After a candidate deletes, the survivor's analysis renders a tombstone and their chat list explains the absence — no crash, no 404 screen.
4. Global baseline and pool questions survive every deletion.
5. A demo user's traits carry real `source_answer_ids` and `extracted_by`, and their snapshot is `ready` — indistinguishable in pipeline terms from a real user's, and labeled in every payload.
6. Boot with a deliberately mismatched `embedding_model` row: the mismatch is logged loudly and queued for re-embedding, never silently compared (`§8`).
7. Reconciliation on a healthy database is a **no-op with a log line saying so** — the second-run witness for all four steps (`§1`).
8. `scan_dead_data.py` runs and reports without deleting anything.

### Dependencies

- **Preceding:** every table exists — Steps 3, 7, 9, 11, 12, 14. Deletion cannot be verified whole until the whole graph exists, which is why it lives here rather than in Step 4.

---

# Step 16 — Witness sweep, gates closed, and the honest report

**Goal.** Turn a system that is *built* into a system that is *witnessed* (`§1`). Nothing new is designed in this step; everything claimed is either proven or written down as owed.

### Technical Tasks — Both repositories

- **S16-B1** Run the **complete probe set** in one session against a cold stack and record each verdict in `PICKUP.md`: `probe_onboarding`, `probe_pool_expansion`, `probe_answer_edit`, `probe_matching_filters`, `probe_simulation_resume`, `probe_structured_guard`, `probe_judge`, `probe_deletion`, `probe_demo_seeding`. **Read the green probes — do not skim a pass** (`§3`).
- **S16-B2** The `§8` flag sweep — every flag and gate observed behaving differently in **both** settings, each with its log line: `opt_in` (in vs out of the pool), `is_demo` (labeled in every payload), the persona-snapshot gate (no snapshot → not a candidate), the one-active-analysis `409`, the event-injection cap and the no-consecutive rule, **every** give-up condition in `§17`, `pool_exhausted`, and the transcript-viewer metadata toggle.
- **S16-B3** The `§17` give-up sweep — each observed firing at least once: 3 validation-repair attempts → typed error; 3 attempts per simulation turn → `incomplete`; one queued follow-up extraction, never a pile-up; one active analysis per user.
- **S16-B4** The `§14` greppability audit — walk each module plan's "Locked by this document" list to the code that implements it. The four named accretion risks get explicit attention: the answer-edit staleness cascade (edit → traits → hash → embeddings → snapshot banner), the incomplete-date judging policy (≥10 messages, 0.5 weight), the no-consecutive-events rule, and the survivor-side tombstones after a deletion.
- **S16-B5** The `§7` log reconstruction test: pick three arbitrary dates from real runs and, **from logs alone and without a debugger**, reconstruct why each ended, scored, or failed as it did. Where you cannot, `§5` applies — fix the seeing before anything else.
- **S16-B6** `/docs` drift check (`communication_protocol.md` §7): every endpoint in every module plan exists in the generated OpenAPI page with the documented shape. **Any drift between a module plan and `/docs` is a defect** — file it in `DEFECTS.md`.
- **S16-B7** Wire privacy audit against raw response bodies, not widgets: persona system prompts never cross; another user's raw answers and full trait **descriptions** never cross (labels only); chat internal-state metadata never crosses; `is_demo` **always** crosses; non-candidates appear in no payload. The one deliberate exposure — full transcripts with both agents' state metadata — happens at the transcript endpoint and **nowhere else**.
- **S16-B8** English-only audit: prompts, UI copy, questions, routing, and model outputs (owner decision, 2026-09-01).
- **S16-B9** `§4` — drive the **Owed measurements** list in `PICKUP.md` to zero, or state plainly what remains owed and why.
- **S16-B10** Confirm both gates recorded closed with real evidence: quota fit (Step 11/12) and fidelity transfer (Step 8).
- **S16-B11** Run `scan_dead_data.py` and the dead-code pass; report only.
- **S16-B12** Final `PICKUP.md` update: state, what was finished, what is next, what is blocked and on whom, the traps that will bite someone resuming cold, which probes currently pass — written for someone with no memory of the last session (`§24`).
- **S16-B13** The `§6` reckoning: produce the status report where every claim matches which of the ten Definition-of-Done points is actually true. Anything built-but-not-witnessed is reported in exactly those words.

### Acceptance Criteria

1. All nine probes pass in one session against a cold stack, and their verdicts have been read, not skimmed.
2. Every `§8` flag and every `§17` give-up has a recorded observation of it behaving both ways / firing once.
3. The log reconstruction test succeeds on three real dates without a debugger.
4. Zero drift between the module plans and `/docs`; anything found is in `DEFECTS.md` with mechanism, discovery method, and lesson.
5. The wire privacy audit passes against raw bodies for all five rules.
6. Both gates are recorded closed with numbers, not impressions.
7. The Owed list is empty, or every remaining item is named with its reason.
8. `PICKUP.md` is accurate enough that a cold reader could take over.
9. The final report to the owner says "works" only where the evidence supports it, and "built, not yet witnessed" everywhere else (`§6`).

### Dependencies

- **Preceding:** Steps 1–15, all of them.

---

## Appendix A — Build order at a glance

| # | Step | Repo focus | Unblocks |
|---|---|---|---|
| 1 | Foundations: stack, wire, artifacts | DevOps + both | everything |
| 2 | AI Interaction Module | Server | 6, 7, 11, 12, 14 |
| 3 | Core schema + reconciliation | Server | 4, 5, 6 |
| 4 | Accounts: register, login, `/me` | Both | 5, 9 |
| 5 | Questions & answers | Both | 6 |
| 6 | Trait extraction | Server | 7, 9 |
| 7 | Persona & snapshots | Server + UX shell | 8, 9, 11, 14 |
| 8 | UX profile & calibration; **fidelity gate** | UX | 11, 14 |
| 9 | Candidate matching | Server | 10, 11 |
| 10 | UX dashboard & reveal | UX | 13 |
| 11 | Date simulation; **quota gate opens** | Server | 12, 13 |
| 12 | Judge & scores; **quota gate closes** | Server | 13, 14 |
| 13 | UX progress, transcript, results | UX | 14 |
| 14 | Chat: selection & conversation | Both | 15 |
| 15 | Data hygiene | Both | 16 |
| 16 | Witness sweep & honest report | Both | ship |

**Parallelisable pairs** (only if two people are working): Steps 2 and 3 are independent. Step 8 (UX) can overlap Step 9 (server). Step 10 (UX) can overlap Step 11 (server).

## Appendix B — What this plan deliberately does not build (this phase)

Carried forward verbatim from the locked decisions, so nobody re-adds them by reflex: direct human-to-human chat; notifying the matched person; payments, quotas, and cost controls; content moderation; data export; email verification and password reset; distance/geo filtering (columns exist, filter deferred); a global browsable user feed (cut at spec level); WebSockets, SSE, or server push; token streaming in chat; an ANN vector index; Celery/Redis or any task queue; a containerised Flutter build; a `/v1/` API prefix; OpenAPI client codegen; localisation of any kind.

Each of these has a named trade in `project_description.md`'s decision log or in its owning module plan. **Decided things stay decided** (`§23`) — reopening one requires new information and a dated, inline revision where the old decision stood.
