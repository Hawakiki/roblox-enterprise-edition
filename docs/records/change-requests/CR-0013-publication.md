---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0013
title: Prepare the Company for Publication
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Prepare the Company for Publication

## 1. Summary

The repository is to be published as it stands: a reference company, whose feature is its reference implementation and whose records are its history.
This change request adds what a public repository needs and the Company has lacked: a README with the development workflow, a guide for contributors, and continuous integration that runs every check on every push and pull request.

## 2. Background

The Approver of record decided against stripping the repository into a blank template.
The compliance incentive programme is to the Company what FizzBuzz is to the work it satirises: the trivial feature that the structure exists to serve.
The records cannot be removed in any case: the documents, the code and `AGENTS.md` cite them, and checkpatch would report every citation (`DANGLING_REFERENCE`).
The Company cannot forget its past.

None of the files this request adds is a controlled document, and the governance stays frozen.

## 3. Scope

- `README.md`: the development workflow. Its introduction is left to the Approver of record.
- `CONTRIBUTING.md`: how a person contributes, by way of the documents that govern it.
- `.github/workflows/check.yml`: on every push to `main` or `develop` and on every pull request, it installs the toolchain that `rokit.toml` pins, runs `tools/check.sh`, and checks every commit message since the first.
  - The third-party actions it uses are pinned by commit, not by tag.
  - It installs the tools without asking whether they are trusted. The workflow, approved like every other change, trusts them on behalf of the person who would trust them on a machine of their own.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Contributors | A README tells them how to begin, and CONTRIBUTING how to be employed. |
| Verification | Every push and every pull request is checked by a machine that no one at the Company runs by hand. |
| Documentation volume | Two Markdown files at the root, which checkpatch already governs as entrance files. No controlled document. |

## 5. Rollback Plan

Revert the merge commit of this change.
The repository would be published without instructions, as most repositories are.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
