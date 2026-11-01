---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-STD-0005
title: Numeric Literal Standard
version: 1.0.1
status: Approved
classification: Internal
owner: Architecture Review Board
parent: EE-STD-0001@2.0
---

# Numeric Literal Standard

## 1. Purpose

This standard sets where numeric literals may appear in the Roblox code, which is almost nowhere, and where its colours come from, which is one place.

## 2. Scope

1. This standard applies to every Luau file under `src/`, the composition roots included.
2. The tooling under `scripts/` is not governed by it.

## 3. Definitions

| Term | Definition |
|---|---|
| Numeric literal | A number written in the source, such as `3`, `0.5`, `0xFF` or `1e3`. A minus sign before it is an operator, not part of the literal. |
| Constants module | A module whose name ends with `Constants` (EE-STD-0002 §3). |
| Corporate colour palette | The Constants module that holds the colours of the Company, `src/Shared/Kernel/CorporatePaletteConstants.luau`. |

## 4. Numeric Literals

1. A numeric literal appears only in a Constants module (`NUMERIC_LITERAL`).
2. The literals `0`, `1` and `2` may appear anywhere, and so may `-1`, the unary minus applied to `1`.
   This is the default ignore list of the MagicNumber check of Checkstyle, the industry standard, which the Company adopts rather than discriminate between numbers on its own authority.
3. The exemption is by spelling.
   Luau has a single type of number, so whether a literal is one of the exempt integers is a matter of how it is written: `2.0`, `0x1`, `1e0`, `-2` and `-0` are not exempt (`NUMERIC_LITERAL`).
4. A Constants module lives in the layer that owns the meaning of its values, as `ErrorLevelConstants` lives in the Kernel, whose functions raise the errors whose levels it names.
   This provision is not enforced, and is therefore a recommendation (EE-CHR-0001, Article 4).
5. The name of a constant that has a unit should end with it, as in `RETRY_DELAY_SECONDS` or `BORDER_PIXELS`.
   This is a recommendation, not a rule.

## 5. Colours

1. Every colour under `src/` comes from the corporate colour palette (`COLOR_OUTSIDE_PALETTE`).
   Without this provision, `Color3.new(1, 0, 0)` would pass §4 on three exempt literals, and `Color3.fromHex("#FF0000")` on none.
2. The palette is the only module that names a member of `Color3` or `BrickColor`, whose members make colours, as `Color3.new`, `Color3.fromRGB`, `Color3.fromHSV`, `Color3.fromHex` and `BrickColor.new` do (`COLOR_OUTSIDE_PALETTE`).
   `Color3` may still be named as a type, and a colour derived from a palette colour, as by `Lerp`, is still a palette colour.
3. The palette lives in the Kernel, because every layer that draws may require the Kernel, and the Domain, which knows nothing of Roblox, draws nothing (EE-STD-0006 §4).
4. A colour enters the palette through a change request that adds it to the palette module.
5. The place itself is written by Rojo from `default.project.json`, which cannot require a module.
   A colour of the place, such as the grey of the Baseplate, is stated there and again in the palette.

## 6. Enforcement

checkpatch enforces §4.1 to §4.3, §5.1 and §5.2.
Annex A lists the rules mandated by this standard.

## Annex A. Rules Enforced Under This Standard

| Rule | Severity | Section |
|---|---|---|
| `NUMERIC_LITERAL` | Error | §4 |
| `COLOR_OUTSIDE_PALETTE` | Error | §5 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1.0 | 2026-10-30 | Number reserved. | Architecture Review Board |
| 0.9.0 | 2026-10-30 | Drafted with the law of the Roblox code, as relaxed during its drafting (CR-0008). | Architecture Review Board |
| 1.0.0 | 2026-10-30 | Approved. | Architecture Review Board |
| 1.0.1 | 2026-11-01 | Reviewed against EE-STD-0001 2.0; citation updated (CR-0025). | Architecture Review Board |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Architecture Review Board | Submitted | 2026-11-01 |
| Approver | Hawakiki | Approved | 2026-11-01 |
