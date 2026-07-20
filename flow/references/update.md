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

## Preflight

Preview the final metadata change before executing it:

```bash
tier0 flow update --id 1 --desc "Line 1 Modbus collector" --dry-run --json
```

An explicitly empty value is meaningful. For example, `--desc ""` clears the
description; confirm that the dry-run body preserves the empty string.

## Rules

- Use integer Flow `id`, not Node-RED `flowId`.
- Use either `--template` or `--template-file`, not both, and provide valid JSON.
- `--favorite` and `--unfavorite` are mutually exclusive.
- Provide at least one field to update.
- Use `flow deploy` for canvas JSON.
- Use `flow data` before changing deployable content.
