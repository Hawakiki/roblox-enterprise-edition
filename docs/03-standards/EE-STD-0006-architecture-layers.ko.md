---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0006
title: 아키텍처 계층 표준
translation-of: 2.0.0
---

# 아키텍처 계층 표준

> 본 문서는 EE-STD-0006 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 표준은 로블록스 코드의 계층, 계층 사이의 의존 방향, 그리고 계층을 조립해 실행 가능한 애플리케이션으로 만드는 방법을 정한다.

## 2. 적용 범위

본 표준은 `src/` 아래의 모든 모듈에 적용한다.

## 3. 실행 위치

| 폴더 | 인스턴스 | 실행 위치 |
|---|---|---|
| `src/Shared` | `ReplicatedStorage.EnterpriseEdition` | 서버와 클라이언트 |
| `src/Server` | `ServerScriptService.EnterpriseEdition` | 서버 |
| `src/Client` | `StarterPlayer.StarterPlayerScripts.EnterpriseEdition` | 클라이언트 |

## 4. 계층

1. 모든 모듈은 자신이 놓인 폴더 `src/<실행 위치>/<계층>/` 에 따라 정확히 한 계층에 속한다(`LAYER_VIOLATION`).

| 계층 | 담는 것 | require 할 수 있는 계층 |
|---|---|---|
| Kernel | 프레임워크. 컨테이너, 호스트, 자원 범위, 모든 계층이 공유하는 계약 | Kernel |
| Domain | 로블록스를 모르는 순수 Luau 로 쓴 업무 규칙 | Domain, Kernel |
| Application | 유스케이스와 서비스, 그리고 그것들이 외부에 요구하는 계약 | Application, Domain, Kernel |
| Infrastructure | 그 계약을 로블록스 위에 구현한 것. 데이터 저장소, 플레이어, 출력 창 | Infrastructure, Application, Domain, Kernel |
| Presentation | 클라이언트의 사용자 인터페이스 | Presentation, Application, Domain, Kernel |

2. 의존은 안쪽, 즉 커널을 향한다(`LAYER_VIOLATION`).
   Application 은 Infrastructure 를 require 하지 아니한다. Application 은 계약을 선언하고, Infrastructure 가 이를 구현한다.
3. 조립 지점인 `init.server.luau` 와 `init.client.luau` 는 어느 계층에도 속하지 아니한다.
   모든 계층을 require 할 수 있는 모듈은 이 둘뿐이다.

## 5. Require

1. require 는 `require(script.Parent.Parent.Kernel.ILogger)` 처럼 들어가는 계층의 이름을 경로에 드러낸다.
   계층 이름이 없는 require 는 자기 계층 안에 머무는 것으로 본다.
2. 경로를 변수에 담아 두었다가 require 하지 아니한다. 변수는 checkpatch 로부터 계층을 가리기 때문이다.
   본 조항은 강제되지 않으므로 권고이다(EE-CHR-0001 제4조).

## 6. 계약과 구현

1. 계약은 `I<이름>` 모듈 안의 테이블 타입이며, 그 메서드는 `self: any` 를 받는다.
2. 생성자는 자기 클래스가 아니라 자신이 구현하는 계약을 반환한다. `RobloxOutputLoggerAdapter.new` 는 `ILogger` 를 반환한다.
   생성자는 인스턴스를 `return setmetatable(state, Class)` 처럼 그대로 반환하며, 타입 검사기는 인스턴스에 계약의 모든 메서드가 있는지 대조한다. `state` 는 인스턴스의 필드를 담은 지역 변수이다.
   로블록스 코드는 `any` 캐스트를 하지 않는다(`CAST_THROUGH_ANY`). `any` 로 들어온 값은 있어야 할 타입의 지역 변수나 필드에 대입한다.
3. 모든 구현은 자신이 구현하는 계약을, 타입이 그 계약인 `_implements` 라는 테이블로 선언한다.
4. `_implements` 의 각 항목은 계약의 시그니처로 쓴 함수이며, 클래스의 메서드를 부르고 그 반환값을 그대로 반환한다. 예를 들면 `Information = function(self: any, message: string) RobloxOutputLoggerAdapter.Information(self, message) end` 이다(`IMPLEMENTS_NOT_WRAPPED`).
   그러면 타입 검사기가 그 호출 지점에서 메서드를 계약에 대조한다. `Information = RobloxOutputLoggerAdapter.Information` 처럼 메서드를 가리키기만 하는 항목은, 메서드가 있는지만 대조되고 그 이상은 대조되지 않는다.

## 7. 조립

1. 조립 지점은 `ServiceCollection` 에 서비스를 등록하고, 이로부터 `ServiceProvider` 를 만들고, `ApplicationHost` 를 실행한다.
2. 서비스는 이름이 아니라 `ServiceTokenRegistry` 에 보관된 토큰으로 꺼낸다.
3. 싱글턴은 제공자마다 한 번, 트랜지언트는 꺼낼 때마다 만든다. 순환 의존성은 거부한다.
4. 호스팅 서비스는 호스트에 주어진 순서대로 시작하고 역순으로 멈춘다. 그다음 제공자가 싱글턴을 생성의 역순으로 해제한다.

## 8. 자원

1. 기능이 만드는 모든 연결, 인스턴스, 스레드, 해제 가능한 객체는 정확히 하나의 `ResourceScope` 가 소유한다.
2. 범위는 소멸자처럼 자원을 획득의 역순으로 해제하며, 자원 하나를 해제하지 못해도 나머지 해제를 멈추지 아니한다.

## 부속서 A. 본 표준에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `LAYER_VIOLATION` | 오류 | §4 |
| `CAST_THROUGH_ANY` | 오류 | §6 |
| `IMPLEMENTS_NOT_WRAPPED` | 오류 | §6 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | 번호 확보 | 아키텍처 검토 위원회 |
| 0.9.0 | 2026-10-30 | 애플리케이션 프레임워크와 함께 작성(CR-0007) | 아키텍처 검토 위원회 |
| 1.0.0 | 2026-10-30 | 승인 | 아키텍처 검토 위원회 |
| 1.0.1 | 2026-10-30 | EE-STD-0001 1.1 기준 재검토, 인용 갱신 | 아키텍처 검토 위원회 |
| 1.1.0 | 2026-10-31 | §6: `_implements` 의 각 항목이 메서드를 감싸고, `any` 캐스트는 생성자가 인스턴스를 반환하는 자리에만 둠(CR-0023) | 아키텍처 검토 위원회 |
| 2.0.0 | 2026-11-01 | §6: 생성자는 캐스트 없이 인스턴스를 반환하고, 로블록스 코드는 `any` 캐스트를 하지 않음. EE-STD-0001 2.0 기준 재검토(CR-0025) | 아키텍처 검토 위원회 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 아키텍처 검토 위원회 | 상신 | 2026-11-01 |
| 결재 | Hawakiki | 승인 | 2026-11-01 |
