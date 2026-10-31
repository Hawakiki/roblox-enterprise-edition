---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0002
title: 이중 언어 정책
translation-of: 1.1.0
---

# 이중 언어 정책

> 본 문서는 EE-POL-0002 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 정책은 회사의 모든 문서를 영어와 한국어로 읽을 수 있게 하고, 두 언어판이 오래 어긋나지 않도록 한다.

## 2. 적용 범위

본 정책은 EE-POL-0001 의 적용 범위에 속하는 모든 문서에 적용한다.

## 3. 정본

1. 문서의 영문판이 정본이며, 국문판은 번역본이다.
2. 두 언어판이 상충하는 경우 영문판이 우선한다.
3. 국문판이 더 명확한 경우에는 변경 요청을 통해 영문판을 국문판에 맞게 개정한다.
4. 번역본은 영문판이 우선한다는 고지로 시작한다.

## 4. 번역 요건

1. 모든 문서는 같은 폴더에, 영문판 이름의 `.md` 를 `.ko.md` 로 바꾼 이름의 번역본을 둔다(`MISSING_TRANSLATION`).
2. 모든 번역본에는 영문판이 있어야 한다(`ORPHAN_TRANSLATION`).
3. 번역본은 영문판의 식별자를 그대로 쓴다(`TRANSLATION_ID_MISMATCH`).
4. 번역본의 frontmatter 에는 다음 필드만 둔다.
   그 밖의 모든 메타데이터는 영문판에 둔다(`TRANSLATION_EXTRA_FIELD`).

| 필드 | 값 |
|---|---|
| `id` | 영문판의 식별자 |
| `title` | 번역한 제목 |
| `translation-of` | 번역의 근거가 된 영문판의 전체 버전 |

5. `translation-of` 는 PATCH 까지 포함하여 영문판의 버전과 정확히 일치해야 한다(`STALE_TRANSLATION`).
   영문판을 아무리 조금 바꾸더라도 번역본을 재검토해야 한다.
6. 번역본에는 한국어 본문이 있어야 한다. 국문 제목만으로는 번역본이 되지 아니한다(`TRANSLATION_NOT_KOREAN`).

## 5. 작업 절차

1. 영문판과 번역본은 같은 커밋에서 함께 바꾼다.
2. 번역자는 바뀐 영문판을 기준으로 번역본을 재검토하고, 필요한 곳을 고친 뒤에야 `translation-of` 를 갱신한다.
3. 번역본을 재검토하지 않고 `translation-of` 를 갱신하는 것은 허위 기재이다.

## 6. 용어

번역본은 다음 용어를 쓴다.
문서 대장도 상태와 보안 등급에 같은 용어를 쓴다.
조직 단위의 이름은 고유명사이므로 릴리스 엔지니어링처럼 음역할 수 있다.
브랜치 이름, 규칙 코드, 필드 값, 파일 이름 같은 코드 식별자는 본문에서 번역하지 않고, 백틱으로 감싸 그대로 쓴다.
아래 표의 상태와 보안 등급의 국문 표기는 문서 대장이 화면에 표시하는 이름이다.

| 영문 | 국문 |
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

| 상태 | 국문 |
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

| 보안 등급 | 국문 |
|---|---|
| `Public` | 공개 |
| `Internal` | 사내 한정 |
| `Confidential` | 대외비 |
| `Restricted` | 극비 |

## 7. 강제 수단

본 정책은 checkpatch 가 강제한다. 부속서 A 는 본 정책을 근거로 하는 규칙을 열거한다.

## 부속서 A. 본 정책에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `MISSING_TRANSLATION` | 오류 | §4 |
| `ORPHAN_TRANSLATION` | 오류 | §4 |
| `TRANSLATION_ID_MISMATCH` | 오류 | §4 |
| `TRANSLATION_EXTRA_FIELD` | 오류 | §4 |
| `STALE_TRANSLATION` | 오류 | §4 |
| `TRANSLATION_NOT_KOREAN` | 경고 | §4 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 문서통제실 |
| 1.0.0 | 2026-10-30 | 승인 | 문서통제실 |
| 1.1.0 | 2026-10-30 | 부서명 음역 허용, 코드 식별자 번역 금지, EE-POL-0001 1.1 인용 | 문서통제실 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 문서통제실 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 승인 | 2026-10-30 |
