# Discover Edges and use their Sources

Start on the center with `POST /openapi/v2/uns/edges/list`, without a target.
Use `page` and `size` (maximum 100); optional filters are `keyword` and `status`.
Read `data.list` and `data.total`, paginate as needed, and select the returned
`fleetNodeId`. Discovery requires `uns.read`, not Fleet administrator access.
The list is workspace-scoped; infrastructure `online` is not a guarantee that
every business operation is available. App-bound and builder identities cannot
use this discovery/forwarding flow.

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

Use OpenAPI or MCP for this Agent workflow. The App SDK is not its delivery
surface. Do not mix target resource IDs or caches, and do not invent a CLI flag.

The header does not grant access. Cloud validates workspace ownership, operation
permissions and Edge consent; App-bound and builder-target identities are not
supported for this forwarding route. Fleet management endpoints have their own
permissions; a native business read does not universally require Fleet manage.
Enterprise centers retain their existing Fleet authorization and Cluster license.

Unknown or invalid targets are rejected before dispatch. A timeout after dispatch
can leave a write outcome unknown: query the same target first and preserve the
original idempotency key. Never interpret transport failure as safe to resend.

## Connect a cloud Stream to an Edge Source

Read the target Source document first. The current cloud input adapter supports
enabled native `modbus-tcp` Sources; other protocols and event subscriptions are
not supported by this adapter. Keep device address, Unit ID and credentials on
the Edge. Pin the Source's `configRevision` and read the current center catalog
for the create/deploy contracts.

On the **center**, create a Source document with `protocol: "edge"` and:

```json
{
  "endpoint": "edge://<fleetNodeId>/<nativeSourceId>",
  "options": {"protocol": "modbus", "configRevision": 1}
}
```

This is the Source document's `config`, not an HTTP URL prefix. Use the actual
Edge revision instead of the example's `1`. Center create/deploy calls omit
`fleetNodeId`. In the cloud Stream document, bind the new center Source ID and
its revision under `sources`, choose an alias, specify `acquisition.ranges`
(`id`, `table`, `address`, `quantity`), and allow matching
`resources: ["modbus:<rangeId>"]`. The Stream reads through
`api.sources.use(alias).read("modbus:<rangeId>")` and can write a cloud Collection.
Deploy through the current Stream API and verify the resulting business data.
Creating a reference or draft alone does not prove device connectivity.

The fixed read path requires business read and Source view/manage permissions,
workspace ownership, the pinned configuration and an enabled Edge Source.
Manual Request grants and confirmations still apply. This does not authorize
device writes or host administration. Use current OpenAPI/MCP contracts for
creating the reference.

Validated on development Cloud → Windows Edge on 2026-11-03: HTTP resource
reads; MCP discovery followed by target Source/Stream/Collection lists; and a
cloud timer Stream reading an Edge Modbus simulator into a cloud Collection,
with its business result read back through MCP. This does not prove other
protocols or device-control execution.
