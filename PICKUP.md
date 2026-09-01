# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** **Steps 11 and 12 are built, both gates are CLOSED, and the caps were then revised by the owner: ONE date per candidate, not two.** Candidates A, B and C now get one evening each — 3 dates per analysis, not 6. Measured on a real run afterwards: **30 model calls per candidate** (1 scenario + 28 turns + 1 judge), so a full pool is **~90 calls and ~11 minutes**, down from ~177 and ~21. The empty-intersection fallback had to be rewritten — its old rule needed two settings — and `date_scenarios` is now **v2**. Step 9's O-8 is still owed; O-13 and O-14 are deliberately deferred. Defects this session: D-010, D-011, D-012.

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

**Next: Step 12 (the judge), which closes the quota-fit gate.** Steps 1–8 and 10 are done and witnessed; **Step 9 is code-complete with its witness OWED (O-8)**; **Step 11 is built with its central claim (resume from checkpoint) witnessed live**, and four of its eight acceptance criteria still owed (O-10…O-13). The fidelity gate is closed with its measurement recorded below; the quota-fit gate is OPEN with its spreadsheet now filled in from measurement.

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
| Step 8 UX + gate | **Witnessed** — profile cards with guess-vs-confirmed styling, one-tap confirm, calibration chat with flagging, settings; **fidelity gate CLOSED with a recorded measurement** | browser (release build) this session |
| Step 9 matching | **Code complete, witness OWED (O-8)** — do not mark done | see O-8 |
| Step 10 UX dashboard | **Witnessed** — hero, history, reveal with partial banner, Demo chip on 3 surfaces, ONE polling loop proven by the network log, deep links landing cold | browser (release build) this session |
| Step 11 simulation | **Built; the central claim WITNESSED.** A real analysis ran two 30-message dates end to end; a SIGKILLed API came back, reconciliation relaunched it, and the date logged `resumed_from_checkpoint … seq 3` and carried on. 4 of 8 ACs owed — see the table below | api logs + psql + transcript this session |
| Step 12 judging | **Witnessed, all 7 ACs** — score recomputed by hand on four analyses, both sides of the 10-message boundary, empty `clashes` accepted, provenance on every row, `probe_judge.py` GREEN 9/9, and the quota gate closed on a full run | probe + psql + api logs this session |
| Unit tests | **78 pass**
| Lint / build | **GREEN, no outstanding errors.** The long-standing `RUF100` in `migrations/env.py` was removed 2026-09-01 — the suppression named `E402`, which this project does not enable, so the suppression was itself the only lint error in the repo. The reason it documented is kept as a plain comment | in-container `ruff check .` |
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

## What was just finished (Step 8, all tickets + the gate)

**UX (S8-U1…U9):** `features/traits/` — `/profile` with cards grouped by the six categories, `/profile/calibration`; `features/chat/chat_widget.dart` — THE shared chat widget built once; `features/settings/` — `/settings`.

**S8-B1 needed no work:** `GET /traits` has carried `confidence` and `status` since Step 6, so nothing is derived client-side.

**Things worth not re-deciding:**
- **A guess looks like a guess** (§9). `inferred` renders with a hand-painted DOTTED border and says "AI's read, not confirmed"; `confirmed` is solid; `disputed` is amber. Confidence is a 3-step strength dot and **never a percentage** — "0.62 confident you're stubborn" is absurd theater, and a number invites arguing with the decimal instead of the claim.
- **The shared chat widget's differences live in `ChatConfig`, passed in by the screen.** Calibration sets `allowFlagging: true`; match chat (Step 14) will set it false — flagging someone else's double is meaningless. Because the difference is a parameter rather than a branch inside the widget, neither chat can inherit the other's behaviour by someone editing the shared file (§13, §16).
- **Disputing deep-links to the generated question.** A dispute that only recolours a card leaves the user with no way to correct anything, which is the opposite of what they just asked for.
- **Delete account is deliberately absent from `/settings`** — it ships in Step 15 with its server counterpart.

### Step 8 acceptance criteria

| AC | Status |
|---|---|
| 1 inferred vs confirmed distinguishable at a glance | **Witnessed** in the browser — dotted + "AI's read, not confirmed" against solid + "You confirmed this" |
| 2 confirm/dispute in one tap; error rolls back | **Confirm witnessed** in the browser (dotted → solid in one tap). The rollback path is written but was not forced — see owed O-5 |
| 3 dispute deep-links to its follow-up question | **Partly** — the server pairing was witnessed in Step 6 (exactly one linked question); the UI deep-link is built and not yet clicked through — O-5 |
| 4 staleness header flips both ways | **Partly** — the `failed` state was witnessed live (the AC5 forced failure rendered "The last rebuild didn't finish. Your previous version is still in use."); the stale→fresh flip is not yet observed — O-6 |
| 5 calibration uses the real snapshot and pipeline, no "calibration mode" prompt | **Witnessed** — replies come from the snapshot's own system prompt through the ordinary Guard path; there is no second prompt anywhere in the code |
| 6 flag visible on the bubble, counted in the footer, present in the next compilation | **Witnessed** — long-press → dialog → bubble outlined in the error colour, footer 1 → 2; the "present in the next compilation" half was witnessed in Step 7 (v3 carried it verbatim) |
| 7 fidelity gate recorded with model, message count, and flag count | **Witnessed** — recorded in the gate register above, with its limitation stated |

**Note on the web witness:** the flutter DEV server's dwds debug socket failed repeatedly this session even on `127.0.0.1` (the D-006 workaround). The witness was taken against a **release build served statically** (`flutter build web` + `python -m http.server`), which has no debug socket at all. That is now the reliable way to witness UI — see trap 3d.

## What was just finished (Step 9 — code complete, end-to-end witness OWED)

**Server (S9-B1…B11):** migration `0005` (`analyses` with `progress` JSONB reserved for Step 11, `analysis_candidates`); `app/matching.py` — deterministic embedding serialisation, staleness re-embed, the five-condition hard filter in pure SQL, the two-vector mutual score, code-computed reasons, honest pool handling, and the per-step funnel log; `app/routers/analyses.py` — `POST /analyses` (202, background), `GET /analyses/{id}`, `GET /analyses`, and the 409 that is **state, not failure**.

**Probes:** `probes/probe_matching_filters.py` written (S9-P1). **S9-P2 done** — the pinned-snapshot assertion is ENABLED in `probe_answer_edit.py`, closing O-2.

**Unit tests: 29 pass** (14 new in `tests/test_matching_math.py`), pinning the deterministic guarantees — byte-stable serialisation, retracted rows never embedded, `shared_interests` finding a real overlap, ignoring filler words, and never treating a *preference* mentioning bicycles as a shared interest.

**Things worth not re-deciding:**
- **The funnel counts are a SEPARATE query from the row query.** Folded together they vanish exactly when the pool is empty — which is the one time they are the whole point (AC3).
- **`shared_interests` intersects LABELS**, so a corrupted label silently disables matching without failing anything. That is not hypothetical — see D-009.
- **Reasons are computed in code and there is no AI call anywhere in `matching.py`.** That is the point of the module (trade #3).

### Step 9 status — honest

| AC | Status |
|---|---|
| 1 probe green over all five exclusions, `partial`, `no_candidates` | **NOT witnessed on clean data — OWED (O-8)** |
| 2 per-step pool counts logged on every run | Code in place; observed in logs on the polluted run |
| 3 `no_candidates` names the emptying filter | Code in place; not yet observed on clean data |
| 4 `opt_in` both directions (closes O-1) | **Observed both ways** on the polluted run — but that run also matched a stale candidate, so it is re-owed under O-8 |
| 5 no-snapshot user never a candidate | Observed on the polluted run |
| 6 `shared_interests` verifiable by hand | **Unit-tested**; end-to-end owed |
| 7 second POST → 409 state | Observed on the polluted run |
| 8 `compatibility` = mean of the two fits | **Unit-tested**; also recomputed exactly on the polluted run |

**Why nothing above is claimed as done:** the one GREEN run this session was polluted — concurrent probe runs shared an output file and stale probe users stayed in the pool, so the requester matched a PREVIOUS run's candidate and `shared_interests` was vacuous because of D-009. Every re-run since has been blocked by the OpenRouter daily cap. **The code is complete and lint/unit-test clean; the end-to-end witness needs one clean run once quota resets.**

## What was just finished (Step 10 — dashboard and the matches reveal)

**UX (S10-U1…U13):** `core/polling/poller.dart` — THE polling primitive; `features/analyses/` — models, repository, and `/analyses/:id`; `features/common/demo_chip.dart`; the dashboard rewritten with history as its spine. **Server (S10-B1):** candidates carry `is_demo` and trait **labels only**.

**Things worth not re-deciding:**
- **The Poller is a `family` provider that is NOT autoDispose.** That is the whole mechanism behind "one loop across navigation". Making it autoDispose would silently double server load and look fine.
- **`DemoChip` renders nothing when `isDemo` is false**, so no call site needs an `if`. An `if` is forgettable; this is not.
- **Breakdown labels are pills, not `Chip`s.** A `Chip` lays its label on one line and truncates, and a trait label is the ONLY thing shown about a candidate.
- **`/analyses/:id` is one route phase-switched by status**, which is also what makes deep links work in every phase.

### Step 10 acceptance criteria

| AC | Status |
|---|---|
| 1 deep link lands in the right phase | **Witnessed** — cold-loaded `/analyses/<id>` renders the reveal directly. Needed BOTH fixes below |
| 2 exactly one polling loop across navigation | **Witnessed** — the browser network log shows exactly ONE `GET /analyses/{id}` across dashboard → analysis → dashboard → analysis |
| 3 `partial` banner + reduced cards; `no_candidates` calm with no simulate button | **`partial` witnessed** on real data; the `no_candidates` screen is built and was not rendered this session — **owed (O-9)** |
| 4 Demo chip on every surface | **Witnessed** on three: latest-result card, history row, breakdown header |
| 5 raw JSON has no descriptions or answers | **Witnessed on the wire** — 0 matches for `description` / `answer_text` / `system_prompt` |
| 6 four states on every screen | Loading, content and error paths are all written; not every empty state was rendered this session — see O-9 |

**DEEP LINKS: the fix is TWO halves, and each alone makes the other look broken.**
1. **Server:** an SPA fallback to `index.html` (`ux/serve_build.py`), or `/analyses/<id>` is a 404 for a path that is not a file.
2. **Client:** `usePathUrlStrategy()` in `main.dart`, or Flutter web's default **hash** strategy means go_router only sees the empty part after `#` and starts at `/` — **with the correct URL still in the address bar**, which is what makes it so confusing.

Fixing the server half first is exactly why the symptom survived into a second attempt looking unchanged. This closes the open question PICKUP has carried since Step 5.

## What was just finished (Step 11 — date simulation, built and largely witnessed; caps REVISED)

**Server (S11-B1…B12):** migration `0006` (`dates`, `date_messages` verbatim from §3 — `analyses.progress` was already added by `0005`). `app/schemas/date_scenarios.py` — `date_scenarios.v1`. `app/simulation.py` — the whole module: scenario generation with the empty-intersection fallback, the turn loop, event injection, the give-up ladder, resume, the global semaphore, and progress. `app/routers/simulation.py` — `POST /analyses/{id}/simulate`, `GET /analyses/{id}/dates`, `GET /dates/{id}/transcript`. `app/reconcile.py` gains **step 3 of the pass**: on every boot, any analysis left in `matching` or `simulating` is relaunched.

**Config:** the `scenario_generation` slot is FILLED (`dots-studio/dots-3-note-preview:free`), because with it empty there is no scenario, no date and no transcript. Provisional, like every other pin. **Three `free-model-of-choice` slots remain unfilled** (`chat_compaction` and the two that Steps 14–15 will need).

**UX (not in the plan's task list, but named by it):** the Step 10 "Start Simulated Dates" button is **live**. `Analysis` gains `progress`, the repository gains `simulate()`, and the `simulating` phase now shows the SERVER's stage sentence rather than a placeholder. The button is also now **gated on `status == 'matched'`** — a finished analysis renders the same reveal, and a live button there could only ever earn a 409 (§11: gate the promise on the capability). `flutter analyze`: no issues.

**Witnessed in the browser** (release build + `serve_build.py`, trap 3d — probes cannot see browser-only failures): a `complete` analysis renders "These dates have already run…" and no button; a `matched` analysis renders the live button; pressing it flipped the screen to the simulating phase, which then showed the SERVER's own sentences in sequence — "Working out where you and Alice would meet…" and then **"Simulating date 1 of 4 — Bob's garage…"**, which is exactly the shape S11-B10 specifies.

**Unit tests: 63 pass** — 29 new in `tests/test_simulation_rules.py` pinning every rule the turn loop obeys, plus 5 in `tests/test_resilience_backoff.py`.

### Things worth not re-deciding

- **ONE date per candidate, revised 2026-09-01 by the owner** (was two). `DATES_PER_CANDIDATE` is now derived from the schema's `SETTINGS_PER_CANDIDATE` rather than written out separately — one generated setting IS one date, and two constants that must agree are two constants that will eventually disagree. **The cost is named:** a candidate's score used to be the mean of two independent readings, so one odd evening or one wobbly judge call got averaged down; now a single date fully determines it. Bought for roughly half the model calls.
- **The empty-intersection fallback had to be rewritten, and this is the part that is easy to miss.** Its old rule was "one setting anchored in HER interests and one in HIS" — an instruction that needs two settings and became impossible the moment a candidate got one date. It now anchors on the **CANDIDATE's** interests, so a requester working through a full pool is shown three different people's worlds rather than three versions of their own. The anchor vocabulary offered to the model is the candidate's list ONLY; leaving the requester's in would quietly re-open the choice the fallback exists to make.
- **The transcript IS the state, and every rule is a pure function of it.** Whose turn it is, how many events have fired, whether the pair have started saying goodbye, which of the two endings finished the date — all recomputed from the stored rows on every pass. There is no in-flight object a restart could lose, which is *why* resume works rather than a bonus on top of it. It is also why 29 unit tests can pin behaviour that would otherwise need a live model to observe.
- **Whose turn it is comes from the COUNT of agent messages, not from "who spoke last."** An environment row sits between two turns; if it were read as "the last speaker", the two agents would swap sides mid-date.
- **The 30-message cap counts environment rows** (§18) and there is a unit test that constructs exactly that boundary — 27 spoken plus 3 events — because this is the rule someone later "fixes" into counting only what was said.
- **There is no fourth retry loop in `simulation.py`.** The three attempts with backoff live in the resilience layer and the three validation repairs live in the Guard. A turn that still fails marks the DATE `incomplete` and the pipeline moves on. Adding a per-turn retry here would silently make it 27 attempts.
- **`anchored_in_interest` is a required field on every generated setting.** It is what makes the empty-intersection fallback *checkable* — "one setting anchored in each person's interests" is otherwise a claim nobody can verify after the fact, which is exactly the shape §9 forbids: a derived value with no provenance.
- **A candidate whose scenario generation fails is skipped, and NO date row is written for them.** A `dates` row needs a scenario, and a placeholder scenario would be a fabricated setting sitting in the database looking real.
- **The analysis is driven to `complete` here, with `progress.stage = "dates_finished"` and `judged: false`.** Step 12 inserts judging *before* that transition and takes the transition over (S12-B10). Leaving it in `simulating` would spin a progress bar over finished work; claiming it was scored would be a lie.

### Step 11 acceptance criteria — honest status

| AC | Status |
|---|---|
| 1 a full simulation produces dates with real transcripts | **Witnessed on four separate analyses** — 13 dates in total, agents visibly reacting to injected events ("Power's out, so I'll grab the flashlight"). Every pool was `partial` (one candidate). The first three ran under the old 2-dates-per-candidate cap; the fourth ran after the 2026-09-01 revision and produced exactly ONE date, judged and scored |
| 2 killed mid-date, restarts, **continues from the last checkpointed message** | **Witnessed four times, and asserted by the green probe.** `probe_simulation_resume.py` SIGKILLs the API at 3 messages and then checks that the pre-kill prefix is present byte for byte in the same order and that the date GREW from it — `3 → 30`. The other three were: the same probe's earlier run, an accidental uvicorn reload mid-date (trap 3e, resumed at seq 17), and the AC5 fault injection (resumed at seq 11). Every one named the seq it resumed from and who was due to speak |
| 3 event injection observed; max-3 and no-consecutive both observed holding | **Witnessed, and asserted by the green probe on every date it checks.** Every roll is logged with its value, the threshold, and the reason it did or did not fire; a date reached exactly 3 events and the next roll logged `reason: event_cap_reached`; the roll after each event logged `reason: no_consecutive_events`. Speaker pattern of one full date: `UCUECUCUCUCUCUCUCUCEUCUCUCUCEU` |
| 4 a date ends by mutual `wants_to_end` at least once, and by cap at least once | **Both witnessed, both logged with which mechanism fired.** `cap` on four dates (`ended_by: cap`, 30 messages). `mutual_wants_to_end` on date `b6a54d43` at **25 messages** — and the closing exchange behaved exactly as designed: `seq 22` user_agent sets the flag, `seq 23` candidate_agent sets it, then EXACTLY two more turns, one goodbye each ("Let's call it a night. I've got that Raleigh waiting for me" / "it was nice meeting you… maybe we'll cross paths again"), and stop |
| 5 a failure marks that date `incomplete` at its last good message and the pipeline continues | **Witnessed twice, once forced and once for real.** *Forced:* `date_simulation` pointed at `there-is/no-such-model:free` while date 2 sat at 11 messages — on relaunch it resumed at `seq 11`, the turn failed, and the row landed `incomplete, ended_by: turn_gave_up, failed_at_seq: 12, messages: 11, judgeable: true`; the analysis still completed (`dates_complete: 1, dates_incomplete: 1`). That fault was a permanent 400, so it failed fast rather than through the ladder. *Unforced, an hour later:* the real model emitted a degenerate whitespace loop, the **Guard spent all 3 validation attempts** (`outcome: gave_up`, raw output attached), the date went `incomplete` at `failed_at_seq: 21, messages: 20`, **and the pipeline moved straight on to date 2**. Between them, every half of this AC is observed |
| 6 empty-intersection fallback produces two settings anchored one in each person's interests | **Unit-tested, not witnessed live — owed (O-13).** Needs a candidate pair sharing zero interest labels |
| 7 the global semaphore of 2 limits three queued analyses | **Not witnessed — owed (O-14).** `simulation_slot_acquired … waited_ms` is logged on every run and read 0 both times, which is correct with one pipeline and proves nothing about the limit |
| 8 the quota-fit spreadsheet exists with real numbers | **Done** — below, from measurement rather than estimate |

### Two model findings from the live runs, worth carrying into Step 12

**The natural ending is real but RARE, and it is late.** Across six dates only one ended itself. In the two completed dates observed first, `wants_to_end` was false on all 47 turns, which looked like the model simply never setting the field — it is not. It sets it, but usually not before the 30-message cap arrives. Practical consequence for the quota table below: **assume most dates cost the full 27 turns.** Do not "fix" the rarity by lowering the cap or by inferring an ending from low satisfaction — both would fabricate an ending the agents did not reach. If shorter dates are wanted, that is a model or prompt question and it belongs with the quota-fit gate.

**`connection` and `satisfaction` are used unevenly and are often 0.** One date ranged 0–100 with a genuine peak; another never left 0–10; long stretches sit flat at 0 while the transcript reads perfectly engaged. **Step 13's per-turn curves should be designed against real stored data, not against the 0–100 range the schema promises.** The judge (Step 12) reads the transcript rather than these numbers, so scoring is not affected — but anyone plotting them will be surprised.

**One more thing the wire did on its own:** mid-date, `dots-3-note-preview` emitted a degenerate whitespace loop — a JSON object that opened `"connection":` and then produced thousands of newlines until it hit `max_tokens`. The Guard spent its three validation attempts, gave up with the raw output attached, and the date ended `incomplete` at its last good message while the pipeline moved on. This is the give-up ladder working, and it is worth knowing that this model does that.

## What was just finished (Step 12 — the judge, and the quota gate CLOSED)

**Server (S12-B1…B11):** migration `0007` (`date_evaluations`, `candidate_scores` verbatim from §3). `app/schemas/judge_rubric.py` — the schema AND the rubric text, versioned together. `app/judging.py` — the judge call, the code-side scoring, the candidate aggregation, and `DateDigest`. The simulation pipeline now judges **before** it transitions to `complete`. `GET /analyses/{id}` carries each candidate's `final_score`; `GET /analyses/{id}/dates` carries each date's full evaluation and an `excluded_from_score` flag.

**Probe:** `probes/probe_judge.py` — **GREEN, 9/9** (S12-P1). **Unit tests: 78 pass** (15 new in `tests/test_judging_math.py`).

### Things worth not re-deciding

- **The rubric TEXT lives in the schema file, versioned with the schema.** `date_evaluations.rubric_version` claims a stored score was produced under particular instructions; that claim is only worth something if the instructions and the shape they produce cannot drift apart. Changing what a criterion means is a v2.
- **There is deliberately no `overall_score` field in the schema.** The four criteria are asked for; the number is arithmetic (S12-B5). A model asked for a headline number produces one that does not follow from its own sub-scores, and then nobody can say why a date scored 71.
- **Both halves are stored — the model's raw `criteria` and the code's `date_score`.** Either alone is unauditable: only the score and the weights are invisible; only the criteria and the score is irreproducible. Storing both is what lets the probe recompute by hand, and what would let a future weights change be applied to old evaluations with no AI call at all.
- **`clash_severity` is inverted at exactly one point in the codebase**, inside `date_score`. It is the only criterion where high is bad, and doing the `(100 - x)` anywhere else as well would double-count it silently.
- **`candidate_score` returns `None`, never `0.0`, when nothing is judgeable.** `0.0` is a SCORE and it means "they were terrible together". A candidate whose every date died before it started has no score, and that difference survives to the wire as `final_score: null`.
- **`excluded_from_score` is computed server-side and shipped.** A client re-deriving the 10-message rule is a client that can disagree with the server about someone's score.
- **The judge is told when a transcript was cut short.** Without that note it scores the missing ending as a bad ending — the technical failure would be charged to the person.
- **A judge that cannot run does not throw away six finished dates.** Judging failure lands the analysis `complete` with `stage: judging_failed`, transcripts readable, and says so plainly. `failed` would hide an evening's worth of real work behind an error.
- **`DateDigest` takes no router, structurally.** It cannot make an AI call because it has nothing to make one with — which is a stronger guarantee than a comment saying it must not.

### Step 12 acceptance criteria — all seven witnessed

| AC | Status |
|---|---|
| 1 `probe_judge.py` green on both assertions | **Witnessed — 9/9.** Hand-recomputed score matched the stored value to the penny (90.00 vs 90.00), and **the same transcript re-judged scored identically: delta 0.00** at temperature 0.1 |
| 2 `candidate_scores` arithmetically checkable by hand | **Witnessed on four analyses.** e.g. (94.25 + 84.00)/2 = **89.12**; (93.00 + 92.75)/2 = **92.88**. Every input is in the `candidate_scored` log line |
| 3 an incomplete date is judged, flagged `is_partial`, weighted 0.5 | **Witnessed at 11, 19 and 20 messages.** By hand: (94.25×1 + 91.25×0.5) / 1.5 = **93.25**, exactly the stored value. A plain mean would have given 92.75 |
| 4 an incomplete date under 10 messages is EXCLUDED; both sides of the boundary observed | **Witnessed.** `date_not_judged … messages: 6, threshold: 10` beside a 19-message date judged as partial, in the same analysis, with `dates_excluded: 1` in the candidate's score line and `excluded_from_score: true` on the wire. **How the 6-message date was made, stated plainly:** its 19-message sibling was produced by a forced fault, but no natural run landed under 10 — the timing window is a few seconds wide. So a genuine transcript was **truncated to 6 rows in the database**. The messages are real model output; the length was constructed. The rule under test (`is_judgeable`) ran on the real server path either way |
| 5 an empty `clashes` array is accepted as a verdict | **Witnessed repeatedly** — most judged dates returned `clashes: 0` with `clash_severity: 0`, stored as-is, never retried into producing one |
| 6 every evaluation carries its judge model and `judge_rubric.v1` | **Witnessed** on every row and asserted by the probe |
| 7 **one full analysis end-to-end; the quota gate closed with real numbers** | **Witnessed** — see below |

## What is next

**Step 13 — the UX for results — is next**: the simulation-progress screen, the transcript viewer, and the results dashboard. Everything it needs is already on the wire and already populated with real data: `GET /analyses/{id}` carries `progress` and each candidate's `final_score`, `GET /analyses/{id}/dates` carries every evaluation plus `excluded_from_score`, and `GET /dates/{id}/transcript` carries the per-turn state. **Twelve real transcripts are in the database to build against, with nine of them judged and five candidate scores computed** — including a partial date, an excluded one, and one that ended by mutual agreement.

**Read the two model findings in the Step 11 section before designing the per-turn curves** — `connection` and `satisfaction` are used unevenly enough that a chart designed against the schema's 0-100 promise will look broken on real data.

**Three witnesses remain owed.** O-13 and O-14 are Step 11's, and the owner has deliberately deferred both (2026-09-01) — do not spend model calls clearing them out of tidiness. **O-8 (Step 9's clean `probe_matching_filters.py` run) is the one that is genuinely open**, and its probe was hardened this session for exactly that. O-9 (Step 10's `no_candidates` screen) is also still open and is nearly free: every probe account is opted out, so an analysis for a lone requester lands there by itself.

**Settled 2026-09-01 (owner decision):** the `trait_extraction` pin on `dots-3-note-preview` is intended, and the apparent conflict with D-008 is not one. **Model pins are testing config and they move with what is available and affordable** — D-008 records why nemotron was right on the day it was written, not a promise that the pin is frozen. What survives from D-008 is the mechanism: one OpenRouter id is several upstream providers, so a task that starts 400ing gets ITS line moved, not every line.

**Every test and probe account is opted OUT of the candidate pool, and that is now the standing default** (owner decision, 2026-09-01): a small pool keeps probe runs cheap, and D-009 is the story of what stale opted-in probe users do to a matching run. `bob@dating-test.dev` included. **Opt in only what a specific witness needs, and opt it back out afterwards** — `probe_simulation_resume.py` now does that for its own two users automatically.

Test accounts on the current volume (password `hunter2222`): `ana@dating-test.dev` (no answers), `bob@dating-test.dev` (all 35 answered — BQ1–BQ5 written in a real voice, pool answers are filler text: fine for pipeline tests, poor for judging extraction quality; **opt_in FALSE, by standing decision**), `carol@dating-test.dev` (no answers), plus disposable probe users.

Useful facts for later steps, learned witnessing Step 2:
- `gemini-3.6-flash` is a **thinking model** — a tight `max_tokens` gets eaten by reasoning and yields `MAX_TOKENS` with no text. Give generous budgets.
- Free OpenRouter models 429 by congestion, per model. `nvidia/nemotron-3.5-lightning:free` worked; `z-ai/glm-5.2:free` was saturated (and its content includes visible reasoning text). The `free-model-of-choice` slots remain unfilled — these are probe arguments, not choices.
- The google embedding free tier has a low per-minute cap — batch embed calls, don't loop them.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Native desktop witness (O-4) | **Owner:** enable Windows Developer Mode, then `flutter run -d windows` in `ux\` | Unchanged from last session |
| OpenRouter `free-model-of-choice` slots | **Owner decision, deferred by design** — EXCEPT `dispute_followups`, filled 2026-09-01 with `nvidia/nemotron-3.5-lightning:free` so Step 6 AC4 could be witnessed. Four slots remain unfilled | Probe takes a model as an argument precisely so the slots stay unfilled |
| Paid-balance question | **Owner**, and the numbers are now in | **Decisive, and improved by the one-date revision.** A full analysis is now ~90 openrouter calls (was ~177). On the free tier as documented (50/day) the core loop still cannot run ONCE. 10 credits raises the allowance to 1000/day ≈ **11 analyses a day**, up from 5. See the spreadsheet below |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Unchanged (decision log #11) |

## Traps that will bite you resuming cold

1. **Three git repositories.** Submodule commit(s) first, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.
2. **`docker compose down`/`up` is NOT a cold start** — the `db_data` volume survives. True cold = `down -v`.
3. **Flutter is not on PATH**: use `C:\src\flutter\bin\flutter.bat` (SDK installed 2026-09-01). Android SDK absent; targets are web and (after Developer Mode) Windows desktop.
3a. **Serve the web app on `127.0.0.1`, never `localhost`** (D-006). `flutter run -d web-server --web-port 5000 --web-hostname 127.0.0.1`. Given the *name* `localhost`, Flutter binds IPv6-only on Windows and dwds' debug websocket dies — the page then hangs on a black screen at "DDC is about to load 740/740 scripts" with no error shown. CORS admits both spellings now, so `127.0.0.1` is simply the one that works.
3b. **A Dart edit needs the dev server restarted** — a browser reload alone serves the stale bundle (this is how a `_minChars` change appeared not to apply). First compile is ~60–90s and the page is blank until it finishes; that blankness is normal, not a failure.
3c. **Probes cannot see browser-only failures** (D-006). Every probe runs inside the api container, where there is no Origin header and no preflight. CORS, mixed content, cookies, websocket upgrades: the probe suite is GREEN straight through all of them. Reaching the API *from the browser* is its own witness step.
3d. **When dwds will not co-operate, witness against a RELEASE BUILD, not the dev server.** `flutter build web` then `python -m http.server 5000 --bind 127.0.0.1` from `ux/build/web`. No debug websocket exists, so the whole dwds failure class disappears; it loads in about a second instead of ninety, and it is what the user would actually run. Cost: no hot reload, and you must rebuild after each Dart change. This is how Step 8 was witnessed after the dev server refused to boot the app repeatedly.
3e. **Do not edit files under `server/` while a probe is running.** uvicorn runs with `--reload`; a save restarts the API and kills every in-flight request the probe is waiting on. A long matching probe was lost to this. Either wait for the probe to settle, or make the edit and accept re-running it.
3h. **`pytest` and `ruff` were in the image only because someone once installed them by hand.** `pyproject.toml` declares them under the `dev` extra, and the Dockerfile ran `pip install .` — no extra. Nobody noticed for eleven steps because the tools happened to be present in a long-lived image; the first genuine rebuild (D-012) removed them and both commands in the definition of done stopped working. Fixed 2026-09-01: the Dockerfile now installs `.[dev]`. **The general shape, worth carrying: if a tool is not named in a build file, it is not installed — it is merely present.**
3g. **The running image can be OLDER than the Dockerfile, and D-004's fix only protects you if the image is current.** Found in Step 12: `docker compose exec api python probes/probe_judge.py` died on `ImportError: cannot import name 'Analysis' from 'app.models'` — because site-packages still held a stale non-editable copy of `app` from an image built before the D-004 fix. It hid for a long time because `uvicorn` and `pytest` both put the live `/app` first by accident of working directory, and only a probe run as `python probes/<file>.py` (whose `sys.path[0]` is `/app/probes`) exposes it. **`docker compose restart` does not rebuild.** If an in-container script cannot import `app.*`, run `docker compose build api && docker compose up -d api`, then check that site-packages holds `__editable__.dating_app_server-*.pth` and NOT a real `app/` directory.
3f. **Deep links need BOTH halves, and each alone looks like the other is broken.** Client: `usePathUrlStrategy()` in `main.dart` — without it Flutter web's default HASH strategy means go_router sees only the empty part after `#` and starts at `/`, **while the correct URL sits in the address bar**. Server: an SPA fallback to `index.html` — `ux/serve_build.py` does this; `python -m http.server` does not and 404s. If a deep link misbehaves, check both before suspecting the router.
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
15. **`log_event` has reserved field names, and nothing warns you until that line runs** (D-010). Its signature is `log_event(logger, event, *, level, **fields)`, so `logger=`, `event=` and `level=` cannot be used as log FIELDS anywhere in the codebase. `event=chosen` in the event-injection line raised `TypeError` from inside the logging call and killed a pipeline **after** it had already spent a scenario call. Lint cannot see it; `**kwargs` keeps the call legal until execution.
16. **A JSONB column stores Python `None` as the JSON value `null`, not SQL NULL, unless you say `JSONB(none_as_null=True)`** (D-011). `date_messages.state` did exactly this: environment rows looked null in every JSON payload and every Python read, while failing `state IS NULL` in SQL. Step 12's judging filters spoken turns on precisely that predicate. Both `date_messages.state` and `analyses.progress` now set it; any new JSONB column whose NULL means something must too.
17. **`probe_simulation_resume.py` runs on the HOST, not in the container**, and it is the only probe that does. It has to kill the api container, and `docker compose exec` processes die *with* the container — a probe that kills the API from inside kills itself mid-assertion. It uses stdlib `urllib` for the same reason (no project virtualenv on the host). Its default run stops once resume is proven; `--full` waits for every date and costs a full analysis.
18. **A rate-limited call now takes ~50 seconds to fail, on purpose.** Rate limits get their own backoff schedule (20 s, 30 s) separate from the 2 s/4 s used for dropped connections, because every quota this project meets is per-minute or per-day and three retries inside seven seconds all land in the same blocked window. A slow failure is the intended behaviour, not a hang.
19. **The `dates` rows are created BEFORE any turn runs, and re-running a pipeline reuses them.** That is what makes resume free — but it also means a failed run leaves date rows behind, and re-triggering `POST /simulate` will NOT regenerate the scenarios. To start genuinely fresh, delete the analysis's `dates` rows first.

## Owed measurements (§4)

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-3 | Matching vs properly seeded demo profiles | Step 9 | Step 15 | **Anticipated** |
| O-4 | Native (Windows) run rendering `/health` | Step 1, 2026-09-01 | Owner: Developer Mode + `flutter run -d windows` | **Owed** |
| O-5 | Step 8 AC2/AC3 UI paths not yet clicked: the optimistic-update ROLLBACK on a forced server error, and the dispute deep-link through to answering the generated question | Step 8, **2026-09-01** | A browser pass with the API forced to fail | **Owed** |
| O-6 | Step 8 AC4's stale→fresh flip: the header was witnessed in its `failed` state but not observed going "Profile changed" → rebuild → "up to date" | Step 8, **2026-09-01** | A browser pass after an answer edit | **Owed** |
| O-7 | The fidelity gate re-run **by the owner on the owner's own account**. The gate asks you to count lines *you* would never say; this session could only assess against the account's written answers | Step 8, **2026-09-01** | Owner | **Owed** |
| O-8 | Step 9's end-to-end witness: ONE clean `probe_matching_filters.py` run from an empty probe pool. The only GREEN run this session was polluted (concurrent runs sharing an output file; stale probe users in the pool; `shared_interests` vacuous under D-009) | Step 9, **2026-09-01** | A single clean run after the OpenRouter daily cap resets (2026-09-02 00:00 UTC) | **Owed** |
| O-9 | Step 10's `no_candidates` screen and the remaining empty states rendered in a browser. The code paths exist and `partial` was witnessed; the empty pool was not reproduced this session | Step 10, **2026-09-01** | Toggle the only candidate's `opt_in` off and re-run | **Owed** |
| O-13 | Step 11 AC6: the empty-intersection fallback observed live, producing two settings whose `anchored_in_interest` values come one from each person's list. Unit-tested both branches; never run against a real pair sharing zero interests | Step 11, **2026-09-01** | Match two people with no overlapping interest labels | **Owed — deliberately deferred** (owner, 2026-09-01): both branches are unit-tested, so this waits until it blocks something or until a wider rollout wants it validated. Do not spend model calls on it before then |
| O-14 | Step 11 AC7: the global semaphore of 2 observed limiting three queued analyses. `simulation_slot_acquired … waited_ms` logs on every run and read 0 both times, which proves nothing | Step 11, **2026-09-01** | Three users with matched analyses, simulated at once | **Owed — deliberately deferred** (owner, 2026-09-01), on the same reasoning as O-13 |
| O-15 | Matching embeds the requester and every candidate in a tight sequential loop, which walks straight into google's per-MINUTE embedding cap. The retry schedule now survives the window (fixed this session); the loop still enters it | Step 11, **2026-09-01** | Space or batch the embed calls in `app/matching.py` | **Owed** |

*(O-10, O-11 and O-12 were incurred and closed within the same session and is deleted per the queue rule: O-10 closed on the third run of `probe_simulation_resume.py`, GREEN at 23/23; O-11 closed when a sixth date ended itself by mutual `wants_to_end` at 25 messages with a clean two-line goodbye; O-12's narrowed halves — a transient fault exhausting the 3-attempt ladder, and the pipeline starting the next date after an incomplete one — were both observed unforced when the model emitted a degenerate whitespace loop mid-date.) (O-1 closed 2026-09-01 — `opt_in` was observed removing and restoring a candidate in someone else's pool. O-2 closed 2026-09-01 — the pinned-snapshot assertion is enabled in `probe_answer_edit.py` (S9-P2). Step 6's O-5 and O-6 were incurred and closed the same day — AC5 witnessed by replacing an answer's whole subject, AC6 witnessed live after the move off google — and are deleted per the queue rule. Earlier: O-5 — the Step 2 live-call ACs — was closed 2026-09-01 and deleted per the queue rule: keys arrived, both probes ran GREEN, the config-only model swap and the 429→backoff→typed-error path were both observed in the logs.)*

## Probe status (§2)

| Probe | Status |
|---|---|
| `probe_structured_guard.py` | **GREEN** (2026-09-01, google/gemini-3.6-flash) |
| `probe_pool_expansion.py` | **GREEN** (2026-09-01) |
| `probe_ai_smoke.py` (helper, not in the §2 minimum set) | **GREEN** (2026-09-01; openrouter model passed as argument) |
| `probe_answer_edit.py` | **GREEN** (2026-09-01, S6-P1/P2 — real AI calls) |
| `probe_onboarding.py` | **GREEN** (2026-09-01, S7-P1 — 16 checks, real AI calls) |
| `probe_matching_filters.py` | Written (S9-P1); **the one clean run is still OWED (O-8)** |
| `probe_simulation_resume.py` | **GREEN — 23/23** (2026-09-01, S11-P1, real AI calls, ~13 minutes). It took three runs to get there and the first two failed on the PROBE, not the code: an uncaught Windows socket abort when it killed the API, then a `UnicodeEncodeError` printing its own verdict on a legacy-code-page console. Both fixed. The recorded green run waited for the whole analysis, which is what `--full` now selects; the 23 assertions are unchanged by that gating |
| `probe_judge.py` | **GREEN — 9/9** (2026-09-01, S12-P1). Takes an account email as its argument and reuses an already-judged date rather than simulating a fresh one: `docker compose exec api python probes/probe_judge.py <email>`. Costs ONE call |
| All others (`deletion`, `demo_seeding`) | Not written — delivered in Step 15 |

## Module build order

1 ~~Foundations~~ **(done; O-4)** · 2 ~~AI Interaction~~ **(done)** · 3 ~~Schema + reconciliation~~ **(done)** · 4 ~~Accounts~~ **(done; O-1)** · 5 ~~Questions & answers~~ **(done)** · 6 ~~Trait extraction~~ **(done)** · 7 ~~Persona & snapshots~~ **(done)** · 8 ~~UX profile + fidelity gate~~ **(done; gate CLOSED)** · 9 Matching **(code complete; witness OWED O-8)** · 10 ~~UX dashboard~~ **(done; O-9)** · 11 Simulation **(built; resume WITNESSED; O-13/O-14 deferred)** · 12 ~~Judge~~ **(done, all 7 ACs; quota gate CLOSED)** · 13 UX results ← **next** · 14 Chat · 15 Data hygiene · 16 Witness sweep.

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **CLOSED 2026-09-01** — see the measurement below |
| Quota fit | Step 11 → 12 | **CLOSED 2026-09-01 (S12-G1)** — one full analysis end to end, 59 calls in 7m13s with zero retries. Measurement below |

### Quota reality, measured (feeds the quota-fit gate)

| Provider | Limit | Evidence |
|---|---|---|
| **OpenRouter free models** | documented as 50/day account-wide — **but see the correction below; measured behaviour does not match** | Step 9 and Step 11, 2026-09-01 |
| **google `gemini-3.6-flash`** | ~20/day (behaves as daily) | Step 6; the reason chat moved off google entirely |
| **google `gemini-embedding-001`** | low per-MINUTE cap | Step 2, and it took down an analysis in Step 11 — see below |

### Quota-fit spreadsheet (S11-G1, Step 11 AC8) — MEASURED 2026-09-01

The gate asks for calls-per-analysis against the providers' caps, as a spreadsheet, with the paid-balance decision made from it. Every latency below is a measured mean from this session's logs, not an estimate.

**Measured per-call cost**

| Task | Provider / model | Mean latency | n |
|---|---|---|---|
| `trait_extraction` | openrouter / dots-3-note-preview | 21.3 s | 4 |
| `persona_digest` | openrouter / dots-3-note-preview | 20.4 s | 4 |
| `scenario_generation` | openrouter / dots-3-note-preview | 29.5 s | 1 |
| `date_simulation` (one turn) | openrouter / dots-3-note-preview | **7.5 s** (max 29.7) | 38 |
| `embeddings` (both vectors, one batch) | google / gemini-embedding-001 | 0.74 s | 2 |

**One analysis, full pool (3 candidates × 1 date = 3 dates)** — REVISED 2026-09-01

| Stage | Calls | Provider | Wall clock |
|---|---|---|---|
| Re-embed requester + 3 candidates | up to **4** | google | ~3 s |
| Scenario generation, 1 per candidate | **3** | openrouter | ~1.5 min |
| Date turns — 28 per date × 3 | **84** | openrouter | **~9 min** |
| Judging, 1 per date | **3** | openrouter | ~1 min |
| **Total** | **90 openrouter + 4 google** | | **~11 min** |

**These are measured, not scaled.** One candidate end to end costs exactly **30 calls** (1 scenario + 28 turns + 1 judge), counted from the logs of a real run on 2026-09-01 after the revision. Multiply by the pool size.

28 turns, not 30: the cap counts environment rows, and a date that fires two events spends two of its thirty slots on them. A date with no events costs 30 turns, so the honest range is **90–96 openrouter calls per full analysis**.

**Before the 2026-09-01 revision** the same table read 171–189 calls and ~24 minutes, at two dates per candidate. The owner halved it by halving the dates.

Onboarding one person, for comparison, is **2 calls** (extract + compile). A full analysis costs about **as much as 45 onboardings.**

**Against the caps**

| Allowance | Analyses per day | Verdict |
|---|---|---|
| OpenRouter free tier, as documented (50/day) | **0.55** | **A single analysis still cannot complete.** It needs 1.8× the whole day's allowance — better than the 3.4× before the revision, and still short |
| OpenRouter with 10 credits added (1000/day) | **~11** | Comfortable for a friends-scale app |
| google embeddings | not the constraint on volume — but see the per-minute cap below | |

**The decision this spreadsheet forces:** on the free tier as documented, the product's core loop **still cannot run once** — 90 calls against a 50/day allowance. Halving the dates halved the cost and did not change that conclusion, it only moved the shortfall from 3.4× to 1.8×. The remedy is the one named in OpenRouter's own 429 body: **adding 10 credits raises the free-model allowance to 1000/day**, which buys ~11 full analyses a day. That is the owner's call and it is now backed by measurement.

### Correction: the "50 free calls per day" figure is not what it looks like

Last session recorded "OpenRouter free models: 50 requests per DAY, account-wide" as a settled fact. **This session contradicts it, and the contradiction is not explained.**

- At **14:55 UTC** a direct one-token call returned `429 … free-models-per-day`, `X-RateLimit-Limit: 50`, `X-RateLimit-Remaining: 0`, `X-RateLimit-Reset` = 2026-09-02 00:00 UTC.
- Between **15:12 and 15:30 UTC the same day**, on the same key and the same model, the api container made **118 successful free-model calls** with 5 rate-limited ones among them. No reset happened in between.

So the cap is real and it does bite, but it is **not a simple per-calendar-day counter**, and `X-RateLimit-Reset` did not predict when service resumed. Do not plan against 50/day as a hard ceiling, and do not plan against it being absent either. What is safe to say: **free-tier throughput is unpredictable enough that a 24-minute, 171-call pipeline cannot be relied on to finish.** That is the same conclusion as the table above, reached a second way.

### The other cap, and what it cost today

**google `gemini-embedding-001` is per-MINUTE, and matching walks straight into it.** Matching embeds the requester and then each candidate, sequentially, within a few seconds — four calls into a low per-minute window. It returned `Quota exceeded for … embed_content_requests_per_minute_per_base_model`, and the analysis **failed outright**, taking down a probe run with it.

The retry schedule was the reason it was fatal rather than slow: the resilience layer backed off 2 s then 4 s, so all three attempts landed inside the same blocked minute. **Fixed this session** — rate limits now get their own schedule (20 s, then 30 s, ~50 s of total waiting), separate from the 2 s/4 s that is right for a dropped connection. Named trade, in the code: a call that is doomed anyway now takes ~50 s to say so.

**Still owed and not fixed:** matching makes those embed calls in a tight sequential loop. The backoff now survives the window; spacing the calls would avoid entering it. That is Step 9's module and it is written up as **O-15**.

### Quota-fit gate — CLOSED 2026-09-01 (S12-G1, Step 12 AC7)

**The run:** analysis `1ea9f4d9`, one uninterrupted pass from `POST /analyses` to `status: complete`. Matching → 1 scenario call → 2 dates of 30 messages → 2 judge calls → scored. Nothing was restarted, nothing was injected, no cap was hit.

| | Calls | Mean latency |
|---|---|---|
| `scenario_generation` | 1 | 27.2 s |
| `date_simulation` (turns) | 56 | 6.0 s |
| `judging` | 2 | 18.3 s |
| **Total** | **59** | **retries: 0** |

**Wall clock: 7 minutes 13 seconds**, start to `complete`. Embeddings cost nothing on this run — both people were already fresh; a cold run adds up to 4 google calls.

56 turns for 60 stored messages: the other 4 are environment rows, which take a slot but no call.

**Against the Step 11 spreadsheet.** The estimate for this shape (1 candidate, 2 dates) was 1 + 54 + 2 = **57 calls**; the measurement is **59**, 3.5% high, because only 2 events fired instead of the 3 the estimate assumed. The estimate was good.

**This run predates the one-date revision.** It is kept as the gate's closing evidence because that is what closed it — a complete pipeline against real providers, on the caps in force at the time. A second run after the revision produced **one** date for the same pair at **30 calls**, judged and scored, confirming the pipeline is unchanged by the cap and giving the per-candidate figure the spreadsheet above now uses.

**What the gate asked, and the answer:** *can one full pipeline complete against the real providers without exhausting a daily cap?* **Yes — and it did.** 59 calls, zero retries, zero rate-limited responses, in seven minutes.

**But read the number the other way before relaxing.** 59 calls was a `partial` pool with ONE candidate, at two dates each. Even after the revision a full pool is ~90, and the documented free-model allowance is 50 a day. **This run only succeeded because the free tier is not behaving like the 50/day counter it advertises** (see the correction above) — it is not evidence that the free tier is sufficient, it is evidence that the pipeline is efficient and correct. The paid-balance decision stands exactly where the Step 11 spreadsheet left it, now with a completed run behind it rather than an estimate.

### Fidelity transfer gate — the measurement (S8-G1, Step 8 AC7)

**Model tested:** `openrouter/dots-studio/dots-3-note-preview:free` — the model `date_simulation` is routed to, deliberately pinned to the same model as `chat_reply` so calibration chat IS the date model rather than a stand-in. **Snapshot:** bob v3 (`ready`), digest by the same model. **Messages:** 6 persona replies over one calibration session, plus 1 more driven through the browser UI.

**Result: 1 clear "I'd never say that" line out of 6, plus 1 borderline.**

- **The clear failure — INVENTED BIOGRAPHY.** Asked "tell me something you're bad at", the persona answered *"I'm bad at cooking… I still managed to set off the smoke alarm making spaghetti last month."* Bob never wrote a word about cooking. His stated weaknesses are not noticing when someone wants comfort rather than a solution, and a pedantic streak. The persona did not merely miss the voice — **it fabricated a specific autobiographical anecdote**, which on a date would be a fact about the user that the user has never heard.
- **The borderline.** Told "my dad's been in hospital", it replied with fluent emotional attunement. Bob explicitly wrote that he *offers a fix when someone wanted company*. The reply was better at comfort than Bob says he is — flattering, and therefore not him.
- **The four that were right were VERY right:** the dealbreaker answer reproduced his own framing ("honest awkwardness over smooth charm I can't trust", rudeness to waiters, contempt); "slow to warm up, loyal to a fault, I remember the small stuff" came straight from his traits; the disagreement answer volunteered "I'm pedantic about details" and "I'd retreat into the garage" unprompted.

**Honest limit on this measurement, stated because it changes what it is worth:** the gate as written says *count the lines **you** would never say*, and only the person themselves can do that. I am not Bob. This was assessed against the account's own written answers — a defensible proxy, not the real thing. **The owner should re-run this on their own account before any date output is trusted for judging.** What it does establish is that the pipeline transfers voice well enough to be worth judging, and that the specific failure mode to watch for is *fabricated concrete detail*, not blandness.

## Where the decisions live

- **What:** `user_perspective.md` → `project_description.md` → module plans. **How:** `development_principles.md`.
- **Wire:** `communication_protocol.md`. **Order:** `IMPLEMENTATION_PLAN.md`. **What went wrong:** `DEFECTS.md` (D-001…D-005).
