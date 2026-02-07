# ==========================================
# 阶段 1: 数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 阶段 2: 猎人 (负责找到二进制文件)
# ==========================================
FROM alpine:latest AS hunter
# 1. 安装 find 工具
RUN apk add --no-cache findutils
# 2. 将源镜像的所有内容复制到临时目录 /dump
COPY --from=source / /dump
# 3. 【核心步骤】搜索并提取
# 在 /dump 中搜索名为 Cli 或 TraffMonetizer (忽略大小写) 的文件
# 找到第一个后，将其复制到 /found_binary 并退出搜索
RUN echo "🔍 Scanning for binary..." && \
    find /dump -type f \( -iname "Cli" -o -iname "TraffMonetizer" \) -exec cp {} /found_binary \; -quit && \
    # 检查是否找到了文件
    if [ ! -f /found_binary ]; then \
        echo "❌ Error: Binary 'Cli' or 'TraffMonetizer' not found in source image!"; \
        # 列出一些文件帮助调试 (可选)
        # find /dump -maxdepth 4; \
        exit 1; \
    fi && \
    chmod +x /found_binary && \
    echo "✅ Binary found and extracted to /found_binary" && \
    # 清理临时文件
    rm -rf /dump

# ==========================================
# 阶段 3: 最终运行环境 (Node.js + Debian)
# ==========================================
FROM node:18-bullseye-slim

# 1. 安装 TM 核心运行所需的原生依赖库
# 使用 debian 源，确保 glibc 兼容性
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libicu-dev \
    libssl-dev \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. 复制 Node 项目定义文件并安装依赖
COPY package.json ./
RUN npm install --only=production

# 3. 【关键修改】从 hunter 阶段复制找到的二进制文件
# 将其保存为 /app/Cli，以便 server.js 调用
COPY --from=hunter /found_binary /app/Cli

# 4. 复制主程序脚本
COPY server.js ./

# 5. 创建配置目录并设置权限
RUN mkdir -p /app/traffmonetizer && \
    chmod 777 /app/traffmonetizer

# 6. 环境变量
ENV PORT=8080
ENV NODE_ENV=production

# 7. 启动命令 (由 Flootup 执行 npm start)
CMD ["npm", "start"]
