---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: ADR-0001
title: Constructors Return Their Contract, Cast Through Any
version: 1.2.0
status: Superseded
classification: Internal
owner: Architecture Review Board
---

# Constructors Return Their Contract, Cast Through Any

## 1. Context

This decision was made with the application framework, in CR-0007, and is recorded a day later, when the Company noticed that it had kept a form for architecture decisions since its founding and had never filed one.

The Company writes its services as classes. Each class is a metatable, whose methods take the class itself as `self`.
Each class works behind a contract: a table type in a module named `I<Name>`, whose methods take `self: any`, because a contract does not know which class will implement it (EE-STD-0006 §6).
Code that uses a service should know its contract and nothing more, so that a fake can stand in for it.

A class instance does not sit easily where its contract is expected.
Under luau-lsp 1.69.0, the old type solver refuses to return one as its contract, and the new solver accepts it.
The Company checks its code with both solvers (EE-STD-0001 §4).

## 2. Decision

We will make every constructor return the contract it implements, and cast its instance through `any` to get there, as in `return setmetatable(state, Class) :: any`.
The cast turns the checker off at that one point, so every class also declares the methods it implements, in a table named `_implements` whose type is its contract, and the checker holds that table to the contract instead.
We will check with both type solvers, because only the old one holds the methods in `_implements` to the signatures of the contract.

## 3. Consequences

| Kind | Consequence |
|---|---|
| Positive | Code depends on contracts only. A fake implements a contract with a plain table. |
| Positive | Under the old solver, a method whose parameters, arguments or return have drifted from its contract is reported where `_implements` declares it. |
| Negative | The cast hides the constructor from the checker: whatever it returns passes as the contract. |
| Negative | The new solver holds `_implements` to the presence of each method, and to nothing more. Against a contract method that takes `self: any`, it reports no difference of parameter, argument or return. On 2026-10-31, three methods drifted in three ways drew three errors from the old solver, and none from the new. |
| Negative | Every class takes five steps: the contract, the class, `_implements`, the cast and the service token. |
| Neutral | At the time of this record, `src/` holds seventeen casts through `any` in fourteen files, and fifteen tables named `_implements`. |

## 4. Alternatives Considered

| Alternative | Reason it was not chosen |
|---|---|
| Constructors return the class, and callers depend on it | Callers would depend on implementations, and a fake could not stand in without every method of the class. |
| Constructors return the instance as the contract, without the cast | The old solver refuses it. |
| Check with the new solver only | A method that drifted from its contract would go unreported. |
| Declare conformance with a `type function`, examined on 2026-10-31 | The old solver does not accept the syntax. Under luau-lsp 1.69.0, a `type function` exported from a shared module checks nothing, and one copied into every class file turns each of those files red for anyone who works with the old solver. |

## 5. Related Decisions

| Relation | Record |
|---|---|
| Supersedes | none |
| Superseded by | ADR-0002 |
