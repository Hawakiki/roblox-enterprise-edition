<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->
<!-- GENERATED FILE. DO NOT EDIT. Regenerate with: lune run scripts/gen_registry -->

# Document Registry

Every controlled document and record of EnterpriseEdition, generated from document frontmatter by `scripts/gen_registry.luau`.
Editing this file by hand violates EE-POL-0001, and checkpatch will notice.

[한국어](REGISTRY.ko.md)

## Summary

| Category | Documents |
|---|---:|
| Charter | 1 |
| Policies | 2 |
| Templates | 7 |
| Change Requests | 3 |
| **Total** | **13** |

## Charter

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-CHR-0001](00-charter/EE-CHR-0001-charter.md) | Charter of EnterpriseEdition | 1.0.0 | Approved | Public | Board of Directors | — |

## Policies

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-POL-0001](01-governance/EE-POL-0001-document-governance.md) | Document Governance Policy | 1.0.0 | Approved | Internal | Document Control Office | EE-CHR-0001@1.0 |
| [EE-POL-0002](01-governance/EE-POL-0002-bilingual-documentation.md) | Bilingual Documentation Policy | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |

## Templates

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-TPL-0001](templates/EE-TPL-0001-controlled-document.md) | Controlled Document Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0002](templates/EE-TPL-0002-change-request.md) | Change Request Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0003](templates/EE-TPL-0003-request-for-comments.md) | Request for Comments Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0004](templates/EE-TPL-0004-architecture-decision-record.md) | Architecture Decision Record Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0005](templates/EE-TPL-0005-approval-request.md) | Approval Request Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0006](templates/EE-TPL-0006-statement-of-circumstances.md) | Statement of Circumstances Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |
| [EE-TPL-0007](templates/EE-TPL-0007-meeting-minutes.md) | Meeting Minutes Template | 1.0.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.0 |

## Change Requests

| ID | Title | Version | Status | Classification | Owner |
|---|---|---|---|---|---|
| [CR-0001](records/change-requests/CR-0001-compliance-tooling.md) | Establish the Change Request Process and Compliance Tooling | 1.1.0 | Implemented | Internal | Compliance Engineering |
| [CR-0002](records/change-requests/CR-0002-stray-luaurc.md) | Remove the Stray Root .luaurc | 1.1.0 | Implemented | Internal | Compliance Engineering |
| [CR-0003](records/change-requests/CR-0003-document-governance.md) | Establish the Charter, the Document Governance Policies and the Templates | 1.0.0 | Approved | Internal | Document Control Office |
