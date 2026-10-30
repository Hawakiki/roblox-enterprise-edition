<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->
<!-- GENERATED FILE. DO NOT EDIT. Regenerate with: lune run scripts/gen_registry -->

# 문서 대장

EnterpriseEdition 의 모든 통제 문서와 기록. `scripts/gen_registry.luau` 가 문서 frontmatter 로부터 생성한다.
이 파일을 손으로 고치는 것은 EE-POL-0001 위반이며, checkpatch 가 알아챈다.

[English](REGISTRY.md)

## 요약

| 구분 | 문서 수 |
|---|---:|
| 헌장 | 1 |
| 정책 | 2 |
| 양식 | 7 |
| 변경 요청 | 4 |
| **합계** | **14** |

## 헌장

| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 | 상위 문서 |
|---|---|---|---|---|---|---|
| [EE-CHR-0001](00-charter/EE-CHR-0001-charter.ko.md) | EnterpriseEdition 헌장 | 1.0.0 | 승인 | 공개 | Board of Directors | — |

## 정책

| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 | 상위 문서 |
|---|---|---|---|---|---|---|
| [EE-POL-0001](01-governance/EE-POL-0001-document-governance.ko.md) | 문서 체계 정책 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-CHR-0001@1.0 |
| [EE-POL-0002](01-governance/EE-POL-0002-bilingual-documentation.ko.md) | 이중 언어 정책 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |

## 양식

| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 | 상위 문서 |
|---|---|---|---|---|---|---|
| [EE-TPL-0001](templates/EE-TPL-0001-controlled-document.ko.md) | 통제 문서 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0002](templates/EE-TPL-0002-change-request.ko.md) | 변경 요청서 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0003](templates/EE-TPL-0003-request-for-comments.ko.md) | 의견 요청서 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0004](templates/EE-TPL-0004-architecture-decision-record.ko.md) | 아키텍처 결정 기록 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0005](templates/EE-TPL-0005-approval-request.ko.md) | 품의서 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0006](templates/EE-TPL-0006-statement-of-circumstances.ko.md) | 경위서 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0007](templates/EE-TPL-0007-meeting-minutes.ko.md) | 회의록 양식 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-POL-0001@1.0 |

## 변경 요청

| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 |
|---|---|---|---|---|---|
| [CR-0001](records/change-requests/CR-0001-compliance-tooling.ko.md) | 변경 요청 제도 및 규정 준수 도구 도입 | 1.1.0 | 시행 | 사내 한정 | Compliance Engineering |
| [CR-0002](records/change-requests/CR-0002-stray-luaurc.ko.md) | 루트에 잘못 들어간 .luaurc 제거 | 1.1.0 | 시행 | 사내 한정 | Compliance Engineering |
| [CR-0003](records/change-requests/CR-0003-document-governance.ko.md) | 헌장, 문서 체계 정책 및 양식 제정 | 1.1.0 | 시행 | 사내 한정 | Document Control Office |
| [CR-0004](records/change-requests/CR-0004-engineering-standards.ko.md) | 변경 관리 정책 및 엔지니어링 표준 제정 | 1.0.0 | 승인 | 사내 한정 | Compliance Engineering |
