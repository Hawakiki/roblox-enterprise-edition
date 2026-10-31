---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0015
title: 지속적 통합 강화
translation-of: 1.2.0
---

# 지속적 통합 강화

> 본 문서는 CR-0015 영문 정본의 번역본이다. 내용이 상충하는 경우 영문 정본이 우선한다.

## 1. 요약

GitHub 위에서 처음 돈 지속적 통합은 통과하였으나, 그 검토에서 아무것도 검사하지 않고도 통과할 수 있었다는 사실이 드러났다.
본 변경 요청은 실행할 수 없는 검사가 모두 실패하게 한다. 검사를 Linux 뿐 아니라 Windows 에서도 돌리고, 워크플로가 고정한 액션의 갱신을 알림으로 받는다. 또한 회사의 도구가 닿지 못하는 단 한 가지 실수에 대비해, 서버에서 `main`, `develop`, 릴리스 태그를 보호한다.

## 2. 배경

첫 실행의 검토에서 드러난 것은 다음과 같다.

| 발견 | 결과 |
|---|---|
| `tools/check` 는 luau-lsp 가 Error 라는 단어를 쓴 줄을 세었다. luau-lsp 가 없거나, 존재하지 않는 경로나 모르는 인자를 받으면 그런 줄을 쓰지 않는다. | 타입 검사가 아무것도 분석하지 않고 0 errors 를 보고하였다. |
| `rojo sourcemap` 이나 `lune setup` 의 실패를 무시하였다. | 낡은 sourcemap 으로, 또는 Lune 타입 정의 없이 검사가 돌 수 있었다. |
| `tools/check.ps1` 은 Windows PowerShell 5.1 과 PowerShell 7 을 위해 썼지만, 워크플로는 Linux 에서 `tools/check.sh` 만 돌렸다. | PowerShell 판이 동작하는지 아무것도 검사하지 않았다. |
| 워크플로는 GitHub 이 새 릴리스로 옮기고 있는 `ubuntu-latest` 에서 돌았다. | 같은 커밋이 서로 다른 시스템에서 검사될 수 있었다. |
| 액션은 커밋으로 고정되어 있으나, 새 릴리스를 알려 주는 것이 없다. | 고정한 버전이 알림 없이 낡아 갔을 것이다. |
| GitHub 에는 `main` 이나 `develop` 으로의 강제 push, 그 삭제, 릴리스 태그의 이동을 막는 것이 없었다. | 회사의 도구는 에이전트를 막지만 사람은 막지 못한다. |

## 3. 범위

- `tools/check.sh` 와 `tools/check.ps1`
  - 각각 자신이 돌리는 도구가 하나라도 없으면 시작하지 아니한다.
  - 각각 luau-lsp 가 0 이 아닌 값으로 끝나면 실패하며, 그 종료 코드를 밝힌다.
  - 각각 `rojo sourcemap` 이나 `lune setup` 의 실패를 실패로 센다.
  - `tools/check.ps1` 은 자신의 오류 처리 방식을 스스로 정한다. 그래서 GitHub 의 PowerShell 단계처럼 모든 오류에서 멈추는 호출자가, 표준 오류에 쓰인 한 줄을 중단으로 바꾸지 못하게 한다.
- `.github/workflows/check.yml`
  - `ubuntu-24.04` 에서 `tools/check.sh` 를 돌리고 모든 커밋 메시지를 검사한다.
  - `windows-2025` 에서 `tools/check.ps1` 을 PowerShell 7 과 Windows PowerShell 5.1 로 각각 돌린다.
  - 툴체인을 캐시한다.
- `.github/dependabot.yml`: 고정한 액션에 새 릴리스가 나오면 매달 `develop` 으로의 pull request 로 알린다. Dependabot 은 아무것에도 서명하지 않으므로 커밋 검사는 그 pull request 를 실패시킨다. 이는 알림 구실을 하며, 사람이 변경 요청을 거쳐 시행한다.
- `.github/rulesets/`: 파일로 보관하는 ruleset 두 개
  - 하나는 `main` 과 `develop` 의 삭제와, 빨리 감기가 아닌 모든 push 를 금지한다.
  - 다른 하나는 `v*` 태그의 삭제와 이동을 금지한다.
  - 기록상 결재권자가 본 요청의 머지를 승인하면 `gh api` 로 적용한다.
- `README.md`, `README.ko.md`, `CONTRIBUTING.md`: CI 가 도는 두 시스템, Dependabot 의 알림, ruleset
- `AGENTS.md`: 첫 실행이 드러낸 지뢰

바뀌는 통제 문서는 없다.

## 4. 영향도 평가

| 영역 | 영향 |
|---|---|
| 검증 | 실행할 수 없는 검사는 통과하지 않고 실패한다. |
| CI 시간 | Windows 작업 때문에 약 두 배가 되며, 캐시가 일부를 되찾는다. |
| Dependabot | 그 pull request 는 설계상 실패한다. |
| 이력 | 기록상 결재권자를 포함해 누구도, ruleset 을 끄기 전에는 GitHub 에서 `main`, `develop`, 릴리스 태그를 고쳐 쓸 수 없다. |

## 5. 원복 계획

본 변경의 머지 커밋을 되돌리고, `gh api` 로 ruleset 두 개를 지운다.
CI 는 다시 검사할 수 없었던 것을 통과시키게 된다.

## 6. 결재

| 구분 | 이름 | 결정 | 일자 |
|---|---|---|---|
| 기안 | 릴리스 엔지니어링 | 상신 | 2026-10-31 |
| 결재 | Hawakiki | 제출 전 승인 | 2026-10-31 |
| 시행 | 릴리스 엔지니어링 | 시행 완료 | 2026-10-31 |

## 7. 시행 기록

| 커밋 | 변경 |
|---|---|
| `2174d2c` | 본 변경 요청 등록 |
| `4056b43` | `tools/check` 가 실행할 수 없는 모든 검사를 실패시키고, `tools/check.ps1` 이 오류 처리 방식을 스스로 정하게 함 |
| `5a87bd1` | 워크플로를 고정 이미지 위의 Linux 작업과 Windows 작업으로 나누고, 툴체인을 캐시하고, Dependabot 을 추가하고, ruleset 두 개를 파일로 보관함 |
| `3bbfdf5` | 두 README 와 `CONTRIBUTING.md` 에 강화된 CI 를 설명하고, `AGENTS.md` 에 지뢰 세 가지를 기록함 |
| `424bc81` | 본 요청을 시행 완료로 표시 |

2026-10-31 에 머지가 승인되어, ruleset 두 개를 `gh api` 로 GitHub 의 저장소에 적용하였다. ruleset 26259515(`main` 과 `develop`)와 26259516(릴리스 태그)이다.
이후 GitHub 은 두 브랜치의 규칙으로 `deletion` 과 `non_fast_forward` 를 보고하였다.
