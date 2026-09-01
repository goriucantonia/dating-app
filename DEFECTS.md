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

## D-001 — `app/ai/registry.py` is named in the module plan's layout but absent from the tree

- **Date:** 2026-09-01
- **Repo:** `server`
- **Mechanism:** `ai_interaction.md` §1 specifies `app/ai/registry.py` as the component that builds provider instances from config and maps `name -> instance`. `app/ai/routing.py` was written against that contract — `TaskRouter.__init__` takes `providers: dict[str, AIProvider]` and validates the routing table against its keys. Nothing in the tree produces that dict, so `TaskRouter` cannot be constructed at all. The AI layer as committed does not assemble.
- **Discovery method:** Document-to-tree diff while writing `IMPLEMENTATION_PLAN.md` — reading `ai_interaction.md` §1's file layout as a checklist against a listing of `app/ai/`. Found **before** any claim of completeness was made about the module, so nothing false was reported to the owner.
- **Lesson:** A module plan's file-layout block is a checklist, and it should be diffed against the directory before a scaffold is treated as complete. The sharper half of the lesson: **an absent file hides better than a stubbed one.** `google.py` and `openrouter.py` are equally unimplemented, but they carry explicit `NotImplementedError` and TODO comments, so their incompleteness announces itself on sight. `registry.py` announces nothing, because it is not there to announce it. When scaffolding a module, write the empty file with its TODO — a stub is a promise you can see.
- **Status:** **open** — closes with ticket **S2-B3** in `IMPLEMENTATION_PLAN.md` (Step 2).
- **Cross-refs:** `server/ai_interaction.md` §1 (layout); `app/ai/routing.py` (the caller). Note: at the time of writing, the `app/` scaffold has not yet been migrated into the `server` submodule and still lives in the pre-restructure `dating_app\dating-app-server\app\` folder — see `PICKUP.md`, "The submodule migration is unfinished".
