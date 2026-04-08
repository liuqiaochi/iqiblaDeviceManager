#!/bin/bash

echo "=========================================="
echo "设备协议管理系统 - 访问地址"
echo "=========================================="

# 读取端口配置
if [ -f .env ]; then
    PORT=$(grep "^PORT=" .env | cut -d '=' -f2)
else
    PORT=3001
fi

echo "端口: $PORT"
echo ""

# 获取本机IP地址
echo "可用的访问地址:"
echo ""

# 本地访问
echo "1. 本地访问:"
echo "   http://localhost:$PORT"
echo "   http://127.0.0.1:$PORT"
echo ""

# 局域网访问
echo "2. 局域网访问:"

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    if [ ! -z "$IP" ]; then
        echo "   http://$IP:$PORT"
    fi
fi

# Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IP=$(hostname -I | awk '{print $1}')
    if [ ! -z "$IP" ]; then
        echo "   http://$IP:$PORT"
    fi
    
    # 显示所有网络接口
    echo ""
    echo "   所有网络接口:"
    ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print "   http://"$2}' | sed "s|/.*|:$PORT|"
fi

echo ""
echo "3. 公网访问(如果有公网IP):"
echo "   http://[公网IP]:$PORT"
echo ""

# 检查防火墙
echo "=========================================="
echo "防火墙检查"
echo "=========================================="

if command -v ufw &> /dev/null; then
    echo "UFW状态:"
    sudo ufw status | grep $PORT || echo "   端口 $PORT 未开放"
elif command -v firewall-cmd &> /dev/null; then
    echo "Firewalld状态:"
    sudo firewall-cmd --list-ports | grep $PORT || echo "   端口 $PORT 未开放"
else
    echo "未检测到防火墙管理工具"
fi

echo ""
echo "=========================================="
echo "如果无法访问,请检查:"
echo "1. 服务器是否正在运行: pm2 status"
echo "2. 防火墙是否开放端口: sudo ufw allow $PORT/tcp"
echo "3. 云服务器安全组是否开放端口"
echo "=========================================="
