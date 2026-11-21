#!/usr/bin/env bash
# 停止 serve.sh 启动的文档站
PIDFILE=/tmp/vuepress-docs.pid

if [ ! -f "$PIDFILE" ]; then
  echo "没有 pid 文件，可能本来就没在运行"
  exit 0
fi

PID=$(cat "$PIDFILE")
if kill -0 "$PID" 2>/dev/null; then
  kill -TERM -- "-$PID" 2>/dev/null || kill -TERM "$PID" 2>/dev/null
  sleep 1
  kill -0 "$PID" 2>/dev/null && kill -KILL -- "-$PID" 2>/dev/null
  echo "已停止（pid $PID）"
else
  echo "进程 $PID 已不存在"
fi
rm -f "$PIDFILE"
