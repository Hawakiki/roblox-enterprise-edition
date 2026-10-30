---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0006
title: Statement of Circumstances Template
version: 0.9.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@0.9
---

# Statement of Circumstances Template

## 1. Usage

1. A statement of circumstances (gyeongwi-seo) is filed by the person involved in an incident, after the blameless postmortem of that incident.
   The postmortem establishes that no one is to blame. The statement establishes who.
2. Copy the form below to `docs/records/statements/STM-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. The statement starts as `Submitted`, and is either `Accepted` or `Returned` for rewriting.
   A returned statement is rewritten with deeper reflection, its MINOR incremented, and submitted again.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: STM-<NNNN>
title: <Title in Title Case>
version: 1.0.0
status: Submitted
classification: Confidential
owner: <Unit of the person involved>
---

# <Title in Title Case>

## 1. Particulars

| Item | Detail |
|---|---|
| Name | <Name> |
| Unit | <Unit> |
| Time of incident | <YYYY-MM-DD HH:MM> |
| Severity | <SEV1, SEV2, SEV3 or SEV4> |
| Postmortem | <Reference, or: not held> |

## 2. Summary of the Incident

<What happened, in one or two sentences.>

## 3. Circumstances

| Time | What happened |
|---|---|
| <HH:MM> | <Event> |

## 4. Cause

<Why it happened.>

## 5. Reflection

<What I should have done instead.>

## 6. Measures to Prevent Recurrence

1. <Measure.>

## 7. Declaration

I declare that the above is true, and I undertake that it will not happen again.

| Date | Name | Signature |
|---|---|---|
| <YYYY-MM-DD> | <Name> | (seal) |
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
