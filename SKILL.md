---
name: tier0-cli
version: 0.3.2
description: "Tier0 Cloud 平台 CLI 统一入口。涵盖 UNS（Unified Namespace）数据面操作：命名空间浏览、节点读写、历史数据查询、节点增删改；以及 Flow（Node-RED）管理：SourceFlow 协议采集 / EventFlow 业务处理流的创建、部署、画布导入导出。triggers: Tier0, Cloud, UNS, Flow, Node-RED, 命名空间, 数据读写, 设备数据, SourceFlow, EventFlow, 工作流"
metadata:
  requires:
    bins: ["tier0"]
  cliHelp: "tier0 help"
  openclaw:
    emoji: "☁️"
  hermes:
    tags: [api, cloud, uns, namespace, data, flow, nodered]
---

# tier0-cli — Tier0 Cloud Platform CLI

**⚠️ 前置条件：必须先安装 `tier0` CLI 并完成登录授权，否则无法调用任何 API。**

## 安装与初始化

### 第 1 步 安装 CLI + Skills（一键）

**推荐（跨平台，需要 Node.js >= 16）：**
```bash
npx @tier0/cli@latest install
```

> 一条命令同时安装 `tier0` CLI 二进制和 Cursor / Claude Agent Skills。

**备选 — macOS / Linux：**
```bash
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
# 然后单独安装 Skills：
npx skills add FREEZONEX/Tier0-skill
```

**备选 — Windows (PowerShell)：**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression
# 然后单独安装 Skills：
npx skills add FREEZONEX/Tier0-skill
```

### 第 3 步 配置（私有化部署必须执行，SaaS 跳过）

```bash
tier0 config --base-url https://your-tier0-instance.com
```

> **关键约束**：先 `config` 再 `login`，否则授权 URL 指向错误地址。

> **⚠️ 变更 base-url 后必须重新登录**：如果用户通过 `tier0 config --base-url` 修改了平台地址（例如从 SaaS 切换到私有化部署，或更换了实例），原有 API Key 对新地址无效，**必须重新执行完整的登录流程**：
> ```bash
> tier0 config --base-url https://new-instance.com
> tier0 login   # 或 tier0 config --api-key <新实例的 API Key>
> ```
> 不重新登录直接调用 API 会收到 `authentication` 错误（exit 3）。

### 第 4 步 登录授权

**方式 A — Agent 已持有 API Key（推荐）：**
```bash
tier0 config --api-key sk-per-xxxxxx
```

**方式 B — Device Flow（需要用户浏览器配合）：**

> **⚠️ CRITICAL：必须先把授权链接展示给用户，用户在浏览器完成授权后轮询才有意义。跳过此步直接轮询等同于永远超时。**

按以下两步执行：

```bash
# 第 1 步：获取授权 URL（立即返回，解析 setup_code）
tier0 login --no-wait --json
# 输出: {"status":"authorization_required","verification_url":"...","setup_code":"abc123","expires_in":600}
```

**必须立即把 `verification_url` 以可点击链接的形式展示给用户**，并明确告知用户需要在浏览器中打开该链接完成授权，然后**立即**执行第 2 步（无需等待用户回复）：

```bash
# 第 2 步：开始轮询（每 5 秒检测一次，最多等待 10 分钟）
tier0 login --setup-code <code>
# 用户浏览器授权后自动保存 API Key，轮询结束
```

> **说明**：第 2 步轮询会阻塞直到用户完成浏览器授权。Agent 无需在两步之间询问用户"是否完成"，但**第 1 步的授权链接必须展示**，否则用户无从授权，轮询永远不会成功。

### 语言切换

```bash
tier0 config --lang zh   # 切换中文
tier0 config --lang en   # 切换英文（默认）
# 或临时覆盖：
TIER0_LANG=zh tier0 flow list
```

## 核心概念

| 概念 | 说明 |
|------|------|
| Workspace | 租户工作区，所有资源的隔离单位 |
| UNS (Unified Namespace) | 统一命名空间，**树形路径结构**组织数据点 |
| Path（路径段） | 路径中的每一段都是**文件夹**，相当于目录层级。只有完整路径才对应一个 topic（数据点） |
| Topic | 完整路径字符串，如 `Plant/Line1/Metric/Temperature`。**只有叶子节点（`file` 类型数据点）才可 read/write**，中间路径段是 `folder` |
| Node | 命名空间中的节点：`folder`（文件夹）或 `file`（数据点，常配合 `topicType`: metric/action/state） |
| VQT | 数据点的值结构：`value`（业务对象）+ `quality`（数据质量）+ `timeStamp`（毫秒时间戳） |
| SourceFlow | Node-RED 实例，连接工业协议采集设备数据并发布 MQTT |
| EventFlow | Node-RED 实例，订阅 MQTT 消息对业务数据进行二次处理 |

> **Flow ↔ UNS Topic 关联**：Flow 名称（`flowName`）与 UNS topic 路径**通常同名**——SourceFlow 负责采集并写入对应 topic，EventFlow 负责订阅并处理该 topic 的数据。
> 当用户提到某个设备/数据点名称时，它**同时对应一个 UNS topic 和一个（或多个）Flow**，应同时查询两侧。
> ⚠️ **目前 API 尚未提供显式关联字段**，`topicmeta` 接口后续版本将加入关联信息，届时更新此文档。

## 资源关系

```
Workspace
├── UNS (Unified Namespace)
│   ├── Plant/                          ← folder（文件夹）
│   │   ├── Line1/                      ← folder
│   │   │   ├── Metric/                 ← folder
│   │   │   │   └── Temperature         ← file（数据点，完整 topic）
│   │   │   │       └── VQT { value: {"temperature":27.5,"unit":"C"},
│   │   │   │                 quality: "Good", timeStamp: 1733382000000 }
│   │   │   └── State/
│   │   │       └── MachineStatus       ← file（数据点）
│   │   └── Line2/
│   │       └── ...
└── Flow
    ├── SourceFlow "Line1-Collector"     ← 同名关联: 采集 → 写入 Plant/Line1/...
    └── EventFlow  "Line1-Processor"     ← 同名关联: 订阅 Plant/Line1/... → 处理
```

**Flow ↔ UNS 名称对应规则**（当前版本约定，`topicmeta` 关联 API 尚在开发中）：
- Flow `flowName` 与 UNS 路径**人为保持同名**，如 `Line1-Collector` 对应路径 `Plant/Line1/...`
- **遇到名称查询时，必须同时查 `tier0 flow list --keyword <name>` 和 `tier0 uns browse`**

**关键规则**：
- `browse` / `search` 操作的对象是**路径段（文件夹）**
- `read` / `write` / `history` 操作的对象是**完整 topic（叶子数据点）**
- 写入时 `value` 是符合该 topic 字段定义的**对象**，不是标量
- 中间路径段（如 `Plant/Line1`）不能直接 read/write，只能 browse

## 子技能路由

根据用户意图，**必须先读取对应子文档，再执行命令**。

### UNS — 统一命名空间

> **路径辨别规则**：用户给出的路径若不到叶子节点（如 `Plant/Line1`），是文件夹，用 browse；完整到数据点（如 `Plant/Line1/Metric/Temperature`）才能 read/write。
> **关联提示**：用户按名称询问某设备/数据的情况时，UNS topic 和 Flow 通常同名，查完 UNS 后也应查 `tier0 flow list --keyword <name>`，除非用户明确只需要其中一侧。

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 浏览命名空间树 | `uns/references/browse.md` | 获取文件夹下的子节点列表、层级结构 |
| 读取数据点当前值 | `uns/references/read.md` | 实时 VQT 值查询，支持通配符 |
| 写入数据点 | `uns/references/write.md` | 发布数据，value 必须是对象 |
| 查询历史/时序数据 | **必读** `uns/references/history.md` | 历史记录、聚合查询（时间戳参数复杂，必读后执行） |
| 搜索节点 | `uns/references/search.md` | 按关键字/前缀搜索 |
| 创建节点 | **必读** `uns/references/create.md` | 单节点 `--topic`；批量/树 `--file`；路径须含 Metric/Action/State |
| 更新节点 | `uns/references/update.md` | 修改元数据或字段定义 |
| 删除节点 | `uns/references/delete.md` | 软删除或硬删除（⚠️ 不可逆） |
| 恢复已删除节点 | `uns/references/restore.md` | 撤销软删除 |

### Auth / Info — 认证与服务信息

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 服务信息/健康检查 | `info/info.md` | 网关连通性验证 |
| API Key 身份/权限诊断 | `auth/whoami.md` | 查看当前 API Key 的用户、Workspace、角色和权限 |

### Flow — Node-RED 管理

**CRITICAL — 执行 `deploy` 前 MUST 先读 `flow/references/deploy.md`，禁止直接盲目调用。**
**CRITICAL — 执行 `delete` 前 MUST 先用 `tier0 flow get --id <id>` 确认 Flow 存在。**
**CRITICAL — 用户按名称询问 Flow 相关数据时，MUST 同时查询 UNS（browse/read）和 Flow（list/get），因为两者通常同名关联。**

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 查询可用节点 / 构造 flowsJson 前 | `flow/references/nodes.md` | 节点查询接口和常用 type 字符串速查 |
| 列出 / 查看 Flow | `flow/references/list.md` | 列表、类型过滤、详情 |
| 创建 Flow | `flow/references/create.md` | 新建 SourceFlow 或 EventFlow |
| 更新 Flow 元数据 | `flow/references/update.md` | 重命名、描述、收藏 |
| 删除 Flow | `flow/references/delete.md` | 单个或批量删除（⚠️ 会停止 Node-RED 容器） |
| 导出 Node-RED 画布 | `flow/references/data.md` | 获取 flowsJson 到文件 |
| 部署 Node-RED 画布 | **必读** `flow/references/deploy.md` | 上传并激活 flowsJson（会替换所有节点配置） |

## 任务选路心智模型

根据用户意图选正确命令，避免走错路径：

| 用户意图 | 正确命令 | 不要误走 |
|---------|---------|---------|
| 探索有哪些设备/数据点 | `uns/references/browse.md` — `browse` 逐层展开 | 不要用 `search` 遍历（search 是关键词搜索，不是结构浏览） |
| 知道名字，找具体 topic | `uns/references/search.md` — `search` 按关键词 | 不要用 `browse` 逐层遍历（低效且可能遗漏） |
| 查某个数据点的当前值 | `uns/references/read.md` — `read` 需完整 topic 路径 | 不要用 `history`（history 是时序，不是当前值） |
| 查某段时间的历史趋势 | **必读** `uns/references/history.md` — 参数复杂，读后执行 | 不要循环调用 `read`（高频调用无意义，read 只返回最新值） |
| 写入/更新数据点 | `uns/references/write.md` — `value` 是对象，不是标量 | 不要用 `update`（update 是改节点元数据，不是写数据） |
| 查看/管理节点元数据、字段定义 | `uns/references/update.md` | 不要用 `write`（write 是写 VQT 数据） |
| 创建 UNS 节点 | **必读** `uns/references/create.md` | 路径须含 `Metric` 等类型目录；不自动插入；`--topic-type` 不是字段类型 |
| 查看 Flow 列表或详情 | `flow/references/list.md` — 先 `list` 拿 `id`，再 `get` 看详情 | 不要用 `flowId` 字段当参数（`flowId` 是 Node-RED 内部 ID，不能用于查询） |
| 导出 Node-RED 画布备份 | `flow/references/data.md` — 导出到文件 | deploy 前 **必须** 先 data 备份，不要跳过 |
| 部署 Node-RED 画布 | **必读** `flow/references/deploy.md` 后执行，带 `--yes` | 不要在未备份的情况下直接 deploy |
| 删除 Flow | 先 `flow get --id <id>` 确认存在，再 `delete --yes` | 不要批量删除（先单个确认） |
| 查数据同时了解采集来源 | **同时查** UNS browse/read **和** `flow list --keyword <name>` | 不要只查其中一侧（Flow 与 UNS topic 通常同名关联） |

## Windows PowerShell 调用注意

`tier0 uns` 子命令在 PowerShell 下与其他平台行为一致，通配符需加引号：

```powershell
tier0 uns browse
tier0 uns read "Plant/+/Metric/Temperature" --json
tier0 uns write --topic Plant/Line1/Metric/Temperature --value '{"temperature":27.5}'
# 复杂 JSON（write/create/update）推荐用 --file
tier0 uns write --file writes.json
tier0 uns create --file structure.json
# 调试模式
tier0 uns browse Plant/Line1 --debug
```

## 常用命令速查

```bash
# ── UNS ──────────────────────────────────────
# 浏览命名空间
tier0 uns browse
tier0 uns browse Plant/Line1 --max-depth 2

# 读取数据点（value 是对象，包含多个字段）
tier0 uns read Plant/Line1/Metric/Temperature
# 响应: {"value":{"temperature":27.5,"unit":"C","humidity":58.6},"quality":"Good","timeStamp":1733382000000}

# 通配符读取（所有产线温度）
tier0 uns read "Plant/+/Metric/Temperature" --json

# 写入数据点（value 是对象）
tier0 uns write --topic Plant/Line1/Metric/Temperature --value '{"temperature":27.5,"unit":"C","humidity":58.6}'

# 查询历史数据
tier0 uns history factory/line1/sensor/temp --start 1715000000 --end 1715600000

# 创建节点（路径须含 Metric；字段类型写在 --fields）
tier0 uns create --topic Plant/Line1/Metric/Temperature --type topic \
  --fields '[{"name":"value","type":"float","unit":"°C"}]'
tier0 uns create --parent Plant/Line1 --topic Metric/ProductionCount --type topic \
  --fields '[{"name":"value","type":"int"}]'
tier0 uns create --file structure.json

# ── Flow ─────────────────────────────────────
# 列出所有 Flow
tier0 flow list

# 只看 SourceFlow / EventFlow
tier0 flow list --source
tier0 flow list --event

# 创建 Flow
tier0 flow create --name "modbus-collector" --source --desc "Modbus 采集"

# 导出画布到文件
tier0 flow data --id 1 --out flows.json

# 从文件部署画布
tier0 flow deploy --id 1 -f flows.json
```

## UNS 批量接口响应解析规则

> **适用接口**：`uns read` / `uns write` / `uns history` / `uns create`（批量数据面接口）

这类接口即使部分 topic 失败，HTTP 状态码仍为 200，外层 `code` 仍为 200，`msg` 仍为 `"success"`。**必须检查 `data.success` 和 `data.results[i].success` 才能判断业务是否真正成功。**

```
HTTP 200 + code:200 + msg:"success"
  └─ data.success: false        ← 整体有失败，不能只看外层
       └─ data.results[i].success: false  ← 具体哪个 topic 失败
            └─ data.results[i].error.code / message
```

**解析规则（伪代码）：**

```js
const apiOk = body.code === 200;

// 批量接口：data.success 存在时用它判断整体业务成功
const businessOk =
  typeof body.data?.success === 'boolean'
    ? body.data.success
    : apiOk;

// 还要逐项检查，因为可能部分成功、部分失败
for (const item of body.data?.results ?? []) {
  if (!item.success) {
    // item.topic + item.error.code + item.error.message
  }
}
```

**非批量接口（browse / search / flow list / flow get / info / auth whoami）不含 `data.success`**，直接用外层 `code === 200` 判断即可。

## 错误处理

| 现象 | 原因 | 解决 |
|------|------|------|
| `login` 轮询超时、始终 pending | Agent 未把授权链接展示给用户，用户无从打开浏览器授权 | 重新执行 `tier0 login --no-wait --json`，**先把 `verification_url` 给用户点击**，再 `--setup-code` 轮询 |
| `API Key not found` | 未登录 | `tier0 config --api-key <key>` 或 `tier0 login` |
| `HTTP 401` / exit 3 `authentication` | API Key 失效，或 **base-url 已变更但未重新登录** | 确认 `tier0 config` 中的 base-url 正确后，重新执行 `tier0 login` |
| `HTTP 403` | Workspace 权限不足 | 联系管理员 |
| `HTTP 404` | 资源不存在 | 检查 ID 或路径 |
| `field "id" is not set` | 误用了 `flowId`（字符串）而非 `id`（整数） | 先 `tier0 flow list` 拿整数 `id`，不要用 `flowId` 字段 |
| PowerShell JSON 解析失败 | 双引号被转义 | 使用文件法或单引号简写 |
| **exit code 10** + `"type":"confirmation_required"` | `flow deploy` 或 `flow delete` 缺少 `--yes` | 向用户展示 `risk.action` 和 summary，用户同意后追加 `--yes` 重试 |

### 高风险操作协议（exit 10）

`flow deploy` 和 `flow delete` 是高风险操作。不带 `--yes` 时 CLI 退出码为 **10**，stderr 输出：

```json
{
  "ok": false,
  "error": {
    "type": "confirmation_required",
    "message": "Deploy canvas to Flow 1 — ALL existing Node-RED nodes will be REPLACED...",
    "hint": "add --yes to confirm",
    "risk": { "level": "high-risk-write", "action": "flow deploy" }
  }
}
```

**Agent 处理规则**：
1. 检测到 exit code = 10 且 `error.type == "confirmation_required"`
2. 把 `error.risk.action` + `error.message` 展示给用户，明确告知高风险
3. 用户同意 → 原命令末尾追加 `--yes` 后重试
4. 用户拒绝 → 终止，不得擅自加 `--yes`

## 更新提示

CLI 每条命令执行后会在后台检查新版本（每 24 小时实际请求一次），有新版本时：
- JSON 模式：响应中附加 `_notice.update` 字段
- 普通模式：stderr 输出一行提示

升级命令：
```bash
tier0 upgrade
```
