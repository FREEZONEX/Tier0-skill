---
name: tier0-uns-create
description: "Create Tier0 UNS namespace folders and topics. Topic leaf paths must include Metric, Action, or State as the segment before the leaf."
---

# uns create

Use `create` to create namespace folders, single topics, or a batch namespace tree.

## Critical Path Rule

For topic nodes, the segment immediately before the leaf must be one of:

- `Metric`
- `Action`
- `State`

The backend derives `topicType` from that segment.

Valid:

```text
Plant/Line1/Metric/Temperature
Plant/Line1/State/MachineStatus
Machine/Action/Start
```

Invalid:

```text
Plant/Line1/Temperature
```

The CLI and backend do not automatically insert the type folder.

## Single Folder

```bash
tier0 uns create --topic Plant/Line1 --type path
```

## Single Topic

```bash
tier0 uns create \
  --topic Plant/Line1/Metric/Temperature \
  --type topic \
  --display-name "Temperature" \
  --description "Line 1 temperature" \
  --fields '[{"name":"temperature","type":"float"},{"name":"unit","type":"string"}]'
```

## Parent Prefix

```bash
tier0 uns create \
  --parent Plant/Line1/Metric \
  --topic Temperature \
  --type topic \
  --fields '[{"name":"temperature","type":"float"}]'
```

## Batch File

For trees or multiple nodes, use `--file`.

```bash
tier0 uns create --file namespace.json --json
```

Preferred file shape:

```json
{
  "namespace": [
    {
      "path": "Plant",
      "type": "PATH",
      "children": [
        {
          "path": "Line1",
          "type": "PATH",
          "children": [
            {
              "path": "Metric",
              "type": "PATH",
              "children": [
                {
                  "path": "Temperature",
                  "type": "TOPIC",
                  "fields": [
                    { "name": "temperature", "type": "float" }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Batch Response Handling

`uns create --file` uses a batch API. HTTP 200 and outer `code: 200` do not prove all nodes were created.

Required checks:

```js
if (resp.data?.success === false) {
  throw new Error("UNS create batch failed");
}
for (const result of resp.data?.results ?? []) {
  if (result.success === false) {
    throw new Error(result.message || result.path || "UNS create item failed");
  }
}
```

## Field Types

Common field types:

| Type | Use |
| --- | --- |
| `float` | Numeric process values |
| `int` | Counts, codes, discrete numeric states |
| `string` | Text state, mode, operator input |
| `bool` | Boolean state |

## Modeling Guidance

If the product requires current readable values for every state or alarm, create those values as topics that the backend caches. Current backend behavior may vary by topic type; verify with `uns read` after creating and writing the topic.

## PowerShell

Prefer `--file` for field arrays:

```powershell
tier0 uns create --file namespace.json --json
```
