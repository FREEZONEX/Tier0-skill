---
name: tier0-uns
version: 0.3.0
description: "Tier0 UNS（Unified Namespace）数据面操作。支持命名空间浏览、节点读写、历史数据查询、搜索、创建、更新、删除、恢复。triggers: Tier0, UNS, 命名空间, 数据读写, 历史查询"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, namespace, data, read, write, history]
---

# tier0-uns — UNS 数据面操作

## 何时使用本 Skill

### 应该使用

- 用户要浏览 UNS 树形结构（查看有哪些设备、路径）
- 用户要读取某个数据点的当前值（实时值查询）
- 用户要写入数据点（发布数据）
- 用户要查询历史/时序数据
- 用户按名称搜索 topic
- 用户要创建、更新、删除、恢复 UNS 节点

### 不应该使用

- 用户询问 Node-RED 节点如何配置 → 走 `flow/SKILL.md`（Flow 是数据的采集管道）
- 用户要查看 Flow 状态（running/stopped）→ 走 `flow/references/list.md`
- 用户说"查一下 modbus-collector 的数据" → **同时查** UNS（read/browse）和 Flow（list），因为两者通常同名关联

## 不可违反规则

1. **先 browse 定位，再 read** — 不知道完整 topic 路径时，先 `browse` 找路径，再 `read` 取值；不要猜测 topic 路径
2. **read/write 操作只能用完整路径（叶子节点）** — 中间路径段（如 `Plant/Line1`）是文件夹，不能 read/write，只能 browse
3. **write 的 value 是对象，不是标量** — 写入格式为 `{"value":{"field1":val1,...}}`，不要直接写数字或字符串
4. **history 参数复杂，必读文档** — 时间戳单位（秒/毫秒）、聚合参数极易出错，读 `references/history.md` 后再执行
5. **delete 分软删除和硬删除** — 硬删除（`hard_delete: true`）不可逆，除非用户明确要求，默认用软删除
6. **不要用 search 替代 browse** — search 是关键词检索，browse 是结构浏览；探索树形结构用 browse，找已知名称用 search

## 子技能路由

> **路径辨别规则**：用户给出的路径若不到叶子节点（如 `Plant/Line1`），是文件夹，用 browse；完整到数据点（如 `Plant/Line1/Metric/Temperature`）才能 read/write。
> **关联提示**：用户按名称询问某设备/数据时，UNS topic 和 Flow 通常同名，查完 UNS 后也应查 `tier0 flow list --keyword <name>`，除非用户明确只需要其中一侧。

| 意图 | 加载文件 | 风险 | 说明 |
|------|---------|------|------|
| 浏览命名空间树 | `references/browse.md` | — | 获取文件夹下的子节点列表、层级结构 |
| 读取数据点当前值 | `references/read.md` | — | 实时 VQT 值查询，支持通配符 |
| 写入数据点 | `references/write.md` | — | 发布数据，value 必须是对象 |
| 查询历史/时序数据 | **必读** `references/history.md` | — | 时间戳参数复杂，必读后执行 |
| 搜索节点 | `references/search.md` | — | 按关键字/前缀搜索 |
| 创建节点 | `references/create.md` | — | 新建 folder 或 thing 节点 |
| 更新节点元数据 | `references/update.md` | — | 修改字段定义或描述 |
| 删除节点 | `references/delete.md` | ⚠️ 硬删除不可逆 | 软删除可恢复，硬删除永久清除 |
| 恢复已删除节点 | `references/restore.md` | — | 撤销软删除 |
| 服务信息/健康检查 | `references/info.md` | — | 网关连通性验证 |

## 任务选路

| 用户意图 | 正确路线 | 不要误走 |
|---------|---------|---------|
| 探索有哪些设备/路径 | `browse` 从根路径逐层展开 | 不要用 `search` 遍历（search 是关键词检索） |
| 知道名字，找完整路径 | `search` 按关键词定位 | 不要逐层 browse（低效） |
| 查当前实时值 | `read`（需完整 topic 路径） | 不要用 `history`（history 是时序归档） |
| 查历史趋势 | **先读 `references/history.md`**，再执行 | 不要循环 `read`（read 只返回最新值） |
| 写入数据 | `write`，value 是 `{"field":val}` 对象 | 不要写标量（`"value": 27.5` 是错误的） |
| 修改节点字段定义 | `update` | 不要用 `write`（write 是写 VQT 数据） |
| 同时了解数据来源（Flow） | UNS 操作后追加 `tier0 flow list --keyword <name>` | 不要只查一侧 |
