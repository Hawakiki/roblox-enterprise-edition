---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0009
title: Correct the Findings of the First Assignment
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Correct the Findings of the First Assignment

## 1. Summary

CR-0008 was the first change request implemented by a new hire.
The hire's report and the review that followed found seven defects in the onboarding, the tooling and the rules.
This change request corrects all seven without changing a controlled document.

## 2. Background

The new hire read about fifteen hundred lines of rules before writing the first line of code, implemented CR-0008 in thirty-nine minutes, and reported every place where the rules had cost time.
The review then tested the seven new rules against sixty-six edge cases, of which sixty-four were handled.

| Finding | Found by | At fault |
|---|---|---|
| `AGENTS.md` says how to file a `Submitted` request, but not that it waits for approval, which EE-POL-0004 §4 requires. | The hire | The onboarding |
| `tools/check` looks for the shared Roblox definitions beside the folder it runs in, which in an agent worktree is `.claude/worktrees/`. | The hire | The tooling |
| The doc comments are written for Moonwave, but no tool in the toolchain reads them as Moonwave does. Lacking one, the hire downloaded it and tried to run it, which the sandbox refused. | The hire | The toolchain |
| `LAYER_VIOLATION` strips comments with a pattern, so a string can hide a require from it or fake one. | The hire | The reviewer, who wrote it |
| Every rule is declared in one catalogue far from the check that reports it, and nothing compares the severity a standard states with the severity checkpatch enforces. | The review | The author of checkpatch |
| checkpatch reads the current branch with `git symbolic-ref --short`, which writes `heads/<name>` when a tag shares the name of the branch. | The Approver of record | The author of checkpatch |
| `PROHIBITED_API` misses a member named in brackets, as in `game["GetService"]`, and `COLOR_OUTSIDE_PALETTE` misses an alias of `Color3`. | The review and the hire | The hire |

The governance remains frozen.
Every correction is made in the onboarding, the tooling or the code, and every standard keeps its text and its version.

## 3. Scope

- `AGENTS.md`: a `Submitted` request waits, and only an `Approved` one is implemented (EE-POL-0004 §4); the mines stepped on during CR-0008.
- `rokit.toml`: `moonwave-extractor`, pinned like every other tool.
- `tools/check`: the shared Roblox definitions are found beside the main checkout, from any worktree; `moonwave-extractor` reads every doc comment under `src/`.
- checkpatch: `LAYER_VIOLATION` reads requires through the lexer.
- checkpatch: `PROHIBITED_API` reads a member named in brackets, and `COLOR_OUTSIDE_PALETTE` reports an alias of `Color3` or `BrickColor`.
- checkpatch: the current branch is read from `git symbolic-ref -q HEAD` in full.
- checkpatch: every rule is declared beside the check that reports it, and a test holds the severity stated in every Annex A to the severity enforced.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Rules | Unchanged in number. Three rules see more than they did. |
| Controlled documents | None is changed. |
| Toolchain | One more tool, which reads comments. |
| New hires | The next one waits for approval before working, and finds the definitions without help. |

## 5. Rollback Plan

Revert the merge commit of this change.
The next new hire would step on the same mines, which are recorded in `AGENTS.md` either way.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved before filing | 2026-10-30 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
