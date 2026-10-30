---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0003
title: Request for Comments Template
version: 0.9.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@0.9
---

# Request for Comments Template

## 1. Usage

1. A request for comments proposes a significant change for discussion, before any change request is filed.
2. Copy the form below to `docs/rfc/RFC-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. The request starts as `Draft`, and becomes `Discussion` when the discussion period opens.
4. It closes as `Accepted`, `Rejected` or `Withdrawn`.
   An accepted request is carried out through one or more change requests, each of which cites it.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: RFC-<NNNN>
title: <Title in Title Case>
version: 1.0.0
status: Draft
classification: Internal
owner: <Proposing unit>
---

# <Title in Title Case>

## 1. Summary

<The proposal, in one paragraph.>

## 2. Motivation

<The problem the proposal solves, and why it is worth solving now.>

## 3. Detailed Design

<The proposal in enough detail that someone else could implement it.>

## 4. Drawbacks

<Why the proposal should not be accepted.>

## 5. Alternatives Considered

| Alternative | Reason it was not chosen |
|---|---|
| <Alternative> | <Reason> |

## 6. Unresolved Questions

- <Question to settle during the discussion.>

## 7. Discussion Period

| Opens | Closes |
|---|---|
| <YYYY-MM-DD> | <YYYY-MM-DD>, or later while anyone still has an opinion |

## 8. Decision

| Decision | Decided by | Date |
|---|---|---|
| <Accepted, Rejected or Withdrawn> | <Name> | <YYYY-MM-DD> |
````

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |
