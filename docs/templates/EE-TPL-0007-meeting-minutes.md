---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0007
title: Meeting Minutes Template
version: 0.9.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@0.9
---

# Meeting Minutes Template

## 1. Usage

1. Minutes are kept for every meeting, by a minute-taker appointed at the start of the meeting.
2. Copy the form below to `docs/records/minutes/MIN-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
3. Minutes are `Draft` until they are approved at the next meeting, and `Approved` thereafter.
   The minutes of that meeting are approved at the meeting after it.
4. A meeting whose only agenda item is the approval of the previous minutes is still a meeting, and has minutes.

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: MIN-<NNNN>
title: <Title in Title Case>
version: 1.0.0
status: Draft
classification: Internal
owner: <Convening unit>
---

# <Title in Title Case>

## 1. Meeting Information

| Item | Detail |
|---|---|
| Date | <YYYY-MM-DD> |
| Time | <HH:MM> to <HH:MM> |
| Place | <Place> |
| Chair | <Name> |
| Minute-taker | <Name> |

## 2. Attendees

- <Name, unit>

## 3. Absentees

| Name | Reason |
|---|---|
| <Name> | <Reason> |

## 4. Agenda

1. Approval of the previous minutes (<MIN identifier, or none>)
2. <Item>

## 5. Discussion

### 5.1 <Agenda item>

<Summary of the discussion.>

## 6. Decisions

1. <Decision.>

## 7. Action Items

| Action | Owner | Due |
|---|---|---|
| <Action> | <Name> | <YYYY-MM-DD> |

## 8. Next Meeting

<YYYY-MM-DD, place. Its first agenda item is the approval of these minutes.>
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
