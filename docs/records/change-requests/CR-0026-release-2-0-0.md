---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0026
title: Release EnterpriseEdition 2.0.0
version: 1.2.0
status: Implemented
classification: Internal
owner: Release Engineering
---

# Release EnterpriseEdition 2.0.0

## 1. Summary

This change request releases EnterpriseEdition 2.0.0, the first release checked by the new Luau type solver alone, as Roblox Studio checks a script (CR-0025).
Its constructors return their instance without a cast through `any`, and its code has none left.
It is a MAJOR release because it removes an obligation of an approved document and alters another, although no contract, service token, remote or stored record of the code has changed.

## 2. Background

CR-0025 has been approved into `develop` since 1.2.0.
It removes the obligation of EE-STD-0001 §4 to type-check every Luau file under the old solver. It alters that of EE-STD-0006 §6: a constructor that casts its instance through `any`, as 1.2.0 required, is now reported.
Both standards went up to 2.0.0, and the release is therefore numbered 2.0.0 (EE-STD-0008 §4.2).
A user of the template whose classes follow 1.2.0 must remove the cast from each constructor.

No contract module, service token registry or `DataStoreConstants` has changed since `v1.2.0`. `default.project.json` gains one property of the Workspace, the solver it is checked with, and no remote.
The only other change request cited since `v1.2.0` is CR-0024, by the merge of `release/1.2.0` back into `develop`, and it belongs to 1.2.0 (EE-STD-0008 §5.3).

## 3. Scope

- `release/2.0.0`, taken from `develop` (EE-POL-0004 §5).
- A rehearsal in a new clone, never pushed: the release merged into `main` and the merge commit tagged there, the tag checked out detached as the workflow checks it out, every check run, the place built and the notes of 2.0.0 generated.
- After approval, outside a change freeze: `release/2.0.0` merged into `main` with `--no-ff`, the merge commit tagged `v2.0.0`, and `release/2.0.0` merged back into `develop`.
- Pushing `main`, `develop` and the tag, and approving the deployment in the environment `production`, are left to the Approver of record.
  The request that follows records how the workflow deployed 2.0.0.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| `main` | Moves from 1.2.0 to 2.0.0, by way of one merge commit. |
| Releases | 2.0.0 is published with its place and its notes, and becomes the latest release. |
| Users of the template | A class written for 1.2.0 drops the cast from its constructor. Nothing else is required of them. |
| Roblox code | As `develop` holds it. The release branch changes it only if the rehearsal finds a defect. |
| Documentation volume | One change request. |

## 5. Rollback Plan

Delete the GitHub release of `v2.0.0`, and revert the merge commits on `main` and on `develop`.
The tag stays, as the ruleset requires. A correction is released as 2.0.1 (EE-STD-0008 §4.6).

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Release Engineering | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved before filing | 2026-11-01 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `5e61b48` | Filed this change request on `release/2.0.0`. |

Before this request was marked as implemented, the release was rehearsed in a new clone, which was never pushed.
There, `release/2.0.0` was merged into `main` and the merge commit tagged `v2.0.0`, and the tag was checked out detached, as the workflow checks it out. Its tree was the tree of `release/2.0.0`.
`tools/check.sh` passed with the new solver alone and the Roblox definitions downloaded afresh, and `rojo build` built the place, 54841 bytes, the size of the place checked in Roblox Studio under CR-0025.
The notes of 2.0.0 listed CR-0025 and CR-0026, and left out CR-0024.
The calendar admitted a deployment at 2026-11-01T02:21:14Z.
The rehearsal found no defect, so the release branch changes nothing but this record.

| Commit | Change |
|---|---|
| `d4e9b0c` | Marked this request as implemented. |

The Approver of record approved the merge on 2026-11-01, and the calendar admitted a deployment at 2026-11-01T02:44:25Z.
The merge into `main`, the tag `v2.0.0` and the merge back into `develop` follow this record.
