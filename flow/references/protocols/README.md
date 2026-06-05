# 协议节点配置

Node-RED 协议节点的使用指南与 flowsJson 模板。

AI Agent 使用路径：
1. 根据协议类型加载对应的 `*.md` 文档，了解节点参数含义
2. 参考 `templates/` 里的 JSON 模板理解节点结构和连线方式
3. **根据用户的具体任务**（标签数量、映射关系、字段定义）生成实际 Flow JSON，不要照搬模板
4. 用 `tier0 flow deploy --id <id> -f <file> --yes` 部署

> **模板是结构参考，不是填空题。** 用它理解节点类型和字段含义，实际 JSON 应按用户需求生成：标签可多可少，function 逻辑按实际字段定义写，不必保留无关节点。

---

## 可用协议文档

| 文件 | 协议 | Flow 类型 | 用途 | 需额外安装 |
|------|------|-----------|------|-----------|
| [modbus.md](modbus.md) | Modbus TCP / RTU | SourceFlow | 周期轮询 PLC 寄存器/线圈 → UNS | node-red-contrib-modbus |
| [postgresql.md](postgresql.md) | PostgreSQL / TimescaleDB | EventFlow | UNS 订阅 → INSERT 归档到用户自有库 | node-red-contrib-postgresql |
| [opcua.md](opcua.md) | OPC-UA | SourceFlow | 订阅 OPC-UA Server 变更 → UNS | node-red-contrib-opcua |
| [mqtt-bridge.md](mqtt-bridge.md) | MQTT Bridge | SourceFlow | 外部 MQTT Broker → Tier0 UNS | ✅ 内置 |
| *(opcda.md 待补充)* | OPC-DA | SourceFlow | — | — |

## 可用模板

| 文件 | 协议 | 对应文档 |
|------|------|---------|
| [templates/modbus-tcp-read.json](templates/modbus-tcp-read.json) | Modbus TCP | modbus.md |
| [templates/postgresql-uns-archive.json](templates/postgresql-uns-archive.json) | PostgreSQL | postgresql.md |
| [templates/opcua-subscribe.json](templates/opcua-subscribe.json) | OPC-UA | opcua.md |

完整占位符说明见 [templates/README.md](templates/README.md)。
