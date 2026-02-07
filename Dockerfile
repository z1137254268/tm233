# ==========================================
# 第一阶段：引入官方镜像作为数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：构建运行环境 (Alpine Linux)
# ==========================================
FROM alpine:latest

# --- 【关键修改】更换 Alpine 镜像源 ---
# 替换默认源为 kernel.org 镜像，通常比默认的 dl-cdn 更稳定，能解决下载卡住的问题
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.edge.kernel.org/g' /etc/apk/repositories

# 1. 安装依赖 (添加了 --no-cache 确保获取最新索引)
# 将命令拆分，这样如果卡住你能清楚看到是哪一步
RUN apk update && \
    apk add --no-cache \
    ca-certificates \
    libstdc++ \
    gcompat \
    icu-libs \
    netcat-openbsd \
    bash

# 2. 【核心操作】从官方镜像提取二进制文件
COPY --from=source / /distro_dump

# 3. 自动搜索并安装程序
RUN echo "🔍 Scanning for binary..." && \
    FOUND=$(find /distro_dump -type f \( -name "Cli" -o -name "TraffMonetizer" \) | head -n 1) && \
    if [ -z "$FOUND" ]; then echo "❌ Binary not found!"; exit 1; fi && \
    echo "✅ Found binary at: $FOUND" && \
    cp "$FOUND" /usr/local/bin/tm && \
    chmod +x /usr/local/bin/tm && \
    rm -rf /distro_dump

# 4. 配置工作目录和环境变量
WORKDIR /app
ENV DOTNET_GCHeapHardLimit=60000000
ENV PORT=8080

# 5. 生成启动脚本 (Entrypoint)
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "🚀 Starting setup..."' >> /entrypoint.sh && \
    echo 'export RUN_PORT=${PORT:-8080}' >> /entrypoint.sh && \
    echo 'echo "🌐 Web Keep-alive listening on port $RUN_PORT"' >> /entrypoint.sh && \
    # Web 保活服务
    echo '(while true; do echo -e "HTTP/1.1 200 OK\nContent-Length: 5\n\nAlive" | nc -l -p $RUN_PORT >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /entrypoint.sh && \
    # 启动主程序
    echo 'exec /usr/local/bin/tm start accept --token "$TM_TOKEN" --device-name "Flootup-$(hostname)"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 启动
CMD ["/entrypoint.sh"]
