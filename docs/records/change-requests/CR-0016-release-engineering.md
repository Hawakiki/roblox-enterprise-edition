---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0016
title: Number, Gate and Publish Releases
version: 1.1.0
status: Implemented
classification: Internal
owner: Release Engineering
---

# Number, Gate and Publish Releases

## 1. Summary

Releases of the Company now follow a standard and a workflow.
EE-STD-0008, written late, sets how a release is numbered, prepared, tagged, published and timed.
Pushing a tag runs a workflow: it consults the calendar, runs every check, builds the place and generates the notes from the change requests released. It publishes the release on GitHub once the Approver of record approves.

## 2. Background

The reservation of EE-STD-0008 said that the standard would be written with the first release.
1.0.0 was released without it (CR-0014). As it turned out, it was also released while it was still Friday in parts of the Pacific.

The Company has no continuous delivery: a release is a tag, and nothing more. Its notes have never been written.

EE-POL-0003, the Delegation of Authority, was reserved to be written with the organization chart, which the Approver of record has set aside.
It stays reserved. The approval of a deployment rests on the documents that already say who approves: EE-POL-0004 §7 and EE-POL-0006 §4.

The Approver of record decided two change freezes:

- No deployment while it is Friday anywhere on Earth.
- No deployment while it is 19 January 2038 anywhere on Earth, the day a signed 32-bit count of seconds overflows.

## 3. Scope

- EE-STD-0008, the Enterprise Versioning Standard, drafted on its reserved number.
- `scripts/lib/ReleaseCalendar.luau` and `scripts/release_gate.luau`, which refuse a deployment during a freeze, with tests that reach 2038 and 2106.
- `scripts/lib/ReleaseNotes.luau` and `scripts/release_notes.luau`, which generate the notes of a release from the change requests that its commits cite, with tests.
- `.github/workflows/release.yml`, run by a tag `v*`, in three jobs:
  - the calendar;
  - every check, the place and the notes;
  - the publication, in the environment `production`.
- `.github/environments/production.json`, the environment as a file. It requires the review of the Approver of record, and admits only tags `v*`. It is applied with `gh api` once the merge of this request is approved.
- The notes of 1.0.0, generated and published as its GitHub release, outside a freeze, once the merge is approved.
- `README.md`, `README.ko.md` and `AGENTS.md`: how to release, and where to look.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Releases | A tag is published only after every check passes and the Approver of record approves. |
| Calendar | About 50 hours of every week, and the 50 hours around 19 January 2038, admit no deployment. |
| Notes | Written by no one, from the records the Company already keeps. |
| Documentation volume | One reserved standard is written. Nothing is added. |

## 5. Rollback Plan

Revert the merge commit of this change, delete the environment `production` with `gh api`, and delete any GitHub release it published.
Tags stay, as the ruleset requires.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Release Engineering | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `27c29b7` | Filed this change request. |
| `aefdc8b` | Added the calendar of deployments and its gate, with tests past 2038 and 2106, and the generator of release notes, with tests. |
| `0b6a3a9` | Added the release workflow, and kept the environment `production` as files. |
| `86e1e72` | Wrote EE-STD-0008 and submitted it for review. |
| `183ff5b` | Described releasing in both READMEs, and pointed `AGENTS.md` at EE-STD-0008 with three new mines. |

Before this request was marked as implemented, the workflow was read back as YAML, the place was built with `rojo build`, and the notes of 1.0.0 were generated: fourteen change requests, CR-0001 to CR-0014.
`scripts/release_gate` refused a deployment at the time, for it was Friday somewhere on Earth until 2026-10-31T12:00:00Z.
