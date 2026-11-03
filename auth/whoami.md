---
name: tier0-auth-whoami
description: "Inspect the server-reported identity and effective resources of the current API key."
---

# auth whoami - API Key Identity

Use this file to inspect the server-reported key type, Workspace, and effective resources. A key is not necessarily a personal user credential.

`auth whoami` is diagnostic only. It is not required before every API call.

## Commands

```bash
# Preferred CLI command
tier0 auth whoami

# JSON output for agents
tier0 auth whoami --json

# Current Cloud OpenAPI contract (older deployments may expose v1 instead)
tier0 api /openapi/v2/auth/whoami --body '{}'
```

## Response Fields

```json
{
  "userID": 1001,
  "userName": "Alice",
  "email": "alice@example.com",
  "workspaceID": 2001,
  "workspaceName": "Factory A",
  "keyPrefix": "sk-per-abc123",
  "keyType": "personal",
  "roles": ["admin"],
  "permissions": ["uns.read"]
}
```

## Troubleshooting Rules

1. Use `workspaceID` and `workspaceName` to confirm the key targets the expected Workspace.
2. Treat `keyType` as the server-reported identity type: `personal`, `service`, or `app`. Do not infer identity or authorization from the key prefix, name, or owner fields. Older responses may omit the type.
3. Treat `permissions` as returned resource keys, not a guarantee that every operation or individual resource is authorized. Current role, seat, plan, App policy, resource checks, and capability availability may further restrict access; an earlier result can become stale.
4. App-bound access may require additional server-verified identity and policy. Do not invent or attach delegation headers, impersonate an employee, or assume CLI support for an unfinished authorization flow.
5. For HTTP 401, check that `tier0 config` has an API key, the key has not expired, and the BaseURL is correct. For 403, preserve the denial and inspect the relevant permissions and policy.
