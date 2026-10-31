<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->

# EnterpriseEdition

[English](README.md) | 한국어

<!-- ▼ 소개문 자리: 이 주석 아래에 한국어로 써 주세요. 대충 써도 됩니다. 영어판은 README.md 로 옮깁니다. ▼ -->

<!-- ▲ 소개문 끝 ▲ -->

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
지속적 통합은 모든 push 와 pull request 에서 같은 스크립트를 돌리며, commit-msg 훅처럼 모든 커밋 메시지를 검사한다.

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
