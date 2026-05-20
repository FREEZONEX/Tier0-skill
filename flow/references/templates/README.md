# Flow Templates

Node-RED flowsJson 模板，用于快速创建协议采集 SourceFlow。

## 使用方式

1. 读取对应协议的 skill 文档了解参数含义（如 `protocol-modbus.md`）
2. 将模板文件复制到本地
3. 替换所有 `{{PLACEHOLDER}}` 占位符为实际值（见下方占位符说明）
4. 用 `tier0 flow deploy` 部署

```bash
# 示例：部署 Modbus TCP 采集模板
cp modbus-tcp-read.json my-modbus.json
# 编辑 my-modbus.json，替换所有占位符
tier0 flow deploy --id <flow_id> -f my-modbus.json --yes
```

## 占位符说明

### 通用

| 占位符 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `{{FLOW_ID}}` | string | 唯一标识符，同一模板内所有节点共用（用于 id 和引用） | `line1_modbus` |
| `{{FLOW_NAME}}` | string | Node-RED Tab 显示名称 | `Line1 Modbus采集` |

### Modbus TCP（`modbus-tcp-read.json`）

| 占位符 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `{{DEVICE_NAME}}` | string | 设备连接显示名称 | `Line1 PLC` |
| `{{MODBUS_HOST}}` | string | PLC/设备 IP 地址 | `192.168.1.100` |
| `{{MODBUS_PORT}}` | number | Modbus TCP 端口（默认 502） | `502` |
| `{{UNIT_ID}}` | number | Modbus 从站 ID（1–247） | `1` |
| `{{READ_NODE_NAME}}` | string | 读取节点显示名称 | `读保持寄存器` |
| `{{DATA_TYPE}}` | enum | 寄存器类型：`Coil` / `Input` / `HoldingRegister` / `InputRegister` | `HoldingRegister` |
| `{{START_ADDRESS}}` | number | 起始地址（0-based） | `0` |
| `{{QUANTITY}}` | number | 读取数量 | `10` |
| `{{POLL_RATE}}` | number | 轮询间隔数值 | `1` |
| `{{POLL_RATE_UNIT}}` | enum | 轮询间隔单位：`ms` / `s` / `m` / `h` | `s` |
| `{{MQTT_HOST}}` | string | MQTT broker 地址（通常是 Tier0 平台内部地址） | `localhost` |
| `{{MQTT_PORT}}` | number | MQTT 端口 | `1883` |
| `{{UNS_TOPIC}}` | string | 目标 UNS topic 完整路径（叶子节点） | `Plant/Line1/Metric/Temperature` |
| `{{FUNCTION_BODY}}` | string | function 节点转换逻辑（见下方说明） | 见示例 |

## `dataType` 对应 Modbus 功能码

| `dataType` 值 | Modbus FC | 说明 |
|--------------|-----------|------|
| `Coil` | FC 1 | 读线圈状态（数字量输出） |
| `Input` | FC 2 | 读离散输入（数字量输入） |
| `HoldingRegister` | FC 3 | 读保持寄存器（模拟量/配置） |
| `InputRegister` | FC 4 | 读输入寄存器（模拟量输入） |

## function 节点转换逻辑示例

Modbus 读取结果在 `msg.payload.data` 里是原始数组，需要映射成 UNS topic 的字段对象。

**示例 1：读 3 个保持寄存器，映射为温度/湿度/压力**

```javascript
var registers = msg.payload.data;
var writes = [];
writes.push({
  topic: "Plant/Line1/Metric/Environment",
  value: {
    temperature: registers[0] * 0.1,   // 寄存器值 × 0.1 = 实际温度
    humidity:    registers[1] * 0.1,
    pressure:    registers[2] * 0.01
  }
});
```

**示例 2：读 10 个线圈，映射为机器状态**

```javascript
var coils = msg.payload.data;
var writes = [];
writes.push({
  topic: "Plant/Line1/State/MachineStatus",
  value: {
    running:   coils[0],
    alarm:     coils[1],
    emergency: coils[2]
  }
});
```

### PostgreSQL（`postgresql-uns-archive.json`）

| 占位符 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `{{PG_NAME}}` | string | 配置节点显示名（一般写 `user@host/db`） | `writer@192.168.1.50/iot` |
| `{{PG_HOST}}` | string | PostgreSQL 主机名或 IP | `192.168.1.50` |
| `{{PG_PORT}}` | number | PostgreSQL 端口（数字，不加引号） | `5432` |
| `{{PG_DATABASE}}` | string | 目标数据库名 | `iot` |
| `{{PG_USER}}` | string | 登录用户名 | `tier0_writer` |
| `{{PG_PASSWORD}}` | string | 登录密码（**明文**；生产环境改用 `env` 类型） | `s3cr3t` |
| `{{MQTT_HOST}}` | string | Tier0 MQTT Broker 地址 | `127.0.0.1` |
| `{{MQTT_PORT}}` | number | MQTT 端口 | `1883` |
| `{{UNS_TOPIC}}` | string | 订阅的 UNS 话题（支持 `#` 通配符） | `factory/line1/#` |
| `{{PG_QUERY}}` | string | `postgresql` 节点上的 SQL；留空则由 `function` 节点动态设置 `msg.query` | `""` 或见示例 |
| `{{FUNCTION_BODY}}` | string | `function` 节点的 JavaScript 逻辑（设置 `msg.query` 和 `msg.params`） | 见示例 |

> **密码安全提示**：`node-red-contrib-postgresql` 的密码以明文存储在 flowsJson 中。  
> 生产环境请将 `password` 字段留空，将 `passwordFieldType` 改为 `"env"`，密码改为环境变量名（如 `PG_WRITER_PASSWORD`）。

#### function 节点示例（`{{FUNCTION_BODY}}`）

```javascript
// msg.payload 是 UNS 消息：{ value, quality, timeStamp }
// msg.topic 是 UNS 话题路径
msg.query = `INSERT INTO sensor_data (topic, ts, value, quality)
             VALUES ($1, to_timestamp($2::bigint / 1000.0), $3, $4)
             ON CONFLICT DO NOTHING`;
msg.params = [
  msg.topic,
  msg.payload.timeStamp,
  JSON.stringify(msg.payload.value),
  msg.payload.quality || 'Unknown'
];
return msg;
```

## 可用模板

| 文件 | 协议 | Flow 类型 | 用途 |
|------|------|-----------|------|
| `modbus-tcp-read.json` | Modbus TCP | SourceFlow | 周期性轮询读寄存器/线圈 → function → MQTT/UNS |
| `postgresql-uns-archive.json` | PostgreSQL | EventFlow | UNS MQTT 订阅 → function → INSERT 到用户自有库 |
| *(更多协议模板待补充)* | OPC-UA、OPC-DA、S7... | | |
