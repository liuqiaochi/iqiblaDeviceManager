# 外部浏览器访问指南

## 快速查看访问地址

运行以下命令查看所有可用的访问地址:

```bash
./show-access-url.sh
```

---

## 访问方式

### 1. 本地访问(服务器本机)

```
http://localhost:3001
http://127.0.0.1:3001
```

### 2. 局域网访问(同一网络内的其他设备)

```
http://[服务器局域网IP]:3001
```

**如何获取服务器IP:**

Linux:
```bash
hostname -I
# 或
ip addr show
```

macOS:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Windows:
```bash
ipconfig
```

**示例:**
- 如果服务器IP是 `192.168.1.100`
- 访问地址: `http://192.168.1.100:3001`

### 3. 公网访问(互联网访问)

```
http://[公网IP]:3001
```

需要:
- 服务器有公网IP
- 防火墙开放端口
- 云服务器需配置安全组

---

## 配置步骤

### 步骤1: 确认服务器正在运行

```bash
# 查看PM2状态
pm2 status

# 或查看进程
ps aux | grep node

# 查看端口监听
netstat -tlnp | grep 3001
# 或
lsof -i :3001
```

### 步骤2: 开放防火墙端口

#### Ubuntu/Debian (UFW)

```bash
# 开放端口
sudo ufw allow 3001/tcp

# 查看状态
sudo ufw status

# 如果防火墙未启用
sudo ufw enable
```

#### CentOS/RHEL (firewalld)

```bash
# 开放端口
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --reload

# 查看已开放端口
sudo firewall-cmd --list-ports
```

#### 直接使用iptables

```bash
# 开放端口
sudo iptables -A INPUT -p tcp --dport 3001 -j ACCEPT

# 保存规则
sudo iptables-save > /etc/iptables/rules.v4
```

### 步骤3: 云服务器配置安全组

如果使用云服务器(阿里云、腾讯云、AWS等),需要在控制台配置安全组:

#### 阿里云ECS
1. 登录阿里云控制台
2. 进入ECS实例管理
3. 点击"安全组" → "配置规则"
4. 添加入方向规则:
   - 端口范围: 3001/3001
   - 授权对象: 0.0.0.0/0 (所有IP)
   - 协议类型: TCP

#### 腾讯云CVM
1. 登录腾讯云控制台
2. 进入云服务器管理
3. 点击"安全组" → "修改规则"
4. 添加入站规则:
   - 类型: 自定义TCP
   - 端口: 3001
   - 来源: 0.0.0.0/0

#### AWS EC2
1. 登录AWS控制台
2. 进入EC2实例
3. 点击"安全组" → "编辑入站规则"
4. 添加规则:
   - 类型: 自定义TCP
   - 端口: 3001
   - 来源: 0.0.0.0/0

### 步骤4: 测试访问

#### 从服务器本机测试

```bash
curl http://localhost:3001
```

#### 从局域网其他设备测试

```bash
curl http://[服务器IP]:3001
```

#### 从浏览器访问

打开浏览器,输入:
```
http://[服务器IP]:3001
```

---

## 使用域名访问(推荐)

### 方式一: 使用Nginx反向代理

1. 安装Nginx:
```bash
sudo apt install nginx  # Ubuntu/Debian
sudo yum install nginx  # CentOS/RHEL
```

2. 配置Nginx (`/etc/nginx/sites-available/device-manager`):
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 你的域名

    location / {
        proxy_pass http://localhost:3001;
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

3. 启用配置:
```bash
sudo ln -s /etc/nginx/sites-available/device-manager /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

4. 访问:
```
http://your-domain.com
```

### 方式二: 配置HTTPS (使用Let's Encrypt)

```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 获取SSL证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

访问:
```
https://your-domain.com
```

---

## 常见问题

### 1. 无法访问 - 连接超时

**检查清单:**
- [ ] 服务器是否运行: `pm2 status`
- [ ] 端口是否监听: `netstat -tlnp | grep 3001`
- [ ] 防火墙是否开放: `sudo ufw status`
- [ ] 云服务器安全组是否配置
- [ ] 服务器IP是否正确

**解决方法:**
```bash
# 重启服务
pm2 restart device-protocol-manager

# 开放防火墙
sudo ufw allow 3001/tcp

# 查看日志
pm2 logs device-protocol-manager
```

### 2. 无法访问 - 连接被拒绝

**可能原因:**
- 服务器未启动
- 端口配置错误
- 监听地址配置错误

**解决方法:**
```bash
# 检查服务状态
pm2 status

# 检查端口
lsof -i :3001

# 重启服务
pm2 restart device-protocol-manager
```

### 3. 局域网可以访问,公网无法访问

**可能原因:**
- 没有公网IP
- 云服务器安全组未配置
- 路由器未做端口转发

**解决方法:**
- 配置云服务器安全组
- 或使用Nginx反向代理80端口
- 或使用内网穿透工具(frp, ngrok)

### 4. 只能本机访问,局域网无法访问

**可能原因:**
- 服务器只监听127.0.0.1

**解决方法:**
确认server.js中监听配置:
```javascript
app.listen(PORT, '0.0.0.0', () => {
    // ...
});
```

---

## 安全建议

### 1. 限制访问IP(可选)

如果只允许特定IP访问:

```bash
# UFW
sudo ufw allow from 192.168.1.0/24 to any port 3001

# iptables
sudo iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 3001 -j ACCEPT
```

### 2. 使用Nginx添加认证

```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:3001;
}
```

创建密码文件:
```bash
sudo apt install apache2-utils
sudo htpasswd -c /etc/nginx/.htpasswd admin
```

### 3. 使用HTTPS

强烈建议生产环境使用HTTPS,参考上面的Let's Encrypt配置。

---

## 测试工具

### 在线端口检测

- https://tool.chinaz.com/port/
- https://www.yougetsignal.com/tools/open-ports/

### 本地测试命令

```bash
# 测试端口连通性
telnet [服务器IP] 3001

# 或使用nc
nc -zv [服务器IP] 3001

# 或使用curl
curl http://[服务器IP]:3001
```

---

## 快速参考

```bash
# 查看访问地址
./show-access-url.sh

# 查看服务状态
pm2 status

# 查看日志
pm2 logs device-protocol-manager

# 开放防火墙
sudo ufw allow 3001/tcp

# 重启服务
pm2 restart device-protocol-manager

# 查看端口监听
netstat -tlnp | grep 3001
```
