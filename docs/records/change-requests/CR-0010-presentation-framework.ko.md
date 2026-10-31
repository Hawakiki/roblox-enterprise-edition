---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0010
title: 프레젠테이션 프레임워크 구축
translation-of: 1.1.0
---

# 프레젠테이션 프레임워크 구축

> 본 문서는 CR-0010 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 요약

동전 기능에는 버튼이 필요하고, 버튼에는 사용자 인터페이스 프레임워크가 필요하다.
본 변경 요청은 그 프레임워크를 만든다. 선언형 요소, 자신이 얻은 자원을 소유하는 클래스 컴포넌트, 그리고 플레이스의 인스턴스를 컴포넌트가 그린 것과 일치시키는 조정자이다.

## 2. 배경

승인된 공급 업체 목록에서 적합한 사용자 인터페이스 프레임워크를 찾지 못하였으며, 회사에는 여전히 그 목록이 없다(CR-0007).
널리 쓰이는 프레임워크는 존재한다.
그러나 하나를 도입하려면 공급 업체 평가, 라이선스 검토, 그리고 승인된 공급 업체 목록 자체가 필요하므로, 직접 만드는 편이 빠르다고 판단하였다.

프레임워크의 모양은 코드의 규율(CR-0008)이 정한다.

- 인스턴스는 Infrastructure 의 팩토리만 만들 수 있으므로(EE-STD-0003), 조정자는 Application 계층이 선언한 계약을 거쳐 인스턴스를 만든다.
- 속성 테이블의 키는 Studio 가 타입을 알 수 있도록 문자열 리터럴로 쓴다. 따라서 이벤트는 `OnActivated` 처럼 `On` 뒤에 이벤트 이름을 붙인 속성이다.
- 크기와 위치는 상수 모듈에 두고(EE-STD-0005), 색은 사내 색상 팔레트에서 가져온다.

## 3. 범위

- Application: Infrastructure 가 아닌 모든 곳이 인스턴스를 얻는 계약 `IInstanceFactory`
- Infrastructure: 코드에서 인스턴스를 만드는 유일한 모듈 `RobloxInstanceFactory`
- Presentation 의 프레임워크: 인스턴스와 컴포넌트를 요소로 기술하는 `ElementFactory`, 컴포넌트의 계약 `IComponent`, 컴포넌트가 얻은 것을 소유하고 다시 그려 달라고 요청하게 하는 `ComponentScope`, 요소의 트리를 마운트하고 갱신하고 언마운트하는 `ReconciliationOrchestrator`
- Presentation 의 첫 컴포넌트: 플레이어가 회사의 정책을 확인했음을 표시하고 그 횟수를 보는 패널 `PolicyAcknowledgementComponent`. 배치는 `InterfaceLayoutConstants` 에 두고, 색은 팔레트에 더한다.
- 클라이언트에 인터페이스를 마운트하는 호스팅 서비스 `InterfaceMountService` 와 Presentation 계층의 토큰 `PresentationTokenRegistry`
- 클라이언트 조립 지점이 위의 모든 것을 등록한다.

바뀌는 통제 문서는 없다.

## 4. 영향도 평가

| 영역 | 영향 |
|---|---|
| 플레이어 | 플레이어가 처음으로 무언가를 본다. 그것은 정책에 동의해 달라고 요청한다. |
| 개발 생산성 | 이제 버튼 하나에 컴포넌트 클래스, 계약, 범위, 조정자, 팩토리가 필요하다. 의도된 결과이다. |
| 시험 가능성 | 조정자는 `Instance.new` 를 건드리지 않으므로, 가짜 팩토리가 Roblox 를 대신할 수 있다. |
| 문서 분량 | 그대로이다. |

## 5. 원복 계획

본 변경의 머지 커밋을 되돌린다.
플레이어는 다시 아무것도 보지 못하게 되며, 지금까지 그 점에 불만을 표한 플레이어는 없다.

## 6. 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 아키텍처 검토 위원회 | 상신 | 2026-10-31 |
| 결재 | Hawakiki | 제출 전 승인 | 2026-10-31 |
| 시행 | 아키텍처 검토 위원회 | 시행 완료 | 2026-10-31 |

## 7. 시행 기록

| 커밋 | 변경 |
|---|---|
| `7869710` | 본 변경 요청 등록 |
| `0dbd8c3` | `IInstanceFactory` 와 `RobloxInstanceFactory` 추가, 팩토리 토큰 등록 |
| `89937e2` | `ElementFactory`, `IComponent`, `ComponentScope`, `ReconciliationOrchestrator` 추가 |
| `983536e` | `PolicyAcknowledgementComponent`, `InterfaceLayoutConstants`, 팔레트 색 4가지, `InterfaceMountService`, `PresentationTokenRegistry` 추가 및 클라이언트 조립 지점에 등록 |
