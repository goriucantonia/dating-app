# Communication Protocol — Server ↔ UI

Status: locked 2026-09-01. High-level contract between the `server` submodule (FastAPI) and the `ux` submodule (Flutter). The per-endpoint details live in the module plans; this document is the shape of the conversation between the two repositories.

---

## 1. The one channel

Everything between the UI and the server is **JSON over HTTP (REST)** on a single origin. There is no second channel: no WebSockets, no server-sent events, no push notifications from the server (a locked decision — see `date_simulation.md` §6). Anything long-running is a **job the client polls**, never a request the client holds open.

- One request–response for quick things (login, saving an answer, sending a chat message).
- Start-then-poll for slow things (matching, simulation, extraction, persona compilation): the POST returns immediately with an id and a status; the UI polls the status object until it reaches a terminal state. The UX has exactly one polling helper for this (`ux_architecture.md` — 3s interval, backing off to 10s, stops on terminal states).

The client never needs to reach Postgres, the AI providers, or anything else directly — the FastAPI server is the UI's only counterpart.

## 2. Docker and where each piece runs

Docker Compose (at the **superproject root**, `dating_app_ai/`) orchestrates the **backend only**: two containers, `api` (FastAPI, built from `./server`) and `db` (PostgreSQL + pgvector). The database is reachable only from the api container on the compose-internal network — it is never exposed to the UI. *(Revised 2026-09-01: Compose previously lived inside the backend repository. New information: the repositories were restructured — `server` and `ux` are now git submodules of a `dating-app` superproject, and the root is the only repo that can hold deployment files describing both. Owner decision. What Compose orchestrates is unchanged: still `api` + `db` only, still no containerized UI.)*

The **Flutter app is not containerized** this phase. It runs natively (mobile/desktop) or as a local web build, and talks to the api container at its published port: `http://localhost:8000` in development. The base URL is the UI's single piece of environment configuration. *(Trade: no containerized UI build pipeline; accepted — Flutter dev workflow is faster outside Docker, and the friends-phase "deployment" is the owner's machine.)*

**Access scope (owner decision, 2026-09-01): local-only for now.** The server is reached only from the owner's machine; external access and hosting (LAN exposure, tunnel, or a rented host) are explicitly deferred decisions. Consequences accepted until then: friends use the app *at* the machine, everything below stays HTTP-on-localhost, and the CORS/auth/base-URL posture will be revisited as part of the hosting decision — not piecemeal before it.

Because Flutter **web** runs in a browser, the server enables CORS for the app's origin; mobile and desktop don't need it but aren't harmed by it.

```
[Flutter app: mobile / desktop / web]
        │  HTTPS-ready JSON REST, JWT bearer, localhost:8000 in dev
        ▼
[api container: FastAPI] ──compose-internal network──► [db container: Postgres + pgvector]
        │
        ▼  outbound only
[Google AI Studio / OpenRouter]
```

## 3. Authentication

- `POST /auth/register` and `POST /auth/login` are the only unauthenticated endpoints.
- Login returns a **JWT**; the client sends it as a `Bearer` token on every other request. Stored via secure storage on mobile/desktop, scoped storage on web (`ux_architecture.md`).
- A `401` anywhere means the session is dead; the UI's one interceptor routes to login. No refresh tokens this phase *(trade: users re-login when the token expires; accepted at friends scale)*.

## 4. The interactions, mapped to the flows

| Flow | Pattern | Endpoints (detail in module plan) |
|---|---|---|
| Register / login | request–response | `/auth/*` (`module_1_data_collection.md`) |
| Questionnaire & edits | request–response, save-per-answer upsert | `GET /questions`, `GET /questions/next-batch`, `PUT /answers/{id}` |
| Profile build | start-then-poll (extract → compile) | `POST /profile/extract`, `POST /persona/compile`, `GET /persona/current` |
| Traits & disputes | request–response | `GET /traits`, `POST /traits/{id}/dispute` |
| Calibration chat | request–response per message | `/calibration/*` (`trait_persona.md`) |
| Find the person | start-then-poll on **one object** | `POST /analyses`, then `GET /analyses/{id}` carries the whole journey: `matching → matched → simulating → complete` with `pool_status`, candidates, `progress`, scores |
| Simulated dates | poll + lazy reads | `POST /analyses/{id}/simulate`, `GET /analyses/{id}/dates`, `GET /dates/{id}/transcript` (readable while later dates still run) |
| Choose & chat | request–response | `POST /analyses/{id}/select`, `/chat/sessions/*` (paged history via `after_seq`) |
| Account | request–response | `GET/PATCH/DELETE /me` |

The design rule behind the table: **the analysis is one server object with one lifecycle**, and the UI polls that single object rather than stitching several sources together.

## 5. Error shape and status conventions

One error envelope everywhere:

```json
{ "error": { "code": "no_candidates", "message": "There is no one to match you with yet." } }
```

- `code` is a stable machine string the UI can branch on; `message` is already user-readable, in layman's terms (§26 of the principles) — the UI may show it verbatim.
- `409` = a state rule, not a failure: analysis already running, analysis not `complete` yet, already selected. The UI pre-empts these where it can and renders them as state, never as error toasts.
- `422` = validation (answer under 200 characters, age range invalid) — field-level, mirrored client-side so it's rare in practice.
- Defined "empty" states are **not errors and not `4xx`**: `pool_exhausted` and `no_candidates` come back as normal payloads with a status field, because they're product states with their own UI, not failures.
- `5xx` / structured-output give-ups surface as an honest "that didn't work, try again" with a retry that is safe by design (server-side checkpoints make retries resume, not restart).

## 6. Data constraints — what crosses the wire and what never does

**Never leaves the server:**
- Persona **system prompts** (they embed raw intimate answers — `trait_persona.md` §7.5).
- Another user's **raw answers** and full **trait descriptions** — a candidate exposes only trait *labels* by category, plus computed `shared_interests` and `reason_summary`.
- Chat-side **internal state metadata** (`connection`, `satisfaction`, …) — stored server-side, stripped from chat responses by contract (`chat.md`).
- Anything belonging to a user who hasn't passed the hard filters for you — non-candidates simply don't appear in any payload.

**Always present when a user is rendered:** `is_demo`, so no screen can forget the demo label.

**Deliberately included:** full date transcripts *with both agents' per-turn state metadata* — that exposure is a named product decision (decision log #4) and the transcript endpoint is where it happens, nowhere else.

**Size and pacing constraints:** payloads are small by design — a transcript tops out at ~30 messages (the largest single response in the app); chat history is paged (`after_seq`) rather than sent whole; there are no file uploads or downloads at all this phase (no photos — nothing consumes them). The slow thing is never the network, it's the AI pipeline behind the job endpoints; the protocol's job is to keep that slowness behind polling.

## 7. Versioning and evolution

- The API is **unversioned this phase** (no `/v1/` prefix) *(trade: a breaking change requires updating both repos together; accepted — one owner, two repos, one deployment)*. What **is** versioned is every stored artifact's schema (`agent_response.v1`, `judge_rubric.v1`) — those version strings appear in payloads so the UI can render old data correctly if formats evolve.
- Additive changes (new fields) are always safe: the Flutter models ignore unknown JSON fields by convention.
- The contract's source of truth is FastAPI's generated OpenAPI page (`/docs`) — hand-written repositories in the UI (`ux_architecture.md`) are checked against it, and any drift between a module plan and `/docs` is a defect (§14: every promise greppable to code).

## Locked by this document

1. One channel: JSON REST on one origin; no push, polling only, one polling helper.
2. Compose runs `api` + `db` only; the database is never network-reachable from the UI; Flutter runs outside Docker with one configured base URL; CORS on for web.
3. JWT bearer auth; 401 → login via the single interceptor; no refresh tokens this phase.
4. The single error envelope (`code` + layman `message`); 409-as-state convention; defined empty states are payloads, not errors.
5. The wire privacy rules in §6 — prompts, others' raw answers/descriptions, and chat metadata never cross; `is_demo` always does.
6. Unversioned API + versioned artifact schemas; additive-change convention; `/docs` as the live contract.
