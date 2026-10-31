---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0022
title: Prohibit the Global Random Number Generator
version: 1.1.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Prohibit the Global Random Number Generator

## 1. Summary

The Roblox code of the Company has not drawn a random number yet. Before it does, this change request prohibits `math.random` and `math.randomseed`, whose one hidden generator any code can reseed and no test can fix.
It allows `Random.new` only in Infrastructure, so that chance reaches the rest of the code through a contract, which a test can replace with a fake that is not random at all.

## 2. Background

The Prohibited API Registry of EE-STD-0003 §5 already prohibits `_G` and `shared`, global state outside the container, and `tick`, whose result depends on the machine that runs it.
`math.random` has both faults: its generator is global, hidden in the math library, reseeded by whoever calls `math.randomseed`, and a test cannot fix what it returns.
The Company already passes time into its code rather than reading a clock: the reward of an acknowledgement and the DataStore wallets receive theirs. Chance belongs with them.

No module of `src/` calls either API, and none creates a `Random`, so nothing has to change.
The contract that replaces them is declared by the first feature that needs chance, and not before.
EE-STD-0003 §5.4 says that its table grows by revision of the standard.

## 3. Scope

- EE-STD-0003, revised `In Review` at 1.1.0: a row that prohibits `math.random` and `math.randomseed` everywhere, and a row that allows `Random.new` only in Infrastructure modules.
- `scripts/lib/ProhibitedApis.luau`, the copy of the register that checkpatch keeps: the two rows, and Infrastructure modules as a place where an API may be allowed, with tests.

No policy, standard, procedure, form, record kind or document rule is added. `PROHIBITED_API` reports the new rows.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Roblox code | Nothing changes today. Code that needs chance will receive it through a contract. |
| Tests | Behaviour that depends on chance can be tested with a fake source. |
| Documentation volume | Two rows of one standard. |

## 5. Rollback Plan

Revert the merge commit of this change. `math.random` becomes allowed again.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `d164018` | Filed this change request. |
| `bdf46cb` | Revised EE-STD-0003 with the two rows, `In Review` at 1.1.0, and updated the copy of the register in `scripts/lib/ProhibitedApis.luau`, with tests. |

The tests were written first, and failed until the rows were added.
The message of `bdf46cb` carries a warning, `COMMIT_BODY_LINE_TOO_LONG`: a line of its Korean body is 73 columns, one over the limit, because each Korean syllable counts as two. The commit stands as it was made (EE-POL-0004 §8).
