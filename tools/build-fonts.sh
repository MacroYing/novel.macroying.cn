#!/usr/bin/env bash
# 重新生成站内字体子集（更纱黑体 SC → woff2）
#
# 默认字符集：通用规范汉字表 8105 字 + GB2312 全集（含标点/全角/假名）+ 站点自身用字
# 需要：node/npm、python3 + fonttools + brotli（pip install fonttools brotli）
#
# 用法：
#   bash tools/build-fonts.sh          # 默认子集（约 1.2MB/字重）
#   bash tools/build-fonts.sh --full   # 全 CJK 基本区（约 2.9MB/字重，含生僻字）
set -euo pipefail
cd "$(dirname "$0")/.."

WIDTH=60
FEAT="kern,liga,ccmp,locl,calt"
FULL=0
[ "${1:-}" = "--full" ] && FULL=1

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "==> 下载更纱黑体 SC 0.36.0"
npm pack sarasa-gothic-sc@0.36.0 --pack-destination "$WORK" >/dev/null
tar -xzf "$WORK"/sarasa-gothic-sc-0.36.0.tgz -C "$WORK" \
  package/sarasa-gothic-sc-regular.ttf package/sarasa-gothic-sc-bold.ttf

BASE="U+0020-007E,U+00A0-00FF,U+2000-206F,U+3000-303F,U+FF00-FFEF"

for W in regular bold; do
  echo "==> 子集 $W"
  if [ "$FULL" = "1" ]; then
    ARGS=(--unicodes="$BASE,U+4E00-9FFF")
  else
    ARGS=(--text-file="$PWD/tools/fonts/subset-chars.txt")
  fi
  python3 -m fontTools.subset "$WORK/package/sarasa-gothic-sc-$W.ttf" \
    "${ARGS[@]}" --output-file="docs/.vuepress/public/fonts/sarasa-gothic-sc-$W.woff2" \
    --flavor=woff2 --layout-features="$FEAT" --no-hinting
done

ls -lh docs/.vuepress/public/fonts/
echo "==> 完成，记得 npm run build"
