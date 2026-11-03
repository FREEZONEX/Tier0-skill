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
- `tier0 assets download` only follows same-origin redirects. A redirect to a different object-storage origin is blocked, even when it is a valid public or presigned URL; the CLI does not send its API key to that origin. Use a trusted direct storage download workflow when available. Treat presigned URLs and diagnostic output as secrets.
