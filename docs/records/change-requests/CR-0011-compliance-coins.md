---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0011
title: Reward Policy Acknowledgement with Compliance Coins
version: 1.1.0
status: Implemented
classification: Internal
owner: Architecture Review Board
---

# Reward Policy Acknowledgement with Compliance Coins

## 1. Summary

Every acknowledgement of the policies of the Company now earns the player one compliance coin, which the server records and the leaderboard shows.
The coins live in a repository behind a contract; this request keeps them in memory, and a later request is to keep them in a DataStore.

## 2. Background

The first user interface of the Company (CR-0010) asks a player to agree to its policies, and the player has no reason to.
A compliance incentive programme gives them one.

The coins cross the network for the first time in the history of the Company, so they are guarded where a client cannot reach:

- The client only asks; the server decides.
- A player may acknowledge no faster than a minimum interval allows.
- A balance stops at 2^53 - 1, the largest whole number a Luau number holds exactly, beyond which adding a coin would change nothing. At one acknowledgement every quarter of a second, a player reaches it in about seventy million years.

Saving the coins in a DataStore, with a session lock, retries and saving on shutdown, is a change of its own and is left to a later request.

## 3. Scope

- Domain: `CoinWalletEntity`, the coins of one player; `CoinOverflowPolicy`; `AcknowledgementThrottlePolicy`; and `CoinConstants`.
- Application: the contracts `ICoinWalletRepository`, `ICoinProjection`, `IPlayerSessionSource`, `IAcknowledgementGateway` and `ICoinBalanceSource`; `CoinWalletRegistry`; `CoinSessionService`, which loads a wallet when a player joins and releases it when they leave; `AcknowledgementRewardUseCase`; and `AcknowledgementRequestHandler`, which hands every request from the network to it.
- Infrastructure: `InMemoryCoinWalletRepository`, `LeaderstatsCoinProjection`, `RobloxPlayerSessionAdapter`, `RemoteEventAcknowledgementGateway`, `LeaderstatsCoinBalanceAdapter` and `LeaderstatsConstants`.
- Presentation: the policy acknowledgement panel shows the coins of the player and asks the server for one on every acknowledgement; a component receives its properties when it mounts.
- `default.project.json`: the `RemoteEvent` through which the client asks.
- Both composition roots register all of the above.
- `AGENTS.md`: the mines stepped on during CR-0010 and since.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Players | Agreeing to the policies of the Company is rewarded. The reward is a number. |
| Network | One remote event, which carries no arguments that the server reads. |
| Data | None is kept beyond the life of a server until that later request. |
| Developer productivity | One coin takes four layers, five contracts and a remote event. This is intended. |
| Documentation volume | Unchanged. |

## 5. Rollback Plan

Revert the merge commit of this change.
Agreeing to the policies of the Company would again be its own reward.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |
| Implementer | Architecture Review Board | Implemented | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| `054b3d9` | Filed this change request. |
| `160c537` | Stopped citing a request that does not exist yet. |
| `e6b90e0` | Added `CoinWalletEntity`, `CoinOverflowPolicy`, `AcknowledgementThrottlePolicy` and `CoinConstants`. |
| `e23861d` | Added the five contracts, `CoinWalletRegistry`, `CoinSessionService`, `AcknowledgementRewardUseCase`, `AcknowledgementRequestHandler` and their tokens. |
| `99c03ed` | Added `InMemoryCoinWalletRepository`, `LeaderstatsCoinProjection`, `RobloxPlayerSessionAdapter`, `RemoteEventAcknowledgementGateway`, `LeaderstatsCoinBalanceAdapter` and `LeaderstatsConstants`. |
| `3791d90` | Showed the coins on the panel, placed the remote event, and registered the programme in both composition roots. |
| `4722335` | Recorded five mines in `AGENTS.md`. |
