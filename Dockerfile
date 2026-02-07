# ==========================================
# 第一阶段：引入官方镜像作为数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：构建运行环境 (Alpine Linux)
# ==========================================
FROM alpine:latest

# 1. 优化镜像源 (解决网络卡顿) 并安装依赖
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.edge.kernel.org/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
    ca-certificates \
    libstdc++ \
    gcompat \
    icu-libs \
    netcat-openbsd \
    bash

# 2. 【直接复制】不再搜索，直接复制已知路径
# 将 /app/Cli 复制并重命名为 /usr/local/bin/tm
COPY --from=source /app/Cli /usr/local/bin/tm

# 3. 赋予执行权限
RUN chmod +x /usr/local/bin/tm

# 4. 配置环境
WORKDIR /app
ENV DOTNET_GCHeapHardLimit=60000000
ENV PORT=8080

# 5. 生成启动脚本
# 包含 Web 保活 (适配 Flootup) 和主程序启动
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "🚀 Starting setup..."' >> /entrypoint.sh && \
    echo 'export RUN_PORT=${PORT:-8080}' >> /entrypoint.sh && \
    echo 'echo "🌐 Web Keep-alive listening on port $RUN_PORT"' >> /entrypoint.sh && \
    # Web Keep-alive 服务
    echo '(while true; do echo -e "HTTP/1.1 200 OK\nContent-Length: 5\n\nAlive" | nc -l -p $RUN_PORT >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /entrypoint.sh && \
    # 启动主程序
    echo 'exec /usr/local/bin/tm start accept --token "$TM_TOKEN" --device-name "Flootup-$(hostname)"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 启动
CMD ["/entrypoint.sh"]
