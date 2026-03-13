# EVE Frontier Smart Turret Extension

A custom targeting extension for EVE Frontier Smart Turrets, built on the Sui blockchain for the EVE Frontier x Sui Hackathon 2026.

## Overview

This extension replaces the default turret targeting logic with a configurable, on-chain system that supports three operating modes, tribe-based access control, weapon specialization bonuses, and real-time Discord notifications via on-chain events.

## Features

- **Three targeting modes** — Whitelist, Aggressor-only, and Sentry
- **Tribe protection** — configure a friendly tribe that the turret will never fire on
- **Aggressor priority** — confirmed attackers are always targeted first with a weight bonus
- **Weapon specialization** — Autocannon, Plasma, and Howitzer turrets get bonuses against their optimal ship classes
- **On-chain events** — emits AggressionDetectedEvent for every attacker, enabling Discord webhook alerts

## Targeting Modes

| Mode | Behavior |
|------|----------|
| Whitelist (1) | Shoots everyone except the configured friendly tribe |
| Aggressor (2) | Only shoots players who have attacked first |
| Sentry (3) | Passive until attacked, then engages aggressors only |

## Weapon Specialization

| Weapon | Bonus Targets |
|--------|--------------|
| Autocannon (92402) | Shuttle, Corvette |
| Plasma (92403) | Frigate, Destroyer |
| Howitzer (92484) | Cruiser, Combat Battlecruiser |

## Deployed Contracts (Testnet)

| Object | ID |
|--------|----|
| Package | `0xd089c5c7d94951106cb578e55950f9357dc9c50b14e8f2e8b9bb4d5fddd43ac5` |
| ExtensionConfig | `0x298e700b7b00a16473798c79c4f24bc71ffb6f38bf34166ca29f875eb266841c` |
| AdminCap | `0xca77365947d1187e503fdadd3ccff1647776b05f776ec2fbfe2e40ec230a09e4` |

## Installation

### Prerequisites
- Sui CLI 1.67.1+
- Access to EVE Frontier Utopia or Stillness test server

### Build and Deploy

Clone world-contracts as a sibling directory:
```bash
git clone https://github.com/evefrontier/world-contracts.git
```

Build the extension:
```bash
cd move-contracts/turret_extension
sui move build -e testnet
```

Deploy:
```bash
sui client publish -e testnet --skip-dependency-verification
```

### Connect to Your Turret

1. Copy the **ExtensionConfig** object ID from the deployment output
2. Open your Smart Turret info window in EVE Frontier
3. Paste the ExtensionConfig ID into the **dApp link** field
4. Call `authorize()` with your turret object ID and OwnerCap

### Configure Targeting Mode

Set mode (1=whitelist, 2=aggressor, 3=sentry):
```bash
sui client call --package <PACKAGE_ID> \
  --module turret_extension \
  --function set_mode \
  --args <EXTENSION_CONFIG_ID> <ADMIN_CAP_ID> 1
```

Set friendly tribe ID:
```bash
sui client call --package <PACKAGE_ID> \
  --module turret_extension \
  --function set_allowed_tribe \
  --args <EXTENSION_CONFIG_ID> <ADMIN_CAP_ID> <TRIBE_ID>
```

## Discord Notifications

Pair this contract with the [EVE Frontier Turret Watcher](https://github.com/Epeon/eve-frontier-turret-watcher) to receive real-time Discord alerts when your turret detects an aggressor.

## Contract Architecture
```
turret_extension/
├── sources/
│   ├── config.move          # Shared config object, AdminCap, mode/tribe storage
│   └── turret_extension.move # Core targeting logic and events
└── Move.toml
```

## Events

| Event | Description |
|-------|-------------|
| `AggressionDetectedEvent` | Fired when an attacker is identified — triggers Discord alert |
| `PriorityListUpdatedEvent` | Fired each targeting cycle with target count |

## Hackathon

Built for the **EVE Frontier x Sui Hackathon 2026** (March 11-31, 2026).

- Hackathon registration: [deepsurge.xyz/evefrontier2026](https://deepsurge.xyz/evefrontier2026)
- EVE Frontier: [evefrontier.com](https://evefrontier.com)
