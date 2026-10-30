---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0004
title: Change Management Policy
version: 1.1.0
status: Approved
classification: Internal
owner: Change Advisory Board
parent: EE-CHR-0001@1.0
---

# Change Management Policy

## 1. Purpose

This policy governs how anything in the repository changes.
It gives effect to the third core value of the Charter: every change has a request (EE-CHR-0001, Article 3).

## 2. Scope

1. This policy applies to every change to every file in the repository, including this policy.
2. Commit `8f2b559` predates it and is exempt (EE-CHR-0001, Article 7).

## 3. Definitions

| Term | Definition |
|---|---|
| Change | Any commit to the repository. |
| Change request | A record that requests a change, filed on the form in EE-TPL-0002. |
| Feature branch | The branch on which one change request is implemented. |
| Approver of record | The person who approves on behalf of the Board of Directors (EE-CHR-0001, Article 5). |

## 4. Change Requests

1. A change request is filed before work on the change starts.
2. One change request covers one coherent change. Unrelated changes are requested separately.
3. A change request moves through the statuses of its kind (EE-POL-0001 §10).

| Status | Meaning |
|---|---|
| `Submitted` | Filed and awaiting a decision. |
| `Approved` | Work may proceed. |
| `Rejected` | Work may not proceed. |
| `Implemented` | The change is complete, and merged or about to be. |
| `Closed` | The request accepts no further commits. |

4. Approval is given by a person, the Approver of record.
   No agent approves a change request, a document or a merge on its own, whether or not it is able to.
5. A request is filed in the name of the unit that owns what it changes, even when a person asked for it.
6. A request is filed as `Submitted`, or as `Approved` when the Approver of record approved it in words before it was filed.
   In either case, the Approval section records the decision and its date.

## 5. Branching Model

1. The repository follows git-flow.

| Branch | Purpose | Taken from | Merged into |
|---|---|---|---|
| `main` | The released state. | — | — |
| `develop` | The integration of approved changes. | `main` | `main`, through a release |
| `feature/CR-<NNNN>-<slug>` | One change request. | `develop` | `develop` |
| `release/<version>` | The preparation of a release. | `develop` | `main` and `develop` |
| `hotfix/SEV<1-4>-<slug>` | An urgent fix to a release. | `main` | `main` and `develop` |

2. `main` and `develop` receive merge commits only. No one commits to them directly.
3. Every merge is made with `--no-ff`, so that each change remains visible in the history as one unit.
4. Branch names follow EE-STD-0007.

## 6. Commits

1. Every commit cites the change request that it implements, and follows EE-STD-0007.
2. Every commit leaves the repository in a state that passes `tools/check`.
3. Before a commit is made, the files staged for it are reviewed (CR-0002).

## 7. Approval and Merging

1. When the work is complete, the implementing commits are listed in the Implementation Record of the change request, which is set to `Implemented` with its MINOR incremented.
2. The Approver of record reviews the result and approves the merge.
3. The merge commit carries an `Approved-by` trailer that names the Approver of record.
4. Controlled documents changed by the request are approved in the same review, and move from `In Review` to `Approved` before the merge (EE-POL-0001 §10).
5. For a revision of an approved document, the Approval section records the approval of the new version, and the Revision History keeps the earlier ones.

## 8. Corrective Changes

1. A mistake that has been committed is corrected by a new change request, never by rewriting history (EE-CHR-0001, Article 7).
2. A corrective change request records the root cause of the mistake and the corrective action, as CR-0002 did.

## 9. Emergency Changes

1. An emergency is not an exemption. It is a change request filed faster.
2. An urgent fix to a release is made on a hotfix branch named after the severity of the incident, and the incident is followed by a postmortem.

## 10. Enforcement

This policy is enforced through EE-STD-0007, whose rules the commit-msg hook applies to every commit.
It mandates no checkpatch rule of its own.

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Change Advisory Board |
| 1.0.0 | 2026-10-30 | Approved. | Change Advisory Board |
| 1.1.0 | 2026-10-30 | Requests approved before filing, the filing unit, and the approval of revisions. | Change Advisory Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Change Advisory Board | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
