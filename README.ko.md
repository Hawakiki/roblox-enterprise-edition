<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->

# EnterpriseEdition

[English](README.md) | 한국어

> **`git commit --no-verify`?** 그러세요. 어차피 CI 가 이력의 모든 커밋 메시지를 검사합니다.\
> **`// eslint-disable-next-line`?** 여기엔 없습니다. checkpatch 에게 눈감아 달라고 할 방법은 없고, `--!nolint` 는 금지된 지시문입니다(EE-STD-0003).

웰컴 투 enterprise edition\
이름 그대로 엔터프라이즈 에디션입니다.

요즘 프로젝트는...

단지 설정 파일과 코드 비율이 이상한 것뿐입니다.\
네, 많이 이상합니다\
존X요

스타트업인데 벌써 3Tbps DDoS를 막을 생각으로 Docker, Redis, Kafka, Toxiproxy를 세팅하고\
NIH 증후군에 걸려서 모든 걸 자기가 만들며

어차피 기여자는 적겠지만 메일링 리스트를 만들고\
xz-utils마냥 공격도 안 할 테지만.\
규칙은 엄격하지만 맨날 구멍이 뻥뻥 뚫리고

물론 여기라고 다른 건 없습니다\
단지 모든 게 지켜지고\
xz-utils처럼 공격하려다가 뇌가 먼저 터져서 도망가는 겁니다.

STOP READING\
GET TO WORK

(it's a joke, don't take it seriously fr fr)

## 개발

### 준비물

- [Rokit](https://github.com/rojo-rbx/rokit): `rokit.toml` 이 고정한 툴체인인 Rojo, StyLua, luau-lsp, Lune, Moonwave 추출기를 설치한다.
- Rojo 플러그인을 설치한 Roblox Studio

### 설치

```sh
rokit trust evaera/moonwave            # 기계마다 한 번. Rokit 은 신뢰를 표시한 외부 도구만 설치한다
rokit install
lune setup                             # luau-lsp 가 쓰는 Lune 타입 정의
git config core.hooksPath .githooks    # commit-msg 훅. 클론마다 한 번
```

### 검사

```sh
tools/check.sh                         # Windows 에서는 tools/check.ps1. --fix(-Fix)를 붙이면 포맷과 문서 대장 재생성까지 한다
```

반드시 0 errors 로 끝나야 한다.
StyLua, 도구와 로블록스 코드에 대한 두 Luau 타입 솔버, 문서 주석에 대한 Moonwave 추출기, checkpatch 의 테스트, checkpatch 를 차례로 돌린다.
지속적 통합은 모든 push 와 pull request 에서 이를 Linux 에서는 Bash 로, Windows 에서는 PowerShell 7 과 5.1 로 돌리며, commit-msg 훅처럼 모든 커밋 메시지를 검사한다.
도구가 없거나 그 밖의 이유로 실행할 수 없는 검사는 실패한다.

### 실행

```sh
rojo serve default.project.json
```

Studio 에서 Rojo 플러그인으로 연결하고 Play 를 누른다.

- 한 번도 게시되지 않은 플레이스는 준법 코인을 메모리에 둔다.
- Studio 의 API 서비스 접근을 허용한 게시된 플레이스는 준법 코인을 DataStore 에 둔다.

다 쓰면 서버를 끈다. 트리가 바뀌는 동안 연결을 열어 두면 폴더의 두 번째 사본이 동기화될 수 있다.

### 무언가를 바꾸려면

[CONTRIBUTING.md](CONTRIBUTING.md) 를 읽는다. 에이전트는 [AGENTS.md](AGENTS.md) 에서 시작한다.

## 라이선스

[MIT](LICENSE)
