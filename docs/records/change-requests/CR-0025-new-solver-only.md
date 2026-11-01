---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0025
title: Check With the New Type Solver Alone
version: 1.2.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Check With the New Type Solver Alone

## 1. Summary

Roblox Studio checks scripts with the new Luau type solver, and since CR-0023 the new solver holds every method of a contract to its signature.
This change request checks the code with the new solver alone, as Studio does, and sets it in the place.
With the old solver gone, a constructor no longer needs to cast its instance through `any` to return it as its contract, and the cast is removed. It hid a class that lacked a method of its contract, which the new solver now reports at the constructor.
The new solver does not check the body of a generic function where it involves the type parameter, and that loss, in seven functions, is accepted.
The release that brings this change removes an obligation of an approved document, and will be numbered 2.0.0. The request also records how the release workflow deployed 1.2.0.

## 2. Background

EE-STD-0001 §4 holds every Luau file to both solvers. ADR-0001 kept the old one because only it held the methods of `_implements` to their contracts. CR-0023 wrapped those methods, and both solvers now hold them (ADR-0002).
The editor settings of the repository already run luau-lsp with the new solver alone.

On 2026-11-01, under luau-lsp 1.69.0, the old solver still reported one kind of mistake that the new one did not: a mistake inside the body of a generic function that involves its type parameter.
Of five such mistakes, the old solver reported all and the new none. A mistake in the same bodies that does not involve the parameter, and the same mistake in a function that is not generic, were reported by both.
`src/` holds seven generic functions: `ServiceToken.new`, `ServiceCollection.AddSingleton` and `AddTransient`, `ServiceProvider.GetRequiredService`, `ResourceScope.Adopt` and `Using`, and `ComponentScope.Adopt`.
The Approver of record accepted that loss on 2026-10-31, on condition that the signatures of contracts were held first, which CR-0023 did.

The same day, in a clone that was never pushed, the thirteen casts through `any` in the constructors of `src/` were removed.
The new solver reported no error, the old one twenty-seven, and every test passed.
A class whose method `Release` was renamed `Release2`, with its wrapper in `_implements` calling `Release2`, drew no error from the new solver while the constructor cast its instance, and would have failed at the first call of `Release`. Without the cast, the new solver reported the constructor.

CR-0024 left the record of how 1.2.0 was deployed to the request that follows it.
The release workflow ran for `v1.2.0` as run 41261633129: the calendar admitted it, and the checks, the build and the notes passed.
The Approver of record approved the deployment in the environment `production` through the review dialog of GitHub, which responded this time. The deployment, 7467046918, was created at 2026-11-01T01:34:54Z.
The GitHub release of `v1.2.0` was published at 2026-11-01T01:36:36Z as the latest release, with the notes of CR-0018 to CR-0024 and a place of 54824 bytes, the size that the rehearsal built.
The checks that ran for `main` and `develop` passed.

## 3. Scope

- `tools/check.sh` and `tools/check.ps1`: each target analysed by the new solver alone.
- `default.project.json`: `Workspace.UseNewLuauTypeSolver` set to `Enabled`, so that the place built and served holds the solver it is checked with.
- The thirteen constructors of `src/`, which return their instance as their contract without a cast. `CAST_THROUGH_ANY` reports every cast through `any` in `src/`, with tests.
- EE-STD-0001, revised `In Review` at 2.0.0: §4 holds every Luau file to the new solver alone. Its children, EE-STD-0002, EE-STD-0003, EE-STD-0005 and EE-STD-0006, are reviewed against it.
- EE-STD-0006, revised `In Review` at 2.0.0: §6 lets a constructor return its instance without a cast, and keeps the wrappers.
- A new architecture decision record of the decision and of the loss it accepts, which supersedes ADR-0002. ADR-0002 is set to `Superseded` when the new record is accepted.
- The fitness test of CR-0020, turned to the new record. It still runs the old solver, only as a witness that a fixture holds the mistake it is meant to hold.
- `AGENTS.md`, where it cites ADR-0002 or says that a file is held to both solvers.
- A person opens the place in Roblox Studio and checks that it uses the new solver, that the script analysis of the code is clean, and that the panel still pays a compliance coin in a play test.

Release 2.0.0 itself is left to a request of its own.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Roblox code | Thirteen constructors lose their cast. No behaviour changes. |
| Type checking | One solver, as in Studio. A constructor whose class lacks a method of its contract is reported. A mistake that involves the type parameter in the body of one of seven generic functions is not. |
| Check time | Each target is analysed once instead of twice. |
| Release | An obligation of an approved document is removed: a MAJOR release, 2.0.0 (EE-STD-0008 §4.2). |
| Documentation volume | Two standards revised at a MAJOR version and three reviewed, one decision record added and one superseded. |

## 5. Rollback Plan

Revert the merge commit of this change. The old solver returns to `tools/check` and the casts to the constructors, and ADR-0002 is accepted again.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved before filing | 2026-11-01 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `525c0d3` | Filed this change request. |
| `4fb56c8` | Analysed every target with the new solver alone in both check scripts, and set `Workspace.UseNewLuauTypeSolver` to `Enabled`, which Rojo writes as the token 2. |
| `bd9a42b` | Returned the instance from the thirteen constructors without a cast, and made `CAST_THROUGH_ANY` report every cast through `any`, with tests. |
| `0f4ab95` | Revised EE-STD-0001 and EE-STD-0006 to 2.0.0, reviewed EE-STD-0002, EE-STD-0003 and EE-STD-0005 against them, proposed ADR-0003, turned the fitness test to it, and pointed `AGENTS.md` and the README at the new state. |

Before the casts were committed, a method of `InMemoryCoinWalletRepository` was renamed in the real code, with its wrapper following it. The new solver reported the constructor, and the change was undone.
Without the casts, a fixture whose entries only name drifted methods still drew no error from the new solver, so the wrappers are kept. The new fixture of the generic loss draws five errors from the old solver, its witness, and none from the new.
The test that `CAST_THROUGH_ANY` reports the cast of a constructor first passed without the change it was meant to prove, because its fixture followed the cast with a second return. It was rewritten as a whole constructor, and failed until the check was changed.
`tools/check.sh` and `tools/check.ps1` both passed.

On 2026-11-01 the Approver of record opened in Roblox Studio the place built from `0f4ab95`, 54841 bytes.
`Workspace.UseNewLuauTypeSolver` read `Enabled`, the script analysis of the code showed no error and no warning, and in a play test the panel paid compliance coins as before.
This settles what CR-0023 left to this request: the editor of Studio accepts `Instance.new` with a class name typed as `string`.

| Commit | Change |
|---|---|
| `b9d3eab` | Marked this request as implemented. |
| `6d8de4a` | Recorded the approval of EE-STD-0001 and EE-STD-0006 at 2.0.0, of EE-STD-0002 at 1.0.2, of EE-STD-0003 at 1.1.1 and of EE-STD-0005 at 1.0.1, and the acceptance of ADR-0003 at 1.1.0; set ADR-0002 to `Superseded` at 1.2.0. |
