---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0012
title: Keep Compliance Coins in a DataStore under a Session Lock
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Keep Compliance Coins in a DataStore under a Session Lock

## 1. Summary

Compliance coins outlive their server: a wallet is kept in a DataStore, and only one server at a time may write it.
The Application layer does not change its mind about anything; a second implementation of `ICoinWalletRepository` takes the place of the first.

## 2. Background

Since CR-0011, a player who leaves a server keeps their coins only until that server shuts down.

A DataStore keeps them for good, but two servers can hold the same wallet at once: a player who rejoins quickly may load it on a new server while the old one is still saving it.
The later save then wins, and coins earned in between are lost.
The usual remedy is a session lock, written into the record itself, which a server takes when it loads a wallet, renews every time it saves, and gives up when the player leaves.

## 3. Scope

- `DataStoreCoinWalletRepository`, which keeps every wallet in one record per player and reads and writes it only through `UpdateAsync`:
  - A server takes the lock when it loads a wallet. It waits for a lock that another server holds, and takes over a lock whose heartbeat has stopped.
  - A save renews the heartbeat. A save that finds the lock in other hands writes nothing and reports the wallet as lost.
  - Every request waits for budget, and a failed request is retried with exponential backoff.
  - A record written by a newer schema is refused rather than overwritten.
- `DataStoreConstants`, which holds every number above.
- `ICoinWalletRepository.Save` reports whether the wallet is still held, and `IPlayerSessionSource` can disconnect a player.
- `CoinSessionService`:
  - It saves every wallet at a fixed interval, held in `CoinSessionConstants`.
  - It disconnects a player whose wallet cannot be loaded or has been lost.
  - On stop, it releases the remaining wallets in parallel, and waits for releases already under way.
- The server composition root keeps the wallets in the DataStore in a published place, and in memory in a place that has never been published, where a DataStore cannot be reached.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Players | Coins survive the end of a server. A player whose wallet another server still holds waits a few seconds, and is asked to rejoin if it is not released. |
| Data | One record per player, which stores a schema version, a balance and the lock. |
| DataStore budget | One request when a player joins, one per player at every autosave, and one when they leave. |
| Testing | A real DataStore needs a published place with Studio access to API services enabled. The lock is verified against a fake DataStore. |
| Documentation volume | Unchanged. |

## 5. Rollback Plan

Revert the merge commit of this change.
Wallets saved in the DataStore stay there, unread, and coins again last only as long as a server.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
