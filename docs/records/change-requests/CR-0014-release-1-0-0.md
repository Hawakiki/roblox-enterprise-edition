---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0014
title: Release EnterpriseEdition 1.0.0
version: 1.1.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Release EnterpriseEdition 1.0.0

## 1. Summary

This change request releases the first version of the Company: everything approved into `develop` since its founding is merged into `main` and tagged `v1.0.0`.
Before it is released, the README gains its introduction, written by the Approver of record, and a Korean version.

## 2. Background

`main` has held only the first commit since the founding of the Company, while thirteen change requests were approved into `develop`.
A release is a change like any other, and every commit cites the change request it implements (EE-POL-0004 §6), merge commits included; the release therefore has a request of its own.

The Approver of record writes the introduction in Korean, and it is translated into English for `README.md`.

## 3. Scope

- `release/1.0.0`, taken from `develop` (EE-POL-0004 §5).
- `README.ko.md`: the README in Korean, including the introduction of the Approver of record.
- `README.md`: the introduction, in English, and links between the two versions.
- After approval:
  - `release/1.0.0` is merged into `main` with `--no-ff`, and the merge commit is tagged `v1.0.0`.
  - `release/1.0.0` is merged back into `develop`.
- Pushing to the remote repository is left to the Approver of record.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| `main` | Moves from the first commit to the first release, by way of one merge commit. |
| Readers | Can read the README in either language. |
| Documentation volume | One Markdown file at the root. No controlled document. |

## 5. Rollback Plan

Delete the tag `v1.0.0`, and revert the merge commit on `main` and on `develop`.
`main` would hold only the first commit again, as it did for the whole history of the Company.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |
| Implementer | Architecture Review Board | Implemented | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `16aad14` | Filed this change request on `release/1.0.0`. |
| `67d7ded` | Added `README.ko.md` and linked the two versions of the README. |
| `a74a823` | Added the introduction of the Approver of record, and its English translation. |
