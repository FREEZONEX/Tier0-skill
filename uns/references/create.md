---
name: tier0-uns-create
version: 0.4.0
description: "在 UNS 命名空间中创建节点。triggers: Tier0, UNS, 创建, 节点, 命名空间"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, create, namespace]
---

# create — 创建节点

## 说明

在 UNS 命名空间中创建节点（文件夹或数据点）。支持单条路径创建和多级 `children` 树。

## API

```
POST /openapi/v1/uns/create
```

## CLI

```bash
tier0 uns create [flags]
```

| 参数 | 说明 |
|------|------|
| `--topic` / `-t` | 点位路径或叶子名（**仅支持单节点**）；中间段自动建为 `folder`；**多节点请用 `--file`** |
| `--parent` | 父路径前缀，与 `--topic` 拼接（如 `--parent Plant --topic Line1` → `Plant/Line1`） |
| `--type` | 节点类型：`folder` / `FOLDER` / `file`；或 `METRIC` / `ACTION` / `STATE`（会映射为 `file` + `topicType`） |
| `--topic-type` | 文件节点的 topic 类型（`metric` / `action` / `state`），`--type METRIC` 时可省略 |
| `--display-name` / `-d` | 显示名称 |
| `--description` | 描述 |
| `--alias` | 别名 |
| `--fields` | Schema 字段 JSON 数组 |
| `--file` / `-f` | 从 JSON 文件读取（支持 `{"namespace":[...]}` 或裸数组 `[...]`）；**批量创建多个节点必须使用此方式** |

## 请求体（API / --file）

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `namespace` | NamespaceNode[] | 是 | 节点定义列表 |

### NamespaceNode

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | **单段**节点名（不能含 `/`） |
| `type` | string | 是 | `folder` / `file`（或 `path` / `topic`）；不要用 `thing` |
| `alias` | string | 否 | 别名 |
| `description` | string | 否 | 描述 |
| `displayName` | string | 否 | 显示名称 |
| `extendProperties` | object | 否 | 扩展属性 |
| `fields` | SchemaField[] | 否 | 字段定义（`file` 节点） |
| `topicType` | string | 否 | `metric` / `action` / `state`（`file` 节点必填或由路径推导） |
| `children` | NamespaceNode[] | 否 | 子节点（多级结构） |

### SchemaField

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 字段名称 |
| `type` | string | 是 | `float` / `int` / `string` / `bool`（或 `DOUBLE` 等） |
| `unit` | string | 否 | 单位 |

## 示例

### 单路径创建（自动补全中间 folder）

```bash
# 创建 Metric 数据点：自动创建 Plant、Line1、Metric 文件夹，再创建 Temperature
tier0 uns create --topic Plant/Line1/Metric/Temperature --type METRIC \
  --fields '[{"name":"value","type":"float","unit":"°C"}]'

# 只建一层 folder
tier0 uns create --topic Plant/Line1 --type FOLDER --display-name "Line 1"

# 在已有 Plant/Line1 下创建（倒数第二段必须是 metric/action/state）
tier0 uns create --parent Plant/Line1 --topic Metric/Temp --type METRIC
```

### 批量创建多个节点

`--topic` 只支持单节点。批量创建请用 `--file`，结构清晰、不易出错：

```bash
tier0 uns create --file structure.json
```

`structure.json`：

```json
[
  {"name": "Line1", "type": "folder"},
  {"name": "Line2", "type": "folder"},
  {"name": "Line3", "type": "folder"}
]
```

或带完整层级：

```json
{
  "namespace": [{
    "name": "Plant", "type": "folder", "children": [{
      "name": "Line1", "type": "folder", "children": [
        {"name": "Metric", "type": "folder", "children": [
          {"name": "Temperature", "type": "file", "topicType": "metric",
           "fields": [{"name": "value", "type": "float", "unit": "°C"}]},
          {"name": "Humidity",    "type": "file", "topicType": "metric",
           "fields": [{"name": "value", "type": "float", "unit": "%RH"}]}
        ]}
      ]}
    ]}
  ]}
}
```

### 从文件批量创建多级结构

```bash
tier0 uns create --file structure.json
```

`structure.json`（两种格式均可）：

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
            {
              "name": "temp",
              "type": "file",
              "topicType": "metric",
              "fields": [{"name": "value", "type": "float", "unit": "°C"}]
            },
            {
              "name": "humidity",
              "type": "file",
              "topicType": "metric",
              "fields": [{"name": "value", "type": "float", "unit": "%RH"}]
            }
          ]
        }
      ]
    }
  ]
}
```

### 直接调 API（高级）

```bash
tier0 api POST /openapi/v1/uns/create --body-file structure.json
```

## 规则

1. **`name` 不能含 `/`** — 多级用 `children` 或 CLI `--topic` 路径自动展开。
2. **`--type METRIC/ACTION/STATE` 时，路径倒数第二段必须是对应的类型文件夹**（`metric` / `action` / `state`），否则报错。例：`Plant/Line1/Metric/Temperature` ✓，`Plant/Line1/Temperature` ✗。CLI 不会自动补充，`--file` 模式同理。
3. **`--type METRIC`** 会映射为 `type=file` + `topicType=metric`。
3. **已存在的同名 folder** 会被复用，不会报错（后端 `createOrReusePath`）。
4. 复杂结构优先用 `--file`；PowerShell 下避免内联大段 JSON。
5. **`--file` 与 `--topic`/`--type`/`--parent` 互斥** — 同时传会报错；需要给中间 folder 加元数据时，也请用 `--file`。
6. **`--display-name`/`--description`/`--alias` 只作用于叶子节点** — `--topic` 路径中间自动生成的 folder 不会附带这些字段；如需给中间层加元数据，请用 `--file` 提供完整树结构。

## Windows PowerShell

```powershell
tier0 uns create --file structure.json
```
