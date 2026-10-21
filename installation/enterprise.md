---
name: tier0-installation-enterprise
description: "Install a self-hosted Tier0 Enterprise server, apply an offline product upgrade, or refresh a Backend image using the deployment package's scripts."
---

# Enterprise Installation and Upgrades

Use this reference for Enterprise host installation and upgrade requests. Installing
the Tier0 CLI or running `tier0 upgrade` does not install or upgrade the server.
CLI authentication is needed only when connecting to the running platform.

The examples below target a standard single-host Linux deployment. For macOS,
Windows, Fleet HA, or external services, follow the matching instructions shipped
with the actual package. Do not apply single-host commands to a Kubernetes deployment.

## Choose the Operation

| User goal | Artifact and entry point |
| --- | --- |
| Install on a new host | Full offline package; `bin/install.sh` |
| Upgrade an existing product version | Full or quick upgrade package; the new package's `bin/apply-offline-package.sh` |
| Refresh Backend within the same product version | A single tagged Backend image archive; installed `bin/upgrade-backend-image.sh`, when available |
| Install or update the local CLI and skills | [Main skill setup](../SKILL.md#setup) |

A quick package is for an existing installation. `packageMode: offline` alone does
not establish that a package is complete enough for a fresh install. An online
upgrade package contains no images and requires registry access; it must not be
used to convert an offline installation by removing its offline marker.

## Establish the Target

Before execution, identify the host, installation path, Compose project, Docker
endpoint, current and target versions, and requested operation. Reuse information
and authorization already supplied by the user. Read-only inspection can proceed
while resolving missing details; apply changes only within the authorized scope.

Read the actual deployment's `AGENTS.md`, `.agents/skills/tier0-enterprise-deploy-runtime/SKILL.md`
when present, and the package's `README.md`, `UPGRADE.md`, and `ENVIRONMENT.md`.
Those version-matched files take precedence over the examples in this reference.

Keep these locations distinct:

- `PACKAGE_ROOT`: the new, separately extracted release package containing
  `package-manifest.json`, `checksums.sha256`, and `bin/`.
- `DEPLOY_ROOT`: the existing installation containing `.env` and runtime state.
- Persistent data and backup directories: preserve them during installation
  troubleshooting and upgrades.

For an existing deployment, the new package's `bin/find-deploy-root.sh` can locate
candidate installations read-only. Check its `--help` and select the exact project
if there is more than one. Do not infer the target from a similar directory name.

Linux prerequisites are Bash 4+, a rootful Docker Engine, and Docker Compose V2 or
newer. A non-root user can access a rootful daemon; the login name does not identify
Docker's mode. Use the same execution account and confirmed Docker endpoint for
preflight and execution. Fleet host service updates may require additional system
service privileges.

Choose the package for the Docker Linux engine's architecture, `amd64` or `arm64`.
Check the release's disk, port, TLS, and runtime requirements through its preflight;
do not bypass architecture checks, switch Docker contexts, or recursively change
customer data permissions to make an installation pass.

## Verify and Extract the Package

Obtain the release artifact from the user's approved distribution source. Check
its manifest and image inventory; do not infer contents or included fixes from
the ZIP filename or product version alone.

The following Linux example verifies the outer checksum when supplied, checks the
ZIP, and extracts into a new directory. Replace both absolute paths. For an upgrade,
the new directory must be outside the existing installation; for a fresh install,
it becomes the deployment directory and must be retained.

```bash
(
  set -euo pipefail
  ZIP_FILE=/absolute/path/to/enterprise-package.zip
  PACKAGE_ROOT=/absolute/path/to/new-enterprise
  ZIP_DIR="$(cd "$(dirname "${ZIP_FILE}")" && pwd -P)"
  ZIP_NAME="$(basename "${ZIP_FILE}")"
  if [[ -f "${ZIP_FILE}.sha256" ]]; then
    (cd "${ZIP_DIR}" && sha256sum -c "${ZIP_NAME}.sha256")
  fi
  unzip -t "${ZIP_FILE}" >/dev/null
  mkdir "${PACKAGE_ROOT}"
  unzip -q "${ZIP_FILE}" -d "${PACKAGE_ROOT}"
  cd "${PACKAGE_ROOT}"
  sha256sum -c checksums.sha256
  sed -n '1,160p' package-manifest.json
)
```

Stop on checksum or archive errors. Check `productVersion`, `sourceRevision`,
`sourceDirty`, `packageMode`, `targetOS`, `targetArch`, `backendImage`, and
`dockerRuntimeIncluded` where provided. Review `images/manifest.txt` for offline
image inventory or `images/online-manifest.txt` for an online package.
An image archive may contain multiple services; its filename does not prove it is
a standalone Backend image.

## Fresh Offline Installation

From a verified full package, run the read-only check:

```bash
cd /absolute/path/to/new-enterprise
bash bin/install.sh --check
```

This check never installs Docker. If the package includes host runtime installers,
interactive installation can request permission to use them when Docker or Compose
is missing. Use the installer for the actual architecture. When
`dockerRuntimeIncluded=false`, prepare the required runtime separately; do not
call a nonexistent bundled installer.

For the authorized installation, start the wizard:

```bash
bash bin/install.sh
```

Confirm the persistent data directory, entrance address and ports, TLS, and App
Gateway access mode. For supplied TLS, follow the package's `certs/README.md` for
certificate and key placement. Do not include private keys or generated passwords
in agent output.

For automation, prepare `.env` from `.env.default` only when `.env` does not already
exist, edit the intended values, then use `bash bin/install.sh --non-interactive`.
Non-interactive mode does not install missing Docker or accept wizard defaults on
the user's behalf. Never overwrite an existing environment with template values.

After installation:

```bash
bash bin/compose.sh ps
```

Use the entrance address reported by the installer and verify login. If a Fleet
Agent was provisioned, also run `bash bin/fleet-agent.sh health`. A successful first
interactive install displays the initial `tier0` credentials locally; change the
password after login and keep it out of shared logs.

## Upgrade an Existing Deployment

Extract and verify the package separately, then run preflight from the **new**
package against the **existing** installation:

```bash
PACKAGE_ROOT=/absolute/path/to/extracted/package
DEPLOY_ROOT=/absolute/path/to/installed/deploy
bash "${PACKAGE_ROOT}/bin/apply-offline-package.sh" \
  --deploy-root "${DEPLOY_ROOT}" --preflight-only
```

Review the target identity, version direction, architecture, available space,
database and storage access, TLS, image changes, and any Fleet conditions. For the
authorized upgrade, with the maintenance window and backup scope established:

```bash
bash "${PACKAGE_ROOT}/bin/apply-offline-package.sh" \
  --deploy-root "${DEPLOY_ROOT}"
```

Alternatively, when supplied, `upgrade-from-zip.sh` handles package selection and
extraction. Follow its `--help` and the accompanying `UPGRADE.md`; do not copy its
files manually over the existing deployment.

At the verified release baseline, the default database backup covers common
`public` and Project/App databases, not potentially large UNS history. Request
history backup with the documented `-- --backup-uns` option when appropriate.
A separate SINK database or external database requires its own verified backup;
`--db-backup-confirmed` records that fact and does not create that backup. Confirm
the actual package's scope and available space instead of assuming all data is
protected. Do not skip backups or override the package's target version to bypass
preflight.

Quick packages update the components they carry and preserve omitted image
references. When Node-RED is omitted, its installed modules and supporting assets
must be preserved by the package workflow. Check the package inventory and
compatibility for the services in use; not using Fleet or Vision does not by itself
prove that any arbitrary Backend build is compatible.

For a Backend-only product upgrade, obtain a compatible quick package containing
Backend and the matching deployment files. The normal Backend release image
includes the main web frontend. A standalone image archive does not carry the
complete product upgrade workflow or establish compatibility with Flow/App
dependencies.

## Same-Version Backend Image Maintenance

Use this only when refreshing Backend within the installed product version and
the installed release provides the entry point. Verify the archive checksum,
architecture, and intended build. It must contain exactly one tagged Backend
image, not the complete multi-image offline archive.

After confirming a usable database backup and authorization for the restart:

```bash
cd /absolute/path/to/installed/deploy
bash bin/upgrade-backend-image.sh /absolute/path/to/backend.tar
```

This records the Backend image in runtime configuration and recreates Backend.
It leaves `PRODUCT_VERSION` unchanged, does not automatically back up the database,
and rejects Fleet HA. Backend startup can still apply database migrations.
Therefore, use a full or quick package for a product version change, such as
`2.2.7` to `2.2.8`; `docker load` alone only imports an image.

Image tags and page versions do not prove that a specific fix is present. Use the
release's source revision/build evidence and, when available, image ID or digest.

## Verify the Result and Handle Failures

For a product upgrade, inspect the reported `verification.json` and `success.json`,
then check the target version, Backend readiness, required services, and actual
business behavior. Do not report success solely because containers started.

For an installation using UNS, Flow, and App, check login, the intended UNS payload
and recent history, Flow editor/runtime behavior, and an existing App's page and
query. Use existing observations first; obtain authorization for any additional
test publish or Flow deployment. If Marimo or UNS Agent is used, verify it separately:
the verified release baseline excludes those optional containers from parts of
upgrade verification.

Read only recent relevant logs, for example:

```bash
bash bin/compose.sh logs --tail=80 backend
```

Preserve the error, failed phase, package, logs, and backup locations. Report only
redacted evidence; do not print full `.env`, `.env.runtime`, tokens, database
connection strings, or License contents. Database migrations are forward-only;
do not automatically revert images or restore databases without checking migration
and backup compatibility. Resolve the cause and retry the documented entry point.

## Connect the CLI After Installation

Install the CLI using [the main skill](../SKILL.md#setup), then point it at the
actual Enterprise entrance **before** authenticating:

```bash
tier0 config --base-url https://your-enterprise.example.com
tier0 auth whoami --json
```

If authentication is missing, follow [the authentication workflow](../SKILL.md#authentication).
Show the returned browser authorization URL to the user and reuse a valid existing
login. Use [service info](../info/info.md) to check connectivity; API availability
depends on the installed server version and permissions.

## Verified Sources

This reference was checked against Enterprise `release` commit
`b7e57d470b4d042b2ff36eec030c4be33039221c` (2026-10-20):

- [Installation guide](https://github.com/FREEZONEX/Tier0-Enterprise-New/blob/b7e57d470b4d042b2ff36eec030c4be33039221c/deploy/README.md)
- [Upgrade guide](https://github.com/FREEZONEX/Tier0-Enterprise-New/blob/b7e57d470b4d042b2ff36eec030c4be33039221c/deploy/UPGRADE.md)
- [Runtime skill](https://github.com/FREEZONEX/Tier0-Enterprise-New/blob/b7e57d470b4d042b2ff36eec030c4be33039221c/deploy/.agents/skills/tier0-enterprise-deploy-runtime/SKILL.md)
- [Backend image maintenance entry](https://github.com/FREEZONEX/Tier0-Enterprise-New/blob/b7e57d470b4d042b2ff36eec030c4be33039221c/deploy/bin/upgrade-backend-image.sh)

These links provide provenance for maintainers. Running an installed release does
not require repository access: use its shipped manuals and scripts, and do not
copy commands from a newer source checkout into an older installation.
