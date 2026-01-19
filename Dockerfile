# 1. 拉取官方镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换到 root 权限
USER root

# 3. 设置工作目录 (确保能找到 ./Cli 文件)
WORKDIR /app

# 4. 生成启动脚本 (逐行写入，最稳健的方式)
# 注意：${PORT:-8080} 和 $TM_TOKEN 前面都加了反斜杠 \ 
# 这是为了告诉 Docker："不要现在替换变量，等容器运行的时候再替换"
RUN echo '#!/bin/sh' > /app/run.sh && \
    echo 'echo "-----------------------------------"' >> /app/run.sh && \
    echo 'echo "🚀 Starting Tiny Web Server (BusyBox)..."' >> /app/run.sh && \
    echo 'echo "Running..." > /index.html' >> /app/run.sh && \
    echo 'busybox httpd -f -p ${PORT:-8080} &' >> /app/run.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /app/run.sh && \
    echo 'chmod +x /app/Cli' >> /app/run.sh && \
    echo './Cli start accept --token "$TM_TOKEN"' >> /app/run.sh

# 5. 赋予脚本执行权限
RUN chmod 777 /app/run.sh

# 6. 暴露端口 (即使我们用 host 网络，这个声明对云平台也有帮助)
EXPOSE 8080

# 7. 覆盖入口点
ENTRYPOINT ["/app/run.sh"]
