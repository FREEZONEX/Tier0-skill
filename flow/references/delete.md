---
name: tier0-flow-delete
description: "Delete Tier0 Flows. High-risk operation: stops the related Node-RED container and requires --yes."
---

# flow delete

Use `flow delete` to delete one or more Flows.

## Commands

```bash
tier0 flow delete --id 1 --yes
tier0 flow delete --id 1 --id 2 --yes
tier0 flow delete 1 2 --yes
```

## Rules

- Confirm the Flow exists with `flow get` before deleting.
- Tell the user deletion stops the related Node-RED container.
- Use `--yes` only after the user confirms.
- Prefer deleting one Flow at a time unless the user explicitly requests batch deletion.

## Recommended Flow

```bash
tier0 flow get --id 1 --json
tier0 flow delete --id 1 --yes
```
