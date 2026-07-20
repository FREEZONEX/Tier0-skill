# Changelog

## Unreleased

- Documented the Launchpad project member query, including role and update-time filters, pagination, permissions, and the complete response contract.
- Documented the fields (schema) rule in `uns/references/create.md`: `Metric` topics require `--fields`; `Action`/`State` topics should declare `--fields` so the schema is visible in UNS, with example payloads in `--description` for nested structures. Added Action/State creation examples (single and batch tree) and a matching non-negotiable rule in `uns/SKILL.md`.

- Added the CLI v0.6.4 request-preview contract, structured validation error guidance, strict JSON rules, and dry-run-first workflows for UNS and Flow mutations.

- Documented the `flow data --out` and `flow deploy -f` round trip: exported files are deployable Node-RED `flows` arrays, while deploy remains compatible with older envelope shapes.
- Converted all agent-facing Tier0 Skill documentation to English.
- Converted UNS references, Flow references, protocol guides, install script text, and Node-RED JSON template labels/comments to English.
- Preserved critical operational guidance for UNS topic path rules, batch response validation, high-risk Flow confirmation, deploy backups, and backend-created Tier0 MQTT broker config reuse.
- Updated examples to match the current `tier0` CLI command tree.
