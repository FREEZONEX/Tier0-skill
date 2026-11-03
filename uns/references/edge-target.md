# Native UNS calls to an Edge

Use the center's existing API host and an authorized identity bound to the Edge's
workspace. Keep the native `/openapi/v2/uns/...` path and set
`X-Fleet-Node-Id` to the registered node ID. Do not add a node path prefix, request
an Edge IP, forward enrollment credentials, or silently retry against the center.
Omitting the target means the center. IDs are strings, including numeric-looking IDs.

Cloud MCP `execute` exposes the typed `fleetNodeId` option:

```javascript
async () => {
  return await tier0.request({
    method: "POST",
    path: "/openapi/v2/uns/catalog/get",
    fleetNodeId: "<registered-node-id>",
    body: {}
  });
}
```

Read that target catalog before unfamiliar operations. The ordinary MCP search
spec describes the center and must not be assumed to match every Edge version.
Reuse the same target for subsequent metadata, Source, Stream and record calls.
The `calls` ledger includes `fleetNodeId`; inspect both HTTP status and outcome.
Operation-mode MCP tools also accept the optional `fleetNodeId` argument.
Non-UNS paths cannot be targeted; use ordinary untargeted `whoami` for identity.

SDK: create a separate `createClient({ apiHost, apiKey, fleetNodeId })` instance
per target. Supported examples are `client.uns.metadataFind`,
`client.source.documents.list`, `client.stream.programs.list`, and
`client.uns.recordFind`; they return the normal UNS envelope. Do not mix target
resource IDs or caches. Check the installed SDK/MCP version exposes this option.
Do not invent a CLI flag: this guide specifies HTTP, SDK and MCP behavior only.

The header does not grant access. Cloud validates workspace ownership, operation
permissions and Edge consent; App-bound and builder-target identities are not
supported for this forwarding route. Fleet management endpoints have their own
permissions; a native business read does not universally require Fleet manage.
Enterprise centers retain their existing Fleet authorization and Cluster license.

Unknown or invalid targets are rejected before dispatch. A timeout after dispatch
can leave a write outcome unknown: query the same target first and preserve the
original idempotency key. Never interpret transport failure as safe to resend.

Validated on development Cloud → Windows Edge on 2026-11-03: target catalog,
Collection metadata, Source documents, Stream programs and workorder reads via
HTTP and SDK; MCP execute metadata read with target recorded in its call ledger.
This read-only acceptance does not prove write or device-control execution.
