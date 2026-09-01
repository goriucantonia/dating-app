# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** **Step 7 (persona compilation, snapshots, `agent_response.v1`) is built and witnessed** — `probe_onboarding.py` GREEN over 16 checks, immutable per-user versioned snapshots, the system prompt never leaving the server, calibration chat working, and flags feeding the next compilation as negative examples. D-008 found and closed: one OpenRouter model id is several upstream providers and one of them broke `trait_extraction` outright. **Next: Step 8, UX profile + the fidelity gate.**

---

## Read this first (30 seconds)

**Steps 1–5 are done and witnessed** (owed: O-4 native desktop run, O-1 opt_in behavioural difference — closes Step 9). Both API keys are in `.env` (git-ignored). The owner's standing directive (2026-09-01): the priority is API calls that **connect, route correctly, and return simple valid responses** — complex architecture, advanced prompting, and model-tier upgrades are decided later, not now.

**Step 5, witnessed today:** `probe_pool_expansion.py` GREEN over real HTTP (two probe users: one for the under-minimum rejection / mid-batch abandon-and-resume / baseline-excluded-from-pool-progress / edit-bumps-updated_at; one straight run proving exactly 6 batches of 5 in `pool_order` with batch 7 the EXACT `pool_exhausted` payload). In the browser: the onboarding guard forced `/onboarding/questions` on a fresh signed-in user; the interstitial shows the locked copy; BQ1 answered with the live counter flipping at the minimum; **the AC1 kill-and-reopen landed on "3 of 5" with BQ1–BQ2 preserved**; finishing baseline lifted the guard to home; `/profile/expand` showed pool progress, served PQ01 through the SAME widget, rendered the exhausted achievement card verbatim, and opened the prefilled single-answer editor.

**Standing model facts — REVISED 2026-09-01 (owner decision):** **`gemini-3.6-flash` is used for NOTHING.** Every chat/structured task (`trait_extraction`, `persona_digest`, `judging`, `dispute_followups`) routes to **`openrouter/dots-studio/dots-3-note-preview:free`**, provisionally — the final tier choice still belongs to the gates. **Embeddings are untouched and remain `google/gemini-embedding-001` at 768 dims**: a different model on a different quota, pinned separately because every stored vector must come from one model, and OpenRouter serves no embedding equivalent. Four `free-model-of-choice` slots remain deliberately unfilled.

**How that model was chosen — do not re-guess it, re-measure it.** Of the 18 free OpenRouter models only **four** advertise `structured_outputs`, and Step 2's smoke-test model `nvidia/nemotron-3.5-lightning` is **not one of them** — pointed at `trait_extraction.v1` it took **211 seconds and returned non-JSON**. All four candidates were run against the real schema and real prompt:

| Model | Result |
|---|---|
| `dots-studio/dots-3-note-preview:free` | **PASS**, 28s, short well-shaped labels — **chosen for `persona_digest`, `judging`, `dispute_followups`, `chat_reply`** |
| `nvidia/nemotron-3-super-120b-a12b:free` | **now carries `trait_extraction`** after D-008 broke the model above for that one task |
| `z-ai/glm-5.2:free` | FAIL — 429 saturated (as in Step 2) |
| `liquid/lfm-2.5-2.6b:free` | 2.6B, too small to trust with this |

**The lesson worth keeping: a Step 2 smoke test proves a model answers; it does not prove the model can satisfy THIS schema. Re-measure per task, not per provider.**

**Since then (2026-09-01), two changes on top of Step 5:**

- **The whole stack was run locally from a cold start and D-006 was found** — the Flutter web app could not reach the API at all. Read traps 3a–3c before running it; they are the difference between a working stack and a black screen.
- **The answer minimum was lowered from 200 to 50 characters** (owner decision, 2026-09-01). Migration `0003`. The floor lives in FOUR code sites plus the probe — trap 9 lists them. Witnessed: 49 rejected, 50 accepted, 51 accepted over real HTTP; the UI counter reads `/ 50`; probe re-run GREEN. The voice nudge still asks for "4–5 sentences" **on purpose** — guidance above the floor, not a contradiction.

**To run it locally:** `docker compose up -d` (api + db), then from the `ux` submodule: `C:\src\flutter\bin\flutter.bat run -d web-server --web-port 5000 --web-hostname 127.0.0.1`, then open `http://127.0.0.1:5000`. First compile ~60-90s, blank page until it finishes.

**Next: Step 8 — UX profile screen and the FIDELITY TRANSFER GATE.** Steps 1–7 are all done and witnessed.

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
│   │   ├── models.py · reconcile.py · traits_hash.py            (Step 3)
│   │   ├── ai\      base.py · google.py · openrouter.py · registry.py
│   │   │            routing.py · structured.py · resilience.py   (all 8 of §1's files exist)
│   │   └── schemas\ __init__.py (registry) · agent_response.py (loud stub, Step 7)
│   ├── config\ai.yaml              (google slots: gemini-2.5-flash PROVISIONAL;
│   │                                openrouter slots: unfilled by design)
│   ├── migrations\  versions\0001_pgvector_extension.py · 0002_module1_core_tables.py
│   ├── seeds\       questions.yaml (GENERATED verbatim — regen with the checker's --write)
│   ├── scripts\     check_question_seeds.py · run_reconcile.py
│   ├── probes\      probe_structured_guard.py (S2-P1) · probe_ai_smoke.py (AC helper)
│   ├── tests\       test_structured_guard.py · test_traits_hash.py (11 tests, green)
│   └── the seven server module plans
└── ux\                             ← submodule
    ├── Flutter 3.47.2 app (lib\app, lib\core\api, lib\features\debug) + widget test
    └── the seven UX module plans
```

## Current state — honest

| Area | State | Evidence |
|---|---|---|
| Step 1 stack | **Witnessed** (2026-09-01): cold up → DB-connected 200; second down/up; topology; envelope; failure path | Prior session, git history |
| Step 2 `app/ai/` layer | **Witnessed** (2026-09-01, with real keys): both providers generate; native structured returns a valid dict; embedding 768-dim; guard probe GREEN; config-only model swap observed; 429 → backoff → typed error observed | Probe verdicts + `ai_call`/`ai_call_retry` log lines this session |
| Step 3 schema | **Witnessed** — migration `0002`: users, traits, questions, answers, trait_events, profile_embeddings (two-vector form), all CHECKs proven by rejected inserts, vector(768) dimension enforced | This session's psql output |
| Step 3 reconciliation | **Witnessed** — boot 1: 35 seeded (codes logged); boot 2: no-op; deleted PQ17 restored by name on boot 3; management script `scripts/run_reconcile.py` runs the same pass | api logs |
| Step 4 accounts | **Witnessed** — register/login/JWT/`/me`/PATCH with every A1 rule server-side (curl) and the whole flow through the Flutter UI in the browser; session restore across app restarts; dead sessions land on `/login` | This session's curl output + browser screenshots |
| Seed fidelity | **Witnessed** — `scripts/check_question_seeds.py` GREEN: plan ↔ `seeds/questions.yaml` ↔ DB identical, 35 questions | script verdict |
| Step 6 extraction | **Witnessed, all 7 ACs** — provenance; all-`keep` second run with byte-identical hash; confirmed trait survives an edit; dispute makes exactly one linked question; 4 traits retracted and still present when an answer's subject was replaced; live one-`done`-one-`queued`; thin answers declined | probe + curl + psql this session |
| Step 7 persona | **Witnessed, all 7 ACs** — ready v1 with verbatim excerpts; v1/v2/v3 immutable; §11 gate; forced failure leaves the previous current; no prompt on the wire; flags reach the next compilation | probe + curl + psql this session |
| Unit tests | **15 pass** in-container (8 guard/router + 3 traits_hash + 4 extraction give-up) | pytest output |
| Lint / build | **one pre-existing ruff error**: `RUF100` unused `# noqa: E402` in `migrations/env.py` — untouched by recent work, not yet fixed; image rebuilt green after D-004 editable-install fix | in-container runs |
| Remotes | All three repos pushed to GitHub (superproject `dating-app`, `dating-app-server`, `dating-app-ux`) | push output 2026-09-01 |

## What was just finished (Step 5, all tickets)

- **Server (S5-B1…B6):** `app/routers/questions.py` — `GET /questions` (baseline + pool + own dispute questions, answered state + answer text; drives resume AND the edit view), `GET /questions/next-batch` (5 unanswered pool by `pool_order`; the answer set IS the cursor; `pool_exhausted` as a normal 200 payload), `PUT /answers/{question_id}` (ONE upsert path; 50-char minimum enforced via pydantic for baseline/pool/dispute alike; edit logging with old/new length + traits sourced from the edited answer — empty until Step 6 but logged from day one). Dispute questions excluded from `answered_pool` by the join on `origin='pool'`.
- **Fix along the way:** models switched from generic `sqlalchemy.ARRAY` to the postgresql dialect ARRAY — `.contains()` (the edit-log trait lookup) only exists on the dialect type. Found by the probe's 500.
- **UX (S5-U1…U8):** `features/questions/` — freezed models, repository, `questionsProvider` (rebuilds on login/logout), and **AnswerFlow**: THE one-question-per-page widget (progress label, 8–16-line field, counter muted→confirmed at 200, A2 voice nudge, autosave on advance + 2s idle debounce once valid, every failure visibly surfaced per D-005). Onboarding screen (interstitial with the locked copy → flow → guard lifts via provider invalidation); `/profile/expand` (pool progress, batch CTA, exhausted achievement card, answers list with "Editing changes your future matches, not past results." and the prefilled single-answer editor — all the SAME AnswerFlow). Router guard 2 added to the one redirect: `baselineIncomplete == null` means "not known yet — never bounce on a guess".
- **Probe:** `probes/probe_pool_expansion.py` GREEN (S5-P1).
- **Noted for Step 10:** the flutter dev web server drops deep-link paths (`/profile/expand` typed into the address bar lands on `/`); deep links are a Step 10 AC and will need the path-URL strategy checked then.

## What was finished earlier today (Step 4, all tickets)

- **Server (S4-B1…B5):** `app/routers/auth.py` (register with the exact A1 form — every rule a pydantic validator so violations arrive as field-level 422s; login; both return `{token, user}`; one message for unknown email and wrong password), `app/routers/me.py` (GET/PATCH `/me`, cross-field age-range check against stored values, `opt_in_changed` log line per §8), `app/security.py` (bcrypt; HS256 JWT, 7-day lifetime — named alongside the no-refresh-tokens trade; the one bearer dependency), `app/users.py` (gender values, `compute_age` — age computed, never stored — and the `UserOut` payload in one place). `email-validator` added to deps (it rejects special-use TLDs like `.local` — use real-shaped domains in tests). `DELETE /me` deliberately absent until Step 15 (S4-B6).
- **UX (S4-U1…U7):** freezed `User` model + `AuthRepository`; resilient `TokenStore` over flutter_secure_storage; the ONE dio interceptor (bearer on request, 401 → `sessionExpired`) in `api_client.dart`; `AuthController` (`AsyncNotifier<User?>`, restores session in `build()`); go_router guard in one place (`routerProvider`); `/login`; `/register` as the three-step Stepper (date picker hard-capped at 18+, opt-in switch default off with its one-line description); placeholder home rendering live `/me`; the Step 1 debug health screen deleted.
- **D-005 found and closed** (see `DEFECTS.md`): submit handlers caught only `ApiException`, so a storage-level failure after a server-side success showed the user *nothing*. Now every submit ends in a visible outcome, and `TokenStore` degrades to in-memory instead of throwing into UI code.
- **O-1 formally incurred:** `opt_in` was witnessed *writing* (UI default-off round-trip; PATCH flip visible in psql) but not yet *changing behaviour* — that needs someone else's candidate pool (Step 9 AC4).

## What was finished earlier today (Step 3, all tickets)

- **S3-B1/B2:** migration `0002` — the A3 DDL verbatim, with `traits` created before `questions` (the document's forward reference is a spec, not an execution order) and one `op.execute` per statement (asyncpg cannot prepare multi-command SQL). `profile_embeddings` is the revised two-vector form only.
- **S3-B3:** `app/models.py` — six async models mirroring the DDL one-to-one, Text + CHECK (named trade), pgvector `Vector(768)`. Alembic `env.py` now targets `Base.metadata`.
- **S3-B4:** `seeds/questions.yaml` **generated verbatim** from the module plan by `scripts/check_question_seeds.py --write` (no hand transcription — that is how a curly apostrophe silently becomes straight). Checker mode is the AC6 witness. Baseline probe_area mapping recorded in the script: BQ1=interests, BQ2=partner_criteria, BQ3/BQ4=situational, BQ5=self_image (routine call, §25 — BQ4's primary framing is situational; the pool carries six dedicated conversational questions).
- **S3-B5/B6:** `app/reconcile.py` — step 1 of the four-step pass (insert missing / repair drifted fields with a per-field log / count correct), wired into lifespan and invocable via `scripts/run_reconcile.py`.
- **S3-B7:** `app/traits_hash.py` — deterministic SHA-256 over the non-retracted trait rows (id, category, label, description, status, confidence), sorted by id. All-`keep` leaves it untouched; a retraction changes it. Unit-tested.
- **D-004 found and closed:** the image's baked site-packages copy of `app` shadowed the bind-mounted live code for `python scripts/…` entry points. Dockerfile now uninstalls the copy and does `pip install --no-deps -e .` — one authoritative code location. Both a script and a probe re-witnessed importing live code.

## What was just finished (Step 6, all backend tickets)

**Server (S6-B1…B10):** `app/extraction.py` — holistic reconciliation over the FULL answer set against existing rows, per-row `keep`/`update`/`retract` verdicts plus `add`, through the Guard. `app/schemas/trait_extraction.py` + `dispute_followup.py` (both registered). `app/routers/traits.py` — `POST /profile/extract`, `GET /traits`, `POST /traits/{id}/dispute`, `POST /traits/{id}/confirm`, `GET /profile/extract/status`.

**Two design choices worth not re-deciding:**
- **The model never sees a UUID.** Trait rows are presented as handles `T1…Tn` and answers by question code (`BQ1`, `PQ07`, `D3`); the server maps back. A model asked to copy a 36-char UUID eventually copies it wrong, and a mistyped id is indistinguishable from a verdict about a *different* trait. Identity is still id-based, never wording-based (A5.1) — the handle is a stand-in for the row id, not derived from the label.
- **Declines are stated, not inferred from silence** (S6-B9). `declined_answer_ids` is explicit, so "judged thin" is distinguishable from "the model forgot it" — which is what makes §10's counting possible.

**Probe:** `probes/probe_answer_edit.py` GREEN (S6-P1/P2). **Unit tests:** `tests/test_extraction_concurrency.py` — 4 deterministic tests of the give-up (15 tests total, green).

**D-007 found and closed:** the first prompt grew the profile by one re-sliced trait per run on *unchanged* answers. The S6-P2 drift alarm caught it on its first run — note that `bob` had already produced a clean all-`keep` second run, so one passing example proved nothing. See DEFECTS.

**Owner decision, 2026-09-01:** the `dispute_followups` slot is **filled** — `openrouter/nvidia/nemotron-3.5-lightning:free` (the model that answered cleanly in Step 2). It is the one AI-generated question type left in the system and AC4 could not be witnessed without it. The remaining four `free-model-of-choice` slots stay deliberately unfilled.

### Step 6 acceptance criteria — honest status

| AC | Status |
|---|---|
| 1 traits with provenance across categories | **Witnessed** — 6 traits over 5 categories, every row with non-empty `source_answer_ids` + `extracted_by` |
| 2 no-change re-run is all-`keep`, no events, hash untouched | **Witnessed** — `kept=6 … added=0`, `changed=false`, hash byte-identical, `trait_events` 6→6 |
| 3 confirmed trait survives an unrelated edit | **Witnessed** — probe GREEN, status and provenance intact |
| 4 dispute → exactly one linked `origin='dispute'` question | **Witnessed** — one row, `trait_id` linked, `user_id` set, trait `disputed`, event written |
| 5 a retracted trait is PRESENT with `status='retracted'` | **Witnessed** — BQ1's whole subject replaced (bees → chess); 4 traits retracted, all 4 still present as rows, none deleted |
| 6 two rapid requests → one run + one queued follow-up | **Witnessed** — live: `[(200,'done'), (200,'queued')]`, exactly one `extraction_queued` and one `extraction_follow_up_start`. Also covered by 4 deterministic unit tests |
| 7 thin answer → logged decline, not an invented trait | **Witnessed** — `bob`'s 30 filler pool answers all declined, zero traits invented from them |

**All seven acceptance criteria are witnessed.** O-5 and O-6 were incurred and closed within the same session and are deleted per the queue rule.

**Honest note on extraction QUALITY, for the fidelity gate (Step 8):** the mechanics are green but the new model is a visible step down from what google produced on the same answers. Gemini gave **6 traits across 5 categories** with short labels (`restores old cars`). `dots-3-note-preview` gave **17 traits across only 2 categories** with snake_case labels (`accepts_being_seen_as_predictable`) — it over-splits and under-categorises. Nothing downstream is broken by this, but a persona built from 17 lopsided traits will read worse than one built from 6 balanced ones. **This is exactly what the fidelity-transfer gate exists to catch — carry it into Step 8 rather than treating the green probe as the whole story.**

## What was just finished (Step 7, all backend tickets + UX)

**Server (S7-B1…B11):** migration `0004` (`persona_snapshots`, `calibration_sessions`, `calibration_messages` verbatim from §4). `app/schemas/agent_response.py` — the Step 1 loud stub replaced by the FROZEN `agent_response.v1` including `wants_to_end`. `app/persona.py` — the two-part compiler and `PersonaService`. `app/routers/persona.py` — `POST /persona/compile` (start-then-poll), `GET /persona/current`, and the three calibration endpoints. **Probe:** `probes/probe_onboarding.py` GREEN over 16 checks.

**UX (S7-U1…U3):** `features/persona/` — models, repository, and `BuildingScreen` at `/onboarding/building`: the post-BQ5 chain (extract → compile → poll) with the stage label naming the REAL stage from job status, never a fake timer. Failure is visible and retryable and the copy says the answers are safe. The router guard lets `/onboarding/building` through while the questions provider still reports "incomplete", or it would bounce the user back into a questionnaire they just finished.

**Things worth not re-deciding:**
- **The system prompt has no field anywhere on the way out.** `SnapshotOut` lists its fields explicitly rather than dumping the row, so no future edit can widen it into leaking the user's raw answers. The probe asserts this against the raw response body.
- **The 3–5 voice excerpts are picked by SPREAD first, then length.** Taking the five longest answers outright returns five answers about the same probe area, and the voice sample then only shows how they write about one subject. Deterministic — a snapshot that re-rolls its quotations per compile is not reproducible.
- **Auto-compile after extraction is gated on `outcome.changed`**, which reads the SAME `traits_hash` as the staleness rule — so the trigger and the staleness banner can never disagree about whether a rebuild is owed, and an all-`keep` run does not burn an AI call to rebuild an identical persona.

### Step 7 acceptance criteria — all witnessed

| AC | Status |
|---|---|
| 1 ready v1 whose prompt contains verbatim excerpts | **Witnessed** — probe asserts the user's own words, and specifically the EDITED BQ1 rather than the superseded draft |
| 2 `probe_onboarding.py` green end-to-end | **Witnessed** — GREEN, 16/16 |
| 3 edit → re-extract → recompile gives v2; v1 unchanged and readable | **Witnessed** — bob carries v1, v2, v3 all `ready` with their prompts intact |
| 4 no ready snapshot → `None`; the §11 gate | **Witnessed** — a fresh user is `simulatable: false` and calibration refuses with `no_persona_yet` (409) |
| 5 forced digest failure → `failed` + error, PREVIOUS stays current | **Witnessed** — digest pointed at a nonexistent model: v4 `failed` with its error, v1–v3 untouched, `simulatable` still true |
| 6 `GET /persona/current` never contains the prompt | **Witnessed** — checked against the raw response body, 0 matches |
| 7 a flag is stored against the right snapshot and appears in the next compilation | **Witnessed** — v1/v2 have no negatives; v3, compiled after the flag, carries both the "THINGS YOU WOULD NEVER SAY" section and the user's correction verbatim |

## What is next

**Step 8 — UX profile screen + the FIDELITY TRANSFER GATE** (S8-*): the trait display with dispute/confirm controls, the persona header showing snapshot state and "profile changed — persona will rebuild", and the gate itself. **Carry the extraction-quality concern into it** — it is the thing this gate exists to catch, and it is now the oldest un-actioned observation in this document.

Test accounts on the current volume (password `hunter2222`): `ana@dating-test.dev` (no answers), `bob@dating-test.dev` (all 35 answered — BQ1–BQ5 written in a real voice, pool answers are filler text: fine for pipeline tests, poor for judging extraction quality), `carol@dating-test.dev` (no answers), plus disposable probe users.

Useful facts for later steps, learned witnessing Step 2:
- `gemini-3.6-flash` is a **thinking model** — a tight `max_tokens` gets eaten by reasoning and yields `MAX_TOKENS` with no text. Give generous budgets.
- Free OpenRouter models 429 by congestion, per model. `nvidia/nemotron-3.5-lightning:free` worked; `z-ai/glm-5.2:free` was saturated (and its content includes visible reasoning text). The `free-model-of-choice` slots remain unfilled — these are probe arguments, not choices.
- The google embedding free tier has a low per-minute cap — batch embed calls, don't loop them.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Native desktop witness (O-4) | **Owner:** enable Windows Developer Mode, then `flutter run -d windows` in `ux\` | Unchanged from last session |
| OpenRouter `free-model-of-choice` slots | **Owner decision, deferred by design** — EXCEPT `dispute_followups`, filled 2026-09-01 with `nvidia/nemotron-3.5-lightning:free` so Step 6 AC4 could be witnessed. Four slots remain unfilled | Probe takes a model as an argument precisely so the slots stay unfilled |
| Paid-balance question | **Owner**, from the quota-fit numbers | Unchanged |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Unchanged (decision log #11) |

## Traps that will bite you resuming cold

1. **Three git repositories.** Submodule commit(s) first, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.
2. **`docker compose down`/`up` is NOT a cold start** — the `db_data` volume survives. True cold = `down -v`.
3. **Flutter is not on PATH**: use `C:\src\flutter\bin\flutter.bat` (SDK installed 2026-09-01). Android SDK absent; targets are web and (after Developer Mode) Windows desktop.
3a. **Serve the web app on `127.0.0.1`, never `localhost`** (D-006). `flutter run -d web-server --web-port 5000 --web-hostname 127.0.0.1`. Given the *name* `localhost`, Flutter binds IPv6-only on Windows and dwds' debug websocket dies — the page then hangs on a black screen at "DDC is about to load 740/740 scripts" with no error shown. CORS admits both spellings now, so `127.0.0.1` is simply the one that works.
3b. **A Dart edit needs the dev server restarted** — a browser reload alone serves the stale bundle (this is how a `_minChars` change appeared not to apply). First compile is ~60–90s and the page is blank until it finishes; that blankness is normal, not a failure.
3c. **Probes cannot see browser-only failures** (D-006). Every probe runs inside the api container, where there is no Origin header and no preflight. CORS, mixed content, cookies, websocket upgrades: the probe suite is GREEN straight through all of them. Reaching the API *from the browser* is its own witness step.
4. **`.env` holds the DB password the volume was initialized with** — regenerate both together or neither.
5. **The `questions` table has a forward reference** (`module_1_data_collection.md` A3): create `traits` before `questions`, or add the FK after both exist.
6. **`profile_embeddings`: build the two-vector form** (`kind IN ('identity','preference')`, PK `(user_id, kind)`) — the revised copy, restated in `candidate_matching.md` §3.
7. **Editing `.env` does not reach a running container** — compose reads it at container start; `docker compose up -d` / restart after key changes.
8. **`ai_routes_unresolved` + two `provider_built … api_key_present: false` warnings at boot are correct behaviour**, not bugs — they disappear only when the owner supplies keys and fills slots.
9. **The answer minimum is 50 characters** (owner decision 2026-09-01, lowered from 200) and **applies to dispute answers too** (§18); **dispute questions are outside pool progress** (§13). It lives in FOUR places that must move together — the DB CHECK (`answers_answer_text_check`, now migration `0003`), `app/models.py`, the pydantic `Field(min_length=...)` in `app/routers/questions.py`, and `_minChars` in `ux/lib/features/questions/answer_flow.dart` — plus the probe's boundary case. **The voice nudge still says "4–5 sentences" on purpose:** guidance above the floor, not a contradiction.
10. **Calibration chat and match chat share a widget but differ** in flagging/metadata rules (§13).
11. **Load-bearing orderings** (§19): checkpoint before advancing; counts before cascade; validate before repair; `traits_hash` only after the trait write commits.
12. **An all-`keep` extraction run leaves everything fresh** (A5.1); **the 30-message cap counts environment rows** (§18).
12a. **The google free tier behaves as a DAILY cap** (found in Step 6): `gemini-3.6-flash` returns `limit: 20` and did not clear across a 75-second wait. It blocked two witnesses outright and is the direct reason chat moved to OpenRouter. Still live knowledge because **embeddings remain on google** — Step 9 will re-embed users and will meet this cap. Carry it into the quota-fit gate.
12b. **Free OpenRouter models are slow and wildly variable** — `dots-3-note-preview` runs ~20-40s per extraction but the whole class queues under congestion, and `z-ai/glm-5.2:free` is reliably 429. Budget minutes, not seconds, for anything that chains several calls. **`--web-port`-style quick loops do not apply here: a probe with four extractions takes several minutes.**
12c. **An OpenRouter model id is NOT one thing** (D-008). It is served by several upstream providers, chosen per request, with different implementations. `dots-3-note-preview` served `trait_extraction` for a whole step and then began 400ing every such request via one upstream while serving other tasks fine on the same key. Consequences already in the code: a `"Provider returned error"` 400 is TRANSIENT and retries (a retry is a fresh routing draw), and **`trait_extraction` is deliberately pinned to a DIFFERENT model from everything else** — per-task routing is what stops one broken provider forcing a global change. **"Model X works" is not a durable fact.** Re-measure; don't reason.
12d. **Debug provider faults by isolation, not by theory.** Three plausible explanations (schema too big, max_tokens, prompt size) were each falsified in about a minute by a script varying one factor at a time. Reasoning about them would have taken longer and settled nothing.
13. **Ruff's `EXE002` is suppressed on purpose** — through the Windows bind mount every file looks executable; do not "fix" it by chmod.
14. **Decided things stay decided** (§23).

## Owed measurements (§4)

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-1 | `opt_in` observed changing pool membership — Step 4 witnessed the toggle writing to the database, not the difference it makes | Step 4, **2026-09-01** | Step 9 AC4 | **Owed** |
| O-2 | Pinned-snapshot assertion in `probe_answer_edit.py` | Step 6 | Step 9 (S9-P2) | **Anticipated** |
| O-3 | Matching vs properly seeded demo profiles | Step 9 | Step 15 | **Anticipated** |
| O-4 | Native (Windows) run rendering `/health` | Step 1, 2026-09-01 | Owner: Developer Mode + `flutter run -d windows` | **Owed** |

*(Step 6's O-5 and O-6 were incurred and closed the same day — AC5 witnessed by replacing an answer's whole subject, AC6 witnessed live after the move off google — and are deleted per the queue rule. Earlier: O-5 — the Step 2 live-call ACs — was closed 2026-09-01 and deleted per the queue rule: keys arrived, both probes ran GREEN, the config-only model swap and the 429→backoff→typed-error path were both observed in the logs.)*

## Probe status (§2)

| Probe | Status |
|---|---|
| `probe_structured_guard.py` | **GREEN** (2026-09-01, google/gemini-3.6-flash) |
| `probe_pool_expansion.py` | **GREEN** (2026-09-01) |
| `probe_ai_smoke.py` (helper, not in the §2 minimum set) | **GREEN** (2026-09-01; openrouter model passed as argument) |
| `probe_answer_edit.py` | **GREEN** (2026-09-01, S6-P1/P2 — real AI calls) |
| `probe_onboarding.py` | **GREEN** (2026-09-01, S7-P1 — 16 checks, real AI calls) |
| All others (`matching_filters`, `simulation_resume`, `judge`, `deletion`, `demo_seeding`) | Not written — delivered in Steps 9–15 |

## Module build order

1 ~~Foundations~~ **(done; O-4)** · 2 ~~AI Interaction~~ **(done)** · 3 ~~Schema + reconciliation~~ **(done)** · 4 ~~Accounts~~ **(done; O-1)** · 5 ~~Questions & answers~~ **(done)** · 6 ~~Trait extraction~~ **(done)** · 7 ~~Persona & snapshots~~ **(done)** · 8 UX profile + **fidelity gate** ← **next** · 9 Matching · 10 UX dashboard · 11 Simulation + **quota gate opens** · 12 Judge + **quota gate closes** · 13 UX results · 14 Chat · 15 Data hygiene · 16 Witness sweep.

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **Open** |
| Quota fit | Step 11 → 12 | **Open** |

## Where the decisions live

- **What:** `user_perspective.md` → `project_description.md` → module plans. **How:** `development_principles.md`.
- **Wire:** `communication_protocol.md`. **Order:** `IMPLEMENTATION_PLAN.md`. **What went wrong:** `DEFECTS.md` (D-001…D-005).
