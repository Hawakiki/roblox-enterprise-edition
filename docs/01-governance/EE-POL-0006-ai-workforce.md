---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: EE-POL-0006
title: AI Workforce Policy
version: 1.1.0
status: In Review
classification: Internal
owner: Human Resources
parent: EE-CHR-0001@1.0
---

# AI Workforce Policy

## 1. Purpose

This policy sets the place of AI agents in the Company: what they may do, what they may never do, and how they are briefed.

## 2. Scope

This policy applies to every AI agent that works in the repository, whatever its vendor, and to the files and settings that brief and restrain it.

## 3. Definitions

| Term | Definition |
|---|---|
| Agent | An AI system that reads, writes or runs anything in the repository. |
| Entrance files | The Markdown files at the root of the repository, which agents and people read first. |
| Shared entrance | `AGENTS.md`, the entrance that every agent reads. |
| Vendor file | A file that the agent of one vendor reads, such as `CLAUDE.md`, `.claude/settings.json` or `.codex/config.toml`. |
| Guardrail | A setting in the tool of an agent that blocks or pauses an action, whatever the agent decides. |

## 4. Status of Agents

1. An agent is an employee of the Company on probation. The probation does not end.
2. An agent follows every rule that a person follows, and is checked by the same checkpatch.
3. An agent may draft, implement, test, propose and file change requests.
4. An agent never approves anything: no change request, no document and no merge (EE-POL-0004 §4).
   It records an approval only when the Approver of record has given it, in words, in the same session.
5. An agent never signs off in its own name.
   It writes a `Signed-off-by` trailer only for the person on whose behalf it works, in that person's git identity and with their authority; that person answers for the commit (EE-STD-0007 §6).
   The agent is named in a `Co-Authored-By` trailer.

## 5. Vendor Neutrality

1. `AGENTS.md` is the single entrance for every agent. No vendor receives a rule that the others do not.
2. A vendor file only makes the shared entrance reach its agent, and adds what is specific to its tool: how the tool is operated, never what the agent may do.
3. `CLAUDE.md` imports `AGENTS.md` with a line of its own, outside code, where Claude Code skips imports (`MISSING_AGENTS_IMPORT`).

## 6. Entrance Files

1. The entrance routes rather than restates.
   It tells the agent which document governs the task at hand, and leaves the rules to the documents and to checkpatch.
2. `AGENTS.md` and `CLAUDE.md` together stay within 200 lines, the length within which Claude Code advises its instructions to stay (`ONBOARDING_TOO_LONG`).
3. Entrance files cite only documents that exist (`DANGLING_ENTRY_REFERENCE`).
4. Every mistake that an agent makes and no rule catches is added to the entrance, among the mines stepped on by its predecessors, together with the record of the mistake.

## 7. Guardrails

1. Instructions are context, not enforcement.
   An action that must never happen without a person is also blocked in the tool.
2. Claude Code applies the following guardrails through `.claude/settings.json`.

| Action | Setting |
|---|---|
| Reading `.env` | Denied |
| `git push` | Denied |
| `git commit --amend`, `git rebase`, `git reset --hard` | Denied, as rewrites of history (EE-CHR-0001, Article 7) |
| `git merge` | Asks the person first |

3. Codex applies them through `.codex/config.toml`: writes stay inside the repository, the network stays closed, and the agent asks before it leaves the sandbox.
4. A guardrail that a tool cannot express is stated in the entrance and, where possible, enforced by checkpatch.
5. A guardrail is not a security boundary; a determined agent can rephrase a command.
   It exists so that an honest agent cannot make an honest mistake.

## 8. Enforcement

checkpatch enforces §5 and §6, and the tools enforce §7.
Annex A lists the rules mandated by this policy.

## Annex A. Rules Enforced Under This Policy

| Rule | Severity | Section |
|---|---|---|
| `MISSING_AGENTS_IMPORT` | Error | §5 |
| `ONBOARDING_TOO_LONG` | Warning | §6 |
| `DANGLING_ENTRY_REFERENCE` | Error | §6 |

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.9.0 | 2026-10-30 | Submitted for review. | Human Resources |
| 1.0.0 | 2026-10-30 | Approved. | Human Resources |
| 1.1.0 | 2026-10-30 | An agent writes a sign-off only for the person it works for. | Human Resources |

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Drafter | Human Resources | Submitted | 2026-10-30 |
| Approver | Hawakiki | Pending | — |
