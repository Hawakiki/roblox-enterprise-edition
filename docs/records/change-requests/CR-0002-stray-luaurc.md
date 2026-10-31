---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0002
title: Remove the Stray Root .luaurc
version: 1.2.0
status: Implemented
classification: Internal
owner: Compliance Engineering
---

# Remove the Stray Root .luaurc

## 1. Summary

Remove the `.luaurc` that was committed to the repository root by mistake, and keep it from coming back.

## 2. Background

`lune setup` writes a `.luaurc` with the `@lune` alias into the directory it runs in.
It ran in the repository root while CR-0001 was being implemented, and `git add -A` committed the result in `dfe02c9` without review.
The file then reached `develop` with the merge of CR-0001.

The intended configuration already lives in `scripts/.luaurc`, which checkpatch keeps in step with `rokit.toml`.
The root copy is checked by nothing, and once Roblox code is added it would apply Lune aliases to code that never runs under Lune.

## 3. Scope

- Delete `/.luaurc` from the repository.
- Ignore `/.luaurc` in `.gitignore`, because `tools/check` runs `lune setup` and will write it again.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. |
| Type checking of `scripts/` | None. `scripts/.luaurc` carries the same alias. |
| Process | The first corrective change request, filed on the day the process was introduced. |

## 5. Root Cause and Corrective Action

| Item | Description |
|---|---|
| Root cause | Staged files were not reviewed before committing. |
| Corrective action | Review `git status` before every commit, and ignore files that tools generate. |

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Compliance Engineering | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
| Implementer | Compliance Engineering | Implemented | 2026-10-30 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `983adee` | Filed this change request. |
| `d681c4b` | Deleted the root `.luaurc` and added it to `.gitignore`. |

## Rollback Plan

Added retroactively by CR-0006, because this request was filed without the section that its form requires.
Revert merge commit `c90a1bc`. The stray `.luaurc` would return to the repository, and with it the reason for this request.
