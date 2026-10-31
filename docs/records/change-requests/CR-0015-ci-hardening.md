---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0015
title: Harden the Continuous Integration
version: 1.0.0
status: Approved
classification: Internal
owner: Release Engineering
---

# Harden the Continuous Integration

## 1. Summary

The first run of the continuous integration on GitHub passed, and its review found that it could have passed without checking anything.
This change request makes every check fail when it cannot run. It runs the checks on Windows as well as Linux, and has the actions the workflow pins updated by notice. It also protects `main`, `develop` and the release tags on the server, against the one kind of mistake the tools of the Company cannot reach.

## 2. Background

The review of the first run found:

| Finding | Consequence |
|---|---|
| `tools/check` counted the lines in which luau-lsp wrote the word Error. A luau-lsp that is missing, or is given a path that does not exist or an argument it does not know, writes no such line. | The type checks reported 0 errors without analysing anything. |
| A failure of `rojo sourcemap` or `lune setup` was ignored. | The checks could run on a stale sourcemap or without the Lune definitions. |
| `tools/check.ps1` is written for Windows PowerShell 5.1 and PowerShell 7, but the workflow ran only `tools/check.sh` on Linux. | Nothing checked that the PowerShell version works. |
| The workflow ran on `ubuntu-latest`, which GitHub is moving to a new release. | The same commit could be checked on different systems. |
| The actions are pinned by commit, and nothing reports a newer release. | The pins would age without notice. |
| Nothing on GitHub stopped a force push to `main` or `develop`, their deletion, or the moving of a release tag. | The tools of the Company stop an agent, but not a person. |

## 3. Scope

- `tools/check.sh` and `tools/check.ps1`:
  - Each refuses to start without every tool it runs.
  - Each fails when luau-lsp exits with anything but 0, and names the exit code.
  - Each counts a failure of `rojo sourcemap` or `lune setup`.
  - `tools/check.ps1` sets its own error preference, so that a caller that stops on every error, as the PowerShell steps of GitHub do, cannot turn a line written to standard error into a crash.
- `.github/workflows/check.yml`:
  - On `ubuntu-24.04`, it runs `tools/check.sh` and checks every commit message.
  - On `windows-2025`, it runs `tools/check.ps1` under PowerShell 7 and under Windows PowerShell 5.1.
  - The toolchain is cached.
- `.github/dependabot.yml`: a monthly notice, as a pull request to `develop`, of a newer release of a pinned action. Dependabot signs off nothing, so the commit check fails its pull requests. They serve as notices, which a person carries out through a change request.
- `.github/rulesets/`: two rulesets, kept as files.
  - One forbids the deletion of `main` and `develop`, and every push to them that is not a fast-forward.
  - The other forbids the deletion or moving of a tag `v*`.
  - They are applied with `gh api` once the Approver of record approves the merge of this request.
- `README.md`, `README.ko.md` and `CONTRIBUTING.md`: the two systems the CI runs on, the notices of Dependabot and the rulesets.
- `AGENTS.md`: the mine that the first run uncovered.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Verification | A check that cannot run fails, instead of passing. |
| CI time | About doubles, for the Windows job; the cache recovers part of it. |
| Dependabot | Its pull requests fail by design. |
| History | No one can rewrite `main`, `develop` or a release tag on GitHub, the Approver of record included, until a ruleset is disabled. |

## 5. Rollback Plan

Revert the merge commit of this change, and delete the two rulesets with `gh api`.
The CI would again pass whatever it could not check.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Release Engineering | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
