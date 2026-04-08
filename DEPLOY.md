# 快速部署指南

## 本地开发环境

### 1. 安装依赖
```bash
npm install
```

### 2. 启动开发服务器
```bash
npm run dev
```

### 3. 访问应用
打开浏览器访问: http://localhost:3001

> 注意: 默认端口为3001,可通过 .env 文件修改

---

## Linux服务器部署

### 方式一: 使用启动脚本

```bash
# 赋予执行权限
chmod +x start.sh

# 运行启动脚本
./start.sh
```

### 方式二: 使用PM2 (推荐生产环境)

```bash
# 1. 安装PM2
npm install -g pm2

# 2. 安装项目依赖
npm install

# 3. 使用配置文件启动(推荐)
pm2 start ecosystem.config.js

# 或直接启动
pm2 start server.js --name device-manager

# 4. 查看状态
pm2 status

# 5. 查看日志
pm2 logs device-manager

# 6. 设置开机自启
pm2 startup
pm2 save

# 7. 重启应用
pm2 restart device-manager

# 8. 停止应用
pm2 stop device-manager
```

### 多应用共存说明

如果服务器上已有其他Node.js应用:

```bash
# 查看所有运行的应用
pm2 list

# 本项目使用不同的端口(3001)和应用名称
# 不会与其他应用冲突

# 如需修改端口,编辑 .env 文件:
echo "PORT=8080" > .env
```

---

## Docker部署

### 1. 创建Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### 2. 构建镜像
```bash
docker build -t device-protocol-manager .
```

### 3. 运行容器
```bash
docker run -d \
  --name device-manager \
  -p 3000:3000 \
  -v $(pwd)/data:/app/data \
  device-protocol-manager
```

---

## Nginx反向代理配置

### 1. 安装Nginx
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx
```

### 2. 配置Nginx

创建配置文件 `/etc/nginx/sites-available/device-manager`:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名

    location / {
        proxy_pass http://localhost:3001;  # 注意端口为3001
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 3. 启用配置
```bash
sudo ln -s /etc/nginx/sites-available/device-manager /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## HTTPS配置 (使用Let's Encrypt)

```bash
# 1. 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 2. 获取SSL证书
sudo certbot --nginx -d your-domain.com

# 3. 自动续期
sudo certbot renew --dry-run
```

---

## 防火墙配置

### Ubuntu/Debian (UFW)
```bash
sudo ufw allow 3001/tcp  # 应用端口
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### CentOS/RHEL (firewalld)
```bash
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

---

## 数据备份

### 手动备份
```bash
# 备份数据文件
cp data/devices.json data/devices.json.backup.$(date +%Y%m%d_%H%M%S)
```

### 自动备份 (使用crontab)
```bash
# 编辑crontab
crontab -e

# 添加每天凌晨2点备份
0 2 * * * cd /path/to/app && cp data/devices.json data/devices.json.backup.$(date +\%Y\%m\%d)
```

---

## 监控和日志

### PM2监控
```bash
# 实时监控
pm2 monit

# 查看日志
pm2 logs device-manager

# 查看错误日志
pm2 logs device-manager --err
```

### 系统服务日志
```bash
# 查看Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 性能优化

### 1. 启用Gzip压缩 (Nginx)

在Nginx配置中添加:
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

### 2. 设置缓存

在Nginx配置中添加:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 故障排查

### 检查服务状态
```bash
# PM2
pm2 status

# 端口占用
sudo lsof -i :3001

# 进程
ps aux | grep node

# 查看所有PM2应用
pm2 list
```

### 重启服务
```bash
# PM2
pm2 restart device-manager

# Nginx
sudo systemctl restart nginx
```

### 查看错误日志
```bash
# PM2日志
pm2 logs device-manager --err

# 应用日志
tail -f data/app.log
```
