# 第一阶段：用官方镜像作为基础
FROM traffmonetizer/cli_v2:latest AS source

# 第二阶段：构建环境
FROM alpine:latest

# 1. 安装依赖
RUN apk add --no-cache \
    netcat-openbsd \
    ca-certificates \
    gcompat \
    libstdc++ \
    icu-libs

# 2. 【核心技巧】直接把源镜像的整个 /app 目录复制过来看看
# 既然不知道具体文件名，我们先复制目录，再用 shell 命令处理
COPY --from=source /app /app_temp

# 3. 找到真正的可执行文件并移动到正确位置
# 逻辑：在 /app_temp 里找那个最大的文件，或者名字里带 Cli/Traff 的文件
# 然后把它移动到 /usr/local/bin/tm_cli 并赋予权限
RUN find /app_temp -type f -exec ls -l {} \; && \
    mv /app_temp/TraffMonetizer /usr/local/bin/tm_cli || \
    mv /app_temp/Cli /usr/local/bin/tm_cli || \
    mv /app_temp/tm /usr/local/bin/tm_cli ; \
    chmod +x /usr/local/bin/tm_cli && \
    rm -rf /app_temp

# 4. 设置工作目录
WORKDIR /tmp

# 5. 生成启动脚本
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "🚀 Starting Web Server..."' >> /start.sh && \
    echo 'nohup sh -c "while true; do echo -e \"HTTP/1.1 200 OK\n\n Alive\" | nc -l -p ${PORT:-8080} >/dev/null 2>&1; sleep 1; done" >/dev/null 2>&1 &' >> /start.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /start.sh && \
    echo '/usr/local/bin/tm_cli start accept --token "$TM_TOKEN"' >> /start.sh

RUN chmod +x /start.sh

# 6. 启动
CMD ["/start.sh"]
