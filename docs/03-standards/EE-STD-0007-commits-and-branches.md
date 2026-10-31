---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0007
title: Commit and Branch Standard
version: 1.0.1
status: Approved
classification: Internal
owner: Compliance Engineering
parent: EE-POL-0004@1.1
---

# Commit and Branch Standard

## 1. Purpose

This standard fixes the form of every commit message and every branch name, so that the history of the repository reads as a register of approved changes.

## 2. Scope

1. This standard applies to every commit and every branch.
2. Commit `8f2b559` predates it and is exempt (EE-CHR-0001, Article 7).

## 3. Message Layout

A commit message consists of a subject, a blank line, a body and a block of trailers, in that order (`COMMIT_MISSING_BLANK_LINE`).

```text
feat(output): deliver the value through the approved channel

[EN]
Deliver the value through the output delivery service instead of
printing it directly.

[KO]
값을 직접 출력하지 않고 출력 전달 서비스를 통해 전달한다.

Signed-off-by: Jane Doe <jane@enterprise-edition.example>
Change-Request: CR-0001
```

## 4. Subject

1. The subject has the form `<type>(<scope>): <description>` (`COMMIT_SUBJECT_FORMAT`).
   An exclamation mark after the scope marks a breaking change.
2. The type is one of the following.

| Type | Use |
|---|---|
| `feat` | A new capability. |
| `fix` | The correction of a defect. |
| `refactor` | A change of structure that changes no behaviour. |
| `perf` | A change that makes something faster. |
| `test` | Tests only. |
| `docs` | Documents only. |
| `chore` | Maintenance that fits nowhere else. |
| `build` | The toolchain and the build. |
| `ci` | Continuous integration. |
| `revert` | The reversal of an earlier commit. |

3. The scope names the area that changes, in lowercase letters, digits and hyphens.
4. The description is written in English (`COMMIT_SUBJECT_NOT_ENGLISH`) and in the imperative.
   It does not start in sentence case and does not end with a period (`COMMIT_SUBJECT_STYLE`); identifiers and acronyms may open it.
5. The subject fits in 72 columns (`COMMIT_SUBJECT_TOO_LONG`).
6. The subject of a merge commit is `Merge branch '<source>' into <target>`.

## 5. Body

1. The body opens with an `[EN]` section followed by a `[KO]` section, neither of them empty (`COMMIT_MISSING_BODY_SECTION`).
2. The `[KO]` section is written in Korean (`COMMIT_SECTION_LANGUAGE`).
3. The body explains why the change is made, not only what it does.
4. Lines fit in 72 columns, East Asian wide characters counting as two; lines that contain a URL are exempt (`COMMIT_BODY_LINE_TOO_LONG`).

## 6. Trailers

1. The message ends with a block of trailers, one `Key: value` per line. Keys are matched without regard to case.
2. Only the following trailers are allowed (`COMMIT_UNKNOWN_TRAILER`), and each value takes the form shown (`COMMIT_MALFORMED_TRAILER`).

| Trailer | Value | Required on |
|---|---|---|
| `Signed-off-by` | `Name <email>` | Every commit |
| `Change-Request` | `CR-NNNN` | Every commit |
| `Approved-by` | `Name <email>` | Every merge commit |
| `Reviewed-by` | `Name <email>` | — |
| `Acked-by` | `Name <email>` | — |
| `Co-Authored-By` | `Name <email>` | — |
| `Jira` | An issue key, such as `EE-1234` | — |

3. `Signed-off-by` certifies, in the manner of the Developer Certificate of Origin, that the signer has the right to submit the change under the license of the repository.
   Every commit carries one (`COMMIT_MISSING_SIGNOFF`), and the author of the commit is among the signers (`COMMIT_SIGNOFF_MISMATCH`).
4. `Change-Request` cites the change request that the commit implements (`COMMIT_MISSING_CHANGE_REQUEST`).
   The request is filed (`COMMIT_UNKNOWN_CHANGE_REQUEST`), is neither `Rejected` nor `Closed` (`COMMIT_CHANGE_REQUEST_CLOSED`), and should be `Approved` or `Implemented` (`COMMIT_CHANGE_REQUEST_NOT_APPROVED`).
5. A merge commit carries `Approved-by`, naming the Approver of record (`COMMIT_MISSING_APPROVAL`).
6. `Jira` refers to an issue tracker that the Company does not have. It is accepted for authenticity.

## 7. Branches

1. Branch names follow the branching model of EE-POL-0004 (`BRANCH_NAME_FORMAT`).

| Branch | Form |
|---|---|
| Main | `main` |
| Development | `develop` |
| Feature | `feature/CR-<NNNN>-<slug>` |
| Release | `release/<version>` |
| Hotfix | `hotfix/SEV<1-4>-<slug>` |

2. Every commit on `feature/CR-<NNNN>-<slug>` cites `CR-<NNNN>` (`BRANCH_CHANGE_REQUEST_MISMATCH`).
3. `main` and `develop` accept merge commits only (`DIRECT_COMMIT_TO_PROTECTED_BRANCH`).

## 8. Enforcement

1. `.githooks/commit-msg` applies this standard to every commit as it is made.
   Each clone enables it once with `git config core.hooksPath .githooks`.
2. `lune run scripts/checkpatch --commits <range>` applies it to a range of existing commits.
3. Annex A lists the rules mandated by this standard.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `COMMIT_MISSING_BLANK_LINE` | Error | §3 |
| `COMMIT_SUBJECT_FORMAT` | Error | §4 |
| `COMMIT_SUBJECT_NOT_ENGLISH` | Error | §4 |
| `COMMIT_SUBJECT_STYLE` | Error | §4 |
| `COMMIT_SUBJECT_TOO_LONG` | Error | §4 |
| `COMMIT_MISSING_BODY_SECTION` | Error | §5 |
| `COMMIT_SECTION_LANGUAGE` | Error | §5 |
| `COMMIT_BODY_LINE_TOO_LONG` | Warning | §5 |
| `COMMIT_UNKNOWN_TRAILER` | Error | §6 |
| `COMMIT_MALFORMED_TRAILER` | Error | §6 |
| `COMMIT_MISSING_SIGNOFF` | Error | §6 |
| `COMMIT_SIGNOFF_MISMATCH` | Error | §6 |
| `COMMIT_MISSING_CHANGE_REQUEST` | Error | §6 |
| `COMMIT_UNKNOWN_CHANGE_REQUEST` | Error | §6 |
| `COMMIT_CHANGE_REQUEST_CLOSED` | Error | §6 |
| `COMMIT_CHANGE_REQUEST_NOT_APPROVED` | Warning | §6 |
| `COMMIT_MISSING_APPROVAL` | Error | §6 |
| `BRANCH_NAME_FORMAT` | Error | §7 |
| `BRANCH_CHANGE_REQUEST_MISMATCH` | Error | §7 |
| `DIRECT_COMMIT_TO_PROTECTED_BRANCH` | Error | §7 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Compliance Engineering |
| 1.0.0 | 2026-10-30 | Approved. | Compliance Engineering |
| 1.0.1 | 2026-10-30 | Reviewed against EE-POL-0004 1.1; citation updated. | Compliance Engineering |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Compliance Engineering | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
