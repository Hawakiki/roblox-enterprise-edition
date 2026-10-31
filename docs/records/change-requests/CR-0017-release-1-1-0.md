---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0017
title: Release EnterpriseEdition 1.1.0
version: 1.2.0
status: Implemented
classification: Internal
owner: Release Engineering
---

# Release EnterpriseEdition 1.1.0

## 1. Summary

This change request releases EnterpriseEdition 1.1.0, the first release made under EE-STD-0008 and the first deployed by the release workflow.
It brings CR-0015, which makes every check fail when it cannot run, and CR-0016, which numbers, gates and publishes releases and keeps the calendar of deployments.
Preparing it showed that its notes would have listed CR-0014, already released in 1.0.0, a second time. A change request now belongs to the first release that cites it.
The notes of 1.0.0, which were never written, are generated and published with it.

## 2. Background

CR-0015 and CR-0016 have been approved into `develop` since 1.0.0.
Together they add a standard, a workflow, a calendar, and checks that fail when they cannot run. They alter no contract, service token, remote, stored schema or obligation of an approved document that 1.0.0 shipped.
The release is therefore numbered 1.1.0 (EE-STD-0008 §4.3).

Before this request was filed, the change requests cited since `v1.0.0` were listed.
The merge of `release/1.0.0` back into `develop` (`df3a4ea`) cites CR-0014, and lies after `v1.0.0`.
EE-STD-0008 §5.3, as approved, lists every change request cited by a commit since the previous release tag. It would have released CR-0014 twice.

CR-0016 left the publication of the notes of 1.0.0 to the release request that follows it.

## 3. Scope

- `release/1.1.0`, taken from `develop` (EE-POL-0004 §5).
- `scripts/lib/ReleaseNotes.luau` and `scripts/release_notes.luau`: a change request that the history of an earlier release cites is left out of the notes, with a test.
- EE-STD-0008 §5.3, revised to say so, `In Review` at 1.1.0.
- `AGENTS.md`: the mine.
- A rehearsal in a new clone, never pushed: the release merged and tagged there, every check run, the notes of 1.1.0 generated and the place built.
- After approval, outside a change freeze:
  - The notes of 1.0.0 generated, the place of 1.0.0 built from its tag, and both published as the GitHub release of `v1.0.0`. This comes first, so that 1.1.0 is the latest release.
  - `release/1.1.0` merged into `main` with `--no-ff`, the merge commit tagged `v1.1.0`, and `release/1.1.0` merged back into `develop`.
- Pushing `main`, `develop` and the tag, and approving the deployment in the environment `production`, are left to the Approver of record.
  The request that follows records how the workflow deployed 1.1.0.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| `main` | Moves from 1.0.0 to 1.1.0, by way of one merge commit. |
| Releases | 1.0.0 gains its notes and its place on GitHub. 1.1.0 is the first release deployed by the workflow. |
| Dependabot | Reads its configuration from `main`, and starts. |
| Documentation volume | One sentence of one standard revised. Nothing added. |

## 5. Rollback Plan

Delete the GitHub releases of `v1.1.0` and `v1.0.0`, and revert the merge commits on `main` and on `develop`.
The tags stay, as the ruleset requires. A correction is released as 1.1.1 (EE-STD-0008 §4.6).

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Release Engineering | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `3781e59` | Filed this change request on `release/1.1.0`. |
| `4cc1f31` | Left out of the notes every change request that the history of the previous release cites, with a test; revised EE-STD-0008 §5.3, `In Review` at 1.1.0; recorded the mine in `AGENTS.md`. |

Before this request was marked as implemented, the release was rehearsed in a new clone, which was never pushed.
There, `release/1.1.0` was merged into `main` and the merge commit tagged `v1.1.0`, and the tag was checked out detached, as the workflow checks it out.
`tools/check.sh` passed, with the Roblox definitions downloaded afresh, and `rojo build` built the place.
The notes of 1.1.0 listed CR-0015, CR-0016 and CR-0017, and those of 1.0.0 listed CR-0001 to CR-0014.
The calendar refused a deployment, for it was Friday somewhere on Earth until 2026-10-31T12:00:00Z.

| Commit | Change |
|---|---|
| `f5c8818` | Marked this request as implemented. |
| `e5331cb` | Recorded the approval of EE-STD-0008 1.1.0. |

On approval of the merge, the calendar admitted a deployment at 2026-10-31T12:03:13Z.
The notes of 1.0.0, fourteen change requests from CR-0001 to CR-0014, and the place built from the tag `v1.0.0`, 52175 bytes, were published as the GitHub release of `v1.0.0` at 2026-10-31T12:03:37Z, by `gh release create`, which made it the latest release.
It is the first deployment the calendar admitted, and it came before 1.1.0, as this request required.
