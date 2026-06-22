# Flow Protocol References

Read the matching protocol file before generating or editing Node-RED Flow JSON.

| Intent | Reference | Template |
| --- | --- | --- |
| Modbus TCP/RTU collection to UNS | `modbus.md` | `templates/modbus-tcp-read.json` |
| OPC-UA subscription to UNS | `opcua.md` | `templates/opcua-subscribe.json` |
| OPC-DA polling to UNS | `opcda.md` | No generic template |
| External MQTT broker to UNS | `mqtt-bridge.md` | No generic template |
| UNS to PostgreSQL archive | `postgresql.md` | `templates/postgresql-uns-archive.json` |

Templates are structural examples only. Always adapt topic paths, field names, node IDs, credentials strategy, and runtime node availability to the user's environment.

Before deploy:

1. Export current canvas with `tier0 flow data --id <id> --out backup.json`.
2. Preserve backend-created config nodes, especially Tier0 `mqtt-broker`.
3. Deploy with `tier0 flow deploy --id <id> -f flows.json --yes` only after confirmation.
