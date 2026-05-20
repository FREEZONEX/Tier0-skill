---
name: tier0-uns-create
version: 0.3.0
description: "在 UNS 命名空间中创建节点。triggers: Tier0, UNS, 创建, 节点, 命名空间"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, create, namespace]
---

# create — 创建节点

## 说明

在 UNS 命名空间中创建一个新的节点（文件夹或数据点）。

## API

```
POST /openapi/v1/uns/create
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `namespace` | NamespaceNode[] | 是 | 节点定义列表 |

### NamespaceNode

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 节点名称 |
| `type` | string | 是 | 节点类型（`folder` / `thing`） |
| `alias` | string | 否 | 别名 |
| `description` | string | 否 | 描述 |
| `displayName` | string | 否 | 显示名称 |
| `extendProperties` | object | 否 | 扩展属性 |
| `fields` | SchemaField[] | 否 | 字段定义列表 |
| `topicType` | string | 否 | 主题类型 |
| `children` | NamespaceNode[] | 否 | 子节点列表 |

### SchemaField

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 字段名称 |
| `type` | string | 是 | 字段类型（`float` / `int` / `string` / `bool`） |
| `unit` | string | 否 | 单位 |

## 示例

```bash
# 创建文件夹节点
tier0 api /openapi/v1/uns/create --body '{"namespace":[{"name":"sensor","type":"folder"}]}'

# 创建带字段的数据点节点
tier0 api /openapi/v1/uns/create --body '{"namespace":[{"name":"temp","type":"thing","fields":[{"name":"value","type":"float","unit":"°C"}]}]}'
```

## 典型场景

**批量创建层级结构：**
```bash
tier0 api /openapi/v1/uns/create --body-file structure.json
```

`structure.json` 内容：
```json
{
  "namespace": [
    {
      "name": "factory",
      "type": "folder",
      "children": [
        {
          "name": "line1",
          "type": "folder",
          "children": [
            {"name": "temp", "type": "thing", "fields": [{"name": "value", "type": "float", "unit": "°C"}]},
            {"name": "humidity", "type": "thing", "fields": [{"name": "value", "type": "float", "unit": "%RH"}]}
          ]
        }
      ]
    }
  ]
}
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：

```powershell
# 复杂结构统一用文件法
@'
{"namespace":[{"name":"sensor","type":"folder"}]}
'@ | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/create --body-file body.json
```
