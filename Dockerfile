# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root
USER root

# 3. 安装 busybox (确保有 httpd)
RUN apk add --no-cache busybox

# 4. 创建并配置启动脚本
# 使用 cat <<EOF 的方式写入，这是最不容易出错的多行写入方式
RUN cat <<EOF > /start.sh
#!/bin/sh

# 1. 启动伪装 Web 服务 (放在后台)
echo "🚀 Starting Web Server on port \${PORT:-8080}..."
mkdir -p /tmp/web
echo "Service is Running" > /tmp/web/index.html
# -h 指定网页根目录, -p 指定端口
busybox httpd -f -p \${PORT:-8080} -h /tmp/web &

# 2. 启动挖矿主程序 (死循环模式)
# 就算程序崩溃，也会在 10 秒后自动重启，保证容器不退出！
echo "💎 Starting Traffmonetizer..."
while true; do
    # 尝试启动
    /app/Cli start accept --token "\$TM_TOKEN"
    
    # 如果程序退出了，打印日志并等待
    echo "⚠️ Main process exited. Restarting in 10 seconds..."
    sleep 10
done
EOF

# 5. 赋予脚本最高权限
RUN chmod +x /start.sh && chmod 777 /start.sh

# 6. 赋予程序执行权限 (双重保险)
RUN chmod +x /app/Cli

# 7. 暴露端口
EXPOSE 8080

# 8. 启动
ENTRYPOINT ["/start.sh"]
