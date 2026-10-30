---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0004
title: Architecture Decision Record Template
version: 1.0.0
status: Approved
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@1.0
---

# Architecture Decision Record Template

## 1. Usage

1. An architecture decision record captures one architectural decision and its reasons, once the decision has been made.
2. Copy the form below to `docs/adr/ADR-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. The record starts as `Proposed` and becomes `Accepted` when the decision is approved.
4. An accepted decision is never edited to change it.
   A new record supersedes it; the old record is set to `Superseded` and names its successor.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: ADR-<NNNN>
title: <Decision, Stated as a Title>
version: 1.0.0
status: Proposed
classification: Internal
owner: Architecture Review Board
---

# <Decision, Stated as a Title>

## 1. Context

<The forces at play: the problem, the constraints, and what is already in place.>

## 2. Decision

<The decision, in active voice: "We will ...".>

## 3. Consequences

| Kind | Consequence |
|---|---|
| Positive | <What becomes easier.> |
| Negative | <What becomes harder.> |
| Neutral | <What merely becomes different.> |

## 4. Alternatives Considered

| Alternative | Reason it was not chosen |
|---|---|
| <Alternative> | <Reason> |

## 5. Related Decisions

| Relation | Record |
|---|---|
| Supersedes | <ADR identifier, or none> |
| Superseded by | <ADR identifier, or none> |
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
