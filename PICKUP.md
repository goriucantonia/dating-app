# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-01 · **Updated because:** **Step 10 is built and largely witnessed on real data** — the dashboard, the reveal, one polling loop proven against the network log, and deep links working after finding they need BOTH an SPA fallback AND `usePathUrlStrategy()`. **Step 9 remains code-complete with its end-to-end witness OWED (O-8)** — do not record it as done. OpenRouter free tier is 50 requests/day and was exhausted; it resets 2026-09-02 00:00 UTC.

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

**Next: clear O-8 and O-9 after the quota resets, then Step 11 (date simulation).** Steps 1–8 are done and witnessed; **Step 9 is code-complete with its witness OWED**; Step 10 is built and largely witnessed. The fidelity gate is closed with its measurement recorded below.

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

## What is next

**Two owed witnesses first, both cheap once quota resets (2026-09-02 00:00 UTC):** O-8 (Step 9's clean probe run) and O-9 (Step 10's `no_candidates` screen). Then **Step 11 — date simulation**, which opens the quota gate and is the most quota-hungry step in the plan; read the measured quota numbers below before starting it.

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
3d. **When dwds will not co-operate, witness against a RELEASE BUILD, not the dev server.** `flutter build web` then `python -m http.server 5000 --bind 127.0.0.1` from `ux/build/web`. No debug websocket exists, so the whole dwds failure class disappears; it loads in about a second instead of ninety, and it is what the user would actually run. Cost: no hot reload, and you must rebuild after each Dart change. This is how Step 8 was witnessed after the dev server refused to boot the app repeatedly.
3e. **Do not edit files under `server/` while a probe is running.** uvicorn runs with `--reload`; a save restarts the API and kills every in-flight request the probe is waiting on. A long matching probe was lost to this. Either wait for the probe to settle, or make the edit and accept re-running it.
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

*(O-1 closed 2026-09-01 — `opt_in` was observed removing and restoring a candidate in someone else's pool. O-2 closed 2026-09-01 — the pinned-snapshot assertion is enabled in `probe_answer_edit.py` (S9-P2). Step 6's O-5 and O-6 were incurred and closed the same day — AC5 witnessed by replacing an answer's whole subject, AC6 witnessed live after the move off google — and are deleted per the queue rule. Earlier: O-5 — the Step 2 live-call ACs — was closed 2026-09-01 and deleted per the queue rule: keys arrived, both probes ran GREEN, the config-only model swap and the 429→backoff→typed-error path were both observed in the logs.)*

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

1 ~~Foundations~~ **(done; O-4)** · 2 ~~AI Interaction~~ **(done)** · 3 ~~Schema + reconciliation~~ **(done)** · 4 ~~Accounts~~ **(done; O-1)** · 5 ~~Questions & answers~~ **(done)** · 6 ~~Trait extraction~~ **(done)** · 7 ~~Persona & snapshots~~ **(done)** · 8 ~~UX profile + fidelity gate~~ **(done; gate CLOSED)** · 9 Matching **(code complete; witness OWED O-8)** · 10 ~~UX dashboard~~ **(done; O-9)** · 11 Simulation + **quota gate opens** ← **next** · 12 Judge + **quota gate closes** · 13 UX results · 14 Chat · 15 Data hygiene · 16 Witness sweep.

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **CLOSED 2026-09-01** — see the measurement below |
| Quota fit | Step 11 → 12 | **Open — but the decisive number is now measured, see below** |

### Quota reality, measured 2026-09-01 (feeds the quota-fit gate)

Both free tiers were hit to exhaustion in one working day:

| Provider | Limit | Evidence |
|---|---|---|
| **OpenRouter free models** | **50 requests per DAY, account-wide** | `429 {"message":"Rate limit exceeded: free-models-per-day"}`, `X-RateLimit-Limit: 50`, `X-RateLimit-Remaining: 0`. Resets 2026-09-02 00:00 UTC. **It is account-wide, not per model** — switching between `dots-3-note-preview` and `nemotron-3-super` made no difference, which is how it was identified. |
| **google `gemini-3.6-flash`** | ~20/day (behaves as daily) | Step 6; the reason chat moved off google entirely |
| **google `gemini-embedding-001`** | low per-minute cap | Step 2; still live, embeddings remain on google |

**What 50/day buys:** one onboarding costs 2 calls (extract + compile). `probe_matching_filters.py` costs ~6. `probe_answer_edit.py` costs 4. **A day of development is ~10 probe runs before everything stops.** That is the quota-fit answer for the free tier, and it is a development-velocity problem before it is ever a product problem.

**The remedy is named in the 429 itself:** adding 10 credits to OpenRouter raises the free-model allowance to **1000 requests/day**. That is an owner decision (the paid-balance question, already in the blocked table) and it is now backed by a number rather than a guess.

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
