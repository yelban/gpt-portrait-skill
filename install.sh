#!/bin/bash
#
# gpt-portrait-skill 一鍵安裝腳本
# 用法：
#   REPO=../gpt-portrait-skill ./install.sh
#
# 預設會自動判斷：
# - 如果專案已有 CLAUDE.md → 只 append H 層（推薦）
# - 如果專案還沒有 CLAUDE.md → 直接複製整份
#
# 如需安裝到全域 ~/.claude/CLAUDE.md，請手動執行情境 (c)

set -e

# 可透過環境變數覆寫範本路徑
REPO=${REPO:-../gpt-portrait-skill}

echo "=== gpt-portrait-skill 一鍵安裝 ==="
echo "範本路徑: $REPO"
echo

if [ ! -d "$REPO" ]; then
  echo "錯誤：找不到範本資料夾 $REPO"
  echo "請先 clone：git clone https://github.com/yelban/gpt-portrait-skill.git \"$REPO\""
  exit 1
fi

# 建立必要目錄
mkdir -p .claude/commands skills

# 1. 複製 skill 本體 (M 層)
echo "→ 複製 skill 本體..."
cp -r "$REPO/skills/gpt-image-portrait-prompt" skills/
echo "   ✓ skills/gpt-image-portrait-prompt"

# 2. 複製 slash command (J 層)
echo "→ 複製 /portrait slash command..."
cp "$REPO/.claude/commands/portrait.md" .claude/commands/
echo "   ✓ .claude/commands/portrait.md"

# 3. 處理 CLAUDE.md (H 層)
echo "→ 處理 CLAUDE.md (H 層)..."

if [ -f CLAUDE.md ]; then
  if ! grep -q "圖片寫真 prompt 必查 skill" CLAUDE.md; then
    sed -n '/^# === gpt-portrait-skill 強制 override 區段開始 ===/,$p' \
      "$REPO/CLAUDE.md" >> CLAUDE.md
    echo "   ✓ H 段落已 append 到既有 CLAUDE.md（情境 b）"
  else
    echo "   ⚠ CLAUDE.md 已包含 H 段落，跳過"
  fi
else
  cp "$REPO/CLAUDE.md" CLAUDE.md
  echo "   ✓ 整份 CLAUDE.md 已建立（情境 a）"
fi

echo
echo "=== 驗證三層完整性 ==="
test -f skills/gpt-image-portrait-prompt/SKILL.md && echo "✓ M skill" || echo "✗ 缺 M"
test -d skills/gpt-image-portrait-prompt/references && echo "✓ M references/" || echo "✗ 缺 references"
test -f .claude/commands/portrait.md && echo "✓ J command" || echo "✗ 缺 J"
grep -q "圖片寫真 prompt 必查 skill" CLAUDE.md && echo "✓ H override" || echo "✗ 缺 H"

echo
echo "★ 請完全退出並重新啟動 Claude Code（新 session）才會生效！"
echo
echo "安裝完成。如需全域安裝（所有專案生效），請手動執行："
echo "  cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak 2>/dev/null || true"
echo "  sed -n '/^# === gpt-portrait-skill 強制 override 區段開始 ===/,\$p' \"$REPO/CLAUDE.md\" >> ~/.claude/CLAUDE.md"
echo "  （之後仍需重開 Claude Code）"
