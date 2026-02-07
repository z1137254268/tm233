# ==========================================
# 第一阶段：引入官方镜像作为数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：构建运行环境 (Debian Bookworm Slim)
# ==========================================
# 放弃 Alpine，改用 Debian，彻底解决 glibc/musl 兼容性问题
FROM debian:bookworm-slim

# 1. 安装运行所需的库 (Netcat 用于保活，libicu/ssl 用于 .NET)
# 替换源这步可选，但为了构建速度和稳定性建议加上
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    netcat-openbsd \
    libicu-dev \
    libssl-dev \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# 2. 【直接复制】
# 从源镜像复制二进制文件。注意：保持原文件名 Cli，防止内部路径依赖
COPY --from=source /app/Cli /app/Cli

# 3. 配置权限和目录
# 某些版本可能需要写入 ./traffmonetizer/storage.json，所以我们创建目录并给权限
WORKDIR /app
RUN mkdir -p /app/traffmonetizer && \
    chmod +x /app/Cli && \
    chmod 777 /app/traffmonetizer

# 4. 环境变量
ENV PORT=8080

# 5. 生成启动脚本
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "🚀 Starting setup (Debian)..."' >> /entrypoint.sh && \
    echo 'export RUN_PORT=${PORT:-8080}' >> /entrypoint.sh && \
    echo 'echo "🌐 Web Keep-alive listening on port $RUN_PORT"' >> /entrypoint.sh && \
    # Web Keep-alive (使用 netcat)
    echo '(while true; do echo -e "HTTP/1.1 200 OK\nContent-Length: 5\n\nAlive" | nc -l -p $RUN_PORT >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /entrypoint.sh && \
    # 启动主程序
    # 注意：这里直接调用 /app/Cli，不再改名为 tm
    echo 'exec /app/Cli start accept --token "$TM_TOKEN" --device-name "Flootup-$(hostname)"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 启动
CMD ["/entrypoint.sh"]
