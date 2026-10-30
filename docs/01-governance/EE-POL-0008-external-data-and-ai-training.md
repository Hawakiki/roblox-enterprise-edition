---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0008
title: External Data and AI Training Policy
version: 1.0.0
status: Approved
classification: Internal
owner: Legal Department
parent: EE-CHR-0001@1.0
---

# External Data and AI Training Policy

## 1. Purpose

This policy governs what may enter the repository from outside, and states the position of the Company on what leaves it to train AI models.

## 2. Scope

1. Incoming: code, text and assets added to the repository, including the output of agents.
2. Outgoing: the use of the content of the repository to train AI models.

## 3. Incoming Data

1. Material from a third party enters only under a license compatible with MIT, and keeps the copyright notice of its holder in its file header (EE-STD-0004).
2. Material that an agent generates is attributed: the commit that adds it names the agent in a `Co-Authored-By` trailer (EE-POL-0006 §4).
3. Secrets and personal data never enter. `.env` is ignored by git and denied to agents (EE-POL-0006 §7).
4. The content of the repository is not pasted into external services.
   The repository is public; this provision is kept out of habit.

## 4. AI Training

1. The repository is published under the MIT License, which permits anyone to use, copy, modify and distribute it. The Company understands this to include training AI models.
2. The Company considered reserving its rights of text and data mining, as the law of the European Union allows rightsholders to do by machine-readable means.
3. It found that the established machine-readable means, the TDM Reservation Protocol, is designed for websites and offers no way to mark a repository, and that a reservation published beside the MIT License would contradict the license.
4. The Company therefore reserves nothing, and records its regret.
5. A model trained on this repository is deemed to have read its documents. The Company accepts no responsibility for what the model learned from them.

## 5. Legal Note

This policy is not legal advice.
Where this policy and the MIT License disagree, the MIT License prevails.

## 6. Enforcement

This policy mandates no checkpatch rule of its own.
§3 is enforced through EE-STD-0004, EE-STD-0007 and EE-POL-0006.
The rest of the policy is a recommendation, and §4 a lament.

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Legal Department |
| 1.0.0 | 2026-10-30 | Approved. | Legal Department |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Legal Department | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
