#!/bin/bash

echo "=========================================="
echo "配置外部访问"
echo "=========================================="

# 读取端口
if [ -f .env ]; then
    PORT=$(grep "^PORT=" .env | cut -d '=' -f2)
else
    PORT=3001
fi

echo "当前端口: $PORT"
echo ""

# 检测操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "检测到Linux系统"
    
    # 检测防火墙类型
    if command -v ufw &> /dev/null; then
        echo "使用UFW防火墙"
        echo "正在开放端口 $PORT ..."
        sudo ufw allow $PORT/tcp
        echo "✅ 端口已开放"
        echo ""
        sudo ufw status | grep $PORT
        
    elif command -v firewall-cmd &> /dev/null; then
        echo "使用Firewalld防火墙"
        echo "正在开放端口 $PORT ..."
        sudo firewall-cmd --permanent --add-port=$PORT/tcp
        sudo firewall-cmd --reload
        echo "✅ 端口已开放"
        echo ""
        sudo firewall-cmd --list-ports | grep $PORT
        
    else
        echo "⚠️  未检测到防火墙管理工具"
        echo "请手动配置防火墙开放端口 $PORT"
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "检测到macOS系统"
    echo "macOS默认防火墙不限制出站连接"
    echo "如果启用了防火墙,请在系统偏好设置中允许Node.js"
fi

echo ""
echo "=========================================="
echo "获取访问地址"
echo "=========================================="

# 获取IP地址
if [[ "$OSTYPE" == "darwin"* ]]; then
    IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IP=$(hostname -I | awk '{print $1}')
fi

if [ ! -z "$IP" ]; then
    echo "✅ 局域网访问地址:"
    echo "   http://$IP:$PORT"
else
    echo "⚠️  无法获取IP地址"
fi

echo ""
echo "=========================================="
echo "云服务器配置提醒"
echo "=========================================="
echo "如果使用云服务器,还需要:"
echo "1. 登录云服务商控制台"
echo "2. 找到安全组配置"
echo "3. 添加入站规则,开放端口 $PORT"
echo ""
echo "详细步骤请查看: EXTERNAL-ACCESS.md"
echo ""

echo "=========================================="
echo "配置完成!"
echo "=========================================="
echo "现在可以通过以下地址访问:"
echo "1. 本地: http://localhost:$PORT"
if [ ! -z "$IP" ]; then
    echo "2. 局域网: http://$IP:$PORT"
fi
echo ""
echo "运行以下命令查看所有访问地址:"
echo "  ./show-access-url.sh"
