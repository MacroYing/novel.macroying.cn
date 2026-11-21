#!/usr/bin/env python3
"""把热铁盒（Retinbox）上的线上站点内容拉回本地 —— 反向同步 / 备份。

官方只提供「推送到 Git → 自动部署」这一个方向，没有反向同步命令，
所以这里用站点公开 URL 抓取一遍，生成一份带哈希的镜像和清单：

  python3 tools/rth-pull.py                 # 抓取到 retiehe-mirror/
  python3 tools/rth-pull.py --site example.rth1.xyz
  python3 tools/rth-pull.py --out /tmp/mirror

每次运行都会和上一次的清单比对，告诉你线上哪些文件变了（新增 / 修改 / 删除）。
镜像目录默认不进 Git（见 .gitignore），要纳入版本管理就把那一行删掉。

注意：热铁盒的 WAF 会拦截云服务器 / 代理 IP，所以这个脚本适合在本机（手机、
家用网络）跑，不要放进 GitHub Actions。
"""

import argparse
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

UA = (
    "Mozilla/5.0 (Linux; Android 15; Pixel 8) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36"
)
HEADERS = {
    "User-Agent": UA,
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
    "Accept-Encoding": "identity",
    "Connection": "close",
}
SKIP_PREFIX = ("data:", "mailto:", "javascript:", "tel:", "#")
ASSET_RE = re.compile(r"""(?:href|src)\s*=\s*["']([^"']+)["']""", re.I)
CSS_URL_RE = re.compile(r"""url\(\s*["']?([^"')]+)["']?\s*\)""", re.I)
TEXT_TYPES = (".html", ".css", ".js", ".json", ".xml", ".txt", ".svg", ".md")


def norm(path, host=None):
    """把 URL/相对路径规整成站点内的绝对路径（以 / 开头）；站外链接返回 None。"""
    path = urllib.parse.urldefrag(path)[0]
    if not path or path.startswith(SKIP_PREFIX):
        return None
    if path.startswith("//"):
        path = "https:" + path
    if path.startswith("http://") or path.startswith("https://"):
        u = urllib.parse.urlparse(path)
        if host and u.hostname and u.hostname != host:
            return None  # CDN、外链：不镜像
        return u.path + (("?" + u.query) if u.query else "")
    if path.startswith("/"):
        return path
    return "/" + path.lstrip("./")


def fetch(path, origin, tries=5):
    url = origin + path
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            last = e
        except Exception as e:  # 网络抖动：重试
            last = e
        time.sleep(min(1.5 * (i + 1), 6))
    print(f"  ! {path} 失败：{type(last).__name__} {last}", file=sys.stderr)
    return None


def links_from(path, body):
    """从 HTML/CSS/JS 中找出站内链接。"""
    if path.endswith(".css"):
        return CSS_URL_RE.findall(body)
    if path.endswith(".html"):
        return ASSET_RE.findall(body) + CSS_URL_RE.findall(body)
    return []  # JS 里的模板字符串不是真链接，跳过避免误报


def crawl(origin, outdir, max_files=500):
    host = urllib.parse.urlparse(origin).hostname
    queue = ["/"]
    seen, saved, missing = set(), {}, []
    while queue and len(saved) < max_files:
        path = queue.pop(0)
        if path in seen:
            continue
        seen.add(path)
        body = fetch(path, origin)
        if body is None:
            missing.append(path)
            continue
        rel = path.lstrip("/").split("?")[0] or "index.html"
        if rel.endswith("/"):
            rel += "index.html"
        dest = os.path.join(outdir, rel)
        os.makedirs(os.path.dirname(dest) or outdir, exist_ok=True)
        with open(dest, "wb") as f:
            f.write(body)
        saved[path] = hashlib.sha256(body).hexdigest()

        if rel.endswith((".html", ".css")):
            text = body.decode("utf-8", "replace")
            for raw in links_from(rel, text):
                nxt = norm(raw, host)
                if nxt and nxt not in seen:
                    queue.append(nxt)
        time.sleep(0.15)  # 轻一点，别把 WAF 惹毛
    return saved, missing


def main():
    ap = argparse.ArgumentParser(description="抓取热铁盒线上站点，生成镜像与变更报告")
    ap.add_argument("--site", default="novel.macroying.cn", help="站点域名")
    ap.add_argument("--out", default="retiehe-mirror", help="输出目录")
    args = ap.parse_args()

    origin = f"https://{args.site}"
    os.makedirs(args.out, exist_ok=True)
    manifest_path = os.path.join(args.out, "manifest.json")
    old = {}
    if os.path.exists(manifest_path):
        try:
            old = json.load(open(manifest_path, encoding="utf-8")).get("files", {})
        except Exception:
            old = {}

    print(f"抓取 {origin} → {args.out}/")
    files, missing = crawl(origin, args.out)

    changed = sorted(p for p in files if p in old and old[p] != files[p])
    added = sorted(p for p in files if p not in old)
    removed = sorted(p for p in old if p not in files)

    json.dump(
        {
            "site": args.site,
            "pulled_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "files": files,
        },
        open(manifest_path, "w", encoding="utf-8"),
        ensure_ascii=False,
        indent=2,
    )

    print(f"完成：{len(files)} 个文件，缺失 {len(missing)} 个")
    for p in missing[:10]:
        print("  缺失：", p)
    if not old:
        print("首次抓取，已生成基线清单；下次运行就能看出线上改了什么。")
    else:
        for label, items in (("新增", added), ("修改", changed), ("删除", removed)):
            if items:
                print(f"{label} {len(items)} 个：")
                for p in items:
                    print("  ", p)
        if not (added or changed or removed):
            print("线上内容与上次完全一致。")


if __name__ == "__main__":
    main()
