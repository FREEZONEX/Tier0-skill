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

## 使用方式

### 通过 tier0 CLI

```bash
# 认证
tier0 login

# 调用 API
tier0 api /openapi/v1/uns/read --body '{"topics":["demo"]}'
```

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
