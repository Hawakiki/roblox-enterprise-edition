---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0001
title: 문서 체계 정책
translation-of: 0.9.0
---

# 문서 체계 정책

> 본 문서는 EE-POL-0001 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 정책은 회사 문서의 식별, 작성, 버전 관리, 문서 간 관계, 대장 등재 방식을 정한다.
본 정책은 checkpatch 가 강제하는 문서 스키마를 사람이 읽을 수 있도록 쓴 것이다.
본 정책과 `scripts/lib/Schema.luau` 가 서로 다르면 둘 다 틀린 것이며, 이를 일치시키려면 변경 요청이 필요하다.

## 2. 적용 범위

1. 본 정책은 `docs/` 아래의 모든 파일에 적용한다.
2. `README.md`, `LICENSE` 등 `docs/` 밖의 파일과 자동 생성되는 문서 대장(§13)에는 적용하지 아니한다.

## 3. 정의

| 용어 | 정의 |
|---|---|
| 문서 | frontmatter 블록으로 시작하는 `docs/` 아래의 Markdown 파일 |
| 통제 문서 | 위계를 이루며 규칙을 정하는 문서. 헌장, 정책, 표준, 절차, 가이드라인, 양식을 말한다. |
| 기록 | 요청, 결정, 사건을 기록하는 문서. 기록은 위계 밖에 있다. |
| 종류 | `POL`, `CR` 같은 코드로 식별되는 문서의 분류 |
| 정본 | 문서의 영문판 |
| 번역본 | 문서의 국문판 |
| 개정판 | 버전 중 `MAJOR.MINOR` 부분 |
| 문서 대장 | 모든 문서의 목록. `docs/REGISTRY.md` 와 `docs/REGISTRY.ko.md` 로 자동 생성된다. |

## 4. 문서 종류와 위계

1. 통제 문서는 위계를 이룬다. 1단계가 최상위이다.

| 단계 | 종류 | 코드 | 식별자 | 폴더 |
|---|---|---|---|---|
| 1 | 헌장 | `CHR` | `EE-CHR-NNNN` | `docs/00-charter/` |
| 2 | 정책 | `POL` | `EE-POL-NNNN` | `docs/01-governance/` |
| 2 | 조직 | `ORG` | `EE-ORG-NNNN` | `docs/02-organization/` |
| 3 | 표준 | `STD` | `EE-STD-NNNN` | `docs/03-standards/` |
| 4 | 표준 운영 절차 | `SOP` | `EE-SOP-NNNN` | `docs/04-procedures/` |
| 4 | 운영 | `OPS` | `EE-OPS-NNNN` | `docs/06-operations/` |
| 5 | 가이드라인 | `GDL` | `EE-GDL-NNNN` | `docs/05-guidelines/` |
| 6 | 양식 | `TPL` | `EE-TPL-NNNN` | `docs/templates/` |

2. 기록은 위계 밖에 있다. 기록의 종류마다 고유한 생애 주기를 갖는다(§10).

| 종류 | 코드 | 식별자 | 폴더 |
|---|---|---|---|
| 의견 요청서 | `RFC` | `RFC-NNNN` | `docs/rfc/` |
| 아키텍처 결정 기록 | `ADR` | `ADR-NNNN` | `docs/adr/` |
| 변경 요청 | `CR` | `CR-NNNN` | `docs/records/change-requests/` |
| 품의서 | `APR` | `APR-NNNN` | `docs/records/approval-requests/` |
| 경위서 | `STM` | `STM-NNNN` | `docs/records/statements/` |
| 회의록 | `MIN` | `MIN-NNNN` | `docs/records/minutes/` |

3. 식별자가 위 표의 어느 종류에도 속하지 않는 문서는 거부한다(`UNKNOWN_DOCUMENT_TYPE`).
4. 문서는 해당 종류의 폴더에 둔다(`MISPLACED_DOCUMENT`).
   `docs/` 아래에는 Markdown 문서만 둔다(`STRAY_FILE`).
5. 새 종류는 같은 변경 요청 안에서 본 정책과 스키마를 함께 개정하여 도입한다.

## 5. 식별자

1. 식별자는 종류의 접두어 뒤에 네 자리 번호를 붙인 것이다. 통제 문서는 `EE-<CODE>-NNNN`, 기록은 `<CODE>-NNNN` 이다.
2. 번호는 종류별로 순서대로 부여한다. 다음 번호는 대장에 등재된 가장 큰 번호에 1을 더한 것이다.
3. 식별자는 유일하며(`DUPLICATE_DOCUMENT_ID`), 문서가 대체되거나 폐지된 뒤에도 재사용하지 아니한다.
4. `EE-XYZ-0001` 처럼 §4 에 등록되지 않은 종류를 가리키는 문자열은 식별자가 아니다. 예시를 쓸 때 이를 이용할 수 있다.

## 6. 파일 이름

1. 정본의 파일 이름은 `<식별자>-<slug>.md`, 번역본은 같은 폴더의 `<식별자>-<slug>.ko.md` 로 한다.
2. slug 는 영문 소문자, 숫자, 한 개짜리 하이픈으로 이루어지며, 영문자나 숫자로 시작한다(`FILENAME_MISMATCH`).
3. slug 는 제목을 몇 단어로 요약한 것이다. 한 번 등재된 slug 는 제목이 바뀌어도 바꾸지 아니한다.

## 7. Frontmatter

1. 모든 문서는 YAML frontmatter 블록으로 시작하며, 블록은 `---` 만 있는 줄로 시작하고 끝난다(`MISSING_FRONTMATTER`, `INVALID_FRONTMATTER`).
2. 정본의 frontmatter 에는 다음 필드만 둔다(`MISSING_FIELD`, `UNKNOWN_FIELD`).

| 필드 | 필수 여부 | 값 |
|---|---|---|
| `id` | 항상 | 식별자(§5) |
| `title` | 항상 | 제목. 영문은 각 단어의 첫 글자를 대문자로 쓴다. |
| `version` | 항상 | `MAJOR.MINOR.PATCH`(§9) |
| `status` | 항상 | 해당 종류의 상태 중 하나(§10) |
| `classification` | 항상 | `Public`, `Internal`, `Confidential`, `Restricted` 중 하나(§12) |
| `owner` | 항상 | 문서를 책임지는 조직 단위 |
| `parent` | 헌장을 제외한 통제 문서 | `<식별자>@<MAJOR.MINOR>`(§11) |

3. 모든 값은 비어 있지 않은 문자열이다.
   `1.0` 처럼 YAML 이 숫자로 읽는 값은 거부한다(`INVALID_FIELD_VALUE`).
4. 번역본의 frontmatter 에는 EE-POL-0002 에서 정한 대로 `id`, `title`, `translation-of` 만 둔다.
5. 라이선스 정보는 블록 맨 위에 YAML 주석으로 쓴다. 주석은 필드가 아니다.

예를 들어 표준 문서는 다음과 같이 시작한다.

```yaml
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-NNNN
title: Example Standard
version: 1.2.0
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-POL-NNNN@1.0
---
```

## 8. 제목과 본문

1. 본문은 제목을 그대로 되풀이한 1단계 제목으로 시작한다(`TITLE_HEADING_MISMATCH`).
2. 통제 문서는 EE-TPL-0001 에 정한 대로 개정 이력과 결재 절로 끝난다.
3. 문서는 한 줄에 한 문장씩 쓴다. 그래야 문장 하나의 변경이 줄 하나의 변경이 된다.

## 9. 버전

1. 버전은 `MAJOR.MINOR.PATCH` 형식이다.
2. 의미가 바뀌지 않는 자구 수정(맞춤법, 서식, 표현)은 PATCH 를 올린다.
3. 기존 의무를 모두 유지하면서 의미가 바뀌는 변경(조항 신설, 해석을 바꾸는 명확화)은 MINOR 를 올린다.
4. 기존 의무를 없애거나 바꾸는 변경은 MAJOR 를 올린다.
5. 문서를 변경할 때마다 버전을 올린다.
6. `Draft` 또는 `In Review` 상태의 통제 문서는 `0.x.y` 버전을 쓴다.
   그 밖의 상태인 통제 문서는 `1.0.0` 이상을 쓴다(`VERSION_STATUS_MISMATCH`).

## 10. 상태와 생애 주기

1. 통제 문서는 다음 상태를 거친다.

| 상태 | 의미 |
|---|---|
| `Draft` | 작성 중 |
| `In Review` | 결재 상신됨 |
| `Approved` | 시행 중 |
| `Superseded` | 이를 명시한 새 문서로 대체됨 |
| `Deprecated` | 대체 없이 폐지됨 |

2. 기록은 해당 종류의 상태를 거친다.

| 종류 | 상태 |
|---|---|
| `RFC` | `Draft`, `Discussion`, `Accepted`, `Rejected`, `Withdrawn` |
| `ADR` | `Proposed`, `Accepted`, `Superseded`, `Deprecated` |
| `CR` | `Draft`, `Submitted`, `Approved`, `Rejected`, `Implemented`, `Closed` |
| `APR` | `Draft`, `Submitted`, `Approved`, `Rejected`, `Withdrawn` |
| `STM` | `Draft`, `Submitted`, `Accepted`, `Returned` |
| `MIN` | `Draft`, `Approved` |

3. 위 목록에 없는 상태는 거부한다(`INVALID_FIELD_VALUE`).
4. 문서는 기록상 결재권자가 승인한다(EE-CHR-0001 제5조).
   승인은 세 곳에 기록한다. 문서의 결재 절, 문서의 상태, 그리고 문서를 `develop` 에 반영하는 머지 커밋의 `Approved-by` trailer 이다.

## 11. 위계와 인용

1. 헌장을 제외한 모든 통제 문서는 `parent` 필드에 상위 문서 하나를 인용한다(`MISSING_PARENT`).
   헌장과 기록은 상위 문서를 인용하지 아니한다(`UNEXPECTED_PARENT`).
2. 상위 문서는 존재해야 하며(`UNKNOWN_PARENT`), 같은 단계 또는 더 높은 단계의 통제 문서여야 한다(`PARENT_HIERARCHY_VIOLATION`).
3. 인용에는 하위 문서가 근거로 삼은 상위 문서의 개정판을 적는다. 예: `parent: EE-POL-NNNN@1.0`
4. 상위 문서의 개정판이 바뀌면 인용이 더 이상 일치하지 않으므로, 모든 하위 문서가 재검토 대상으로 보고된다(`STALE_PARENT`).
   하위 문서는 새 개정판을 기준으로 재검토하고 인용을 갱신한다. 이 갱신도 하위 문서의 변경이다(§9).
   상위 문서의 PATCH 변경은 개정판을 바꾸지 않으므로 하위 문서에 영향을 주지 아니한다.
5. 상위 문서를 따라 올라간 사슬이 출발점으로 되돌아와서는 아니 된다(`PARENT_CYCLE`).

## 12. 보안 등급

| 보안 등급 | 의미 |
|---|---|
| `Public` | 회사 밖에 공유할 수 있다. |
| `Internal` | 회사 구성원용이다. |
| `Confidential` | 지정된 구성원만 볼 수 있다. |
| `Restricted` | 이사회만 볼 수 있다. |

본 저장소는 공개되어 있다.
보안 등급은 누가 문서를 읽을 수 있는지를 제한하지 않는다. 회사가 그에 대해 어떻게 느끼는지를 기록할 뿐이다.

## 13. 참조와 문서 대장

1. 문서에 나타나는 등록된 종류의 식별자는 모두 실재하는 문서를 가리켜야 한다(`DANGLING_REFERENCE`).
2. 문서 대장은 모든 문서를 수록한다.
   문서 대장은 `scripts/gen_registry.luau` 가 생성하며, 손으로 고치지 아니한다.
   생성 결과와 다른 문서 대장은 거부한다(`REGISTRY_OUT_OF_DATE`).

## 14. 변경

1. 문서의 모든 변경은 변경 요청을 통해 한다. 변경 요청은 EE-TPL-0002 양식으로 제출하며, 이를 시행하는 모든 커밋이 인용한다.
2. checkpatch 가 강제하는 모든 규칙은 그 근거 문서의 두 언어판 모두에 규칙 코드로 인용되어야 한다(`UNDOCUMENTED_RULE`).
   문서화되지 않은 규칙은 배포할 수 없다.

## 15. 강제 수단

본 정책은 checkpatch 가 강제한다.
`lune run scripts/checkpatch --list-rules` 는 모든 규칙을, 부속서 A 는 본 정책을 근거로 하는 규칙을 열거한다.

## 부속서 A. 본 정책에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `UNKNOWN_DOCUMENT_TYPE` | 오류 | §4 |
| `MISPLACED_DOCUMENT` | 오류 | §4 |
| `STRAY_FILE` | 경고 | §4 |
| `DUPLICATE_DOCUMENT_ID` | 오류 | §5 |
| `FILENAME_MISMATCH` | 오류 | §6 |
| `MISSING_FRONTMATTER` | 오류 | §7 |
| `INVALID_FRONTMATTER` | 오류 | §7 |
| `MISSING_FIELD` | 오류 | §7 |
| `UNKNOWN_FIELD` | 오류 | §7 |
| `INVALID_FIELD_VALUE` | 오류 | §7, §10 |
| `TITLE_HEADING_MISMATCH` | 오류 | §8 |
| `VERSION_STATUS_MISMATCH` | 오류 | §9 |
| `MISSING_PARENT` | 오류 | §11 |
| `UNEXPECTED_PARENT` | 오류 | §11 |
| `UNKNOWN_PARENT` | 오류 | §11 |
| `PARENT_HIERARCHY_VIOLATION` | 오류 | §11 |
| `STALE_PARENT` | 오류 | §11 |
| `PARENT_CYCLE` | 오류 | §11 |
| `DANGLING_REFERENCE` | 오류 | §13 |
| `REGISTRY_OUT_OF_DATE` | 오류 | §13 |
| `UNDOCUMENTED_RULE` | 오류 | §14 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 문서통제실 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 문서통제실 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 대기 | — |
