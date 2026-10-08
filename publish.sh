#!/usr/bin/env bash
# 把一份 HTML（或整個資料夾）發布到 GitHub Pages
# 用法：bash /d/SharePages/publish.sh <HTML檔或資料夾> <網址名稱>
# 網址名稱只能用小寫英文、數字、減號，例如 q3-report
# 發布後網址：https://taicca-ianlin.github.io/share/<網址名稱>/
# 注意：repo 是公開的，放上去的東西全世界都看得到。
set -euo pipefail

ROOT="/d/SharePages"
SRC="${1:-}"
SLUG="${2:-}"

if [ -z "$SRC" ] || [ -z "$SLUG" ]; then
  echo "用法：bash $ROOT/publish.sh <HTML檔或資料夾> <網址名稱>" >&2
  exit 1
fi
if ! [[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "網址名稱只能用小寫英文、數字、減號：$SLUG" >&2
  exit 1
fi
if [ ! -e "$SRC" ]; then
  echo "找不到來源：$SRC" >&2
  exit 1
fi

DEST="$ROOT/$SLUG"
mkdir -p "$DEST"
if [ -d "$SRC" ]; then
  cp -r "$SRC"/. "$DEST"/
else
  cp "$SRC" "$DEST/index.html"
fi

cd "$ROOT"
git add -- "$SLUG"
if git diff --cached --quiet; then
  echo "內容沒有變，不用重新發布。"
else
  git commit -q -m "publish: $SLUG"
  git push -q
  echo "已推上 GitHub。"
fi
echo "網址（約 1 分鐘後生效）：https://taicca-ianlin.github.io/share/$SLUG/"
