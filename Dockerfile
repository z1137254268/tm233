FROM traffmonetizer/cli_v2:latest

# 1. 切换到 root 用户以获取安装权限
USER root

# 2. 安装 netcat (用于 Web 保活)
RUN apk add --no-cache netcat-openbsd

# 3. 查找并备份核心程序
# cli_v2 镜像里的二进制文件通常叫 "Cli" 或者 "TraffMonetizer"
# 我们直接全盘搜索并复制到标准目录，防止路径变动
RUN find / -type f \( -name "Cli" -o -name "TraffMonetizer" \) -exec cp {} /usr/local/bin/tm_cli \; \
    && chmod +x /usr/local/bin/tm_cli

# 4. 设置工作目录为 /tmp
# 关键步骤！因为 /app 目录通常是只读的，/tmp 才有写配置文件的权限
WORKDIR /tmp

# 5. 生成启动脚本
# 使用 EOF 格式写入 start.sh
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo '# === Web 保活 (Netcat) ===' >> /start.sh && \
    echo 'echo "🚀 Starting Web Server on port ${PORT:-8080}..."' >> /start.sh && \
    echo 'while true; do' >> /start.sh && \
    echo '  echo -e "HTTP/1.1 200 OK\n\n Traffmonetizer Running" | nc -l -p ${PORT:-8080} >/dev/null 2>&1' >> /start.sh && \
    echo '  sleep 1' >> /start.sh && \
    echo 'done &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# === 启动主程序 ===' >> /start.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /start.sh && \
    echo 'cd /tmp' >> /start.sh && \
    echo 'while true; do' >> /start.sh && \
    echo '  /usr/local/bin/tm_cli start accept --token "$TM_TOKEN"' >> /start.sh && \
    echo '  echo "⚠️ Process exited. Restarting in 10s..."' >> /start.sh && \
    echo '  sleep 10' >> /start.sh && \
    echo 'done' >> /start.sh

# 6. 赋予脚本执行权限
RUN chmod +x /start.sh

# 7. 暴露端口 (虽然主要是给平台看的)
EXPOSE 8080

# 8. 启动
ENTRYPOINT ["/start.sh"]
