# Tier0 Skills

Tier0 平台 AI Agent Skills 文档。

## 安装

```bash
npx skills add FREEZONEX/Tier0-skill
```

## 前置条件

使用本 skill 前需先安装 `tier0` CLI 并完成登录授权：

```bash
npm install -g @freezonex/tier0-cli
tier0 login
```

> 版本要求：`v0.2.7+`

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
