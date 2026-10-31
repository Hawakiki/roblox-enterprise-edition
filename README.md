<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->

# EnterpriseEdition

English | [한국어](README.ko.md)

> **`git commit --no-verify`?** Go ahead. The CI checks every commit message in the history anyway.\
> **`// eslint-disable-next-line`?** Not here. checkpatch cannot be asked to look away, and `--!nolint` is a prohibited directive (EE-STD-0003).

Welcome to EnterpriseEdition.\
It is exactly what the name says: the enterprise edition.

Projects these days...

It's just that the ratio of config files to code is a little off.\
Yes, very off.\
Off as f\*\*\*.

A startup that is already planning to survive a 3 Tbps DDoS sets up Docker, Redis, Kafka and Toxiproxy,\
and catches NIH syndrome, so it builds everything itself.

It sets up a mailing list, though it will have few contributors anyway.\
Nobody is going to pull an xz-utils on it, either.\
The rules are strict, and full of holes every single day.

Of course, it's no different here.\
Except that every rule is actually kept,\
and anyone who tries to pull an xz-utils has their brain explode before they can, and runs.

STOP READING\
GET TO WORK

(it's a joke, don't take it seriously fr fr)

## Development

### Prerequisites

- [Rokit](https://github.com/rojo-rbx/rokit), which installs the toolchain that `rokit.toml` pins: Rojo, StyLua, luau-lsp, Lune and the Moonwave extractor.
- Roblox Studio, with the Rojo plugin.

### Setup

```sh
rokit trust evaera/moonwave            # once per machine: Rokit installs a third-party tool only once you trust it
rokit install
lune setup                             # Lune type definitions for luau-lsp
git config core.hooksPath .githooks    # the commit-msg hook, once per clone
```

### Checking

```sh
tools/check.sh                         # or tools/check.ps1 on Windows; add --fix (-Fix) to format and regenerate the registry
```

It must end with 0 errors.
In order, it runs StyLua, both Luau type solvers over the tooling and over the Roblox code, the Moonwave extractor over the doc comments, the tests of checkpatch, and checkpatch.
The continuous integration runs it on every push and pull request, on Linux with Bash and on Windows under PowerShell 7 and 5.1, and checks every commit message as the commit-msg hook does.
A check that cannot run, for want of a tool or otherwise, fails.

### Running

```sh
rojo serve default.project.json
```

Connect the Rojo plugin in Studio, and press Play.

- A place that has never been published keeps compliance coins in memory.
- A published place with Studio access to API services keeps them in a DataStore.

Stop the server when you are done: a connection left open while the tree changes can sync a second copy of a folder.

### Releasing

```sh
lune run scripts/release_gate          # is a change freeze in force?
lune run scripts/release_notes v1.0.0  # the notes of a release, generated from its change requests
```

A release is prepared on `release/<version>` and tagged `v<version>` on `main` (EE-STD-0008).
Pushing the tag runs the release workflow, which checks, builds the place and writes the notes, then waits for the approval of the Approver of record in the environment `production` before it publishes.
When the Review deployments dialog of GitHub does not respond, the Approver of record, and only they, can approve with `gh api -X POST repos/Hawakiki/roblox-enterprise-edition/actions/runs/<run>/pending_deployments -F "environment_ids[]=25857438866" -f state=approved`.
No release is deployed while it is Friday anywhere on Earth, nor while it is 19 January 2038 anywhere on Earth.

### Changing anything

Read [CONTRIBUTING.md](CONTRIBUTING.md). Agents start at [AGENTS.md](AGENTS.md).

## License

[MIT](LICENSE).
