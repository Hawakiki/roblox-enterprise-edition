---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0020
title: Test the Facts That ADR-0001 Rests On
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Test the Facts That ADR-0001 Rests On

## 1. Summary

This change request adds a fitness test for ADR-0001, which tells the Company when a fact the decision rests on changes, so that the record is revisited rather than left to rot.
It also records how the release workflow deployed 1.1.0, and how the Approver of record can approve a deployment when the review dialog of GitHub does not respond.

## 2. Background

ADR-0001 rests on what luau-lsp 1.69.0 does with a class and its contract.
The old type solver refuses a class instance returned as its contract without the cast through `any`, and the new one accepts it.
The old solver reports a method that has drifted from its contract where `_implements` declares it, and the new one reports nothing.
Nothing tells the Company when a newer luau-lsp changes one of these facts, for example when the new solver starts to catch the drift.

The first design kept the fixtures of the test, deliberately invalid Luau, in `scripts/tests/solver-fixtures/`, and excluded that folder from the analysis of `tools/check`.
EE-STD-0001 §4.1 holds every `.luau` file to both type solvers, and `tools/check` is what enforces it.
Excluding the folder would have switched the standard off for those files, and a rule that is not enforced is a recommendation (EE-CHR-0001, Article 4).
The implementer stopped and reported the conflict instead of following the brief.
The Approver of record chose to keep the fixtures as strings in the tests, written under the ignored `build/` when the test runs, so that no invalid Luau enters the repository and all of `scripts/` stays analysed.

CR-0017 left to the request that follows it the record of how the release workflow deployed 1.1.0.
The tag `v1.1.0` was pushed on 2026-10-31, with `main` and `develop`.
Run 41200439245 of the release workflow passed Calendar, then Check, build and write the notes, and waited in the environment `production`.
The dialog in which GitHub reviews a deployment did not respond, so the Approver of record approved deployment 7458471110 through `gh api`.
Publish consulted the calendar once more, and published the GitHub release `v1.1.0` at 2026-10-31T12:22:38Z, with `EnterpriseEdition-v1.1.0.rbxl` of 52175 bytes and notes that list CR-0015, CR-0016 and CR-0017 only.
It became the latest release.
The check runs of `main` and `develop` passed, and so did the first run of Dependabot, which opened no pull request.

## 3. Scope

- `scripts/tests/AdrFitnessFixtures.luau`: four fixtures held as source strings: a class whose methods drift from its contract, a class returned as its contract without the cast, the pattern as `src/` writes it, and an obvious type error that proves the analyser ran.
- `scripts/tests/AdrFitness.spec.luau`, listed in `scripts/tests/run.luau`: writes each fixture to `build/solver-fixtures/`, analyses it under both solvers, and fails with a message naming ADR-0001 when a result differs from the one the record rests on.
- `README.md` and `README.ko.md`: approving a deployment with `gh api` when the review dialog does not respond, as a fallback that the Approver of record runs.
- `AGENTS.md`: the mine of deliberately invalid Luau.
- This request: the record of how 1.1.0 was deployed.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Architecture | Nothing changes. The facts behind ADR-0001 are checked on every run of `tools/check`. |
| Checks | Eight more analyses by luau-lsp, about a second. Four files are written under `build/`, which git ignores. |
| Releases | Nothing changes. The fallback for approving a deployment is written down. |
| Documentation volume | One line in each README, one mine, and this record. |

## 5. Rollback Plan

Revert the merge commit of this change.
The files the test wrote under `build/` stay where they are, ignored, until someone deletes them.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
