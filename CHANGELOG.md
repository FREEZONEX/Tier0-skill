# Changelog

## Unreleased

- Routed continuous/event-driven UNS consumption to MQTT/EventFlow and prohibited silent OpenAPI polling fallbacks.
- Corrected batch namespace examples to use `name`, current-read VQT fields to use `results[i].result`, and search value inclusion to use `--include-leaf-value`.
- Added PowerShell-safe `--fields-file` and `--clear-description` guidance for UNS mutations.
- Removed unsupported claims about clearing Flow descriptions and using undocumented Flow create/update template contracts on public SaaS.
- Marked currently unavailable SaaS member endpoints, aligned authorization troubleshooting with `whoami.permissions`, and fixed repeated Flow node examples.
- Converted all protocol templates to valid JSON and removed generated/example Tier0 MQTT broker config nodes in favor of a preserved broker-ID placeholder.
- Made explicit CLI installation and post-install authentication verification mandatory in the agent workflow.

- Documented the Launchpad project member query, including role and update-time filters, pagination, permissions, and the complete response contract.
- Documented the fields (schema) rule in `uns/references/create.md`: `Metric` topics require `--fields`; `Action`/`State` topics should declare `--fields` so the schema is visible in UNS, with example payloads in `--description` for nested structures. Added Action/State creation examples (single and batch tree) and a matching non-negotiable rule in `uns/SKILL.md`.

- Added the CLI v0.6.4 request-preview contract, structured validation error guidance, strict JSON rules, and dry-run-first workflows for UNS and Flow mutations.

- Documented the `flow data --out` and `flow deploy -f` round trip: exported files are deployable Node-RED `flows` arrays, while deploy remains compatible with older envelope shapes.
- Converted all agent-facing Tier0 Skill documentation to English.
- Converted UNS references, Flow references, protocol guides, install script text, and Node-RED JSON template labels/comments to English.
- Preserved critical operational guidance for UNS topic path rules, batch response validation, high-risk Flow confirmation, deploy backups, and backend-created Tier0 MQTT broker config reuse.
- Updated examples to match the current `tier0` CLI command tree.
