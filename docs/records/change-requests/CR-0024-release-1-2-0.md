---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0024
title: Release EnterpriseEdition 1.2.0
version: 1.1.0
status: Implemented
classification: Internal
owner: Release Engineering
---

# Release EnterpriseEdition 1.2.0

## 1. Summary

This change request releases EnterpriseEdition 1.2.0.
It brings the first code review of the Company and its seven corrections (CR-0018), its first architecture decision records and the test that says when one has gone stale (CR-0019, CR-0020, CR-0023), its organization chart and delegation of authority (CR-0021), and the prohibition of the global random number generator (CR-0022).
The next release is planned to remove the old type solver, and would then be numbered 2.0.0.

## 2. Background

CR-0018 to CR-0023 have been approved into `develop` since 1.1.0.
Together they correct seven defects of the Roblox code, bring into the repository the harness that runs it under Lune, write a policy on its reserved number and an organization chart, file two decision records, add two checkpatch rules, and revise three standards, each at a MINOR version.

They alter nothing that a user of 1.1.0 relies on (EE-STD-0008 §4.2).
No contract module, service token registry, `default.project.json` or `DataStoreConstants` has changed since `v1.1.0`, and the record that a wallet keeps in a data store has the same fields.
Every approved document they revise went up a MINOR version, so no obligation was removed or altered.
The release is therefore numbered 1.2.0 (EE-STD-0008 §4.3).

## 3. Scope

- `release/1.2.0`, taken from `develop` (EE-POL-0004 §5).
- A rehearsal in a new clone, never pushed: the release merged into `main` and the merge commit tagged there, the tag checked out detached as the workflow checks it out, every check run, the place built and the notes of 1.2.0 generated.
- After approval, outside a change freeze: `release/1.2.0` merged into `main` with `--no-ff`, the merge commit tagged `v1.2.0`, and `release/1.2.0` merged back into `develop`.
- Pushing `main`, `develop` and the tag, and approving the deployment in the environment `production`, are left to the Approver of record.
  The request that follows records how the workflow deployed 1.2.0.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| `main` | Moves from 1.1.0 to 1.2.0, by way of one merge commit. |
| Releases | 1.2.0 is published with its place and its notes, and becomes the latest release. |
| Roblox code | As `develop` holds it. The release branch changes it only if the rehearsal finds a defect. |
| Documentation volume | One change request. |

## 5. Rollback Plan

Delete the GitHub release of `v1.2.0`, and revert the merge commits on `main` and on `develop`.
The tag stays, as the ruleset requires. A correction is released as 1.2.1 (EE-STD-0008 §4.6).

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Release Engineering | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved before filing | 2026-11-01 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `faca30a` | Filed this change request on `release/1.2.0`. |

Before this request was marked as implemented, the release was rehearsed in a new clone, which was never pushed.
There, `release/1.2.0` was merged into `main` and the merge commit tagged `v1.2.0`, and the tag was checked out detached, as the workflow checks it out. Its tree was the tree of `release/1.2.0`.
`tools/check.sh` passed, with the Roblox definitions downloaded afresh, and `rojo build` built the place, 54824 bytes.
The notes of 1.2.0 listed CR-0018 to CR-0024, and left out CR-0017, which the merge of `release/1.1.0` back into `develop` cites again.
The calendar admitted a deployment at 2026-11-01T01:09:17Z.
The rehearsal found no defect, so the release branch changes nothing but this record.
