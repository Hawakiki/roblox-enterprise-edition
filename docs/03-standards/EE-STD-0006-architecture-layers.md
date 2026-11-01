---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0006
title: Layered Architecture Standard
version: 2.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-STD-0001@2.0
---

# Layered Architecture Standard

## 1. Purpose

This standard sets the layers of the Roblox code, the direction in which they may depend on one another, and how they are assembled into a running application.

## 2. Scope

This standard applies to every module under `src/`.

## 3. Sides

| Folder | Instance | Runs on |
|---|---|---|
| `src/Shared` | `ReplicatedStorage.EnterpriseEdition` | Server and client |
| `src/Server` | `ServerScriptService.EnterpriseEdition` | Server |
| `src/Client` | `StarterPlayer.StarterPlayerScripts.EnterpriseEdition` | Client |

## 4. Layers

1. Every module belongs to exactly one layer, given by the folder it lives in: `src/<side>/<layer>/` (`LAYER_VIOLATION`).

| Layer | Holds | May require |
|---|---|---|
| Kernel | The framework: the container, the host, resource scopes, and the contracts that every layer shares. | Kernel |
| Domain | Business rules, in plain Luau, unaware of Roblox. | Domain, Kernel |
| Application | Use cases and services, and the contracts they need from outside. | Application, Domain, Kernel |
| Infrastructure | Implementations of those contracts on Roblox: data stores, players, the output window. | Infrastructure, Application, Domain, Kernel |
| Presentation | The user interface of the client. | Presentation, Application, Domain, Kernel |

2. Dependencies point inwards, towards the kernel (`LAYER_VIOLATION`).
   Application never requires Infrastructure: it declares a contract, and Infrastructure implements it.
3. The composition roots, `init.server.luau` and `init.client.luau`, belong to no layer.
   They are the only modules that may require every layer.

## 5. Requires

1. A require names the layer it reaches into, as in `require(script.Parent.Parent.Kernel.ILogger)`.
   A require that names no layer stays within its own layer.
2. A path is not stored in a variable before it is required, because the variable would hide the layer from checkpatch.
   This provision is not enforced, and is therefore a recommendation (EE-CHR-0001, Article 4).

## 6. Contracts and Implementations

1. A contract is a table type in a module named `I<Name>`, whose methods take `self: any`.
2. A constructor returns the contract it implements, not its own class: `RobloxOutputLoggerAdapter.new` returns `ILogger`.
   It returns its instance as it is, `return setmetatable(state, Class)`, where `state` is a local that holds the fields of the instance, and the type checker holds the instance to the presence of every method of the contract.
   The Roblox code makes no cast through `any` (`CAST_THROUGH_ANY`): a value that arrives as `any` is assigned to a local or a field of the type it should have.
3. Every implementation declares the contract it implements, in a table named `_implements` whose type is the contract.
4. Each entry of `_implements` is a function written with the signature of the contract, which calls the method of the class and returns what it returns, as in `Information = function(self: any, message: string) RobloxOutputLoggerAdapter.Information(self, message) end` (`IMPLEMENTS_NOT_WRAPPED`).
   The type checker then holds the method to the contract at that call. An entry that only names the method, as in `Information = RobloxOutputLoggerAdapter.Information`, is held to the presence of the method and to nothing more.

## 7. Composition

1. A composition root registers services in a `ServiceCollection`, builds a `ServiceProvider` from it, and runs an `ApplicationHost`.
2. Services are resolved by the tokens kept in a `ServiceTokenRegistry`, never by name.
3. A singleton is created once per provider, and a transient every time it is resolved. Circular dependencies are refused.
4. Hosted services start in the order given to the host and stop in reverse; the provider then disposes its singletons, last created first.

## 8. Resources

1. Every connection, instance, thread and disposable that a feature creates is adopted by exactly one `ResourceScope`.
2. A scope releases its resources in reverse order of acquisition, as destructors do, and a failure to release one resource does not stop the others.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `LAYER_VIOLATION` | Error | §4 |
| `CAST_THROUGH_ANY` | Error | §6 |
| `IMPLEMENTS_NOT_WRAPPED` | Error | §6 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | Number reserved. | Architecture Review Board |
| 0.9.0 | 2026-10-30 | Drafted with the application framework (CR-0007). | Architecture Review Board |
| 1.0.0 | 2026-10-30 | Approved. | Architecture Review Board |
| 1.0.1 | 2026-10-30 | Reviewed against EE-STD-0001 1.1; citation updated. | Architecture Review Board |
| 1.1.0 | 2026-10-31 | §6: each entry of `_implements` wraps its method, and a cast through `any` stands only where a constructor returns its instance (CR-0023). | Architecture Review Board |
| 2.0.0 | 2026-11-01 | §6: a constructor returns its instance without a cast, and the Roblox code makes no cast through `any`; reviewed against EE-STD-0001 2.0 (CR-0025). | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved | 2026-11-01 |
