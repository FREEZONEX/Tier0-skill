---
name: tier0-uns-update
description: "Update Tier0 UNS node metadata and topic field definitions. This does not write current values."
---

# uns update

Use `update` to change metadata or field definitions for an existing UNS node.

Do not use this command to write live values. Use `write.md` for data.

## Command

```bash
tier0 uns update \
  --path Plant/Line1/Metric/Temperature \
  --display-name "Temperature" \
  --description "Line 1 temperature" \
  --alias "line1_temp"
```

Update fields:

```bash
tier0 uns update \
  --path Plant/Line1/Metric/Temperature \
  --fields '[{"name":"temperature","type":"float"},{"name":"unit","type":"string"}]'
```

Use a file for complex field definitions:

```bash
tier0 uns update --path Plant/Line1/Metric/Temperature --fields '[{"name":"temperature","type":"float"}]'
```

## Rules

- `--path` is required.
- This command updates node metadata, not VQT data.
- Field updates may affect future writes and reads; verify schema before changing production topics.
- For current values, use `uns write`.

## Recommended Flow

```bash
tier0 uns browse --path Plant/Line1/Metric --include-metadata --json
tier0 uns update --path Plant/Line1/Metric/Temperature --description "Line 1 temperature"
tier0 uns browse --path Plant/Line1/Metric --include-metadata --json
```
