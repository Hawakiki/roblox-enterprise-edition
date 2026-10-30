---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0008
title: Lay Down the Law of the Roblox Code
version: 1.3.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Lay Down the Law of the Roblox Code

## 1. Summary

This change request lays down the law of the Roblox code under `src/`: the directives and APIs it may not use, the only place its numbers may live, and how it documents itself.
It drafts the Prohibited API Registry and the Numeric Literal Standard on their reserved numbers, revises the comment provisions of the Luau Coding Standard, enforces all three with checkpatch, and brings every module under `src/` into compliance.

## 2. Background

The Company has a product of thirteen files, which prints two lines.
Nothing yet stops it from printing them directly, from writing numbers without names, or from keeping its purpose to itself.

The Approver of record decided the content of this request in words, on 2026-10-30, and assigned the work.

| Part | Decision of the Approver of record |
|---|---|
| Directives | `--!strict` is the only directive allowed. `--!nonstrict`, `--!nocheck`, `--!native`, `--!optimize` at any level and the `@native` attribute are prohibited without waiver, because the Company ranks procedure above performance. A file that declares `--!strict` beside another mode no longer passes. |
| APIs | `print`, `warn`, `Instance.new` and direct `game:GetService` calls are prohibited. The use of `print` and `warn` by `RobloxOutputLoggerAdapter` is the first sanctioned exception. The standard says where each prohibited API is still allowed, and why. |
| Numbers | No numeric literal appears under `src/` outside a module whose name ends with `Constants`, zero and one included. Constants modules live in the layer that owns the meaning. |
| Documentation | Every module under `src/` carries a Moonwave doc comment with `@class`, or `@interface` for a contract, described in English and Korean. Every public function carries one with `@within`, and `@param` and `@return` where they apply, in English. |

While the work was in progress, on the same day, the Approver of record relaxed the part on numbers in words, and added a provision on colours.

| Part | Revised decision of the Approver of record |
|---|---|
| Numbers | `0`, `1` and `2` may appear anywhere under `src/`, and so may `-1`, the unary minus applied to `1`. This is the default ignore list of the MagicNumber check of Checkstyle, the industry standard. Every other numeric literal still lives in a Constants module. |
| Colours | Every `Color3` value under `src/` comes from a corporate colour palette, a Constants module that holds the colours of the Company, so that `Color3.new(1, 0, 0)` does not slip through the relaxed rule. Which standard holds the provision, and whether checkpatch enforces it, is left to the drafter. |

The reserved numbers were each to be drafted through a change request of their own.
The Approver of record assigned the three parts as one request, because together they are one coherent change: the law of one body of code (EE-POL-0004 §4).
The request itself was not approved in words, and is therefore filed as `Submitted` (EE-POL-0004 §4).
The Approver of record approved the request after its implementation, on 2026-10-30.

## 3. Scope

- EE-STD-0003, the Prohibited API Registry, drafted on its reserved number: the allow-list of directives and attributes, the prohibited APIs with where each is still allowed, and the register of sanctioned exceptions.
  Two new rules: `PROHIBITED_DIRECTIVE` and `PROHIBITED_API`.
- EE-STD-0005, the Numeric Literal Standard, drafted on its reserved number, with the corporate colour palette.
  Two new rules: `NUMERIC_LITERAL` and `COLOR_OUTSIDE_PALETTE`.
- EE-STD-0001, the Luau Coding Standard, revised: Moonwave doc comments for the Roblox code.
  Four new rules: `MISSING_MODULE_DOC`, `MISSING_FUNCTION_DOC`, `INCOMPLETE_DOC_COMMENT` and `DOC_COMMENT_LANGUAGE`.
- EE-STD-0002 and EE-STD-0006, reviewed against the new revision of EE-STD-0001 and their citations updated.
- checkpatch: a Luau lexer, so that the new rules read code and not the comments and strings around it.
- Every module under `src/`, rewritten to comply without a change in behaviour: a Kernel Constants module for error levels, the corporate colour palette, and doc comments throughout.
- `AGENTS.md`: where the new standards are read.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | Unchanged. The same two lines are printed, by the one module licensed to print them. |
| Numbers in the code | Every number under `src/` other than `-1`, `0`, `1` and `2` acquires a name and a module of its own. Writing `3` now takes a require. |
| Colours | The Company acquires a palette, before it has drawn anything. |
| Developer productivity | Every function now comes with a paragraph that describes it, and every module with two. This is intended. |
| Documentation volume | Unchanged in number: two reserved standards are written and one is revised, none is added. |

## 5. Rollback Plan

Revert the merge commit of this change.
The code would again be free to print, to write any number in any colour, and to keep its purpose to itself.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
| Implementer | Architecture Review Board | Implemented | 2026-10-30 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `0cca85c` | Filed this change request. |
| `152069a` | Named every number of the Kernel in two Constants modules, as first decided. |
| `9b0db07` | Documented every module under `src/` in Moonwave doc comments. |
| `124ccb1` | Revised EE-STD-0001 to 1.1.0 and added the lexer and the four doc comment rules; submitted EE-STD-0002 and EE-STD-0006 for review at 1.0.1. |
| `e9e92ea` | Wrote EE-STD-0003 and added `PROHIBITED_DIRECTIVE` and `PROHIBITED_API`. |
| `7a3666b` | Recorded the relaxed decision on numbers and the provision on colours. |
| `f7119f4` | Removed the Constants module that the relaxed decision made unnecessary. |
| `d340152` | Wrote EE-STD-0005, added the corporate colour palette, `NUMERIC_LITERAL` and `COLOR_OUTSIDE_PALETTE`. |
| `86ab17e` | Routed work on `src/` to the new standards in `AGENTS.md`, and added two mines. |
| `41a1c0f` | Marked this request as implemented. |
| `79000da` | Approved EE-STD-0003 and EE-STD-0005 at 1.0.0, EE-STD-0001 at 1.1.0, and EE-STD-0002 and EE-STD-0006 at 1.0.1. |
