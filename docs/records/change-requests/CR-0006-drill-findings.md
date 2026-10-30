---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0006
title: Correct the Findings of the First Onboarding Drill
version: 1.1.0
status: Implemented
classification: Internal
owner: Document Control Office
---

# Correct the Findings of the First Onboarding Drill

## 1. Summary

The first onboarding drill found six faults in the rules of the Company.
This change request corrects them, and adds a rule so that one of them cannot recur.

## 2. Background

An agent with no context was given one ordinary task, and was not told that `AGENTS.md` exists.
It found the entrance, filed its request as `Submitted`, and stopped at the point of approval, as the rules require.
Its request was never merged; it is preserved under the tag `archive/drill-0001`.

It reported six findings.

| Finding | Fault |
|---|---|
| 1 | An approved document cannot be revised: a revision must pass through `In Review`, which allowed only `0.x.y` versions. |
| 2 | `AGENTS.md` described MAJOR as "for obligations", against EE-POL-0001 §9. |
| 3 | EE-POL-0006 says that an agent never signs off, while `AGENTS.md` has the agent write the sign-off. |
| 4 | Unit names such as Release Engineering, and code identifiers such as `hotfix`, were translated inconsistently with the terminology of EE-POL-0002. |
| 5 | Nothing stated how a request approved before it was filed is recorded. |
| 6 | Change requests CR-0002 to CR-0005 were filed without the Rollback Plan that their form requires. |

## 3. Scope

- EE-POL-0001: a revision is reviewed at its new version; a record contains every section of the form for its kind.
- EE-POL-0002: names of organizational units may be transliterated, and code identifiers are never translated.
- EE-POL-0004: requests approved before filing, the unit in whose name a request is filed, and the approval of revisions.
- EE-POL-0006: an agent writes a sign-off only for the person it works for, with their authority.
- EE-TPL-0002: the starting status of a request, aligned with EE-POL-0004.
- Every child of a revised policy, reviewed against the new revision and its citation updated.
- checkpatch: `VERSION_STATUS_MISMATCH` accepts revisions in review, and a new rule, `TEMPLATE_SECTION_MISSING`, requires the sections of the form.
- Rollback plans for CR-0002 to CR-0005, added retroactively.
- `AGENTS.md`, `CLAUDE.md` and `.gitignore`: the corrected wording, new entries among the mines, and the agent worktrees ignored.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. |
| Documents in review | Thirteen controlled documents return to review, because one policy changed and its children must follow. This is the hierarchy working as designed. |
| Developer productivity | Approved documents can be revised again. |
| Records | Four implemented change requests receive the section they were filed without. |

## 5. Rollback Plan

Revert the merge commit of this change.
Approved documents would again be impossible to revise, including the documents that would have to be revised to roll this change back.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved before filing | 2026-10-30 |
| Implementer | Document Control Office | Implemented | 2026-10-30 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `b765978` | Filed this change request. |
| `88c7ee0` | Let revisions of approved documents be reviewed at their new version. |
| `af9353f` | Added the rollback plans that CR-0002 to CR-0005 lacked. |
| `adc5994` | Submitted the thirteen revised documents for review. |
| `d986d66` | Added `TEMPLATE_SECTION_MISSING`. |
| `41727ef` | Corrected `AGENTS.md` and `CLAUDE.md`, and ignored the agent worktrees. |
| `7991580` | Approved the thirteen revisions. |
