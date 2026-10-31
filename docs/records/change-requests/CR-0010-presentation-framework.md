---
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
id: CR-0010
title: Build the Presentation Framework
version: 1.0.0
status: Approved
classification: Internal
owner: Architecture Review Board
---

# Build the Presentation Framework

## 1. Summary

The coin feature needs a button, and a button needs a user interface framework.
This change request builds one: declarative elements, class components that own their resources, and a reconciler that keeps the instances of the place in step with what the components render.

## 2. Background

No suitable user interface framework was found on the list of approved vendors, which the Company still does not have (CR-0007).
Frameworks that are widely used do exist.
Adopting one would take a vendor assessment, a licence review and the list of approved vendors itself, so writing one was judged faster.

The framework is shaped by the law of the code (CR-0008):

- Only an Infrastructure factory may create an instance (EE-STD-0003), so the reconciler creates instances through a contract that the Application layer declares.
- A key of a table of properties is a string literal, so that Studio can type it; an event is therefore a property named `On` followed by the name of the event, such as `OnActivated`.
- Sizes and positions live in a Constants module (EE-STD-0005), and colours come from the corporate colour palette.

## 3. Scope

- Application: `IInstanceFactory`, the contract through which anything but Infrastructure obtains an instance.
- Infrastructure: `RobloxInstanceFactory`, the only module of the code that creates an instance.
- Presentation, the framework: `ElementFactory`, which describes instances and components as elements; `IComponent`, the contract of a component; `ComponentScope`, which owns what a component acquires and lets it ask to be rendered again; and `ReconciliationOrchestrator`, which mounts, updates and unmounts trees of elements.
- Presentation, the first component: `PolicyAcknowledgementComponent`, a panel on which a player acknowledges the policies of the Company and sees how often they have done so, with its layout in `InterfaceLayoutConstants` and its colours added to the palette.
- `InterfaceMountService`, a hosted service that mounts the interface on the client, and `PresentationTokenRegistry`, the tokens of the Presentation layer.
- The client composition root registers all of the above.

No controlled document is changed.

## 4. Impact Assessment

| Area | Impact |
|---|---|
| Players | For the first time, a player sees something. It asks them to agree to a policy. |
| Developer productivity | A button now takes a component class, a contract, a scope, a reconciler and a factory. This is intended. |
| Testability | The reconciler never touches `Instance.new`, so a fake factory can stand in for Roblox. |
| Documentation volume | Unchanged. |

## 5. Rollback Plan

Revert the merge commit of this change.
Players would see nothing again, which no player has complained about so far.

## 6. Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Requester | Architecture Review Board | Submitted | 2026-10-31 |
| Approver | Hawakiki | Approved before filing | 2026-10-31 |

## 7. Implementation Record

| Commit | Change |
|---|---|
| — | To be filled in when the request is implemented. |
