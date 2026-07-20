# Tier0 Agent Skills

Tier0 AI Agent skill documentation.

These files are written for agents. Some authentication steps require the user to complete a browser-based authorization flow.

> Required CLI version: `v0.6.4+`

## Install

Recommended one-command install, requires Node.js >= 16:

```bash
npx @tier0/cli@latest
```

This installs:

- The `tier0` CLI binary into `~/.tier0/bin/`
- Cursor / Claude Agent Skills from `FREEZONEX/Tier0-skill`

Alternative install without Node.js:

```bash
curl -fsSL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

```powershell
iwr https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | iex
```

If using the alternative installer, install skills separately:

```bash
npx skills add FREEZONEX/Tier0-skill
```

## Configure

SaaS uses `https://tier0.dev` by default and needs no base URL configuration.

Private deployments must configure the base URL before login:

```bash
tier0 config --base-url https://your-tier0.example.com
```

Important: run `config` before `login`; otherwise the authorization URL may point to the wrong instance.

## Login

Preferred when an API key is already available:

```bash
tier0 config --api-key <api-key>
```

Browser authorization flow:

```bash
tier0 login --no-wait --json
```

Show the returned `verification_url` to the user immediately. Then poll:

```bash
tier0 login --setup-code <setup_code>
```

## Verify

```bash
tier0 doctor
tier0 auth whoami
tier0 api /openapi/v1/info --body '{}'
```

## Safe Write Previews

Tier0 Skills use `--dry-run --json` to validate generated UNS and Flow mutation
requests before execution. Dry-run output contains the HTTP method, URL, and
body, but never credentials and never sends the request.

High-risk delete, restore, and deploy workflows preview first, ask for user
confirmation, and only then execute with `--yes`.

## Uninstall

```bash
npx @tier0/cli@latest uninstall
npx @tier0/cli@latest uninstall --purge
```

## Directory

- [`SKILL.md`](SKILL.md) - Main routing and safety rules
- [`uns/`](uns/) - UNS data-plane operations
- [`flow/`](flow/) - Node-RED Flow management
- [`launchpad/`](launchpad/) - Project member, role, and application queries
- [`platform/`](platform/) - Platform member, Workspace role, and user status queries
- [`info/`](info/) - Service information and connectivity checks
- [`auth/`](auth/) - API key identity diagnostics
