# Development Principles

Scope: these principles govern how the `server` and `ux` submodules are built. The *what* lives in the spec documents — `user_perspective.md` (source of truth), `project_description.md` (architecture + decision log), `technical_details.md` (stack), and the module plans (`module_1_data_collection.md`, `ai_interaction.md`, `trait_persona.md`, `candidate_matching.md`, `date_simulation.md`, `chat.md`, `data_hygiene.md`, plus the `ux/*.md` files). This document is the *how*. Section numbers are stable — the module plans cite them (§7, §9, §12, §16, §17, §23…); never renumber.

Project artifacts these principles create and maintain:

| Artifact | Where | Principle |
|---|---|---|
| Committed probe scripts | `server/probes/` | §2 |
| Owed-measurements list | `PICKUP.md`, "Owed" section | §4 |
| Defect ledger | `DEFECTS.md` (project root, shared) | §21 |
| Dead-data scan | `server/scripts/scan_dead_data.py` | §22, `data_hygiene.md` |
| Decision log | `project_description.md` + per-module "trades named" | §20, §23 |
| Pickup document | `PICKUP.md` (project root) | §24 |

## A. Done means witnessed

1. A passing test is evidence about the test. A feature is done when you have observed it do the thing **on the running Docker stack, over real HTTP, against real Postgres, with a real model call where one is involved** — and can show that observation to someone else. Until then it is built, and "built" is the word you use when you report it.

   Never write "done", "works", "verified", or "✅" on the strength of code that reads correctly, a green suite, a clean build, or a convincing argument.

   Anything that keeps state has a first run that creates the state and a second run that consumes it — the witness must include the second run. In this system that is not a corner case, it is the product: startup reconciliation (first boot seeds BQ1–BQ5, PQ01–PQ30, demo profiles; second boot must be a no-op and log it), questionnaire save/resume (answer, kill the app, return to the right question), simulation resume (kill the server mid-date, restart, watch it continue from the last checkpointed message — not restart), answer editing (edit, re-extract, confirm the persona goes stale while old snapshots don't), and pool exhaustion (answer question 30, request a batch, get the defined state).

2. Every mechanism gets a committed probe. A probe is a script in `server/probes/`, named after the thing it proves, that drives the mechanism end to end against the real deployment and prints a verdict a human can read. Its output is the witness from §1. The minimum probe set, one per locked mechanism:

   - `probe_onboarding.py` — register, answer BQ1–BQ5 (with an edit mid-way), extract, compile; verify traits and snapshot exist.
   - `probe_pool_expansion.py` — batches of 5 in `pool_order`; abandon one mid-batch and resume; drive to exhaustion and verify the `pool_exhausted` payload.
   - `probe_answer_edit.py` — edit an old answer; verify holistic re-extraction, trait_events, stale embeddings/snapshot, and that a pinned snapshot in a past analysis did **not** change.
   - `probe_matching_filters.py` — users on each side of every hard filter (gender mismatch, one-directional interest, age out of range, opt-in off, no snapshot); verify each exclusion and the logged per-step pool counts; verify `partial` and `no_candidates` states.
   - `probe_simulation_resume.py` — start an analysis, kill the server mid-date, restart, verify continuation from checkpoint and a final complete analysis.
   - `probe_structured_guard.py` — force malformed output (a deliberately hostile schema/model combination); watch repair attempts, then the typed give-up; verify nothing downstream received a silent default.
   - `probe_judge.py` — same transcript judged twice; scores within tolerance; `date_score` recomputed by hand from the stored criteria matches the stored value.
   - `probe_deletion.py` — a user entangled everywhere (candidate in someone's analysis, active chat) deletes; verify the cascade counts, the survivor's tombstones, and that global questions survived.
   - `probe_demo_seeding.py` — wipe a demo user's traits; reboot; verify reconciliation rebuilt them through the real pipeline (provenance present, not shortcut rows).

3. Read the green probe. Do not skim a pass.

4. Owed measurements are debts, and the queue goes to zero. When you claim a mechanism works and the evidence is a test rather than a live observation, write it in the "Owed" section of `PICKUP.md`. Review the list. Drive it to empty.

5. Fix the blindness before the bug. When a run reveals you could not see something — a date failed and the logs don't say which turn, which provider, which outcome; a match came back empty and no filter-step counts were logged — fix the seeing first. Instrumentation gaps queue behind each other; each deployment surfaces one more, and N gaps cost N full cycles.

6. Report in the words the evidence supports. Tests passed → "tests passed". Observed on the stack → say it works, plainly. Built but not witnessed → "built, not yet witnessed", every time. Skipped, deferred, partial → say so unprompted, and say why. An earlier claim turned out wrong → correct it in one sentence and continue.

## B. The system explains itself, or it is not finished

7. The log line ships in the same commit as the feature. Every decision the system makes on its own leaves a trace naming what it decided, why (inputs, rule, threshold), what it did, and what it declined to do. The module plans already enumerate the required lines; they are obligations, not suggestions:

   - every AI call: task, provider, model, attempt, latency, outcome — `ok / malformed / rate_limited / refused / gave_up` (`ai_interaction.md` §5);
   - matching: pool size after each filter step, the three scores per selected candidate, and on `no_candidates` **which filter emptied the pool**;
   - simulation: every turn's outcome, every event-injection roll and chosen event, how each date ended (`mutual_wants_to_end` vs `cap`), every `analyses.status` transition with its reason;
   - extraction: input answer IDs, produced/updated/retracted traits; disputes and calibration flags as `trait_events`;
   - deletion: per-table counts before the cascade; reconciliation: what it seeded, re-launched, or found inconsistent.

   The test: from logs alone, reconstruct why any specific date ended, scored, or failed as it did — without a debugger. Truncated logging is worse than none. The failure and refusal paths are the ones that must log.

8. A flag is decorative until you have watched behaviour differ. This project's flags and gates, each owed a log line showing it consulted and an observation of both settings: `opt_in` (in vs out of the candidate pool), `is_demo` (labeled in every payload), the persona-snapshot gate (no snapshot → not a candidate), the one-active-analysis 409, the event-injection cap and no-consecutive rule, every give-up condition in §17, `pool_exhausted`, and the transcript-viewer metadata toggle.

## C. Do not manufacture certainty

9. A guess about the user is a question, never a fact. This is implemented, not aspirational: every `traits` row carries `confidence`, `status` (`inferred` until the user confirms), and `source_answer_ids` provenance; the UI renders inferred traits visibly as guesses (dotted border, "AI's read, not confirmed") with one-tap confirm/dispute. Never collapse this: no code path may treat an `inferred` trait as confirmed, and no new derived value (scores, reasons, digests) ships without provenance — which model, which rubric version, which inputs.

10. "Be specific" is an instruction to fabricate, unless refusing is spelled out. Every generation in this app has an explicit way to decline, and the declines are logged and counted: extraction may produce no trait from a thin answer; the judge reports clashes only with a citable moment — an empty `clashes` array is a valid verdict; matching reasons are computed from data, never composed (a fabricated "you both love hiking" is the canonical failure); the Structured Output Guard raises a typed error — never a silent default (`ai_interaction.md` §4).

11. Gate the promise on the capability. `PersonaService.get_current_snapshot` returning `None` means the user cannot be simulated — so they are not offered as a candidate, ever, rather than simulated degraded. Same shape everywhere: no ready embedding → re-embed before matching, don't compare stale; fewer than 3 eligible → run with fewer and say so; zero → `no_candidates`, never a fabricated match. Unmet actions stay unstarted and are re-evaluated later.

12. No trust bypasses — reconcile instead. Everything that must exist by default — BQ1–BQ5, PQ01–PQ30, demo profiles — is seeded by the startup reconciliation pass (`data_hygiene.md`) comparing desired state to actual state on every boot, flowing through the same pipeline as real data. Demo profiles get real answers, real extraction, real snapshots, real embeddings. There is no code path that skips verification because "it shipped with us".

13. Verify the precedent before you inherit it. "We already do this elsewhere" is a claim to check — go read the elsewhere. In this codebase the likely traps: assuming the calibration chat and match chat share behavior (they share a widget by decision, but flagging and metadata rules differ), assuming all questions behave like pool questions (dispute questions are per-user, AI-generated, and outside pool progress), and assuming every long operation follows the simulation's job pattern (extraction is synchronous with a queued follow-up, chat is request–response).

14. Every promise in the spec must be greppable to code. Each module plan ends with a "Locked by this document" list — that list is the audit checklist. Periodically walk each item to the code that implements it. The known accretion risks, written down so they get checked: the answer-edit staleness cascade (edit → traits → hash → embeddings → snapshot banner), the incomplete-date judging policy (≥10 messages, 0.5 weight), the no-consecutive-events rule, and the survivor-side tombstones after a deletion.

## D. Design

15. The wire dictates the design. This system's wire is free-tier model APIs: aggressive rate limits and unreliable JSON. That is why dates run sequentially under a global semaphore of 2, why every turn checkpoints before advancing, why the Structured Output Guard exists, and why the UI polls one `analyses` row instead of holding connections open. A feature that ignores these facts — parallel simulation, streaming, synchronous long requests — is designing up from an ideal wire we do not have. Name the missing pieces and ask for them instead.

16. One choke point beats checks sprinkled everywhere. Standing examples to extend, not duplicate: all structured model output flows through the one Guard in `app/ai/structured.py` — no module parses its own JSON; all provider access goes through `AIProvider` — no module imports a concrete provider; the UX has one `Poller` — no screen spawns its own loop; the onboarding gate lives in one go_router guard. A second implementation of any of these is a defect, not a convenience.

17. Every retry, escalation, and feedback loop needs a give-up condition. The committed ones: 3 validation-repair attempts per structured call, then a typed error; 3 attempts per simulation turn, then the date goes `incomplete` and the pipeline moves on; one queued follow-up extraction per user, never a pile-up; one active analysis per user. A new loop ships with its give-up condition in the same commit, and §8 applies: the give-up must be observed firing at least once.

18. A rule written for one case is a trap in the case it did not consider. Write the scope down and check the boundary immediately. Current examples with their scopes stated: the 50-character minimum (owner decision 2026-09-01, lowered from 200) applies to baseline, pool, *and* dispute answers; "edits are forward-looking only" applies to answers *and* trait disputes, and pinned snapshots are the enforcement; "one selection per analysis" does not mean one chat ever — a new analysis makes a new session; the 30-message date cap counts environment events as messages.

19. Ordering is a mechanism, not a formatting choice. Load-bearing orderings in this system, never to be "simplified": checkpoint the message row **before** advancing the turn; log the per-table counts **before** the deletion cascade; validate against the schema **before** any repair prompt; bump `traits_hash` only **after** the trait write commits, so staleness can never claim freshness.

20. Name the trade. Every decision that costs something has the cost written down in plain language — "the consequence of this is X; we accept it because Y" — in the decision log (`project_description.md`) or the owning module's "Technical decisions (trades named)" section. The standing examples set the bar: no Celery means restart kills in-flight tasks, accepted because checkpoints resume; a friend's deletion punches holes in your history, accepted because privacy beats history. A new decision without a named trade is not decided yet.

## E. Keeping it honest over time

21. Keep a numbered, append-only defect ledger in `DEFECTS.md` at the project root — every defect that got past you, with mechanism, discovery method, and lesson. One shared ledger for both repos; a UX defect caused by a server contract counts once, cross-referenced.

22. Scan for dead code and dead data periodically. Script it. The data half already exists as an obligation: `scripts/scan_dead_data.py` (`data_hygiene.md`) — abandoned registrations, failed snapshots/analyses, orphaned running dates. Add a dead-code pass per repo alongside it. Report only; deleting real users' data is always a human decision.

23. Decided things stay decided. The spec documents carry the decisions and this project already has the convention: a revision names the new information and the date, inline, where the old decision stood — the way "single provider, switching deferred" became dual-provider (owner requirement, 2026-09-01) and the AI question generator became the curated pool (owner decision, 2026-09-01). Do not reopen a decision for a mild alternative, and do not silently drift from one. The locked lists at the bottom of each module plan are the register of what is decided.

24. Maintain one pickup document: `PICKUP.md` at the project root. What the state is, what was just finished, what is next, what is blocked and on whom, what traps will bite someone resuming cold, and the "Owed" measurements list (§4). Written for someone with no memory of the last session, because periodically that is exactly who reads it — including the module build order and which probes currently pass. Update it as part of the work, not as a task afterwards.

25. Escalate real conflicts in plain language; decide everything else yourself. The owner's calls are already on record (friends-only pool, free models, no quotas/moderation this phase, simple consent, curated pool) — build on them without re-asking. When two locked decisions genuinely collide, or a call is the owner's (their friends' data, their taste, re-scoping toward strangers), put it in layman's terms: what each option means for them, what you recommend, why. Every routine judgement call: decide it, state what you assumed, keep moving.

26. Whenever explaining anything — a decision, a failure, a trade — use layman's terms. If a nine-year-old couldn't follow the sentence, rewrite it. This applies to UI copy doubly: "there is no one to match you with yet", never "candidate retrieval returned an empty set".

## Definition of done

A change is finished when all of these are true:

1. The code is written and reviewed.
2. Automated tests cover it, and they pass.
3. It emits the log lines §7 requires for it — including on its refusal and failure paths.
4. It has been observed working on the running Docker stack, in the real flow, on at least the second run where state is involved (§1).
5. A committed probe in `probes/` reproduces that observation on demand (§2).
6. Its failure and refusal modes have each been observed at least once, or are written in `PICKUP.md` as owed measurements (§4).
7. Any trade it makes is named in the decision log or its module plan (§20).
8. Anything it revealed is in `DEFECTS.md`, with mechanism, discovery method, and lesson (§21).
9. `PICKUP.md` reflects the new state (§24).
10. What you told the owner about it matches which of 1–9 are actually true (§6).
