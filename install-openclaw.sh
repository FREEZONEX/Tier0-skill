#!/bin/bash
# Tier0 Skills OpenClaw 安装脚本
# 用法: ./install-openclaw.sh

set -e

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/skills"
TARGET_DIR="${OPENCLAW_SKILLS_DIR}/tier0-api"

echo "☁️  Installing Tier0 Skills for OpenClaw..."

# 检查 OpenClaw 是否已安装
if ! command -v openclaw &> /dev/null; then
    echo "❌ OpenClaw not found. Please install it first:"
    echo "   npm install -g openclaw@latest"
    exit 1
fi

# 确保 OpenClaw skills 目录存在
mkdir -p "${OPENCLAW_SKILLS_DIR}"

# 如果已存在旧版本，先备份
if [ -d "${TARGET_DIR}" ]; then
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%s)"
    echo "⚠️  Existing tier0-api skill found, backing up to ${BACKUP_DIR}"
    mv "${TARGET_DIR}" "${BACKUP_DIR}"
fi

# 复制 skill 文件
cp -r "${SKILL_DIR}" "${TARGET_DIR}"

# 清理不需要的文件
rm -f "${TARGET_DIR}/install-openclaw.sh"
rm -f "${TARGET_DIR}/README.md"

echo "✅ Tier0 Skills installed to ${TARGET_DIR}"
echo ""
echo "Installed files:"
ls -1 "${TARGET_DIR}/uns/" | sed 's/^/   📄 /'
echo ""

# 验证安装
if command -v openclaw &> /dev/null; then
    echo "🔍 Verifying installation..."
    openclaw skills info tier0-api 2>/dev/null || true
    echo ""
    echo "💡 To verify, run: openclaw skills list | grep tier0"
fi

echo "🎉 Done!"
