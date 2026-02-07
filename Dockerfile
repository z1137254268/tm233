# 第一阶段：作为资源库 (Source)
# 我们只用它来提供文件，不运行它，所以不需要管它的权限问题
FROM traffmonetizer/cli_v2:latest AS source

# 第二阶段：构建运行环境 (Runtime)
# 使用干净的 Alpine，你是这里的神 (Root)
FROM alpine:latest

# 1. 安装必要的依赖库
# gcompat 和 libstdc++ 是运行该程序必须的
RUN apk add --no-cache \
    netcat-openbsd \
    ca-certificates \
    gcompat \
    libstdc++ \
    icu-libs

# 2. 从第一阶段复制核心程序
# 根据官方镜像结构，文件通常在 /app/Cli 或 /app/TraffMonetizer
# 我们使用通配符逻辑变通一下：直接指名复制
# 注意：如果下面这行报错，说明官方改了路径，但目前大概率是这个
COPY --from=source /app/Cli /usr/local/bin/tm_cli

# 3. 赋予执行权限
RUN chmod +x /usr/local/bin/tm_cli

# 4. 设置工作目录到 /tmp (确保有读写权限)
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
