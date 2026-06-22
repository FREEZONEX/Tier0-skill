---
name: tier0
description: "Tier0 platform operations for AI agents: CLI setup, authentication, UNS data-plane operations, Node-RED Flow management, service info, and API key diagnostics."
---

# Tier0

This is the main Tier0 skill entry point. Use it when the user asks about Tier0 CLI, UNS, Flow, Node-RED, authentication, service status, or API key permissions.

## Required Order

1. Configure private deployments before login.
2. Authenticate with an API key or browser device flow.
3. Read the matching reference file before running a task-specific command.
4. For risky operations, confirm impact with the user before adding `--yes`.

## Install

Recommended:

```bash
npx @tier0/cli@latest
```

Alternative:

```bash
curl -fsSL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

If using the alternative installer, install skills separately:

```bash
npx skills add FREEZONEX/Tier0-skill
```

## Configure

SaaS uses `https://tier0.dev` by default.

Private deployments must be configured before login:

```bash
tier0 config --base-url http://127.0.0.1:8088
```

If `base-url` changes, run login again or set an API key for that instance. Existing keys are tied to the previous instance and Workspace.

## Authenticate

Preferred when an API key is already available:

```bash
tier0 config --api-key <api-key>
```

Browser device flow:

```bash
tier0 login --no-wait --json
```

Immediately show the returned `verification_url` to the user as a clickable link. Then poll without asking whether the user is done:

```bash
tier0 login --setup-code <setup_code>
```

The polling command blocks until the browser authorization completes or times out.

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Workspace | Tenant boundary for all resources |
| UNS | Unified Namespace, a tree of paths and data topics |
| Path | Folder-like namespace segment |
| Topic | Full leaf path, such as `Plant/Line1/Metric/Temperature`; only topics can be read or written |
| Node | A namespace item: `PATH` or `TOPIC` |
| VQT | Value object plus `quality` plus millisecond `timeStamp` |
| SourceFlow | Node-RED instance for collecting industrial data and publishing MQTT |
| EventFlow | Node-RED instance for processing business data or subscribing to MQTT |

Flow names and UNS paths are often manually kept similar, but current APIs do not expose a guaranteed relation field. When the user asks about a named device or data point, check both UNS and Flow unless they explicitly ask for only one side.

## Routing

Always read the referenced file before executing the corresponding command.

### UNS

| Intent | Read |
| --- | --- |
| Browse namespace folders | `uns/references/browse.md` |
| Read current topic values | `uns/references/read.md` |
| Write topic values | `uns/references/write.md` |
| Query history or aggregates | `uns/references/history.md` |
| Search topics | `uns/references/search.md` |
| Create namespace nodes | `uns/references/create.md` |
| Update metadata or fields | `uns/references/update.md` |
| Delete nodes | `uns/references/delete.md` |
| Restore soft-deleted nodes | `uns/references/restore.md` |

Key UNS rules:

- `browse` and `search` operate on paths or namespace discovery.
- `read`, `write`, and `history` require complete topic leaf paths.
- Topic paths must include a type folder immediately before the leaf: `Metric`, `Action`, or `State`.
- `topicType` is derived from that type folder.
- `value` for writes must be an object matching the topic fields, not a scalar.
- Batch APIs can return HTTP 200 while individual items fail. Check both `data.success` and every `data.results[i].success`.

### Flow

| Intent | Read |
| --- | --- |
| Query available Node-RED node types | `flow/references/nodes.md` |
| List or inspect flows | `flow/references/list.md` |
| Create SourceFlow or EventFlow | `flow/references/create.md` |
| Update flow metadata | `flow/references/update.md` |
| Delete flows | `flow/references/delete.md` |
| Export Node-RED canvas JSON | `flow/references/data.md` |
| Deploy Node-RED canvas JSON | `flow/references/deploy.md` |

Critical Flow rules:

- Use integer `id` for CLI commands. Do not use Node-RED `flowId`.
- Before deploy, always export a backup with `tier0 flow data --id <id> --out backup.json`.
- `flow deploy` and `flow delete` require `--yes` after user confirmation.
- Delete stops the related Node-RED container.
- Backend-created Flows include a Tier0 `mqtt-broker` config node with credentials. Preserve that config node from `flow data` output when deploying; do not create or replace it.

### Auth and Info

| Intent | Read |
| --- | --- |
| Service connectivity and gateway info | `info/info.md` |
| API key identity and permissions | `auth/whoami.md` |

## Task Selection

| User intent | Correct path | Avoid |
| --- | --- | --- |
| Discover devices or data points | Browse folders step by step | Using search as a tree traversal |
| Find a known topic by name | Search by keyword | Blindly browsing every branch |
| Read current data | `uns read` with full topic path | `history`, which is not current value |
| Query trends | `uns history` after reading its reference | Looping `read` |
| Write data | `uns write` with object value | `uns update`, which changes metadata |
| Manage topic fields | `uns update` | `uns write` |
| Create nodes | `uns create`; path must include `Metric`, `Action`, or `State` before the leaf | Assuming the CLI inserts the type folder |
| Inspect Flow | `flow list`, then `flow get --id <id>` | Passing Node-RED `flowId` |
| Deploy canvas | Backup with `flow data`, read deploy reference, then deploy with `--yes` | Deploying without backup |
| Delete Flow | `flow get`, show impact, then delete with `--yes` | Bulk delete without explicit confirmation |

## PowerShell Notes

Quote wildcard topics:

```powershell
tier0 uns read --topic 'Plant/+/Metric/Temperature'
```

For complex JSON, prefer files:

```powershell
tier0 uns write --topic demo --file payload.json
```

## Common Commands

```bash
tier0 config
tier0 doctor
tier0 auth whoami --json
tier0 uns browse --path /
tier0 uns read Plant/Line1/Metric/Temperature --json
tier0 uns write --topic Plant/Line1/Metric/Temperature --value '{"temperature":27.5}'
tier0 uns history -t Plant/Line1/Metric/Temperature --start -1h --json
tier0 flow list
tier0 flow create --name "modbus-collector" --source --desc "Modbus collector"
tier0 flow data --id 1 --out flows.json
tier0 flow deploy --id 1 -f flows.json --yes
```

## Batch Response Handling

For `uns read`, `uns write`, `uns history`, and batch `uns create`, do not trust only HTTP status or the outer response code. These APIs may return partial failure inside `data`.

Required checks:

```js
if (resp.data && typeof resp.data.success === "boolean" && !resp.data.success) {
  throw new Error("Batch operation failed");
}
for (const item of resp.data?.results ?? []) {
  if (item.success === false) {
    throw new Error(`Item failed: ${item.topic || item.path || item.message}`);
  }
}
```

Non-batch APIs such as browse, search, flow list/get, info, and auth whoami do not use this inner batch success contract.

## High-Risk Confirmation

`flow deploy` and `flow delete` exit with code 10 and a `confirmation_required` error when `--yes` is missing.

Agent handling:

1. Detect exit code 10 and `error.type == "confirmation_required"`.
2. Show `error.risk.action` and the summary to the user.
3. If the user agrees, retry the same command with `--yes`.
4. If the user refuses, stop.

## Updates

The CLI checks for updates in the background at most once every 24 hours. Upgrade manually with:

```bash
tier0 upgrade
tier0 skills update
```
