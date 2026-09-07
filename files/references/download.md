---
name: tier0-files-download
description: "Download a file from Tier0 object storage."
---

# download — Download a file

## API

```
GET /openapi/v1/assets/files/download?filePath={filePath}&responseContentDisposition={...}
```

## Request

| Field | Type | Required | Description |
|------|------|------|------|
| `filePath` | string | **Yes** | Object key returned by upload |
| `responseContentDisposition` | string | No | Custom Content-Disposition header |

## Response

302 redirect to the actual object storage URL (public or presigned).

## CLI

```bash
tier0 assets download --file-path workspace/.../report.csv -o ./report.csv
```

## Notes

- `filePath` must be URL-encoded.
- Private files use short-lived presigned URLs (default 3600 seconds).
- This reference documents CLI/raw API behavior. When generating a browser
  application, use the `tier0-sdk` skill instead.
- Browser attachment downloads must keep the Tier0 API key on the server,
  resolve `filePath` from a server-owned business record ID, stream
  `downloadFile().response.body` through a same-origin application route, then
  save the response Blob with `<a download>`.
- Do not generate `getFileUrl()` followed by `window.open()`, `location.href`,
  or a new-tab link for private attachments. Do not rely on
  `responseContentDisposition` to force browser download.
