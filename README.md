# Tier0 Skills

Tier0 平台 AI Agent Skills 文档。

## 目录

- [`uns/`](uns/) — UNS（Unified Namespace）数据面 API

## 使用方式

AI Agent 通过 `tier0` CLI 调用平台 API：

```bash
# 认证
tier0 login

# 调用 API
tier0 api /openapi/v1/uns/read --body '{"topics":["demo"]}'
```
