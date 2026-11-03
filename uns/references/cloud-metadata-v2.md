# Cloud and Enterprise metadata v2

Use this reference when the target instance exposes the `metadata/1`
OpenAPI v2 contract. Confirm the live `/openapi/v2/swagger.json` and
`/openapi/v2/uns/catalog/get` before constructing a request. A newer repository
revision does not prove that an instance has deployed it. Cloud and Enterprise
share the metadata action family but retain their own authentication and model
details: Enterprise adds `mountId` to metadata identities, keeps Collection
independent of directory placement, and uses dedicated App grants instead of
Cloud `appId/alias` creation binding. Read the target instance schema.

The existing `tier0 uns` command family manages legacy topic paths. Do not map
its create/update/delete flags to this API or invent CLI support. Use an enabled
OpenAPI/MCP client and its current operation schema; do not put credentials in
examples, generated application code or documentation.

## Select the operation

All routes below use `POST` under `/openapi/v2`.

| Intent | Route |
| --- | --- |
| Query metadata | `/uns/metadata:find` or `/uns/metadata:findOne` |
| Count, distinct values or aggregation | `/uns/metadata:count`, `:distinct` or `:aggregate` |
| Create one or many | `/uns/metadata` or `/uns/metadata:insertMany` |
| Update one or many | `/uns/metadata:updateOne` or `:updateMany` |
| Replace one object's configuration | `/uns/metadata:replaceOne` |
| Atomically mutate and return the object | `/uns/metadata:findOneAndUpdate`, `:findOneAndReplace` or `:findOneAndDelete` |
| Soft-delete one or many | `/uns/metadata:deleteOne` or `:deleteMany` |
| Restore explicit identities | `/uns/metadata:restore` |
| Mixed writes of one kind | `/uns/metadata:bulkWrite` |
| Dependent operations across kinds | `/uns/metadata:transact` |

The generic writable kinds are `directory`, `topic` and `collection`. A metadata
object is identified by `kind` and `id`. Source/Stream lifecycle, App grants,
credentials, internal tasks and runtime state use their dedicated APIs.

The old `/uns/metadata/query`, `/uns/meta/batch*` and per-kind basic CRUD routes
are retired from this contract. Do not fall back to them after a request fails.
The capability catalog and `/uns/references/query` remain separate operations.

## Build the request

- Read the operation schema for exact fields. Query configuration fields by
  bare paths such as `name` and `parentId`; use `_id` and `_meta.*` for identity
  and system fields. Returned objects place configuration under `data`.
- `state` is `active`, `deleted` or `all`; ordinary queries default to active.
  For edit forms, retain the returned `revision` as `expectedRevision` when
  saving. A conflict requires a fresh read and a new decision, not an automatic
  overwrite.
- Partial updates use `$set`, `$unset` and `$setOnInsert`. Replacements must
  supply valid complete writable configuration. Schema, index, parent and
  reference validation applies to both styles.
- Single-object upsert requires an explicit `_id` and a valid creation result.
  An existing soft-deleted identity is a conflict; restore it explicitly.
- Batch writes default to atomic execution, bounded to 200 objects.
  `bulkWrite` can explicitly select independent writes and `ordered` handling.
  `transact` remains atomic and supports `opId`, dependencies and references to
  prior created objects. Use it to create a directory, a child Collection and a
  Topic referring to that Collection together.
- Use `dryRun` for server-side validation. It neither commits nor reserves the
  objects; execution rechecks authorization and state. Reuse an
  `idempotencyKey` only for an identical write intent.

Example: atomically rename a directory and return the updated object with
`/uns/metadata:findOneAndUpdate`:

```json
{
  "kind": "directory",
  "filter": {"_id": "workshop-1"},
  "expectedRevision": 6,
  "update": {"$set": {"name": "Assembly"}},
  "returnDocument": "after",
  "dryRun": true
}
```

Replace the example ID and revision with values read from the target instance.
Set `dryRun` to false only when executing the authorized intent.

## Interpret the result

`find` returns `items/pageInfo`. `findOne` and `findOneAnd*` return `value`, which
can be null when no object matches. Metadata objects share
`kind/id/revision/createdAt/updatedAt/deletedAt/data`. Other mutations return
operation-specific counts and IDs; bulk IDs use the original zero-based input
indices. Check per-item errors when independent writes were requested.

Delete marks metadata as deleted; it does not implicitly cascade or physically
purge Record/Sample data. Restore revalidates names, parents and references.
For ambiguous write outcomes, inspect the response and current state before
retrying. MCP clients use `error.rolledBack` to distinguish a proven rollback
from an unknown outcome.

MCP derives its tools from the instance's Swagger. After an API rollout, refresh
the operation catalog before reusing an old tool or saved request. App context
and Record change notifications are not metadata CRUD operations.
