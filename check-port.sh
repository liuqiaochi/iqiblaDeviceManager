#!/bin/bash

echo "检查端口占用情况"
echo "===================="

PORT=${1:-3001}

echo "检查端口 $PORT ..."

# 检查端口是否被占用
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  端口 $PORT 已被占用"
    echo ""
    echo "占用进程信息:"
    lsof -i :$PORT
    echo ""
    echo "建议:"
    echo "1. 修改 .env 文件中的 PORT 为其他端口"
    echo "2. 或停止占用该端口的进程"
else
    echo "✅ 端口 $PORT 可用"
fi

echo ""
echo "当前所有Node.js进程:"
ps aux | grep node | grep -v grep
