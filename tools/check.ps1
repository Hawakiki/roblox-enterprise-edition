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

# Runs both solvers over one target / 대상 하나에 두 솔버를 돌린다
function Invoke-Analysis([string]$Label, [string[]]$Arguments) {
	foreach ($solver in 'false', 'true') {
		# stderr lines captured with 2>&1 are ErrorRecords on 5.1 / 5.1 에서 2>&1 로 받은 stderr 줄은 ErrorRecord 라 문자열로 바꾼다
		$out = @(& luau-lsp analyze "--flag:LuauSolverV2=$solver" @Arguments 2>&1 |
				ForEach-Object { "$_" } | Where-Object { $_ -notmatch '^\[' })
		$count = @($out | Where-Object { $_ -cmatch 'Error' }).Count
		Write-Output "$Label solverV2=${solver}: $count errors"
		if ($count -ne 0) {
			$out | Select-Object -First 60
			$script:status = 1
		}
	}
}

Push-Location (Split-Path -Parent $PSScriptRoot)
try {
	# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
	lune setup | Out-Null

	# Roblox type definitions: shared by the workspace that holds the main checkout, then local, downloaded if
	# neither exists. git finds the main checkout, from an agent worktree too (CR-0009).
	# Roblox 타입 정의: 주 작업 폴더가 있는 워크스페이스 공용(../.luau) → 프로젝트 로컬 순으로 찾고, 없으면 받는다.
	# 주 작업 폴더는 git 이 찾으므로 에이전트 작업 사본에서도 찾는다(CR-0009).
	$main = Split-Path -Parent (git rev-parse --path-format=absolute --git-common-dir)
	$defs = $null
	foreach ($candidate in (Join-Path $main '../.luau/globalTypes.d.luau'), './globalTypes.d.luau') {
		if (Test-Path -LiteralPath $candidate) { $defs = $candidate; break }
	}
	if (-not $defs) {
		$defs = './globalTypes.d.luau'
		Invoke-WebRequest -UseBasicParsing -OutFile $defs 'https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau'
	}

	if ($Fix) {
		stylua scripts src
		lune run scripts/gen_registry
	} else {
		stylua --check scripts src
		if ($LASTEXITCODE -ne 0) { $status = 1 }
	}

	rojo sourcemap default.project.json --include-non-scripts -o sourcemap.json | Out-Null

	Invoke-Analysis 'scripts' @('--platform=standard', 'scripts')
	Invoke-Analysis 'src' @('--platform=roblox', '--sourcemap=sourcemap.json', "--definitions=$defs", 'src')

	# Moonwave reads every doc comment under src/ as the documentation site would; the JSON is not kept (CR-0009)
	# Moonwave 가 문서 사이트처럼 src/ 아래의 모든 문서 주석을 읽는다. 추출한 JSON 은 버린다(CR-0009)
	moonwave-extractor extract src > $null
	if ($LASTEXITCODE -eq 0) { Write-Output 'moonwave: doc comments read' } else { $status = 1 }

	lune run scripts/tests/run
	if ($LASTEXITCODE -ne 0) { $status = 1 }
	lune run scripts/checkpatch
	if ($LASTEXITCODE -ne 0) { $status = 1 }
} finally {
	Pop-Location
}
exit $status
