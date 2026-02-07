# ==========================================
# 第一阶段：引入数据源
# ==========================================
FROM traffmonetizer/cli_v2:latest AS source

# ==========================================
# 第二阶段：Node.js 运行环境 (基于 Debian)
# ==========================================
# 使用 Node 18 bullseye 版本，既有 Node 环境，又有良好的 glibc 兼容性
FROM node:18-bullseye-slim

# 1. 安装 TM 二进制文件运行所需的原生依赖库
# 这一步不能省，否则 Cli 无法运行
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

# 2. 复制 Node 项目定义文件
COPY package.json ./

# 3. 安装 Node 依赖 (仅 express)
RUN npm install --only=production

# 4. 从源镜像复制核心二进制文件
# 保持原名 Cli，放在根目录
COPY --from=source /app/Cli /app/Cli
# 赋予执行权限
RUN chmod +x /app/Cli

# 5. 复制我们的主程序脚本
COPY server.js ./

# 6. 创建必要的配置目录并给权限
RUN mkdir -p /app/traffmonetizer && \
    chmod 777 /app/traffmonetizer

# 7. 环境变量设置
ENV PORT=8080
ENV NODE_ENV=production

# 8. 启动命令
# Flootup 默认就会执行这个，非常完美
CMD ["npm", "start"]
