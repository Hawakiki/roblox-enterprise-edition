---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: ADR-0003
title: Check With the New Type Solver Alone, and Return Each Instance Without a Cast
version: 1.0.0
status: Proposed
classification: Internal
owner: Architecture Review Board
---

# Check With the New Type Solver Alone, and Return Each Instance Without a Cast

## 1. Context

ADR-0002 kept the constructor of ADR-0001, which casts its instance through `any` to return it as its contract, and declared each method of `_implements` through a wrapper, so that both solvers hold every method to its signature.
It left to EE-STD-0001 §4 which solvers check the code. The one reason it gave for the cast was the old solver, which refuses an instance returned as its contract.
Roblox Studio checks scripts with the new solver, and so does the editor of the repository.

On 2026-11-01, under luau-lsp 1.69.0, the old solver reported one kind of mistake that the new one did not: a mistake inside the body of a generic function that involves its type parameter.
Five such mistakes drew five errors from the old solver and none from the new. A mistake in the same bodies that does not involve the parameter, and the same mistake in a function that is not generic, drew an error from each.

The same day, the thirteen casts of `src/` were removed in a clone. The new solver reported nothing, and the old one twenty-seven errors.
A class that lacked a method of its contract, behind a wrapper that called a method of another name, passed the new solver while its constructor cast the instance, and was reported at the constructor once the cast was gone.

## 2. Decision

We will check every Luau file with the new type solver alone, as Roblox Studio does, and set that solver in the place.
We will return each instance from its constructor as its contract without a cast, and the new solver will hold it to the presence of every method of the contract. The Roblox code makes no cast through `any`.
We will keep the wrappers of ADR-0002, because the new solver holds an instance to the presence of its methods and to nothing more, and a wrapper holds each method to its signature.
We accept that a mistake which involves the type parameter inside the body of a generic function goes unreported. `src/` holds seven such functions: `ServiceToken.new`, `ServiceCollection.AddSingleton` and `AddTransient`, `ServiceProvider.GetRequiredService`, `ResourceScope.Adopt` and `Using`, and `ComponentScope.Adopt`.

## 3. Consequences

| Kind | Consequence |
|---|---|
| Positive | The code is checked as Roblox Studio checks it, by one solver, once for each target. |
| Positive | A constructor whose class lacks a method of its contract is reported where it returns the instance. |
| Positive | `src/` holds no cast through `any`, and checkpatch reports any that is written (EE-STD-0006 §6). |
| Negative | A mistake that involves the type parameter in the body of one of the seven generic functions is not reported. The Approver of record accepted this loss on 2026-10-31. |
| Negative | A wrapper still repeats the signature of its contract, method by method. |
| Neutral | `scripts/tests/AdrFitness.spec.luau` holds the facts of this record to the luau-lsp that `rokit.toml` pins. It runs the old solver only as a witness that a fixture holds the mistake it is meant to hold. |

## 4. Alternatives Considered

| Alternative | Reason it was not chosen |
|---|---|
| Keep the old solver beside the new | It would keep the bodies of seven generic functions checked, at the price of a second analysis of every target, and of the cast that hides a class from the new solver. |
| Check with the new solver alone, and keep the cast | The cast hides a class that lacks a method of its contract, and only the old solver required it. |
| Drop the wrappers, and rely on the constructor | The new solver holds an instance to the presence of each method, and to nothing more. |
| Wait until the new solver checks the bodies of generic functions | Nothing says when it will. The fitness test reports when it does. |

## 5. Related Decisions

| Relation | Record |
|---|---|
| Supersedes | ADR-0002 |
| Superseded by | none |
