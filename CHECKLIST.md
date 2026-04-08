# 部署检查清单

## 部署前检查

- [ ] 已安装Node.js (版本 >= 14.0)
- [ ] 已安装npm或yarn
- [ ] 已安装PM2 (生产环境推荐)
- [ ] 检查端口3001是否可用
- [ ] 确认有足够的磁盘空间

## 端口冲突检查

```bash
# 运行端口检查脚本
./check-port.sh

# 或手动检查
lsof -i :3001

# 如果端口被占用,修改 .env 文件
echo "PORT=8080" > .env
```

## 安装步骤

- [ ] 1. 上传项目文件到服务器
- [ ] 2. 进入项目目录
- [ ] 3. 运行 `npm install` 安装依赖
- [ ] 4. 复制 `.env.example` 到 `.env` 并配置端口
- [ ] 5. 测试启动: `npm start`
- [ ] 6. 确认可以访问: `http://localhost:3001`

## PM2部署步骤

- [ ] 1. 安装PM2: `npm install -g pm2`
- [ ] 2. 启动应用: `pm2 start ecosystem.config.js`
- [ ] 3. 查看状态: `pm2 status`
- [ ] 4. 查看日志: `pm2 logs device-protocol-manager`
- [ ] 5. 设置开机自启: `pm2 startup && pm2 save`

## 多应用共存检查

如果服务器上已有其他应用:

- [ ] 确认其他应用使用的端口
- [ ] 确认本应用使用不同端口(默认3001)
- [ ] 使用 `pm2 list` 查看所有运行的应用
- [ ] 确认应用名称不冲突

```bash
# 查看所有PM2应用
pm2 list

# 示例输出:
# ┌─────┬──────────────────────┬─────────┬─────────┬──────────┐
# │ id  │ name                 │ status  │ cpu     │ memory   │
# ├─────┼──────────────────────┼─────────┼─────────┼──────────┤
# │ 0   │ other-app            │ online  │ 0%      │ 50.0mb   │
# │ 1   │ device-protocol-...  │ online  │ 0%      │ 45.0mb   │
# └─────┴──────────────────────┴─────────┴─────────┴──────────┘
```

## Nginx配置(可选)

- [ ] 安装Nginx
- [ ] 创建配置文件
- [ ] 修改 `proxy_pass` 端口为实际端口
- [ ] 测试配置: `nginx -t`
- [ ] 重启Nginx: `systemctl restart nginx`

## 防火墙配置

- [ ] 开放应用端口(3001)
- [ ] 开放HTTP端口(80)
- [ ] 开放HTTPS端口(443,如需要)

## 数据备份

- [ ] 确认 `data` 目录已创建
- [ ] 设置定期备份计划
- [ ] 测试备份恢复流程

## 测试验证

- [ ] 访问应用首页(本地)
- [ ] 访问应用首页(局域网)
- [ ] 访问应用首页(外部,如适用)
- [ ] 测试添加设备
- [ ] 测试添加业务功能
- [ ] 测试导出JSON
- [ ] 测试数据持久化
- [ ] 重启服务器后数据仍存在

## 外部访问配置

- [ ] 运行 `./setup-external-access.sh` 配置防火墙
- [ ] 运行 `./show-access-url.sh` 查看访问地址
- [ ] 云服务器配置安全组(如适用)
- [ ] 测试外部浏览器访问

## 监控和日志

- [ ] 配置PM2日志
- [ ] 设置日志轮转
- [ ] 配置监控告警(可选)

## 常见问题排查

### 端口被占用
```bash
# 查看占用端口的进程
lsof -i :3001

# 修改端口
echo "PORT=8080" > .env
pm2 restart device-protocol-manager
```

### 无法访问
```bash
# 检查服务是否运行
pm2 status

# 检查防火墙
sudo ufw status

# 查看日志
pm2 logs device-protocol-manager
```

### 数据丢失
```bash
# 检查数据文件
ls -la data/devices.json

# 检查文件权限
chmod 644 data/devices.json

# 恢复备份
cp data/devices.json.backup data/devices.json
```

## 完成确认

- [ ] 应用正常运行
- [ ] 可以正常访问
- [ ] 数据可以保存
- [ ] PM2自动重启正常
- [ ] 日志正常记录
- [ ] 备份策略已设置

## 联系信息

如遇问题,请检查:
1. 日志文件: `pm2 logs device-protocol-manager`
2. 数据文件: `data/devices.json`
3. 配置文件: `.env`
