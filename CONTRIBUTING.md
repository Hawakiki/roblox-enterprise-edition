<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->

# Contributing

To contribute to EnterpriseEdition is to be employed by it, on a probation that does not end (EE-POL-0006).
People and agents follow the same rules.
[AGENTS.md](AGENTS.md) is the entrance to them, and serves people as well.

## Before you change anything

1. Every change starts with a change request, on the form in EE-TPL-0002, on a branch of its own named `feature/CR-NNNN-<slug>`, with the next free number (EE-POL-0004).
2. File it as `Submitted`, and wait. Only the Approver of record approves, and only an approved request is implemented (EE-POL-0004 §4).
3. The governance is frozen: no policy, standard, procedure, form, record kind or document rule is added or removed. The work happens in `src/`.

## While you work

- Follow the standards that `AGENTS.md` points to for whatever you touch. `lune run scripts/checkpatch --list-rules` lists every rule, with the document that mandates it.
- Run `tools/check.sh` before every commit. The commit-msg hook checks the message, not the files.
- Write commit messages as EE-STD-0007 requires: an English subject, an `[EN]` and a `[KO]` section in the body, and a `Change-Request` trailer.
- Sign off every commit with a `Signed-off-by` trailer in your own name. It certifies, in the manner of the [Developer Certificate of Origin](https://developercertificate.org/), that you have the right to submit the change under the license of the repository (EE-STD-0007 §6).
- Never rewrite history that others may have. A mistake gets a corrective change request.

## Pull requests

Open the pull request against `develop`.
The continuous integration runs every check and checks every commit message.
The Approver of record merges an approved request with `--no-ff` and an `Approved-by` trailer; no one else merges.
