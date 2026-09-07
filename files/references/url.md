---
name: tier0-files-url
description: "Get file access URL from Tier0 object storage."
---

# url — Get file access URL

## API

```
GET /openapi/v1/assets/files/url?filePath={filePath}&expiredSec={expiredSec}&responseContentDisposition={...}
```

## Request

| Field | Type | Required | Description |
|------|------|------|------|
| `filePath` | string | **Yes** | Object key returned by upload |
| `expiredSec` | number | No | Presigned URL expiration seconds (default 3600) |
| `responseContentDisposition` | string | No | Custom Content-Disposition header |

## Response

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "fileUrl": "https://s3.ap-southeast-1.amazonaws.com/...",
    "expiresAt": 1784537770739
  }
}
```

## CLI

```bash
tier0 assets url --file-path workspace/.../report.csv --expired-sec 300
```

## Notes

- Public files return a long-lived URL without `expiresAt`.
- Private files return a presigned URL with `expiresAt`.
- Use this endpoint for previews, media references, temporary sharing, or other
  cases that specifically require a URL. Do not use it to implement a browser
  application's attachment download button.
- For browser application downloads, use the `tier0-sdk` skill:
  `downloadFile` runs on the server, a same-origin authenticated route streams
  the response, and the browser saves a Blob with `<a download>`.
- Do not navigate to or `window.open()` a private presigned URL. PDF files may
  enter the built-in viewer or be blocked by browser policy/extensions.
- `responseContentDisposition` does not replace the browser-side `download`
  attribute and must not be treated as a portable force-download mechanism.
