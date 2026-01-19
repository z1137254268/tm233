# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root
USER root

# 3. 安装 netcat (Web伪装工具)
RUN apk add --no-cache netcat-openbsd

# 4. 备份程序 (防止 /app 被平台覆盖导致找不到程序)
RUN echo "🔍 Backing up binary..." && \
    find / -type f -name "Cli" -exec cp {} /usr/local/bin/tm_cli \; && \
    chmod +x /usr/local/bin/tm_cli

# 5. 【核心修改】设置工作目录为 /tmp
# 这样程序就会在 /tmp 下创建配置文件，而不是去碰那个没有权限的 /app
WORKDIR /tmp

# 6. 创建启动脚本
RUN cat <<EOF > /start.sh
#!/bin/sh

# === Web 保活 (Netcat) ===
echo "🚀 Starting Web Server on port \${PORT:-8080}..."
# 循环响应 HTTP 200
while true; do 
    echo -e "HTTP/1.1 200 OK\n\n Traffmonetizer Running" | nc -l -p \${PORT:-8080} >/dev/null 2>&1
    sleep 1
done &

# === 挖矿业务 ===
echo "💎 Moving to /tmp and starting..."

# 再次确保进入 /tmp 目录
cd /tmp

# 启动程序
# 此时程序会在 /tmp/traffmonetizer 生成配置文件，这里绝对有权限！
while true; do
    /usr/local/bin/tm_cli start accept --token "\$TM_TOKEN"
    echo "⚠️ Process exited. Restarting in 10s..."
    sleep 10
done
EOF

# 7. 赋予权限
RUN chmod +x /start.sh

# 8. 暴露端口
EXPOSE 8080

# 9. 启动
ENTRYPOINT ["/start.sh"]
