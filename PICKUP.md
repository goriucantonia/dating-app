# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-02 · **Updated because:** **Two owner decisions landed on the date pipeline: one random scenario per analysis run identically against every candidate (D-021), and the ≥10-turn "too short to judge" rule removed entirely.** Before this, three candidates were ranked against each other on three DIFFERENT evenings and the results masthead printed "— the same for every candidate" underneath them; now one archetype is drawn in code from a 16-entry catalogue, generated once, and copied onto every date, with the last 3 a user has had excluded from their next draw. And every date with a transcript is judged however short — depth is reported as the judge's own `confidence` (`judge_rubric.v2`) instead of being used as a bar to clear. **Server 145 pytest GREEN · UX 54 widget tests GREEN · `flutter analyze` clean · migrations `0011` (the fixture) and `0012` (the judge's confidence) applied. OWED: the live witness — nothing in this change has been run against real providers yet (see "What Step 11/12 owes after 2026-09-02").** Earlier today: D-020, D-019, D-018, D-017, Step 17 (candidate rejection, probe GREEN 15/15), D-016, the Modernist restyle (O-18), the ten-person demo pool (O-22).

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

**Next: the owner's turn.** Every step is built. Steps 1–8, 10, 12 and 15 are witnessed whole; Step 9's clean matching run (O-8), Steps 13–15's signed-in browser pass (O-16/O-20), Step 14's live compaction (O-19), and the cold-stack probe sweep (O-21) are the open witnesses, and each is priced in the Owed table. The demo profiles mean a real account can run an analysis and find three people — that is O-3, now unblocked.

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
    ├── Flutter 3.47.2 app (lib\app, lib\core\{api,auth,polling,notify}, lib\features\{auth,questions,persona,traits,chat,analyses,dates,home,settings,common}) + widget tests
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
| Step 11 simulation | **Built; the central claim WITNESSED.** A real analysis ran two full-length dates end to end; a SIGKILLed API came back, reconciliation relaunched it, and the date logged `resumed_from_checkpoint … seq 3` and carried on. 4 of 8 ACs owed — see the table below | api logs + psql + transcript this session |
| Step 12 judging | **Witnessed, all 7 ACs** — score recomputed by hand on four analyses, both sides of the 10-message boundary, empty `clashes` accepted, provenance on every row, `probe_judge.py` GREEN 9/9, and the quota gate closed on a full run | probe + psql + api logs this session |
| Step 13 UX results | **Built; RESTYLED onto the Modernist design system (O-18); tested on MOCKED data (19 widget tests, all still green after the restyle); wire verified on real data; server-side resume WITNESSED over HTTP.** The signed-in browser pass is owed (O-16) — see the Step 13 section | `flutter test` 19/19, `flutter analyze` clean, curl against the running stack, api logs |
| Step 14 chat | **Built; server side WITNESSED over HTTP** (selection 201, `already_selected` 409 and `not_a_candidate` 404 as state, one real reply with no `state` on the wire, forced give-up → 502 with the user's message not stored, end → 409 `chat_ended` with history readable). UX tested on MOCKED data (7 widget tests). **Compaction not witnessed live (O-19)**; browser pass owed (O-16) | curl, api logs, psql; `flutter test` 25/25 |
| Step 15 data hygiene | **Witnessed, all 8 ACs** — `probe_deletion.py` GREEN 17/17, `probe_demo_seeding.py` GREEN 12/12, the four-step pass a no-op on a healthy boot, the planted embedding mismatch logged and marked stale, `scan_dead_data.py` reporting 6 items and deleting nothing. UI (delete flow with receipt, tombstones, the vanished chat) widget-tested on mocks; browser pass owed under O-16 | probe verdicts, api logs, psql; `flutter test` 29/29 |
| Step 16 witness sweep | **Run as far as a session without a human can take it** — see the Step 16 section: drift 0, privacy 10/10, log reconstruction done, 7/9 probes GREEN today, the flag and give-up sweeps tabulated with each observation's source. The cold-stack sweep (O-21) and the browser passes (O-16/O-20) need the owner | this session's tool output, retained in the sections below |
| Step 17 candidate rejection | **Built and WITNESSED, all 8 ACs** (AC8's browser half owed under O-16) — `probe_candidate_rejection.py` GREEN 15/15 over HTTP on a live analysis, zero model calls; migration `0010`; 11 new unit tests; 6 new widget tests | probe verdict, api logs, psql |
| Step 18 navigation + corrections | **Built and tested (D-018)** — one `StatefulShellRoute` with four branches, `BackTo` everywhere, the dispute's own `/profile/correct/:questionId` screen, waiting-corrections banner on the profile. 8 tests drive the REAL router | `flutter test` 43/43, `flutter analyze` clean |
| Unit tests | **Server 139 pass** (10 new in `tests/test_identity_refresh.py`; 11 in `tests/test_candidate_rejection.py`; 6 earlier (6 new in `tests/test_deletion_graph.py` — the cascade graph walked from the ORM metadata and every reached table asserted counted) · **UX 50 pass** (6 new in `test/step19_preferences_test.dart`, 1 for D-019, 8 in `test/step18_navigation_test.dart`, 6 in `test/step17_rejection_test.dart`) | in-container `pytest`; `flutter test` |
| Lint / build | **GREEN, no outstanding errors.** The long-standing `RUF100` in `migrations/env.py` was removed 2026-09-01 — the suppression named `E402`, which this project does not enable, so the suppression was itself the only lint error in the repo. The reason it documented is kept as a plain comment | in-container `ruff check .` |
| Remotes | All three repos pushed to GitHub (superproject `dating-app`, `dating-app-server`, `dating-app-ux`) | push output 2026-09-01 |

## What was just finished (the Modernist restyle — O-18 — and a ten-person demo pool)

**The design source.** `Matchmaking app UI design/Ranking & Date Reveal.dc.html` (the Claude Design canvas, four artboards: 1a/1b the ranking at desktop width, 1c/1d the reveal at phone width) and its token sheet `_ds/modernist-*/styles.css` + `readme.md`. The system: flat and architectural, set in Archivo, one accent (#ec3013) on an off-white ground (#f3f2f2), **zero corner radius anywhere**, 2px rules instead of cards and shadows, flush-left labels, tabular figures, uppercase micro-labels.

**What changed.**

- **`lib/app/theme.dart` — the whole theme, rewritten as the design system.** The token sheet is transcribed with the CSS variable names kept as Dart names so the two can be diffed by eye. Two departures from `ux_architecture.md` §1.6, both named in the file: the `ColorScheme` is **written out rather than seeded** (`fromSeed` invents a green tertiary and a purple secondary, and this palette is mono), and dark mode is the same system inverted rather than a second palette. Every shape is square, every button label is flush left, focus and hover come off the accent ramp.
- **`Modernist` `ThemeExtension` + `Kicker` / `Tag` / `Rule`.** The roles Material has no slot for — the plot ground, the two curve strokes, the rule ink, the accent tint. `Modernist.of(context)` **falls back to the light tokens when the extension is absent**, which is what lets the 29 existing widget tests keep pumping a bare `MaterialApp` and still get the design.
- **`results_screen.dart`.** The ranking is now the design's row: a masthead whose tally (`3 candidates · 6 dates`, `5 complete · 1 partial`, `judge_rubric.v1`, the shared settings) is **read off the wire, never asserted**; a rank gutter with the numeral, `FINAL`, the score in tabular figures and the line saying what it is a mean of; the candidate's name and dates in the main column; square bordered date panels; `PARTIAL · WEIGHTED ×0.5` as an outlined tag instead of an amber icon; "what clicked" as square accent-tinted chips. The composition panel gained the design's **weight bars** — the bar is the candidate's mean on that check *as it enters the sum* (the inverted check drawn as 100 − clash, so a long bar always means "did well"), the number beside it is the weight. Banners are flat tinted fields; the error state is flush left.
- **`curves.dart`.** The chart moved onto the design's flat plot ground with 25-step gridlines, the two-stroke convention (**connection solid and heavy, satisfaction light and dashed**, the two people told apart by colour — four dash patterns compete and none of them reads), event markers as the design's fine dashed ticks, a `SEQ 1 · CONNECTION · SATISFACTION · 0—100 · SEQ n` axis strip, and a legend whose swatch **draws the stroke it stands for** instead of saying "(dashed)" in words.
- **Archivo** arrives via `google_fonts` (added to `pubspec.yaml`, resolved from the local pub cache with `pub get --offline`). **Named trade:** the font is fetched at runtime, so offline the app falls back to the platform sans and keeps every weight, size and tracking — the layout is identical and only the letterforms differ. In a widget test with no network `google_fonts` throws a caught exception; nothing in the app's own suite touches `AppTheme`, so the suite is unaffected.

**Two real layout defects were found and fixed before they shipped**, by rendering the restyled screen to PNG inside a throwaway widget test (`RepaintBoundary.toImage`, no server and no sign-in needed — the test font draws boxes, so it checks geometry, not letterforms): the route label in the app bar overflowed its actions slot, and the "How it felt, over time" / "Read it" row overflowed the column the rank gutter leaves it on a phone. The route label is gone; the row is a `Wrap`, and the gutter narrows to 76px under 480px wide.

**Still owed:** the restyle has not been *looked at* in a browser with the real typeface — that is part of O-16, and O-18 now names only that.

**The demo pool went from 3 people to 10.** `seeds/demo_profiles.yaml` gained Ana, Radu, Ileana, Sam, Dana, Victor and Petra — seven more real accounts with five baseline answers each, written in distinct voices, spread across four cities, all four `gender` values represented and a range of `interested_in` sets, so a real account can be matched on more than one axis. The fixture validates through `load_demo_profiles()` (A1 rules, the 50-character floor) and the accounts and answers were seeded **through the real registration and upsert paths** — `demo_accounts: {created: 7, answers_created: 35, answers_edited: 0, ok: 3}`, the original three untouched.

**What is NOT done for those seven, and why:** the AI half of the pipeline — extraction, persona compilation, embeddings — was deliberately not run, because it is three model calls per profile (21) and the owner's standing rule is not to spend calls on what is already unit-tested. **UPDATE 2026-09-02 — O-22 is CLOSED.** The owner chose to spend the calls: `run_reconcile.py --wait` returned `extracted: 7, compiled: 7, embedded: 7, failed: 0, deferred: 0, ok: 3` (21 calls, ~4 minutes, no rate limits, no failures). All ten demo profiles now carry traits, a `ready` persona snapshot and two vectors, and the pool is ten people deep.

## Step 17 — turning a candidate down before the dates run (built and WITNESSED, 2026-09-02)

**Why it exists.** The owner asked for it after reading a real ranking: "why can't I dismiss one and choose the fourth?" The honest answer was that nothing was built for it, and that the top three were separated by **0.005** — a near-tie where the one person in the pool who shared an interest with the requester sat **sixth** (D-016). A swap is worth more the flatter the ranking is.

**Server (S17-B1…B4).**
- Migration `0010`: `analysis_candidates.status` (`active` | `rejected`) + `rejected_at`, the two CHECKs that keep them consistent (`(status='rejected') = (rejected_at IS NOT NULL)`), and **`UNIQUE (analysis_id, rank)` replaced by a PARTIAL unique index over the active rows**. A rejected row keeps the rank it held when the user saw it; the seat is re-filled behind it.
- `app/matching.py`: the scoring loop was extracted into **`score_pool(..., exclude=…)`** — the ONE scoring path, now shared by the first three and every replacement, so a replacement cannot be built by different arithmetic than the original. `reject_and_replace()` marks the row, scores the pool with everyone already offered excluded, re-ranks 1..n by compatibility in two phases (the partial index is checked per statement, so every live row goes negative first), and updates `candidate_count` / `pool_status`. Two pure gates sit beside it: `rejection_refusal(status)` and `would_leave_nobody(...)`.
- `POST /analyses/{id}/candidates/{user_id}/reject` — **synchronous**, unlike `POST /analyses`, because the work is vector arithmetic over embeddings that already exist and the UI can render the new three from the response instead of polling for a swap it cannot see happen. `_build()` now filters to `status='active'`, so a rejected person is never on the wire again.

**UX (S17-U1, U2).** `AnalysesRepository.rejectCandidate()`; a "Not this one" action on each candidate card, present **only** while the analysis is `matched` (a button that can only ever fail is worse than no button, §11). One confirmation that says the two things the user cannot see for themselves — *they don't come back*, and *someone else may or may not be waiting* — then a snackbar naming who took the seat, or saying plainly that nobody did. Refusals are shown in the server's own words.

**Things worth not re-deciding:**
- **The rejected row is kept.** It is the record of a decision (the rule retracted traits and superseded snapshots already follow), it is how the replacement search knows not to offer the same person back, and with `UNIQUE (analysis_id, candidate_user_id)` still in place a re-offer becomes impossible **by construction** rather than by care.
- **Rejection is per-analysis, not a block-list.** A persistent block is a different feature with its own consent questions ("are they told?", "does it cut both ways?"), and deciding it silently inside a swap button would be the wrong place. Named in `candidate_matching.md` trade 7.
- **Ranks are re-assigned.** Rank means "ordered by fit" everywhere else in this system; a stable-but-wrong rank would be a number that quietly stopped meaning what it says.
- **Refuse rather than empty.** Turning down your last candidate with nobody to replace them would leave an analysis that can never be simulated, so it is refused with a sentence that says what to do instead.

### Step 17 acceptance criteria — all witnessed

| AC | Status |
|---|---|
| 1 a rejected candidate leaves the wire and the next-best takes the seat | **Witnessed** — `probe_candidate_rejection.py` GREEN 15/15 over real HTTP on a live `matched` analysis: Dan out, **Radu in**, line-up still three |
| 2 the ranks stay 1..n, ordered by fit | **Witnessed** — `[1, 2, 3]` with compatibilities `[0.6600, 0.6577, 0.6488]` descending |
| 3 the rejection is recorded, not erased | **Witnessed** — the row is still there as `('rejected', 3, rejected_at set)` |
| 4 the swap does not look like a deletion | **Witnessed** — `candidate_count` follows the active line-up, `removed_candidates: 0`, so no tombstone appears |
| 5 the same person cannot be rejected or offered twice | **Witnessed** — a second rejection is 404 `not_a_candidate`; a third rejection offered a person who was neither of the first two |
| 6 every refusal is a named state with a sentence | **Witnessed** — 404 `not_a_candidate` on a non-candidate; 409 `cannot_reject_now` on a `complete` analysis, carrying "These dates have already run…" |
| 7 no model call in the normal case | **Witnessed** — **0 `ai_call` lines** in the api log across the probe's three rejections |
| 8 the UI confirms before swapping and shows every refusal | **Widget-tested on mocks** (6 tests): the action is absent unless `matched`, "Keep <name>" swaps nothing, confirming names who took the seat, an empty seat says so, a server refusal is rendered verbatim. **Browser pass owed** under O-16 |

**Cost of the whole step: zero model calls.** The probe's three rejections made none, which is the point of scoring over stored vectors.

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

- **The judging threshold counts AGENT TURNS too** (revised 2026-09-01, owner decision). It counted transcript rows until now, which was a leftover from when the date cap did — and once the cap moved to turns the two rules disagreed about what a date is made of. The disagreement was reachable and had already happened in stored data: `7 turns + 3 events = 10 rows` was judged while `9 turns + 0 events = 9 rows` was thrown away, so the date with LESS conversation got the score. Both now read the same `turn_count`. The number stays 10 and the change RESTORES its stated meaning — "roughly five each" was always a claim about turns. Against a 16-turn cap this is a high bar (~62% of a full evening); revisit the number if genuinely half-finished dates start being discarded, not to make scores look better.
- **The date cap is 16 AGENT TURNS, and it does NOT count environment rows** (revised 2026-09-01 by the owner, from a 30-message cap that did). The budget is written in model calls — 1 scenario + 16 turns + 1 judge — and an event costs no call, so charging events against the cap made the real spend 13–16 turns depending on dice. That is a distribution, not a budget. Events still fire and still cap at 3; a transcript is at most `TURN_CAP + MAX_EVENTS_PER_DATE` = 19 rows, and `MAX_MESSAGES_PER_DATE` is derived rather than typed. **This reverses a rule that `development_principles.md` §18 held up as a standing example**, so §18 itself was revised — and the unit test that pinned the old behaviour was INVERTED rather than deleted, because someone will eventually remember the old rule.
- **`JUDGEABLE_MIN_MESSAGES` stayed at 10 through that change, and its meaning moved.** Against a 30-row date it was a third; against a 19-row date it is closer to two-thirds. It now excludes MORE, which is the safe direction — the failure it guards against is scoring an evening too thin to have been one. Revisit if genuinely half-finished dates start being discarded; not to make numbers look better.
- **ONE date per candidate, revised 2026-09-01 by the owner** (was two). `DATES_PER_CANDIDATE` is now derived from the schema's `SETTINGS_PER_ANALYSIS` (renamed 2026-09-02) rather than written out separately — one generated setting IS one date, and two constants that must agree are two constants that will eventually disagree. **The cost is named:** a candidate's score used to be the mean of two independent readings, so one odd evening or one wobbly judge call got averaged down; now a single date fully determines it. Bought for roughly half the model calls.
- **The empty-intersection fallback had to be rewritten, and this is the part that is easy to miss.** Its old rule was "one setting anchored in HER interests and one in HIS" — an instruction that needs two settings and became impossible the moment a candidate got one date. It now anchors on the **CANDIDATE's** interests, so a requester working through a full pool is shown three different people's worlds rather than three versions of their own. The anchor vocabulary offered to the model is the candidate's list ONLY; leaving the requester's in would quietly re-open the choice the fallback exists to make.
- **The transcript IS the state, and every rule is a pure function of it.** Whose turn it is, how many events have fired, whether the pair have started saying goodbye, which of the two endings finished the date — all recomputed from the stored rows on every pass. There is no in-flight object a restart could lose, which is *why* resume works rather than a bonus on top of it. It is also why 29 unit tests can pin behaviour that would otherwise need a live model to observe.
- **Whose turn it is comes from the COUNT of agent messages, not from "who spoke last."** An environment row sits between two turns; if it were read as "the last speaker", the two agents would swap sides mid-date.
- **The 30-message cap counts environment rows** (§18) and there is a unit test that constructs exactly that boundary — 27 spoken plus 3 events — because this is the rule someone later "fixes" into counting only what was said.
- **There is no fourth retry loop in `simulation.py`.** The three attempts with backoff live in the resilience layer and the three validation repairs live in the Guard. A turn that still fails marks the DATE `incomplete` and the pipeline moves on. Adding a per-turn retry here would silently make it 27 attempts.
- ~~**`anchored_in_interest` is a required field on every generated setting.**~~ **Replaced 2026-09-02 by `archetype`** when the scenario stopped being interest-anchored at all (D-021). The PRINCIPLE it existed for is the reason `archetype` exists: the draw happens in code, so "this analysis ran the cinema fixture" would otherwise be a claim nobody could verify after the fact — exactly the shape §9 forbids, a derived value with no provenance. The model copies the drawn key back and `generate_scenarios` checks it against what was actually drawn.
- **A candidate whose scenario generation fails is skipped, and NO date row is written for them.** A `dates` row needs a scenario, and a placeholder scenario would be a fabricated setting sitting in the database looking real.
- **The analysis is driven to `complete` here, with `progress.stage = "dates_finished"` and `judged: false`.** Step 12 inserts judging *before* that transition and takes the transition over (S12-B10). Leaving it in `simulating` would spin a progress bar over finished work; claiming it was scored would be a lie.

### Step 11 acceptance criteria — honest status

| AC | Status |
|---|---|
| 1 a full simulation produces dates with real transcripts | **Witnessed on four separate analyses** — 13 dates in total, agents visibly reacting to injected events ("Power's out, so I'll grab the flashlight"). Every pool was `partial` (one candidate). The first three ran under the old 2-dates-per-candidate cap; the fifth ran after both 2026-09-01 revisions and produced exactly ONE date of exactly **16 turns plus 3 events = 19 rows**, judged and scored 92.75 |
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
- **`excluded_from_score` is computed server-side and shipped.** A client re-deriving the rule is a client that can disagree with the server about someone's score. *(The rule it re-derived was the 10-message threshold; since 2026-09-02 the flag means only "nobody spoke on this date".)*
- **The judge is told when a transcript was cut short.** Without that note it scores the missing ending as a bad ending — the technical failure would be charged to the person.
- **A judge that cannot run does not throw away six finished dates.** Judging failure lands the analysis `complete` with `stage: judging_failed`, transcripts readable, and says so plainly. `failed` would hide an evening's worth of real work behind an error.
- **`DateDigest` takes no router, structurally.** It cannot make an AI call because it has nothing to make one with — which is a stronger guarantee than a comment saying it must not.

### Step 12 acceptance criteria — all seven witnessed

| AC | Status |
|---|---|
| 1 `probe_judge.py` green on both assertions | **Witnessed — 9/9.** Hand-recomputed score matched the stored value to the penny (90.00 vs 90.00), and **the same transcript re-judged scored identically: delta 0.00** at temperature 0.1 |
| 2 `candidate_scores` arithmetically checkable by hand | **Witnessed on four analyses.** e.g. (94.25 + 84.00)/2 = **89.12**; (93.00 + 92.75)/2 = **92.88**. Every input is in the `candidate_scored` log line |
| 3 an incomplete date is judged, flagged `is_partial`, weighted 0.5 | **Witnessed at 11, 19 and 20 messages.** By hand: (94.25×1 + 91.25×0.5) / 1.5 = **93.25**, exactly the stored value. A plain mean would have given 92.75 |
| 4 an incomplete date under 10 TURNS is EXCLUDED; both sides of the boundary observed | **Witnessed, and re-witnessed after the 2026-09-01 turn revision.** Originally: `date_not_judged … messages: 6, threshold: 10` beside a judged 19-row partial, in the same analysis. **After the threshold moved to turns**, a stored date with 11 rows but only 9 TURNS was correctly excluded on re-run — `turns: 9, threshold: 10, counted: "agent turns, not rows"` — and its candidate's score recomputed from 93.25 to 94.25 with no model call. That is the boundary observed on real data from both sides and in both units. **How the 6-turn case was made, stated plainly:** no natural run landed under the threshold (the timing window is seconds wide), so a genuine transcript was truncated in the database. Real model output; constructed length. `is_judgeable` ran on the real server path either way |

> **This acceptance criterion no longer exists (2026-09-02).** The threshold it witnessed was removed by owner decision; the row is kept because it is a true record of what was observed under the design in force at the time, and because how the 6-turn case was constructed is the recipe the replacement witness (O-23, check 4) will reuse. AC4 now reads: a 4-turn date is JUDGED, with a low confidence.
| 5 an empty `clashes` array is accepted as a verdict | **Witnessed repeatedly** — most judged dates returned `clashes: 0` with `clash_severity: 0`, stored as-is, never retried into producing one |
| 6 every evaluation carries its judge model and `judge_rubric.v1` | **Witnessed** on every row and asserted by the probe |
| 7 **one full analysis end-to-end; the quota gate closed with real numbers** | **Witnessed** — see below |

## What was just finished (Step 13 — the results UX, built and tested on mocked data)

**UX (S13-U1…U15):** `features/dates/` — `models.dart` (DateSummary, Evaluation, Clash, Transcript, the rubric weights and the score formula as pure functions), `dates_repository.dart` (the two lazy reads and their providers), `metadata_toggle.dart` (the app-wide switch, persisted per user in `shared_preferences`), `date_checklist.dart` (THE checklist, shared by the progress phase and the results), `transcript_screen.dart` (`/dates/:id?seq=`), `results_screen.dart` (`/analyses/:id/results`), `curves.dart` (the pure `buildCurves` and the `fl_chart` widget). `analysis_screen.dart` gains the `simulating` phase, the `failed` state, and the door to the results on `complete`. `core/notify/` — the app-wide completion banner and the web-only local notification. `core/polling/poller.dart` announces a LIVE finish and gains `kick()` (D-013). Routes `/analyses/:id/results` and `/dates/:id` added.

**Server (S13-B1 and two small contract additions):** `ended_by` on every date in `GET /analyses/{id}/dates` and on `GET /dates/{id}/transcript`, computed by the same `ended_by()` the loop uses; `analysis_id` on the transcript; **`POST /simulate` accepts a `failed` analysis that has candidates and resumes it** (pure `simulate_refusal()` gate, unit-tested), logged `simulation_requested … resumed_after_failure: true, failed_stage, previous_error`; a resumed analysis clears its stale `error` on the way back to `simulating`. S13-B1 (transcript readable while the analysis is still `simulating`) needed no work: the endpoint has no status gate, and Step 11's resume probe already read a 3-message transcript mid-run.

**Design import — NOT done, and why.** The owner asked for the Claude Design file `Ranking & Date Reveal.dc.html` (project `8da35c97-…`). Every route to it failed from this session: `DesignSync` needs `/design-login` from an interactive session; the URL is behind claude.ai sign-in (WebFetch 403, in-app browser lands on the login wall); the Chrome extension was not connected. **The screens were built on the existing Material 3 theme.** Restyling to the design is a follow-up once `/design-login` has been run — the structure (which widgets, which data) will not change, only the look.

### Things worth not re-deciding

- **`ended_by` and `excluded_from_score` come from the server and are never re-derived in the client.** A client with its own idea of "mutual", or of when a date counts, is a client that can disagree with the score it is showing. The server computes both with the same functions the pipeline used. *(The 10-turn rule this originally referred to was removed 2026-09-02; the principle is what survived, and `fixture` was added under it.)*
- **The rubric weights live in the client too (`rubricWeights`), keyed by `rubric_version`, and the composition view RECOMPUTES the score in front of the user** and prints "mismatch" if the arithmetic disagrees with the stored value. Verified on real data: all 5 stored evaluations and 4 candidate means recompute exactly over the wire. A v2 rubric is a second table entry, never an edit.
- **"No score" is not 0.0.** A candidate whose every date was excluded renders "No score — nothing to score" and sorts last. Zero would say "they were terrible together" about an evening that never happened.
- **The transcript viewer builds every row** (a plain scroll view). `?seq=` needs message N to exist before it can scroll to it, and a transcript is at most 19 rows — laziness buys nothing here and costs the anchor.
- **The metadata toggle is in `shared_preferences`, keyed per user id, not in the token store** — sign-out wipes the token store, and a preference is not a session. Storage failure falls back to the in-memory default; never an exception into UI code.
- **The date list refetches when the ONE poller says `progress.updated_at` moved, and never otherwise.** That is how the checklist is live during `simulating` without a second loop (§16), and why results are fetched exactly once on `complete`: the poller has stopped, the key stops changing.
- **The completion banner fires only on a LIVE transition** (`simulating → complete|failed` seen by the poller), never on a cold load of a finished analysis — the user opened it; they know. The OS notification is browser-only this phase, permission asked on the "Start Simulated Dates" tap because browsers require a gesture (named trade in `simulate_date_page.md`).
- **A `failed` analysis with no candidates offers "Start a new analysis", not a retry.** It died in matching; the server refuses `/simulate` for it with a sentence saying so. One WITH candidates offers "Pick up where it stopped", and the copy is true: `ensure_dates` reuses rows, finished dates are no-ops, the judge returns stored evaluations.
- **The poller is `kick()`ed after every `/simulate`** so it polls through the terminal status the row may still report for a moment (D-013). Without it, "the retry button does nothing" was a real, reachable failure that every live witness so far had been fast enough to miss.
- **The satisfaction chart's axis is fixed at 0–100 even though real data mostly sits at 0** (the Step 11 model finding). Rescaling would make a flat evening dramatic; the caption under the chart says what the numbers are, and rows without state are gaps, not zeros.

### Step 13 acceptance criteria — honest status

| AC | Status |
|---|---|
| 1 leave and return: progress reflects real server state | **Built, widget-tested on mocked progress; not witnessed live** — needs a real simulation run (~20 calls) with a signed-in browser. Owed under O-16 |
| 2 date 1 readable while later dates run | **Built and widget-tested** (checklist row opens the transcript under an "Other dates are still running" banner). Server half witnessed in Step 11. Live UI pass owed (O-16) |
| 3 metadata toggle both ways, survives a restart | **Widget-tested both ways** (badges appear/disappear; stored OFF honoured on a cold start; the preference is written under the user's key). Browser restart pass owed (O-16) |
| 4 an incomplete date labeled in viewer AND analytics, with reason | **Widget-tested in both** ("Stopped after message 11 — the AI stopped answering. Scored from a partial date — weighted half."; the viewer footer says "This date stopped early") |
| 5 tapped score shows criteria + weights; arithmetic matches `date_score` | **Widget-tested, and recomputed on REAL data over the wire:** 5/5 evaluations and 4/4 candidate means match exactly |
| 6 scrub to message 14 and tap through lands on message 14 | **Widget-tested** via the chart's tap-through into `/dates/:id?seq=N`, with the anchored bubble outlined. The touch gesture on the chart itself is not driven in a test — browser pass owed (O-16) |
| 7 an event marker corresponds to an actual `environment` row | **Unit-tested** (`buildCurves` produces exactly one marker per environment row, at its seq) |
| 8 a `failed` analysis names the stage; retry visibly RESUMES | **Server half WITNESSED over HTTP:** a finished analysis marked `failed` (constructed, stated plainly) was retried — 202, `resumed_after_failure: true`, back to `complete` in 2 s, **0 `ai_call` lines**. UI half widget-tested (names "during the dates", calls `/simulate`, keeps polling). A genuine mid-date failure resumed through the UI is owed (O-16) |


## What was just finished (Step 14 — chat: selection and the live conversation)

**Server (S14-B1…B11):** migration `0008` (`chat_sessions` with `UNIQUE (analysis_id)`, `chat_messages`, verbatim from `chat.md` §3). `app/schemas/chat_compaction.py` — `chat_compaction.v1`, one field. `app/chat.py` — the pure rules (`fold_plan`, `selection_refusal`, `extend_system_prompt`), `select_match` (pins `analysis_candidates.snapshot_id`, compiles the digest via `DateDigest` with no AI call), `compact_if_needed`, `reply`, `end_session`. `app/routers/chat.py` — `POST /analyses/{id}/select`, `GET /chat/sessions`, `GET /chat/sessions/{id}` (added: the header sheet's payload — labels only), `GET …/messages?after_seq=&limit=`, `POST …/messages`, `POST …/end`. `chat_compaction` slot filled (provisional, same model). `SIMULATED_HISTORY_RULES` is the S14-B6 contract text, in one constant, pinned by tests.

**UX (S14-U1…U9):** `features/chat/` — models, `ChatRepository` (+ `chatSessionsProvider`, `selectionForAnalysisProvider`), `/chat` list, `/chat/:sessionId` on the SHARED widget with `ChatConfig(allowFlagging: false, showMetadata: false)`, the header sheet, the overflow menu (End chat / Improve my profile / Start a new analysis). The results screen grew the `SelectionFooter` (confirm sheet with the two lines; "already chose [name]" visible-disabled after). The shared `ChatView` gained `typingLabel`, `composerEnabled` and `ChatBubble.isError` — parameters, not branches; calibration is unchanged.

### Things worth not re-deciding

- **A failed send rolls the user's message back on the server AND keeps it in the composer on the client.** The plan said "persist the user message, then call" — but the UX keeps the text for a retry, and a retry of a message the server already stored double-posts. Revised inline in `chat.md`; the raw output is logged, so nothing about the failure is lost.
- **The persona is told, every call, that the human was NOT there.** `SIMULATED_HISTORY_RULES` is contract, not tone: "our simulated date", never "remember when", never a detail beyond the digest. The first real reply read the date back as "like watching a recording of yourself" — framed as read, not lived.
- **No chat payload has a `state` field, and a test says so** (`test_no_chat_payload_has_a_state_field` over every response model). The inner state IS stored on `chat_messages.state` — `connection: 1` sat in the row while the wire carried nothing.
- **Selection is refused as STATE in a fixed order**: `already_selected` (409, with the session id in `fields`) beats `analysis_not_complete` (409) beats `not_a_candidate` (404). The client turns the first into "open that chat", never a toast.
- **`fold_plan` is the whole compaction policy.** First fold as the 41st message is about to be written (seqs 1–20), second as the 61st is sent; a compaction commits on its own BEFORE the reply call (§19), so a reply that then fails does not undo it.
- **History loads every page on open.** Chats at friends scale are small; a scroll-up paginator is plumbing that breaks silently. The wire is still paged.
- **D-014: capture ids into plain values before anything that can roll back.** The give-up path read `convo.user_id` after `rollback()` and turned the honest 502 into a 500 on its first forced run.

### Step 14 acceptance criteria — honest status

| AC | Status |
|---|---|
| 1 selection creates exactly one session; a second → 409 rendered as state | **Server WITNESSED** (201 then `already_selected` 409 carrying the session id; `not_a_candidate` 404 for a stranger). UI half widget-tested (the 409 opens the existing chat, no snackbar) |
| 2 first replies reference the dates AS simulations — by reading real replies | **One real reply read** (1 model call): "It's a bit strange reading it back, like watching a recording of yourself" — framed as a transcript read, not a lived memory. One reply is a sample, not a study; more reads are cheap and belong to the browser pass (O-16) |
| 3 raw chat body contains NO `state` — on the wire | **Witnessed on the wire** (reply body and the messages page: 0 matches) and pinned by a test over every response model |
| 4 past 60 messages → compaction; folded range logged; coherent across the fold | **Unit-tested at the boundary, NOT witnessed live — OWED (O-19).** It costs 30+ model calls; the arithmetic, the schema, the log line and the commit-before-reply ordering are all written |
| 5 forced give-up → explicit in-thread "couldn't reply", text survives, retry works | **Server half WITNESSED** after D-014: `502 reply_failed`, the user's message NOT stored (0 rows), `chat_reply_failed` logged with provider/model/outcome/error. UI half widget-tested (notice in-thread, text back in the composer marked "Not sent yet", retry sends) |
| 6 ending moves the session to ended; history readable | **Server WITNESSED** (`ended_at` set, `chat_ended` 409 on a further send, messages still readable). UI widget-tested |
| 7 a new analysis while a chat is active → separate session on selection | **Server half WITNESSED**: `fd018e9d` was selected while `c8e3d56b`'s chat was active and got its own session (two rows, two analyses, one requester); the "start a new analysis from the overflow menu" half is a navigation and is widget-covered by the menu test |
| 8 the shared widget shows no metadata and no flag affordance here, both in calibration | **Chat half widget-tested** (config asserted, no flag icon rendered). Calibration's `allowFlagging: true` was witnessed in Step 8; the side-by-side in one browser session is part of O-16 |


## What was just finished (Step 15 — data hygiene: deletion, demo seeding, the whole pass, the scan)

**Server (S15-B1…B8):** `app/deletion.py` — `USER_ROW_COUNTS` (every table the cascade reaches from `users`, counted for THIS user before anything is deleted), `cascade_tables()` (walks the ORM metadata along `ON DELETE CASCADE`; a unit test asserts every reached table is counted), `delete_account()` (counts → log → cascade → log; the counts are the receipt). `DELETE /me` in `app/routers/me.py`. `app/accounts.py` (`create_user`) and `app/answers.py` (`save_answer`) — the ONE registration path and the ONE upsert path, now shared by `/auth/register`, `PUT /answers/{id}` and demo seeding. `seeds/demo_profiles.yaml` (Maya, Theo, Jonah — five answers each in a voice, `demo-password`). `app/demo.py` (step 2 of the pass: accounts + answers inline, the AI half in a background task after boot). `app/reconcile.py` — steps 2 and 4 added, `run_full_pass()` in the locked order, `inline_demo_pipeline=True` for scripts and probes. Migration `0009` (`analyses.candidate_count`, backfilled) and `removed_candidates` on `GET /analyses/{id}`. `scripts/scan_dead_data.py` (report only). `scripts/run_reconcile.py` runs the whole pass (`--wait` awaits the AI half).

**UX (S15-U1…U3):** `/settings` → Delete my account: two confirms (the second names the cross-user effect: "your simulated dates disappear from your friends' results too"), the receipt dialog listing the server's non-zero counts, sign-out only after it is dismissed. Tombstones from `removed_candidates`: the history row, the analysis reveal, the results ranking. A chat whose session vanished renders "This person removed their account, so this chat is gone with them." with a way back. The Demo chip already rode on every surface the three demo profiles can now appear on.

**Probes:** `probes/probe_deletion.py <victim> <survivor>` (GREEN 17/17; zero model calls) and `probes/probe_demo_seeding.py [email]` (GREEN 12/12; one extraction + one compile + one embedding). Both call `setup_logging()` — see D-015 for why that is not optional.

**The dead-code pass (S15-B8)** this session is what the linters report — `ruff` (F401/F841 and friends) and `flutter analyze` both clean. No dedicated tool was added; that is stated rather than dressed up.

### Things worth not re-deciding

- **The cascade graph is walked, not listed.** `test_deletion_graph.py` derives the reachable set from `Base.metadata` and pins it to the sixteen tables named there; a seventeenth table that hangs off `users` fails the test until it is counted. `persona_snapshots` is referenced WITHOUT cascade by four tables, and the test also proves every one of those four is itself cascade-reachable from `users` — that is why a deletion never trips the FK.
- **Counts before the cascade, and the receipt IS the counts** (§19). The probe hand-counts six tables with its own SQL and every one matched. `date_messages: 41` is a number nobody could have recovered afterwards.
- **`analyses.candidate_count` exists because `pool_status` cannot tell 1 from 2.** Without it a survivor's three-person analysis silently becomes a two-person one. `removed_candidates` is computed from it; the UI renders the sentence from ONE function so three screens cannot phrase it three ways.
- **Demo profiles are accounts, full stop.** `create_user` and `save_answer` are the same functions the endpoints call; `is_demo=True` is the only difference and it rides on every payload (`/me`, candidates, chat match). The probe reads `source_answer_ids` and `extracted_by` straight off the rebuilt rows.
- **The AI half of seeding is a background task at boot and an awaited call everywhere else.** Boot must not hold `/health` hostage for three profiles' worth of model calls; a probe that launches the background task and then runs the work again is racing the extraction lock (D-015). `run_full_pass(app, inline_demo_pipeline=True)` is the scripted form.
- **`extract_once` returning `None` is a state — `deferred` — and the demo pipeline stops there.** Compiling would build a persona from nothing; the compiler refuses, but the pipeline should never have asked.
- **"Queued for re-embedding" is a blanked `traits_hash`.** `refresh_embeddings` already compares stored hash to live hash before any matching run, so the mismatched row is regenerated by the pinned model before it is ever compared. No new queue, no new column.
- **A `failed` analysis is NOT relaunched at boot.** It waits for the user's retry (S13-U5); relaunching it would start work nobody asked for.
- **Editing `app/models.py` before running the migration crashes the reloading API at startup** (trap 26). It did, this session: `column analyses.candidate_count does not exist`, and `/health` was dead until `docker compose restart api` after `alembic upgrade head`.

### Step 15 acceptance criteria — all eight witnessed

| AC | Status |
|---|---|
| 1 both probes green on the running stack | **Witnessed** — `probe_deletion.py` GREEN 17/17; `probe_demo_seeding.py` GREEN 12/12 (after D-015) |
| 2 counts logged before the cascade, returned, matching a hand count | **Witnessed** — `account_deletion_counts` precedes `account_deleted` in the log; the receipt's six hand-counted tables matched exactly (answers 5, traits 9, snapshots 1, dates-as-candidate 2, chat-sessions-as-match 1, candidate rows 1); 41 date messages and an evaluation went with them |
| 3 survivor renders a tombstone; chat list explains; no crash, no 404 screen | **Server witnessed** — `removed_candidates: 1` on the survivor's analysis, the victim absent from its candidates and dates, the session gone from the list, and the direct GET a 404 carrying "That chat doesn't exist." UI half widget-tested (history row, reveal, results, the vanished-chat screen). Browser pass owed (O-16) |
| 4 global questions survive every deletion | **Witnessed** — 35 before, 35 after |
| 5 a demo user's traits carry real provenance and their snapshot is `ready`, labeled in every payload | **Witnessed** — 10 rebuilt traits, every one with `source_answer_ids` and `extracted_by = openrouter/dots-3-note-preview`, snapshot v5 `ready`, two embeddings from `google/gemini-embedding-001`, `is_demo: true` on `/me` |
| 6 a mismatched `embedding_model` is logged loudly and queued, never silently compared | **Witnessed** — a planted `google/text-embedding-004` on Theo's identity vector: `embedding_model_mismatch` at ERROR naming user, kind, stored and expected model; `traits_hash` blanked; `reconcile_embeddings mismatched: 1`. Restored afterwards; the next pass logged the no-op |
| 7 reconciliation on a healthy database is a no-op with a line saying so — all four steps | **Witnessed** on the boot after the probes: `reconcile_questions_noop`, `reconcile_demo_accounts_noop`, `reconcile_demo_pipeline_noop`, `reconcile_analyses_noop`, `reconcile_embeddings_noop`, `reconcile_pass_complete` |
| 8 `scan_dead_data.py` reports without deleting | **Witnessed** — 6 items (1 failed snapshot, 2 snapshots stuck `compiling` — left by processes this session's reloads killed mid-call —, 3 failed analyses from the Step 9/11 quota days), nothing deleted |


## What was just finished (Step 16 — the sweep, as far as it goes without a human)

Nothing new was designed. Two audit scripts were added because §14 says a promise must be greppable and §6 says a claim must match its evidence: `scripts/check_docs_drift.py` (every endpoint named in a module plan's table, against the live `/openapi.json`) and `scripts/audit_wire_privacy.py <email>` (the five §6 rules against RAW response bodies). Both are re-runnable in seconds and cost no model calls.

### S16-B1 — the probe set, on THIS volume (not a cold stack — see O-21)

| Probe | Verdict | When | Cost |
|---|---|---|---|
| `probe_structured_guard.py` | GREEN | Step 2 (earlier today) | a few forced calls |
| `probe_pool_expansion.py` | **GREEN — re-run this session** | now | 0 |
| `probe_answer_edit.py` | GREEN | Step 6/9 (earlier today) | several extractions |
| `probe_onboarding.py` | GREEN 16/16 | Step 7 (earlier today) | 2 |
| `probe_matching_filters.py` | **not GREEN on clean data — O-8** | — | ~10 |
| `probe_simulation_resume.py` | GREEN 23/23 | Step 11 (earlier today) | a full analysis |
| `probe_judge.py` | **GREEN 9/9 — re-run this session** (92.75 recomputed; re-judge delta 2.75) | now | 1 |
| `probe_deletion.py` | **GREEN 17/17 — this session** | Step 15 | 0 |
| `probe_demo_seeding.py` | **GREEN 12/12 — this session** | Step 15 | 3 |
| `probe_candidate_rejection.py <email>` | **GREEN 15/15 — 2026-09-02** | Step 17 | **0** |

**Why not a cold stack.** `docker compose down -v` destroys the volume that holds the owner's own account, the twelve real transcripts Steps 13–14 were built against, and the probe accounts named in this file. That is the owner's decision to make, not a session's (O-21). Every probe above is written to be runnable against the cold stack when it is made.

### S16-B2 — the §8 flag sweep: each observed behaving both ways

| Flag / gate | Off / in one state | On / in the other | Where recorded |
|---|---|---|---|
| `opt_in` | a candidate removed from someone's pool | restored to it | Step 9, O-1 closed |
| `is_demo` | `false` on every real user's payload | `true` on `/me`, candidates and chat matches for the three demo profiles — checked on raw bodies by the audit | Step 15; `audit_wire_privacy.py` rule 4 |
| persona-snapshot gate | a fresh user is `simulatable: false` and calibration refuses `no_persona_yet` | a ready user is matched | Step 7 AC4; Step 9 AC5 |
| one-active-analysis 409 | second `POST /analyses` → 409 `analysis_in_progress` | none active → 202 | Step 9 AC7 |
| event cap (3) and no-consecutive | `reason: event_cap_reached` on every roll after the third; `no_consecutive_events` on the roll after each | events fired at rolls 0.0779, 0.0476, 0.1336 | Step 11 AC3; reconstructed below |
| `pool_exhausted` | batches 1–6 served | batch 7 the exact payload | `probe_pool_expansion.py`, re-run today |
| transcript metadata toggle | badges gone, preference stored `false`, honoured on a cold start | badges present by default | **widget-tested both ways** (Step 13 AC3); the browser flip is part of O-16 |
| `/simulate` on `failed` | refused when the failure was in matching (409, "start a new one") | accepted and RESUMED when candidates exist | Step 13 AC8 (server), `simulate_refusal()` tests |
| chat selection gate | `already_selected` 409, `not_a_candidate` 404 | `complete` + candidate → 201 | Step 14 AC1 |
| embedding-model consistency | `reconcile_embeddings_noop` on a healthy boot | a planted mismatch logged at ERROR and marked stale | Step 15 AC6 |

### S16-B3 — the §17 give-up sweep: each observed firing once

| Give-up | Observed | Where |
|---|---|---|
| 3 validation-repair attempts → typed error | `outcome: gave_up` with the raw output attached, mid-date (a whitespace loop) | Step 11 AC5, unforced |
| 3 attempts per simulation turn → date `incomplete`, pipeline moves on | `failed_at_seq: 21`, then date 2 started | Step 11 AC5 |
| one queued follow-up extraction, never a pile-up | `[(200,'done'), (200,'queued')]`, one follow-up | Step 6 AC6; 4 unit tests |
| one active analysis per user | the 409 | Step 9 AC7 |
| rate-limit backoff (20 s, 30 s) then a typed error | google embedding cap, Step 11 | PICKUP quota section |
| chat reply give-up → 502, user message NOT stored | forced with a nonexistent model | Step 14 AC5 (after D-014) |
| demo pipeline: one attempt per boot, `deferred` on a held lock | `demo_pipeline_failed … retried on the next boot`; `deferred` path added after D-015 | Step 15 |
| poller `kick()` window (30 s) then stop | **unit-tested**, not observed live | D-013 |

### S16-B4 — the §14 greppability audit, the four named accretion risks

| Promise | Code |
|---|---|
| answer-edit staleness cascade (edit → traits → hash → embeddings → snapshot banner) | `app/answers.py` (`save_answer`, logs the traits sourced from the edited answer) → `app/extraction.py` → `app/traits_hash.py` → `app/matching.py:190` (`live_hash` vs stored) → `app/persona.py:431` (`is_stale`) → `ux/lib/features/traits/profile_screen.dart` header |
| incomplete-date judging policy (**every date with a transcript is judged**; 0.5 weight for a partial) | `app/judging.py` — `JUDGEABLE_MIN_TURNS = 1` (moved here from `app/simulation.py` on 2026-09-02, where it was 10), `is_judgeable`, `PARTIAL_WEIGHT = 0.5`, `candidate_score`; shipped as `excluded_from_score` (now true only for a date nobody spoke on) plus the judge's `confidence` |
| no-consecutive-events rule | `app/simulation.py` `should_inject_event` — `reason: no_consecutive_events` in every roll line; 29 unit tests |
| survivor-side tombstones after a deletion | `app/routers/analyses.py:128` (`candidate_count` → `removed_candidates`), `ux/lib/features/home/home_screen.dart` (`removedCandidatesSentence`, used by three screens), `ux/lib/features/chat/chat_screen.dart:239` (the vanished chat) |

Every module plan's "Locked by this document" list was walked while its step was built; the inline "Built 2026-09-01" notes in each plan are the trail.

### S16-B5 — the §7 log reconstruction test

**Date `f5a1277d` (analysis `c8e3d56b`), from `docker compose logs api` alone, no debugger, no database:** started `running`; the first roll (0.7516) logged `no_messages_yet`; turn 1 by `user_agent`; roll 0.0779 HIT before seq 2 ("They start by assessing the bike's condition…"); the next roll logged `no_consecutive_events`; turns 3–5; roll 0.0476 HIT before seq 6 ("A stubborn bolt…"); `no_consecutive_events` again; turns 7–12 with rolls 0.3179–0.9913 all `roll_missed`; roll 0.1336 HIT before seq 13 ("Dan recalls a detail…"); from seq 15 on every roll logged `event_cap_reached`; turns 14–19; `date_finished status=complete ended_by=cap messages=19 events=3` — 16 agent turns plus 3 events, the derived maximum; `date_judged criteria={90, 90, 95, 0} score=92.75`; `candidate_scored final_score=92.75 date_scores=[92.75] dates_excluded=0`. **Why it ended:** the turn cap. **Why it scored 92.75:** 0.3×90 + 0.3×90 + 0.25×95 + 0.15×(100−0). Every number is in a line.

**Date `4d0b082c` (analysis `8ae03783`):** `date_not_judged … messages: 11, turns: 9, threshold: 10, counted: "agent turns, not rows", reason: "too few turns to be a date"`, and the candidate's `candidate_scored … dates_excluded: 1`. **Why it was not scored:** nine turns under a threshold of ten, with the unit named.

**Date `8fc67efa` (analysis `fd018e9d`):** 27 turn lines, `date_finished ended_by=cap messages=30 events=3` (the old 30-row cap, before the revision), judged 89.4, `candidate_scored final_score=89.4`.

Three dates, three different outcomes, each reconstructed. The log retained by the container reaches back only to its last recreation, so older dates are reconstructible only from `PICKUP` — trap 28.

### S16-B6 / B7 / B8 / B11

- **`/docs` drift: ZERO.** 29 endpoints promised across six plans, all served (Step 17's reject endpoint is named in `candidate_matching.md`, not additive); 5 additive endpoints not named in a table (`GET /health`, `/calibration/flags/count`, `/calibration/sessions/{id}/messages`, `/profile/extract/status`, `POST /traits/{id}/confirm`) — allowed by `communication_protocol.md` §7.
- **Wire privacy: 10/10** on 27 raw bodies of an account with eight transcripts and two chats — no `system_prompt`, no trait `description`/`answer_text` in analysis payloads, no `state` in any chat body, `is_demo` everywhere a person is rendered, no stranger's user id, and `state`/`connection`/`satisfaction` present on transcripts and NOWHERE else.
- **English-only:** no non-English letters in prompts, UI copy, seeds or routing (the only non-ASCII in the seeds is two Romanian city names, which are names).
- **Dead data:** `scan_dead_data.py` reports 6 items — 1 failed snapshot (a forced failure from Step 7's AC5), 2 snapshots stuck `compiling` (killed by this session's reloads mid-call), 3 failed analyses (Step 9/11 quota days). Nothing deleted; the decision is the owner's.

### S16-B13 — the §6 reckoning

| Claim | Definition-of-done points true |
|---|---|
| Steps 1–8, 10, 12, 15 | 1–10: written, tested, logged, witnessed on the stack on a second run, probed, failure modes observed, trades named, defects filed, PICKUP current, reported in these words |
| Step 9 (matching) | 1, 2, 3, 7, 8, 9, 10; **4/5/6 owed** — the one GREEN run was polluted; a clean `probe_matching_filters.py` run is O-8 |
| Step 11 (simulation) | 1–10 for the central claim (resume witnessed four times); **AC6 and AC7 owed by owner decision** (O-13, O-14) |
| Step 13 (results UX) | 1, 2, 3, 7, 8, 9, 10; server halves witnessed over HTTP; **the signed-in browser pass owed** (O-16) |
| Step 14 (chat) | 1, 2, 3, 5 (server), 7, 8, 9, 10; selection, reply, give-up and end witnessed over HTTP; **compaction live owed** (O-19); browser pass owed (O-16) |
| Step 16 | run as far as it goes; **the cold-stack sweep owed** (O-21) |
| Both gates | closed with numbers (fidelity: 1 clear failure in 6; quota: 59 calls, 7 m 13 s, zero retries) |

**"Works" is claimed for:** registration, the questionnaire and its resume, extraction, persona compilation, calibration, the dashboard, the reveal, a simulated date that resumes after a kill, judging and scoring, the results and transcript payloads, chat selection/reply/end, account deletion with its receipt, demo seeding, and the four-step reconciliation pass. **"Built, not yet witnessed" is the honest phrase for:** the Step 13–15 screens in a signed-in browser, live chat compaction, the clean matching run, the two deferred Step 11 criteria, and the whole suite against a cold stack.


## What Step 11/12 owes after 2026-09-02

**Two owner decisions were built today and NEITHER has been witnessed live.** Everything below is green in unit tests and in the database; not one model call has been made under the new design. Do not describe it as done in front of anyone until the run in "The witness this owes" has happened.

**What changed, mechanically:**

- **One scenario per ANALYSIS, drawn at random in code.** `app/date_archetypes.py` is a new catalogue of 16 written-down archetypes (cinema, night market, hill walk, arcade bar, museum lates, cooking class, record shop, crazy golf, aquarium, pub quiz, flea market, ice rink, glasshouse, karaoke booth, pier, escape room). `ensure_analysis_scenarios` draws one, excluding the last `RECENT_ARCHETYPES_AVOIDED = 3` that user has had, generates it in ONE call that receives no names, no ages, no interests and no traits, stores it on `analyses.scenarios` (migration `0011`), and `ensure_dates` copies it onto every candidate's date row.
- **`date_scenarios.v3`.** `anchored_in_interest` is gone; `archetype` replaced it. The model echoes the drawn key back and `generate_scenarios` verifies it against what was actually drawn, logging `archetype_repaired` if it does not match — the no-repeat rule matches on that key, so a paraphrase would break it silently.
- **`build_scenario_request` takes archetypes and nothing else.** `_interest_traits`, `_interest_block` and the empty-intersection fallback are deleted. There is no intersection left to be empty.
- **The ≥10-turn judging threshold is gone.** `JUDGEABLE_MIN_TURNS` moved from `app/simulation.py` (where it was 10) to `app/judging.py` (where it is 1) and now means "somebody spoke". `is_judgeable` returns True for any `complete` or `incomplete` date with at least one agent turn.
- **`judge_rubric.v2`.** Same four criteria, same four weights — so no stored score is re-based — plus `confidence` (0–100) and `evidence_note`, and prompt text telling the judge to scale what it CLAIMS to what it saw, to score a criterion near the middle rather than low when it never had a chance to appear, and never to extrapolate. `build_judge_request` states the turn count and which of three depth bands it falls in.
- **The wire.** `GET /analyses/{id}/dates` gains a top-level `fixture` object (`setting_name`, `archetype`, `dates_per_candidate`; null on pre-2026-09-02 analyses) and each date carries `archetype` instead of `anchored_in_interest`. Evaluations carry `confidence` and `evidence_note`, both nullable and null on every `judge_rubric.v1` row.
- **The screen.** The masthead prints the fixture and says "every candidate went here, so these scores compare" — and on an older analysis says "a different one per candidate", which is what was actually true of it. Each judged date shows a confidence line (band, value, turns spoken, and the judge's note). "Not scored — too short to judge" is gone; the only remaining not-scored copy is "nothing was said".

**Backward compatibility, deliberate and load-bearing:** no backfill was attempted on either column. Analyses that ran before today genuinely had no shared fixture, and v1 evaluations were never asked for a confidence — writing values into either would be inventing history. Both render as absence.

**One live consequence, handled rather than hidden.** Dates that the old rule excluded were never judged, and removing the rule made them *judgeable* without retroactively judging them — they now arrive as "finished, not excluded, no evaluation". The old card would have printed "Scored from a partial date — weighted half" over a date with no score at all. There is a `Not yet scored` branch for exactly this, saying what happened and that re-running the analysis will score it, with a test that fails if the misleading branch ever catches them again. **No retroactive judge pass was run**: it would spend a model call per stale date on data the owner has not asked to be re-scored.

**The witness this owes (O-23).** One analysis end-to-end against real providers, ~20 calls, checking four things no unit test can:

1. Three candidates' dates all name the SAME `setting_name`, and `analysis_scenarios_drawn` logs one archetype for the analysis rather than one per candidate.
2. A second analysis for the same user draws a DIFFERENT archetype (the log line carries `avoided=[…]`).
3. The generated setting names nobody and assumes nothing about who is coming — read the actual `description` and check it, because this is a prompt instruction and prompt instructions are the thing that quietly does not hold.
4. A thin date is judged with a low `confidence` rather than excluded. Constructing one is the same problem it always was (the timing window is seconds wide) — truncating a real transcript in the database and re-running the judge pass is the honest way, and it exercises the real server path.

`probes/probe_judge.py` already checks 1 and 4 against whatever is stored, and costs one judging call.

---

## What is next

**All sixteen steps are built. What remains is witnessing that needs the owner:** O-8 (one clean matching run, ~10 calls), O-16/O-20 (the Steps 13–15 screens signed in — the trap-3d recipe with `probe-sim-alice-4aa682e1@probe.dev` / `probe-password`, or the owner's own account), O-19 (a long chat, 30+ calls), O-21 (the nine probes against a cold stack — destroys this volume; take a `pg_dump` first if the transcripts matter), and O-3 (an analysis from a real account against the three demo profiles — the product's first real run, ~20 calls, and the most informative thing left to do).

**Before the Step 13 browser pass (O-16):** run `flutter build web` in `ux/`, `python serve_build.py 5000`, sign in as `probe-sim-alice-4aa682e1@probe.dev` / `probe-password` (owns five complete analyses, one with a partial and an excluded date: `2b83aeab`), and walk the eight ACs above. It is the same trap-3d recipe as Steps 8–11.

**Owed witnesses.** O-13 and O-14 are Step 11's and the owner has deliberately deferred both — do not spend model calls clearing them. **O-8 (Step 9's clean `probe_matching_filters.py` run) is genuinely open.** O-9 (Step 10's `no_candidates` screen) is nearly free. **O-16 (Step 13 in a signed-in browser) is the new one** and needs no model calls for seven of its eight checks.

**Settled 2026-09-01 (owner decision):** the `trait_extraction` pin on `dots-3-note-preview` is intended, and the apparent conflict with D-008 is not one. **Model pins are testing config and they move with what is available and affordable** — D-008 records why nemotron was right on the day it was written, not a promise that the pin is frozen. What survives from D-008 is the mechanism: one OpenRouter id is several upstream providers, so a task that starts 400ing gets ITS line moved, not every line.

**Every test and probe account is opted OUT of the candidate pool, and that is now the standing default** (owner decision, 2026-09-01): a small pool keeps probe runs cheap, and D-009 is the story of what stale opted-in probe users do to a matching run. `bob@dating-test.dev` included. **Opt in only what a specific witness needs, and opt it back out afterwards** — `probe_simulation_resume.py` now does that for its own two users automatically.

**Demo accounts (password `demo-password`, from `seeds/demo_profiles.yaml`, all opted IN by design — they are the pool). TEN of them since 2026-09-01:** `maya`, `theo`, `jonah`, `ana`, `radu`, `ileana`, `sam`, `dana`, `victor`, `petra`, all `@dating-demo.dev`. **All ten are fully pipelined since 2026-09-02** (traits, a `ready` snapshot and two vectors each — O-22 closed), so all ten are matchable. Reconciliation recreates any of them that goes missing, through the real pipeline.

Test accounts on the current volume (password `hunter2222`):

Useful facts for later steps, learned witnessing Step 2:
- `gemini-3.6-flash` is a **thinking model** — a tight `max_tokens` gets eaten by reasoning and yields `MAX_TOKENS` with no text. Give generous budgets.
- Free OpenRouter models 429 by congestion, per model. `nvidia/nemotron-3.5-lightning:free` worked; `z-ai/glm-5.2:free` was saturated (and its content includes visible reasoning text). The `free-model-of-choice` slots remain unfilled — these are probe arguments, not choices.
- The google embedding free tier has a low per-minute cap — batch embed calls, don't loop them.

### The knobs, and what moves with them

Both caps are single integers and both are meant to be turned. Written down because "is this configurable or is it baked in" is the question, and the answer differs between them:

| Knob | Where | What follows it automatically |
|---|---|---|
| **Turn cap** | `TURN_CAP = 16` in `app/simulation.py` | `MAX_MESSAGES_PER_DATE` (= `TURN_CAP + MAX_EVENTS_PER_DATE`). Nothing else reads the value. **A one-line change, genuinely.** |
| **Dates per candidate** | `SETTINGS_PER_ANALYSIS = 1` in `app/schemas/date_scenarios.py` | `DATES_PER_CANDIDATE` and, since 2026-09-01, `MAX_DATES_PER_ANALYSIS` (= `MAX_CANDIDATES × DATES_PER_CANDIDATE`). The scenario prompt already says "produce exactly N setting(s)" with the singular handled, and `generate_scenarios` returns a list because N is a knob |
| **How often a setting can repeat** | `RECENT_ARCHETYPES_AVOIDED = 3` in `app/date_archetypes.py` | Nothing. It is advisory: if it ever reached the catalogue size every draw would hit the exhausted-pool fallback and the no-repeat rule would stop working silently, which is why a test asserts it stays below `len(ARCHETYPES)` |

**RENAMED 2026-09-02:** the constant was `SETTINGS_PER_CANDIDATE`. Under the shared fixture that name states something false — one setting is generated for the whole ANALYSIS — but the derivation is still exactly true: N fixtures means every candidate goes on N dates, one per fixture, so `analyses.scenarios` is an ARRAY and each date's `ordinal` indexes it.

**Nothing about the structure restricts it to one date.** The plural path is intact — `settings[:DATES_PER_CANDIDATE]`, ordinals from `enumerate(..., start=1)`, one `dates` row per setting, and `ensure_analysis_scenarios` draws N distinct archetypes without replacement.

Two things do NOT follow the dates-per-candidate knob and need a human:

1. **The JSON schema version.** `minItems`/`maxItems` read the constant, so changing it changes the schema — and the registry's rule is a version bump, not an edit in place. v1→v2 was that bump when it went 2→1; v2→v3 was the 2026-09-02 contract change (`anchored_in_interest` out, `archetype` in).
2. ~~**The empty-intersection fallback prompt.**~~ **Gone 2026-09-02** — there is no fallback and no interests in the call. What replaced it as the human-judgement part is **the catalogue itself**: 16 archetypes, each with a premise that has to contain something two strangers can disagree about. A premise that does not is a fixture where three candidates produce three identical transcripts, and no constant will tell you that has happened.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Native desktop witness (O-4) | **Owner:** enable Windows Developer Mode, then `flutter run -d windows` in `ux\` | Unchanged from last session |
| OpenRouter `free-model-of-choice` slots | **Owner decision, deferred by design** — EXCEPT `dispute_followups`, filled 2026-09-01 with `nvidia/nemotron-3.5-lightning:free` so Step 6 AC4 could be witnessed. Four slots remain unfilled | Probe takes a model as an argument precisely so the slots stay unfilled |
| Paid-balance question | **Owner**, and the numbers are now in | **Decisive, and much improved by the two 2026-09-01 revisions.** A full analysis is now **~54 calls floor, ~63 observed** (was ~177 at two 30-message dates). On the free tier as documented (50/day) the core loop still cannot run ONCE. 10 credits raises the allowance to 1000/day ≈ **16 analyses a day**, up from 5. See the spreadsheet below |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Unchanged (decision log #11) |
| ~~Claude Design import (O-18)~~ | **UNBLOCKED 2026-09-01** — the canvas was exported to disk as `Matchmaking app UI design/Ranking & Date Reveal.dc.html` with its `_ds/modernist-*` token sheet, and read from there. No `/design-login` and no `DesignSync` needed | If a FUTURE canvas is only online, the old blocker returns: `/design-login` from an interactive session, or export the `.dc.html` + `_ds/` folder next to the repo again |

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
12. **An all-`keep` extraction run leaves everything fresh** (A5.1); **the date cap is 16 AGENT TURNS and does NOT count environment rows** (§18 — REVISED 2026-09-01; it was a 30-message cap that counted them, and §18's own example said so. One turn is one model call; an event costs none, so charging events against the cap made the spend a distribution rather than a budget).
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
20. **`flutter pub add <package>` prints "Building with plugins requires symlink support / enable Developer Mode" on this machine and looks like a failure. It is not** — the pubspec and lockfile are updated, and a plain `flutter pub get` immediately after succeeds; web builds and tests are unaffected. The symlink step is for the Windows desktop target (O-4).
21. **The UI cannot be signed into by an automated session** (the password field is off-limits to the assistant's browser tools). API-level witnesses go through `curl` with the probe accounts; anything that must be seen signed-in in a browser is the owner's, or a session with a human at the keyboard. This is why O-16 exists.
23. **After ANY change to `pubspec.yaml`, run `flutter clean` before `flutter run -d chrome`.** Adding `google_fonts` mid-session (2026-09-01) left the DDC dev-compiler holding an incremental module graph from before the dependency set changed, and the run died with a wall of errors in files nobody had touched — `models.freezed.dart: Couldn't find constructor 'JsonKey'`, `the getter 'freezed' isn't defined` (both names come from `freezed_annotation`) — then `Unsupported invalid type InvalidType` and **“The Dart compiler exited unexpectedly”**. It reads like the generated code is broken. It is not: `flutter analyze` was clean, 29 widget tests were green, and `flutter build web` (dart2js, a different pipeline) compiled the same source. The cure is `flutter clean` then `flutter pub get` — note trap 20: that first `pub get` prints the Developer-Mode symlink message and exits non-zero, and the second one says “Got dependencies!”. Verified after the fix: `flutter run -d chrome` compiles and links to the debug service, and the release build renders with Archivo actually fetched (`fonts.gstatic.com/s/a/684bc629…ttf` in the page's resource timings).
25. **`dots-3-note-preview` can return empty content with `finish=length` on trait extraction, and the retry costs two minutes.** Seen 2026-09-02 re-extracting a full five-answer baseline: attempt 1 came back empty (`ai_call_retry … openrouter returned empty content (finish=length)`), attempt 2 succeeded, total `latency_ms: 126637`. It self-heals — but any HTTP client calling `POST /profile/extract` needs a read timeout well above two minutes, because that endpoint runs the extraction INLINE and returns `done`. A 120s timeout kills the client while the server carries on and finishes the work.
26. **Anything a compiled prompt STATES about a person can go stale, and `traits_hash` will not notice** (D-017). The persona prompt asserts name, age, gender, interested-in and city in its `WHO YOU ARE` block and its opening sentence. Staleness compared traits only, so a rename left every agent using the old name silently. There is now a free repair (`refresh_identity`, no model call, new immutable version) on `PATCH /me` and on every boot — but **the seam it cuts on is the literal heading `WHO YOU ARE`**, kept as `persona.FACTS_HEADING`. Move or reword that heading and the repair stops working; `tests/test_identity_refresh.py` builds a real prompt and will fail loudly if you do.
27. **A widget test that builds its own router cannot see the router** (D-018). Thirty-five green tests coexisted with a `/profile` nobody could navigate away from, because every test wired up a `GoRouter` with just the routes it needed. `test/step18_navigation_test.dart` drives `routerProvider` itself for that reason — when you add a screen, add it to a branch there too, or the shell will not be exercised for it.
28. **`MaterialApp.builder` sits ABOVE the router, so `GoRouter.of(context)` throws there** (D-019). The completion banner's “See results” button looked up the router from the ScaffoldMessenger's context, threw `No GoRouter found in context` inside `onPressed`, and so neither navigated nor let `SnackBarAction` dismiss the banner — the user had to reload the page. Anything in that position must be HANDED the router. And: a test that finds a button should press it; this one had been asserted visible since Step 13 and never tapped.
29. **Audit `MePatch`'s fields against the rows on `/settings` whenever either changes** (D-020). `interested_in` and `gender` were patchable from Step 4 and editable in the UI from nowhere — so the field the mutual matching filter turns on could be set once, at registration, and never again. Nothing misbehaved; the app was missing a door. The check is mechanical: every field the form collects and every field the funnel filters on needs an answer to “and where does a person change it later?”
24. **The demo pool cannot match an 18-year-old, and only one demo profile is nonbinary.** Every profile in `seeds/demo_profiles.yaml` has an `age_pref_min` of 24 or higher (Ileana/Jonah 24, Sam 25, Ana 26, Maya/Petra 27, Theo 28, Radu 30, Dana 32), and matching's age rule is MUTUAL — `me.age BETWEEN g.age_pref_min AND g.age_pref_max` as well as the reverse. So a legitimate 18-year-old user (the youngest the A1 date picker allows) funnels to ZERO candidates no matter what they are interested in, and reads it as “the app found nobody”. Found 2026-09-02 on a real account (woman, 18, interested in nonbinary): Sam is the only mutual-gender fit and Sam's band starts at 25. **Not a bug in the funnel — a gap in the fixture**, and worth closing with a profile or two whose band starts at 18 before anyone demos the product to a young user.
22. **A `failed` analysis is resumable only if it has candidates.** `simulate_refusal()` in `app/routers/simulation.py` is the gate; the UI mirrors it (`candidates.isEmpty` → "Start a new analysis"). Reconciliation still relaunches only `matching`/`simulating` on boot — a `failed` one waits for the user's retry, on purpose.
23. **Read what a failure path will log BEFORE the thing that can fail** (D-014). On the request session, `rollback()` expires every loaded row and the next attribute read from async code raises `MissingGreenlet` — inside your `except`, which turns an honest error envelope into a 500 and swallows the log line. Capture ids into locals first.
24. **Forcing a give-up is: edit the slot in `config/ai.yaml` to `there-is/no-such-model:free`, `docker compose restart api`, send, then restore and restart.** The 400 is immediate and costs no quota. Every Step 14 give-up was witnessed this way; it is the cheapest witness in the project.
25. **A probe must call `setup_logging()` or the §7 lines go nowhere** (D-015). Two RED runs of `probe_demo_seeding.py` were spent reading PASS/FAIL lines that could not say why, while the `extraction_queued` line that named the race was being written to an unconfigured logger.
26. **Edit `app/models.py` and run `alembic upgrade head` in the same breath.** uvicorn reloads on the save, the ORM asks for the new column, Postgres does not have it, and startup fails — `/health` then answers nothing until `docker compose restart api`. The container's own start command migrates before it serves; a reload does not.
27. **Never launch the demo pipeline in the background and then run it again inline** — that is a race against the per-user extraction lock (D-015). `run_full_pass(app, inline_demo_pipeline=True)` is the scripted form; the background form is boot's alone.
28. **`docker compose logs api` reaches back only to the container's last recreation.** A `restart` keeps the log; `up -d` after a Dockerfile change, or `down`, starts it over. The §7 reconstruction test could be run on three dates this session because the container had lived through them; anything older is reconstructible only from this file. If log history matters, ship the JSON lines somewhere before recreating the container.

## Owed measurements (§4)

| # | Owed | Incurred at | Closed by | Status |
|---|---|---|---|---|
| O-3 | Matching vs properly seeded demo profiles | Step 9 | Step 15 | **HALF WITNESSED 2026-09-02.** The owner's own account (`antoniagoriuc@gmial.com`) was re-pointed through the real endpoints — `PATCH /me` (interested_in `{man,woman}`, birth date to age 30, band 24–45), five `PUT /answers/{id}` edits, `POST /profile/extract` (retracted 5, added 10, hash `21c8495cc3b2`→`67dd2aa80d68`), auto-compiled persona v2, then `POST /analyses`. Result: **`matched`, analysis `d1699bb7`, funnel `opt_in 13 → gender 7 → age 7 → snapshot 7 → embedding 7 → top 3`** — Theo 0.660, Victor 0.658, Dan 0.655. **The dates have NOT been simulated** (≈54 calls); that half is still owed. Note: `shared_interests` empty for all three (D-009), and one candidate (`Dan`) is a leftover PROBE account, not a demo profile — probe users are opted in and sit in the real pool |
| O-4 | Native (Windows) run rendering `/health` | Step 1, 2026-09-01 | Owner: Developer Mode + `flutter run -d windows` | **Owed** |
| O-5 | Step 8 AC2/AC3 UI paths not yet clicked: the optimistic-update ROLLBACK on a forced server error, and the dispute deep-link through to answering the generated question | Step 8, **2026-09-01** | A browser pass with the API forced to fail | **Owed** |
| O-6 | Step 8 AC4's stale→fresh flip: the header was witnessed in its `failed` state but not observed going "Profile changed" → rebuild → "up to date" | Step 8, **2026-09-01** | A browser pass after an answer edit | **Owed** |
| O-7 | The fidelity gate re-run **by the owner on the owner's own account**. The gate asks you to count lines *you* would never say; this session could only assess against the account's written answers | Step 8, **2026-09-01** | Owner | **Owed** |
| O-8 | Step 9's end-to-end witness: ONE clean `probe_matching_filters.py` run from an empty probe pool. The only GREEN run this session was polluted (concurrent runs sharing an output file; stale probe users in the pool; `shared_interests` vacuous under D-009) | Step 9, **2026-09-01** | A single clean run after the OpenRouter daily cap resets (2026-09-02 00:00 UTC) | **Owed** |
| O-9 | Step 10's `no_candidates` screen and the remaining empty states rendered in a browser. The code paths exist and `partial` was witnessed; the empty pool was not reproduced this session | Step 10, **2026-09-01** | Toggle the only candidate's `opt_in` off and re-run | **Owed** |
| ~~O-13~~ | ~~Step 11 AC6: the empty-intersection fallback observed live~~ | Step 11, **2026-09-01** | — | **Void 2026-09-02.** The fallback no longer exists: the scenario is drawn from a catalogue and reads no interests, so there is no intersection to be empty. Never spent a model call, and now never will. Its successor is **O-23** — see "What Step 11/12 owes after 2026-09-02" |
| O-23 | The shared fixture and the removed judging threshold, live: three candidates on the same `setting_name`; a second analysis drawing a different archetype; the generated setting naming nobody; a thin date judged with a low `confidence` rather than excluded | 2026-09-02 | One analysis end-to-end against real providers, ~20 calls; `probes/probe_judge.py` covers two of the four for one judging call | **Owed.** Unit tests are green on every checkable part; not one model call has been made under the new design |
| O-14 | Step 11 AC7: the global semaphore of 2 observed limiting three queued analyses. `simulation_slot_acquired … waited_ms` logs on every run and read 0 both times, which proves nothing | Step 11, **2026-09-01** | Three users with matched analyses, simulated at once | **Owed — deliberately deferred** (owner, 2026-09-01), on the same reasoning as O-13 |
| O-15 | Matching embeds the requester and every candidate in a tight sequential loop, which walks straight into google's per-MINUTE embedding cap. The retry schedule now survives the window (fixed this session); the loop still enters it | Step 11, **2026-09-01** | Space or batch the embed calls in `app/matching.py` | **Owed** |
| O-16 | Step 13 in a signed-in browser against the release build: the eight ACs above, seven of them on the stored data with no model calls. This session built and tested everything on mocked repositories and verified the wire with curl, but could not sign in to the running web app | Step 13, **2026-09-01** | Owner or next session: trap 3d recipe, account named in "What is next" | **Owed** |
| O-17 | OS-level completion notification on desktop/mobile (S13-U4). Web uses the browser Notification API; other platforms get the in-app banner only, because an OS notification needs a plugin and platform setup | Step 13, **2026-09-01** | Add `flutter_local_notifications` (or similar) once a non-web target is actually run — see O-4 | **Owed — deliberately deferred** until a non-web target exists |
| O-18 | The Claude Design restyle of the results screens (`Ranking & Date Reveal.dc.html`) | Step 13, **2026-09-01** | **DONE 2026-09-01** — the design file was read directly from the `Matchmaking app UI design` working directory; theme, `results_screen.dart` and `curves.dart` rebuilt in the Modernist language; 29 widget tests and `flutter analyze` green. What is left is *looking* at it with the real typeface in a browser, which is part of O-16 | **Closed but for the browser look** |
| O-19 | Step 14 AC4 — compaction observed live: a chat driven past 40 messages, the `chat_compacted` line with its folded range and summary length, and coherent replies across the fold. Unit-tested at the boundary; the live run costs 30+ model calls | Step 14, **2026-09-01** | One long chat once quota allows, or a probe that seeds 41 rows directly and sends one message (1 compaction + 1 reply call) | **Owed** |
| O-20 | Step 15's UI (the delete flow with its receipt, the tombstones on the dashboard/reveal/results, the vanished-chat screen) in a signed-in browser. Widget-tested on mocks; the server halves witnessed by the probes | Step 15, **2026-09-01** | Part of the O-16 browser pass; a probe account can be deleted through the UI for the receipt | **Owed** |
| O-21 | Step 16 S16-B1 as written: all nine probes in one session against a COLD stack (`docker compose down -v`). Not done because it destroys the volume holding the owner's account and the transcripts Steps 13–14 were built against | Step 16, **2026-09-01** | Owner: `pg_dump` if the data matters, then `down -v`, `up -d`, and the nine probes in the order of the probe table | **Owed — owner's decision** |
| O-22 | The AI half of the seven new demo profiles: extraction, persona compilation and embeddings (3 model calls each, 21 total). Until it runs they have answers but no traits, no snapshot and no vector, so matching cannot see them | Demo pool, **2026-09-01** | The next API boot does it in the background on its own; `docker compose exec api python scripts/run_reconcile.py --wait` does it inline and reports | **DONE 2026-09-02** — `run_reconcile.py --wait`: `extracted: 7, compiled: 7, embedded: 7, failed: 0, deferred: 0, ok: 3` in ~4 minutes, 21 calls, no rate limits. All ten demo profiles now carry traits, a `ready` snapshot and two vectors |

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
| `probe_deletion.py` | **GREEN — 17/17** (2026-09-01, S15-P1). Takes `<victim_email> <survivor_email> [password]`; refuses an un-entangled pair; zero model calls; the victim is gone afterwards |
| `probe_demo_seeding.py` | **GREEN — 12/12** (2026-09-01, S15-P2). Wipes one demo user's traits and rebuilds them through the real pipeline: one extraction, one compile, one embedding call |

## Module build order

1 ~~Foundations~~ **(done; O-4)** · 2 ~~AI Interaction~~ **(done)** · 3 ~~Schema + reconciliation~~ **(done)** · 4 ~~Accounts~~ **(done; O-1)** · 5 ~~Questions & answers~~ **(done)** · 6 ~~Trait extraction~~ **(done)** · 7 ~~Persona & snapshots~~ **(done)** · 8 ~~UX profile + fidelity gate~~ **(done; gate CLOSED)** · 9 Matching **(code complete; witness OWED O-8)** · 10 ~~UX dashboard~~ **(done; O-9)** · 11 Simulation **(built; resume WITNESSED; O-13/O-14 deferred)** · 12 ~~Judge~~ **(done, all 7 ACs; quota gate CLOSED)** · 13 ~~UX results~~ **(built + tested on mocks; browser pass OWED O-16)** · 14 ~~Chat~~ **(built; server witnessed; compaction OWED O-19)** · 15 ~~Data hygiene~~ **(done, all 8 ACs; both probes GREEN)** · 16 Witness sweep **(run on this volume; cold-stack sweep OWED O-21)** · 17 ~~Candidate rejection~~ **(built and witnessed 2026-09-02, all 8 ACs; UI half owed under O-16)**. **Nothing on the plan is left to build; Step 17 was added from use, not from the plan.**

## Gate register (`ai_interaction.md` §3)

| Gate | Closes in | Status |
|---|---|---|
| Fidelity transfer | Step 8 | **CLOSED 2026-09-01** — see the measurement below |
| Quota fit | Step 11 → 12 | **CLOSED 2026-09-01 (S12-G1)** — one full analysis end to end, 59 calls in 7m13s with zero retries. That run predates the one-date and 16-turn revisions, so its *configuration* is historical; the conclusion holds a fortiori, since both revisions made the pipeline cheaper. Measurement below |

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

**One analysis, full pool (3 candidates × 1 date = 3 dates)** — REVISED TWICE on 2026-09-01

| Stage | Calls (floor) | Provider | Wall clock |
|---|---|---|---|
| Re-embed requester + 3 candidates | up to **4** | google | ~3 s |
| Scenario generation, 1 per candidate | **3** | openrouter | ~1 min |
| Date turns — 16 per date × 3 | **48** | openrouter | **~4 min** |
| Judging, 1 per date | **3** | openrouter | ~1 min |
| **Total (floor)** | **54 openrouter + 4 google** | | **~6 min** |

**Per candidate the floor is 18 calls: 1 scenario + 16 turns + 1 judge.** That is the budget the owner specified, and the turn cap now delivers exactly 16 turns because environment rows are no longer charged against it.

**The measured figure was 21, not 18, and the gap is worth understanding rather than rounding away.** On the witness run all 16 turns succeeded, but **3 of them needed one validation repair each** — the model returned JSON that failed the schema, and the Guard re-asked. Each repair is another model call. So:

| | Per candidate | Full pool of 3 |
|---|---|---|
| **Floor** — nothing malformed | 18 | 54 |
| **Measured** — 3 repairs in 16 turns | **21** | **~63** |
| **Ceiling** — every call using all 3 Guard attempts | 54 | 162 |

The ceiling is not a realistic figure, but it is the real worst case and it is why "18 calls per candidate" should be quoted as a floor. Free-model output quality, not the cap, sets the actual spend.

**History of this line, because it has moved twice today.** It was 171–189 calls at two 30-message dates per candidate; then ~90 at one 28-turn date; it is now ~54–63 at one 16-turn date. Each step was an owner decision and each is dated in `date_simulation.md`.

Onboarding one person, for comparison, is **2 calls** (extract + compile). A full analysis now costs about **as much as 30 onboardings.**

**Against the caps**

| Allowance | Analyses per day | Verdict |
|---|---|---|
| OpenRouter free tier, as documented (50/day) | **~0.8** | **Borderline for the first time.** A full pool needs ~54–63 calls against a 50/day allowance: one analysis a day is now within touching distance, and a `partial` pool of one or two candidates fits comfortably |
| OpenRouter with 10 credits added (1000/day) | **~16** | Comfortable for a friends-scale app, with room for probe runs on top |
| google embeddings | not the constraint on volume — but see the per-minute cap below | |

**The decision this spreadsheet forces, restated after the two revisions:** the shortfall has gone from 3.4× the daily allowance to roughly **1.1×**. A FULL pool of three candidates is still marginally over a documented 50/day, and a partial pool now fits inside it. That is a genuine change in kind — the core loop went from impossible on the free tier to borderline. **It is still not somewhere to run a product from:** one bad run of malformed output pushes it back over, and there is no headroom for the probe suite. The remedy is unchanged and named in OpenRouter's own 429 body — **10 credits raises the allowance to 1000/day**, now buying ~16 full analyses a day. Still the owner's call, now a much cheaper one.

### Correction: the "50 free calls per day" figure is not what it looks like

Last session recorded "OpenRouter free models: 50 requests per DAY, account-wide" as a settled fact. **This session contradicts it, and the contradiction is not explained.**

- At **14:55 UTC** a direct one-token call returned `429 … free-models-per-day`, `X-RateLimit-Limit: 50`, `X-RateLimit-Remaining: 0`, `X-RateLimit-Reset` = 2026-09-02 00:00 UTC.
- Between **15:12 and 15:30 UTC the same day**, on the same key and the same model, the api container made **118 successful free-model calls** with 5 rate-limited ones among them. No reset happened in between.

So the cap is real and it does bite, but it is **not a simple per-calendar-day counter**, and `X-RateLimit-Reset` did not predict when service resumed. Do not plan against 50/day as a hard ceiling, and do not plan against it being absent either. What is safe to say: **free-tier throughput is unpredictable enough that a multi-minute, multi-call pipeline cannot be relied on to finish** — that was written of a 171-call pipeline and still holds of today's ~63. That is the same conclusion as the table above, reached a second way.

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

**But read the number the other way before relaxing.** 59 calls was a `partial` pool with ONE candidate, at two dates each — the configuration of the day. A full pool under today's caps is ~54–63, and the documented free-model allowance is 50 a day. **This run only succeeded because the free tier is not behaving like the 50/day counter it advertises** (see the correction above) — it is not evidence that the free tier is sufficient, it is evidence that the pipeline is efficient and correct. The paid-balance decision stands exactly where the Step 11 spreadsheet left it, now with a completed run behind it rather than an estimate.

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
