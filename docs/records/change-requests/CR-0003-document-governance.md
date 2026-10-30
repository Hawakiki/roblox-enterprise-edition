---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0003
title: Establish the Charter, the Document Governance Policies and the Templates
version: 1.0.0
status: Approved
classification: Internal
owner: Document Control Office
---

# Establish the Charter, the Document Governance Policies and the Templates

## 1. Summary

CR-0001 built the machinery that enforces the rules for documents.
This change request writes the rules down, so that the machinery has something to enforce on behalf of.

## 2. Background

The document schema currently exists only as code in `scripts/lib/Schema.luau`.
Code is not a controlled document, and rules that are not written in a controlled document are not rules.
Until this change is approved, the Company is therefore enforcing rules that do not exist.

## 3. Scope

- The Charter, the root of the document hierarchy.
- The Document Governance Policy: kinds, identifiers, frontmatter, versions, the hierarchy, references and the registry.
- The Bilingual Documentation Policy: authoritative versions and translation requirements.
- Seven templates: controlled documents, change requests, requests for comments, architecture decision records, approval requests, statements of circumstances and meeting minutes.
- Three new record kinds, so that the last three templates can be used: approval requests, statements of circumstances and meeting minutes.
- A new checkpatch rule, `UNDOCUMENTED_RULE`: a rule must be cited by the document that mandates it, once that document exists.

### Scope note

The original plan for this step covered the governance policy and the templates only.
The Charter and the Bilingual Documentation Policy were brought forward, because the governance policy cannot cite a parent that does not exist, and cannot be complete without the translation rules.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. |
| Rules | Unchanged. They become official. |
| Documents | Ten controlled documents in two languages, submitted for review. |
| Tooling | Every future rule must be documented before it can be released. |

## 5. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
