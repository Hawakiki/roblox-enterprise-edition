---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0001
title: Luau 코딩 표준
translation-of: 2.0.0
---

# Luau 코딩 표준

> 본 문서는 EE-STD-0001 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 표준은 저장소의 모든 Luau 파일이 하는 일과 관계없이 지켜야 할 규칙을 정한다.

## 2. 적용 범위

1. 본 표준은 `scripts/` 아래의 도구와 `src/` 아래의 로블록스 코드를 포함한 모든 `.luau` 파일에 적용한다.
2. 로블록스 코드에는 명명 규칙(EE-STD-0002), 금지 API 목록(EE-STD-0003), 숫자 리터럴 표준(EE-STD-0005), 아키텍처 계층 표준(EE-STD-0006)이 추가로 적용된다.
3. 도구를 포함한 모든 Luau 파일의 지시문에는 금지 API 목록(EE-STD-0003)이 적용된다.

## 3. Strict 모드

1. 모든 Luau 파일은 코드나 블록 주석보다 앞선 첫 주석 줄들 사이에 `--!strict` 를 선언한다(`MISSING_STRICT_MODE`).
2. `.luaurc` 파일로도 strict 모드를 설정할 수 있으나 Roblox Studio 는 이를 읽지 아니한다. 어디서나 유효한 설정은 이 선언 주석뿐이다.
3. Luau 파일이 선언하는 지시문은 `--!strict` 하나뿐이다.
   그 곁에 다른 지시문을 함께 선언한 파일은, 어느 쪽이 먼저 오든 EE-STD-0003 에 따라 보고된다.

## 4. 타입 검사

1. 모든 Luau 파일은 Roblox Studio 가 검사하듯 새 타입 솔버에서, 즉 `LuauSolverV2` 를 켠 상태에서 오류 없이 타입 검사를 통과해야 한다.
2. `scripts/` 아래의 도구는 standard 플랫폼과 Lune 타입 정의로, 로블록스 코드는 Roblox 플랫폼과 sourcemap 으로 검사한다.
3. `tools/check` 는 새 솔버 하나만 돌린다.
   옛 솔버는 돌리지 않는다. 옛 솔버만 보고하던 것, 곧 제네릭 함수 본문 안에서 타입 매개변수가 얽힌 실수는 잃는 것으로 받아들인다(ADR-0003).

## 5. 서식

1. 모든 Luau 파일은 `stylua.toml` 설정에 따라 StyLua 로 서식을 맞춘다. 탭, 120칸, 큰따옴표, 모든 호출에 괄호를 쓴다.
2. `tools/check` 는 서식을 검사하고, `tools/check --fix` 는 서식을 적용한다.

## 6. 주석

1. 모든 모듈은 파일 헤더(EE-STD-0004) 아래에, 목적을 영어로 쓰고 이어서 한국어로 쓴 블록 주석으로 시작한다.
2. 그 밖의 주석은 영어로 쓰며, 무엇을 하는지보다 왜 하는지를 설명한다.
3. `src/` 아래의 로블록스 코드에서 코드를 문서화하는 주석은 Moonwave 문서 주석이다. 문서 주석은 그 줄에 홀로 놓인 `--[=[` 로 열고 `]=]` 로 닫는 블록 주석이다.
   그 밖의 형식으로 쓴 주석은 아무것도 문서화하지 않는다.
   `scripts/` 아래의 도구는 §6.1 의 블록 주석을 유지하며 문서 주석은 필요하지 않다.
4. §6.1 의 블록 주석은 모듈의 이름을 `@class` 로 지닌 문서 주석이다(`MISSING_MODULE_DOC`).
   조립 지점은 모듈 이름이 없으므로 `ServerCompositionRoot` 처럼 자기 클래스에 따로 이름을 붙인다.
5. 계약 모듈은 그 계약을 `@interface` 와 `@within` 으로도 문서화하며, 둘 다 모듈의 이름을 가리키고, 계약의 멤버를 필드로 나열한다(`MISSING_MODULE_DOC`).
   Moonwave 는 모든 인터페이스를 어떤 클래스 안에 두므로, 계약 모듈은 클래스와 인터페이스를 모두 지닌다.
6. 모든 공개 함수는 바로 위에 문서 주석을 두며, 둘 사이에는 코드가 없다(`MISSING_FUNCTION_DOC`).
   공개 함수란 `function ApplicationHost.Start(self)` 나 `ApplicationHost.Start = function(self)` 처럼 모듈이 반환하는 테이블에 선언한 함수 중 이름이 밑줄로 시작하지 않는 것을 말한다.
7. 공개 함수의 문서 주석은 모듈의 클래스를 가리키는 `@within`, `self` 를 뺀 모든 매개변수의 `@param`, 그리고 함수가 `()` 가 아닌 반환 타입을 선언한 경우 `@return` 을 지닌다.
   함수에 없는 매개변수는 문서화하지 아니한다(`INCOMPLETE_DOC_COMMENT`).
8. 클래스와 인터페이스의 설명은 영어로 쓰고 이어서 한국어로 쓴다.
   함수의 문서 주석을 포함한 그 밖의 모든 문서 주석은 영어로만 쓴다(`DOC_COMMENT_LANGUAGE`).
9. Moonwave 는 문장 앞에 놓인 문서 주석만 읽으며, 테이블 생성자 안의 문서 주석은 말없이 버린다.
   따라서 문서화할 값은 그 값만의 문장에서 대입한다.
   메서드에는 `@method`, 속성에는 `@prop`, 타입에는 `@type` 을 붙인다. 이 태그들은 강제되지 않으므로 권고이다(EE-CHR-0001 제4조).
10. 문서 주석은 Moonwave 를 위해 쓰지만, `tools/check` 는 Node.js 가 필요한 문서 사이트를 생성하지 아니한다.

## 7. Require

1. 모듈은 타입 검사기가 따라갈 수 있도록 정적 경로로 require 한다.
2. 도구는 `require("./lib/Report")` 처럼 상대 경로로 모듈을 require 한다.
3. 로블록스 코드는 `require(ReplicatedStorage.EnterpriseEdition.Shared.Types)` 처럼 서비스에서 시작하는 인스턴스 경로로 모듈을 require 한다.
   `WaitForChild` 를 거쳐 require 하지 아니한다. 그러면 타입 검사기가 모듈을 볼 수 없다.

## 8. 툴체인

1. 도구 버전은 `rokit.toml` 에 고정한다.
2. 도구 버전을 적은 설정은 `rokit.toml` 과 일치해야 한다(`TOOLCHAIN_VERSION_MISMATCH`).
   현재는 `scripts/.luaurc` 의 Lune 타입 정의 별칭이 이에 해당한다.
3. `lune setup` 은 실행한 폴더에 `.luaurc` 를 만든다. 루트에 만든 것은 무시한다(CR-0002).

## 9. 도구

`scripts/` 아래의 도구는 리눅스 커널의 전통을 따른다.
실행 스크립트는 `checkpatch`, `gen_registry` 처럼 하는 일을 snake case 로, 모듈은 Pascal case 로 이름 짓는다.
도구는 명명 표준의 적용을 면제한다.

## 부속서 A. 본 표준에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `MISSING_STRICT_MODE` | 오류 | §3 |
| `MISSING_MODULE_DOC` | 오류 | §6 |
| `MISSING_FUNCTION_DOC` | 오류 | §6 |
| `INCOMPLETE_DOC_COMMENT` | 오류 | §6 |
| `DOC_COMMENT_LANGUAGE` | 오류 | §6 |
| `TOOLCHAIN_VERSION_MISMATCH` | 오류 | §8 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 아키텍처 검토 위원회 |
| 1.0.0 | 2026-10-30 | 승인 | 아키텍처 검토 위원회 |
| 1.1.0 | 2026-10-30 | 로블록스 코드의 Moonwave 문서 주석, 유일한 지시문 `--!strict`(CR-0008) | 아키텍처 검토 위원회 |
| 2.0.0 | 2026-11-01 | §4: 새 타입 솔버 하나로 검사, 옛 솔버는 더 요구하지 않음(CR-0025) | 아키텍처 검토 위원회 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 아키텍처 검토 위원회 | 상신 | 2026-11-01 |
| 결재 | Hawakiki | 대기 | — |
