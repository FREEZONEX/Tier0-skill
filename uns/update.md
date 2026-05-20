---
name: tier0-uns-update
version: 0.3.0
description: "更新 UNS 命名空间中的节点信息。triggers: Tier0, UNS, 更新, 节点"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, update, namespace]
---

# update — 更新节点

## 说明

更新 UNS 命名空间中指定节点的元数据、字段定义等属性。

## API

```
POST /openapi/v1/uns/update
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `path` | string | 是 | 节点路径 |
| `name` | string | 否 | 新名称 |
| `alias` | string | 否 | 别名 |
| `description` | string | 否 | 描述 |
| `displayName` | string | 否 | 显示名称 |
| `extendProperties` | object | 否 | 扩展属性 |
| `fields` | SchemaField[] | 否 | 字段定义列表 |
| `updateMask` | string[] | 否 | 指定要更新的字段列表（推荐明确指定） |

### SchemaField

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 字段名称 |
| `type` | string | 是 | 字段类型 |
| `unit` | string | 否 | 单位 |

## 示例

```bash
# 更新节点描述
tier0 api /openapi/v1/uns/update --body '{"path":"factory/line1/sensor/temp","description":"生产线1温度传感器","updateMask":["description"]}'

# 更新节点字段
tier0 api /openapi/v1/uns/update --body '{"path":"factory/line1/sensor/temp","fields":[{"name":"value","type":"float","unit":"°C"}],"updateMask":["fields"]}'
```

## 典型场景

**同时更新描述和显示名称：**
```bash
tier0 api /openapi/v1/uns/update --body-file update.json
```

`update.json` 内容：
```json
{
  "path": "factory/line1/sensor/temp",
  "displayName": "温度传感器",
  "description": "生产线1温度监控",
  "updateMask": ["displayName", "description"]
}
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：

```powershell
# 文件法（含 updateMask 时推荐）
@'
{"path":"factory/line1/sensor/temp","description":"温度传感器","updateMask":["description"]}
'@ | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/update --body-file body.json
```
