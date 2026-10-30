#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
#
# Every check in one place: formatting, both type solvers, checkpatch's own tests, then checkpatch.
# 모든 검사를 한곳에서: 포맷, 두 타입 솔버, checkpatch 자체 테스트, 그리고 checkpatch.
#   tools/check.sh          # check / 검사
#   tools/check.sh --fix    # also format with stylua / stylua 포맷까지
set -u
cd "$(dirname "$0")/.."
status=0

# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
lune setup >/dev/null

if [ "${1:-}" = "--fix" ]; then stylua scripts; else stylua --check scripts || status=1; fi

for solver in false true; do
	out=$(luau-lsp analyze --platform=standard --flag:LuauSolverV2=$solver scripts 2>&1 | grep -v '^\[')
	count=$(printf '%s' "$out" | grep -c 'Error' || true)
	echo "solverV2=$solver: $count errors"
	if [ "$count" != "0" ]; then printf '%s\n' "$out" | head -60; status=1; fi
done

lune run scripts/tests/run || status=1
lune run scripts/checkpatch || status=1
exit $status
