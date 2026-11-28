#!/usr/bin/env bash
# 重新生成首页卡片用的 Material Symbols 图标子集字体
#
# 依赖：npm、python3 + fonttools（pip install fonttools）
# 用法：
#   bash tools/build-icons.sh                       # 用默认的 6 个图标
#   bash tools/build-icons.sh search dark_mode ...  # 指定图标名（Material Symbols 的 ligature 名）
#
# 产物：docs/public/fonts/material-symbols-rounded.<hash>.woff2（文件名带哈希，避免浏览器缓存旧图标）
# 之后再改 docs/index.md 的 features.icon，填对应图标名即可。
set -euo pipefail

cd "$(dirname "$0")/.."
OUTDIR=docs/public/fonts
CSS=docs/.vitepress/theme/custom.css
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

ICONS=("$@")
if [ ${#ICONS[@]} -eq 0 ]; then
  ICONS=(auto_stories library_books description format_align_left search rocket_launch)
fi
TEXT=$(printf '%s' "${ICONS[@]}")
echo "图标：${ICONS[*]}"

cd "$WORK"
npm pack @material-symbols/font-400 --silent >/dev/null
tar -xzf material-symbols-font-400-*.tgz
FONT=package/material-symbols-rounded.woff2

python3 - "$FONT" "$TEXT" "$OLDPWD/$OUTDIR" "$OLDPWD/$CSS" <<'PY'
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

src, text, outdir, css_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

# 1) woff2 -> 静态字体（FILL 轴固定为 1，实心图标）
font = TTFont(src)
font.flavor = None
font = instantiateVariableFont(font, {"FILL": 1}, inplace=True, updateFontNames=False)
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
import glob, hashlib, os, re

out = os.path.join(outdir, "material-symbols-rounded.pending.woff2")
font.save(out)
digest = hashlib.sha256(open(out, "rb").read()).hexdigest()[:8]
final = os.path.join(outdir, f"material-symbols-rounded.{digest}.woff2")
os.replace(out, final)

# 删掉旧版本，避免 public 里堆积
for old in glob.glob(os.path.join(outdir, "material-symbols-rounded*.woff2")) + glob.glob(
    os.path.join(outdir, "material-symbols-icons*.woff2")
):
    if old != final:
        os.remove(old)

# 把 custom.css 里的字体地址换成新哈希
css = open(css_path, encoding="utf-8").read()
css = re.sub(
    r"url\('/fonts/material-symbols-[^']+'\)",
    f"url('/fonts/{os.path.basename(final)}')",
    css,
)
open(css_path, "w", encoding="utf-8").write(css)
print(f"已生成 {final}，并更新 custom.css")
PY
