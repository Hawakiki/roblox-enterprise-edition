---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0007
title: 회의록 양식
translation-of: 0.9.0
---

# 회의록 양식

> 본 문서는 EE-TPL-0007 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 사용법

1. 모든 회의에는 회의록을 남기며, 회의 시작 시 지명한 서기가 작성한다.
2. 영문판 양식을 `docs/records/minutes/MIN-<NNNN>-<slug>.md` 로, 아래 국문 양식을 같은 경로의 `.ko.md` 로 복사한다.
3. 회의록은 다음 회의에서 승인되기 전까지 `Draft`, 승인된 뒤에는 `Approved` 이다.
   다음 회의의 회의록은 그다음 회의에서 승인한다.
4. 직전 회의록 승인만을 안건으로 하는 회의도 회의이며, 회의록을 남긴다.

## 2. 양식

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: MIN-<NNNN>
title: <국문 제목>
translation-of: 1.0.0
---

# <국문 제목>

> 본 문서는 MIN-<NNNN> 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 회의 개요

| 항목 | 내용 |
|---|---|
| 일자 | <YYYY-MM-DD> |
| 시간 | <HH:MM> ~ <HH:MM> |
| 장소 | <장소> |
| 의장 | <성명> |
| 서기 | <성명> |

## 2. 참석자

- <성명, 소속>

## 3. 불참자

| 성명 | 사유 |
|---|---|
| <성명> | <사유> |

## 4. 안건

1. 직전 회의록 승인(<MIN 식별자, 없으면 없음>)
2. <안건>

## 5. 논의 내용

### 5.1 <안건>

<논의 내용 요약>

## 6. 결정 사항

1. <결정>

## 7. 실행 항목

| 내용 | 담당 | 기한 |
|---|---|---|
| <실행 항목> | <성명> | <YYYY-MM-DD> |

## 8. 차기 회의

<YYYY-MM-DD, 장소. 첫 안건은 본 회의록의 승인이다.>
````

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 문서통제실 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 문서통제실 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 대기 | — |
