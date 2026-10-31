---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0004
title: Establish the Change Management Policy and the Engineering Standards
version: 1.2.0
status: Implemented
classification: Internal
owner: Compliance Engineering
---

# Establish the Change Management Policy and the Engineering Standards

## 1. Summary

checkpatch enforces 27 rules whose mandating documents do not exist.
This change request writes those documents, so that no rule of the Company is enforced without one.

## 2. Background

The rules for commit messages, branches, file hygiene and the toolchain were built with CR-0001, before any standard existed.
Each of them names the standard that mandates it, and none of those standards has been written.
Under the Charter, a rule that is not written in a controlled document is not a rule; the Company has therefore been rejecting commits on the authority of nothing.

## 3. Scope

- The Change Management Policy: change requests, the branching model, approval and merging, corrective and emergency changes.
- The Luau Coding Standard, the File Header Standard, the Commit and Branch Standard, and the Text File and Documentation Standard.
- Two new rules: every Luau file declares strict mode, and every file that can carry a comment carries an SPDX header.
- SPDX headers for the configuration files committed before the File Header Standard existed.
- Reserved numbers for the policy and the four standards that come before or between the new ones, as placeholders in `Draft`, so that numbers stay sequential.

### Scope note

The standards for Roblox code (naming, prohibited APIs, numeric literals and architecture layers) are reserved but not written.
They will be drafted together with the template skeleton, so that the rules and the code they govern are designed together.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. |
| Rules without a mandating document | From 27 to 0. |
| Developer productivity | Unchanged, because the rules already apply. They are merely explained now. |
| Documentation volume | Increases by eleven documents in two languages. |

## 5. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Compliance Engineering | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
| Implementer | Compliance Engineering | Implemented | 2026-10-30 |

## 6. Implementation Record

| Commit | Change |
|---|---|
| `7468e29` | Filed this change request. |
| `03379b1` | Added `MISSING_STRICT_MODE` and `MISSING_SPDX_HEADER`, and gave five configuration files their SPDX header. |
| `390edbf` | Submitted EE-POL-0004, EE-STD-0001, EE-STD-0004, EE-STD-0007 and EE-STD-0009 for review, and reserved EE-POL-0003, EE-STD-0002, EE-STD-0003, EE-STD-0005, EE-STD-0006 and EE-STD-0008. |
| `589d908` | Approved the five documents at 1.0.0. |

## Rollback Plan

Added retroactively by CR-0006, because this request was filed without the section that its form requires.
Revert merge commit `3312a8f`. Twenty-seven rules would again lack a mandating document, and five configuration files their SPDX header.
