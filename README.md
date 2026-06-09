# Tier0 Skills

Tier0 平台 AI Agent Skills 文档。

以下步骤面向 AI Agent，部分步骤需要用户在浏览器中配合完成。

> **版本要求**：`v0.4.6+`

## 第 1 步 安装

**一键安装 CLI + Skills（推荐，需要 Node.js >= 16）：**

```bash
npx @tier0/cli@latest install
```

一条命令同时完成：
- `tier0` CLI 二进制安装到 `~/.tier0/bin/`
- Cursor / Claude Agent Skills 自动安装（`FREEZONEX/Tier0-skill`）

**备选方式（无 Node.js 环境）：**

```bash
# macOS / Linux
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash

# Windows PowerShell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression

# 以上备选方式需额外安装 Skills：
npx skills add FREEZONEX/Tier0-skill
```

## 第 2 步 配置（私有化部署需执行）

SaaS 环境（默认 `https://tier0.dev`）无需配置，直接跳到第 3 步。

私有化部署必须先配置地址再登录：

```bash
tier0 config --base-url https://your-tier0-instance.com
```

> **关键约束**：先 `config` 再 `login`，否则授权 URL 会指向错误地址。

## 第 3 步 登录授权

Agent 运行以下命令，并提取授权链接发给用户：

```bash
tier0 login --no-wait
# → 向用户展示 verification_url，用户浏览器授权后：
tier0 login --setup-code <code>
```

## 第 4 步 验证

```bash
tier0 api /openapi/v1/uns/read --body '{topics:[demo]}'
```

更多命令和能力指南，可参考 [`SKILL.md`](SKILL.md)。

## 卸载

```bash
npx @tier0/cli@latest uninstall            # 卸载 CLI + Skills，保留 config
npx @tier0/cli@latest uninstall --purge    # 彻底清除（含登录凭证）
```

---

## 目录

- [`SKILL.md`](SKILL.md) — 总览入口（安装、认证、命令速查）
- [`uns/`](uns/) — UNS（Unified Namespace）数据面
  - [`SKILL.md`](uns/SKILL.md) — UNS 路由、规则、任务选路
  - [`references/browse.md`](uns/references/browse.md) — 浏览命名空间树
  - [`references/read.md`](uns/references/read.md) — 读取数据点
  - [`references/write.md`](uns/references/write.md) — 写入数据点
  - [`references/history.md`](uns/references/history.md) — 查询历史数据
  - [`references/search.md`](uns/references/search.md) — 搜索命名空间
  - [`references/create.md`](uns/references/create.md) — 创建节点
  - [`references/update.md`](uns/references/update.md) — 更新节点
  - [`references/delete.md`](uns/references/delete.md) — 删除节点
  - [`references/restore.md`](uns/references/restore.md) — 恢复已删除节点
  - [`references/attachments.md`](uns/references/attachments.md) — UNS 附件上传和查询
  - [`references/bind-flow.md`](uns/references/bind-flow.md) — 绑定 UNS 节点到 SourceFlow
- [`info/`](info/) — 服务信息
  - [`info.md`](info/info.md) — 健康检查 / 连通性验证
- [`auth/`](auth/) — 认证与权限诊断
  - [`whoami.md`](auth/whoami.md) — 当前 API Key 的用户、Workspace、角色和权限
- [`flow/`](flow/) — Flow（Node-RED）管理
  - [`SKILL.md`](flow/SKILL.md) — Flow 路由、规则、任务选路
  - [`references/nodes.md`](flow/references/nodes.md) — 可用节点查询接口和常用 type 字符串速查
  - [`references/list.md`](flow/references/list.md) — 列出 / 查看 Flow
  - [`references/create.md`](flow/references/create.md) — 创建 Flow
  - [`references/update.md`](flow/references/update.md) — 更新 Flow 元数据
  - [`references/delete.md`](flow/references/delete.md) — 删除 Flow
  - [`references/data.md`](flow/references/data.md) — 导出 Node-RED 画布
  - [`references/deploy.md`](flow/references/deploy.md) — 部署 Node-RED 画布
