---
name: tier0-info
description: "Get Tier0 gateway service information. Triggers: Tier0, service info, status, health check, connectivity."
---

# info - Service Information

Use this file when the user asks to verify Tier0 gateway connectivity or service status.

## Command

```bash
tier0 api /openapi/v2/info --body '{}' --json
```

No business parameters are required.

## Typical Use

```bash
# Verify BaseURL and API key connectivity while debugging
tier0 api /openapi/v2/info --body '{}' --debug --json
```

## PowerShell

```powershell
tier0 api /openapi/v2/info --body '{}' --json
```

## Interpretation

Use a successful response with a populated `data.version` to confirm that the configured `base-url` is reachable. Authentication and workspace permissions should be diagnosed with `auth/whoami.md`.

The examples target the current v2 contract. On an older deployment known to expose only v1, use `/openapi/v1/info` explicitly: the generic `tier0 api` command does not automatically retry v1. Current `tier0 doctor` tries v2 and falls back to v1 only when v2 returns HTTP 404.
