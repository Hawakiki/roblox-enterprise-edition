#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
#
# Every check in one place: formatting, both type solvers on the tooling and on the Roblox code,
# checkpatch's own tests, then checkpatch.
# 모든 검사를 한곳에서: 포맷, 도구와 로블록스 코드에 대한 두 타입 솔버, checkpatch 자체 테스트, 그리고 checkpatch.
#   tools/check.sh          # check / 검사
#   tools/check.sh --fix    # also format and regenerate the registry / 포맷과 문서 대장 재생성까지
set -u
cd "$(dirname "$0")/.."
status=0

# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
lune setup >/dev/null

# Roblox type definitions: shared by the workspace, then local, downloaded if neither exists
# Roblox 타입 정의: 워크스페이스 공용(../.luau) → 프로젝트 로컬 순으로 찾고, 없으면 받는다
DEFS=""
for candidate in ../.luau/globalTypes.d.luau ./globalTypes.d.luau; do
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

lune run scripts/tests/run || status=1
lune run scripts/checkpatch || status=1
exit $status
