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
