---
name: tier0-flow-create
description: "Create Tier0 SourceFlow or EventFlow instances. Backend-created Flows initialize a Tier0 MQTT broker config node."
---

# flow create

Use `flow create` to create a SourceFlow or EventFlow.

## Commands

```bash
tier0 flow create --name "modbus-collector" --source --desc "Modbus TCP collector"
tier0 flow create --name "alert-handler" --event --desc "Temperature alarm processor"
tier0 flow create --name "opcua-line1" --type SourceFlow --json
```

## Rules

- Choose exactly one Flow type: `--source`, `--event`, or `--type`.
- Use clear names that match the device, line, or business function.
- After creating a SourceFlow that will publish to Tier0 MQTT, export its canvas before deploy:

```bash
tier0 flow data --id <id> --out flows.json
```

## Tier0 MQTT Broker Config

The backend Flow creation API initializes a Tier0 `mqtt-broker` config node and credentials for the Node-RED instance.

When deploying canvas JSON later:

- Preserve that config node from `flow data`.
- Keep its `id`, `broker`, and `clientid`.
- Do not hand-write `credentials.user` or `credentials.password`.
- Do not replace it with a new `mqtt-broker` node.

Read `references/protocols/mqtt-bridge.md` before building MQTT paths.
