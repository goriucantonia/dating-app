# Technical Details

## 1. Tech Stack

- **Backend / Server Repository:** Python, using an async framework (FastAPI) to handle long-running API requests efficiently.
- **Frontend / UI Repository:** Dart with Flutter — cross-platform (Mobile, Web, Desktop) from a single codebase.
- **Database:** PostgreSQL with the `pgvector` extension — one database holds both relational data and the trait vector embeddings, and executes the semantic similarity searches. There is no separate vector service; `pgvector` lives inside the Postgres container.
- **Containerization & Environment:** Docker Desktop — the server and the database each run in isolated local containers, spun up together (docker-compose).

## 2. Core Architectural Principles (Crucial to Remember)

- **Asynchronous Execution (Async-First):** The entire backend must be heavily asynchronous. The app relies on multiple long-running AI API calls (simulating multiple dates, generating traits, evaluating transcripts); synchronous code would block the system and cause timeouts. Concretely: simulations run as background tasks, every completed turn is checkpointed to the database, and HTTP endpoints return immediately with a job ID the client polls (or subscribes to) for progress — matching the checkpointed-execution design in `project_description.md`.
- **Strict Modularity:** The system is split into the clearly separated modules defined in the Source of Truth (Data Collection & Dynamic Profiling, Trait Prompting & Persona, Candidate Matching, Date Simulation, AI Interaction, Chat, Data Hygiene). Each module owns its own logic; no module reaches into another's internals.
- **Clear Interfaces:** Communication between modules happens through strictly defined interfaces and JSON data schemas. The contract between the two repositories (REST, polling, auth, error shape, wire privacy rules, Docker layout) is defined in `communication_protocol.md`. Schemas are versioned (per the decision log) — the agent response schema in particular carries a version number stored with every transcript. This prevents spaghetti code and ensures a change in one module doesn't silently break the others.
- **English-Only:** All UI copy, questions, system prompts, routing logic, and model outputs are in English (owner decision, 2026-09-01 — maximizes model performance). User answers are expected in English; there is no localization layer anywhere.
- **Highly Extensible:** Built with future expansion in mind. The AI Interaction Module implements both Google AI Studio and OpenRouter (free models) behind one `AIProvider` interface, with a per-task routing config mapping each task to a provider + model. Swapping a model (e.g., a free OpenRouter model today, a paid Google one later) is a config edit, not a rewrite of core logic. The embedding model is pinned separately from chat models. Details in `ai_interaction.md`.
