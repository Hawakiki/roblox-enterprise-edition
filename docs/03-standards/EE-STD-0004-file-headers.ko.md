---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0004
title: 파일 헤더 표준
translation-of: 1.1.0
---

# 파일 헤더 표준

> 본 문서는 EE-STD-0004 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 목적

모든 파일은 첫 몇 줄에 배포 라이선스와 저작권자를 밝혀, 저장소 밖으로 복사되더라도 그 파일만으로 이해될 수 있게 한다.
형식은 리눅스 커널과 REUSE 규격이 쓰는 SPDX 를 따른다.

## 2. 적용 범위

본 표준은 저장소의 모든 텍스트 파일에 적용한다.

## 3. 헤더

1. 모든 파일은 처음 10줄 안에, 그 파일의 주석 문법으로 다음 두 줄을 둔다(`MISSING_SPDX_HEADER`).

```text
SPDX-License-Identifier: MIT
SPDX-FileCopyrightText: <year> Hawakiki and EnterpriseEdition contributors
```

2. 연도는 파일을 만든 해이며, 이후에 갱신하지 아니한다.
3. 라이선스는 `LICENSE` 와 같은 MIT 이다. 다른 라이선스의 파일은 저장소에 두지 아니한다.

## 4. 위치

| 파일 | 형식 |
|---|---|
| Luau | 첫 줄들에 `--` 주석, `--!strict` 보다 앞 |
| 셸 스크립트 | shebang 줄 다음에 `#` 주석 |
| PowerShell 스크립트 | BOM 다음에 `#` 주석 |
| TOML, `.gitignore`, `.gitattributes`, `.editorconfig` | 첫 줄들에 `#` 주석 |
| `docs/` 아래의 문서 | frontmatter 블록 안의 YAML 주석(EE-POL-0001 §7) |
| 그 밖의 Markdown | 첫 줄들에 HTML 주석 |
| SVG | 첫 줄들에 XML 주석, 루트 요소보다 앞 |

## 5. 예외

1. `.luaurc` 를 포함한 JSON 파일은 JSON 에 주석 문법이 없으므로 헤더를 두지 아니한다. 이 파일들은 `LICENSE` 가 다룬다.
2. `LICENSE` 는 라이선스 그 자체이므로 헤더를 두지 아니한다.
3. 바이너리 파일은 헤더를 두지 아니한다.

## 6. 모듈 머리 주석

Luau 모듈은 파일 헤더 아래에 두 언어로 쓴 머리 주석을 둔다(EE-STD-0001 §6).

## 부속서 A. 본 표준에 따라 강제되는 규칙

| 규칙 | 심각도 | 조항 |
|---|---|---|
| `MISSING_SPDX_HEADER` | 오류 | §3 |

## 개정 이력

| 버전 | 일자 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | 검토 회부 | 법무팀 |
| 1.0.0 | 2026-10-30 | 승인 | 법무팀 |
| 1.1.0 | 2026-10-31 | §4: SVG 파일의 헤더 위치(CR-0021) | 법무팀 |

## 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 법무팀 | 상신 | 2026-10-31 |
| 결재 | Hawakiki | 대기 | — |
