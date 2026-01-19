# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root 权限
USER root

# 3. 安装 netcat (用于超低内存的 Web 伪装)
RUN apk add --no-cache netcat-openbsd

# 4. 【关键步骤】拯救挖矿程序
# 既然 /app 可能会被平台覆盖，我们先全盘搜索 'Cli' 文件
# 把它复制到 /usr/local/bin/tm_cli (这里绝对安全，不会被覆盖)
RUN echo "🔍 Searching for original binary..." && \
    find / -type f -name "Cli" -exec cp {} /usr/local/bin/tm_cli \; && \
    chmod +x /usr/local/bin/tm_cli && \
    echo "✅ Binary saved to /usr/local/bin/tm_cli"

# 5. 创建启动脚本
# 使用 EOF 写入，逻辑清晰
RUN cat <<EOF > /start.sh
#!/bin/sh

# === Web 保活部分 ===
echo "🚀 Starting Fake Web Server (Netcat) on port \${PORT:-8080}..."
# 使用 nc 监听端口，收到任何请求都返回 200 OK
# 这是一个死循环，放在后台运行 (&)
while true; do 
    echo -e "HTTP/1.1 200 OK\n\n Traffmonetizer Running..." | nc -l -p \${PORT:-8080} >/dev/null 2>&1
    sleep 1
done &

# === 挖矿业务部分 ===
echo "💎 Starting Traffmonetizer from backup location..."

# 检查 Token
if [ -z "\$TM_TOKEN" ]; then
    echo "❌ Error: TM_TOKEN is missing!"
    exit 1
fi

# 启动挖矿 (无限重启模式，防止崩溃退出)
while true; do
    /usr/local/bin/tm_cli start accept --token "\$TM_TOKEN"
    echo "⚠️ Process exited. Restarting in 10s..."
    sleep 10
done
EOF

# 6. 赋予脚本权限
RUN chmod +x /start.sh

# 7. 暴露端口
EXPOSE 8080

# 8. 启动
ENTRYPOINT ["/start.sh"]
