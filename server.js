const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const os = require('os');

// --- 配置区 ---
const app = express();
// 极其重要：使用 process.env.PORT 接收 Flootup 分配的端口
const port = process.env.PORT || 8080;
// 获取 Token
const tmToken = process.env.TM_TOKEN;

// 检查 Token 是否存在
if (!tmToken) {
    console.error("❌ 【严重错误】未检测到 TM_TOKEN 环境变量！");
    console.error("请在 Flootup 控制台的 Environment Variables 中添加 TM_TOKEN。");
    process.exit(1);
}

// --- 1. 启动 Web 服务器 (用于保活/健康检查) ---
app.get('/', (req, res) => {
    res.status(200).send('✅ 服务正常运行.');
});

// 监听 0.0.0.0 以确保外部可访问
app.listen(port, '0.0.0.0', () => {
    console.log(`🌐 [Web服务] 已启动，正在监听端口: ${port}`);
});


// --- 2. 启动 Traffmonetizer 核心进程 ---
const binaryPath = path.join(__dirname, 'Cli'); // 二进制文件路径
const deviceName = `Flootup-${os.hostname().substring(0, 6)}`; // 生成设备名

console.log(`💎 [TM核心] 准备启动...`);
console.log(`📋 [TM核心] 参数: start accept --token ${tmToken.substring(0, 5)}... --device-name ${deviceName}`);

// 使用 spawn 启动子进程
const tmProcess = spawn(binaryPath, [
    'start',
    'accept',
    '--token', tmToken,
    '--device-name', deviceName
], {
    stdio: 'inherit', // 将子进程的日志直接输出到主控制台
    env: { ...process.env, DOTNET_GCHeapHardLimit: '80000000' } // 优化内存
});

// 监听子进程错误
tmProcess.on('error', (err) => {
    console.error('❌ [TM核心] 启动失败:', err);
});

// 监听子进程退出
tmProcess.on('close', (code) => {
    if (code !== 0) {
        console.error(`⚠️ [TM核心] 异常退出，退出码: ${code}`);
        // 如果核心进程挂了，我们也退出 Node 主进程，让平台重启我们
        process.exit(code);
    } else {
        console.log('ℹ️ [TM核心] 正常退出。');
    }
});
