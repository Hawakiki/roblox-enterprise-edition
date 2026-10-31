---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0023
title: Declare Each Contract Method Through a Wrapper
version: 1.1.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Declare Each Contract Method Through a Wrapper

## 1. Summary

Every class of the Roblox code declares the methods it implements in a table named `_implements`, whose entries refer to the methods of the class (ADR-0001).
The new type solver holds such a table to the presence of each method and to nothing more, which is the one reason the Company still checks its code with the old solver.
This change request makes each entry a function written with the signature of the contract, which calls the method of the class: both solvers then report a method that has drifted from its contract, at the call inside the wrapper.
Two checkpatch rules keep the pattern in place, and the four casts through `any` that stand outside a constructor are written without one.

It is the first of two requests that move the Company to the new solver alone. The second enables the new solver in Roblox Studio and removes the old one, and its release will be numbered 2.0.0, because it removes an obligation of an approved document (EE-STD-0008 §4.2).

## 2. Background

On 2026-10-31 three agents met to decide whether the old solver could go: one argued for it, one against, and Internal Audit kept the evidence.
On a copy of `src/`, wrappers in `_implements` drew the same errors from both solvers for a return of the wrong type and for a missing argument, and none for the classes as they are.
A `type function` that declares conformance was examined and set aside, for the reasons ADR-0001 records.
The Approver of record decided to keep the new solver alone, once both solvers hold every method to its signature.

At the time of this request, `src/` holds fifteen tables named `_implements` and seventeen casts through `any`.
Thirteen casts are where a constructor returns its instance as its contract, as ADR-0001 decides.
The other four are not: two in `PolicyAcknowledgementComponent`, which read its properties, one in `RobloxInstanceFactory`, which passes a class name to `Instance.new`, and one in `ServiceProvider`, which disposes a service. Each can be written without a cast, and both solvers accept it.

An accepted decision is never edited to change it (EE-TPL-0004 §1). The wrapper changes how ADR-0001 declares a contract, and the reason it gives for keeping both solvers, so a new record supersedes it.

## 3. Scope

- Every table named `_implements` in `src/`: each entry becomes a function with the signature of the contract, which calls the method of the class.
- The four casts through `any` outside a constructor, written without a cast.
- `scripts/lib/Contracts.luau`, a check of the Roblox code with two rules, with tests: an entry of `_implements` that is not a function (`IMPLEMENTS_NOT_WRAPPED`), and a cast through `any` anywhere but `return setmetatable(<state>, <class>) :: any` (`CAST_THROUGH_ANY`).
- EE-STD-0006, revised `In Review` at its next MINOR version: §6 states the wrapper and the one place of the cast, and Annex A lists the two rules.
- A new architecture decision record that restates the cast of ADR-0001 and adds the wrapper. ADR-0001 is set to `Superseded` when the new record is accepted.
- The fitness test of CR-0020, turned to the new record: a wrapped method that drifts is reported by both solvers, and an entry that only refers to a drifted method is still not reported by the new one, which is why the wrapper is required.
- `AGENTS.md`, where it cites ADR-0001.

Out of scope, for the second request: the setting that enables the new solver in Roblox Studio, the removal of the old solver, and EE-STD-0001 §4.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Roblox code | Fifteen tables and four casts are rewritten. Nothing calls a table named `_implements`, so no behaviour changes. |
| Type checking | Both solvers report a method whose parameters, arguments or return have drifted from its contract. |
| Release | Obligations are added and none is removed or altered: a MINOR release (EE-STD-0008 §4.3). |
| Documentation volume | One standard revised, one decision record added and one superseded. |

## 5. Rollback Plan

Revert the merge commit of this change. The bare entries of `_implements` and the four casts return, and ADR-0001 is accepted again.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `a6fffe0` | Filed this change request. |
| `68406ca` | Wrapped the thirty-one methods of the fifteen tables named `_implements`, and wrote the four casts outside a constructor without one. |
| `6fdb7cd` | Added `scripts/lib/Contracts.luau` with `IMPLEMENTS_NOT_WRAPPED` and `CAST_THROUGH_ANY`, with tests, and revised EE-STD-0006 to 1.1.0, `In Review`. |
| `eb0286e` | Proposed ADR-0002, turned the fitness test of CR-0020 to it, and pointed `AGENTS.md` at it, with a new mine. |

Before the rules were committed, a method of `InMemoryCoinWalletRepository` was made to drift in two ways, a return of the wrong type and a parameter too many: both solvers reported both at the wrapper, where the new solver had reported nothing under ADR-0001. The change was then undone.
The check skips the body of a wrapper by counting blocks, and an `if` that starts an expression opens none. A test proves that counting every `if` fails it.
The fitness test now finds three errors under each solver for three drifts behind wrappers, the fact that ADR-0002 states.
Roblox Studio checks scripts against type definitions of its own. Whether its editor accepts `Instance.new` with a class name typed as `string`, as luau-lsp does, is left to the person who checks Studio in the second request.
