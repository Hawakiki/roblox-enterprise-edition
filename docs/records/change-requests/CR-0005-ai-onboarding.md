---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0005
title: Onboard the AI Workforce
version: 1.1.0
status: Implemented
classification: Internal
owner: Human Resources
---

# Onboard the AI Workforce

## 1. Summary

Most of the work in the repository is done by AI agents, and every one of them starts every session with no memory of the last.
This change request gives them an entrance: a short file that every agent reads first, settings that stop the actions they must never take, and policies that state their place in the Company.

## 2. Background

The Company has 25 documents, and their number will grow.
An agent that reads all of them before every task does nothing else; an agent that reads none of them breaks the rules on its first commit.
The entrance therefore routes rather than restates: it tells the agent which document governs the task at hand, and leaves the rules to the documents and to checkpatch.

Instructions given to an agent are context, not enforcement.
The actions that must never happen without a person, such as approving and merging, are therefore also blocked in the configuration of the tools, not only forbidden in prose.

## 3. Scope

- The AI Workforce Policy: the status of agents, vendor neutrality, the entrance files and the guardrails.
- The External Data and AI Training Policy: what may enter the repository, and the Company's position on what leaves it.
- Reserved numbers for the two policies in between, as placeholders in `Draft`.
- `AGENTS.md`, the entrance shared by every agent, and `CLAUDE.md`, which imports it and adds what is specific to Claude Code.
- `.claude/settings.json` and `.codex/config.toml`, which apply the guardrails in each tool.
- Three new rules: the entrance files cite only existing documents, `CLAUDE.md` imports `AGENTS.md`, and the entrance stays short.

### Numbering note

The plan for this step called this request the sixth.
Change requests are numbered in sequence (EE-POL-0001 §5), so it is the fifth, and the request for the root files becomes the sixth.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Output delivery | None. |
| AI agents | Productive from their first minute, within limits they cannot talk their way past. |
| Merges | Every merge now asks a person first, in the tool itself. |
| Documentation volume | Increases by four documents in two languages and two entrance files. |

## 5. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Human Resources | Submitted | 2026-10-30 |
| Approver | Hawakiki | Approved | 2026-10-30 |
| Implementer | Human Resources | Implemented | 2026-10-30 |

## 6. Implementation Record

| Commit | Change |
|---|---|
| `d009a3d` | Filed this change request. |
| `00ad282` | Added `DANGLING_ENTRY_REFERENCE`, `MISSING_AGENTS_IMPORT` and `ONBOARDING_TOO_LONG`. |
| `405e01c` | Submitted EE-POL-0006 and EE-POL-0008 for review, and reserved EE-POL-0005 and EE-POL-0007. |
| `3cadfc7` | Added `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json` and `.codex/config.toml`. |
| `1aebfef` | Approved EE-POL-0006 and EE-POL-0008 at 1.0.0. |
