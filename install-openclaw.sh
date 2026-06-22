#!/usr/bin/env bash
# Tier0 Skills installer for OpenClaw.
# Usage: ./install-openclaw.sh

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
SKILLS_DIR="${OPENCLAW_DIR}/skills"
TIER0_SKILL_DIR="${SKILLS_DIR}/tier0"

if [[ ! -d "${OPENCLAW_DIR}" ]]; then
  echo "OpenClaw is not installed: ${OPENCLAW_DIR}"
  exit 1
fi

mkdir -p "${SKILLS_DIR}"

if [[ -d "${TIER0_SKILL_DIR}" ]]; then
  BACKUP_DIR="${TIER0_SKILL_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  mv "${TIER0_SKILL_DIR}" "${BACKUP_DIR}"
  echo "Backed up existing skill to ${BACKUP_DIR}"
fi

mkdir -p "${TIER0_SKILL_DIR}"
cp -R . "${TIER0_SKILL_DIR}/"

rm -rf "${TIER0_SKILL_DIR}/.git" \
       "${TIER0_SKILL_DIR}/install-openclaw.sh"

if [[ -f "${TIER0_SKILL_DIR}/SKILL.md" ]]; then
  echo "Tier0 skills installed to ${TIER0_SKILL_DIR}"
else
  echo "Install failed: SKILL.md not found"
  exit 1
fi
