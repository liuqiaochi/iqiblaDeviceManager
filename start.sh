#!/bin/bash

echo "设备协议管理系统 - 启动脚本"
echo "=============================="

# 检查Node.js是否安装
if ! command -v node &> /dev/null
then
    echo "错误: 未检测到Node.js,请先安装Node.js"
    exit 1
fi

echo "Node.js版本: $(node -v)"

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "正在安装依赖..."
    npm install
fi

# 启动服务器
echo "正在启动服务器..."
npm start
