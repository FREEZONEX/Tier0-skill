---
name: tier0-uns-restore
description: "Restore a soft-deleted Tier0 UNS topic or node."
---

# uns restore

Use `restore` only for nodes that were soft-deleted.

## Command

```bash
tier0 uns restore --path Plant/Line1/Metric/Temperature --yes
```

## Rules

- `--path` is required.
- Confirm with the user before adding `--yes`.
- Hard-deleted nodes cannot be restored.

## Follow-Up

After restore, verify with:

```bash
tier0 uns browse --path Plant/Line1/Metric --include-metadata --json
```
