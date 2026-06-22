---
name: tier0-uns-search
description: "Search Tier0 UNS topics by keyword, path prefix, type, and metadata options."
---

# uns search

Use `search` when the exact topic path is unknown and the user provides a name, keyword, prefix, or type.

## Command

```bash
tier0 uns search --keyword temp --json
tier0 uns search --path-prefix Plant/Line1 --size 50 --json
tier0 uns search --keyword temp --include-metadata --json
tier0 uns search --topic-type METRIC --json
```

## Rules

- Use `browse` for structural tree traversal.
- Use `search` for keyword or prefix lookup.
- Use `--include-metadata` when field definitions or descriptions are needed.
- Use `--include-values` only if the user wants current values alongside search results.

## Typical Flow

```bash
tier0 uns search --keyword Temperature --include-metadata --json
tier0 uns read Plant/Line1/Metric/Temperature --json
```

If the user asks about a named device or data source, also check matching Flow names:

```bash
tier0 flow list --keyword Line1 --json
```
