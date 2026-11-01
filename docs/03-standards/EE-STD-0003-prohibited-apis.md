---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0003
title: Prohibited API Registry
version: 1.1.1
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-STD-0001@2.0
---

# Prohibited API Registry

## 1. Purpose

This standard lists the directives that no Luau file declares, and the Roblox and Luau APIs that the Roblox code does not use directly, with the places where each is still allowed and what the code uses instead.

## 2. Scope

1. §4 applies to every Luau file in the repository, the tooling under `scripts/` included, because it protects the strict mode that EE-STD-0001 §3 requires of every Luau file.
2. §5 and §6 apply to the Roblox code under `src/`, the composition roots included.

## 3. Definitions

| Term | Definition |
|---|---|
| Directive | A comment that opens with `--!`, which Luau reads as an instruction to its type checker or its compiler. |
| Attribute | A name that opens with `@` before a function, such as `@native`, which Luau reads as an instruction to its compiler. |
| Prohibited API | A global, or a member of a global, listed in §5. |
| Sanctioned exception | A module that §6 allows, by its path, to use a prohibited API. |
| Composition root | `init.server.luau` or `init.client.luau` (EE-STD-0006 §4). |

## 4. Directives and Attributes

1. Directives and attributes are an allow-list: what the list does not name is prohibited (`PROHIBITED_DIRECTIVE`).
2. The list names one directive, `--!strict`, which EE-STD-0001 §3 also requires. It names no attribute.
3. In particular, the following are prohibited without waiver: `--!nonstrict`, `--!nocheck`, `--!native`, `--!optimize` at any level, and the `@native` attribute.
4. A file that declares `--!strict` beside another directive is reported for the other directive, whichever of the two comes first.
   Declaring `--!strict` is not enough; declaring nothing else is also required.
5. The reason is that premature optimisation is the root of all evil, and that the Company ranks procedure above performance.
   `--!nonstrict` and `--!nocheck` give up the type checker for convenience; `--!native`, `--!optimize` and `@native` tune the compiler for speed.
   The Company does neither.
6. No exception is granted under §6 for a directive or an attribute.

## 5. Prohibited APIs

1. The Roblox code uses a prohibited API only where the table below allows it, and everywhere else uses what the table names instead (`PROHIBITED_API`).

| API | Still allowed in | Why there | Use instead |
|---|---|---|---|
| `print`, `warn` | The sanctioned exceptions of §6 | The output window is an external system, and one adapter implements `ILogger` on it (EE-STD-0006 §6). | `ILogger`, resolved from the container |
| `Instance.new` | Infrastructure modules whose names end with `Factory` | Instances belong to Roblox, which only Infrastructure knows (EE-STD-0006 §4), and creating objects is what a factory does (EE-STD-0002 §3). The caller adopts what it receives into a `ResourceScope` (EE-STD-0006 §8). | A factory, through a contract that Application declares |
| `game:GetService`, `game:FindService` | The composition roots | A static require path starts from a service (EE-STD-0001 §7), and a root has no container to resolve a service from until it has required one. The roots already know every implementation (EE-STD-0006 §4), so knowing every service adds nothing. | The constructor: the composition root passes each module the services it needs |
| `Random.new` | Infrastructure modules | Chance comes from outside the code, as the time does, and the code receives it rather than drawing it. Infrastructure implements on a generator a contract that Application declares (EE-STD-0006 §4), and a test gives the code a fake that is not random at all. | A source of chance, through a contract that Application declares |
| `wait`, `delay`, `spawn` | Nowhere | Deprecated: the task library replaces them, and they resume late, at the pace of a throttled scheduler. | `task.wait`, `task.delay`, `task.spawn` |
| `tick` | Nowhere | Discouraged by Roblox: its result depends on the clock and the time zone of the machine that runs it. | `os.clock`, `os.time`, `DateTime` |
| `math.random`, `math.randomseed` | Nowhere | Global state: they share one generator, hidden in the math library outside the container (EE-STD-0006 §7), which any code may reseed and whose numbers no test can fix. | `Random.new`, in Infrastructure, behind a contract that Application declares |
| `loadstring` | Nowhere | Unsafe: it runs code that the type checker, checkpatch and the Approver of record never see. | A module, required by a static path |
| `getfenv`, `setfenv` | Nowhere | Deprecated by Luau, and unsafe: they read and replace the environment of other functions, hiding globals from the type checker and from this registry. | Requires and parameters |
| `_G`, `shared` | Nowhere | Unsafe: they hold global state outside the container, found by name, which EE-STD-0006 §7 forbids. | A service, resolved by its token |

2. An API is used wherever it is named: in a call, in an alias such as `local log = print`, or through a member, as in `game.GetService(game, name)`.
   `wait`, `delay`, `spawn` and `tick` are reported only when they are called, so that a local variable that shares their name, such as `spawn`, is left alone.
3. A field or method of another value that shares the name of an API, as in `logger.print`, is not the API.
4. The table grows by revision of this standard.
   Every entry names the API, where it is still allowed and why, and what is used instead.

## 6. Sanctioned Exceptions

1. A sanctioned exception allows one module, named by its path, to use the prohibited APIs that the register names, for the reason it states.
2. An exception is granted by a change request that revises this register, and takes effect when the Approver of record approves the revision.
3. checkpatch keeps a copy of the register in `scripts/lib/ProhibitedApis.luau`, which the same change request updates.
4. A module that uses an exception says so in a comment beside each use.

| Module | APIs | Reason | Granted by |
|---|---|---|---|
| `src/Shared/Infrastructure/RobloxOutputLoggerAdapter.luau` | `print`, `warn` | It implements `ILogger` on the Roblox output window, which no other API reaches. It is the first sanctioned exception. | CR-0008 |

## 7. Enforcement

checkpatch enforces §4 to §6.
Annex A lists the rules mandated by this standard.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `PROHIBITED_DIRECTIVE` | Error | §4 |
| `PROHIBITED_API` | Error | §5, §6 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | Number reserved. | Architecture Review Board |
| 0.9.0 | 2026-10-30 | Drafted with the law of the Roblox code (CR-0008). | Architecture Review Board |
| 1.0.0 | 2026-10-30 | Approved. | Architecture Review Board |
| 1.1.0 | 2026-10-31 | §5: `Random.new` allowed only in Infrastructure, and `math.random` and `math.randomseed` prohibited (CR-0022). | Architecture Review Board |
| 1.1.1 | 2026-11-01 | Reviewed against EE-STD-0001 2.0; citation updated (CR-0025). | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved | 2026-11-01 |
