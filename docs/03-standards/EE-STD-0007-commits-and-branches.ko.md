---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0007
title: 커밋 및 브랜치 표준
translation-of: 1.0.1
---

# 커밋 및 브랜치 표준

> 본 문서는 EE-STD-0007 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 표준은 모든 커밋 메시지와 브랜치 이름의 형식을 정하여, 저장소의 이력이 승인된 변경의 대장으로 읽히도록 한다.

## 2. 적용 범위

1. 본 표준은 모든 커밋과 모든 브랜치에 적용한다.
2. 커밋 `8f2b559` 는 본 표준보다 앞서므로 적용을 면제한다(EE-CHR-0001 제7조).

## 3. 메시지 구성

커밋 메시지는 제목, 빈 줄, 본문, trailer 블록의 순서로 구성한다(`COMMIT_MISSING_BLANK_LINE`).

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

## 4. 제목

1. 제목은 `<type>(<scope>): <description>` 형식이다(`COMMIT_SUBJECT_FORMAT`).
   scope 뒤의 느낌표는 하위 호환을 깨는 변경을 뜻한다.
2. type 은 다음 중 하나이다.

| type | 용도 |
|---|---|
| `feat` | 새 기능 |
| `fix` | 결함 수정 |
| `refactor` | 동작을 바꾸지 않는 구조 변경 |
| `perf` | 무언가를 더 빠르게 하는 변경 |
| `test` | 테스트만 변경 |
| `docs` | 문서만 변경 |
| `chore` | 다른 곳에 속하지 않는 유지 보수 |
| `build` | 툴체인과 빌드 |
| `ci` | 지속적 통합 |
| `revert` | 이전 커밋의 되돌림 |

3. scope 는 바뀌는 영역을 영문 소문자, 숫자, 하이픈으로 적는다.
4. description 은 영어(`COMMIT_SUBJECT_NOT_ENGLISH`) 명령문으로 쓴다.
   첫 단어를 대문자로 시작하는 문장형으로 쓰지 않고, 마침표로 끝내지 아니한다(`COMMIT_SUBJECT_STYLE`). 식별자와 약어로는 시작할 수 있다.
5. 제목은 72칸 이내로 쓴다(`COMMIT_SUBJECT_TOO_LONG`).
6. 머지 커밋의 제목은 `Merge branch '<source>' into <target>` 이다.

## 5. 본문

1. 본문은 `[EN]` 절로 시작하고 `[KO]` 절이 뒤따르며, 어느 절도 비어 있어서는 아니 된다(`COMMIT_MISSING_BODY_SECTION`).
2. `[KO]` 절은 한국어로 쓴다(`COMMIT_SECTION_LANGUAGE`).
3. 본문은 변경이 무엇을 하는지뿐 아니라 왜 하는지를 설명한다.
4. 각 줄은 72칸 이내로 쓰며, 동아시아 전각 문자는 두 칸으로 센다. URL 이 있는 줄은 예외이다(`COMMIT_BODY_LINE_TOO_LONG`).

## 6. Trailer

1. 메시지는 한 줄에 `Key: value` 하나씩 적은 trailer 블록으로 끝난다. 키는 대소문자를 구분하지 아니한다.
2. 다음 trailer 만 허용하며(`COMMIT_UNKNOWN_TRAILER`), 각 값은 표의 형식을 따른다(`COMMIT_MALFORMED_TRAILER`).

| trailer | 값 | 필수 대상 |
|---|---|---|
| `Signed-off-by` | `Name <email>` | 모든 커밋 |
| `Change-Request` | `CR-NNNN` | 모든 커밋 |
| `Approved-by` | `Name <email>` | 모든 머지 커밋 |
| `Reviewed-by` | `Name <email>` | — |
| `Acked-by` | `Name <email>` | — |
| `Co-Authored-By` | `Name <email>` | — |
| `Jira` | `EE-1234` 같은 이슈 키 | — |

3. `Signed-off-by` 는 Developer Certificate of Origin 의 방식에 따라, 서명자가 저장소의 라이선스로 변경을 제출할 권리가 있음을 보증한다.
   모든 커밋에 하나 이상 있어야 하며(`COMMIT_MISSING_SIGNOFF`), 커밋 작성자가 서명자 중에 있어야 한다(`COMMIT_SIGNOFF_MISMATCH`).
4. `Change-Request` 는 커밋이 시행하는 변경 요청을 인용한다(`COMMIT_MISSING_CHANGE_REQUEST`).
   그 변경 요청은 등록되어 있어야 하고(`COMMIT_UNKNOWN_CHANGE_REQUEST`), `Rejected` 나 `Closed` 가 아니어야 하며(`COMMIT_CHANGE_REQUEST_CLOSED`), `Approved` 또는 `Implemented` 이어야 바람직하다(`COMMIT_CHANGE_REQUEST_NOT_APPROVED`).
5. 머지 커밋에는 기록상 결재권자를 명시한 `Approved-by` 를 단다(`COMMIT_MISSING_APPROVAL`).
6. `Jira` 는 회사에 존재하지 않는 이슈 추적 시스템을 가리킨다. 사실감을 위해 허용한다.

## 7. 브랜치

1. 브랜치 이름은 EE-POL-0004 의 브랜치 모델을 따른다(`BRANCH_NAME_FORMAT`).

| 브랜치 | 형식 |
|---|---|
| 메인 | `main` |
| 개발 | `develop` |
| 기능 | `feature/CR-<NNNN>-<slug>` |
| 배포 | `release/<version>` |
| 긴급 수정 | `hotfix/SEV<1-4>-<slug>` |

2. `feature/CR-<NNNN>-<slug>` 의 모든 커밋은 `CR-<NNNN>` 을 인용한다(`BRANCH_CHANGE_REQUEST_MISMATCH`).
3. `main` 과 `develop` 은 머지 커밋만 받는다(`DIRECT_COMMIT_TO_PROTECTED_BRANCH`).

## 8. 강제 수단

1. `.githooks/commit-msg` 가 커밋할 때마다 본 표준을 적용한다.
   클론마다 `git config core.hooksPath .githooks` 로 한 번 연결한다.
2. `lune run scripts/checkpatch --commits <range>` 는 기존 커밋 범위에 본 표준을 적용한다.
3. 부속서 A 는 본 표준을 근거로 하는 규칙을 열거한다.

## 부속서 A. 본 표준에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `COMMIT_MISSING_BLANK_LINE` | 오류 | §3 |
| `COMMIT_SUBJECT_FORMAT` | 오류 | §4 |
| `COMMIT_SUBJECT_NOT_ENGLISH` | 오류 | §4 |
| `COMMIT_SUBJECT_STYLE` | 오류 | §4 |
| `COMMIT_SUBJECT_TOO_LONG` | 오류 | §4 |
| `COMMIT_MISSING_BODY_SECTION` | 오류 | §5 |
| `COMMIT_SECTION_LANGUAGE` | 오류 | §5 |
| `COMMIT_BODY_LINE_TOO_LONG` | 경고 | §5 |
| `COMMIT_UNKNOWN_TRAILER` | 오류 | §6 |
| `COMMIT_MALFORMED_TRAILER` | 오류 | §6 |
| `COMMIT_MISSING_SIGNOFF` | 오류 | §6 |
| `COMMIT_SIGNOFF_MISMATCH` | 오류 | §6 |
| `COMMIT_MISSING_CHANGE_REQUEST` | 오류 | §6 |
| `COMMIT_UNKNOWN_CHANGE_REQUEST` | 오류 | §6 |
| `COMMIT_CHANGE_REQUEST_CLOSED` | 오류 | §6 |
| `COMMIT_CHANGE_REQUEST_NOT_APPROVED` | 경고 | §6 |
| `COMMIT_MISSING_APPROVAL` | 오류 | §6 |
| `BRANCH_NAME_FORMAT` | 오류 | §7 |
| `BRANCH_CHANGE_REQUEST_MISMATCH` | 오류 | §7 |
| `DIRECT_COMMIT_TO_PROTECTED_BRANCH` | 오류 | §7 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 규정 준수 엔지니어링 |
| 1.0.0 | 2026-10-30 | 승인 | 규정 준수 엔지니어링 |
| 1.0.1 | 2026-10-30 | EE-POL-0004 1.1 기준 재검토, 인용 갱신 | 규정 준수 엔지니어링 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 규정 준수 엔지니어링 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 승인 | 2026-10-30 |
