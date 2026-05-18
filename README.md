# Tier0 Skills

Tier0 平台 AI Agent Skills 文档。

## 目录

- [`SKILL.md`](SKILL.md) — 总览入口（认证 + 命令速查）
- [`uns/`](uns/) — UNS（Unified Namespace）数据面 API 技能
  - [`browse.md`](uns/browse.md) — 浏览命名空间树
  - [`read.md`](uns/read.md) — 读取数据点
  - [`write.md`](uns/write.md) — 写入数据点
  - [`history.md`](uns/history.md) — 查询历史数据
  - [`search.md`](uns/search.md) — 搜索命名空间
  - [`create.md`](uns/create.md) — 创建节点
  - [`update.md`](uns/update.md) — 更新节点
  - [`delete.md`](uns/delete.md) — 删除节点
  - [`restore.md`](uns/restore.md) — 恢复已删除节点
  - [`info.md`](uns/info.md) — 服务信息

## 安装与初始化

> **版本要求**：`v0.2.2+` 才支持 `login` 读取配置文件中的 `baseURL`。如果已安装旧版本，请先执行 `tier0 upgrade`。

### 步骤 1：安装 CLI

**macOS / Linux：**
```bash
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

**Windows (PowerShell)：**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression
```

### 步骤 2：选择部署环境

**A. SaaS 环境（默认 `https://tier0.dev`）**

无需配置地址，直接跳到步骤 3 登录。

**B. 私有化部署**

必须在登录**之前**配置平台地址：

```bash
tier0 config --base-url https://your-tier0-instance.com
```

**⚠️ 关键约束**：如果先执行 `tier0 login` 再 `config --base-url`，授权 URL 会指向错误地址。私有化部署必须先 `config` 再 `login`。

### 步骤 3：登录授权

```bash
tier0 login --no-wait
# → 在浏览器中完成授权后：
tier0 login --setup-code <code>
```

### 步骤 4：调用 API

```bash
tier0 api /openapi/v1/uns/read --body '{"topics":["demo"]}'
```

**配置优先级**：`--base-url` 参数 > 环境变量 `TIER0_BASE_URL` > 配置文件 > 默认地址 `https://tier0.dev`

### 通过 OpenClaw

**一键安装：**

```bash
cd skill/
./install-openclaw.sh
```

**手动安装：**

```bash
mkdir -p ~/.openclaw/skills/tier0-api
cp SKILL.md ~/.openclaw/skills/tier0-api/
cp -r uns ~/.openclaw/skills/tier0-api/
```

**验证安装：**

```bash
openclaw skills list | grep tier0
openclaw skills info tier0-api
```
