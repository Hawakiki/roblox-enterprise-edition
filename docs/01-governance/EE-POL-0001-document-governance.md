---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0001
title: Document Governance Policy
version: 0.9.0
status: In Review
classification: Internal
owner: Document Control Office
parent: EE-CHR-0001@0.9
---

# Document Governance Policy

## 1. Purpose

This policy establishes how the documents of the Company are identified, written, versioned, related to one another and registered.
It is the human-readable form of the document schema that checkpatch enforces.
Where this policy and `scripts/lib/Schema.luau` disagree, both are wrong, and a change request is required to make them agree.

## 2. Scope

1. This policy applies to every file under `docs/`.
2. It does not apply to files outside `docs/`, such as `README.md` or `LICENSE`, nor to the generated registry (§13).

## 3. Definitions

| Term | Definition |
|---|---|
| Document | A Markdown file under `docs/` that opens with a frontmatter block. |
| Controlled document | A document that forms part of the hierarchy and states rules: a charter, policy, standard, procedure, guideline or template. |
| Record | A document that records a request, a decision or an event. Records sit outside the hierarchy. |
| Kind | The category of a document, identified by a code such as `POL` or `CR`. |
| Authoritative version | The English version of a document. |
| Translation | The Korean version of a document. |
| Revision | The `MAJOR.MINOR` part of a version. |
| Registry | The generated list of every document, in `docs/REGISTRY.md` and `docs/REGISTRY.ko.md`. |

## 4. Document Kinds and Hierarchy

1. Controlled documents form a hierarchy. Level 1 is the highest.

| Level | Kind | Code | Identifier | Folder |
|---|---|---|---|---|
| 1 | Charter | `CHR` | `EE-CHR-NNNN` | `docs/00-charter/` |
| 2 | Policy | `POL` | `EE-POL-NNNN` | `docs/01-governance/` |
| 2 | Organization | `ORG` | `EE-ORG-NNNN` | `docs/02-organization/` |
| 3 | Standard | `STD` | `EE-STD-NNNN` | `docs/03-standards/` |
| 4 | Standard operating procedure | `SOP` | `EE-SOP-NNNN` | `docs/04-procedures/` |
| 4 | Operations | `OPS` | `EE-OPS-NNNN` | `docs/06-operations/` |
| 5 | Guideline | `GDL` | `EE-GDL-NNNN` | `docs/05-guidelines/` |
| 6 | Template | `TPL` | `EE-TPL-NNNN` | `docs/templates/` |

2. Records sit outside the hierarchy. Each kind of record has its own lifecycle (§10).

| Kind | Code | Identifier | Folder |
|---|---|---|---|
| Request for comments | `RFC` | `RFC-NNNN` | `docs/rfc/` |
| Architecture decision record | `ADR` | `ADR-NNNN` | `docs/adr/` |
| Change request | `CR` | `CR-NNNN` | `docs/records/change-requests/` |
| Approval request | `APR` | `APR-NNNN` | `docs/records/approval-requests/` |
| Statement of circumstances | `STM` | `STM-NNNN` | `docs/records/statements/` |
| Meeting minutes | `MIN` | `MIN-NNNN` | `docs/records/minutes/` |

3. A document whose identifier belongs to no kind in these tables is rejected (`UNKNOWN_DOCUMENT_TYPE`).
4. A document lives in the folder of its kind (`MISPLACED_DOCUMENT`).
   Only Markdown documents belong under `docs/` (`STRAY_FILE`).
5. A new kind is introduced by amending this policy and the schema in the same change request.

## 5. Identifiers

1. An identifier is the prefix of a kind followed by a four-digit number: `EE-<CODE>-NNNN` for controlled documents, `<CODE>-NNNN` for records.
2. Numbers are assigned in sequence within each kind. The next number is the highest registered number plus one.
3. An identifier is unique (`DUPLICATE_DOCUMENT_ID`) and is never reused, including after its document is superseded or deprecated.
4. Text that names a kind not registered in §4, such as `EE-XYZ-0001`, is not an identifier. Examples may rely on this.

## 6. File Names

1. The authoritative version is named `<identifier>-<slug>.md` and its translation `<identifier>-<slug>.ko.md`, in the same folder.
2. The slug consists of lowercase letters, digits and single hyphens, and starts with a letter or a digit (`FILENAME_MISMATCH`).
3. The slug summarizes the title in a few words. It does not change once registered, even when the title does.

## 7. Frontmatter

1. Every document opens with a YAML frontmatter block, which starts and ends with a line containing only `---` (`MISSING_FRONTMATTER`, `INVALID_FRONTMATTER`).
2. The frontmatter of the authoritative version carries the following fields and no others (`MISSING_FIELD`, `UNKNOWN_FIELD`).

| Field | Required | Value |
|---|---|---|
| `id` | Always | The identifier (§5). |
| `title` | Always | The title, in Title Case. |
| `version` | Always | `MAJOR.MINOR.PATCH` (§9). |
| `status` | Always | A status of the kind of the document (§10). |
| `classification` | Always | `Public`, `Internal`, `Confidential` or `Restricted` (§12). |
| `owner` | Always | The organizational unit responsible for the document. |
| `parent` | Controlled documents other than the Charter | `<identifier>@<MAJOR.MINOR>` (§11). |

3. Every value is a non-empty string.
   Values that YAML reads as numbers, such as `1.0`, are rejected (`INVALID_FIELD_VALUE`).
4. The frontmatter of a translation carries only `id`, `title` and `translation-of`, as set out in EE-POL-0002.
5. License information is written as YAML comments at the top of the block. Comments are not fields.

For example, a standard would open as follows.

```yaml
---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-NNNN
title: Example Standard
version: 1.2.0
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-POL-NNNN@1.0
---
```

## 8. Title and Body

1. The body opens with a level-one heading that repeats the title exactly (`TITLE_HEADING_MISMATCH`).
2. A controlled document closes with a Revision History and an Approval section, as laid out in EE-TPL-0001.
3. A document is written one sentence per line, so that every change to a sentence is a change to one line.

## 9. Versions

1. A version has the form `MAJOR.MINOR.PATCH`.
2. PATCH is incremented for an editorial change that does not change the meaning: spelling, formatting, wording.
3. MINOR is incremented for a change in meaning that keeps every existing obligation: a new provision, or a clarification that changes how a provision is read.
4. MAJOR is incremented for a change that removes or alters an existing obligation.
5. Every change to a document increments its version.
6. A controlled document in `Draft` or `In Review` is versioned `0.x.y`.
   A controlled document in any other status is versioned `1.0.0` or later (`VERSION_STATUS_MISMATCH`).

## 10. Status and Lifecycle

1. A controlled document moves through the following statuses.

| Status | Meaning |
|---|---|
| `Draft` | Being written. |
| `In Review` | Submitted for approval. |
| `Approved` | In effect. |
| `Superseded` | Replaced by a newer document, which names it. |
| `Deprecated` | Withdrawn without replacement. |

2. A record moves through the statuses of its kind.

| Kind | Statuses |
|---|---|
| `RFC` | `Draft`, `Discussion`, `Accepted`, `Rejected`, `Withdrawn` |
| `ADR` | `Proposed`, `Accepted`, `Superseded`, `Deprecated` |
| `CR` | `Draft`, `Submitted`, `Approved`, `Rejected`, `Implemented`, `Closed` |
| `APR` | `Draft`, `Submitted`, `Approved`, `Rejected`, `Withdrawn` |
| `STM` | `Draft`, `Submitted`, `Accepted`, `Returned` |
| `MIN` | `Draft`, `Approved` |

3. A status outside these lists is rejected (`INVALID_FIELD_VALUE`).
4. A document is approved by the Approver of record (EE-CHR-0001, Article 5).
   Approval is recorded three times: in the Approval section of the document, by its status, and by an `Approved-by` trailer on the merge commit that brings it into `develop`.

## 11. Hierarchy and Citation

1. Every controlled document other than the Charter cites exactly one parent in its `parent` field (`MISSING_PARENT`).
   The Charter and records cite none (`UNEXPECTED_PARENT`).
2. The parent exists (`UNKNOWN_PARENT`) and is a controlled document at the same or a higher level (`PARENT_HIERARCHY_VIOLATION`).
3. A citation names the revision of the parent that the child was written against, as in `parent: EE-POL-NNNN@1.0`.
4. When the revision of a parent changes, its citations no longer match, and every child is reported for review (`STALE_PARENT`).
   The child is reviewed against the new revision and its citation updated, which is itself a change to the child (§9).
   A PATCH change to a parent leaves its revision, and therefore its children, untouched.
5. A chain of parents never leads back to where it started (`PARENT_CYCLE`).

## 12. Classification

| Classification | Meaning |
|---|---|
| `Public` | May be shared outside the Company. |
| `Internal` | For employees of the Company. |
| `Confidential` | For named employees only. |
| `Restricted` | For the Board of Directors only. |

The repository is public.
Classification does not restrict who can read a document; it records how the Company feels about it.

## 13. References and the Registry

1. Every identifier of a registered kind that appears in a document refers to an existing document (`DANGLING_REFERENCE`).
2. The registry lists every document.
   It is generated by `scripts/gen_registry.luau` and never edited by hand.
   A registry that differs from the generated output is rejected (`REGISTRY_OUT_OF_DATE`).

## 14. Changes

1. Every change to a document is made through a change request, filed on the form in EE-TPL-0002 and cited by every commit that implements it.
2. Every rule that checkpatch enforces is cited by its code in both versions of the document that mandates it (`UNDOCUMENTED_RULE`).
   A rule cannot be released before it is documented.

## 15. Enforcement

checkpatch enforces this policy.
`lune run scripts/checkpatch --list-rules` lists every rule; Annex A lists the rules mandated by this policy.

## Annex A. Rules Enforced Under This Policy

| Rule | Severity | Section |
|---|---|---|
| `UNKNOWN_DOCUMENT_TYPE` | Error | §4 |
| `MISPLACED_DOCUMENT` | Error | §4 |
| `STRAY_FILE` | Warning | §4 |
| `DUPLICATE_DOCUMENT_ID` | Error | §5 |
| `FILENAME_MISMATCH` | Error | §6 |
| `MISSING_FRONTMATTER` | Error | §7 |
| `INVALID_FRONTMATTER` | Error | §7 |
| `MISSING_FIELD` | Error | §7 |
| `UNKNOWN_FIELD` | Error | §7 |
| `INVALID_FIELD_VALUE` | Error | §7, §10 |
| `TITLE_HEADING_MISMATCH` | Error | §8 |
| `VERSION_STATUS_MISMATCH` | Error | §9 |
| `MISSING_PARENT` | Error | §11 |
| `UNEXPECTED_PARENT` | Error | §11 |
| `UNKNOWN_PARENT` | Error | §11 |
| `PARENT_HIERARCHY_VIOLATION` | Error | §11 |
| `STALE_PARENT` | Error | §11 |
| `PARENT_CYCLE` | Error | §11 |
| `DANGLING_REFERENCE` | Error | §13 |
| `REGISTRY_OUT_OF_DATE` | Error | §13 |
| `UNDOCUMENTED_RULE` | Error | §14 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |
