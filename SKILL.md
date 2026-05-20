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
| UNS (Unified Namespace) | 统一命名空间，树形结构组织数据点 |
| Topic | 数据点路径，如 `factory/line1/sensor/temp` |
| Node | 命名空间中的节点，文件夹或数据点 |
| SourceFlow | Node-RED 实例，连接协议采集数据并发布 MQTT |
| EventFlow | Node-RED 实例，对业务数据进行二次处理 |

## 子技能路由

根据用户意图，读取对应子文档后再执行：

### UNS — 统一命名空间

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 浏览命名空间树 | `uns/browse.md` | 获取节点列表、层级结构 |
| 读取数据点当前值 | `uns/read.md` | 实时值查询 |
| 写入数据点 | `uns/write.md` | 发布数据 |
| 查询历史/时序数据 | `uns/history.md` | 历史记录、聚合查询 |
| 搜索节点 | `uns/search.md` | 按关键字/前缀搜索 |
| 创建节点 | `uns/create.md` | 新建文件夹或数据点 |
| 更新节点 | `uns/update.md` | 修改元数据或字段 |
| 删除节点 | `uns/delete.md` | 软删除或硬删除 |
| 恢复已删除节点 | `uns/restore.md` | 撤销软删除 |
| 服务信息/健康检查 | `uns/info.md` | 网关状态 |

### Flow — Node-RED 管理

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 列出 / 查看 Flow | `flow/list.md` | 列表、过滤、详情 |
| 创建 Flow | `flow/create.md` | 新建 SourceFlow 或 EventFlow |
| 更新 Flow 元数据 | `flow/update.md` | 重命名、描述、收藏 |
| 删除 Flow | `flow/delete.md` | 单个或批量删除 |
| 导出 Node-RED 画布 | `flow/data.md` | 获取 flowsJson |
| 部署 Node-RED 画布 | `flow/deploy.md` | 上传并部署 flowsJson |

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
