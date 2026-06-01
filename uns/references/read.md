---
name: tier0-uns-read
version: 0.3.0
description: "读取 UNS 数据点的当前值（VQT 模型）。triggers: Tier0, UNS, 读取, 数据点, 实时值, 传感器数据"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, read, data, vqt]
---

# read — 读取数据点

## 说明

读取一个或多个 UNS topic 的当前值。返回 **VQT 结构**：`value`（业务数据对象）+ `quality`（数据质量）+ `timeStamp`（毫秒时间戳）。

支持通配符：`+` 匹配一层，`#` 匹配剩余所有层。

## API

```
POST /openapi/v1/uns/read
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topics` | string[] | 是 | topic 路径列表，支持通配符 |
| `include_metadata` | boolean | 否 | 是否同时返回 topicType、fields（字段定义）、description 等元数据。**不确定 topic 有哪些字段时建议带上** |
| `max_depth` | int64 | 否 | 通配符展开时的最大递归深度 |

> **建议**：第一次读取某个不熟悉的 topic 时，加上 `"include_metadata": true`，可以同时看到该 topic 的字段定义（名称、类型、单位），方便后续写入时构造正确的 `value` 对象。

## 响应结构

响应遵循批量接口的 bulk 格式，每个 topic 独立成功/失败。**HTTP 200 + 外层 `code:200` 不代表所有 topic 成功，必须检查 `data.success`（整体）和 `data.results[i].success`（逐项）**：

```json
{
  "code": 200,
  "msg": "ok",
  "data": {
    "success": true,
    "results": [
      {
        "success": true,
        "topic": "Plant/Line1/Metric/Temperature",
        "result": {
          "value": { "temperature": 23.5, "unit": "C" },
          "quality": "Good",
          "timeStamp": 1733382000000
        }
      }
    ]
  }
}
```

### quality 4 档含义

| quality | 含义 | value 状态 |
|---------|------|-----------|
| `Good` | 值有效且新鲜 | 非 null |
| `Uncertain` | 值存在但可信度存疑 | 非 null |
| `Bad` | 值不可信 / 数据源断开 | `null` 或保留 last-known |
| `GoodNoData` | topic 已建模但还没收到任何数据 | `null` |

## 示例

### 读取单个 topic（多字段对象）

```bash
tier0 uns read Plant/Line1/Metric/Temperature
```

响应中 `value` 是完整的业务对象：

```json
{
  "success": true,
  "topic": "Plant/Line1/Metric/Temperature",
  "result": {
    "value": { "temperature": 27.5, "unit": "C", "humidity": 58.6 },
    "quality": "Good",
    "timeStamp": 1733382000000
  }
}
```

### 读取时同时查看字段定义（推荐首次读取时使用）

不确定 topic 有哪些字段、字段类型和单位时，加 `--meta`：

```bash
tier0 uns read Plant/Line1/Metric/Temperature --meta
```

响应中会额外包含 `metadata` 字段：

```json
{
  "success": true,
  "topic": "Plant/Line1/Metric/Temperature",
  "result": {
    "value": { "temperature": 27.5, "unit": "C", "humidity": 58.6 },
    "quality": "Good",
    "timeStamp": 1733382000000
  },
  "metadata": {
    "topicType": "METRIC",
    "description": "Line 1 temperature sensor",
    "fields": [
      { "name": "temperature", "type": "float", "unit": "°C" },
      { "name": "unit",        "type": "string" },
      { "name": "humidity",    "type": "float",  "unit": "%" }
    ]
  }
}
```

拿到 `fields` 后，即可按字段定义构造正确的写入 `value` 对象。

### 批量读取多个 topic

```bash
tier0 uns read Plant/Line1/Metric/Temperature Plant/Line1/State/MachineStatus
```

### 通配符读取（同层所有产线的温度）

```bash
# + 匹配一层：所有产线温度
tier0 uns read "Plant/+/Metric/Temperature" --json

# # 匹配剩余所有层：Line1 下所有数据
tier0 uns read "Plant/Line1/#" --json
```

### 处理异常 quality

当数据源断开时 `value` 为 `null`，`quality` 为 `Bad` 或 `GoodNoData`，需判断后再使用：

```json
{
  "success": true,
  "topic": "Plant/Line1/Metric/Temperature",
  "result": {
    "value": null,
    "quality": "Bad",
    "timeStamp": 1733381500000
  }
}
```

### 读取失败（topic 不存在）

外层 `code` 仍为 200，单项 `success` 为 `false`：

```json
{
  "success": false,
  "topic": "Plant/NotExist",
  "error": { "code": 404, "message": "Topic not found" }
}
```

## Windows PowerShell 注意

通配符 `+` / `#` 在 PowerShell 中需加引号：

```powershell
tier0 uns read Plant/Line1/Metric/Temperature
tier0 uns read "Plant/+/Metric/Temperature" --json
```
