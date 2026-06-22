---
name: tier0-flow
description: "Tier0 Flow management for Node-RED: list, create, update, delete, export, and deploy SourceFlow and EventFlow canvas JSON."
---

# tier0-flow

Use this skill for Tier0 Node-RED Flow management.

## Use When

- The user wants to list, inspect, create, update, or delete Flows.
- The user wants to export Node-RED canvas JSON.
- The user wants to deploy or replace a Node-RED canvas.
- The user asks about SourceFlow or EventFlow state.

## Do Not Use When

- The user wants current UNS topic values. Use `uns/references/read.md`.
- The user wants to directly drag nodes in the Node-RED UI. The CLI imports and exports JSON; UI editing happens in a browser.
- The user wants protocol mapping details. Read the matching protocol reference first.

## Non-Negotiable Rules

1. List before acting when the Flow ID is unknown.
2. CLI commands use integer `id`; Node-RED `flowId` is not a CLI identifier.
3. Before deploy, export a backup: `tier0 flow data --id <id> --out backup.json`.
4. `flow deploy` and `flow delete` require `--yes` after user confirmation.
5. Deleting a Flow stops the related Node-RED container.
6. Do not construct deploy payloads before reading `references/deploy.md`.
7. Preserve the backend-created Tier0 `mqtt-broker` config node. Do not create or replace it.

## Flow Types

| Type | Meaning | Typical Use |
| --- | --- | --- |
| `SourceFlow` | Collects industrial protocol data and publishes MQTT / UNS | Modbus, OPC-UA, OPC-DA, MQTT bridge |
| `EventFlow` | Processes business data or subscribes to MQTT | Alarms, transformations, actions, archival |

## Routing

| Intent | Read | Risk |
| --- | --- | --- |
| Query available node types | `references/nodes.md` | Low |
| List or inspect Flow | `references/list.md` | Low |
| Create Flow | `references/create.md` | Low |
| Update Flow metadata | `references/update.md` | Low |
| Delete Flow | `references/delete.md` | High, requires `--yes` |
| Export Node-RED canvas | `references/data.md` | Low |
| Deploy Node-RED canvas | `references/deploy.md` | High, requires backup and `--yes` |

## Protocol References

Read the matching file before generating or editing Flow JSON:

| Intent | Read |
| --- | --- |
| Modbus TCP/RTU to UNS | `references/protocols/modbus.md` |
| OPC-UA subscription to UNS | `references/protocols/opcua.md` |
| OPC-DA polling to UNS | `references/protocols/opcda.md` |
| External MQTT broker to UNS | `references/protocols/mqtt-bridge.md` |
| UNS to PostgreSQL archive | `references/protocols/postgresql.md` |
| Template index | `references/protocols/README.md` |

## Common Commands

```bash
tier0 flow list
tier0 flow list --source --json
tier0 flow get --id 1 --json
tier0 flow create --name "modbus-collector" --source --desc "Modbus TCP collector"
tier0 flow create --name "alert-handler" --event --desc "Temperature alarm processor"
tier0 flow data --id 1 --out flows.json
tier0 flow deploy --id 1 -f flows.json --yes
```

## Node-RED Canvas Workflow

```bash
tier0 flow list
tier0 flow data --id <id> --out backup.json
# edit or generate flows.json
tier0 flow deploy --id <id> -f flows.json --yes
```

When generating `flows.json`, include the existing backend-created Tier0 `mqtt-broker` config node from the exported data. Node-RED credentials are stored against the node ID; replacing that node can cause anonymous MQTT connections and authentication failure.
