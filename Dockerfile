# 第一阶段：作为“资源库”，只为了提取官方文件
FROM traffmonetizer/traffmonetizer:latest AS source

# 第二阶段：构建我们要运行的实际环境 (使用 Alpine Linux)
FROM alpine:latest

# 1. 安装你需要的 netcat 和 .NET 运行所需的依赖库 (gcompat/icu-libs 是关键)
RUN apk add --no-cache \
    netcat-openbsd \
    ca-certificates \
    gcompat \
    icu-libs

# 2. 从第一阶段把 TraffMonetizer 程序复制过来
# 官方镜像通常把程序放在 /app/TraffMonetizer
COPY --from=source /app/TraffMonetizer /app/TraffMonetizer

# 3. 设置工作目录
WORKDIR /app

# 4. 复制你的启动脚本并赋予权限
COPY start.sh ./
RUN chmod +x start.sh

# 5. 启动
CMD ["./start.sh"]
