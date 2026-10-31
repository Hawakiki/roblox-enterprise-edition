#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
#
# Every check in one place: formatting, both type solvers on the tooling and on the Roblox code,
# Moonwave on the doc comments, checkpatch's own tests, then checkpatch.
# 모든 검사를 한곳에서: 포맷, 도구와 로블록스 코드에 대한 두 타입 솔버, 문서 주석에 대한 Moonwave,
# checkpatch 자체 테스트, 그리고 checkpatch.
#   tools/check.sh          # check / 검사
#   tools/check.sh --fix    # also format and regenerate the registry / 포맷과 문서 대장 재생성까지
set -u
cd "$(dirname "$0")/.."
status=0

# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
lune setup >/dev/null

# Roblox type definitions: shared by the workspace that holds the main checkout, then local, downloaded if
# neither exists. git finds the main checkout, from an agent worktree too (CR-0009).
# Roblox 타입 정의: 주 작업 폴더가 있는 워크스페이스 공용(../.luau) → 프로젝트 로컬 순으로 찾고, 없으면 받는다.
# 주 작업 폴더는 git 이 찾으므로 에이전트 작업 사본에서도 찾는다(CR-0009).
MAIN=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
DEFS=""
for candidate in "$MAIN/../.luau/globalTypes.d.luau" ./globalTypes.d.luau; do
	if [ -f "$candidate" ]; then DEFS="$candidate"; break; fi
done
if [ -z "$DEFS" ]; then
	DEFS=./globalTypes.d.luau
	curl -sSL -o "$DEFS" https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau
fi

if [ "${1:-}" = "--fix" ]; then
	stylua scripts src
	lune run scripts/gen_registry
else
	stylua --check scripts src || status=1
fi

rojo sourcemap default.project.json --include-non-scripts -o sourcemap.json >/dev/null

# Runs both solvers over one target / 대상 하나에 두 솔버를 돌린다
analyze() {
	local label=$1
	shift
	for solver in false true; do
		out=$(luau-lsp analyze --flag:LuauSolverV2=$solver "$@" 2>&1 | grep -v '^\[')
		count=$(printf '%s' "$out" | grep -c 'Error' || true)
		echo "$label solverV2=$solver: $count errors"
		if [ "$count" != "0" ]; then printf '%s\n' "$out" | head -60; status=1; fi
	done
}
analyze scripts --platform=standard scripts
analyze src --platform=roblox --sourcemap=sourcemap.json "--definitions=$DEFS" src

# Moonwave reads every doc comment under src/ as the documentation site would; the JSON is not kept (CR-0009)
# Moonwave 가 문서 사이트처럼 src/ 아래의 모든 문서 주석을 읽는다. 추출한 JSON 은 버린다(CR-0009)
if moonwave-extractor extract src >/dev/null; then echo "moonwave: doc comments read"; else status=1; fi

lune run scripts/tests/run || status=1
lune run scripts/checkpatch || status=1
exit $status
