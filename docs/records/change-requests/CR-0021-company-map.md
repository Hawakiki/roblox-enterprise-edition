---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0021
title: Draw the Map of the Company
version: 1.0.0
status: Approved
classification: Internal
owner: Document Control Office
---

# Draw the Map of the Company

## 1. Summary

The Company has nine departments and one person, and no chart of either.
This change request writes its organization chart and its delegation of authority, which says who approves what.
It also draws the chart and the lineage of the documents as images, generated from the documents themselves, so that neither can fall out of date.

## 2. Background

Nine organizational units own the documents of the Company, as their `owner` fields say, but no document says what the units are, whom they report to, or who holds them.
EE-POL-0003, the Delegation of Authority, was reserved to be drafted together with the organization chart.
EE-POL-0001 §4 already registers the kind of document that holds an organization chart, in `docs/02-organization/`, and no document of that kind has been written.

Every controlled document cites its parent, and the registry lists each citation in a column, but nothing draws the tree they form.
A diagram in Mermaid would be drawn by whatever renders the Markdown, and not every renderer does.
The Approver of record chose images instead: SVG, drawn by the Company's own tooling, readable wherever an image is.

`docs/` holds only Markdown documents (`STRAY_FILE`), and the placement table of EE-STD-0004 has no row for SVG.

## 3. Scope

- The first organization document, in `docs/02-organization/`, `In Review`: the units of the Company, whom each reports to, and who holds each, in a table that the tooling reads.
- EE-POL-0003, the Delegation of Authority, written on its reserved number, `In Review`: which position approves which decision, and that the Approver of record holds every position until another person does.
- `scripts/lib/`: a renderer that draws a tree as SVG, laid out left to right, with the width of wide characters counted as EE-STD-0007 counts it, and tests.
- `scripts/gen_registry.luau` and `scripts/lib/Registry.luau`: the registry draws the lineage of the controlled documents and the organization chart, in English and in Korean, into `diagrams/`, and shows the lineage, with a text version beside it.
  `REGISTRY_OUT_OF_DATE` holds the images to the generated output as it holds the registry (EE-POL-0001 §13.2).
- EE-STD-0004, revised `In Review`: a row of its placement table for SVG files, whose header is an XML comment.
- `AGENTS.md`: where to look before deciding who approves something.

No policy, standard, procedure, form, record kind or document rule is added.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Governance | Every decision keeps its approver; the delegation names the positions behind the one person. |
| Registry | Shows the lineage of the documents as an image, with a text version. |
| Repository | A new folder, `diagrams/`, of generated images. |
| Documentation volume | One organization document and one policy, written; one standard, revised by a row. |

## 5. Rollback Plan

Revert the merge commit of this change. The units go back to being names in `owner` fields, and EE-POL-0003 to its reservation.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Document Control Office | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
