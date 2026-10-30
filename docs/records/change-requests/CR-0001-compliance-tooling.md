---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0001
title: Establish the Change Request Process and Compliance Tooling
version: 1.0.0
status: Approved
classification: Internal
owner: Compliance Engineering
---

# Establish the Change Request Process and Compliance Tooling

## 1. Summary

This change request requests the introduction of change requests.
It also requests the tooling that enforces them, so that the rules of this repository are kept by machines rather than by memory.

## 2. Background

EnterpriseEdition has no process for approving changes.
This includes the change that would introduce such a process.
To break the deadlock, this request is filed first and approved retroactively once the process exists.

## 3. Scope

- A machine-readable frontmatter schema for every document.
- `scripts/checkpatch.luau`: file hygiene, document control and commit message checks.
- `scripts/gen_registry.luau`: the document registry, generated from frontmatter.
- `.githooks/commit-msg`: rejects non-compliant commit messages at the source.
- `tools/check.sh`, `tools/check.ps1`: a single entry point for every check.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. Nothing is delivered yet. |
| Developer productivity | Expected to decrease. This is intended. |
| Documentation volume | Expected to increase significantly. This is also intended. |
| Memory of contributors | No longer relied upon. |

## 5. Rollback Plan

Revert the merge commit of this change.
Note that the revert itself requires a change request, and the process for filing one is removed by the revert.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Compliance Engineering | Submitted | 2026-10-30 |
| Change Advisory Board | Not yet established | Approved retroactively | 2026-10-30 |
