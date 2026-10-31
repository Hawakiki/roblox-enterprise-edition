---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0011
title: 정책 확인에 대한 준법 코인 보상
translation-of: 1.0.0
---

# 정책 확인에 대한 준법 코인 보상

> 본 문서는 CR-0011 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 요약

이제 플레이어는 회사의 정책을 확인할 때마다 준법 코인 하나를 받으며, 서버가 이를 기록하고 리더보드가 보여 준다.
코인은 계약 뒤의 저장소에 있다. 본 요청은 코인을 메모리에 두며, DataStore 에 두는 일은 CR-0012 가 맡는다.

## 2. 배경

회사의 첫 사용자 인터페이스(CR-0010)는 플레이어에게 정책에 동의해 달라고 요청하지만, 플레이어에게는 그럴 이유가 없다.
준법 인센티브 제도가 그 이유를 준다.

코인은 회사 역사상 처음으로 네트워크를 건너므로, 클라이언트가 닿을 수 없는 곳에서 지킨다.

- 클라이언트는 요청만 하고, 서버가 결정한다.
- 플레이어는 최소 간격보다 빠르게 확인할 수 없다.
- 잔액은 Luau 의 숫자가 정확히 담을 수 있는 가장 큰 정수인 2^53 - 1 에서 멈춘다. 그 너머에서는 코인을 더해도 아무것도 바뀌지 않는다. 0.25초마다 한 번씩 확인하면 그곳에 이르는 데 약 7천만 년이 걸린다.

세션 락, 재시도, 종료 시 저장을 갖춘 DataStore 저장은 별개의 변경이므로 CR-0012 에 맡긴다.

## 3. 범위

- Domain: 플레이어 한 명의 코인인 `CoinWalletEntity`, `CoinOverflowPolicy`, `AcknowledgementThrottlePolicy`, `CoinConstants`
- Application: 계약 `ICoinWalletRepository`, `ICoinProjection`, `IPlayerSessionSource`, `IAcknowledgementGateway`, `ICoinBalanceSource`. `CoinWalletRegistry`. 플레이어가 들어오면 지갑을 불러오고 나가면 놓아 주는 `CoinSessionService`. `AcknowledgementRewardUseCase`. 네트워크에서 온 모든 요청을 그것에 넘기는 `AcknowledgementRequestHandler`
- Infrastructure: `InMemoryCoinWalletRepository`, `LeaderstatsCoinProjection`, `RobloxPlayerSessionAdapter`, `RemoteEventAcknowledgementGateway`, `LeaderstatsCoinBalanceAdapter`, `LeaderstatsConstants`
- Presentation: 정책 확인 패널이 플레이어의 코인을 보여 주고, 확인할 때마다 서버에 코인을 요청한다. 컴포넌트는 마운트될 때 자신의 속성을 받는다.
- `default.project.json`: 클라이언트가 요청할 때 쓰는 `RemoteEvent`
- 두 조립 지점이 위의 모든 것을 등록한다.
- `AGENTS.md`: CR-0010 이후에 밟은 지뢰

바뀌는 통제 문서는 없다.

## 4. 영향도 평가

| 영역 | 영향 |
|---|---|
| 플레이어 | 회사의 정책에 동의하면 보상을 받는다. 보상은 숫자이다. |
| 네트워크 | 원격 이벤트 하나. 서버는 그 이벤트가 나르는 인자를 읽지 않는다. |
| 데이터 | CR-0012 전까지는 서버의 수명을 넘어 남는 데이터가 없다. |
| 개발 생산성 | 코인 하나에 계층 넷, 계약 다섯, 원격 이벤트 하나가 든다. 의도된 결과이다. |
| 문서 분량 | 그대로이다. |

## 5. 원복 계획

본 변경의 머지 커밋을 되돌린다.
회사의 정책에 동의하는 일은 다시 그 자체로 보상이 된다.

## 6. 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 아키텍처 검토 위원회 | 상신 | 2026-10-31 |
| 결재 | Hawakiki | 제출 전 승인 | 2026-10-31 |

## 7. 시행 기록

| 커밋 | 변경 |
|---|---|
| — | 요청이 시행되면 채운다. |
