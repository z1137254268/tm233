# 第一阶段：引入官方镜像（仅作为数据源）
FROM traffmonetizer/cli_v2:latest AS source

# 第二阶段：构建我们要运行的系统 (Alpine)
FROM alpine:latest

# 1. 安装必要的依赖 (运行 .NET 和 Web 保活所需)
RUN apk add --no-cache \
    ca-certificates \
    libstdc++ \
    gcompat \
    icu-libs \
    netcat-openbsd

# 2. 【核心操作】把官方镜像的“根目录”完全复制到临时文件夹
# 既然不知道它在哪，就全拷过来
COPY --from=source / /distro_dump

# 3. 搜索并提取程序
# 在 dump 目录里找名为 "Cli" 或 "TraffMonetizer" 的可执行文件
# 找到后移动到 /usr/local/bin/tm
RUN echo "🔍 Scanning for binary..." && \
    FOUND=$(find /distro_dump -type f \( -name "Cli" -o -name "TraffMonetizer" \) | head -n 1) && \
    if [ -z "$FOUND" ]; then echo "❌ Binary not found!"; exit 1; fi && \
    echo "✅ Found binary at: $FOUND" && \
    cp "$FOUND" /usr/local/bin/tm && \
    chmod +x /usr/local/bin/tm && \
    # 清理垃圾
    rm -rf /distro_dump

# 4. 准备工作环境
WORKDIR /tmp
ENV DOTNET_GCHeapHardLimit=60000000
ENV TM_TOKEN=$TM_TOKEN

# 5. 生成启动脚本 (包含 Web 保活)
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'echo "🚀 Starting Web Keep-alive..."' >> /entrypoint.sh && \
    echo '(while true; do echo -e "HTTP/1.1 200 OK\n\nAlive" | nc -l -p 8080 >/dev/null 2>&1; sleep 5; done) &' >> /entrypoint.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /entrypoint.sh && \
    echo '/usr/local/bin/tm start accept --token "$TM_TOKEN"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. 启动
CMD ["/entrypoint.sh"]
