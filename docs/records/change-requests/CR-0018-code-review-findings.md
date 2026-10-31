---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0018
title: Correct the Findings of the First Code Review
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Correct the Findings of the First Code Review

## 1. Summary

The first code review of the Company found seven defects, and reproduced every one of them. The two most serious could cost a player compliance coins, or hold a wallet locked for ten minutes after a server closed.
This change request corrects all seven, each with a test that fails without its correction.
It also brings into the repository the harness that runs the Roblox code under Lune, so that the continuous integration tests the code it used to only type-check.

## 2. Background

On 2026-10-31 a new employee, an agent working read-only in a worktree of its own, reviewed the Luau of `src/` and `scripts/`.
It reported seven defects, each with a script that reproduced it outside the repository. The chair confirmed the two Major ones by reading the code.

| # | Severity | Defect |
|---|---|---|
| 1 | Major | A late load or release of a wallet on the same server clears the lock of the wallet that replaced it, and the player is disconnected with coins lost. |
| 2 | Major | `CoinSessionService.StopAsync` does not wait for loads in progress, so a wallet loaded after it returns is never released, and its lock stands for ten minutes. |
| 3 | Minor | An autosave pass that reaches a wallet already released disconnects the player who has since rejoined. |
| 4 | Minor | A component invalidated while it is being updated is mounted twice, and the orphaned copy is never unmounted. |
| 5 | Minor | `release_notes` reads only `Change-Request:`, although trailer keys are matched without regard to case (EE-STD-0007 §6.1). |
| 6 | Minor | checkpatch accepts a function that returns a function without `@return`, and skips a module that ends otherwise than `return <name>`. |
| 7 | Minor | A stored balance that is negative, fractional or too large is read, and the load fails only after it has taken the lock. |

The harness that verified CR-0010 to CR-0012 under Lune lived outside the repository, in the scratch folder of the session that wrote it.
`tools/check` type-checks `src/`, but no test of it runs in the continuous integration.

The review also found that an agent worktree starts from `main`, not from the branch of the session that creates it.

## 3. Scope

- `scripts/tests/roblox/`: the harness, brought into the repository under EE-STD-0001, and its suites for the presentation framework, the policy panel, the compliance coins and the DataStore wallets.
  `scripts/tests/run.luau` runs them, so `tools/check` and the continuous integration run them too.
- `src/`: the corrections of defects 1 to 4 and 7, each with a test in the harness that fails without it.
- `scripts/`: the corrections of defects 5 and 6, each with a test that fails without it.
- `AGENTS.md`: the mine of the agent worktree.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Wallets | No coin is lost to a rejoin, and no lock outlives a server that closed. |
| Stored records | Records that are already valid are read as before. Records with an impossible balance are refused before any lock is taken. |
| Continuous integration | Runs the Roblox code as well as type-checking it. |
| Documentation volume | One row in `AGENTS.md`. No controlled document. |

## 5. Rollback Plan

Revert the merge commit of this change. The harness leaves with it, and the defects return.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
