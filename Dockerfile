# ==========================================
# 第一阶段：引入官方镜像作为数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：构建运行环境 (Alpine Linux)
# ==========================================
FROM alpine:latest

# 1. 安装必要的依赖
# netcat-openbsd 用于 Web 保活
# libstdc++, gcompat, icu-libs 用于运行 .NET 程序
RUN apk add --no-cache \
    ca-certificates \
    libstdc++ \
    gcompat \
    icu-libs \
    netcat-openbsd \
    bash

# 2. 【核心操作】从官方镜像提取二进制文件
# 将源镜像的根目录复制到临时目录进行扫描
COPY --from=source / /distro_dump

# 3. 自动搜索并安装程序
# 扫描 Cli 或 TraffMonetizer 可执行文件并移动到 /usr/local/bin/tm
RUN echo "🔍 Scanning for binary..." && \
    FOUND=$(find /distro_dump -type f \( -name "Cli" -o -name "TraffMonetizer" \) | head -n 1) && \
    if [ -z "$FOUND" ]; then echo "❌ Binary not found!"; exit 1; fi && \
    echo "✅ Found binary at: $FOUND" && \
    cp "$FOUND" /usr/local/bin/tm && \
    chmod +x /usr/local/bin/tm && \
    # 清理临时文件以减小镜像体积
    rm -rf /distro_dump

# 4. 配置工作目录和环境变量
WORKDIR /app

# 优化 .NET 垃圾回收限制 (适合容器环境)
ENV DOTNET_GCHeapHardLimit=60000000
# 默认端口 (如果平台未提供 PORT 变量，则使用 8080)
ENV PORT=8080

# 5. 生成启动脚本 (Entrypoint)
# 修改点：使用了 $PORT 变量，适配 Flootup 的动态端口
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "🚀 Starting setup..."' >> /entrypoint.sh && \
    echo 'export RUN_PORT=${PORT:-8080}' >> /entrypoint.sh && \
    echo 'echo "🌐 Web Keep-alive listening on port $RUN_PORT"' >> /entrypoint.sh && \
    # 启动后台 Web 服务器 (Keep-alive)
    echo '(while true; do echo -e "HTTP/1.1 200 OK\nContent-Length: 5\n\nAlive" | nc -l -p $RUN_PORT >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /entrypoint.sh && \
    # 启动主程序
    echo 'exec /usr/local/bin/tm start accept --token "$TM_TOKEN" --device-name "Flootup-$(hostname)"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 暴露端口 (仅供文档参考，实际由 $PORT 决定)
EXPOSE 8080

# 7. 启动
CMD ["/entrypoint.sh"]
