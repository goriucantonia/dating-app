# User Perspective

## Account Creation and Profile Building

- A regular user begins by creating an account (email + password) and providing hard facts: name, age (18+ required), gender, sexual orientation, location, and matching preferences (which genders, what age range, what distance). These are hard filters used before any trait matching — they are not traits.
- The user then answers a baseline questionnaire of **5 deep, open-ended questions** (defined verbatim in `module_1_data_collection.md`). Progress is saved after every answer; the user can leave and resume. Before starting, the UI states plainly: "This takes about 10 minutes. Nothing works without it." Each answer doubles as a writing sample the AI uses to learn the user's voice. *(Revised 2026-09-01 from "~20 questions": depth over count — each open-ended answer probes several trait areas at once.)*
- The user is encouraged to write honest answers so that the system can build a highly accurate, well-defined "traits profile" from this information.
- Every trait the system infers is a guess until the user confirms it. The trait display is not read-only: each trait carries a "this is wrong" control. Disputing a trait triggers a follow-up question and a correction — the system never silently keeps a disputed trait.
- **Persona calibration (optional):** the user can chat with their own AI persona ("meet your AI self") and flag any line "I'd never say that," which updates the profile. Persona fidelity has already been validated by hand (2026-08-31: real answers produced a highly accurate persona), so this is a refinement tool, not a gate — matchmaking is available immediately after the baseline questionnaire.
- The user can expand their profile over time by answering **batches of 5 new questions** drawn from a curated pool of 30 (defined in `module_1_data_collection.md`). The pool probes interests, how the interests are approached (e.g., reading about a subject vs. learning by experimenting), what the user seeks in a partner, how they handle situations (tense, flirty, supportive), their conversational skill, and self-image. The system tracks which questions they've answered; once all 30 are done it says so gracefully and stops offering new ones — from there, refining means editing past answers. *(Revised 2026-09-01 from on-demand AI-generated questions to a curated pool.)*
- The user can also **edit any previously submitted answer** at any time. The profile re-extracts from the full updated answer set; the change affects future matching and simulations only — past results keep the persona they were run against.

## Opt-In

- A user is only visible for matching if they switch on the opt-in toggle in settings. A simple toggle with a one-line description is sufficient — the pool for this phase is friends of the builder, not strangers, so no heavier consent flow is needed.
- The chosen candidate is **not** notified in this phase. There is no real messaging between people.
- Demo/seeded profiles used to fill the pool are visibly labeled as demo profiles.

## Match Analysis and Simulated Dates

- At the user's request, they trigger an analysis to find the "right person."
- **Step 1 — hard filters:** mutual gender/orientation fit, both users' age ranges satisfied, distance, and opt-in status. Trait matching only runs on candidates who pass.
- **Step 2 — trait compatibility:** the system selects the top 3 most compatible people from the filtered set. If fewer than 3 eligible candidates exist, it runs with however many there are and tells the user so plainly. If zero, it says "there is no one to match you with yet" — it never fakes a candidate.
- **2 simulated dates per candidate** (max 6 dates per analysis), each in a different setting drawn from overlapping interests (e.g., a garage if both love cars). Each date is capped at **30 exchanges**. The caps exist to keep runs fast on free-tier model rate limits and transcripts short enough that someone actually reads them — not for billing reasons (free models are used this phase).
- Dates are simulated as textual conversations between the two AI personas. Occasionally (a per-turn chance roll), an environmental event interrupts the date (a waiter drops a glass, a song comes on) and the conversation must adapt to it.
- Each agent mimics its user based on their traits profile and calibrated way of talking. Each agent response contains: the spoken reply, current state of mind, emotional state, connection level (0–100), and satisfaction (0–100). Fixed scales, so numbers are comparable across dates and candidates.
- **The simulation runs in the background.** The user can close the tab; they are notified when results are ready. Results are stored permanently and can be revisited from a history page.
- If a simulation fails partway (model error, rate limit), it resumes from the last completed turn. A date that cannot finish after retries is reported as incomplete — never silently dropped, and the analysis still shows whatever completed.

## Post-Date Analytics and Chat Selection

- After the dates complete, the system shows per-date transcripts (with internal-state badges and event markers), satisfaction statistics for each peer, and a detailed analysis: what subjects clicked, which traits aligned, which quality or flaw of the user clashed with the candidate.
- The final match score is 0–100, produced by an LLM judge strictly instructed to evaluate specific conversational criteria (clashing traits, conversational flow) and derive the score from those exact checks. Judged at low temperature with the rubric and model version logged, so scores stay explainable and comparable.
- The user reviews the dates and chooses the one person they want to continue with.
- The user then chats with the AI persona of that person. The persona knows the simulated dates happened and refers to them as simulations ("on our simulated date at the car show…"), never as real shared memories — the human user wasn't there and must not be gaslit into a history they didn't live.
- Direct human-to-human conversation is out of scope for this phase.

## Data Rights

- Delete account = full deletion of answers, traits profile, embeddings, and transcripts involving the user's persona.

## Out of Scope (this phase)

- Direct human-to-human chat.
- Notifying the other person they were matched or simulated.
- Payments, quotas, and cost controls (free models, friends-only pool).
- Content moderation and data export (pool is friends, not strangers).
