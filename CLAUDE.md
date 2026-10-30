<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->
<!-- AGENTS.md is the shared entrance for every agent (EE-POL-0006 §5). Keep only how to operate Claude Code here. -->

@AGENTS.md

# Claude Code

Everything above is shared with every agent. This section only covers operating Claude Code.

- Create and change files with Write and Edit, not with shell heredocs or `sed`, so that Korean text and byte order marks survive.
- Write commit messages to a file in your scratchpad and pass them with `git commit -F`.
- The PowerShell tool refuses `git rm` on some dot files, taking them for system paths. Run `git rm` through the Bash tool.
- `.claude/settings.json` denies push, history rewrites and `.env`, and asks before every merge.
  The prompt on `git merge` is the Approver of record approving. Never route around it.
- In a main session, run `/context` to confirm that this file and `AGENTS.md` loaded. Subagents cannot run it; they read `AGENTS.md` directly.
