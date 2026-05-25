---
name: tier0-flow-protocol-http
version: 0.3.0
description: "HTTP Request 协议节点：定时轮询第三方 REST API，将返回数据发布到 UNS。"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, http, rest, api, sourceflow, polling]
---

# HTTP Request — 定时轮询第三方 REST API → UNS

> 使用 Node-RED 内置节点 `inject` + `http request` + `function` + `mqtt out`，
> 按固定间隔请求外部 REST API，将返回数据解析后发布到 Tier0 UNS。
>
> **不需要安装额外 npm 包**，Node-RED 内置，本地环境即可测试。

---

## 何时使用

- 用户要对接第三方系统（ERP、MES、天气服务、设备云平台等）的 HTTP API
- 用户要定时拉取外部接口数据并写入 UNS
- 用户说"轮询 API"、"定时请求"、"HTTP 采集"、"REST 接入"

## 不应该使用

- 外部系统主动推送数据（Webhook 模式）→ 改用 `http in` + `http response` 节点
- 已有 MQTT 数据流，不需要 HTTP 桥接
- 用户只是想读/写 UNS 数据 → 走 `tier0 uns` 命令

---

## 不可违反规则

1. **先备份再部署** — 对现有 Flow 部署前必须先 `tier0 flow data --id <id> --out backup.json`
2. **function 节点必须写** — `{{FUNCTION_BODY}}` 不能留空，须根据 API 返回结构解析数据
3. **先确认 API 返回格式** — 写 function 前必须知道 API 的响应 JSON 结构
4. **先查 UNS topic 字段定义** — 写 function 前用 `tier0 uns browse` 确认目标 topic 的字段名

---

## 节点架构

```
[inject] → [http request] → [function] → [mqtt out] → Tier0 UNS
    ↑             ↓
  定时触发     调用外部 API       解析响应          发布到 UNS
             (GET/POST)        构造 UNS write
```

> 可选：在 `function` 后加 `[debug]` 节点，部署后在 Node-RED 侧边栏确认数据结构。

---

## 节点说明

### inject（定时触发）

| 字段 | 说明 | 推荐值 |
|------|------|--------|
| `repeat` | 重复模式 | `interval`（固定间隔） |
| `crontab` | cron 表达式（`repeat` 为 `cron` 时） | `*/5 * * * *`（每 5 分钟） |
| `once` | 启动时立即触发一次 | `true`（推荐，避免等待第一个间隔） |
| `onceDelay` | 启动后延迟多少秒触发 | `0.1` |
| `payload` | 传给 http request 的初始 payload | 通常为空或 `{}` |
| `topic` | 初始 topic | 通常留空 |

**interval 模式字段：**

| 字段 | 说明 | 示例 |
|------|------|------|
| `repeat` | `"interval"` | — |
| `crontab` | 留空 | — |
| 间隔数值 | 由 `payloadType` + `payload` 控制 | 见模板 |

> Node-RED 的 inject 节点用 `"repeat": "interval"` 时，实际间隔由 `props` 数组里的 `interval` 和 `intervalType` 字段控制（见模板注释）。

---

### http request（调用外部 API）

| 字段 | 说明 | 示例 |
|------|------|------|
| `method` | HTTP 方法 | `GET` / `POST` / `PUT` |
| `ret` | 响应格式 | `obj`（自动 JSON 解析，**推荐**） / `txt` / `bin` |
| `url` | 目标 URL（支持 `{{msg.url}}` 动态 URL） | `https://api.example.com/v1/data` |
| `tls` | TLS 配置节点 ID（HTTPS 时） | 留空则使用系统默认 CA |
| `persist` | 保持 TCP 连接（keep-alive） | `false` |
| `authType` | 认证方式 | `""` 无认证 / `"basic"` / `"bearer"` |

**认证配置：**

- 无需认证：`authType: ""`
- Basic Auth：`authType: "basic"`，需设 `credentials.user` 和 `credentials.password`
- Bearer Token：在 function 节点里设 `msg.headers = { Authorization: "Bearer {{TOKEN}}" }`，`authType: ""`
- API Key（Header）：同 Bearer，改为 `msg.headers = { "X-API-Key": "{{API_KEY}}" }`

**响应数据位置：**

设置 `ret: "obj"` 时，API 返回的 JSON 自动解析为对象，位于 `msg.payload`：

```javascript
// 示例：API 返回 { "temperature": 25.3, "humidity": 60 }
msg.payload.temperature  // → 25.3
msg.payload.humidity     // → 60
```

---

### function（解析响应 → 构造 UNS write）

将 API 响应映射为 UNS write body：

```javascript
// msg.payload 是 http request 返回的 JSON 对象（ret: "obj" 时已自动解析）
var data = msg.payload;

var writes = [];
writes.push({
  topic: "Plant/Line1/Metric/Environment",
  value: {
    temperature: data.temperature,
    humidity: data.humidity
  }
});

msg.payload = JSON.stringify({ writes: writes });
msg.topic = "Plant/Line1/Metric/Environment";
return msg;
```

**处理 API 错误：**

```javascript
// 检查 HTTP 状态码（msg.statusCode）
if (msg.statusCode !== 200) {
  node.warn("API error: " + msg.statusCode);
  return null;  // 不往下传，丢弃这条消息
}
var data = msg.payload;
// ... 正常处理 ...
```

**处理 API 返回数组：**

```javascript
// 示例：API 返回 [{ id: 1, value: 25.3 }, { id: 2, value: 60 }]
var items = msg.payload;
var writes = [];
items.forEach(function(item) {
  writes.push({
    topic: "Plant/Line1/Sensor/" + item.id,
    value: { value: item.value }
  });
});
msg.payload = JSON.stringify({ writes: writes });
return msg;
```

---

### mqtt out（发布到 Tier0 UNS）

| 字段 | 说明 | 值 |
|------|------|-----|
| `broker` | 引用 mqtt-broker 配置节点 | `mqtt_broker_{{FLOW_ID}}` |
| `topic` | UNS topic（可由 function 节点的 `msg.topic` 动态覆盖） | `{{UNS_TOPIC}}` |
| `qos` | QoS 等级 | `"0"` |
| `retain` | 是否保留消息 | `"false"` |

---

## 快速部署流程

```bash
# 1. 确认 UNS topic 字段结构
tier0 uns browse --path "Plant/Line1"

# 2. 确认目标 Flow ID（SourceFlow）
tier0 flow list --source

# 3. 备份现有画布
tier0 flow data --id <id> --out backup.json

# 4. 用模板，替换占位符（参考下方示例和 templates/README.md）

# 5. 部署（需用户确认）
tier0 flow deploy --id <id> -f my-http-poller.json --yes
```

---

## 典型示例

### 场景：每 30 秒轮询天气 API，发布到 UNS

占位符替换值：

| 占位符 | 示例值 |
|--------|--------|
| `{{FLOW_ID}}` | `weather_poll` |
| `{{FLOW_NAME}}` | `Weather API Poller` |
| `{{POLL_INTERVAL_S}}` | `30` |
| `{{API_URL}}` | `https://api.open-meteo.com/v1/forecast?latitude=31.23&longitude=121.47&current_weather=true` |
| `{{API_METHOD}}` | `GET` |
| `{{MQTT_HOST}}` | `127.0.0.1` |
| `{{MQTT_PORT}}` | `1883` |
| `{{UNS_TOPIC}}` | `Plant/Site/Weather/Current` |
| `{{FUNCTION_BODY}}` | 见下方 |

**`{{FUNCTION_BODY}}` 示例（Open-Meteo API）：**

```javascript
if (msg.statusCode !== 200) {
  node.warn("Weather API error: " + msg.statusCode);
  return null;
}
var w = msg.payload.current_weather;
var writes = [{
  topic: "Plant/Site/Weather/Current",
  value: {
    temperature: w.temperature,
    windspeed: w.windspeed,
    weathercode: w.weathercode
  }
}];
msg.payload = JSON.stringify({ writes: writes });
msg.topic = "Plant/Site/Weather/Current";
return msg;
```

### 场景：轮询内部 MES API（需 Bearer Token）

在 function 节点**前**加一个 `function` 节点设置请求头：

```javascript
// 第一个 function：设置认证 Header
msg.headers = {
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
};
return msg;
```

> 也可以直接在 `http request` 节点前的 inject 触发后、http request 前加这个 function。

---

## 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| `msg.payload` 是字符串而不是对象 | `ret` 未设为 `obj` | 将 `http request` 的 `ret` 改为 `"obj"` |
| 状态码 401 / 403 | 认证失败 | 检查 Token / API Key；确认 Header 名称 |
| 状态码 429 | 请求频率超限 | 调大 `inject` 的间隔时间 |
| UNS 没有收到数据 | function 返回了 `null` | 检查 `msg.statusCode`；用 debug 节点看原始响应 |
| 第一次要等很久才有数据 | inject 未设 `once: true` | 在 inject 节点勾选"启动时立即触发" |
| HTTPS 证书错误 | 自签名证书 | 在 `http request` 节点配置 TLS，或临时用 `http` 协议测试 |
