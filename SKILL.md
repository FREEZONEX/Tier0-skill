---
name: tier0-cli
version: 0.3.0
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

### 第 1 步 安装 CLI

**macOS / Linux：**
```bash
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

**Windows (PowerShell)：**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression
```

**npm（跨平台，推荐）：**
```bash
npm install -g @freezonex/tier0-cli
```

### 第 2 步 安装 Skills

```bash
npx skills add FREEZONEX/Tier0-skill
```

### 第 3 步 配置（私有化部署必须执行，SaaS 跳过）

```bash
tier0 config --base-url https://your-tier0-instance.com
```

> **关键约束**：先 `config` 再 `login`，否则授权 URL 指向错误地址。

### 第 4 步 登录授权

Agent 运行以下命令，提取授权链接发给用户：
```bash
tier0 login --no-wait
# → 向用户展示 verification_url，用户浏览器授权后：
tier0 login --setup-code <code>
```

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
| Topic | 完整路径字符串，如 `Plant/Line1/Metric/Temperature`。**只有叶子节点（thing 类型）才是可读写的数据点**，中间路径段是文件夹 |
| Node | 命名空间中的节点：`folder`（文件夹）或 `thing`（数据点） |
| VQT | 数据点的值结构：`value`（业务对象）+ `quality`（数据质量）+ `timeStamp`（毫秒时间戳） |
| SourceFlow | Node-RED 实例，连接工业协议采集设备数据并发布 MQTT |
| EventFlow | Node-RED 实例，订阅 MQTT 消息对业务数据进行二次处理 |

## 资源关系

```
Workspace
├── UNS (Unified Namespace)
│   ├── Plant/                          ← folder（文件夹）
│   │   ├── Line1/                      ← folder
│   │   │   ├── Metric/                 ← folder
│   │   │   │   └── Temperature         ← thing（数据点，完整 topic）
│   │   │   │       └── VQT { value: {"temperature":27.5,"unit":"C"},
│   │   │   │                 quality: "Good", timeStamp: 1733382000000 }
│   │   │   └── State/
│   │   │       └── MachineStatus       ← thing（数据点）
│   │   └── Line2/
│   │       └── ...
└── Flow
    ├── SourceFlow                       ← Node-RED 实例（协议采集 → MQTT/UNS）
    └── EventFlow                        ← Node-RED 实例（业务数据二次处理）
```

**关键规则**：
- `browse` / `search` 操作的对象是**路径段（文件夹）**
- `read` / `write` / `history` 操作的对象是**完整 topic（叶子数据点）**
- 写入时 `value` 是符合该 topic 字段定义的**对象**，不是标量
- 中间路径段（如 `Plant/Line1`）不能直接 read/write，只能 browse

## 子技能路由

根据用户意图，**必须先读取对应子文档，再执行命令**。

### UNS — 统一命名空间

> **路径辨别规则**：用户给出的路径若不到叶子节点（如 `Plant/Line1`），是文件夹，用 browse；完整到数据点（如 `Plant/Line1/Metric/Temperature`）才能 read/write。

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 浏览命名空间树 | `uns/browse.md` | 获取文件夹下的子节点列表、层级结构 |
| 读取数据点当前值 | `uns/read.md` | 实时 VQT 值查询，支持通配符 |
| 写入数据点 | `uns/write.md` | 发布数据，value 必须是对象 |
| 查询历史/时序数据 | **必读** `uns/history.md` | 历史记录、聚合查询（时间戳参数复杂，必读后执行） |
| 搜索节点 | `uns/search.md` | 按关键字/前缀搜索 |
| 创建节点 | `uns/create.md` | 新建 folder 或 thing 节点 |
| 更新节点 | `uns/update.md` | 修改元数据或字段定义 |
| 删除节点 | `uns/delete.md` | 软删除或硬删除（⚠️ 不可逆） |
| 恢复已删除节点 | `uns/restore.md` | 撤销软删除 |
| 服务信息/健康检查 | `uns/info.md` | 网关连通性验证 |

### Flow — Node-RED 管理

**CRITICAL — 执行 `deploy` 前 MUST 先读 `flow/deploy.md`，禁止直接盲目调用。**
**CRITICAL — 执行 `delete` 前 MUST 先用 `tier0 flow get --id <id>` 确认 Flow 存在。**

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 列出 / 查看 Flow | `flow/list.md` | 列表、类型过滤、详情 |
| 创建 Flow | `flow/create.md` | 新建 SourceFlow 或 EventFlow |
| 更新 Flow 元数据 | `flow/update.md` | 重命名、描述、收藏 |
| 删除 Flow | `flow/delete.md` | 单个或批量删除（⚠️ 会停止 Node-RED 容器） |
| 导出 Node-RED 画布 | `flow/data.md` | 获取 flowsJson 到文件 |
| 部署 Node-RED 画布 | **必读** `flow/deploy.md` | 上传并激活 flowsJson（会替换所有节点配置） |

## Windows PowerShell 调用注意

PowerShell 处理 JSON 字符串中的双引号时容易出错。**推荐三种方式**：

**方式一：单引号简写（v0.2.6+ 自动修复）**
```powershell
tier0 api /openapi/v1/uns/browse --body '{path:/}'
# CLI 自动修复为 {"path":"/"} 再发送
```

**方式二：文件法（最稳妥，适合复杂 JSON）**
```powershell
'{"path":"/"}' | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/browse --body-file body.json
```

**方式三：调试模式**
```powershell
tier0 api /openapi/v1/uns/browse --body '{path:/}' --debug
# 可查看实际发出的 HTTP 请求和响应
```

## 常用命令速查

```bash
# ── UNS ──────────────────────────────────────
# 浏览命名空间
tier0 api /openapi/v1/uns/browse --body '{"path":"/"}'

# 读取数据点（value 是对象，包含多个字段）
tier0 api /openapi/v1/uns/read --body '{"topics":["Plant/Line1/Metric/Temperature"]}'
# 响应: {"value":{"temperature":27.5,"unit":"C","humidity":58.6},"quality":"Good","timeStamp":1733382000000}

# 通配符读取（所有产线温度）
tier0 api /openapi/v1/uns/read --body '{"topics":["Plant/+/Metric/Temperature"]}'

# 写入数据点（value 是对象）
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"Plant/Line1/Metric/Temperature","value":{"temperature":27.5,"unit":"C","humidity":58.6}}]}'

# 查询历史数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'

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

## 错误处理

| 现象 | 原因 | 解决 |
|------|------|------|
| `API Key not found` | 未登录 | `tier0 login` |
| `HTTP 401` | API Key 失效 | 重新 `tier0 login` |
| `HTTP 403` | Workspace 权限不足 | 联系管理员 |
| `HTTP 404` | 资源不存在 | 检查 ID 或路径 |
| PowerShell JSON 解析失败 | 双引号被转义 | 使用文件法或单引号简写 |

## 更新提示

CLI 每条命令执行后会在后台检查新版本（每 24 小时实际请求一次），有新版本时：
- JSON 模式：响应中附加 `_notice.update` 字段
- 普通模式：stderr 输出一行提示

升级命令：
```bash
tier0 upgrade
```
