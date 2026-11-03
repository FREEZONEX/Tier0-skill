---
name: tier0-files-download
description: "Download a file from Tier0 object storage."
---

# download — Download a file

## API

```
GET /openapi/v2/assets/files/download?filePath={filePath}&responseContentDisposition={...}
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
- The CLI tries v2 first and falls back to v1 only on a direct gateway HTTP 404, before any redirect.
- The CLI follows cross-origin public or presigned storage URLs only over HTTPS. It strips request headers, including the API key, and rejects HTTPS-to-HTTP downgrades and more than five redirects. Treat presigned URLs as secrets.
