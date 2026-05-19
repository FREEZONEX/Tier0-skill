# Tier0 Skills

Tier0 平台 AI Agent Skills 文档。

## 前置条件（必须先完成）

**使用本 skill 的所有功能之前，必须先安装 `tier0` CLI 并完成登录授权。**

- 没有安装 CLI → 无法调用任何 API
- 没有完成 `tier0 login` → 没有 API Key，所有请求会返回 401

**macOS / Linux：**
```bash
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

**Windows (PowerShell)：**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression
```

安装完成后执行 `tier0 login` 完成授权。

> **版本要求**：`v0.2.6+` 推荐（支持 `--body-file`、`--debug` 和 JSON 自动修复）。

---

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

## 初始化步骤（CLI 安装完成后）

确认 `tier0` CLI 已安装且 `tier0 version` 能正常输出版本号后，按以下步骤完成初始化：

### 步骤 1：选择部署环境

**A. SaaS 环境（默认 `https://tier0.dev`）**

无需配置地址，直接跳到步骤 2 登录。

**B. 私有化部署**

必须在登录**之前**配置平台地址：

```bash
tier0 config --base-url https://your-tier0-instance.com
```

**⚠️ 关键约束**：如果先执行 `tier0 login` 再 `config --base-url`，授权 URL 会指向错误地址。私有化部署必须先 `config` 再 `login`。

### 步骤 2：登录授权

```bash
tier0 login --no-wait
# → 在浏览器中完成授权后：
tier0 login --setup-code <code>
```

### 步骤 3：验证调用

```bash
tier0 api /openapi/v1/uns/read --body '{"topics":["demo"]}'
```

**配置优先级**：`--base-url` 参数 > 环境变量 `TIER0_BASE_URL` > 配置文件 > 默认地址 `https://tier0.dev`

---

## 安装 Skill 文档（通过 OpenClaw）

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
