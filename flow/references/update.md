---
name: tier0-flow-update
description: "Update Tier0 Flow metadata such as name, description, template, and favorite state."
---

# flow update

Use `flow update` to change Flow metadata. It does not deploy Node-RED canvas JSON.

## Commands

```bash
tier0 flow update --id 1 --name "line1-collector"
tier0 flow update --id 1 --desc "Line 1 Modbus collector"
tier0 flow update --id 1 --favorite
tier0 flow update --id 1 --unfavorite
tier0 flow update --id 1 --template-file template.json
```

## Rules

- Use integer Flow `id`, not Node-RED `flowId`.
- Use `flow deploy` for canvas JSON.
- Use `flow data` before changing deployable content.
