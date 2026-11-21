#!/usr/bin/env bash
# 后台常驻启动文档站：关闭终端 / 退出会话后仍然可访问
set -e
cd "$(dirname "$0")"

LOG=/tmp/vuepress-dev.log
PIDFILE=/tmp/vuepress-docs.pid
URL=http://127.0.0.1:8080/

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "已经在运行：$URL（pid $(cat "$PIDFILE")）"
  exit 0
fi

setsid nohup node node_modules/vuepress/bin/vuepress.js dev docs \
  --host 127.0.0.1 --port 8080 > "$LOG" 2>&1 < /dev/null &
echo $! > "$PIDFILE"

for _ in $(seq 1 60); do
  if (exec 3<>/dev/tcp/127.0.0.1/8080) 2>/dev/null; then
    exec 3<&- 3>&-
    echo "已启动：$URL"
    echo "pid $(cat "$PIDFILE")，日志 $LOG"
    exit 0
  fi
  sleep 1
done

echo "启动超时，看日志：$LOG" >&2
exit 1
