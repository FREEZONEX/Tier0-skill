---
name: tier0-uns-bind-flow
version: 0.3.0
description: "把 UNS 节点绑定到 SourceFlow。triggers: Tier0, UNS, Flow, SourceFlow, 绑定, 关联"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, flow, bind]
---

# bind-flow — 绑定 SourceFlow

## 说明

使用 UNS 节点 ID 和 Flow 业务主键 ID 建立关联。这里的 `flowId` 是平台 Flow 业务主键 ID，不是 Node-RED tab 内部的字符串 `flowId`。

## 命令

```bash
tier0 uns bind-flow --uns-id <unsId> --flow-id <flowId>
```

也可以使用位置参数：

```bash
tier0 uns bind-flow <unsId> <flowId>
```

| Flag | 说明 |
|------|------|
| `--uns-id` | ✅ UNS 节点 ID |
| `--flow-id` | ✅ Flow 业务主键 ID |
| `--json` | 原始 JSON 输出 |

## API

```http
POST /openapi/v1/uns/unsBindFlow
```

请求体：

```json
{
  "unsId": 10001,
  "flowId": 20001
}
```

## 示例

```bash
# 先找 Flow 业务主键 ID
tier0 flow list --source --keyword pump

# 绑定 UNS 到 SourceFlow
tier0 uns bind-flow --uns-id 10001 --flow-id 20001
```

## 注意

- 只绑定 SourceFlow；如果后端返回参数错误，先确认目标 Flow 类型。
- 不要把 Node-RED 画布里的 tab id 当成 `flowId`。
- 绑定前可用 `tier0 flow list --source` 获取业务主键 `id`。
