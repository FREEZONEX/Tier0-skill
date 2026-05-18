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

```bash
# 1. 下载 CLI（自动识别平台）
curl -sL https://github.com/FREEZONEX/Tier0-cli/releases/latest/download/tier0-cli-$(uname -s)-$(uname -m).tar.gz | tar -xz && sudo mv */tier0 /usr/local/bin/

# 2. （私有化部署）设置平台地址
tier0 config --base-url https://tier0-eks-frontend.tier0.dev

# 3. 登录授权
tier0 login --no-wait
# → 在浏览器中打开返回的 URL 完成授权，然后：
tier0 login --setup-code <code>

# 4. 调用 API
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
