# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
#
# Every check in one place. The PowerShell version of tools/check.sh.
# 모든 검사를 한곳에서. tools/check.sh 의 PowerShell 판.
#   tools/check.ps1          # check / 검사
#   tools/check.ps1 -Fix     # also format and regenerate the registry / 포맷과 문서 대장 재생성까지
# Runs on Windows PowerShell 5.1 and PowerShell 7. Saved as UTF-8 with BOM so that 5.1 reads the Korean text.
# Windows PowerShell 5.1 과 PowerShell 7 둘 다 된다. 5.1 이 한글을 읽도록 UTF-8 BOM 으로 저장한다.
param([switch]$Fix)

$status = 0
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
	# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
	lune setup | Out-Null

	if ($Fix) {
		stylua scripts
		lune run scripts/gen_registry
	} else {
		stylua --check scripts
		if ($LASTEXITCODE -ne 0) { $status = 1 }
	}

	foreach ($solver in 'false', 'true') {
		# stderr lines captured with 2>&1 are ErrorRecords on 5.1 / 5.1 에서 2>&1 로 받은 stderr 줄은 ErrorRecord 라 문자열로 바꾼다
		$out = @(& luau-lsp analyze --platform=standard "--flag:LuauSolverV2=$solver" scripts 2>&1 |
				ForEach-Object { "$_" } | Where-Object { $_ -notmatch '^\[' })
		$count = @($out | Where-Object { $_ -cmatch 'Error' }).Count
		Write-Output "solverV2=${solver}: $count errors"
		if ($count -ne 0) {
			$out | Select-Object -First 60
			$status = 1
		}
	}

	lune run scripts/tests/run
	if ($LASTEXITCODE -ne 0) { $status = 1 }
	lune run scripts/checkpatch
	if ($LASTEXITCODE -ne 0) { $status = 1 }
} finally {
	Pop-Location
}
exit $status
