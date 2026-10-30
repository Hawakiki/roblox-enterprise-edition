---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0004
title: File Header Standard
version: 1.0.0
status: Approved
classification: Internal
owner: Legal Department
parent: EE-CHR-0001@1.0
---

# File Header Standard

## 1. Purpose

Every file states, in its first lines, the license under which it is distributed and who holds its copyright, so that it can be understood on its own when copied out of the repository.
The format is that of SPDX, as used by the Linux kernel and by the REUSE specification.

## 2. Scope

This standard applies to every text file in the repository.

## 3. Header

1. Every file carries the following two lines, in the comment syntax of the file, within its first ten lines (`MISSING_SPDX_HEADER`).

```text
SPDX-License-Identifier: MIT
SPDX-FileCopyrightText: <year> Hawakiki and EnterpriseEdition contributors
```

2. The year is the year in which the file was created. It is not updated afterwards.
3. The license is MIT, as in `LICENSE`. A file under any other license does not belong in the repository.

## 4. Placement

| File | Form |
|---|---|
| Luau | `--` comments on the first lines, before `--!strict` |
| Shell scripts | `#` comments after the shebang line |
| PowerShell scripts | `#` comments after the byte order mark |
| TOML, `.gitignore`, `.gitattributes`, `.editorconfig` | `#` comments on the first lines |
| Documents under `docs/` | YAML comments inside the frontmatter block (EE-POL-0001 §7) |
| Other Markdown | HTML comments on the first lines |

## 5. Exemptions

1. JSON files, including `.luaurc`, carry no header, because JSON has no comment syntax. `LICENSE` covers them.
2. `LICENSE` carries no header, because it is the license.
3. Binary files carry no header.

## 6. Module Header

Below its file header, a Luau module carries a header comment in both languages (EE-STD-0001 §6).

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `MISSING_SPDX_HEADER` | Error | §3 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Legal Department |
| 1.0.0 | 2026-10-30 | Approved. | Legal Department |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Legal Department | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
