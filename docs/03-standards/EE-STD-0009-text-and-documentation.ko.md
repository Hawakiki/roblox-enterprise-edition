---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0009
title: 텍스트 파일 및 문서 작성 표준
translation-of: 0.9.0
---

# 텍스트 파일 및 문서 작성 표준

> 본 문서는 EE-STD-0009 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

본 표준은 모든 텍스트 파일을 어느 플랫폼에서나 읽을 수 있게 하고, 모든 문서를 같은 방식으로 쓰게 한다.

## 2. 적용 범위

1. §3 은 저장소의 모든 텍스트 파일에 적용한다.
2. §4 는 `docs/` 아래의 문서에 적용한다.

## 3. 텍스트 파일

1. 텍스트 파일은 UTF-8 로 인코딩한다(`INVALID_UTF8`).
2. 텍스트 파일은 BOM 으로 시작하지 아니한다(`UTF8_BOM`).
   비ASCII 문자를 포함한 PowerShell 스크립트는 예외로, 반드시 BOM 으로 시작해야 한다. Windows PowerShell 5.1 은 BOM 이 없는 파일을 ANSI 코드 페이지로 읽기 때문이다(`MISSING_UTF8_BOM`).
3. 줄은 LF 로 끝난다(`CRLF_LINE_ENDING`).
   이는 세 겹으로 강제한다. `core.autocrlf` 를 덮어쓰는 `.gitattributes`, 편집기를 위한 `.editorconfig`, 그리고 둘을 빠져나간 것을 잡는 checkpatch 이다.
4. 줄은 공백으로 끝나지 아니한다(`TRAILING_WHITESPACE`).
   따라서 줄 끝 공백 두 칸으로 만드는 Markdown 줄바꿈은 쓸 수 없다. 새 줄은 새 문장이다(§4).
5. 파일은 줄바꿈으로 끝난다(`MISSING_FINAL_NEWLINE`).
6. 확장자나 NUL 바이트로 식별되는 바이너리 파일은 본 절의 적용을 면제한다.

## 4. 문서

1. 한 줄에 한 문장씩 쓴다(EE-POL-0001 §8).
2. 영어는 쉽고 능동적으로 쓴다. 한국어는 문어체로 쓰며, 문장은 평서형 "-다"로 끝낸다.
3. 절에는 번호를, 부속서에는 알파벳을 붙인다.
4. 구조화된 정보는 문장 대신 표로 쓴다.
5. 날짜는 `YYYY-MM-DD` 로 쓴다. 해당 없는 표 칸에는 줄표(—)를 쓴다.
6. 양식의 자리 표시자는 꺾쇠괄호로 쓴다.
7. 용어는 EE-POL-0002 §6 의 용어를 따른다.

## 부속서 A. 본 표준에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `INVALID_UTF8` | 오류 | §3 |
| `UTF8_BOM` | 오류 | §3 |
| `MISSING_UTF8_BOM` | 오류 | §3 |
| `CRLF_LINE_ENDING` | 오류 | §3 |
| `TRAILING_WHITESPACE` | 오류 | §3 |
| `MISSING_FINAL_NEWLINE` | 오류 | §3 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 문서통제실 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 문서통제실 | 상신 | 2026-10-30 |
| 결재 | Hawakiki | 대기 | — |
