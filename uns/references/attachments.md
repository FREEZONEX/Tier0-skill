---
name: tier0-uns-attachments
version: 0.3.0
description: "上传和查询绑定到 UNS 节点的附件。triggers: Tier0, UNS, 附件, 文件, 上传, 查询"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, attachments, files]
---

# attachments — UNS 附件

## 说明

附件必须绑定到 `unsId`，一个文件只属于指定 UNS 节点。接口不暴露内部附件 id，统一用 `filePath` 标识文件；返回的 `fileUrl` 可以直接下载，过期后重新查询获取新的 URL。

## 命令

```bash
tier0 uns attachments upload --uns-id <unsId> --file <local-file> [--file-name <name>] [--sha256 <sha256>]
tier0 uns attachments list --uns-id <unsId> [--page-no 1] [--page-size 20] [--include-file-url=true]
```

| Flag | 说明 |
|------|------|
| `--uns-id` | ✅ UNS 节点 ID |
| `--file`, `-f` | 上传的本地文件 |
| `--file-name` | 覆盖附件文件名 |
| `--sha256` | 可选客户端 sha256 |
| `--page-no` | 查询页码，默认 1 |
| `--page-size` | 查询每页条数，默认 20 |
| `--include-file-url` | 是否返回可下载 `fileUrl`，默认 true |
| `--json` | 原始 JSON 输出 |

## API

上传：

```http
POST /openapi/v1/uns/:unsId/attachments
Content-Type: multipart/form-data
```

查询：

```http
POST /openapi/v1/uns/:unsId/attachments/list?pageNo=1&pageSize=20&includeFileUrl=true
```

## 示例

```bash
# 上传附件
tier0 uns attachments upload --uns-id 10001 --file manual.pdf

# 指定文件名和 sha256
tier0 uns attachments upload --uns-id 10001 --file ./manual.pdf --file-name manual-v2.pdf --sha256 <sha256>

# 查询附件
tier0 uns attachments list --uns-id 10001

# JSON 输出，读取 fileUrl
tier0 uns attachments list --uns-id 10001 --json
```

## 响应字段

| 字段 | 说明 |
|------|------|
| `unsId` | UNS 节点 ID |
| `fileName` | 文件名 |
| `filePath` | 文件标识路径，后续以它识别附件文件 |
| `fileUrl` | 可直接下载的 URL |
| `contentType` | 文件 Content-Type |
| `size` | 文件大小 |
| `sha256` | 客户端传入或服务端计算的 sha256 |
| `createdAt` | 创建时间，毫秒时间戳 |
| `fileUrlExpiresAt` | 下载 URL 过期时间，毫秒时间戳 |

## 注意

- `fileUrl` 过期后不要拼接下载地址，重新执行 `attachments list` 获取新的 `fileUrl`。
- 错误的 `unsId` 会返回失败；不要用 alias 或内部 nodeId 以外的字段替代。
- 查询不同 `unsId` 不会串出其他 UNS 节点的附件。
