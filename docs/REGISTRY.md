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
| Policies | 8 |
| Standards | 9 |
| Templates | 7 |
| Architecture Decision Records | 1 |
| Change Requests | 20 |
| **Total** | **46** |

## Charter

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-CHR-0001](00-charter/EE-CHR-0001-charter.md) | Charter of EnterpriseEdition | 1.0.0 | Approved | Public | Board of Directors | — |

## Policies

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-POL-0001](01-governance/EE-POL-0001-document-governance.md) | Document Governance Policy | 1.1.0 | Approved | Internal | Document Control Office | EE-CHR-0001@1.0 |
| [EE-POL-0002](01-governance/EE-POL-0002-bilingual-documentation.md) | Bilingual Documentation Policy | 1.1.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-POL-0003](01-governance/EE-POL-0003-delegation-of-authority.md) | Delegation of Authority | 0.1.0 | Draft | Internal | Board of Directors | EE-CHR-0001@1.0 |
| [EE-POL-0004](01-governance/EE-POL-0004-change-management.md) | Change Management Policy | 1.1.0 | Approved | Internal | Change Advisory Board | EE-CHR-0001@1.0 |
| [EE-POL-0005](01-governance/EE-POL-0005-information-classification.md) | Information Classification Policy | 0.1.0 | Draft | Internal | Information Security Office | EE-CHR-0001@1.0 |
| [EE-POL-0006](01-governance/EE-POL-0006-ai-workforce.md) | AI Workforce Policy | 1.1.0 | Approved | Internal | Human Resources | EE-CHR-0001@1.0 |
| [EE-POL-0007](01-governance/EE-POL-0007-deprecation.md) | Deprecation Policy | 0.1.0 | Draft | Internal | Release Engineering | EE-CHR-0001@1.0 |
| [EE-POL-0008](01-governance/EE-POL-0008-external-data-and-ai-training.md) | External Data and AI Training Policy | 1.0.0 | Approved | Internal | Legal Department | EE-CHR-0001@1.0 |

## Standards

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-STD-0001](03-standards/EE-STD-0001-luau-coding.md) | Luau Coding Standard | 1.1.0 | Approved | Internal | Architecture Review Board | EE-CHR-0001@1.0 |
| [EE-STD-0002](03-standards/EE-STD-0002-naming.md) | Naming Convention | 1.0.1 | Approved | Internal | Architecture Review Board | EE-STD-0001@1.1 |
| [EE-STD-0003](03-standards/EE-STD-0003-prohibited-apis.md) | Prohibited API Registry | 1.0.0 | Approved | Internal | Architecture Review Board | EE-STD-0001@1.1 |
| [EE-STD-0004](03-standards/EE-STD-0004-file-headers.md) | File Header Standard | 1.0.0 | Approved | Internal | Legal Department | EE-CHR-0001@1.0 |
| [EE-STD-0005](03-standards/EE-STD-0005-numeric-literals.md) | Numeric Literal Standard | 1.0.0 | Approved | Internal | Architecture Review Board | EE-STD-0001@1.1 |
| [EE-STD-0006](03-standards/EE-STD-0006-architecture-layers.md) | Layered Architecture Standard | 1.0.1 | Approved | Internal | Architecture Review Board | EE-STD-0001@1.1 |
| [EE-STD-0007](03-standards/EE-STD-0007-commits-and-branches.md) | Commit and Branch Standard | 1.0.1 | Approved | Internal | Compliance Engineering | EE-POL-0004@1.1 |
| [EE-STD-0008](03-standards/EE-STD-0008-versioning.md) | Enterprise Versioning Standard | 1.1.0 | Approved | Internal | Release Engineering | EE-POL-0004@1.1 |
| [EE-STD-0009](03-standards/EE-STD-0009-text-and-documentation.md) | Text File and Documentation Standard | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |

## Templates

| ID | Title | Version | Status | Classification | Owner | Parent |
|---|---|---|---|---|---|---|
| [EE-TPL-0001](templates/EE-TPL-0001-controlled-document.md) | Controlled Document Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0002](templates/EE-TPL-0002-change-request.md) | Change Request Template | 1.1.0 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0003](templates/EE-TPL-0003-request-for-comments.md) | Request for Comments Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0004](templates/EE-TPL-0004-architecture-decision-record.md) | Architecture Decision Record Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0005](templates/EE-TPL-0005-approval-request.md) | Approval Request Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0006](templates/EE-TPL-0006-statement-of-circumstances.md) | Statement of Circumstances Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |
| [EE-TPL-0007](templates/EE-TPL-0007-meeting-minutes.md) | Meeting Minutes Template | 1.0.1 | Approved | Internal | Document Control Office | EE-POL-0001@1.1 |

## Architecture Decision Records

| ID | Title | Version | Status | Classification | Owner |
|---|---|---|---|---|---|
| [ADR-0001](adr/ADR-0001-constructors-return-their-contract.md) | Constructors Return Their Contract, Cast Through Any | 1.1.0 | Accepted | Internal | Architecture Review Board |

## Change Requests

| ID | Title | Version | Status | Classification | Owner |
|---|---|---|---|---|---|
| [CR-0001](records/change-requests/CR-0001-compliance-tooling.md) | Establish the Change Request Process and Compliance Tooling | 1.1.0 | Implemented | Internal | Compliance Engineering |
| [CR-0002](records/change-requests/CR-0002-stray-luaurc.md) | Remove the Stray Root .luaurc | 1.2.0 | Implemented | Internal | Compliance Engineering |
| [CR-0003](records/change-requests/CR-0003-document-governance.md) | Establish the Charter, the Document Governance Policies and the Templates | 1.2.0 | Implemented | Internal | Document Control Office |
| [CR-0004](records/change-requests/CR-0004-engineering-standards.md) | Establish the Change Management Policy and the Engineering Standards | 1.2.0 | Implemented | Internal | Compliance Engineering |
| [CR-0005](records/change-requests/CR-0005-ai-onboarding.md) | Onboard the AI Workforce | 1.2.0 | Implemented | Internal | Human Resources |
| [CR-0006](records/change-requests/CR-0006-drill-findings.md) | Correct the Findings of the First Onboarding Drill | 1.1.0 | Implemented | Internal | Document Control Office |
| [CR-0007](records/change-requests/CR-0007-application-framework.md) | Establish the Application Framework | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0008](records/change-requests/CR-0008-law-of-the-code.md) | Lay Down the Law of the Roblox Code | 1.3.0 | Implemented | Internal | Architecture Review Board |
| [CR-0009](records/change-requests/CR-0009-first-assignment-findings.md) | Correct the Findings of the First Assignment | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0010](records/change-requests/CR-0010-presentation-framework.md) | Build the Presentation Framework | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0011](records/change-requests/CR-0011-compliance-coins.md) | Reward Policy Acknowledgement with Compliance Coins | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0012](records/change-requests/CR-0012-datastore-wallets.md) | Keep Compliance Coins in a DataStore under a Session Lock | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0013](records/change-requests/CR-0013-publication.md) | Prepare the Company for Publication | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0014](records/change-requests/CR-0014-release-1-0-0.md) | Release EnterpriseEdition 1.0.0 | 1.2.0 | Implemented | Internal | Architecture Review Board |
| [CR-0015](records/change-requests/CR-0015-ci-hardening.md) | Harden the Continuous Integration | 1.2.0 | Implemented | Internal | Release Engineering |
| [CR-0016](records/change-requests/CR-0016-release-engineering.md) | Number, Gate and Publish Releases | 1.2.0 | Implemented | Internal | Release Engineering |
| [CR-0017](records/change-requests/CR-0017-release-1-1-0.md) | Release EnterpriseEdition 1.1.0 | 1.2.0 | Implemented | Internal | Release Engineering |
| [CR-0018](records/change-requests/CR-0018-code-review-findings.md) | Correct the Findings of the First Code Review | 1.1.0 | Implemented | Internal | Architecture Review Board |
| [CR-0019](records/change-requests/CR-0019-contract-decision-record.md) | Record the Contract Pattern as the First Architecture Decision | 1.2.0 | Implemented | Internal | Architecture Review Board |
| [CR-0020](records/change-requests/CR-0020-adr-0001-fitness-test.md) | Test the Facts That ADR-0001 Rests On | 1.1.0 | Implemented | Internal | Architecture Review Board |
