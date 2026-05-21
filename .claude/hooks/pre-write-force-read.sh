#!/usr/bin/env bash
set -euo pipefail

# --- 対象拡張子（ここに追加・削除する） ---
TARGET_EXTENSIONS=(".ps1")

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0
[[ -f "$FILE_PATH" ]] && exit 0

# 拡張子チェック
EXT=".${FILE_PATH##*.}"
MATCH=false
for t in "${TARGET_EXTENSIONS[@]}"; do
  [[ "$EXT" == "$t" ]] && MATCH=true && break
done
[[ "$MATCH" == false ]] && exit 0

# ファイル未存在 & 対象拡張子 → 空ファイル作成 + deny
mkdir -p "$(dirname "$FILE_PATH")"
touch "$FILE_PATH"

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "File '${FILE_PATH}' did not exist. It was created empty. Path-based rules are only loaded on Read. You MUST Read this file first (to load rules), then Write/Edit."
  }
}
EOF
