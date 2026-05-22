---
name: tier0-flow-nodes
version: 0.3.0
description: "Tier0 Flow（Node-RED）内置节点一览。触发场景: 构造 flowsJson、查询可用节点、了解节点 type 字符串"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, nodered, nodes, flowsjson]
---

# Node-RED 内置节点

Tier0 Flow 环境基于标准 Node-RED，以下节点开箱即用，**构造 flowsJson 时无需额外安装**。

> **关键**：flowsJson 中每个节点对象的 `"type"` 字段必须与下表"type 字符串"完全一致，否则 Node-RED 无法识别。

---

## 常用节点（Common）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| Inject | `inject` | 定时或手动触发，输出 `msg.payload` / `msg.topic` |
| Debug | `debug` | 输出调试信息到侧边栏，不影响流程 |
| Complete | `complete` | 检测指定节点完成事件 |
| Catch | `catch` | 捕获同 Tab 内节点抛出的错误 |
| Status | `status` | 监听节点状态变化 |
| Link In | `link in` | 跨 Tab / 跨 Flow 接收链接 |
| Link Out | `link out` | 跨 Tab / 跨 Flow 发送链接 |
| Link Call | `link call` | 同步调用 Link In 并等待返回 |
| Comment | `comment` | 注释，不参与数据流 |

---

## 功能节点（Function）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| Function | `function` | 用 JavaScript 自定义处理逻辑，可输出多个 msg |
| Switch | `switch` | 按条件分支路由 msg |
| Change | `change` | 设置、移动、删除 msg / flow / global 属性 |
| Range | `range` | 数值范围映射缩放 |
| Template | `template` | Mustache 模板渲染字符串 |
| Delay | `delay` | 延迟或限速消息流 |
| Trigger | `trigger` | 定时发送消息，可用于超时检测 |
| Exec | `exec` | 执行系统命令，返回 stdout / stderr |
| Filter (RBE) | `rbe` | 仅在值变化时才通过消息（Report By Exception） |

---

## 网络节点（Network）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| HTTP Request | `http request` | 发起 HTTP/HTTPS 请求，支持 GET/POST/PUT/DELETE 等 |
| HTTP In | `http in` | 创建 HTTP 端点，接收入站请求 |
| HTTP Response | `http response` | 向 HTTP In 的请求回送响应 |
| WebSocket In | `websocket in` | 接收 WebSocket 消息 |
| WebSocket Out | `websocket out` | 发送 WebSocket 消息 |
| TCP In | `tcp in` | 接收 TCP 连接数据 |
| TCP Out | `tcp out` | 发送 TCP 数据 |
| TCP Request | `tcp request` | 发送 TCP 请求并等待响应 |
| UDP In | `udp in` | 接收 UDP 数据报 |
| UDP Out | `udp out` | 发送 UDP 数据报 |

---

## MQTT 节点

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| MQTT In | `mqtt in` | 订阅 MQTT topic，接收消息 |
| MQTT Out | `mqtt out` | 发布消息到 MQTT topic |
| MQTT Broker（配置节点）| `mqtt-broker` | 连接配置，被 MQTT In / Out 引用，不出现在画布 |

---

## 序列节点（Sequence）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| Split | `split` | 拆分数组 / 字符串 / 对象为多条 msg |
| Join | `join` | 合并多条 msg 为数组 / 字符串 / 对象 |
| Sort | `sort` | 对序列中的 msg 排序 |
| Batch | `batch` | 按数量或时间窗口分批打包 msg |

---

## 解析节点（Parser）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| CSV | `csv` | CSV ↔ JSON 互转 |
| HTML | `html` | 用 CSS 选择器从 HTML 提取内容 |
| JSON | `json` | JSON 字符串 ↔ JavaScript 对象互转 |
| XML | `xml` | XML 字符串 ↔ JavaScript 对象互转 |
| YAML | `yaml` | YAML 字符串 ↔ JavaScript 对象互转 |

---

## 存储节点（Storage）

| 节点 | type 字符串 | 说明 |
|------|------------|------|
| File | `file` | 写入文件（追加或覆盖） |
| File In | `file in` | 读取文件内容 |
| Watch | `watch` | 监听文件或目录变化 |

---

## 需额外安装的节点（非内置）

以下节点**不内置**，需在 Node-RED Palette Manager 或镜像中预装后才可在 flowsJson 中使用：

| 节点包 | type 字符串前缀 | 协议文档 |
|--------|---------------|---------|
| node-red-contrib-modbus | `modbus-*` | `references/protocols/modbus.md` |
| node-red-contrib-postgresql | `postgresql` | `references/protocols/postgresql.md` |

> 使用这些节点前必须先读对应协议文档，其 flowsJson 结构与内置节点有所不同。
