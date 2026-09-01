# Project Description — Architectural Breakdown

Aligned with `user_perspective.md` (the source of truth). Supports dynamic profile expansion, multi-date simulations, environment-specific matching, random event injection, and per-turn internal-state tracking of the AI agents.

### Server Repository

**1. Data Collection & Dynamic Profiling Module**

- **Database Schema Management:** Structured storage of user accounts, hard-filter fields (age, gender, orientation, location, matching preferences), raw questionnaire answers, generated dynamic questions, and the evolving "traits profile." Every inferred trait is stored with provenance (which answers produced it) and a confirmed/disputed flag — inferred values are hypotheses until the user confirms them.
- **CRUD Operations:** Standard operations for user personal data and form answers. Includes full account deletion (answers, traits, embeddings, transcripts) and full data export.
- **Public Matching Opt-In:** A privacy toggle that flags a user's profile as available for matching. A simple toggle with a one-line description — the pool this phase is friends only, so no heavier consent flow.
- **Question Pool & Expansion:** A curated, pre-defined pool of ~30 extra questions (`PQ01`–`PQ30` in `module_1_data_collection.md`, six per probe area: interests and how they're approached, ideal partner criteria, situational reactions, conversational aptitude, self-image). Users expand their profile in fixed batches of 5; the `answers` table tracks what's been answered; when all 30 are done the system reports a graceful `pool_exhausted` state and stops offering questions. *(Revised 2026-09-01 from the AI-generated Dynamic Questionnaire Generator — curated pool gives uniform coverage, zero generation failures, and comparable profiles; the only AI-generated questions left are dispute follow-ups.)*
- **Answer Editing & Progressive Profile Expander:** Any past answer can be edited through the same upsert path; extraction then re-reads the full answer set and reconciles the traits profile (holistic, not incremental), which cascades to stale embeddings and a stale persona snapshot — forward-looking only, pinned snapshots in past analyses stay untouched. Runs synchronously on submit — no background service at this scale. The profile is stored as structured traits, not one ever-growing prose blob, so the persona prompt is rebuilt from current traits and does not grow without bound.
- **Trait Dispute Handling:** When the user marks a trait wrong, generate one follow-up question, correct the trait, and log the correction.

**2. Trait Prompting & Persona Module**

- **Data Ingestion:** Retrieves baseline answers, dynamic answers, and calibration corrections ("I'd never say that" flags) from the Data Collection Module.
- **Persona Compilation:** Uses few-shot prompting to translate the structured traits into a behavioral and psychological profile: how the user handles tense situations, their flirting style, conversational skill level, how they engage with hobbies, and — critically — how they actually phrase things, learned from their own written answers and calibration feedback.
- **System Prompt Generation:** Packages the compiled persona into a strict, optimized system prompt.
- **Response Schema Enforcer:** Forces structured JSON output containing: spoken response, state of mind, emotional state, connection level (0–100), satisfaction (0–100). **The schema carries a version number** stored with every transcript, so a later schema change does not break stored data or the judge pipeline.
- **Calibration Chat Endpoint (optional feature):** Drives the "meet your AI self" chat and feeds "I'd never say that" flags back into the profile. Persona fidelity was validated by hand (2026-08-31), so this does not gate matchmaking — it is a refinement tool.

**3. Candidate Matching Module**

- **Hard-Filter Pre-Pass:** Before any semantic work: mutual gender/orientation fit, both users' age-range preferences satisfied, distance, opt-in status. Trait matching never sees candidates who fail these.
- **Profile Vectorization:** Converts the traits profile into embeddings.
- **Storage:** Embeddings live in the main Postgres database via pgvector. No separate vector database — at this scale a dedicated vector store is pure overhead.
- **Semantic Similarity Engine:** On analysis trigger, compares the user's embedding against the filtered, opted-in pool and returns the top 3 candidates. Similarity is the v1 heuristic for compatibility; "complementary traits" is explicitly deferred until there is evidence similarity fails. Fewer than 3 eligible → run with what exists and say so; zero → report honestly, never fabricate.

**4. Date Simulation Module**

- **Interest-Based Scenario Initialization:** Analyzes overlapping interests of user and candidate to assign date settings. **2 dates per candidate, max 6 per analysis, each capped at 30 exchanges.**
- **Multi-Agent Orchestration:** Manages conversational turns between the two agents, each adhering strictly to its persona.
- **Event Injection:** A per-turn probability roll inside the orchestration loop (no separate cron/scheduler). When it fires, an environmental event is inserted and the agents must adapt.
- **State & Emotion Tracking:** Parses the structured output every turn, logging state of mind, emotional state, connection, and satisfaction for analytics.
- **Checkpointed Execution:** Every completed turn is persisted. On model error or rate limit, the simulation resumes from the last completed turn. Retries have a give-up condition (e.g., 3 attempts per turn); a date that gives up is marked incomplete and reported — the analysis proceeds with whatever finished. Free-tier models rate-limit aggressively, which makes checkpointing the load-bearing piece of this module. Simulations run in the background; the user is notified on completion and results are permanently viewable.
- **AI Judge Evaluation Pipeline:** Scores completed transcripts with an LLM judge strictly instructed to evaluate specific conversational criteria (clashing traits, conversational flow) and derive the 0–100 match score from those exact checks, plus the clicked/clashed analysis. Judged at low temperature; the model ID and rubric version are logged with every score so scores stay explainable and comparable.

**5. AI Interaction Module**

- **Dual Provider:** Google AI Studio and OpenRouter (free models) are both implemented from day one, behind one `AIProvider` interface. A per-task routing config maps each task (question generation, trait extraction, date simulation, judging, embeddings) to a provider + model; swapping a model is a config edit, never a code change. The embedding model is pinned separately — every stored vector must come from one model or similarity search is meaningless. Full architecture in `ai_interaction.md`.
- **Structured Output Guard:** JSON validation with repair-and-retry and a give-up condition; malformed-output failures are logged with the raw response. Free models hold structured output less reliably, so this guard is mandatory, not optional.
- **No cost guardrails this phase:** free models mean no quotas, no spend ceiling, no token accounting. The rate-limit handling lives in Checkpointed Execution instead.

**6. Chat Module**

- **Session Management:** Maintains the chat session between the human user and the AI persona of their chosen match. Direct human-to-human routing is out of scope this phase; the chosen person is not notified.
- **Context & History Tracking:** Stores chat history and feeds the persona its system prompt plus a summary of the simulated dates. The persona refers to those dates as simulations, never as real shared memories.

**7. Data Hygiene**

- **Demo Profile Labeling:** Seeded profiles used to fill the pool are flagged in the schema and visibly labeled in every UI surface.
- **Account Deletion:** Removes answers, traits, embeddings, and transcripts involving the user's persona.
- *(Content moderation and data export are out of scope this phase — the pool is friends, not strangers.)*

---

### UI/UX Repository

**1. New User Creation**

- **Registration Flow:** Email + password, age gate (18+), hard-filter fields (gender, orientation, location, matching preferences).
- **Baseline Questionnaire Form:** ~20 questions, progress saved per answer, resumable. Up-front honesty framing and a plain statement of how long it takes and why.

**2. User Profile & Settings**

- **Trait Display with Dispute Control:** Shows AI-extracted traits (qualities, flaws, behavioral markers, conversational skill), each with a "this is wrong" control. Refreshes automatically after new answers.
- **Persona Calibration Chat (optional):** The "meet your AI self" screen with per-message "I'd never say that" flagging. Reachable from the profile; does not gate matchmaking.
- **Progressive Profile Expansion UI:** An "Answer 5 more questions" action with pool progress ("15 of 30 answered"), serving the next batch from the question pool; a graceful completed state once the pool is exhausted. Past answers are editable from the same interface.
- **Settings:** Opt-in toggle (one-line description), account deletion.

**3. Main Dashboard**

- **Analysis Trigger Hero:** The "Find the Right Person" CTA.
- **Analysis History:** Past analyses with their results, revisitable.
- *(The global browsable user feed is cut: it leaks traits to everyone, adds a browsing step, and contradicts the core promise that the system finds the person. Visibility control lives in Settings.)*

**4. Simulate Date Page**

- **Top 3 Match Display:** The candidates pulled by the algorithm and why (shared interests). Honest states for "only N candidates found" and "no one to match you with yet."
- **Candidate Breakdown:** Expandable cards showing candidate profiles before simulation.
- **Simulation Execution Trigger:** "Start Simulated Dates" for all candidates.

**5. Simulation Execution & Results**

- **Background-Safe Progress:** Stage-by-stage progress ("Simulating Date 1 at the Car Show…"), plus an explicit "you can leave — we'll notify you" affordance. Failure and partial-completion states are designed, not just the happy path.
- **Enhanced Transcript Viewer:** Chat UI with the conversation text, per-message internal-state badges (emotional state, state of mind, connection), and inline blocks marking injected events. Incomplete dates are labeled as such.
- **Post-Date Analytics Dashboard:** Satisfaction statistics per peer, clicked/clashed analysis, and the 0–100 match score per candidate.

**6. Chat Selection & Further Actions**

- **Match Selection Button:** Pick the one person to pursue.
- **Live AI Chat Interface:** Chat with the AI persona of the selected match.
- **Navigation Controls:** End chat, answer more questions, or trigger a new analysis.

---

### Decision Log (trades named)

1. **Dual provider (Google AI Studio + OpenRouter free models), per-task config routing.** Consequence: the structured-output guard must handle heterogeneous models from day one, which is more build effort up front. Accepted because the owner explicitly requires running free OpenRouter models now and paid Google models later without rewrites. *(Revised 2026-09-01 from "single provider, switching deferred" on that requirement; all model output is validated through one choke point, and every stored artifact records the model that produced it.)*
2. **pgvector instead of a dedicated vector DB.** Consequence: re-platforming needed above ~100k profiles. Accepted because the pool is friends-only for this phase.
3. **2 dates × 3 candidates, 30-exchange cap.** Consequence: less simulation depth. Accepted because free-tier rate limits bound run time and nobody reads 9 long transcripts. *(Revised 2026-08-31: daily analysis quotas dropped — free models, so cost is not a constraint.)*
4. **Full internal-state metadata of both agents is shown to the searching user, behind a simple opt-in toggle.** Consequence: candidates' simulated reactions are visible to others. Accepted because the pool is friends who know what the app does; real strangers are explicitly out of scope. *(Revised 2026-08-31: heavy consent copy dropped on owner's decision — friends-only pool, consent not a concern this phase.)*
5. **Calibration chat is optional, not a gate.** Consequence: a user could reach dates with an uncorrected persona. Accepted because persona fidelity was validated by hand on real answers (2026-08-31) and found highly accurate. *(Revised from "mandatory gate" on that evidence.)*
6. **Similarity-as-compatibility.** Consequence: matches similar people, not complementary ones. Accepted as the v1 heuristic; revisit with evidence, not intuition.
7. **Seeded demo profiles, visibly labeled.** Consequence: less magic. Accepted because unlabeled synthetics discovered later would destroy trust, even among friends.
8. **Match score = criteria-checklist judge, single pass, low temperature.** Consequence: some rerun variance remains possible. Accepted because the judge is strictly instructed to score from exact conversational checks (clashing traits, flow), which is sufficient for this scope; rubric and model ID are still logged.
9. **No moderation, no export, no quotas this phase.** Consequence: nothing protects against ugly generated content or data-portability requests. Accepted because users are friends and models are free; all three return to scope the day a stranger can sign up.
10. **Trait identity is verdict-based.** Extraction receives the existing trait rows and returns explicit `keep`/`update`/`retract`/`add` verdicts per row, matched by id — confirmations, disputes, and provenance survive re-extraction, and an all-`keep` run leaves nothing stale. Consequence: extraction prompts are more complex than a fresh-inference approach. Accepted (owner decision, 2026-09-01) because without it, user confirmations evaporate on every re-run and the profile churns forever. Details in `module_1_data_collection.md` A5.1.
11. **Local-only access this phase.** The server is reached only on the owner's machine; hosting/external access is a deferred decision, and CORS/auth posture will be revisited with it, not before. Consequence: friends can't use the app from their own devices yet. Accepted (owner decision, 2026-09-01).
12. **English-only throughout** — prompts, outputs, UI copy, answers. Consequence: non-English answers are out of contract. Accepted (owner decision, 2026-09-01) to maximize model performance.
13. **Model selection and paid-balance decision deferred to initial tests.** The routing table's model slots stay unfilled until tests run; two gates stand before the first real analysis: the quota-fit check (calls-per-analysis vs provider daily/minute caps) and the persona-fidelity re-validation on the actual routed simulation model. Consequence: build proceeds against the `AIProvider` interface with placeholder models. Accepted (owner decision, 2026-09-01); gates recorded in `ai_interaction.md` §3.
