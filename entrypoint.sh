#!/bin/sh

# 1. 设置默认端口 (如果没有环境变量 PORT，则默认 8080)
PORT=${PORT:-8080}

# 2. 检查 Token 是否存在
if [ -z "$TM_TOKEN" ]; then
    echo "❌ Error: TM_TOKEN environment variable is not set!"
    exit 1
fi

echo "-----------------------------------"
echo "🚀 Starting Fake Web Server on port $PORT"
echo "💎 Starting Traffmonetizer with Token: ${TM_TOKEN:0:5}..."
echo "-----------------------------------"

# 3. 启动伪装 Web 服务 (后台运行 &)
# 创建一个简单的 index.html 用于显示状态
echo "Traffmonetizer is running..." > index.html
# 使用 Python 内置服务器监听平台分配的端口
python3 -m http.server $PORT &

# 4. 启动 Traffmonetizer (前台运行)
# 注意：这里不使用 --network host，因为在 PaaS 容器中通常无法控制网络模式，
# 但 Traffmonetizer 在 NAT 后通常也能工作。
./Cli start accept --token "$TM_TOKEN"
