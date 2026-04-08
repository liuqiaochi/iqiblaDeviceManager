# 设备协议管理系统

一个用于管理设备协议、业务功能和功能属性的Web应用系统。

## 功能特性

- 设备管理:添加、编辑、删除设备信息
- 协议版本管理:管理多个协议版本号
- 业务功能管理:管理业务功能及其属性
- 版本配置:为设备的每个协议版本配置业务功能和属性
- 数据导出:将设备配置导出为JSON格式
- 数据持久化:数据保存在服务器本地文件系统

## 技术栈

- 前端:HTML5, CSS3, JavaScript (原生)
- 后端:Node.js + Express
- 数据存储:JSON文件

## 安装部署

### 1. 环境要求

- Node.js 14.0 或更高版本
- npm 或 yarn

### 2. 安装依赖

```bash
npm install
```

### 3. 启动服务器

开发模式(自动重启):
```bash
npm run dev
```

生产模式:
```bash
npm start
```

服务器默认运行在 `http://localhost:3001`

> 注意: 默认端口为3001,避免与其他服务冲突。可以通过修改 `.env` 文件中的 `PORT` 来更改端口。

### 4. 访问应用

**本地访问:**
```
http://localhost:3001
```

**局域网/外部访问:**
```bash
# 查看所有可用的访问地址
./show-access-url.sh

# 访问地址格式
http://[服务器IP]:3001
```

**详细的外部访问配置请查看:** [EXTERNAL-ACCESS.md](EXTERNAL-ACCESS.md)

## 外部浏览器访问

### 快速配置

1. **开放防火墙端口:**
```bash
sudo ufw allow 3001/tcp
```

2. **查看访问地址:**
```bash
./show-access-url.sh
```

3. **在浏览器中打开:**
```
http://[服务器IP]:3001
```

### 云服务器额外配置

如果使用阿里云、腾讯云、AWS等云服务器,还需要在控制台配置安全组,开放3001端口。

详细步骤请参考: [EXTERNAL-ACCESS.md](EXTERNAL-ACCESS.md)

## 端口配置

本项目默认使用端口 **3001**,避免与其他服务冲突。

### 修改端口的三种方式:

#### 方式一: 修改 .env 文件(推荐)
```bash
# 编辑 .env 文件
PORT=3001  # 修改为你需要的端口
```

#### 方式二: 使用环境变量启动
```bash
PORT=8080 npm start
```

#### 方式三: 修改 ecosystem.config.js (使用PM2时)
```javascript
env: {
  PORT: 3001  // 修改为你需要的端口
}
```

## 目录结构

```
.
├── server.js           # Express服务器
├── package.json        # 项目配置
├── public/            # 静态文件目录
│   └── index.html     # 前端页面
├── data/              # 数据存储目录(自动创建)
│   └── devices.json   # 设备数据文件
└── README.md          # 项目说明
```

## API接口

### 获取数据
```
GET /api/data
```

### 保存数据
```
POST /api/data
Content-Type: application/json

{
  "devices": [...],
  "functions": [...],
  "versionNumbers": [...]
}
```

## 配置说明

### 端口配置

项目默认使用端口 **3001**。如果需要修改:

1. 编辑 `.env` 文件:
```bash
PORT=你的端口号
```

2. 或使用环境变量:
```bash
PORT=8080 npm start
```

### 修改数据存储路径

编辑 `server.js` 文件中的 `DATA_FILE` 常量:

```javascript
const DATA_FILE = path.join(__dirname, 'data', 'devices.json');
```

## 多应用共存

如果服务器上已经运行了其他Node.js应用:

1. **确保使用不同端口** - 本项目默认3001端口
2. **使用PM2管理** - 可以同时运行多个应用
3. **使用不同的应用名称** - 避免PM2中名称冲突

```bash
# 查看所有运行的PM2应用
pm2 list

# 使用不同名称启动
pm2 start ecosystem.config.js
```

## 生产环境部署

### 使用PM2部署

1. 安装PM2:
```bash
npm install -g pm2
```

2. 使用配置文件启动(推荐):
```bash
pm2 start ecosystem.config.js
```

或直接启动:
```bash
pm2 start server.js --name device-protocol-manager
```

3. 查看运行状态:
```bash
pm2 list
pm2 status device-protocol-manager
```

4. 设置开机自启:
```bash
pm2 startup
pm2 save
```

5. 其他常用命令:
```bash
pm2 restart device-protocol-manager  # 重启
pm2 stop device-protocol-manager     # 停止
pm2 delete device-protocol-manager   # 删除
pm2 logs device-protocol-manager     # 查看日志
```

### 使用Nginx反向代理

Nginx配置示例:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 数据备份

数据文件位于 `data/devices.json`,建议定期备份此文件。

备份命令示例:
```bash
cp data/devices.json data/devices.json.backup.$(date +%Y%m%d)
```

## 故障排查

### 无法连接到服务器
- 检查服务器是否正常运行
- 检查端口是否被占用
- 检查防火墙设置

### 数据保存失败
- 检查 `data` 目录是否有写入权限
- 检查磁盘空间是否充足

## 许可证

MIT License
