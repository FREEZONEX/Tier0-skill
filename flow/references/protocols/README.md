# 协议节点配置

Node-RED 协议节点的使用指南与 flowsJson 模板。

AI Agent 使用路径：
1. 根据协议类型加载对应的 `*.md` 文档，了解节点参数含义
2. 复制 `templates/` 里的 JSON 模板，替换所有 `{{PLACEHOLDER}}` 占位符
3. 用 `tier0 flow deploy --id <id> -f <file> --yes` 部署

---

## 可用协议文档

| 文件 | 协议 | Flow 类型 | 用途 | 需额外安装 |
|------|------|-----------|------|-----------|
| [http.md](http.md) | HTTP REST API | SourceFlow | 定时轮询第三方接口 → UNS | ✅ 内置 |
| [modbus.md](modbus.md) | Modbus TCP / RTU | SourceFlow | 周期轮询 PLC 寄存器/线圈 → UNS | node-red-contrib-modbus |
| [postgresql.md](postgresql.md) | PostgreSQL / TimescaleDB | EventFlow | UNS 订阅 → INSERT 归档到用户自有库 | node-red-contrib-postgresql |
| *(mqtt-bridge.md 待补充)* | MQTT Bridge | SourceFlow / EventFlow | 外部 MQTT ↔ Tier0 UNS 桥接 | ✅ 内置 |
| *(opcua.md 待补充)* | OPC-UA | SourceFlow | — | — |
| *(opcda.md 待补充)* | OPC-DA | SourceFlow | — | — |

## 可用模板

| 文件 | 协议 | 对应文档 |
|------|------|---------|
| [templates/http-poller.json](templates/http-poller.json) | HTTP REST API 轮询 | http.md |
| [templates/modbus-tcp-read.json](templates/modbus-tcp-read.json) | Modbus TCP | modbus.md |
| [templates/postgresql-uns-archive.json](templates/postgresql-uns-archive.json) | PostgreSQL | postgresql.md |

完整占位符说明见 [templates/README.md](templates/README.md)。
