---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0001
title: Controlled Document Template
version: 1.0.1
status: Approved
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@1.1
---

# Controlled Document Template

## 1. Usage

1. Choose the kind of the document and its parent, which is at the same or a higher level (EE-POL-0001 §4, §11).
2. Take the next number of the kind from the registry, and choose a slug (EE-POL-0001 §5, §6).
3. Copy the form below to `<folder>/EE-<CODE>-<NNNN>-<slug>.md`, and the form in the Korean version of this template to the same path ending in `.ko.md`.
4. Replace every placeholder in angle brackets.
5. A new document starts as `Draft` at `0.1.0`.
   It is submitted as `In Review`, still at `0.x.y`, and becomes `Approved` at `1.0.0` when the Approver of record approves it.
6. List under Enforcement the codes of the checkpatch rules that the document mandates.
   If there are none, say so; the document is then a recommendation (EE-CHR-0001, Article 4).

## 2. Form

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: EE-<CODE>-<NNNN>
title: <Title in Title Case>
version: 0.1.0
status: Draft
classification: Internal
owner: <Owning unit>
parent: <Parent identifier>@<MAJOR.MINOR>
---

# <Title in Title Case>

## 1. Purpose

<Why this document exists, in one or two sentences.>

## 2. Scope

<What this document applies to, and what it does not.>

## 3. Definitions

| Term | Definition |
|---|---|
| <Term> | <Definition> |

## 4. <Provisions>

1. <One obligation per item, one sentence per line.>

## 5. Enforcement

<The codes of the checkpatch rules that enforce this document, or: None. This document is a recommendation.>

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | <YYYY-MM-DD> | Drafted. | <Owning unit> |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | <Owning unit> | Submitted | <YYYY-MM-DD> |
| Approver | <Approver of record> | Pending | — |
````

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |
| 1.0.0 | 2026-10-30 | Approved. | Document Control Office |
| 1.0.1 | 2026-10-30 | Reviewed against EE-POL-0001 1.1; citation updated. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
