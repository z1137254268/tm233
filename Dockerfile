# 使用官方镜像
FROM traffmonetizer/cli_v2:latest

# 切换到 root 用户安装依赖
USER root

# 安装 Python3 (用于伪装 Web 服务)
RUN apk add --no-cache python3

# --- 关键修改：直接在构建时生成启动脚本，避免 Windows 换行符问题 ---
# 1. 写入脚本内容
# 2. 赋予执行权限
RUN echo '#!/bin/sh' > /app/run.sh && \
    echo 'echo "-----------------------------------"' >> /app/run.sh && \
    echo 'echo "🚀 Starting Fake Web Server on port ${PORT:-8080}"' >> /app/run.sh && \
    echo 'python3 -m http.server ${PORT:-8080} &' >> /app/run.sh && \
    echo 'echo "💎 Starting Traffmonetizer..."' >> /app/run.sh && \
    echo './Cli start accept --token "$TM_TOKEN"' >> /app/run.sh && \
    chmod +x /app/run.sh

# 设置工作目录
WORKDIR /app

# 设置启动命令
ENTRYPOINT ["/app/run.sh"]
