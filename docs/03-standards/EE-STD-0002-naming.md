---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0002
title: Naming Convention
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-STD-0001@1.0
---

# Naming Convention

## 1. Purpose

This standard sets the names of modules, types and members in the Roblox code, so that a name says what a thing is before anyone opens it.

## 2. Scope

1. This standard applies to every module under `src/`.
2. The tooling under `scripts/` follows the tradition of the Linux kernel instead (EE-STD-0001 §9).
3. The composition roots, `init.server.luau` and `init.client.luau`, are named by Rojo and are exempt.

## 3. Modules

1. Module names are written in Pascal case (`MODULE_NAME_SUFFIX`).
2. A module that only declares a contract is named `I` followed by the name of the contract, as in `ILogger`.
3. Every other module ends with one of the approved suffixes below, which says what the module is (`MODULE_NAME_SUFFIX`).
   A suffix alone is not a name.
4. A folder module, `init.luau`, takes the name of its folder.

| Suffix | A module that |
|---|---|
| `Adapter` | implements a contract on top of something external |
| `Collection` | gathers things before they are used |
| `Component` | renders part of the user interface |
| `Constants` | holds named values, so that nothing else has to hold numbers |
| `Controller` | handles input on the client |
| `Entity` | is a domain object with an identity |
| `Factory` | creates objects |
| `Gateway` | carries requests across the network |
| `Handler` | answers one kind of request or event |
| `Host` | runs and stops other services |
| `Mapper` | converts one representation into another |
| `Options` | holds configuration |
| `Orchestrator` | coordinates other services |
| `Policy` | decides whether something is allowed |
| `Projection` | shows domain state somewhere else |
| `Provider` | supplies instances on request |
| `Registry` | keeps things by name |
| `Repository` | stores and retrieves domain objects |
| `Scope` | owns resources and releases them |
| `Service` | performs an application task |
| `Specification` | states a rule as an object |
| `Strategy` | is one of several interchangeable ways to do something |
| `Token` | names a service in the container |
| `UseCase` | carries out one thing that a user can do |
| `ValueObject` | is a domain value without an identity |

## 4. Types

1. A module that defines a class exports a type with the name of the module.
2. A contract type has the name of its module.

## 5. Members

| Member | Form | Example |
|---|---|---|
| Methods | Pascal case | `host:Start()` |
| Constructors | `new` | `ApplicationHost.new` |
| Private fields | Camel case with a leading underscore | `_resources` |
| Locals and parameters | Camel case | `hostedServices` |
| Constants within a module | Upper snake case | `MAXIMUM_RETRIES` |

This section is not enforced, and is therefore a recommendation (EE-CHR-0001, Article 4).

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `MODULE_NAME_SUFFIX` | Error | §3 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | Number reserved. | Architecture Review Board |
| 0.9.0 | 2026-10-30 | Drafted with the application framework (CR-0007). | Architecture Review Board |
| 1.0.0 | 2026-10-30 | Approved. | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
