# Flow JSON Templates

These templates are examples for agents generating Node-RED Flow JSON.

Do not deploy templates unchanged.

Required adaptation:

- Replace topic paths with the user's UNS paths.
- Match payload field names to UNS topic schemas.
- Query `tier0 flow nodes --source --json` to confirm required node types exist.
- Export current canvas with `tier0 flow data --id <id> --out backup.json`.
- Preserve existing backend-created config nodes, especially Tier0 `mqtt-broker`.
- Deploy with `tier0 flow deploy --id <id> -f flows.json --yes` only after user confirmation.

## Templates

| File | Use |
| --- | --- |
| `modbus-tcp-read.json` | Modbus polling to MQTT / UNS |
| `opcua-subscribe.json` | OPC-UA subscription to MQTT / UNS |
| `postgresql-uns-archive.json` | UNS messages archived to PostgreSQL |

## Credential Rule

Node-RED credentials are not reliably represented as plaintext in exported Flow JSON. For Tier0 MQTT output, reuse the existing backend-created `mqtt-broker` config node from the export instead of generating a new one or embedding credentials.
