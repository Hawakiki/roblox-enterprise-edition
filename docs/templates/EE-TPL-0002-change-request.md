---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0002
title: Change Request Template
version: 1.0.0
status: Approved
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@1.0
---

# Change Request Template

## 1. Usage

1. File the change request before any work starts. Take the next number from the registry.
2. Copy the form below to `docs/records/change-requests/CR-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. Commit the request on its own, on a branch named `feature/CR-<NNNN>-<slug>` taken from `develop`, citing itself as `Change-Request: CR-<NNNN>`.
4. The request starts as `Submitted`.
   The Approver of record approves it by recording the decision in the Approval section and setting `Approved`.
   Commits that cite a request that is not yet approved draw a warning.
5. Before the branch is merged, list the implementing commits under Implementation Record, set `Implemented` and increment MINOR.
6. A request that will receive no further commits is `Closed`; a request that is turned down is `Rejected`. Neither accepts commits.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: CR-<NNNN>
title: <Title in Title Case>
version: 1.0.0
status: Submitted
classification: Internal
owner: <Requesting unit>
---

# <Title in Title Case>

## 1. Summary

<What changes, in one or two sentences.>

## 2. Background

<Why the change is needed.>

## 3. Scope

- <One item for each thing that changes.>

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | <Impact> |
| Developer productivity | <Impact> |
| Documentation volume | <Impact> |

## 5. Rollback Plan

<How the change is undone. Undoing it requires a change request of its own.>

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | <Requesting unit> | Submitted | <YYYY-MM-DD> |
| Approver | <Approver of record> | Pending | — |

## 7. Implementation Record

| Commit | Change |
|---|---|
| <Filled in when the request is implemented.> | |
````

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |
| 1.0.0 | 2026-10-30 | Approved. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
