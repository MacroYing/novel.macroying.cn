#!/usr/bin/env bash
# 重新生成首页卡片用的 Material Symbols 图标子集字体
#
# 依赖：npm、python3 + fonttools（pip install fonttools）
# 用法：
#   bash tools/build-icons.sh                       # 用默认的 6 个图标
#   bash tools/build-icons.sh search dark_mode ...  # 指定图标名（Material Symbols 的 ligature 名）
#
# 产物：docs/public/fonts/material-symbols-icons.woff2
# 之后再改 docs/index.md 的 features.icon，填对应图标名即可。
set -euo pipefail

cd "$(dirname "$0")/.."
OUT=docs/public/fonts/material-symbols-icons.woff2
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

ICONS=("$@")
if [ ${#ICONS[@]} -eq 0 ]; then
  ICONS=(auto_stories format_align_left dark_mode search smartphone rocket_launch)
fi
TEXT=$(printf '%s' "${ICONS[@]}")
echo "图标：${ICONS[*]}"

cd "$WORK"
npm pack @material-symbols/font-400 --silent >/dev/null
tar -xzf material-symbols-font-400-*.tgz
FONT=package/material-symbols-outlined.woff2

python3 - "$FONT" "$TEXT" "$OLDPWD/$OUT" <<'PY'
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

src, text, out = sys.argv[1], sys.argv[2], sys.argv[3]

# 1) woff2 -> 静态字体（FILL 轴固定为 0，只保留描边图标）
font = TTFont(src)
font.flavor = None
font = instantiateVariableFont(font, {"FILL": 0}, inplace=True, updateFontNames=False)
static = "/tmp/material-symbols-static.ttf"
font.save(static)

# 2) 只保留用到的图标：Material Symbols 靠 rlig/rclt 连字把图标名变成字形
from fontTools import subset

opts = subset.Options()
opts.layout_features = ["rlig", "rclt"]
opts.flavor = "woff2"
opts.hinting = False
opts.name_IDs = ["*"]
opts.notdef_outline = True
subsetter = subset.Subsetter(options=opts)
subsetter.populate(text=text)
subsetter.subset(font)
font.flavor = "woff2"
font.save(out)
print(f"已生成 {out}")
PY
