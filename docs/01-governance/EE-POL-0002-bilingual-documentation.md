---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0002
title: Bilingual Documentation Policy
version: 1.1.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@1.1
---

# Bilingual Documentation Policy

## 1. Purpose

This policy ensures that every document of the Company can be read in English and in Korean, and that the two versions never disagree for long.

## 2. Scope

This policy applies to every document within the scope of EE-POL-0001.

## 3. Authoritative Version

1. The English version of a document is authoritative. The Korean version is a translation.
2. Where the two versions conflict, the English version prevails.
3. Where the Korean version is clearer, the English version is amended to match it, through a change request.
4. A translation opens with a notice that the English version prevails.

## 4. Translation Requirements

1. Every document has a translation in the same folder, named after the English version with `.ko.md` in place of `.md` (`MISSING_TRANSLATION`).
2. Every translation has an English version (`ORPHAN_TRANSLATION`).
3. A translation carries the identifier of its English version (`TRANSLATION_ID_MISMATCH`).
4. The frontmatter of a translation carries only the following fields.
   Every other piece of metadata lives in the English version (`TRANSLATION_EXTRA_FIELD`).

| Field | Value |
|---|---|
| `id` | The identifier of the English version. |
| `title` | The title, translated. |
| `translation-of` | The full version of the English version that the translation was made from. |

5. `translation-of` matches the version of the English version exactly, PATCH included (`STALE_TRANSLATION`).
   Every change to the English version, however small, requires the translation to be reviewed.
6. A translation contains Korean prose. A Korean title alone does not make a translation (`TRANSLATION_NOT_KOREAN`).

## 5. Workflow

1. The English version and its translation change in the same commit.
2. The translator reviews the translation against the new English version, revises it where needed, and only then sets `translation-of`.
3. Setting `translation-of` without reviewing the translation is a false statement.

## 6. Terminology

Translations use the following terms.
The registry uses the same terms for statuses and classifications.
Names of organizational units are proper nouns, and may be transliterated, as in 릴리스 엔지니어링.
Code identifiers, such as branch names, rule codes, field values and file names, are never translated in prose; they are written as they are, in backticks.
The Korean labels of statuses and classifications below are what the registry displays.

| English | Korean |
|---|---|
| Charter | 헌장 |
| Policy | 정책 |
| Organization | 조직 |
| Standard | 표준 |
| Standard operating procedure | 표준 운영 절차 |
| Operations | 운영 |
| Guideline | 가이드라인 |
| Template | 양식 |
| Controlled document | 통제 문서 |
| Record | 기록 |
| Request for comments | 의견 요청서 |
| Architecture decision record | 아키텍처 결정 기록 |
| Change request | 변경 요청 |
| Approval request | 품의서 |
| Statement of circumstances | 경위서 |
| Meeting minutes | 회의록 |
| Registry | 문서 대장 |
| Approval | 결재 |
| Approver | 결재권자 |
| Drafter | 기안자 |

| Status | Korean |
|---|---|
| `Draft` | 초안 |
| `In Review` | 검토 중 |
| `Submitted` | 상신 |
| `Discussion` | 논의 중 |
| `Proposed` | 제안 |
| `Approved` | 승인 |
| `Accepted` | 채택 |
| `Rejected` | 반려 |
| `Returned` | 재작성 요청 |
| `Withdrawn` | 철회 |
| `Implemented` | 시행 |
| `Closed` | 종결 |
| `Superseded` | 대체됨 |
| `Deprecated` | 폐지 |

| Classification | Korean |
|---|---|
| `Public` | 공개 |
| `Internal` | 사내 한정 |
| `Confidential` | 대외비 |
| `Restricted` | 극비 |

## 7. Enforcement

checkpatch enforces this policy. Annex A lists the rules mandated by this policy.

## Annex A. Rules Enforced Under This Policy

| Rule | Severity | Section |
|---|---|---|
| `MISSING_TRANSLATION` | Error | §4 |
| `ORPHAN_TRANSLATION` | Error | §4 |
| `TRANSLATION_ID_MISMATCH` | Error | §4 |
| `TRANSLATION_EXTRA_FIELD` | Error | §4 |
| `STALE_TRANSLATION` | Error | §4 |
| `TRANSLATION_NOT_KOREAN` | Warning | §4 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |
| 1.0.0 | 2026-10-30 | Approved. | Document Control Office |
| 1.1.0 | 2026-10-30 | Unit names may be transliterated; code identifiers are not translated. Cites EE-POL-0001 1.1. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |
