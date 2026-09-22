---
name: address-review-comments
description: "Address the human code-review comments stored in .codereview.md (created with the nvim <leader>rc command). Reads each comment, edits the referenced file/range to resolve it, and reports per-comment status. Use when the user says to address, apply, or fix review comments."
---

Apply every human review comment in `.codereview.md` to the working tree.

This skill is the counterpart to `code-review`: that skill produces findings, this one consumes human findings.

## Format

`.codereview.md` is a markdown log. One block per comment:

```markdown
## `path/to/file:12-18` — 2026-09-22T15:04:00Z

File: `path/to/file`
Lines: 12-18

### Selected (`lua`)

````lua
<code snapshot at comment time>
````

### Comment

<free-form markdown>

<!-- end-comment -->

---
```

Parsing rules:

- A block runs from a `## ` header line to its `<!-- end-comment -->` sentinel. Never split on `---` or inner `## ` lines — both may appear inside comment text or the snapshot.
- `file` is repo-relative (`%:.'`), `start/end` are 1-indexed inclusive. Prefer the `File:`/`Lines:` body lines when present; fall back to the header.
- The snapshot fence is 3+ backticks and grows past any backtick run inside the snapshot; the closing fence is the line exactly equal to the opening run.
- The comment body is everything between `### Comment` and the sentinel, trimmed. It is raw markdown and may contain fences, `---`, or `## ` lines.
- Malformed blocks (no sentinel, empty comment) are skipped and counted, not fixed.

## Process

### 1. Locate and parse `.codereview.md`

1. Read `./.codereview.md` in the current working directory. If missing, also try `git rev-parse --show-toplevel` + `/.codereview.md`. If still missing, stop: "no review comments found".
2. Split into blocks per *Format* above. On zero blocks, stop: "no review comments". Count malformed blocks and carry the count into the final report.
3. Number comments in file order (`#1..#N`) and keep that order for the whole run.

### 2. Address each comment sequentially

- Work strictly in order, one comment at a time. Do not fan out to parallel sub-agents: edits to the same files would conflict.
- Create a todo list for the comments

For each comment:

1. `Read` `file:start_line-end_line` (current content).
2. Compare current content to the `Selected` snapshot. If it matches, edit in place. If it drifted (lines moved/changed since the comment), search the surrounding ~50 lines for the snapshot; if found, apply there and note the new location; if not found, do your best at the recorded location and flag it as `stale` in the report.
3. Dont be afraid to ask followup questions about the comment
4. Interpret the comment body as the requirement. Scope the fix to the commented range unless the request clearly needs a wider change — then say so.
5. Apply the minimal edit that resolves the comment. Follow repo standards; if the comment conflicts with a documented standard, follow the comment but note the conflict.
6. If a comment is ambiguous, ask followup questions

### 3. Verify

- Re-read each edited hunk.
- Run the most relevant check if cheap and obvious (e.g. filetype lint, focused test). Don't go hunting for full test suites.

### 4. Report

Per comment, one row:

`#N file:start-end | request (short quote) | status | notes`

Statuses: `done` (what changed), `assumed` (what you assumed), `skipped` (why — include validation errors, missing files, malformed blocks), `stale` (snapshot drifted, where you applied it).

End with: total `done/assumed/skipped/stale` counts plus a list of follow-up questions for anything `assumed`/`skipped`.

## Rules

- Never create, truncate, or delete `.codereview.md` yourself.
- Never commit the changes unless asked.
- Keep each fix minimal; don't refactor surrounding code to satisfy a comment unless that is what the comment is asking for.
