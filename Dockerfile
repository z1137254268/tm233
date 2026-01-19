# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root 权限
USER root

# 3. 安装 netcat (nc) 用于伪装 Web 服务
#    Traffmonetizer 基于 Alpine，所以用 apk
RUN apk add --no-cache netcat-openbsd

# 4. 创建智能启动脚本
RUN cat <<EOF > /start.sh
#!/bin/sh

echo "🔍 Scanning for Traffmonetizer binary..."
# 自动寻找名为 Cli 的文件，取第一个找到的结果
TM_BIN=\$(find / -type f -name "Cli" | head -n 1)

if [ -z "\$TM_BIN" ]; then
    echo "❌ Error: Could not find 'Cli' binary anywhere!"
    echo "📂 Listing /app directory for debugging:"
    ls -la /app
    exit 1
else
    echo "✅ Found binary at: \$TM_BIN"
fi

# 1. 启动伪装 Web 服务 (使用 netcat 循环响应)
#    这是一个极简的 HTTP 响应器，占用内存几乎为 0
echo "🚀 Starting Fake Web Server via Netcat on port \${PORT:-8080}..."
while true; do 
    echo -e "HTTP/1.1 200 OK\n\n Traffmonetizer is Running" | nc -l -p \${PORT:-8080} >/dev/null 2>&1
done &

# 2. 启动挖矿主程序 (无限重启模式)
echo "💎 Starting Mining Process..."
while true; do
    # 赋予执行权限
    chmod +x "\$TM_BIN"
    
    # 启动程序
    "\$TM_BIN" start accept --token "\$TM_TOKEN"
    
    echo "⚠️ Main process exited. Restarting in 10 seconds..."
    sleep 10
done
EOF

# 5. 赋予脚本权限
RUN chmod +x /start.sh

# 6. 暴露端口
EXPOSE 8080

# 7. 启动
ENTRYPOINT ["/start.sh"]
