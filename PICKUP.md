# PICKUP

The one document that tells someone with no memory of the last session where this project actually is. Maintained per `development_principles.md` §24, as part of the work — never as a task afterwards.

**Last updated:** 2026-09-04 · **Updated because:** this file had grown to 943 lines carrying a per-step record of the whole project. §24 asks for where the project *is*; the trail of how it got here now lives in **`PICKUP_ARCHIVE.md`** — every step's build notes, acceptance-criteria tables, "things worth not re-deciding" decisions, and both gate measurements in full, unedited. Nothing was deleted. Three stale facts were corrected on the way (see "Corrections made in this cleanup" at the end).

---

## Read this first (30 seconds)

**Everything is built. Nothing on the plan is left to write.** Eighteen steps: 1–17 from `IMPLEMENTATION_PLAN.md`, plus Step 18 (navigation) which came from use, not from the plan. What remains is **witnessing** — and every open witness needs either a human at a keyboard or the owner's decision to spend model calls. They are priced individually in "Owed measurements".

**The 2026-09-02/03 audit is COMMITTED and PUSHED as of 2026-09-04** — `server` `b1db7bc`, `ux` `2afeb21`, each as one reviewable commit carrying **D-022 … D-030**. It sat uncommitted for two days and no longer does. The LiteLLM provider (**D-031**) is the commit on top of it, `server` `5c6a05f`. All three repos are level with GitHub, and the suite is 205 server pytest / 60 UX widget tests, `ruff` clean, `flutter analyze` clean, migration `0013` applied. **What the audit still owes is its live witnesses, priced under O-24** — none of it has been seen in a browser.

**To run it locally:** `docker compose up -d` (api + db), then from the `ux` submodule:

```bash
C:\src\flutter\bin\flutter.bat run -d web-server --web-port 5000 --web-hostname 127.0.0.1
```

Then open `http://127.0.0.1:5000`. First compile is 60–90 s and the page is blank until it finishes. **Read traps 4–12 before doing this** — they are the difference between a working stack and a black screen. Both API keys are in `.env` (git-ignored).

**Standing owner directive (2026-09-01):** the priority is API calls that connect, route correctly, and return simple valid responses. Complex architecture, advanced prompting and model-tier upgrades are decided later, not now.

**Standing model facts.** Since 2026-09-04 there are **three** providers — `google`, `openrouter` and `litellm`, the last being one interface to everything else (Anthropic, OpenAI, Bedrock, Vertex, Groq, Ollama, vLLM …) and reached by writing its model string into a routing line. **Nothing routes to it yet — that is a deliberate owner decision, not an oversight.** All eight chat/structured tasks route to **`openrouter/dots-studio/dots-3-note-preview:free`** — `trait_extraction`, `persona_digest`, `judging`, `dispute_followups`, `scenario_generation`, `date_simulation`, `chat_reply`, `chat_compaction`. Every slot in `config/ai.yaml` is filled. **Embeddings are pinned separately and are untouched: `google/gemini-embedding-001` at 768 dims** — a different model on a different quota, because every stored vector must come from one model and OpenRouter serves no embedding equivalent. All pins are provisional; the final tier choice belongs to the gates.

**How that model was chosen — do not re-guess it, re-measure it.** Of the 18 free OpenRouter models only four advertise `structured_outputs`, and Step 2's smoke-test model `nvidia/nemotron-3.5-lightning` is **not one of them** — pointed at `trait_extraction.v1` it took 211 seconds and returned non-JSON. All four candidates were run against the real schema and the real prompt: `dots-3-note-preview` passed in 28 s with short well-shaped labels; `z-ai/glm-5.2:free` was 429-saturated; `liquid/lfm-2.5-2.6b:free` is too small to trust. **A Step 2 smoke test proves a model answers; it does not prove the model can satisfy THIS schema. Re-measure per task, not per provider.**

---

## Repository layout

Three git repositories: the `dating-app` superproject, with `server` and `ux` as submodules. All three are pushed to GitHub (`dating-app`, `dating-app-server`, `dating-app-ux`).

```
dating_app_ai\                      ← superproject
├── docker-compose.yml, Dockerfile, .env.example, .env (git-ignored), .gitignore
├── the five specs + IMPLEMENTATION_PLAN.md
├── PICKUP.md (this file) + PICKUP_ARCHIVE.md + DEFECTS.md
├── Matchmaking app UI design\      ← the Claude Design canvas + its _ds token sheet
├── server\                         ← submodule
│   ├── pyproject.toml (explicit package decl — D-003), alembic.ini
│   ├── app\
│   │   ├── main.py · config.py · db.py · errors.py · logging_setup.py · security.py
│   │   ├── models.py · reconcile.py · traits_hash.py · accounts.py · answers.py
│   │   ├── extraction.py · persona.py · matching.py · simulation.py · judging.py
│   │   ├── chat.py · demo.py · deletion.py · date_archetypes.py
│   │   ├── ai\      base.py · google.py · openrouter.py · litellm_provider.py
│   │   │            registry.py · routing.py · structured.py · resilience.py
│   │   ├── routers\ auth · me · questions · traits · persona · analyses
│   │   │            simulation · chat
│   │   └── schemas\ the registry + one file per versioned schema
│   ├── config\ai.yaml · migrations\versions\0001…0013 · seeds\ · scripts\ · probes\ · tests\
│   └── the seven server module plans
└── ux\                             ← submodule
    ├── Flutter 3.47.2 app: lib\app, lib\core\{api,auth,polling,notify},
    │   lib\features\{auth,questions,persona,traits,chat,analyses,dates,home,settings,common}
    └── the seven UX module plans + widget tests
```

## Current state — honest

| Area | State |
|---|---|
| **Steps 1–8, 10, 12, 15, 17** | **Witnessed whole.** Every acceptance criterion observed on the running stack. The tables are in `PICKUP_ARCHIVE.md` |
| **Step 9 — matching** | **Code complete; witness OWED (O-8).** The one GREEN run was polluted (concurrent probes sharing an output file, stale opted-in probe users in the pool, `shared_interests` vacuous under D-009). Do not mark done |
| **Step 11 — simulation** | **Built; the central claim witnessed.** A real analysis ran two full dates end to end; a SIGKILLed API came back, reconciliation relaunched it, and the date resumed from its checkpoint. Two ACs deliberately deferred by the owner (O-14, and O-13 which is now void) |
| **Step 13 — results UX** | **Built, restyled onto the Modernist design system, tested on mocked data; wire verified on real data; server-side resume witnessed over HTTP.** The signed-in browser pass is owed (O-16) |
| **Step 14 — chat** | **Built; server side witnessed over HTTP** (selection, refusals as state, a real reply with no `state` on the wire, forced give-up, end). **Compaction not witnessed live (O-19)**; browser pass owed (O-16) |
| **Step 16 — witness sweep** | **Run as far as a session without a human can take it.** Doc drift 0, wire privacy 10/10, log reconstruction done on three dates, 7/9 probes GREEN. The cold-stack sweep is O-21 |
| **Step 18 — navigation** | **Built and tested** — one `StatefulShellRoute` with four branches, `BackTo` everywhere, the dispute's own correction screen. 8 tests drive the REAL router |
| **The 2026-09-02/03 audit** | **Fixed, tested, committed and pushed** (`server` `b1db7bc`, `ux` `2afeb21`). **Live witnesses still owed (O-24)** |
| **AI providers** | **Three**: `google`, `openrouter`, and `litellm` (added 2026-09-04, witnessed live). All eight tasks currently route to openrouter; litellm is wired, tested and proven but nothing routes to it yet |
| **Tests / lint** | Server **205 pytest green**; UX **60 widget tests green**; `ruff` clean; `flutter analyze` clean |
| **Migrations** | Through **`0013`**, all applied |
| **The pool** | **51 people, all matchable** — 50 demo profiles + the owner's account. Plus **36 probe accounts** that are wreckage, not people |

## What was just finished

### The `litellm` provider (2026-09-04) — built and WITNESSED live

The owner asked for models to be callable through the LiteLLM interface. `app/ai/litellm_provider.py` is a third provider behind the same locked `AIProvider` protocol, so nothing downstream changed: `TaskRouter` resolves it like any other, the Guard is still the only place model JSON is parsed (§16), and a stored artifact still records exactly what made it.

**Added ALONGSIDE the two hand-written clients, not in place of them.** Those two are what this project measured, pinned and closed its gates on, and each encodes upstream knowledge a generic client does not. LiteLLM is the door to everything else — Anthropic, OpenAI, Azure, Bedrock, Vertex, Groq, Together, Mistral, DeepSeek, Ollama, a local vLLM.

**To use it:** uncomment the `litellm` provider in `config/ai.yaml` and point a routing line at it. **The model string IS the routing** — `{ provider: litellm, model: "anthropic/claude-sonnet-4-5" }`. For a self-hosted endpoint add `api_base` (only this provider reads it; the registry refuses it on the other two at startup rather than ignoring it).

**Its key is optional, and that is the one real difference.** LiteLLM resolves a key PER UPSTREAM from the environment (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, …), so an empty `LITELLM_API_KEY` is normal and is logged at INFO with `key_resolution: provider_env` — not the WARNING the other two get, because a warning that fires every boot is one people learn to skip.

**Witnessed against real providers, not just mocked:** a plain call and a **native** structured call through `gemini/gemini-flash-latest` returning a validated dict; a 768-dimension embedding at L2 norm 1.000000; a real 404 classified fatal and correctly not retried; the env-resolved key path proven through `openrouter/…`; and an OpenRouter upstream fault retried three times as transient before an honest typed give-up. 45 unit tests, none of which touch the network.

**The live call found a real defect on its first attempt — D-031.** LiteLLM flattens OpenRouter's `"Provider returned error"` (the D-008 upstream fault, which `openrouter.py` deliberately treats as *transient*) onto its own `BadRequestError`, and my mapper made it **fatal** — silently undoing D-008 for everything routed through the new provider. Fixed, re-witnessed, and three tests pin it. **The lesson is worth more than the fix: a new provider does not inherit the defect knowledge the old ones encode — it has to re-earn it**, because those classifications are facts about an UPSTREAM, not about the client library that reached it.

**Two operational notes.** `litellm` is a new dependency in `server/pyproject.toml`, so the **image was rebuilt** (`docker compose build api && docker compose up -d api`) — a fresh clone needs the same, and the provider's own ImportError message says so (trap 5). And it is **imported lazily**: the import costs seconds, and the registry builds every configured provider at boot whether or not a task routes to it.


### The demo pool: 3 → 10 → 50 people (2026-09-01 … 09-03)

`seeds/demo_profiles.yaml` holds **50 real accounts**, seeded through the real registration and upsert paths — `create_user` and `save_answer`, the same functions the endpoints call. `is_demo=True` is the only difference. Five baseline answers each, written in distinct voices.

**All 50 are fully pipelined** (O-23 in its old numbering, closed 2026-09-03): live traits, a `ready` persona snapshot and 2 embeddings each — **511 traits, avg 10.2 per person, every one carrying `source_answer_ids` AND `extracted_by`**. Verified by querying the database, not by trusting the pass's counters.

What the fixture deliberately spans: ages **22–58**, 25 women / 22 men / 2 nonbinary / 1 other, **seven** distinct `interested_in` shapes, **24 cities** including four diaspora profiles, a real class and occupation range (long-haul driver, welder, hairdresser, firefighter, ship's engineer, pastry chef) and a range of life circumstance. Answer length is **deliberately uneven, 189–471 characters**, so extraction is not fed one house voice.

**The one thing to carry forward — a provider quirk, not a bug.** Three profiles (`vlad`, `mihnea`, `gheorghe`) were reliably rejected by the openrouter upstream with `400 bad request` / `content_filter` on **identical bytes**. Proven not to be a content-safety problem: the production request was captured and replayed verbatim and returned `400` on one attempt and `content_filter` on the next; two other profiles hit `content_filter` on persona v1 and compiled `ready` on v2 from identical content; the failing prompt with one 134-char line changed passed 7/7. **The common factor was terseness (~200 chars/answer against the pool's ~300+), and lengthening the answers fixed all three, first try.** `seeds/demo_profiles.yaml`'s header carries this warning. There is no code change to make.

### The roster page (2026-09-03)

`server/scripts/roster.py` — reads the database directly, writes standalone HTML to stdout:

```bash
docker compose exec -T api python scripts/roster.py > roster.html
```

**Why a local script and not an endpoint — owner decision.** `communication_protocol.md` §6 rule 5, audited by `scripts/audit_wire_privacy.py`, says non-candidates appear in no payload. A "list everyone" endpoint would break that invariant for every signed-in client, permanently, to serve one person looking at their own database. The owner was offered three options and chose the local page, so the invariant is untouched. `roster.html` is gitignored — a snapshot, never a source file.

It shows identity basics and trait **labels** only (the one trait field candidate payloads may already carry), never descriptions, answers, snapshots or prompts.

**What it surfaced:** the database holds 87 accounts and only **51 are the pool**. The other **36 are probe wreckage** — 32 `@probe.dev`, 3 `@dating-test.dev`, plus a `probe-onboard-…@probe.dev` that had `is_demo` set on a probe account, so it counted as a 51st demo profile in every naive query. The script therefore groups by ORIGIN (email domain beats the flag). **They are safe to delete and nobody has** — see "Blocked".

### D-021 and the judging threshold (2026-09-02) — built, NOT yet witnessed live

Two owner decisions on the date pipeline, both green in unit tests and in the database, and **not one model call has been made under the new design.** Do not describe this as done in front of anyone until O-23 has run.

- **One scenario per ANALYSIS, drawn at random in code.** `app/date_archetypes.py` holds 16 written-down archetypes. `ensure_analysis_scenarios` draws one (excluding the last `RECENT_ARCHETYPES_AVOIDED = 3` that user has had), generates it in ONE call that receives no names, ages, interests or traits, stores it on `analyses.scenarios` (migration `0011`), and every candidate's date copies it. Before this, three candidates were ranked against each other on three *different* evenings while the screen printed "— the same for every candidate" underneath.
- **`date_scenarios.v3`** — `anchored_in_interest` is gone, `archetype` replaced it. The model echoes the drawn key back and `generate_scenarios` verifies it against what was actually drawn; the no-repeat rule matches on that key, so a paraphrase would break it silently.
- **The ≥10-turn "too short to judge" rule is removed entirely.** `JUDGEABLE_MIN_TURNS` moved from `app/simulation.py` (where it was 10) to `app/judging.py` (where it is 1) and now means "somebody spoke". Depth is **reported** as the judge's own `confidence` (`judge_rubric.v2`, migration `0012`) instead of being used as a bar to clear.
- **Backward compatibility, deliberate and load-bearing:** no backfill on either column. Analyses that ran before genuinely had no shared fixture, and v1 evaluations were never asked for a confidence. Writing values into either would be inventing history. Both render as absence.

### The whole-codebase audit and its fixes (2026-09-02/03) — UNCOMMITTED

A review of both submodules ([report](https://claude.ai/code/artifact/5a3f6f28-2dcd-419c-b862-6f84d6d803b1)) found 7 critical, 11 high, ~31 medium and ~40 low items. Every critical and high item and the cheap mediums are fixed. **Ledger entries D-022 … D-029 carry the mechanism, lesson and status for each group; D-030 carries the seven regressions found in the fixes themselves the next day** — the worst being `PATCH /me` silently unregistered by a misplaced decorator, and two new `rollback()`-then-read `MissingGreenlet` paths. `tests/test_routes_registered.py` now pins the route table.

Read D-022…D-030 in `DEFECTS.md` rather than a summary here; that is what the ledger is for.

**Still open from the report, all low:** backoff jitter (the backoff test pins exact delays) and a typed truncation error for `finish_reason=length`. Two items were left alone **on purpose**: the empty-`finish=length` retry (trap 34 records a real case where the retry succeeded) and 403-as-refusal (it matches OpenRouter's documented meaning).

**The Demo label is retired by owner decision** — `DemoChip` renders nothing; `is_demo` still guards the server.

## What is next

In the order that buys the most:

1. **Commit the audit diff.** It is 56 modified files across two submodules, green, and one `checkout` from gone. Submodules first, then the superproject pointer bump (trap 1).
2. **O-3 — an analysis from a real account against the demo pool, dates and all.** ~54 calls. The product's first genuinely real run, and the most informative thing left to do. Matching has already been witnessed on the owner's account (`matched`, funnel `opt_in 13 → gender 7 → age 7 → snapshot 7 → embedding 7 → top 3`); **the dates have not been simulated.** This run also closes most of **O-23**.
3. **O-16 / O-20 — the signed-in browser pass** over Steps 13–15. Seven of the eight Step 13 criteria need **no model calls**. Recipe: `flutter build web` in `ux/`, `python serve_build.py 5000`, sign in as `probe-sim-alice-4aa682e1@probe.dev` / `probe-password` (owns five complete analyses, one with a partial and an excluded date: `2b83aeab`), or use the owner's own account.
4. **O-8 — one clean `probe_matching_filters.py` run** from an empty probe pool. ~10 calls.
5. **O-9 — the `no_candidates` screen**, rendered. Nearly free: toggle the only candidate's `opt_in` off and re-run.

**Do not spend model calls on O-14 or O-17** — both are deliberately deferred by the owner.

**Every test and probe account is opted OUT of the candidate pool, and that is the standing default** (owner, 2026-09-01): a small pool keeps probe runs cheap, and D-009 is the story of what stale opted-in probe users do to a matching run. `bob@dating-test.dev` included. **Opt in only what a specific witness needs, and opt it back out afterwards** — `probe_simulation_resume.py` does that for its own two users automatically.

**Demo accounts** use password `demo-password`, all `@dating-demo.dev`, all opted IN by design — they are the pool. Reconciliation recreates any that go missing, through the real pipeline. Test accounts on the current volume use `hunter2222`.

## Blocked, and on whom

| Item | Blocked on | Notes |
|---|---|---|
| Native desktop witness (O-4) | **Owner:** enable Windows Developer Mode, then `flutter run -d windows` in `ux\` | Unchanged for three sessions |
| **The paid-balance decision** | **Owner**, and the numbers are in | A full analysis is **~54 calls floor, ~63 observed**. On the free tier as documented (50/day) a full pool is marginally over; a partial pool fits. **10 credits raises the allowance to 1000/day ≈ 16 analyses a day.** See the gate register |
| The 36 probe accounts | **Owner** | 8 are complete, 28 are not, and 2 of those never can be (zero answers — `extract_once` refuses a person who has not answered anything). Completing the other 26 costs ~80 model calls on test litter. **Recommendation: delete all 36.** `down -v` (O-21) would also clear them. Nothing deleted |
| The cold-stack sweep (O-21) | **Owner** | `down -v` destroys the volume holding the owner's account and the transcripts Steps 13–14 were built against. Take a `pg_dump` first if they matter |
| Hosting / CORS / auth posture | **Owner, explicitly deferred** | Decision log #11 |

## Owed measurements (§4)

| # | Owed | Incurred | Closed by | Status |
|---|---|---|---|---|
| O-3 | Matching against properly seeded demo profiles, **through the dates** | Step 9 | One full analysis, ~54 calls | **HALF WITNESSED 2026-09-02** — the owner's account was re-pointed through the real endpoints and matched three candidates (Theo 0.660, Victor 0.658, Dan 0.655). The dates have NOT been simulated. Note `shared_interests` was empty for all three (D-016), and `Dan` is a leftover PROBE account, not a demo profile |
| O-4 | Native (Windows) run rendering `/health` | Step 1 | Owner: Developer Mode + `flutter run -d windows` | **Owed** |
| O-5 | Step 8 AC2/AC3 UI paths: the optimistic-update ROLLBACK on a forced server error, and the dispute deep-link through to answering the generated question | Step 8 | A browser pass with the API forced to fail | **Owed.** The second half changed shape in D-018 — the dispute now opens `/profile/correct/:questionId` |
| O-6 | Step 8 AC4's stale→fresh flip: observed going "Profile changed" → rebuild → "up to date" | Step 8 | A browser pass after an answer edit | **Owed** |
| O-7 | The fidelity gate re-run **by the owner on the owner's own account**. The gate asks you to count lines *you* would never say; a session can only assess against the account's written answers | Step 8 | Owner | **Owed** |
| O-8 | Step 9's end-to-end witness: ONE clean `probe_matching_filters.py` run from an empty probe pool | Step 9 | A single clean run | **Owed** |
| O-9 | Step 10's `no_candidates` screen and the remaining empty states, rendered | Step 10 | Toggle the only candidate's `opt_in` off and re-run | **Owed — nearly free** |
| O-14 | Step 11 AC7: the global semaphore of 2 observed limiting three queued analyses. `simulation_slot_acquired … waited_ms` reads 0 with one pipeline, which proves nothing | Step 11 | Three users with matched analyses, simulated at once | **Owed — deliberately deferred** (owner) |
| O-15 | Matching embeds the requester and every candidate in a tight sequential loop, walking into google's per-MINUTE embedding cap. The retry schedule now survives the window; the loop still enters it | Step 11 | Space or batch the embed calls in `app/matching.py` | **Owed** |
| O-16 | Steps 13–14 in a signed-in browser against the release build. Seven of Step 13's eight ACs need no model calls | Step 13 | Owner or a session with a human: the recipe in "What is next" | **Owed** |
| O-17 | OS-level completion notification on desktop/mobile. Web uses the browser Notification API; other platforms get the in-app banner only | Step 13 | `flutter_local_notifications` once a non-web target is actually run (see O-4) | **Owed — deliberately deferred** |
| O-19 | Step 14 AC4 — compaction observed live: a chat past 40 messages, the `chat_compacted` line with its folded range, coherent replies across the fold | Step 14 | One long chat (30+ calls), **or** a probe that seeds 41 rows directly and sends one message (1 compaction + 1 reply) | **Owed** |
| O-20 | Step 15's UI — the delete flow with its receipt, the tombstones on dashboard/reveal/results, the vanished-chat screen | Step 15 | Part of the O-16 pass; a probe account can be deleted through the UI for the receipt | **Owed** |
| O-21 | All nine probes in one session against a COLD stack (`docker compose down -v`) | Step 16 | Owner: `pg_dump` if the data matters, then `down -v`, `up -d`, the nine probes in probe-table order | **Owed — owner's decision** |
| O-23 | **The D-021 shared fixture and the removed judging threshold, live.** Four checks no unit test can make: (1) three candidates' dates all name the SAME `setting_name`, and `analysis_scenarios_drawn` logs one archetype per analysis, not per candidate; (2) a second analysis for the same user draws a DIFFERENT archetype, with `avoided=[…]` in the log line; (3) the generated setting names nobody and assumes nothing about who is coming — **read the actual `description`**, because this is a prompt instruction and prompt instructions are the thing that quietly does not hold; (4) a thin date is judged with a low `confidence` rather than excluded | 2026-09-02 | One analysis end-to-end, ~20 calls. `probes/probe_judge.py` covers (1) and (4) against whatever is stored, for one judging call | **Owed** |
| O-24 | **The browser pass for the audit fixes.** A slow-day extraction through the building screen (now start-then-poll); a reload on `/analyses/:id/results` staying signed in; a dispute → answer → `corrected` round trip; a rejection followed by a simulation (also wants a fake-router unit test); a genuine mid-date provider failure resumed through the UI; a chat resend replayed from `client_message_id` | 2026-09-02 | Folds into the O-16 pass | **Owed** |

**Closed and deleted per the queue rule:** O-1 (opt_in observed both ways), O-2 (pinned-snapshot assertion enabled), O-10/O-11/O-12 (all closed within their own session), O-18 (the Modernist restyle — done 2026-09-01; what is left is *looking* at it with the real typeface, which is part of O-16), and the two demo-pipeline runs that filled first ten and then fifty profiles. **O-13 is void** — the empty-intersection fallback it was about no longer exists; the scenario is drawn from a catalogue and reads no interests, so there is no intersection to be empty. Its successor is O-23.

> **Numbering note, 2026-09-04.** Two O-numbers had been used twice. Resolved by first use: **O-22** was the demo-pipeline run (closed) and **O-23** is the D-021 live witness (open). The audit's browser pass, previously also called O-22, is now **O-24**; the forty-profile pipeline run, previously also called O-23, closed 2026-09-03 and is folded into the demo-pool section above.

## Probe status (§2)

| Probe | Status | Cost to re-run |
|---|---|---|
| `probe_structured_guard.py` | **GREEN** | a few forced calls |
| `probe_pool_expansion.py` | **GREEN** | 0 |
| `probe_ai_smoke.py` (helper, not in the §2 minimum set) | **GREEN** — takes the model as an argument | 1 |
| `probe_answer_edit.py` | **GREEN** (S6-P1/P2, real AI calls) | several extractions |
| `probe_onboarding.py` | **GREEN 16/16** | 2 |
| `probe_matching_filters.py` | **The one clean run is still OWED (O-8)** | ~10 |
| `probe_simulation_resume.py` | **GREEN 23/23.** Runs on the HOST — see trap 22. Default run stops once resume is proven; `--full` costs a whole analysis | 0 → a full analysis |
| `probe_judge.py` | **GREEN 9/9.** Takes an account email and reuses an already-judged date rather than simulating a fresh one | **1** |
| `probe_deletion.py` | **GREEN 17/17.** Takes `<victim> <survivor> [password]`; refuses an un-entangled pair; the victim is gone afterwards | **0** |
| `probe_demo_seeding.py` | **GREEN 12/12.** Wipes one demo user's traits and rebuilds them through the real pipeline | 3 |
| `probe_candidate_rejection.py` | **GREEN 15/15** on a live `matched` analysis | **0** |

Two audit scripts sit beside them, re-runnable in seconds at no model cost: `scripts/check_docs_drift.py` (every endpoint named in a module plan, against the live `/openapi.json` — currently **zero drift**) and `scripts/audit_wire_privacy.py <email>` (the five §6 rules against RAW response bodies — currently **10/10**).

## Module build order

1 ~~Foundations~~ **(done; O-4)** · 2 ~~AI Interaction~~ **(done)** · 3 ~~Schema + reconciliation~~ **(done)** · 4 ~~Accounts~~ **(done)** · 5 ~~Questions & answers~~ **(done)** · 6 ~~Trait extraction~~ **(done)** · 7 ~~Persona & snapshots~~ **(done)** · 8 ~~UX profile + fidelity gate~~ **(done; gate CLOSED)** · 9 Matching **(code complete; witness OWED O-8)** · 10 ~~UX dashboard~~ **(done; O-9)** · 11 Simulation **(built; resume WITNESSED; O-14 deferred)** · 12 ~~Judge~~ **(done; quota gate CLOSED)** · 13 ~~UX results~~ **(built + tested on mocks; browser pass OWED O-16)** · 14 ~~Chat~~ **(built; server witnessed; compaction OWED O-19)** · 15 ~~Data hygiene~~ **(done; both probes GREEN)** · 16 Witness sweep **(run on this volume; cold-stack sweep OWED O-21)** · 17 ~~Candidate rejection~~ **(built and witnessed; UI half under O-16)** · 18 ~~Navigation + corrections~~ **(built and tested — came from use, not from the plan)**

## Gate register (`ai_interaction.md` §3)

| Gate | Status |
|---|---|
| **Fidelity transfer** (Step 8) | **CLOSED 2026-09-01** — 1 clear "I'd never say that" line in 6, plus 1 borderline. **The failure mode to watch is *fabricated concrete detail*, not blandness:** asked what he is bad at, the persona invented a cooking anecdote its subject had never written a word about. **Honest limit: only the person themselves can run this gate properly — O-7 is the owner's re-run** |
| **Quota fit** (Steps 11→12) | **CLOSED 2026-09-01** — one full analysis end to end, **59 calls in 7 m 13 s with zero retries**. That run predates the one-date and 16-turn revisions, so its configuration is historical; the conclusion holds a fortiori because both revisions made the pipeline cheaper |

Full measurements, per-call latencies and the spreadsheet's revision history are in `PICKUP_ARCHIVE.md`. The numbers that matter now:

| | Per candidate | Full pool of 3 |
|---|---|---|
| **Floor** — nothing malformed (1 scenario + 16 turns + 1 judge) | 18 | **54** |
| **Measured** — 3 validation repairs in 16 turns | 21 | **~63** |
| **Ceiling** — every call using all 3 Guard attempts | 54 | 162 |

Onboarding one person, for comparison, is **2 calls**. A full analysis costs about as much as 30 onboardings.

**Measured provider caps:** OpenRouter free models are documented as 50/day account-wide — **but the measured behaviour does not match.** At 14:55 UTC a one-token call returned `429 free-models-per-day` with `X-RateLimit-Remaining: 0` and a reset at midnight; between 15:12 and 15:30 the same day, same key, same model, the container made **118 successful free-model calls** with no reset in between. So the cap is real and it does bite, but it is not a simple per-calendar-day counter and `X-RateLimit-Reset` does not predict when service resumes. **Do not plan against 50/day as a hard ceiling, and do not plan against it being absent either.** google `gemini-3.6-flash` behaves as ~20/day (the reason chat moved off google entirely); `gemini-embedding-001` has a low per-MINUTE cap that matching walks straight into (O-15).

## The knobs, and what moves with them

Both caps are single integers and both are meant to be turned. Written down because "is this configurable or is it baked in" is the question, and the answer differs between them.

| Knob | Where | What follows it automatically |
|---|---|---|
| **Turn cap** | `TURN_CAP = 16` in `app/simulation.py` | `MAX_MESSAGES_PER_DATE` (= `TURN_CAP + MAX_EVENTS_PER_DATE`). Nothing else reads the value. **A one-line change, genuinely** |
| **Dates per candidate** | `SETTINGS_PER_ANALYSIS = 1` in `app/schemas/date_scenarios.py` | `DATES_PER_CANDIDATE` and `MAX_DATES_PER_ANALYSIS`. The scenario prompt already says "produce exactly N setting(s)" with the singular handled, and `generate_scenarios` returns a list because N is a knob |
| **How often a setting can repeat** | `RECENT_ARCHETYPES_AVOIDED = 3` in `app/date_archetypes.py` | Nothing. It is advisory: if it reached the catalogue size, every draw would hit the exhausted-pool fallback and the no-repeat rule would stop working **silently**, which is why a test asserts it stays below `len(ARCHETYPES)` |

**Nothing about the structure restricts it to one date.** The plural path is intact — `settings[:DATES_PER_CANDIDATE]`, ordinals from `enumerate(..., start=1)`, one `dates` row per setting, and `ensure_analysis_scenarios` draws N distinct archetypes without replacement.

**Two things do NOT follow the knob and need a human:**

1. **The JSON schema version.** `minItems`/`maxItems` read the constant, so changing it changes the schema — and the registry's rule is a version bump, not an edit in place.
2. **The archetype catalogue itself.** 16 archetypes, each with a premise that has to contain something two strangers can disagree about. A premise that does not is a fixture where three candidates produce three identical transcripts, and **no constant will tell you that has happened.**

---

## Traps that will bite you resuming cold

Renumbered 1–45 on 2026-09-04; the old list had six duplicate numbers.

### Repositories and the build

1. **Three git repositories.** Submodule commit(s) first, then the superproject pointer bump. An un-bumped pointer serves yesterday's code with today's specs.
2. **`docker compose down`/`up` is NOT a cold start** — the `db_data` volume survives. True cold = `down -v`.
3. **`.env` holds the DB password the volume was initialized with** — regenerate both together or neither. And **editing `.env` does not reach a running container**: compose reads it at container start, so `up -d` / restart after key changes.
4. **If a tool is not named in a build file, it is not installed — it is merely present.** `pytest` and `ruff` were in the image only because someone once installed them by hand; the first genuine rebuild removed them and both commands in the definition of done stopped working. The Dockerfile now installs `.[dev]`.
5. **The running image can be OLDER than the Dockerfile** (D-012), and D-004's fix only protects you if the image is current. `docker compose restart` does not rebuild. If an in-container script cannot import `app.*`, run `docker compose build api && docker compose up -d api`, then check site-packages holds `__editable__.dating_app_server-*.pth` and **not** a real `app/` directory.
6. **Ruff's `EXE002` is suppressed on purpose** — through the Windows bind mount every file looks executable. Do not "fix" it by chmod.

### Running the Flutter app

7. **Flutter is not on PATH**: use `C:\src\flutter\bin\flutter.bat`. Android SDK absent; targets are web and (after Developer Mode) Windows desktop.
8. **Serve the web app on `127.0.0.1`, never `localhost`** (D-006). Given the *name*, Flutter binds IPv6-only on Windows and dwds' debug websocket dies — the page then hangs on a black screen at "DDC is about to load 740/740 scripts" **with no error shown**. CORS admits both spellings now, so `127.0.0.1` is simply the one that works.
9. **A Dart edit needs the dev server restarted** — a browser reload alone serves the stale bundle. First compile is 60–90 s and the page is blank until it finishes; that blankness is normal.
10. **When dwds will not co-operate, witness against a RELEASE BUILD.** `flutter build web`, then `python serve_build.py 5000` from `ux/`. No debug websocket exists, so the whole dwds failure class disappears; it loads in about a second instead of ninety, and it is what the user would actually run. Cost: no hot reload, and you must rebuild after each Dart change. **This is how Steps 8–13 were witnessed.**
11. **Deep links need BOTH halves, and each alone makes the other look broken.** Client: `usePathUrlStrategy()` in `main.dart` — without it, Flutter web's default HASH strategy means go_router sees only the empty part after `#` and starts at `/`, **with the correct URL still in the address bar**. Server: an SPA fallback to `index.html` — `ux/serve_build.py` does this; `python -m http.server` does not and 404s.
12. **After ANY change to `pubspec.yaml`, run `flutter clean` before `flutter run`.** Adding `google_fonts` mid-session left the DDC dev-compiler holding a module graph from before the dependency set changed, and the run died with a wall of errors in files nobody had touched (`models.freezed.dart: Couldn't find constructor 'JsonKey'`, then "The Dart compiler exited unexpectedly"). **It reads like the generated code is broken. It is not** — `flutter analyze` was clean and `flutter build web` compiled the same source. Cure: `flutter clean` then `flutter pub get`.
13. **`flutter pub add <package>` prints "Building with plugins requires symlink support / enable Developer Mode" and looks like a failure. It is not** — the pubspec and lockfile are updated and a plain `flutter pub get` immediately after succeeds. The symlink step is for the Windows desktop target (O-4).
14. **Icons rendering as boxes after a rebuild** is a cache problem, not a font problem: a browser or service worker serving the OLD tree-shaken font under the NEW `main.dart.js`. `serve_build.py` now sends `Cache-Control: no-store`. If it recurs: hard reload, or DevTools → Application → Service Workers → Unregister, then reload twice.

### Probes and witnessing

15. **Probes cannot see browser-only failures** (D-006). Every probe runs inside the api container, where there is no Origin header and no preflight. CORS, mixed content, cookies, websocket upgrades: the probe suite is GREEN straight through all of them. **Reaching the API from a browser is its own witness step.**
16. **The UI cannot be signed into by an automated session** — the password field is off-limits to the assistant's browser tools. API-level witnesses go through `curl` with probe accounts; anything that must be seen signed-in is the owner's, or a session with a human at the keyboard. **This is why O-16 exists.**
17. **Do not edit files under `server/` while a probe is running.** uvicorn runs with `--reload`; a save restarts the API and kills every in-flight request. A long matching probe was lost to this.
18. **Writing a scratch `.py` into `server/` triggers that same reload — and every reload relaunches the whole demo pipeline.** Pipe throwaway scripts in over stdin instead: `docker exec -i dating_app_ai-api-1 python - < script.py`.
19. **`docker exec -w /app …` from Git Bash dies with `Cwd must be an absolute path`** (MSYS path mangling), and six "retry passes" once silently never ran. Use `docker compose exec -T api …` from the superproject root.
20. **A probe must call `setup_logging()` or the §7 lines go nowhere** (D-015). Two RED runs were spent reading PASS/FAIL lines that could not say why, while the line naming the race was being written to an unconfigured logger.
21. **One probe run at a time, and clean up the users it leaves behind** (D-009). Concurrent runs sharing an output file produced a report spliced from two different runs, and stale opted-in probe users polluted the pool.
22. **`probe_simulation_resume.py` runs on the HOST, not in the container**, and it is the only one that does. It has to kill the api container, and `docker compose exec` processes die *with* the container. It uses stdlib `urllib` for the same reason.
23. **`docker compose logs api` reaches back only to the container's last recreation.** A `restart` keeps the log; `up -d` after a Dockerfile change, or `down`, starts it over. If log history matters, ship the JSON lines somewhere before recreating the container.

### The domain rules that get "fixed" back

24. **The answer minimum is 50 characters** (owner, lowered from 200) and **applies to dispute answers too**; **dispute questions are outside pool progress**. It lives in FOUR places that must move together — the DB CHECK (migration `0003`), `app/models.py`, the pydantic `Field(min_length=…)` in `app/routers/questions.py`, and `_minChars` in `ux/lib/features/questions/answer_flow.dart` — plus the probe's boundary case. **The voice nudge still says "4–5 sentences" on purpose:** guidance above the floor, not a contradiction.
25. **The date cap is 16 AGENT TURNS and it does NOT count environment rows.** Revised 2026-09-01 from a 30-message cap that did. One turn is one model call; an event costs none, so charging events against the cap made the real spend a distribution rather than a budget. **This reversed a rule `development_principles.md` §18 held up as a standing example**, so §18 itself was revised — and the unit test that pinned the old behaviour was INVERTED rather than deleted, because someone will eventually remember the old rule.
26. **Every date with a transcript is judged, however short** (2026-09-02). The ≥10-turn threshold is gone; depth is reported as the judge's `confidence`. `excluded_from_score` now means only "nobody spoke on this date".
27. **An all-`keep` extraction run leaves everything fresh** — that is the point of `traits_hash`, and it is why an idempotent re-run costs no compile call.
28. **Load-bearing orderings** (§19): checkpoint before advancing; counts before cascade; validate before repair; `traits_hash` only after the trait write commits.
29. **The `dates` rows are created BEFORE any turn runs, and re-running a pipeline reuses them.** That is what makes resume free — but it also means a failed run leaves date rows behind, and re-triggering `POST /simulate` will **not** regenerate the scenarios. To start genuinely fresh, delete the analysis's `dates` rows first.
30. **A `failed` analysis is resumable only if it has candidates.** `simulate_refusal()` is the gate; the UI mirrors it. Reconciliation relaunches only `matching`/`simulating` on boot — a `failed` one waits for the user's retry, on purpose.
31. **The `questions` table has a forward reference**: create `traits` before `questions`, or add the FK after both exist.
32. **`profile_embeddings` is the two-vector form** — `kind IN ('identity','preference')`, PK `(user_id, kind)`.
33. **Calibration chat and match chat share a widget but differ** in flagging and metadata rules. The difference lives in `ChatConfig`, passed in by the screen — a parameter, not a branch, so neither chat can inherit the other's behaviour by someone editing the shared file.
34. **The demo pool cannot match an 18-year-old.** Every profile's `age_pref_min` is 24 or higher, and matching's age rule is MUTUAL — so a legitimate 18-year-old user (the youngest the date picker allows) funnels to ZERO candidates and reads it as "the app found nobody". **Not a bug in the funnel — a gap in the fixture**, worth closing with a profile or two whose band starts at 18 before anyone demos this to a young user.

### Providers and quota

35. **An OpenRouter model id is NOT one thing** (D-008). It is served by several upstream providers, chosen per request, with different implementations. `dots-3-note-preview` served `trait_extraction` for a whole step and then began 400ing every such request via one upstream while serving other tasks fine on the same key. Consequences already in the code: a `"Provider returned error"` 400 is **transient** and retries (a retry is a fresh routing draw). **"Model X works" is not a durable fact. Re-measure; don't reason.**
36. **Debug provider faults by isolation, not by theory.** Three plausible explanations (schema too big, max_tokens, prompt size) were each falsified in about a minute by a script varying one factor at a time.
37. **Free OpenRouter models are slow and wildly variable** — `dots-3-note-preview` runs ~20–40 s per extraction and the whole class queues under congestion. **Budget minutes, not seconds**, for anything that chains several calls.
38. **`dots-3-note-preview` can return empty content with `finish=length` on trait extraction, and the retry costs two minutes.** Seen once at `latency_ms: 126637` — attempt 1 empty, attempt 2 fine. It self-heals, but **any HTTP client calling `POST /profile/extract` needs a read timeout well above two minutes**, because that endpoint runs the extraction inline. A 120 s timeout kills the client while the server carries on and finishes the work. (This is D-022; the app now uses the start-then-poll form.)
39. **A rate-limited call takes ~50 seconds to fail, on purpose.** Rate limits get their own backoff schedule (20 s, 30 s), separate from the 2 s/4 s used for dropped connections, because every quota this project meets is per-minute or per-day and three retries inside seven seconds all land in the same blocked window. **A slow failure is intended behaviour, not a hang.**
40. **`ai_routes_unresolved` and `provider_built … api_key_present: false` warnings at boot are correct behaviour**, not bugs.

### Code shapes that have already bitten

41. **`log_event` has reserved field names, and nothing warns you until that line runs** (D-010). Its signature is `log_event(logger, event, *, level, **fields)`, so `logger=`, `event=` and `level=` cannot be used as log FIELDS anywhere. `event=chosen` raised `TypeError` from inside the logging call and killed a pipeline **after** it had already spent a scenario call. Lint cannot see it; `**kwargs` keeps the call legal until execution.
42. **A JSONB column stores Python `None` as the JSON value `null`, not SQL NULL, unless you say `JSONB(none_as_null=True)`** (D-011 — *note: this defect has no entry in `DEFECTS.md`; the mechanism is recorded here*). `date_messages.state` did exactly this: environment rows looked null in every JSON payload and every Python read, while failing `state IS NULL` in SQL — which is precisely the predicate judging filters spoken turns on. Both `date_messages.state` and `analyses.progress` now set it; any new JSONB column whose NULL means something must too.
43. **Read what a failure path will log BEFORE the thing that can fail** (D-014, generalised by D-030). `rollback()` is a **session-wide** event: it expires every loaded row, and the next attribute read from async code raises `MissingGreenlet` — inside your `except`, turning an honest error envelope into a 500 and swallowing the log line. Capture ids into plain locals first. The safe shape is to roll back only when the SESSION failed (`SQLAlchemyError`), never as a reflex after a model failure that left nothing pending.
44. **Anything a compiled prompt STATES about a person can go stale, and `traits_hash` will not notice** (D-017). The persona prompt asserts name, age, gender, interested-in and city, so a rename left every agent using the old name silently. There is now a free repair (`refresh_identity`, no model call, new immutable version) — but **the seam it cuts on is the literal heading `WHO YOU ARE`**, kept as `persona.FACTS_HEADING`. Move or reword that heading and the repair stops working; `tests/test_identity_refresh.py` will fail loudly if you do.
45. **A widget test that builds its own router cannot see the router** (D-018), and **`MaterialApp.builder` sits ABOVE the router, so `GoRouter.of(context)` throws there** (D-019). Thirty-five green tests coexisted with a `/profile` nobody could navigate away from. `test/step18_navigation_test.dart` drives `routerProvider` itself — when you add a screen, add it to a branch there too. And **every affordance a test finds, it should press**: the "See results" button was asserted visible since Step 13 and never once tapped.

**Two standing rules that are not traps but belong beside them:** **decided things stay decided** (§23), and **audit `MePatch`'s fields against the rows on `/settings` whenever either changes** (D-020) — every field a form collects and every field the funnel filters on needs an answer to "and where does a person change it later?"

---

## Corrections made in this cleanup (2026-09-04)

Three claims in the previous PICKUP were checked against the code and found stale. They are corrected above:

1. **Model routing.** The file said `trait_extraction` was carried by `nvidia/nemotron-3-super-120b-a12b:free` and `dispute_followups` by `nvidia/nemotron-3.5-lightning:free`, and that "four `free-model-of-choice` slots remain deliberately unfilled". `server/config/ai.yaml` shows **all eight tasks pinned to `dots-studio/dots-3-note-preview:free`** and no slot unfilled. The file's own later note ("Settled 2026-09-01: the `trait_extraction` pin on `dots-3-note-preview` is intended") was the current truth and the earlier table was the leftover.
2. **Two duplicate O-numbers**, resolved by first use — see the numbering note under "Owed measurements".
3. **The traps list had six duplicate numbers** (two each of 22–28) and out-of-order suffixes (`3a`–`3h`). Renumbered 1–45 with no trap dropped.

Also corrected: the closing pointer said `DEFECTS.md (D-001…D-005)`; the ledger runs to **D-030**.

## Where the decisions live

- **What:** `user_perspective.md` → `project_description.md` → the module plans.
- **How:** `development_principles.md`.
- **Wire:** `communication_protocol.md`. **Order:** `IMPLEMENTATION_PLAN.md`.
- **What went wrong:** `DEFECTS.md` (D-001 … D-030) — append-only, per §21.
- **How this project got here:** `PICKUP_ARCHIVE.md` — per-step build notes, acceptance criteria as witnessed, and the gate measurements in full.
