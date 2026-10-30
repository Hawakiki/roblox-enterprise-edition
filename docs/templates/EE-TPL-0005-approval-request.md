---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0005
title: Approval Request Template
version: 0.9.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@0.9
---

# Approval Request Template

## 1. Usage

1. An approval request (pumui-seo) asks for a decision that is not a change to the repository: establishing a committee, adopting a tool, reserving a meeting room.
   A change to the repository is requested through a change request instead (EE-TPL-0002).
2. Copy the form below to `docs/records/approval-requests/APR-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. The request passes along the approval line from left to right.
   Each position either seals it or returns it to the drafter, and a vacant position is skipped.
4. Until the organization chart is approved, every position on the approval line is vacant except that of the Approver of record.
5. The request starts as `Submitted`, and closes as `Approved`, `Rejected` or `Withdrawn`.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: APR-<NNNN>
title: <Title in Title Case>
version: 1.0.0
status: Submitted
classification: Internal
owner: <Drafting unit>
---

# <Title in Title Case>

## Approval Line

| Drafter | Assistant Manager | Manager | General Manager | Approver |
|---|---|---|---|---|
| <Name> (seal) | <Name, or vacant> | <Name, or vacant> | <Name, or vacant> | <Approver of record> |

## 1. Particulars

| Item | Detail |
|---|---|
| Drafted by | <Name, unit> |
| Drafted on | <YYYY-MM-DD> |
| Retention period | Permanent |

## 2. Subject

<What is requested, in one sentence.>

## 3. Reason

<Why the decision is needed.>

## 4. Details

1. <Exactly what is to be approved.>

## 5. Budget

<Amount and source, or: KRW 0. The Company has no budget.>

## 6. Expected Effect

<What changes once the request is approved.>

## 7. Attachments

- <Attachment, or none.>

The above is respectfully submitted for approval.
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
