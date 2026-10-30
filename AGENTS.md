<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->

# AGENTS.md

Welcome to EnterpriseEdition. You are an employee now, on a probation that does not end (EE-POL-0006).

This file is the entrance, not the rulebook.
The rules live in `docs/`, listed in `docs/REGISTRY.md`, and checkpatch enforces them.
Where this file and a document disagree, the document prevails.

You start every session with no memory of the last one. That is expected.
Trust the registry, not the memory (EE-CHR-0001, Article 3).

## 1. First Five Minutes

```sh
rokit install                          # pinned toolchain: rojo, stylua, luau-lsp, lune
lune setup                             # Lune type definitions for luau-lsp
git config core.hooksPath .githooks    # the commit-msg hook, once per clone
tools/check.sh                         # or tools/check.ps1; it must end with 0 errors
rojo serve default.project.json        # sync src/ into Roblox Studio
```

## 2. Absolute Rules

1. **A person approves.** Never set anything to `Approved`, never write `Approved-by` and never merge, unless the Approver of record has said so in this session (EE-POL-0006 §4).
2. **Never rewrite history.** No amend, rebase, hard reset or force push. A mistake gets a corrective change request (EE-POL-0004 §8).
3. **Every change starts with a change request,** on its own `feature/CR-NNNN-<slug>` branch.
   File it as `Submitted`, unless the Approver of record has already approved it in words (EE-POL-0004 §4).
4. **Read `git status` before every commit,** and stage only what you meant to (CR-0002).
5. **Never read `.env`, and never push.**
6. **When unsure, run checkpatch.** Every error ends with the document that mandates it.
7. **The governance is frozen.** Add or remove no policy, standard, procedure, form, record kind or document rule; numbers already reserved may still be written.
   The work happens in `src/` (CR-0007).

## 3. Where to Look

| You are about to | Read |
|---|---|
| Change anything | EE-POL-0004 |
| Write a commit message | EE-STD-0007 |
| Write or revise a document | EE-POL-0001 §7 to §11, EE-POL-0002 §4 and §5 |
| File a change request | EE-TPL-0002 |
| Write a new controlled document | EE-TPL-0001 |
| Write Luau | EE-STD-0001 |
| Write Roblox code under `src/` | EE-STD-0006, EE-STD-0002 |
| Add any file | EE-STD-0004, EE-STD-0009 |
| Add a checkpatch rule | EE-POL-0001 §14 |
| Approve something | Nothing. You do not approve (EE-POL-0006 §4). |

Every rule, with the document that mandates it: `lune run scripts/checkpatch --list-rules`.

## 4. Routine Work

### Changing a document

1. Change the English version and its Korean translation in the same commit.
2. Increment the version: PATCH for wording, MINOR for a new provision or a change in meaning, MAJOR for removing or altering an obligation (EE-POL-0001 §9).
   Set `translation-of` to the new version only after you have reviewed the translation.
3. A revision of an approved document goes `In Review` at its new version, and becomes `Approved` only when the Approver of record approves it (EE-POL-0004 §7).
4. Run `lune run scripts/gen_registry`.
5. A new MAJOR.MINOR makes every child report `STALE_PARENT`. Review each child, then update its citation.

### Committing

Write the message to a file and commit with `git commit -F <file>`, so that multi-line Korean text survives.

```text
docs(governance): clarify the scope of the bilingual policy

[EN]
Why the change is made, wrapped at 72 columns.

[KO]
변경하는 이유를 72칸에 맞춰 쓴다.

Signed-off-by: <the person you work for> <their email>
Change-Request: CR-NNNN
Co-Authored-By: <your name> <your email>
```

You write `Signed-off-by` only for the person you work for, in their git identity and with their authority, never as yourself (EE-POL-0006 §4).

### Finishing a change request

1. List the implementing commits in its Implementation Record, set `Implemented` and increment MINOR.
2. Report to the Approver of record, and wait.
3. Only after approval in words: merge into `develop` with `--no-ff` and an `Approved-by` trailer that names the Approver.

## 5. Mines Your Predecessors Stepped On

| Mine | What happened | Record |
|---|---|---|
| `lune setup` writes `.luaurc` into the current directory | A stray file was committed at the root | CR-0002 |
| `git add -A` without reading `git status` | The same stray file went unnoticed | CR-0002 |
| Citing a document that does not exist yet | `DANGLING_REFERENCE`. Commit documents that cite each other together | EE-POL-0001 §13 |
| Changing frontmatter without regenerating the registry | `REGISTRY_OUT_OF_DATE` | EE-POL-0001 §13 |
| Writing `version: 1.0` | YAML reads a number: `INVALID_FIELD_VALUE`. Versions have three parts | EE-POL-0001 §7 |
| Leaving a gap in the numbering | Numbers are sequential. Reserve one with a `Draft` placeholder | EE-POL-0001 §5, CR-0004 |
| Calling a request by the number it had in a plan | It takes the next free number instead | CR-0005 |
| A Korean commit subject | `COMMIT_SUBJECT_NOT_ENGLISH`. Korean goes in `[KO]` | EE-STD-0007 §4 |
| Adding a rule without documenting it | `UNDOCUMENTED_RULE`. Cite it in both versions of its document | EE-POL-0001 §14 |
| A PowerShell script with Korean text and no BOM | `MISSING_UTF8_BOM` | EE-STD-0009 §3 |
| Revising an approved document | Impossible until CR-0006. Now it goes `In Review` at its new version | EE-POL-0001 §9, CR-0006 |
| Filing a record without a section of its form | `TEMPLATE_SECTION_MISSING` | EE-POL-0001 §8, CR-0006 |
| Working on the branch an agent worktree starts on | `BRANCH_NAME_FORMAT`. Create `feature/CR-NNNN-<slug>` first | CR-0006 |
| Translating a branch name, rule code or field value | Code identifiers stay as they are, in backticks | EE-POL-0002 §6 |
| Using a class instance where its contract type is expected | Both solvers reject it. Constructors return the contract, and `_implements` declares it | EE-STD-0006 §6 |

When you step on a new one, add it here with its record (EE-POL-0006 §6).
