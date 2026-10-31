---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: ADR-0002
title: Declare Each Method of a Contract Through a Wrapper
version: 1.1.0
status: Accepted
classification: Internal
owner: Architecture Review Board
---

# Declare Each Method of a Contract Through a Wrapper

## 1. Context

ADR-0001 decided that every constructor returns the contract it implements, cast through `any`, and that every class declares the methods it implements in a table named `_implements`, whose type is its contract. Each entry of the table named a method of the class.

Under luau-lsp 1.69.0, the new type solver holds such an entry to the presence of the method and to nothing more: against a contract whose methods take `self: any`, it reports no drift of parameter, argument or return.
ADR-0001 kept the old solver for that reason alone. Roblox Studio checks scripts with the new one.

On 2026-10-31 three agents met on whether the old solver could go, and examined a `type function`, the old solver kept for ever, and a wrapper.
On a copy of `src/`, wrappers in `_implements` drew the same errors from both solvers.
The Approver of record decided to keep the new solver alone, once both solvers hold every method to its signature.

## 2. Decision

We will keep the constructor of ADR-0001: it returns the contract it implements through `return setmetatable(state, Class) :: any`, and the Roblox code makes no other cast through `any`.
We will write each entry of `_implements` as a function with the signature of the contract, which calls the method of the class and returns what it returns. Both solvers hold the call to the signature of the method, and the function to the signature of the contract.
checkpatch keeps both parts, with `CAST_THROUGH_ANY` and `IMPLEMENTS_NOT_WRAPPED` (EE-STD-0006 §6).
Which solvers check the code is left to EE-STD-0001 §4: this decision holds under either of them.

## 3. Consequences

| Kind | Consequence |
|---|---|
| Positive | A method whose parameters, arguments or return have drifted from its contract is reported by both solvers. On 2026-10-31, the three drifts that drew no error from the new solver under ADR-0001 drew three from each solver once wrapped. |
| Positive | The old solver is no longer needed to hold a method to its contract, which opens the way to remove it. |
| Positive | A cast through `any` stands in one statement of each class, where checkpatch can find it. |
| Negative | Every class takes one more step: the wrapper repeats the signature of the contract, method by method. |
| Negative | A wrapper is code that never runs: nothing calls a table named `_implements`. |
| Negative | The cast still hides the constructor from the checker: whatever it returns passes as the contract. |
| Neutral | At the time of this record, `src/` holds fifteen tables named `_implements` with thirty-one wrappers, and thirteen casts through `any`, one in each constructor. |
| Neutral | `scripts/tests/AdrFitness.spec.luau` holds the facts of this record to the luau-lsp that `rokit.toml` pins, as it held those of ADR-0001 (CR-0020). |

## 4. Alternatives Considered

| Alternative | Reason it was not chosen |
|---|---|
| Keep the entries that name a method, and the old solver with them | The old solver is kept for this alone, while Roblox Studio checks with the new one. |
| Declare conformance with a `type function` | As ADR-0001 records: the old solver does not accept the syntax, and under luau-lsp 1.69.0 a `type function` exported from a shared module checks nothing. |
| Drop `_implements`, and rely on the cast | The cast hides the class from the checker, and nothing would hold its methods to the contract. |
| Return the instance as the contract without the cast | The old solver refuses it, and it still checks the code. |

## 5. Related Decisions

| Relation | Record |
|---|---|
| Supersedes | ADR-0001 |
| Superseded by | none |
