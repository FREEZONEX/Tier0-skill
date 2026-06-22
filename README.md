# Tier0 Agent Skills

Tier0 AI Agent skill documentation.

These files are written for agents. Some authentication steps require the user to complete a browser-based authorization flow.

> Required CLI version: `v0.4.6+`

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

## Uninstall

```bash
npx @tier0/cli@latest uninstall
npx @tier0/cli@latest uninstall --purge
```

## Directory

- [`SKILL.md`](SKILL.md) - Main routing and safety rules
- [`uns/`](uns/) - UNS data-plane operations
- [`flow/`](flow/) - Node-RED Flow management
- [`info/`](info/) - Service information and connectivity checks
- [`auth/`](auth/) - API key identity diagnostics
