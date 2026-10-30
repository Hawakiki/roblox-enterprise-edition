---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0009
title: Text File and Documentation Standard
version: 1.0.0
status: Approved
classification: Internal
owner: Document Control Office
parent: EE-POL-0001@1.0
---

# Text File and Documentation Standard

## 1. Purpose

This standard keeps every text file readable on every platform, and every document written in the same way.

## 2. Scope

1. Section 3 applies to every text file in the repository.
2. Section 4 applies to the documents under `docs/`.

## 3. Text Files

1. Text files are encoded in UTF-8 (`INVALID_UTF8`).
2. Text files do not start with a byte order mark (`UTF8_BOM`).
   PowerShell scripts that contain non-ASCII text are the exception: they must start with one, because Windows PowerShell 5.1 reads files without it in the ANSI code page (`MISSING_UTF8_BOM`).
3. Lines end with LF (`CRLF_LINE_ENDING`).
   This is enforced three times: by `.gitattributes`, which overrides `core.autocrlf`; by `.editorconfig`, for editors; and by checkpatch, for whatever slips past both.
4. Lines do not end with whitespace (`TRAILING_WHITESPACE`).
   Markdown line breaks made of two trailing spaces are therefore unavailable; a new line is a new sentence (§4).
5. Files end with a newline (`MISSING_FINAL_NEWLINE`).
6. Binary files, recognized by their extension or by a NUL byte, are exempt from this section.

## 4. Documents

1. One sentence is written per line (EE-POL-0001 §8).
2. English is plain and active. Korean is written in the written style, with sentences ending in the plain declarative form.
3. Sections are numbered and annexes are lettered.
4. Structured information goes into tables rather than prose.
5. Dates are written `YYYY-MM-DD`. A table cell that does not apply holds an em dash.
6. Placeholders in templates are written in angle brackets.
7. Terms follow the terminology of EE-POL-0002 §6.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `INVALID_UTF8` | Error | §3 |
| `UTF8_BOM` | Error | §3 |
| `MISSING_UTF8_BOM` | Error | §3 |
| `CRLF_LINE_ENDING` | Error | §3 |
| `TRAILING_WHITESPACE` | Error | §3 |
| `MISSING_FINAL_NEWLINE` | Error | §3 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Document Control Office |
| 1.0.0 | 2026-10-30 | Approved. | Document Control Office |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Document Control Office | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
