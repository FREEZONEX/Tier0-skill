---
name: tier0-uns-write
version: 0.3.0
description: "向 UNS topic 写入数据（对象值）。triggers: Tier0, UNS, 写入, 数据点, 发布, 上报"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, write, data]
---

# write — 写入数据点

## 说明

向一个或多个 UNS topic 写入值。**不支持通配符**，必须明确指定 topic。

`value` 是业务数据对象，需符合该 topic 已声明的 `fields` 定义（若有）。写入成功仅代表 MQTT Broker 已收到，不代表下游执行完成——如需确认结果请用 `/read` 查对应 State topic。

> **注意**：写入时平台自动将 `quality` 置为 `Good`，调用方不需要（也不应该）传 `quality` 字段。

## API

```
POST /openapi/v1/uns/write
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `writes` | WriteItem[] | 是 | 写入项列表 |
| `qos` | int64 | 否 | MQTT QoS 等级（0 / 1 / 2），默认 0，全局作用于本次所有写入 |
| `retain` | boolean | 否 | 是否设置 MQTT retain 标志，默认 false |

### WriteItem

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topic` | string | 是 | 目标 topic，不支持通配符 |
| `value` | object | 是 | 写入值，通常是包含多个字段的对象 |
| `timeStamp` | int64 | 否 | 毫秒时间戳，默认服务端当前时间 |

## 示例

### 写入多字段对象（典型 OT 场景）

```bash
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"Plant/Line1/Metric/Temperature","value":{"temperature":27.5,"unit":"C","humidity":58.6}}]}'
```

### 写入业务状态对象（IT 场景）

```bash
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"Plant/Warehouse/State/OrderStatus","value":{"pending":42,"processing":15}}]}'
```

### 触发动作指令

```bash
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"Plant/Line1/Action/EmergencyStop","value":{"command":"stop","reason":"温度超阈值","triggered_by":"agent"}}]}'
```

### 批量写入（含 QoS 和 retain）

```bash
tier0 api /openapi/v1/uns/write --body-file writes.json
```

`writes.json` 内容：
```json
{
  "writes": [
    {
      "topic": "Plant/Line1/Metric/Temperature",
      "value": { "temperature": 27.5, "unit": "C", "humidity": 58.6 }
    },
    {
      "topic": "Plant/Warehouse/Metric/StockLevel",
      "value": { "sku_A": 120, "sku_B": 8 }
    }
  ],
  "qos": 1,
  "retain": true
}
```

## 响应结构

```json
{
  "code": 200,
  "msg": "ok",
  "data": {
    "success": true,
    "results": [
      { "success": true, "topic": "Plant/Line1/Metric/Temperature", "result": null }
    ]
  }
}
```

单条失败（schema 校验不通过）不影响其他条：

```json
{
  "success": false,
  "topic": "Plant/Warehouse/Metric/StockLevel",
  "error": { "code": 400, "message": "Schema validation failed: sku_A must be integer" }
}
```

## 确认写入结果

写入成功 ≠ 下游执行完成，如需验证请用 read 查 State topic：

```bash
# 写入动作后，读取状态确认
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"Plant/Line1/Action/EmergencyStop","value":{"command":"stop"}}]}'
tier0 api /openapi/v1/uns/read --body '{"topics":["Plant/Line1/State/MachineStatus"]}'
```

## Windows PowerShell 简写

```powershell
# 多字段对象 — 用文件法（最稳妥）
@'
{
  "writes": [
    {
      "topic": "Plant/Line1/Metric/Temperature",
      "value": { "temperature": 27.5, "unit": "C", "humidity": 58.6 }
    }
  ]
}
'@ | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/write --body-file body.json
```
