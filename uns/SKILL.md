---
name: tier0-uns
version: 0.4.16
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
3. **write 前先查 schema** — 不确定 topic 字段时，先 `browse --path <path> --include-metadata` 查 `fields`（metric）或 `description`（action/state）；action/state 节点无 fields 约束，依赖 description 里的示例 payload 推断结构
4. **write 的 value 是对象，不是标量** — 写入格式为 `{"value":{"field1":val1,...}}`，不要直接写数字或字符串
5. **history 参数复杂，必读文档** — 时间戳单位（秒/毫秒）、聚合参数极易出错，读 `references/history.md` 后再执行
6. **delete 分软删除和硬删除** — 硬删除（`hard_delete: true`）不可逆，除非用户明确要求，默认用软删除
7. **不要用 search 替代 browse** — search 是关键词检索，browse 是结构浏览；探索树形结构用 browse，找已知名称用 search
8. **create 必读 `references/create.md`** — 单节点用 `--topic`；多个节点或复杂树用 `--file`。**路径不会自动插入 `Metric`/`Action`/`State`**，数据点路径必须已含类型目录（如 `.../Metric/ProductionCount`）。**`--topic-type` 不是字段类型**（`int`/`float` 写在 `--fields`）

## Topic 类型定义

UNS 叶子节点（`type=file`）的 `topicType` 有且仅有三种，含义严格区分：

| topicType | 用途 | 存储格式 | 典型示例 |
|-----------|------|---------|---------|
| **metric** | **设备实时数据** — 传感器采集、生产过程的时序数据，持续产生、有历史记录 | **单层 JSON**（字段扁平，不支持嵌套） | 产量、温度、压力、库存数量、设备运行状态 |
| **action** | **对外集成接口（下行请求）** — 由 UNS 发出的命令/请求，触发下游系统执行操作 | **JSONB**（支持任意层级嵌套） | 工单下发、报工指令、出入库操作、设备控制命令 |
| **state** | **接口结果（上行回执）** — 外部系统返回的操作结果或当前状态快照，不是时序流 | **JSONB**（支持任意层级嵌套） | 工单执行结果、出入库确认、设备连接状态、报警状态 |

> **字段约束**：`metric` 节点的 `--fields` 必须是单层扁平结构（不可嵌套）；`action`/`state` 节点以 JSONB 存储，结构自由，`--fields` 可省略。
>
> **路径约定**（强制）：叶子节点路径的倒数第二段必须与 `topicType` 一致，CLI 会校验并报错：
> - `Plant/Line1/Metric/ProductionCount` ✓
> - `Plant/WMS/Action/StockOut` ✓
> - `Plant/MES/State/WorkOrderStatus` ✓
> - `Plant/Line1/ProductionCount`（缺少类型目录）✗

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
| 创建节点 | **必读** `references/create.md` | — | 单节点 `--topic`；批量/树 `--file`；不自动插类型目录 |
| 更新节点元数据 | `references/update.md` | — | 修改字段定义或描述 |
| 删除节点 | `references/delete.md` | ⚠️ 硬删除不可逆 | 软删除可恢复，硬删除永久清除 |
| 恢复已删除节点 | `references/restore.md` | — | 撤销软删除 |
| 服务信息/健康检查 | `../info/info.md` | — | 网关连通性验证 |

## 任务选路

| 用户意图 | 正确路线 | 不要误走 |
|---------|---------|---------|
| 探索有哪些设备/路径 | `browse` 从根路径逐层展开 | 不要用 `search` 遍历（search 是关键词检索） |
| 知道名字，找完整路径 | `search` 按关键词定位 | 不要逐层 browse（低效） |
| 查当前实时值 | `read`（需完整 topic 路径） | 不要用 `history`（history 是时序归档） |
| 查历史趋势 | **先读 `references/history.md`**，再执行 | 不要循环 `read`（read 只返回最新值） |
| 写入数据 | `write`，value 是 `{"field":val}` 对象 | 不要写标量（`"value": 27.5` 是错误的） |
| 修改节点字段定义 | `update` | 不要用 `write`（write 是写 VQT 数据） |
| 创建单个数据点 | **必读 `references/create.md`**，`--topic .../Metric/<name> --type topic` | 不要用 `--topic-type int`；不要省略路径中的 `Metric` |
| 创建多个并列节点 | **`--file`** 传 JSON 数组 | `--topic` 一次只建一个节点 |
| 创建整棵工厂/产线树 | **`--file`** + `children` 嵌套 | 不要多次重复调用以为能批量 |
| 在已有路径下追加节点 | `--parent <已有路径> --topic Metric/<name> --type topic` | 不要假设会自动补父路径或 Metric |
| 同时了解数据来源（Flow） | UNS 操作后追加 `tier0 flow list --keyword <name>` | 不要只查一侧 |
