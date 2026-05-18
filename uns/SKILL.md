---
name: tier0-uns
description: "Tier0 UNS（Unified Namespace）数据面操作。支持命名空间浏览、节点读写、历史数据查询、搜索、创建、更新、删除、恢复。triggers: Tier0, UNS, 命名空间, 数据读写, 历史查询"
metadata:
  hermes:
    tags: [uns, namespace, data, read, write, history]
---

# tier0-uns — UNS 数据面操作

## API 参考

| 端点 | 方法 | 说明 |
|------|------|------|
| `/openapi/v1/uns/browse` | POST | 浏览命名空间树 |
| `/openapi/v1/uns/read` | POST | 读取节点值 |
| `/openapi/v1/uns/write` | POST | 写入数据点 |
| `/openapi/v1/uns/history` | POST | 查询历史数据 |
| `/openapi/v1/uns/search` | POST | 搜索命名空间 |
| `/openapi/v1/uns/create` | POST | 创建节点 |
| `/openapi/v1/uns/update` | POST | 更新节点 |
| `/openapi/v1/uns/delete` | POST | 删除节点 |
| `/openapi/v1/uns/restore` | POST | 恢复已删除节点 |
| `/openapi/v1/info` | POST | 服务信息 |

## 请求格式

所有请求均为 JSON，Header 需包含：
```
Content-Type: application/json
Authorization: Bearer <api-key>
```

响应格式：
```json
{
  "code": 200,
  "msg": "success",
  "data": { ... }
}
```
