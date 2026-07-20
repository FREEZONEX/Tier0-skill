---
name: tier0
description: "Tier0 platform operations entry point: CLI setup, authentication, routing to UNS, Flow, project and platform member queries, service info, and API key diagnostics skills."
metadata:
  requires:
    bins: ["tier0"]
  cliHelp: "tier0 --help"
---

# Tier0

This is the shared entry point for Tier0 CLI work. Keep this file focused on setup, authentication, and routing. Task-specific behavior belongs in the matching sub skill or reference file.

## Use When

Use this skill when the user asks about:

- installing or configuring Tier0 CLI
- authenticating with Tier0
- choosing the right Tier0 skill or command family
- UNS, Flow, Node-RED, service connectivity, or API key permissions
- querying project or platform members, roles, user statuses, or role-bound applications

## Setup

Recommended install:

```bash
npx @tier0/cli@latest
```

Alternative install:

```bash
curl -fsSL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

If using the alternative installer, install skills separately:

```bash
npx skills add FREEZONEX/Tier0-skill
```

## Configuration

SaaS uses `https://tier0.dev` by default.

Private deployments must be configured before login:

```bash
tier0 config --base-url <tier0-base-url>
```

If `base-url` changes, run login again or set an API key for that instance. Existing keys are tied to the previous instance and Workspace.

## Authentication

Preferred when an API key is already available:

```bash
tier0 config --api-key <api-key>
```

Browser device flow:

```bash
tier0 login --no-wait --json
```

Show the returned `verification_url` to the user. Then poll with:

```bash
tier0 login --setup-code <setup_code>
```

The polling command blocks until browser authorization completes or times out.

## Routing

Read the target sub skill or reference before executing a task-specific command.

| User goal | Read |
| --- | --- |
| Browse, search, read, write, history, create, update, delete, or restore UNS nodes/topics | `uns/SKILL.md` |
| List, inspect, create, update, delete, export, or deploy Node-RED Flows | `flow/SKILL.md` |
| List or filter project members, roles, or role-bound applications | `launchpad/members.md` |
| List or filter platform members, Workspace roles, or user statuses | `platform/members.md` |
| Check service connectivity and gateway info | `info/info.md` |
| Check API key identity and permissions | `auth/whoami.md` |

## Core Concepts

| Concept | Meaning |
| --- | --- |
| Workspace | Tenant boundary for all resources |
| Project | Workspace-scoped application context identified by name in Launchpad APIs |
| UNS | Unified Namespace, a tree of paths and data topics |
| Path | Folder-like namespace segment |
| Topic | Full leaf path, such as `Plant/Line1/Metric/Temperature` |
| Flow | Node-RED instance managed by Tier0 |

Flow names and UNS paths are often manually kept similar, but current APIs do not expose a guaranteed relation field. When the user asks about a named device or data point, check both UNS and Flow unless they explicitly ask for only one side.

## Shell Notes

Quote wildcard topics in shells that expand `*`, `+`, or `#`:

```bash
tier0 uns read --topic 'Plant/+/Metric/Temperature'
```

For complex JSON, prefer files or stdin over fragile shell quoting.

## Updates

The CLI checks for updates in the background at most once every 24 hours. Upgrade manually with:

```bash
tier0 upgrade
tier0 skills update
```
