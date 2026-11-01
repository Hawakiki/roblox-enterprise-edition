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

# Set here, not inherited: a caller that stops on every error, as the PowerShell steps of GitHub do, would make
# Windows PowerShell 5.1 stop at the first line a tool writes to standard error (CR-0015).
# 물려받지 않고 여기서 정한다. GitHub 의 PowerShell 단계처럼 모든 오류에서 멈추는 호출자 아래에서는,
# Windows PowerShell 5.1 이 도구가 표준 오류에 쓴 첫 줄에서 멈추기 때문이다(CR-0015).
$ErrorActionPreference = 'Continue'
$status = 0

# Every tool the checks run, so that a missing one fails the checks instead of passing them unseen (CR-0015)
# 검사가 돌리는 모든 도구. 빠진 도구가 검사를 몰래 통과시키지 않고 실패시키게 한다(CR-0015)
foreach ($tool in 'stylua', 'rojo', 'luau-lsp', 'lune', 'moonwave-extractor') {
	if (-not (Get-Command $tool -CommandType Application -ErrorAction SilentlyContinue)) {
		Write-Output "missing tool: $tool; run rokit install"
		exit 1
	}
}

# Runs the new type solver over one target, as Roblox Studio checks it (EE-STD-0001 §4, CR-0025), judging by the
# exit code: luau-lsp also exits 1 for a path that does not exist or an argument it does not know, without
# writing the word Error (CR-0015)
# 대상 하나에 Roblox Studio 처럼 새 타입 솔버를 돌리고(EE-STD-0001 §4, CR-0025) 종료 코드로 판정한다.
# luau-lsp 는 없는 경로나 모르는 인자에도 Error 라는 단어 없이 1 로 끝나기 때문이다(CR-0015)
function Invoke-Analysis([string]$Label, [string[]]$Arguments) {
	# stderr lines captured with 2>&1 are ErrorRecords on 5.1 / 5.1 에서 2>&1 로 받은 stderr 줄은 ErrorRecord 라 문자열로 바꾼다
	$out = @(& luau-lsp analyze '--flag:LuauSolverV2=true' @Arguments 2>&1 |
			ForEach-Object { "$_" } | Where-Object { $_ -notmatch '^\[' })
	$code = $LASTEXITCODE
	$count = @($out | Where-Object { $_ -cmatch 'Error' }).Count
	Write-Output "$Label solverV2=true: $count errors"
	if ($code -ne 0 -or $count -ne 0) {
		Write-Output "luau-lsp exited with $code"
		$out | Select-Object -First 60
		$script:status = 1
	}
}

Push-Location (Split-Path -Parent $PSScriptRoot)
try {
	# Lune type definitions, which scripts/.luaurc points luau-lsp at / scripts/.luaurc 가 가리키는 Lune 타입 정의
	lune setup | Out-Null
	if ($LASTEXITCODE -ne 0) { $status = 1 }

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
		# Those of the luau-lsp release that rokit.toml pins, so that a fresh checkout analyses as every other (CR-0013)
		# rokit.toml 이 고정한 luau-lsp 릴리스의 것을 받아, 새로 받은 사본도 다른 사본과 똑같이 분석한다(CR-0013)
		$luauLsp = [regex]::Match((Get-Content -Raw rokit.toml), '(?m)^luau-lsp = ".*@(.+)"').Groups[1].Value
		$defs = './globalTypes.d.luau'
		Invoke-WebRequest -UseBasicParsing -OutFile $defs "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/$luauLsp/scripts/globalTypes.d.luau"
	}

	if ($Fix) {
		stylua scripts src
		lune run scripts/gen_registry
	} else {
		stylua --check scripts src
		if ($LASTEXITCODE -ne 0) { $status = 1 }
	}

	rojo sourcemap default.project.json --include-non-scripts -o sourcemap.json | Out-Null
	if ($LASTEXITCODE -ne 0) { $status = 1 }

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
