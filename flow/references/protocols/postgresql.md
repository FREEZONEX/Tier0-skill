# Protocol: node-red-contrib-postgresql

> 用途：在 Node-RED 流里对接用户自己的 **PostgreSQL / TimescaleDB** 数据库。  
> 最常见场景是 **EventFlow**：订阅 UNS MQTT 数据 → function 构建 SQL → INSERT 归档。

---

## 何时使用本 Skill

| 场景 | 示例 |
|------|------|
| UNS → PostgreSQL 归档 | MQTT 订阅 → function 构建 INSERT → 写入用户自有库 |
| 历史数据回填 | 从 PostgreSQL 读历史记录 → 发布到 UNS 话题 |
| 事件触发写数据库 | EventFlow 收到告警 → 写 incidents 表 |

## 不应该使用

- 如果只是在 Tier0 平台内部存储数据，应使用平台内置时序存储（无需手动配置 PostgreSQL）
- 如果只是读/写 UNS 值，使用 `tier0 uns` 命令，无需 Node-RED

---

## 不可违反规则

1. **`password` 是明文**：`node-red-contrib-postgresql` 的配置节点不使用 Node-RED Credentials API，`password` 字段以明文存储在 flowsJson 里。  
   → 部署前确认密码不会被不受信任的人通过 `flow get` 读取；生产环境建议改用 `env` 类型（`passwordFieldType: "env"`），从环境变量读取。
2. **deploy 前必须备份**：执行 `flow deploy` 前先 `flow get` 保存现有配置（见 [flow deploy 文档](../deploy.md)）。
3. **deploy 和 delete 需要 `--yes`**：高风险操作需要显式确认。

---

## 节点架构

```
[mqtt in]  →  [function]  →  [postgresql]  →  [debug]
    │              │               │
 订阅 UNS       构建 SQL        INSERT / SELECT
 MQTT 话题      参数数组         连接用户自己的库
```

---

## 节点说明

### `postgreSQLConfig`（配置节点）

连接池配置，被 `postgresql` 查询节点引用。

| 字段 | 说明 | 模板占位符 |
|------|------|-----------|
| `host` | 数据库主机名或 IP | `{{PG_HOST}}` |
| `port` | 端口，默认 5432 | `{{PG_PORT}}` |
| `database` | 数据库名 | `{{PG_DATABASE}}` |
| `user` | 登录用户名 | `{{PG_USER}}` |
| `password` | 登录密码（**明文**，见安全说明） | `{{PG_PASSWORD}}` |
| `ssl` | 是否启用 TLS，默认 `false` | 按需设置 |
| `max` | 连接池最大连接数，默认 `10` | 一般不改 |

> **env 变量方式（推荐生产环境）：**  
> 将 `password` 改为 `""`, `passwordFieldType` 改为 `"env"`, 然后在 Node-RED 的 `settings.js` 里配置 `envVarSettings` 或在容器环境变量里注入 `PG_PASSWORD`。

### `postgresql`（查询节点）

| 字段 | 说明 | 模板占位符 |
|------|------|-----------|
| `query` | SQL 语句，支持 `$1`、`$2` 等参数占位符 | `{{PG_QUERY}}` |
| `postgreSQLConfig` | 引用配置节点的 `id` | 自动绑定 |
| `split` | 大结果集时逐行输出，默认 `false` | 归档场景设 `false` |
| `rowsPerMsg` | `split=true` 时每条消息的行数 | 按需设置 |

#### 参数化 SQL

使用 `$1`、`$2` 传参，`function` 节点中设置 `msg.params`：

```javascript
// function 节点示例（UNS 消息 → INSERT）
const p = msg.payload;          // UNS message: { value, quality, timeStamp }
msg.query = `INSERT INTO sensor_data (topic, ts, value, quality)
             VALUES ($1, to_timestamp($2::bigint / 1000.0), $3, $4)`;
msg.params = [
  msg.topic,                    // $1 — UNS 话题路径
  p.timeStamp,                  // $2 — 毫秒时间戳
  JSON.stringify(p.value),      // $3 — value 序列化为 JSON text
  p.quality                     // $4 — 'Good' / 'Bad' / 'Uncertain'
];
return msg;
```

---

## 快速部署工作流

```text
1. tier0 flow list                  — 确认 EventFlow 容器已创建
2. tier0 flow get --id <id>         — 备份现有 flowsJson
3. (用模板生成 flowsJson，替换占位符)
4. tier0 flow deploy --id <id> --yes --flows <file.json>
5. 检查 debug 节点输出确认 INSERT 成功
```

---

## 典型示例

### EventFlow：UNS 订阅 → PostgreSQL INSERT

替换 `postgresql-uns-archive.json` 里的占位符：

| 占位符 | 示例值 | 说明 |
|--------|--------|------|
| `{{FLOW_ID}}` | `evt_pg_01` | 在本 flowsJson 内唯一的短 ID，避免节点 ID 冲突 |
| `{{FLOW_NAME}}` | `UNS to PostgreSQL` | Tab 显示名 |
| `{{PG_NAME}}` | `mydb@postgres:5432/iot` | 配置节点显示名 |
| `{{PG_HOST}}` | `192.168.1.100` | 用户自己的 PostgreSQL 主机 |
| `{{PG_PORT}}` | `5432` | PostgreSQL 端口（数字，不加引号） |
| `{{PG_DATABASE}}` | `iot` | 目标数据库 |
| `{{PG_USER}}` | `tier0_writer` | 登录用户 |
| `{{PG_PASSWORD}}` | `s3cr3t` | 登录密码（**生产环境建议用 env 方式**） |
| `{{MQTT_HOST}}` | `127.0.0.1` | Tier0 平台 MQTT Broker 地址 |
| `{{MQTT_PORT}}` | `1883` | MQTT 端口 |
| `{{UNS_TOPIC}}` | `factory/line1/plc01/#` | 订阅的 UNS 话题（支持通配符） |
| `{{PG_QUERY}}` | 见下方 | `postgresql` 节点的 SQL |
| `{{FUNCTION_BODY}}` | 见下方 | `function` 节点的 JavaScript 逻辑 |

**`{{PG_QUERY}}` 示例：**

```sql
INSERT INTO sensor_data (topic, ts, value, quality)
VALUES ($1, to_timestamp($2::bigint / 1000.0), $3, $4)
ON CONFLICT DO NOTHING;
```

**`{{FUNCTION_BODY}}` 示例：**

```javascript
const p = msg.payload;
msg.query = `INSERT INTO sensor_data (topic, ts, value, quality)
             VALUES ($1, to_timestamp($2::bigint / 1000.0), $3, $4)
             ON CONFLICT DO NOTHING`;
msg.params = [
  msg.topic,
  p.timeStamp,
  JSON.stringify(p.value),
  p.quality || 'Unknown'
];
return msg;
```

> 注意：若 `query` 字段直接写在 `postgresql` 节点上，`msg.query` 会被忽略；  
> 若 `query` 字段**为空**，节点会用 `msg.query`（动态模式）。  
> 推荐将 SQL 写在 `function` 节点并留空 `postgresql` 节点的 `query` 字段，方便 AI Agent 生成。

---

## 安全说明

| 风险 | 处置建议 |
|------|---------|
| password 明文存在 flowsJson | 生产环境设 `passwordFieldType: "env"`, 值填环境变量名（如 `PG_WRITER_PASSWORD`） |
| `flow get` 会导出明文密码 | 限制 API Key 权限范围，避免 flowsJson 存入代码仓库 |
| SQL 注入 | 始终使用 `$1`/`$2` 参数化，不要用字符串拼接 SQL |

---

## 故障排查

| 现象 | 可能原因 | 处置 |
|------|---------|------|
| `connection refused` | PG_HOST / 端口不通 | 检查防火墙、主机地址 |
| `password authentication failed` | 用户名/密码错误 | 确认 `pg_user`/`pg_password` |
| `relation does not exist` | 表不存在 | 先建表，或检查 `database` 是否正确 |
| `ERROR: syntax error at $1` | 旧版 pg 驱动不支持参数化 | 升级 `node-red-contrib-postgresql` |
| 消息进入但无 INSERT | `msg.params` 未设置 | 检查 `function` 节点是否正确设置 `msg.params` |
