---
name: tier0-uns-create
version: 0.4.16
description: "在 UNS 命名空间中创建节点。triggers: Tier0, UNS, 创建, 节点, 命名空间, 批量创建"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, create, namespace]
---

# uns create — 创建命名空间节点

## 命令

```bash
# 创建一个 topic（数据点）
tier0 uns create \
  --topic "Factory1/Assembly/Line1/Station1/Metric/ProductionCount" \
  --type topic \
  --display-name "当前产量" \
  --fields '[{"name":"value","type":"int"}]' \
  --json

# 父路径已存在，只建子节点
tier0 uns create \
  --parent "Factory1/Assembly/Line1/Station1" \
  --topic "Metric/ProductionCount" \
  --type topic \
  --fields '[{"name":"value","type":"int"}]'

# 创建 path（目录）
tier0 uns create \
  --topic "Factory1/Assembly/Line1" \
  --type path \
  --display-name "产线1"

# 从 JSON 文件批量创建整棵树
tier0 uns create --file structure.json
```

## 返回值

成功后输出创建的完整路径（`--topic` 模式）或 `Namespace created.`（`--file` 模式）。
加 `--json` 可获取 API 原始响应。

### 响应结构（`--json` 模式）

create 是批量接口，后端将树结构展开为多条叶子节点逐一处理。**HTTP 200 + 外层 `code:200` 不代表全部成功，必须检查 `data.success`（整体）和 `data.results[i].success`（逐项）**：

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "success": true,
    "results": [
      {
        "success": true,
        "topic": "Factory1/Metric/ProductionCount",
        "result": {}
      }
    ]
  }
}
```

部分节点失败时（如路径冲突、格式不合法）：

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "success": false,
    "results": [
      { "success": true,  "topic": "Factory1/Metric/ProductionCount", "result": {} },
      { "success": false, "topic": "Factory1/Metric/BadNode",
        "error": { "code": 400, "message": "segment before leaf must be a type folder" } }
    ]
  }
}
```

## 参数

| 参数 | 必填 | 说明 |
|------|------|------|
| `--topic` / `-t` | 与 `--type` 同用 | 节点路径或叶子名；与 `--parent` 拼接后成完整路径 |
| `--parent` | 否 | 已有父路径前缀，用于复用现有路径前缀 |
| `--type` | 与 `--topic` 同用 | 节点类型：`path`（目录）；或 `METRIC` / `ACTION` / `STATE`（数据点，含义见下表） |
| `--display-name` / `-d` | 否 | 显示名称 |
| `--description` | 否 | 描述 |
| `--alias` | 否 | 别名 |
| `--fields` | 否 | Schema 字段定义，JSON 数组；**METRIC 只支持单层扁平字段**；ACTION/STATE 存 JSONB 无需定义 Schema，可省略 |
| `--file` / `-f` | 与 `--topic` 互斥 | JSON 文件：`{"namespace":[...]}` 或裸数组 `[...]` |

## 数据点类型（topicType）

| --type | topicType | 含义 | 存储格式 | 典型场景 |
|--------|-----------|------|---------|---------|
| `METRIC` | `metric` | **设备实时数据** — 传感器/过程量，持续产生、有时序历史 | **单层 JSON**，字段必须扁平，不可嵌套 | 产量、温度、压力、库存数量 |
| `ACTION` | `action` | **对外集成接口（下行请求）** — 由 UNS 发出的命令，触发下游系统执行 | **JSONB**，支持任意层级嵌套 | 工单下发、报工指令、出入库操作、设备控制命令 |
| `STATE` | `state` | **接口结果（上行回执）** — 外部系统返回的操作结果或当前状态快照 | **JSONB**，支持任意层级嵌套 | 工单执行结果、出入库确认、设备连接状态、报警状态 |

## 路径规则

UNS 每个 topic（数据点）节点的路径结构固定为：

```
<任意层 folder> / Metric|Action|State / <叶子名>
                     └── 类型目录（倒数第二段）
                                           └── topic 节点（最后一段）
```

- 倒数第二段必须是类型目录之一：`Metric`、`Action`、`State`（大小写不敏感）
- `topicType` 直接从该段推导，无需手动指定
- **不会自动插入**类型目录——路径中没写的段不会出现

| 类型目录 | `topicType` | 语义 |
|---------|-------------|------|
| `Metric` | `metric` | 采集量、测量值 |
| `Action` | `action` | 控制指令、执行动作 |
| `State` | `state` | 状态标志、模式 |

## 行为说明

- **`--topic` 展开为树**：`Plant/Line1/Metric/Temp` 中每一段都会建为 folder，只有最后一段是 topic 节点
- **`--topic` 一次建一个叶子**：不要用它批量建并列节点，并列场景用 `--file`
- **`--parent` + `--topic` 拼接**：`--parent A/B --topic Metric/Count` 等价于 `--topic A/B/Metric/Count`
- **中间 folder 的元数据**（displayName 等）只能通过 `--file` + `children` 表达；`--display-name` 只作用于叶子
- **已存在的同名 folder** 会复用，不报错
- **`--topic-type` 已废弃**：topicType 从路径自动推导；旧参数仍被接受但会打印警告
- **`description` 应包含写入示例**（强烈建议）：action/state 节点没有 `fields` 约束，写入时 agent 只能从 description 推断 payload 结构；建议格式：`"说明。示例: {\"field\":value}"`；metric 节点有 fields 定义，description 可补充单位/业务含义

## 推荐场景

- 用户说"在 Station1 下创建一个产量数据点"→ 使用 `--parent Station1 --topic Metric/ProductionCount --type topic`
- 用户给出设备层级，需要批量建完整树 → 用 `--file structure.json`（见下方 JSON 示例）
- 只建目录结构，暂不建数据点 → `--type path`，路径无需包含类型目录

## JSON 文件格式（`--file`）

```json
{
  "namespace": [
    {
      "name": "Factory1",
      "type": "path",
      "children": [
        {
          "name": "Metric",
          "type": "path",
          "children": [
            {
              "name": "ProductionCount",
              "type": "topic",
              "topicType": "metric",
              "displayName": "当前产量",
              "fields": [{"name": "value", "type": "int"}]
            }
          ]
        },
        {
          "name": "Action",
          "type": "path",
          "children": [
            {
              "name": "Start",
              "type": "topic",
              "topicType": "action",
              "description": "启动工单指令。示例: {\"order_id\":\"WO-001\",\"product\":\"SKU-A\",\"qty\":100}"
            }
          ]
        }
      ]
    }
  ]
}
```

裸数组也支持：`[{"name":"Line1","type":"path"}, ...]`

### NamespaceNode 字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 单段名称，不含 `/` |
| `type` | string | 是 | `path`（目录）或 `topic`（数据点） |
| `topicType` | string | topic 时必填 | `metric` / `action` / `state` |
| `fields` | SchemaField[] | 否 | 数据点字段定义 |
| `displayName` | string | 否 | 显示名 |
| `description` | string | 否 | 描述 |
| `alias` | string | 否 | 别名 |
| `children` | NamespaceNode[] | 否 | 子节点 |

### SchemaField

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 字段名 |
| `type` | string | `int` / `float` / `string` / `bool` 等 |
| `unit` | string | 单位（可选） |

## 常见错误

| 现象 | 原因 | 处理 |
|------|------|------|
| `segment before leaf must be a type folder` | 路径叶子前一段不是 Metric/Action/State | 在叶子名前补类型目录，如 `.../Metric/ProductionCount` |
| `a topic node needs at least two segments` | 路径只有一段，缺少类型目录 | 至少写 `Metric/Count`，不能只写 `Count` |
| `--type "" is not valid` | `--type` 漏填或拼错 | 只接受 `path` 或 `topic` |
| PowerShell 下 JSON 解析失败 | 内联 JSON 转义问题 | 改用 `--fields` 值写入文件，再 `--file` 传入 |

## API

```
POST /openapi/v1/uns/create
```

直接调用：

```bash
tier0 api POST /openapi/v1/uns/create --body-file structure.json
```

## 参考

- [uns SKILL.md](../SKILL.md) — UNS 全部命令
