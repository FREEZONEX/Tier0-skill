# Tier0 OPC-UA Client

Use this guide for `@tier0/opcua-client`, Tier0's own open62541-backed
Node-RED client. It does not provide an OPC-UA server. Do not use the
`OpcUa-Client` / `OpcUa-Endpoint` community template or its DataValue parser.

## Contents

- [Before generating a Flow](#before-generating-a-flow)
- [Node types and shared connection](#node-types-and-shared-connection)
- [Point lists](#point-lists)
- [Browse and Read](#browse-and-read)
- [Subscribe: auto-start and control](#subscribe-auto-start-and-control)
- [Write](#write)
- [Siemens WinCC](#siemens-wincc)
- [Template and verification](#template-and-verification)

## Before Generating a Flow

1. Run `tier0 flow nodes --source --json` and verify required types are enabled.
2. Confirm endpoint, security requirements, real NodeIds, and expected data types.
3. Inspect target UNS schemas; map actual values to matching fields and types.
4. Export the existing canvas, reuse its OPC-UA Connection where appropriate,
   and preserve the backend-created Tier0 `mqtt-broker` node and its ID.
5. Read `../deploy.md`, preview the final canvas, show replacement impact, and
   wait for confirmation before deploying with `--yes`. Writes to equipment
   require explicit authorization for the target point and value as well.

## Node Types and Shared Connection

| Type | Purpose | Important fields |
| --- | --- | --- |
| `tier0-opcua-connection` | Shared client / Session config | `endpoint`, `securityMode`, `securityPolicy`, `compatibilityProfile` |
| `tier0-opcua-browse` | Browse or emit editor-selected points | `connection`, `rootNodeId`, `selectedNodes`, `outputMode` |
| `tier0-opcua-read` | Read values on input | `connection`, `nodeId` or `pointList`, `batchSize`, `outputMode`, `resultDetail` |
| `tier0-opcua-write` | Write values on input | `connection`, `nodeId` or `pointList`, `dataType`, `batchSize`, `outputMode` |
| `tier0-opcua-subscribe` | Persistent change subscription | `connection`, `nodeId` or `pointList`, subscription and queue settings |

All operation nodes refer to the Connection node ID using **`connection`**,
not `endpoint`. Its `endpoint` is the actual `opc.tcp://host:port` URL.
Reuse one Connection for the same server/security identity, including across
tabs. Creating equivalent Connection nodes creates separate Sessions;
`allowParallelSession: true` only suppresses the duplicate-session warning.

Connection defaults in this source version: `requestedSessionTimeout: 60000`,
`requestTimeout: 10000`, `connectivityCheckInterval: 5000`,
`reconnectInterval: 5000`, `maxReconnectInterval: 30000` (milliseconds),
`nodeIdCacheSize: 100000`, `commandQueueSize: 256`.

### Security

- `securityMode`: `None`, `Sign`, or `SignAndEncrypt`.
- `securityPolicy`: `None`, `Basic256Sha256`,
  `Aes128_Sha256_RsaOaep`, or `Aes256_Sha256_RsaPss`.
- `None`/`None` is only appropriate when the server and environment explicitly
  permit it; do not downgrade a secure endpoint to make a connection succeed.
- Secure connections require `certificate`, `privateKey`, and a nonempty
  `trustedCertificates` list. Paths must exist **inside the Node-RED runtime**,
  not just on the user's workstation. Trust/revocation paths accept newline or
  semicolon-separated lists. Configure `applicationUri` to match the certificate.
- `user` is config; `password` and `privateKeyPassword` are Node-RED credentials.
  Never embed secrets in example Flow JSON or assume exports contain them.
- `/opcua-client/browse`, `/opcua-client/endpoints`,
  `/opcua-client/test-connection`, and `/opcua-client/security-files` are
  authenticated **Node-RED Admin** helpers, not Tier0 OpenAPI routes. Do not
  call them through `/flow/source/**` or `/flow/event/**`.

## Point Lists

For read/subscribe, use `msg.payload` as a descriptor array (or JSON/CSV point
list), `msg.items`, or the configured `pointList`. A valid message point list
takes precedence over configured points. `nodeId` / `msg.nodeId` / `msg.topic`
support single-point requests. Use a clean message to avoid stale selectors.

```json
[
  {"nodeId":"ns=2;s=Temperature","alias":"temperature","samplingInterval":1000},
  {"nodeId":"ns=2;s=Running","alias":"running","samplingInterval":1000}
]
```

In saved Flow JSON, **`pointList` is a JSON or CSV string**, not a nested
array; `selectedNodes` on Browse is an array. CSV requires a `nodeId` header.
Duplicate NodeIds use the last descriptor; `enabled: false` disables a point.
NodeIds are exact server IDs; do not append community `;datatype=Double`
suffixes. Optional point settings include `alias`, `dataType`,
`samplingInterval`, `queueSize`, `discardOldest`, `deadbandType`,
`deadbandValue`, and `indexRange`. Read/write ranges use forms such as `2:5`
or `0:1,2:3`.

## Browse and Read

Browse defaults to `rootNodeId: "ns=0;i=85"` (Objects), `recursive: true`,
`variablesOnly: true`, `maxDepth: 10`, `maxNodes: 10000`,
`browseBatchSize: 100`, `referencesPerNode: 1000`, `attributeBatchSize: 200`.
When `selectedNodes` is nonempty, input emits the saved selection unless
`msg.opcua.liveBrowse: true` requests a live browse. A live root may be supplied
via `msg.nodeId` or `msg.topic`; `msg.opcua.namespaceIndexes` filters namespaces.

`outputMode: "all"` emits a descriptor array with `msg.opcua.command: "replace"`.
`"paged"` uses `pageSize` (default 500), then `replace` for the first page and
`add` for subsequent pages, suitable for feeding Subscribe. Check
`msg.opcua.browse` diagnostics, `truncated`, and `truncationReason`; reaching a
limit or partial browse failure is not proof that all points were discovered.

Read is input-triggered, with `batchSize: 500`. Set `resultDetail: "compact"`
and `outputMode: "batch"` explicitly for descriptor-list reads:

```json
{
  "payload": [
    {"nodeId":"ns=2;s=Temperature","alias":"temperature","value":23.5,"statusCode":"Good","sourceTimestamp":"2026-09-07T00:00:00.000Z"}
  ],
  "opcua": {"operation":"read","total":1,"good":1,"resultDetail":"compact"}
}
```

`outputMode: "split"` emits one message per result, with `msg.topic` = NodeId,
`msg.payload` = decoded value, and `msg.opcua` = result metadata. Legacy
single-point reads without a point list also use this scalar shape even when
outputMode is batch. `resultDetail: "value"` removes quality information; use
compact when quality matters. Omitted `resultDetail` uses legacy full output.

## Subscribe: Auto-start and Control

For continuous collection use Subscribe, not repeated Read calls. A nonempty
configured `pointList` or `nodeId` **starts automatically after deployment**;
no Inject timer is needed. Dynamic input supports these `msg.opcua.command`
values (default `replace`):

| Command | Effect |
| --- | --- |
| `replace` | Reconcile the desired set; unchanged points remain subscribed |
| `add` | Add/update the supplied points |
| `remove` | Remove supplied NodeIds |
| `clear` | Clear all desired points; no point list needed |

```js
// Dynamic point-set update, sent to tier0-opcua-subscribe.
return {
  opcua: { command: "add" },
  payload: [{ nodeId: "ns=2;s=Temperature", alias: "temperature" }]
};
```

For new generated subscriptions, explicitly set:

| Field | Starting value | Meaning |
| --- | --- | --- |
| `publishingInterval` / `samplingInterval` | 1000 / 1000 | Requested server publish/sample periods, ms |
| `queueSize` / `discardOldest` | 1 / true | Server monitored-item queue, per point |
| `deadbandType` / `deadbandValue` | `none` / 0 | `none`, `absolute`, or `percent`; subject to server support |
| `timestampMode` | `source` | Also supports `both`, `server`, `neither` |
| `batchSize` | 500 | Monitored-item request batch size |
| `maxItemsPerSubscription` | 5000 | Requested shard cap, also bounded by server limits |
| `outputMode` / `resultDetail` | `batch` / `compact` | Change arrays with quality metadata |
| `callbackBatchSize` / `callbackFlushIntervalMs` | 500 / 50 | Node-RED callback output batching |
| `callbackQueueSize` | 10000 | Native callback capacity **per server subscription** |
| `queueMode` / `overflowPolicy` | `latest` / `drop-oldest` | Coalesce pending updates / bounded overflow behavior |

Missing fields can select legacy defaults (`resultDetail: full`,
`queueMode: all`, monitored-item `queueSize: 10`), not the new editor defaults.
`latest` is for current-state monitoring and may coalesce intermediate values.
`all` retains changes only within finite queues: neither mode guarantees
lossless history, especially across disconnections. Check server-revised
sampling/publishing/queue settings, not only requested values.

### Output Contract and UNS Mapping

Compact **batch** notification:

```json
{
  "payload": [
    {"nodeId":"ns=2;s=Running","alias":"running","value":false,"statusCode":"Good","sourceTimestamp":"2026-09-07T00:00:00.000Z"}
  ],
  "opcua": {"operation":"change","total":1,"subscriptionCount":1,"resultDetail":"compact","queue":{}}
}
```

The batch contains **changes, not a complete point snapshot**. Iterate each
entry; use `nodeId` (or a deliberate alias mapping), `value`, and string
`statusCode === "Good"`. Never use `payload.value.value` or
`statusCode.value === 0` here. Preserve `0`, `false`, arrays, and strings;
do not blindly apply `Number()`. Int64/UInt64 outside JavaScript's safe integer
range are decimal strings; preserve them and choose a compatible UNS schema.

The same output port also emits `msg.opcua.operation: "subscription-status"`
for startup/commands/recovery, with payload fields such as `desired`,
`monitored`, `failed`, `failures`, `subscriptionCount`, and revised settings.
Do not publish these objects as measurements. The template filters for
`operation === "change"` and sends non-Good results to a separate diagnostic
output. An active node alone does not prove every desired point succeeded.

`outputMode: "single"` instead emits scalar `msg.payload`, NodeId in
`msg.topic`, and change metadata in `msg.opcua`; do not reuse the batch filter
unchanged (the operation marker is not present on every single-mode message).
Batch `resultDetail: "value"` emits values plus parallel `msg.opcua.identifiers`
(alias or NodeId), without quality; do not assume stable positional snapshots.
Compact mode retains source timestamps only; use full output if server
timestamps or richer diagnostics are required.

Monitor `msg.opcua.queue` for `dropped`, `coalesced`, `queueDepth`,
`queueCapacity`, and `maxLagMs`. Rebuilt subscription recovery can signal
`msg.opcua.dataGapPossible: true`; report possible gaps, not lossless recovery.
Use a Node-RED Catch node for operation errors and diagnostics for partial
failures/bad quality.

## Write

Write only user-approved values to user-approved points. Use explicit types:

```js
return {
  opcua: { pointList: true },
  payload: [{ nodeId: "ns=2;s=Setpoint", dataType: "Double", value: 25.5 }]
};
```

The default `dataType` is `String`, not automatic numeric inference. For large
Int64/UInt64 values, supply decimal strings. Use CSV headers
`nodeId,value,dataType` to declare types explicitly. A single configured target with an array payload
treats that array as the **value**; use `msg.opcua.pointList: true` to force
descriptor-list interpretation and remove stale topic/nodeId selectors.
Configured write points may use `useInput: true`: one point uses msg.payload;
multiple points use a payload object keyed by NodeId or alias.

Write batch output contains acknowledgements with `statusCode` and
`msg.opcua.operation: "write"`, `total`, `good`. Split output places each
acknowledgement in `msg.opcua` and keeps the input payload. It is **not a
read-back value**; inspect each acknowledgement and read back if needed.

## Siemens WinCC

Set `compatibilityProfile: "siemens-wincc"` on the shared Connection only
when targeting WinCC. Standard is the default. In this source version the
profile uses 200 as the fallback service batch size when usable OperationLimits
are unavailable, caps monitored items at 1000 per subscription (server limits
can lower this), and disables deadband. Do not promise that an entered
deadband remains active under this profile.

## Template and Verification

`templates/tier0-opcua-subscribe.json` provides a static auto-start compact-batch
subscription, per-NodeId UNS mapping, and a diagnostic branch. Replace the
example endpoint, security settings, NodeIds, field mappings, and broker-ID
placeholder. Merge preserved config nodes into the final canvas; do not deploy
the template unchanged. Confirm desired/monitored/failed counts, received
quality, queue diagnostics, and actual UNS values after an authorized deploy.

Source baseline: `@tier0/opcua-client` 0.6.0, commit
`9d8a6c83744b266a7fb79ef4aad4440a8120821b` in
`https://github.com/loliuy/opcua-client`.
Contracts checked against `nodes/{connection,browse,read,write,subscribe}.{js,html}`,
`lib/points.js`, and `lib/compatibility.js`. Recheck source/runtime version
before relying on newer behavior.
