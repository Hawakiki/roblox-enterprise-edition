---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-TPL-0006
title: 경위서 양식
translation-of: 1.0.0
---

# 경위서 양식

> 본 문서는 EE-TPL-0006 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 사용법

1. 경위서는 사고의 당사자가, 그 사고에 대한 비난 없는(blameless) 포스트모템이 끝난 뒤 제출하는 문서이다.
   포스트모템은 누구의 책임도 아님을 밝힌다. 경위서는 누구의 책임인지를 밝힌다.
2. 영문판 양식을 `docs/records/statements/STM-<NNNN>-<slug>.md` 로, 아래 국문 양식을 같은 경로의 `.ko.md` 로 복사한다.
3. 경위서는 `Submitted` 로 시작하며, `Accepted` 되거나 재작성을 위해 `Returned` 된다.
   반려된 경위서는 더 깊이 반성하여 다시 쓰고, MINOR 를 올려 다시 제출한다.

## 2. 양식

````markdown
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: <YEAR> Hawakiki and EnterpriseEdition contributors
id: STM-<NNNN>
title: <국문 제목>
translation-of: 1.0.0
---

# <국문 제목>

> 본 문서는 STM-<NNNN> 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 인적 사항

| 항목 | 내용 |
|---|---|
| 성명 | <성명> |
| 소속 | <소속> |
| 발생 일시 | <YYYY-MM-DD HH:MM> |
| 심각도 | <SEV1, SEV2, SEV3, SEV4 중 하나> |
| 포스트모템 | <참조. 열리지 않았으면 미개최> |

## 2. 사고 개요

<무슨 일이 있었는지 한두 문장으로 쓴다.>

## 3. 경위

| 시각 | 내용 |
|---|---|
| <HH:MM> | <일어난 일> |

## 4. 원인

<왜 일어났는지 쓴다.>

## 5. 반성

<대신 어떻게 했어야 했는지 쓴다.>

## 6. 재발 방지 대책

1. <대책>

## 7. 서약

위 내용은 사실과 다름없으며, 향후 같은 일이 재발하지 않도록 할 것을 서약합니다.

| 일자 | 성명 | 서명 |
|---|---|---|
| <YYYY-MM-DD> | <성명> | (인) |
````

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 문서통제실 |
| 1.0.0 | 2026-10-30 | 승인 | 문서통제실 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 문서통제실 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 승인 | 2026-10-30 |
