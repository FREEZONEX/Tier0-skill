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

## 安装 CLI

### 方式一：下载 Release 包（推荐）

从 [GitHub Releases](https://github.com/FREEZONEX/Tier0-cli/releases) 下载对应平台的预编译包：

```bash
# Linux x86_64
curl -LO https://github.com/FREEZONEX/Tier0-cli/releases/latest/download/tier0-cli-Linux-x86_64.tar.gz
tar -xzf tier0-cli-Linux-x86_64.tar.gz
sudo mv linux-amd64/tier0 /usr/local/bin/

# macOS Apple Silicon
curl -LO https://github.com/FREEZONEX/Tier0-cli/releases/latest/download/tier0-cli-macOS-arm64.tar.gz
tar -xzf tier0-cli-macOS-arm64.tar.gz
sudo mv darwin-arm64/tier0 /usr/local/bin/

# Windows (PowerShell)
# 下载 tier0-cli-Windows-x86_64.zip 并解压，将 tier0.exe 添加到 PATH
```

Release 包已包含 skills 文档，解压后 `skill/` 目录与二进制同级，CLI 会自动识别。

### 方式二：go install（仅二进制，不含 skills）

```bash
go install github.com/FREEZONEX/Tier0-cli@latest
```

> 注意：`go install` 仅安装二进制文件，不含 skills 文档。如需 skills，请单独下载或克隆 [Tier0-skill](https://github.com/FREEZONEX/Tier0-skill) 仓库。

## 使用方式

### 通过 tier0 CLI

```bash
# 私有化部署：先设置平台地址（持久化到配置文件）
tier0 config --base-url https://tier0-eks-frontend.tier0.dev

# 认证
tier0 login

# 调用 API
tier0 api /openapi/v1/uns/read --body '{"topics":["demo"]}'
```

> **优先级**：`--base-url` 参数 > 环境变量 `TIER0_BASE_URL` > 配置文件 > 默认地址 `https://tier0.dev`

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
