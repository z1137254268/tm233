# ==========================================
# 第一阶段：引入官方镜像作为数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：构建运行环境 (Debian Bookworm Slim)
# ==========================================
# 使用 Debian 以确保最佳的 glibc 兼容性
FROM debian:bookworm-slim

# 1. 安装必要的运行库
# libicu 和 libssl 是 .NET 程序必须的，netcat 用于保活
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    netcat-openbsd \
    libicu-dev \
    libssl-dev \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# 2. 【直接复制】
# 从源镜像复制二进制文件。保持原文件名 Cli
COPY --from=source /app/Cli /app/Cli

# 3. 配置权限和目录
# 创建必要的配置目录并赋予完整权限，防止写入失败
WORKDIR /app
RUN mkdir -p /app/traffmonetizer && \
    chmod +x /app/Cli && \
    chmod 777 /app/traffmonetizer

# 4. 默认环境变量
ENV PORT=8080

# 5. 生成启动脚本
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "🚀 Starting setup (Debian)..."' >> /entrypoint.sh && \
    # 优先使用平台提供的 PORT，没有则用 8080
    echo 'export RUN_PORT=${PORT:-8080}' >> /entrypoint.sh && \
    echo 'echo "🌐 Web Keep-alive listening on port $RUN_PORT"' >> /entrypoint.sh && \
    # Web Keep-alive (后台运行)
    echo '(while true; do echo -e "HTTP/1.1 200 OK\nContent-Length: 5\n\nAlive" | nc -l -p $RUN_PORT >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    # 启动主程序，确保传入 TM_TOKEN
    echo 'exec /app/Cli start accept --token "$TM_TOKEN" --device-name "Flootup-$(hostname)"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 启动
CMD ["/entrypoint.sh"]
