# Dungeons

> A multiplayer dungeon RPG built in Roblox Studio — engineered for scalability, clean architecture, and responsive gameplay across all network conditions.

## Features

- **ECS-based combat** powered by [jecs](https://github.com/Ukendio/jecs) — data-driven, composable, and highly extensible
- **Ability system** with cancellation logic, input buffering, configurable concurrency rules, and animation state management
- **Lag compensation** via client-server time synchronization and position history rewinding
- **ServiceBag dependency injection** enforcing strict unidirectional module dependency flow
- **Promise-based async patterns** with full Luau type coverage across the entire codebase
- **Event bus pub/sub** system for decoupled cross-system communication
- **Object pooling** throughout to minimize GC overhead at runtime
- **Composition-based inventory system** with a layered network architecture separating replication, validation, and gameplay concerns
- **Cross-platform UI** with scaling support for both desktop and mobile form factors

## Overview

**The Dungeons** is a multiplayer dungeon RPG developed in Roblox Studio using Luau, designed from the ground up with scalability and maintainability as core priorities. The architecture enforces clear responsibility boundaries across all systems — from a ServiceBag DI framework eliminating implicit module coupling, to naming conventions (Manager vs. Service) that make system roles immediately legible to any contributor.

Combat is built on an entity-component system, enabling modular, data-driven gameplay logic that scales cleanly as complexity grows. The networking layer handles lag compensation transparently, ensuring the game feels responsive regardless of player latency. All async flows run through a promise-based pattern, and the full type coverage in Luau catches errors at edit time rather than runtime.
