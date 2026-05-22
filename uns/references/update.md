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
tier0 uns update --path factory/line1/sensor/temp --desc "生产线1温度传感器"

# 同时更新显示名称和描述
tier0 uns update --path factory/line1/sensor/temp --display-name "温度传感器" --desc "生产线1温度监控"
```

## 典型场景

**复杂更新（含字段定义）：**
```bash
tier0 uns update --file update.json
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

## Windows PowerShell

```powershell
tier0 uns update --path factory/line1/sensor/temp --desc "温度传感器"
# 或复杂更新用文件法
tier0 uns update --file update.json
```
