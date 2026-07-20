---
name: tier0-files-upload
description: "Upload a file to Tier0 object storage."
---

# upload — Upload a file

## API

```
POST /openapi/v1/assets/files
```

## Request

| Field | Type | Required | Description |
|------|------|------|------|
| `fileName` | string | **Yes** | Original file name |
| `contentType` | string | **Yes** | MIME type |
| `size` | number | **Yes** | File size in bytes (0 < size ≤ 10MB) |
| `business` | string | No | Business scene, e.g. `attachment` |
| `useBy` | string | No | `user` / `workspace` / `platform`, default `user` |
| `visibility` | string | No | `public` / `private`, default `private` |
| `appInstanceId` | string | No | AI app instance ID |
| `sessionId` | string | No | AI session ID |

## Response

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "fileId": 12345,
    "filePath": "workspace/335601780494560/attachment/20260720/abcdef/test.txt",
    "fileUrl": "",
    "uploadUrl": "https://s3.ap-southeast-1.amazonaws.com/...",
    "expiresAt": 1784542276678
  }
}
```

## CLI

```bash
tier0 assets upload ./report.csv --use-by workspace --visibility private
```

## Flow

1. CLI requests `POST /openapi/v1/assets/files` with file metadata.
2. Backend returns `uploadUrl` (presigned PUT) and `filePath`.
3. CLI PUTs file content directly to `uploadUrl`.
4. Save `filePath` for download/url/delete operations.

## Notes

- `uploadUrl` expires in 3600 seconds by default.
- `useBy=workspace` is recommended for API Key authentication on Cloud.
- `visibility=public` returns a long-lived `fileUrl`.
