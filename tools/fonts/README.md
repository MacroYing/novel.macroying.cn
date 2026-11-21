# 字体子集说明

站内使用的更纱黑体 SC 是子集化的 woff2（源：npm 包 `sarasa-gothic-sc@0.36.0`，SIL OFL）。

## 文件

| 文件 | 体积 | 内容 |
| --- | --- | --- |
| `docs/.vuepress/public/fonts/sarasa-gothic-sc-regular.woff2` | ~1.2MB | 常规字重子集 |
| `docs/.vuepress/public/fonts/sarasa-gothic-sc-bold.woff2` | ~1.3MB | 粗体子集 |

## 字符集（默认）

`subset-chars.txt` 共 9,792 个字符，覆盖：

- 通用规范汉字表 8,105 字（一级 3,500 / 二级 3,000 / 三级 1,605）
- GB2312 全集（6,763 汉字 + 全角符号/拉丁/假名）
- 站点自身文案用到的所有字符（构建时自动并入）
- 拉丁字母、常用标点、CJK 标点、全角字符区间

缺字时的表现：浏览器回退到系统中的 CJK 字体（字体栈里依次是 Noto Sans CJK / 思源黑体 /
苹方 / 微软雅黑），只有生僻字（如 龘、扩展 A/B 区汉字）会这样，阅读影响极小。

## 重新生成

```bash
# 默认子集（覆盖标准汉字）
bash tools/build-fonts.sh

# 全 CJK 基本区（20,992 字，约 2.9MB/字重，含生僻字）
bash tools/build-fonts.sh --full

npm run build
```

需要 `python3 -m pip install fonttools brotli`。

## 为什么去掉了 hinting

`--no-hinting` 让 woff2 从 1.9MB 降到 1.2MB；现代浏览器在 16–18px 下用灰度/次像素抗锯齿，
屏幕阅读不受影响。要恢复 hinting 就删掉脚本里的 `--no-hinting`（体积约 +60%）。
