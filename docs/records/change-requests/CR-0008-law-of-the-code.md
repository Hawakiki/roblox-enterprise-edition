---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0008
title: Lay Down the Law of the Roblox Code
version: 1.0.0
status: Submitted
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

The reserved numbers were each to be drafted through a change request of their own.
The Approver of record assigned the three parts as one request, because together they are one coherent change: the law of one body of code (EE-POL-0004 §4).
The request itself was not approved in words, and is therefore filed as `Submitted` (EE-POL-0004 §4).

## 3. Scope

- EE-STD-0003, the Prohibited API Registry, drafted on its reserved number: the allow-list of directives and attributes, the prohibited APIs with where each is still allowed, and the register of sanctioned exceptions.
  Two new rules: `PROHIBITED_DIRECTIVE` and `PROHIBITED_API`.
- EE-STD-0005, the Numeric Literal Standard, drafted on its reserved number.
  One new rule: `NUMERIC_LITERAL`.
- EE-STD-0001, the Luau Coding Standard, revised: Moonwave doc comments for the Roblox code.
  Four new rules: `MISSING_MODULE_DOC`, `MISSING_FUNCTION_DOC`, `INCOMPLETE_DOC_COMMENT` and `DOC_COMMENT_LANGUAGE`.
- EE-STD-0002 and EE-STD-0006, reviewed against the new revision of EE-STD-0001 and their citations updated.
- checkpatch: a Luau lexer, so that the new rules read code and not the comments and strings around it.
- Every module under `src/`, rewritten to comply without a change in behaviour: two Kernel Constants modules, and doc comments throughout.
- `AGENTS.md`: where the new standards are read.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | Unchanged. The same two lines are printed, by the one module licensed to print them. |
| Numbers in the code | Every number under `src/` acquires a name and a module of its own. Writing `1` now takes a require. |
| Developer productivity | Every function now comes with a paragraph that describes it, and every module with two. This is intended. |
| Documentation volume | Unchanged in number: two reserved standards are written and one is revised, none is added. |

## 5. Rollback Plan

Revert the merge commit of this change.
The code would again be free to print, to count from one without saying so, and to keep its purpose to itself.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |

## 7. Implementation Record

| Commit | Change |
|---|---|
| <Filled in when the request is implemented.> | |
