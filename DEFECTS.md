# DEFECTS

The numbered, append-only defect ledger for this project (`development_principles.md` §21). **One shared ledger across all three repositories** — the `dating_app_ai` superproject and both submodules, `server` and `ux`. It lives at the superproject root because that is the only place both submodules can be spoken about at once. A UX defect caused by a server contract is recorded **once**, on the side where the cause lives, and cross-referenced from the side where it surfaced.

**Started:** 2026-09-01.

---

## How to use this file

**Append only.** Entries are never edited away, never renumbered, never deleted. A defect that turns out to be something else gets a correction appended to its own entry, with a date. The ledger's value is that it is a complete record of what got past us — a tidied ledger is a lie about our own history.

**Every entry carries four things**, because those are what make it useful a year later:

| Field | Why |
|---|---|
| **Mechanism** | What actually broke, in mechanical terms — not "matching was wrong" but "the hard filter compared age in one direction only" |
| **Discovery method** | *How* it was found: a probe, a live run, a document-to-code diff, a user hitting it. This field is the one that improves the process — if defects are consistently found by users rather than probes, the probes are the problem |
| **Lesson** | What to do differently. If the lesson is "be more careful", the entry is not finished — find the structural version |
| **Status** | `open` (with the ticket that will close it) or `closed` (with what closed it and when) |

**What belongs here.** Anything that got past you: a bug found in a live run, a spec promise with no code behind it (`§14`), a contract drift between a module plan and `/docs` (`communication_protocol.md` §7 — drift *is* a defect), a flag that was decorative because its behaviour was never observed (`§8`), a retry loop that shipped without its give-up condition (`§17`), a log line that was missing when it was needed to explain a failure (`§7`).

**What does not belong here.** Work that is simply unbuilt, and work visibly in progress. The roadmap tracks the first; `PICKUP.md` tracks the second. An unwritten feature is not a defect; a feature claimed done that was not witnessed **is**.

**Entry template:**

```
## D-NNN — one-line title

- **Date:** YYYY-MM-DD
- **Repo:** dating_app_ai | server | ux | multiple
- **Surfaced in:** (where it showed up, if different from where it lives)
- **Mechanism:**
- **Discovery method:**
- **Lesson:**
- **Status:** open (ticket) | closed (what closed it, date)
- **Cross-refs:**
```

---

## D-001 — a module plan's file-layout block was not treated as a checklist

- **Date:** 2026-09-01
- **Repo:** `server`
- **Mechanism:** `ai_interaction.md` §1 lays out the eight files of `app/ai/`. In an early draft of that module, seven were written and `registry.py` — the component that builds provider instances from config and maps `name -> instance` — was not. `routing.py` had been written against its contract: `TaskRouter.__init__` takes `providers: dict[str, AIProvider]` and validates the routing table against its keys, and nothing produced that dict. The layer could not be constructed at all.
- **Discovery method:** Document-to-tree diff while writing `IMPLEMENTATION_PLAN.md` — reading §1's file layout as a checklist against a directory listing. Found **before** any claim of completeness was made, so nothing false was reported to the owner.
- **Lesson:** A module plan's file-layout block is a checklist; diff it against the directory before treating a module as complete. The sharper half: **an absent file hides better than a stubbed one.** The unimplemented providers in that draft carried explicit `NotImplementedError` and TODO comments, so their incompleteness announced itself on sight. A missing file announces nothing, because it is not there to announce it. Write every file the layout names, even the ones you are not implementing yet — a stub is a promise you can see.
- **Status:** **void** — the draft it describes was discarded for a clean start (2026-09-01) before anything was built on it. Retained per §21 (the ledger is append-only; a tidied ledger is a lie about our own history) because the lesson applies directly to the Step 2 rebuild, where it is written into the ticket set as a standing instruction.
- **Cross-refs:** `server/ai_interaction.md` §1 (the layout); `IMPLEMENTATION_PLAN.md` Step 2 preamble.

## D-002 — `flutter create` scaffolded the app into the superproject root, not `ux/`

- **Date:** 2026-09-01
- **Repo:** `multiple` (surfaced at the superproject root; the file belongs in `ux`)
- **Mechanism:** The Step 1 ticket S1-U1 says "flutter create the app in `ux/`". The command was run as `flutter create … .` relying on the shell's *remembered* working directory — which was still the superproject root from the preceding Docker work. The generator dutifully scaffolded ~14 files and directories (`lib/`, `android/`, `pubspec.yaml`, a root `README.md`, …) into the repo that is supposed to hold only specs and infrastructure. No existing file was overwritten (verified by timestamp before cleanup), the strays were deleted, and the create was re-run inside `ux/`.
- **Discovery method:** Immediate post-command verification — checking `Test-Path .\pubspec.yaml` vs `.\ux\pubspec.yaml` right after the generator ran, before anything was built on top of it.
- **Lesson:** A generator that targets "the current directory" inherits whatever directory the last unrelated command left behind. The structural fix: never point a scaffolding tool at `.` — give it the explicit absolute target path (or `Set-Location` *in the same command*), and diff the tree immediately after any generator runs, because generators write many files fast and in exactly the place you didn't look.
- **Status:** closed (strays removed, re-run in `ux/` verified, 2026-09-01)
- **Cross-refs:** `IMPLEMENTATION_PLAN.md` S1-U1; repository-layout table in `PICKUP.md`.

## D-003 — the package build only worked while sibling directories were empty

- **Date:** 2026-09-01
- **Repo:** `server`
- **Surfaced in:** `pip install '.[dev]'` inside the running api container, while setting up the Step 2 test run.
- **Mechanism:** `pyproject.toml` declared no package layout, so setuptools *auto-discovered* it. At Step 1 that silently resolved to just `app/` — because `probes/` held only a README and `tests/` did not exist. The moment Step 2 put `.py` files into `probes/` and `tests/`, discovery saw multiple top-level packages (`app`, `config`, `probes`, `migrations`) and the build failed: `Multiple top-level packages discovered in a flat-layout`. The Step 1 claim "the dependency set installs together" (S1-B9) was true, but it was witnessed on a tree shape that no longer exists — the packaging config was load-bearing on an accident.
- **Discovery method:** Live run — the very next `pip install` after adding probe/test files failed loudly. Also left a stray `build/` artifact in the bind-mounted source tree, now git-ignored.
- **Lesson:** Never let a build tool *infer* structure that the specs define explicitly; the inference is re-run on every future tree shape, including ones that don't exist yet. Declare it: `[tool.setuptools.packages.find] include = ["app*"]`. The general form: a configuration that works by default is only proven for the tree it was tested on — pin what must stay true.
- **Status:** closed (explicit package declaration; full `docker compose build` re-verified green the same day)
- **Cross-refs:** `IMPLEMENTATION_PLAN.md` S1-B9; `server/pyproject.toml`.

## D-004 — a baked site-packages copy of `app` silently shadowed the bind-mounted live code

- **Date:** 2026-09-01
- **Repo:** `dating_app_ai` (the Dockerfile), surfaced in `server` scripts
- **Mechanism:** The Dockerfile's `pip install .` put a frozen copy of the `app` package into site-packages at build time. The dev workflow bind-mounts `./server` over `/app`, and uvicorn (run from `/app`) resolved the live code — but any script run as `python scripts/x.py` gets `scripts/` as `sys.path[0]`, falls through to site-packages, and imports the **stale snapshot**. It surfaced as a loud `ModuleNotFoundError` for the just-added `app.reconcile` — the lucky case. The unlucky case it implied: a probe importing a stale-but-importable `app` would have run *yesterday's code* and printed a verdict about it, silently.
- **Discovery method:** Live run of `scripts/run_reconcile.py` inside the container (Step 3, S3-B6).
- **Lesson:** In a bind-mount dev workflow there must be exactly ONE authoritative code location on `sys.path`. The fix: install dependencies from the lockstep layer but `pip uninstall` the package copy, then `pip install --no-deps -e .` after COPY — the editable install points at `/app`, so image-only and bind-mounted runs both resolve the same, current code. The general form: "it worked for the app entry point" says nothing about the other entry points; each way code gets executed (server, scripts, probes) resolves imports its own way and each needs the witness.
- **Status:** closed (Dockerfile editable-install fix; rebuilt, and both a script and a probe re-witnessed importing live code, 2026-09-01)
- **Cross-refs:** `Dockerfile`; `IMPLEMENTATION_PLAN.md` S1-D2, S3-B6; D-003 (the same file's previous packaging trap).

## D-005 — a registration that succeeded server-side showed the user nothing at all

- **Date:** 2026-09-01
- **Repo:** `ux`
- **Surfaced in:** The Step 4 register-through-the-UI witness.
- **Mechanism:** The submit handlers caught only `ApiException` (the server's envelope). During the witness, the token save threw a *platform* exception instead (`DataError: AES key data must be 128 or 256 bits` — the browser test had corrupted flutter_secure_storage's own AES key entry). The throw happened AFTER the server had created the account, and nothing caught it: no error text, no navigation, no state change. The user's tap did nothing visible while the account silently came into existence — the second tap then honestly reported "already registered", which is how it was noticed. `TokenStore` had the same fragility on load/save/clear: any storage failure would propagate raw.
- **Discovery method:** Live UI run in the browser, plus the uncaught-promise error in the browser console. The storage corruption itself was self-inflicted by the tamper test — but the silent-catch structure would have swallowed ANY non-API failure (blocked browser storage, missing platform keystore) the same way.
- **Lesson:** The failure branch you *typed* is the only failure branch you handle. A submit path needs a catch for "everything else" that still puts words on the screen — an invisible failure after a server-side success is the worst failure mode a form can have. Structurally: every user-triggered async action ends in exactly three visible outcomes (success navigation, envelope message, generic device-error message), and storage wrappers degrade to in-memory rather than throwing into UI code.
- **Status:** closed (catch-alls in login/register submit + resilient TokenStore; register re-witnessed green end-to-end, 2026-09-01)
- **Cross-refs:** `ux/lib/core/auth/token_store.dart`, `ux/lib/features/auth/*_screen.dart`; ux_architecture.md §1.5 (the four-state rule this violated in spirit).

---

## D-006 — the Flutter web app could not reach the API at all: dev CORS admitted `localhost` but the app can only be served from `127.0.0.1`

- **Date:** 2026-09-01
- **Repo:** `server` (cause) — surfaced in `ux`
- **Surfaced in:** The first "run the whole thing locally" attempt of a fresh session. Steps 1–5 were all witnessed working, so the stack was believed runnable; it was not, from a cold start, without knowing one undocumented fact.
- **Mechanism:** Two correct-looking settings that are individually right and jointly fatal. (1) `Settings.cors_origin_regex` was `http://localhost(:\d+)?` — its comment says "dev CORS admits any localhost origin", but the regex admits only the *name*, not `127.0.0.1`. (2) On Windows, `flutter run -d web-server --web-hostname localhost` binds **IPv6-only** (`::1`); the page then loads over HTTP but dwds' debug websocket (`ws://localhost:PORT/$dwdsSseHandler`) fails, and the app hangs forever at "DDC is about to load 740/740 scripts" — a black screen with no error on the page. So the only hostname the dev server actually works on is `127.0.0.1`, and that is precisely the origin CORS rejected. Serving on `localhost` to satisfy CORS breaks the app before it boots; serving on `127.0.0.1` to boot the app gets every request blocked at the preflight. The visible symptom was the login form reporting "Couldn't reach the server — is it running?" while the server was healthy and answering the identical request over curl.
- **Discovery method:** Live run from a cold start, then the browser console (`No 'Access-Control-Allow-Origin' header`, then `WebSocket connection to 'ws://localhost:5000/$dwdsSseHandler' failed`). Not reachable by any probe: every probe runs *inside* the api container over `localhost:8000`, where there is no browser, no Origin header, and therefore no preflight. The entire probe suite was GREEN throughout.
- **Lesson:** **A server-to-server probe cannot witness a browser-only failure mode.** CORS, mixed content, cookie policy, and websocket upgrades exist only when a browser is the client, and this project's probes deliberately run in-container — so that whole class is invisible to them by construction. The structural fix is not "add CORS to a probe" but to treat *the app reaching the API from a browser* as its own witness step, run from a cold start, on every environment the app is served from. Secondary lesson: when a setting's comment states an intent ("any localhost origin") and its value implements something narrower, the comment is the requirement and the value is the bug — `127.0.0.1` and `localhost` are the same origin to a human and different origins to a browser.
- **Status:** closed (regex widened to `http://(localhost|127\.0\.0\.1)(:\d+)?`, preflight verified returning `access-control-allow-origin: http://127.0.0.1:5000`, and the full login → `/me` → home flow re-witnessed in the browser, 2026-09-01). The dev-only scope is unchanged; the hosting/CORS posture decision stays deferred to the owner.
- **Cross-refs:** `server/app/config.py` (the regex and its revised comment), `server/app/main.py` (the one CORSMiddleware), PICKUP trap on the `127.0.0.1` binding.

---

## D-007 — trait extraction grew the profile by one trait per run, on answers that had not changed

- **Date:** 2026-09-01
- **Repo:** `server`
- **Surfaced in:** The first run of `probe_answer_edit.py` (S6-P1/P2), before Step 6 shipped.
- **Mechanism:** The first version of the extraction system prompt described `additions` as being for "genuinely new traits" and said nothing about the situation the call is almost always actually in — re-reading answers it has already read, against a list already built from them. On a no-edit re-run the model returned all eight existing rows as `keep` (correct) and then *also* added a ninth: "Repelled by contempt and control", a `partner_preference` re-slicing the same BQ2 dealbreaker sentence that two existing `partner_preference` rows already covered. No new information, one more row. Because every future run re-reads the enlarged list, the growth compounds: the profile gets longer on every extraction while getting no truer, and each new row dilutes the matching signal and the persona digest built from it.
- **Discovery method:** `probe_answer_edit.py`'s drift alarm (S6-P2) on its very first run — the assertion that a no-edit re-run writes no `trait_events` and leaves `traits_hash` byte-identical. It failed with `added=1`. Note what did NOT catch it: the same code had already been run against a real 35-answer account (`bob`) and produced a clean all-`keep` second run. One passing example proved nothing; the probe with the explicit alarm found it on a different user's richer answers immediately.
- **Lesson:** **A reconciliation prompt has to describe the situation the call is usually in, not the situation it is nominally for.** "Add genuinely new traits" is a correct description of the *field* and useless as an *instruction*, because on a re-read the honest answer is almost always "add nothing" and the model has no way to know that from the field description alone. The fix states the default explicitly (on a re-read expect `keep` everywhere and an EMPTY additions list), names the failure mode in the model's own terms (re-slicing ground an existing entry already covers is drift), and says why it matters (it compounds, because you will re-read again). Structurally, the lesson that generalises: **every idempotent AI operation needs its no-op case spelled out in the prompt AND an alarm asserting the no-op actually happens** — A5.1 already required the alarm, which is the only reason this was a twenty-minute fix instead of a profile that silently bloated for weeks.
- **Status:** closed (prompt hardened in `app/extraction.py`; `probe_answer_edit.py` re-run GREEN with `kept=6 updated=0 retracted=0 added=0` and an unchanged `traits_hash`, 2026-09-01)
- **Cross-refs:** `server/app/extraction.py` (SYSTEM_PROMPT, and the re-read note appended to the user prompt when handles exist), `server/probes/probe_answer_edit.py`, module_1_data_collection.md A5.1 (which specified the alarm).

---

## D-008 — one OpenRouter model id is several upstream providers, and one of them broke a whole task

- **Date:** 2026-09-01
- **Repo:** `server`
- **Surfaced in:** Step 7's `probe_onboarding.py`, which could not get past `POST /profile/extract`.
- **Mechanism:** OpenRouter serves a single model id from **several upstream providers** and picks one per request. `dots-studio/dots-3-note-preview:free` had been serving `trait_extraction` correctly (Step 6 closed on it), then began answering **every** `trait_extraction` request with `400 {"message":"Provider returned error", ..., "provider_name":"AtlasCloud"}` — while the SAME model, on the SAME key, served `persona_digest` and `chat_reply` fine seconds apart. Our resilience layer classified a 400 as a client error and therefore fatal, so the whole onboarding chain died on what was an upstream fault we had no part in. The first two fixes were both wrong because they assumed the fault was ours: broadening the `response_format` fallback (it 400d in prompt mode too, so the schema was not the trigger) and sending `provider: {require_parameters: true}` (still routed to the same failing upstream). A controlled isolation run then showed plain calls to that same upstream succeeding at `max_tokens=8192` with a long prompt — ruling out size, parameters, and the schema.
- **Discovery method:** The probe, then a hand-written isolation script that varied one factor at a time (max_tokens, prompt length, system prompt, schema) against the same model. The isolation is the part that mattered: three plausible theories were each falsified in about a minute, where reasoning about them would have taken longer and settled nothing.
- **Lesson:** **A model id from an aggregator is not one thing.** "Model X works" is not a durable fact when X is served by a rotating set of providers with different implementations — Step 6's shootout proved the MODEL could satisfy the schema, and that remained true while the pipeline was broken. Two structural consequences, both taken: (1) an aggregator saying *the upstream failed* (`"Provider returned error"`) is **transient**, not fatal — it must go through the retry ladder like a 429, because a retry is a fresh routing draw; (2) **per-task routing exists so one task's broken provider cannot force a global change** — `trait_extraction` moved to `nvidia/nemotron-3-super-120b-a12b:free` (the Step 6 shootout's other passing model) while everything else stayed put. The wider lesson for the gates: free-tier model choice is not a decision made once. It needs re-measuring, and the config comments now carry the evidence so the next person does not re-derive it.
- **Status:** closed (upstream 400 reclassified as `TransientAIError` in `app/ai/openrouter.py`; `trait_extraction` re-routed in `config/ai.yaml`; `probe_onboarding.py` GREEN end to end, 2026-09-01)
- **Cross-refs:** `server/app/ai/openrouter.py`, `server/config/ai.yaml` (the pin carries the reasoning inline), `server/probes/probe_onboarding.py`, PICKUP trap 12c.

---

## D-009 — a prompt fix taught the model to write identifiers into the `label` field, and a probe passed vacuously over the wreckage

- **Date:** 2026-09-01
- **Repo:** `server`
- **Surfaced in:** Step 9. Hand-inspecting the database after `probe_matching_filters.py` reported GREEN.
- **Mechanism:** Two failures, and the second is the more serious one.
  1. **The defect.** Step 9's first extractions were producing traits whose `label` was `T1`, `T2` … `T11`. The `description` fields were excellent and fully grounded ("He enjoys restoring old bicycles and motorbikes, often working alone on the balcony…") — only the label was ruined. **The cause was a fix of mine from an hour earlier.** To stop the model returning verdicts on a first read (there being no traits to judge), I had written "a verdict refers to an existing trait handle (T1, T2, ...)" into the prompt. The model stopped misusing `verdicts` — and started copying that `T`-pattern into the `label` field of its additions instead. The instruction that removed one failure supplied the vocabulary for the next.
  2. **The probe said GREEN anyway.** `shared_interests` intersects trait LABELS, so it was comparing `"T1"` against `"T7"` for two people who both restore bicycles, and returned `[]`. The AC6 assertion had been written to skip when nothing was shared — so it passed, *reporting its own vacuity in the detail string*, and I read the GREEN and nearly moved on. Compounding it, I had launched the probe several times without killing earlier runs: they shared one output file (so the header came from one run and the PASS lines from another) and left old probe users with `ready` snapshots in the pool, so the requester matched a PREVIOUS run's candidate.
- **Discovery method:** Not the probe. A hand query of `traits` after the probe went green — `SELECT label` — because empty `shared_interests` between two people who obviously share an interest did not smell right. §5's "fix the blindness before the bug" applies to the probe itself here.
- **Lesson:** Three, in order of how much they generalise.
  1. **A prompt is an input, and every identifier you put in front of a model is vocabulary it may reuse in the wrong field.** Naming the handle format inside an instruction about a DIFFERENT field was enough. Prompt fixes need the same "what else could this change" question as code fixes — they are not free.
  2. **Never let the model's own scaffolding be storable.** The structural fix is not the prompt, it is `_IDENTIFIER_LIKE` in `app/extraction.py`: an addition whose label matches `T1` / `BQ1` / `PQ07` is dropped and logged, because those strings are things THIS CALL put in front of the model, and none of them is ever a label. A model can always do this again; a guard cannot forget.
  3. **A conditional assertion that skips when its subject is missing will pass on exactly the runs where the subject went missing because of a bug.** The AC6 check "every shared interest is present in both" is vacuously true when nothing is shared — which is the symptom. A probe assertion whose precondition can be destroyed by the defect it is testing for is not an assertion. It now demands a non-empty intersection on a pair built to share one.
  Operationally: **one probe run at a time, and clean up the users it leaves behind** — concurrent runs sharing an output file produced a report that was a splice of two different runs.
- **Status:** closed (prompt no longer names the handle format; `_IDENTIFIER_LIKE` guard added and unit-checked; 13 polluted `probe-match-*` accounts deleted; probe re-run from a clean pool)
- **Cross-refs:** `server/app/extraction.py`, `server/probes/probe_matching_filters.py`, PICKUP trap 3e.
