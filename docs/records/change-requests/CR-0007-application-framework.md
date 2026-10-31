---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0007
title: Establish the Application Framework
version: 1.1.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Establish the Application Framework

## 1. Summary

The Company has seventeen approved documents, fifty-nine rules and no product.
This change request lays the foundation of the product: the structure of the Roblox code, the framework that every feature will be built on, and the two standards that govern its shape.

## 2. Background

The governance of the Company is frozen.
No policy, standard, procedure, form or document rule is added or removed unless the documents suffer an incident of the severity of December 2021.
Work continues in `src/`, and the standards for code are drafted on the numbers that were reserved for them.

No suitable application framework was found on the list of approved vendors.
The Company does not have a list of approved vendors.

## 3. Scope

- A Rojo place project, with an `EnterpriseEdition` folder in ReplicatedStorage, ServerScriptService and StarterPlayerScripts.
- The kernel: resource scopes that release what they own in reverse order, a dependency injection container, and an application host for hosted services.
- Five layers, Kernel, Domain, Application, Infrastructure and Presentation, and the composition roots that assemble them.
- The first hosted service, which announces that the server has started, by way of three layers.
- The Layered Architecture Standard and the Naming Convention, drafted on their reserved numbers, with two new rules: `LAYER_VIOLATION` and `MODULE_NAME_SUFFIX`.
- `tools/check`: Roblox code is type-checked against the Roblox definitions and a sourcemap, under both solvers.
- `AGENTS.md`: the governance freeze, and where code lives.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | The server announces its own startup. It is the first output in the history of the Company. |
| Lines of game code | From 0 to several hundred, none of which does anything a player can see. |
| Developer productivity | Every future feature passes through five layers and a container. This is intended. |
| Documentation volume | Unchanged in number: two reserved standards are written, not added. |

## 5. Rollback Plan

Revert the merge commit of this change.
The Company would return to having rules and no product, which it has shown it can sustain indefinitely.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved before filing | 2026-10-30 |
| Implementer | Architecture Review Board | Implemented | 2026-10-30 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `fd90604` | Filed this change request. |
| `6541b71` | Added the Rojo project, the kernel and the first hosted service, and type-checked `src/` under both solvers. |
| `cda2d41` | Added `LAYER_VIOLATION` and `MODULE_NAME_SUFFIX`, and submitted EE-STD-0006 and EE-STD-0002 for review. |
| `a13b3e7` | Recorded the governance freeze and the place of code in `AGENTS.md`. |
| `cc29818` | Approved EE-STD-0006 and EE-STD-0002 at 1.0.0. |
