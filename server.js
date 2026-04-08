const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
// 从环境变量读取端口,默认使用3001
const PORT = process.env.PORT || 3001;
const DATA_FILE = path.join(__dirname, 'data', 'devices.json');

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// 确保数据目录存在
async function ensureDataDir() {
    const dataDir = path.join(__dirname, 'data');
    try {
        await fs.access(dataDir);
    } catch {
        await fs.mkdir(dataDir, { recursive: true });
    }
}

// 读取数据
async function readData() {
    try {
        const data = await fs.readFile(DATA_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        // 如果文件不存在,返回默认数据
        return {
            devices: [],
            functions: [],
            versionNumbers: ['0']
        };
    }
}

// 写入数据
async function writeData(data) {
    await fs.writeFile(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
}

// API路由

// 获取所有数据
app.get('/api/data', async (req, res) => {
    try {
        const data = await readData();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: '读取数据失败' });
    }
});

// 保存数据
app.post('/api/data', async (req, res) => {
    try {
        await writeData(req.body);
        res.json({ success: true, message: '数据保存成功' });
    } catch (error) {
        res.status(500).json({ error: '保存数据失败' });
    }
});

// 启动服务器
async function startServer() {
    await ensureDataDir();
    // 监听所有网络接口,允许外部访问
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`========================================`);
        console.log(`服务器已启动!`);
        console.log(`========================================`);
        console.log(`本地访问: http://localhost:${PORT}`);
        console.log(`局域网访问: http://[服务器IP]:${PORT}`);
        console.log(`========================================`);
        console.log(`按 Ctrl+C 停止服务器`);
    });
}

startServer();
