---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0019
title: Record the Contract Pattern as the First Architecture Decision
version: 1.2.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Record the Contract Pattern as the First Architecture Decision

## 1. Summary

The Company has kept a form for architecture decision records since its founding, and has never filed one.
This change request files the first, which records why every constructor returns its contract through a cast to `any`, and what that costs, as checked again before it was written.
The check disproved the reason one mine in `AGENTS.md` gave, and the mine is corrected.

## 2. Background

Of the seven forms the Company keeps, only the change request has ever been used.
The decision to return contracts through `any` was made with the application framework in CR-0007. EE-STD-0006 §6 states it as a rule, and its reasons survive only in that record and in one line of `AGENTS.md`.

That line says that both type solvers reject a class instance where its contract is expected.
Before the record was written, a fixture outside the repository was checked with luau-lsp 1.69.0. The old solver rejects such an instance, and the new one accepts it.
A second fixture drifted three methods from their contract in three ways. The old solver reported three errors, and the new one none.

## 3. Scope

- `docs/adr/`: the first architecture decision record and its Korean version, filed as `Proposed`, to become `Accepted` when the Approver of record approves the merge.
- `AGENTS.md`: the corrected mine, and the record among the documents to read before writing Roblox code.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Architecture | Nothing changes. A decision already in force is written down. |
| Records | The first architecture decision record, under a form unused until now. |
| Documentation volume | One record in two languages, and two lines of `AGENTS.md`. |

## 5. Rollback Plan

Revert the merge commit of this change. The decision stays in force, unrecorded, as before.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `4f44c92` | Filed this change request. |
| `28290d2` | Filed ADR-0001 as `Proposed`, corrected the mine on class instances in `AGENTS.md`, and listed the record among the documents to read before writing Roblox code. |

The request was filed before the record, as a request is filed on its own, and therefore names the record by its folder rather than by an identifier that did not yet exist.
A merge with each of the other two branches due to reach `develop` on the same evening, simulated with `git merge-tree`, conflicts only in the generated registry.

| Commit | Change |
|---|---|
| `238dcc6` | Marked this request as implemented. |
| `930b926` | Accepted ADR-0001, on the approval of the Approver of record. |

In the same review, the Approver of record asked how the cast through `any` could be made less dangerous.
Fixtures showed that the new solver, with the cast or without it, holds a class only to the presence of its methods, and that four of the seventeen casts in `src/` stand outside the constructor pattern.
The Approver of record decided that a checkpatch rule confining the cast to `return setmetatable(<state>, <class>) :: any` belongs to the request that changes the type solvers, and not to this one.
