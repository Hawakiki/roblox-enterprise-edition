---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0001
title: Luau Coding Standard
version: 0.9.0
status: In Review
classification: Internal
owner: Architecture Review Board
parent: EE-CHR-0001@1.0
---

# Luau Coding Standard

## 1. Purpose

This standard sets the rules that every Luau file in the repository follows, whatever it does.

## 2. Scope

1. This standard applies to every `.luau` file: the tooling under `scripts/` and, once it exists, the Roblox code of the template.
2. The Roblox code is further governed by the standards reserved for naming (EE-STD-0002), prohibited APIs (EE-STD-0003), numeric literals (EE-STD-0005) and architecture layers (EE-STD-0006), once they are drafted.

## 3. Strict Mode

1. Every Luau file declares `--!strict` among its leading comment lines, before any code or block comment (`MISSING_STRICT_MODE`).
2. A `.luaurc` file may set strict mode as well, but Roblox Studio does not read it; the hot comment is the only setting that holds everywhere.

## 4. Type Checking

1. Every Luau file type-checks without errors under both the old and the new type solver, that is with `LuauSolverV2` off and on.
   Roblox Studio uses the new solver; the old one still catches what the new one misses.
2. Tooling under `scripts/` is checked against the standard platform and the Lune type definitions; Roblox code against the Roblox platform and a sourcemap.
3. `tools/check` runs both solvers.

## 5. Formatting

1. Every Luau file is formatted by StyLua with the configuration in `stylua.toml`: tabs, 120 columns, double quotes, parentheses on every call.
2. `tools/check` verifies the formatting, and `tools/check --fix` applies it.

## 6. Comments

1. Every module opens, below its file header (EE-STD-0004), with a block comment that states its purpose in English and then in Korean.
2. Every other comment is written in English, and explains why rather than what.

## 7. Requires

1. Modules are required by static paths, so that the type checker can follow them.
2. Tooling requires its modules relatively, as in `require("./lib/Report")`.
3. Roblox code requires modules through instance paths from a service, as in `require(ReplicatedStorage.EnterpriseEdition.Shared.Types)`.
   It never requires through `WaitForChild`, which hides the module from the type checker.

## 8. Toolchain

1. Tool versions are pinned in `rokit.toml`.
2. Configuration that names a tool version agrees with `rokit.toml` (`TOOLCHAIN_VERSION_MISMATCH`).
   Today this is the alias for the Lune type definitions in `scripts/.luaurc`.
3. `lune setup` writes a `.luaurc` into the directory it runs in; the one it writes at the root is ignored (CR-0002).

## 9. Tooling

Tooling under `scripts/` follows the tradition of the Linux kernel.
Entry scripts are named in snake case after what they do, as in `checkpatch` and `gen_registry`; modules are named in Pascal case.
Tooling is exempt from the naming standard.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `MISSING_STRICT_MODE` | Error | §3 |
| `TOOLCHAIN_VERSION_MISMATCH` | Error | §8 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |
