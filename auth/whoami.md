---
name: tier0-auth-whoami
version: 0.3.1
description: "查看当前 API Key 绑定的用户、Workspace、角色和权限。触发场景: API Key 诊断、权限排查、确认当前身份"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [auth, apikey, whoami, permissions, workspace]
---

# auth whoami — API Key 身份诊断

用于排查当前 CLI 配置的 API Key 绑定到了哪个用户、Workspace，以及具备哪些角色和权限。

> `auth/whoami` 只用于诊断，不是调用其他 API 的前置步骤。

## API

```
POST /openapi/v1/auth/whoami
```

## 请求参数

无需业务参数，传空对象即可。

## 示例

```bash
# 推荐：CLI 子命令
tier0 auth whoami

# JSON 输出，便于 Agent 解析
tier0 auth whoami --json

# 直接调用 API
tier0 api /openapi/v1/auth/whoami --body '{}'
```

## 响应结构

```json
{
  "code": 200,
  "msg": "ok",
  "data": {
    "userID": 1,
    "userName": "agent",
    "email": "agent@example.com",
    "workspaceID": 1001,
    "workspaceName": "Default",
    "apiKeyName": "agent-key",
    "keyPrefix": "sk-per",
    "permissions": ["full_access"],
    "roles": ["admin"],
    "keyType": "personal"
  }
}
```

## 排查规则

1. `workspaceID` / `workspaceName` 用来确认当前 key 是否绑定到目标 Workspace。
2. `permissions` 用来确认 key 是否具备目标接口所需权限；`full_access` 可访问所有 OpenAPI 资源。
3. `keyType` 用来区分 personal / service 等 key 类型。
4. 如果接口返回 401，先检查 `tier0 config` 里的 API Key 是否存在、是否过期、BaseURL 是否正确。

## Windows PowerShell

```powershell
tier0 auth whoami --json
tier0 api /openapi/v1/auth/whoami --body '{}'
```
