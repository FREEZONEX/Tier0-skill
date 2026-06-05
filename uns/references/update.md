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

### fields 更新规则（重要）

`fields` 是**全量替换**（Replace）策略，传入的列表会完整覆盖原有 schema。但不同节点类型有严格限制：

| 操作 | Metric 节点 | State / Action 节点 |
|------|------------|-------------------|
| 新增 field | ✅ 允许 | ✅ 允许 |
| 删除 field（传入列表少于原有） | ❌ **报错** | ✅ 允许 |
| 修改 field 类型（type） | ❌ **报错** | ❌ **报错** |
| 修改 field 单位（unit） | ✅ 允许 | ✅ 允许 |
| 重命名 field（改 name） | ❌ 等价于删旧增新，**报错** | ⚠️ 等价于删旧增新 |

**Metric 节点是 add-only**：只能在原有 fields 基础上追加新字段，必须把原有 fields 完整传入，不能减少，不能改类型，不能改名。

> **操作示例（Metric 新增字段）：**
> 原有 fields：`[{name:"temperature", type:"float"}]`
> 正确做法：传入 `[{name:"temperature", type:"float"}, {name:"humidity", type:"float"}]`（包含原有字段 + 新增字段）
> 错误做法：只传 `[{name:"humidity", type:"float"}]`（缺少原有字段 temperature，会报错 `metric schema 不允许删除字段: temperature`）

**后端错误信息对照：**
- `metric schema 不允许删除字段: {字段名}` — Metric 节点传入的 fields 少于原有
- `metric定义不能为空` — Metric 节点传入空 fields
- `字段类型不能修改: {字段名}` — 修改了同名字段的 type

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
tier0 uns update --path factory/line1/sensor/temp --description "生产线1温度传感器"

# 同时更新显示名称和描述
tier0 uns update --path factory/line1/sensor/temp --display-name "温度传感器" --description "生产线1温度监控"
```

## 典型场景

**复杂更新（含字段定义），使用 API 文件法：**
```bash
tier0 api POST /openapi/v1/uns/update --body-file update.json
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
tier0 uns update --path factory/line1/sensor/temp --description "温度传感器"
```
