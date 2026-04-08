# 快速启动指南

## 5分钟快速部署

### 1. 安装依赖 (1分钟)

```bash
npm install
```

### 2. 启动服务 (30秒)

```bash
# 开发模式
npm run dev

# 或生产模式(使用PM2)
pm2 start ecosystem.config.js
```

### 3. 配置外部访问 (1分钟)

```bash
# 一键配置防火墙
./setup-external-access.sh

# 查看访问地址
./show-access-url.sh
```

### 4. 访问应用 (30秒)

打开浏览器,访问显示的地址:
- 本地: `http://localhost:3001`
- 局域网: `http://[服务器IP]:3001`

---

## 常用命令

```bash
# 查看访问地址
./show-access-url.sh

# 查看服务状态
pm2 status

# 查看日志
pm2 logs device-protocol-manager

# 重启服务
pm2 restart device-protocol-manager

# 停止服务
pm2 stop device-protocol-manager
```

---

## 云服务器额外步骤

如果使用阿里云、腾讯云、AWS等:

1. 登录云服务商控制台
2. 找到"安全组"配置
3. 添加入站规则:
   - 端口: 3001
   - 协议: TCP
   - 来源: 0.0.0.0/0

详细步骤: [EXTERNAL-ACCESS.md](EXTERNAL-ACCESS.md)

---

## 故障排查

### 无法访问?

```bash
# 1. 检查服务是否运行
pm2 status

# 2. 检查端口是否监听
netstat -tlnp | grep 3001

# 3. 检查防火墙
sudo ufw status

# 4. 查看日志
pm2 logs device-protocol-manager
```

### 端口被占用?

```bash
# 检查端口占用
./check-port.sh

# 修改端口
echo "PORT=8080" > .env
pm2 restart device-protocol-manager
```

---

## 完整文档

- [README.md](README.md) - 完整项目说明
- [DEPLOY.md](DEPLOY.md) - 详细部署指南
- [EXTERNAL-ACCESS.md](EXTERNAL-ACCESS.md) - 外部访问配置
- [CHECKLIST.md](CHECKLIST.md) - 部署检查清单
