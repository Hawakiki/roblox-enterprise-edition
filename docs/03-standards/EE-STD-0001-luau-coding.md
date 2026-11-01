---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0001
title: Luau Coding Standard
version: 2.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-CHR-0001@1.0
---

# Luau Coding Standard

## 1. Purpose

This standard sets the rules that every Luau file in the repository follows, whatever it does.

## 2. Scope

1. This standard applies to every `.luau` file: the tooling under `scripts/` and the Roblox code under `src/`.
2. The Roblox code is further governed by the Naming Convention (EE-STD-0002), the Prohibited API Registry (EE-STD-0003), the Numeric Literal Standard (EE-STD-0005) and the Layered Architecture Standard (EE-STD-0006).
3. The directives of every Luau file, the tooling included, are governed by the Prohibited API Registry (EE-STD-0003).

## 3. Strict Mode

1. Every Luau file declares `--!strict` among its leading comment lines, before any code or block comment (`MISSING_STRICT_MODE`).
2. A `.luaurc` file may set strict mode as well, but Roblox Studio does not read it; the hot comment is the only setting that holds everywhere.
3. `--!strict` is the only directive that a Luau file declares.
   A file that declares another directive beside it is reported under EE-STD-0003, whichever of the two comes first.

## 4. Type Checking

1. Every Luau file type-checks without errors under the new type solver, that is with `LuauSolverV2` on, as Roblox Studio checks it.
2. Tooling under `scripts/` is checked against the standard platform and the Lune type definitions; Roblox code against the Roblox platform and a sourcemap.
3. `tools/check` runs the new solver alone.
   The old solver is not run. What it alone reported, a mistake that involves the type parameter inside the body of a generic function, is accepted as lost (ADR-0003).

## 5. Formatting

1. Every Luau file is formatted by StyLua with the configuration in `stylua.toml`: tabs, 120 columns, double quotes, parentheses on every call.
2. `tools/check` verifies the formatting, and `tools/check --fix` applies it.

## 6. Comments

1. Every module opens, below its file header (EE-STD-0004), with a block comment that states its purpose in English and then in Korean.
2. Every other comment is written in English, and explains why rather than what.
3. In the Roblox code under `src/`, the comments that document the code are Moonwave doc comments: block comments that open with `--[=[` on a line of their own and close with `]=]`.
   A comment of any other form documents nothing.
   The tooling under `scripts/` keeps the block comment of §6.1 and needs no doc comments.
4. The block comment of §6.1 is a doc comment that carries `@class` with the name of the module (`MISSING_MODULE_DOC`).
   A composition root has no module name, and gives its class a name of its own, such as `ServerCompositionRoot`.
5. A contract module also documents its contract with `@interface` and `@within`, both naming the module, and lists the members of the contract as fields (`MISSING_MODULE_DOC`).
   Moonwave places every interface within a class, so a contract module carries both a class and an interface.
6. Every public function carries a doc comment directly above it, with no code between them (`MISSING_FUNCTION_DOC`).
   A public function is a function declared on the table that its module returns, as in `function ApplicationHost.Start(self)` or `ApplicationHost.Start = function(self)`, whose name does not start with an underscore.
7. The doc comment of a public function carries `@within` with the class of its module, `@param` for every parameter other than `self`, and `@return` when the function declares a return type other than `()`.
   It documents no parameter that the function does not have (`INCOMPLETE_DOC_COMMENT`).
8. The description of a class or an interface is written in English and then in Korean.
   Every other doc comment, that of a function included, is written in English only (`DOC_COMMENT_LANGUAGE`).
9. Moonwave reads only the doc comments that lead a statement, and silently drops one inside a table constructor.
   A value worth documenting is therefore assigned in a statement of its own.
   A method carries `@method`, a property `@prop` and a type `@type`; these tags are not enforced, and are therefore recommendations (EE-CHR-0001, Article 4).
10. The doc comments are written for Moonwave, but `tools/check` does not generate the documentation site, which needs Node.js.

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
| `MISSING_MODULE_DOC` | Error | §6 |
| `MISSING_FUNCTION_DOC` | Error | §6 |
| `INCOMPLETE_DOC_COMMENT` | Error | §6 |
| `DOC_COMMENT_LANGUAGE` | Error | §6 |
| `TOOLCHAIN_VERSION_MISMATCH` | Error | §8 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Architecture Review Board |
| 1.0.0 | 2026-10-30 | Approved. | Architecture Review Board |
| 1.1.0 | 2026-10-30 | Moonwave doc comments for the Roblox code; `--!strict` as the only directive (CR-0008). | Architecture Review Board |
| 2.0.0 | 2026-11-01 | §4: the new type solver alone; the old one is no longer required (CR-0025). | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved | 2026-11-01 |
