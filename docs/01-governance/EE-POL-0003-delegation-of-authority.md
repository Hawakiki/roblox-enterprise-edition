---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0003
title: Delegation of Authority
version: 1.0.0
status: Approved
classification: Internal
owner: Board of Directors
parent: EE-CHR-0001@1.0
---

# Delegation of Authority

## 1. Purpose

This policy sets which decisions each unit of the Company may approve on its own authority, and which go higher.

## 2. Scope

1. This policy covers every decision that the repository records: change requests, documents, merges, releases, deployments, architecture decisions, approval requests and sanctioned exceptions.
2. The units, whom they report to and who holds them are those of the Organization Chart (EE-ORG-0001).

## 3. Definitions

| Term | Meaning |
|---|---|
| Delegation | The authority of a unit to approve a decision in the name of the Company without taking it higher; *jeongyeol* in Korean practice. |
| Approval line | The holders an approval request passes, from left to right (EE-TPL-0005). |

## 4. Delegation

1. A decision is approved by the holder of the unit that the table names, or by the holder of any unit above it in EE-ORG-0001.

| Decision | Approved by | Recorded in |
|---|---|---|
| Filing a change request as approved | Change Advisory Board | its Approval section and status (EE-POL-0004 §4) |
| Merging into `develop` or `main` | Change Advisory Board | the `Approved-by` trailer of the merge (EE-POL-0004 §7) |
| A controlled document, or a revision of one | The unit that owns it | its Approval section and status (EE-POL-0001 §10) |
| An architecture decision record | Architecture Review Board | its status (EE-TPL-0004) |
| The deployment of a release | Release Engineering | the environment `production` (EE-STD-0008 §6) |
| A sanctioned exception to the Prohibited API Registry | Compliance Engineering | the register of EE-STD-0003 §6 |
| An approval request | Every holder on its approval line | its approval line (EE-TPL-0005) |
| Engaging an agent for an assignment | Human Resources | the session that engages it |
| Anything this table does not name | Board of Directors | — |

2. The Approver of record holds every unit (EE-ORG-0001, §4).
   Every decision in the table is therefore approved by the Approver of record, as the documents that record it already require, and the table names the unit in whose name each approval is given.
3. An agent holds no unit and approves nothing (EE-POL-0006 §4).
4. In a company of one, the person who requests a decision is the person who approves it.
   Such an approval stands, and is recorded as any other; it is why the environment `production` lets its one reviewer approve a deployment that the same person started.

## 5. Enforcement

This policy mandates no checkpatch rule.
Each approval is recorded as the document that the table cites requires, and is checked there.

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | Number reserved. | Board of Directors |
| 0.9.0 | 2026-10-31 | Drafted with the Organization Chart, and submitted for review (CR-0021). | Board of Directors |
| 1.0.0 | 2026-10-31 | Approved. | Board of Directors |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Board of Directors | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved | 2026-10-31 |
