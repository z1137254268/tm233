# 使用官方镜像作为基础，确保内核版本和依赖是最新的
FROM traffmonetizer/cli_v2:latest

# 切换到 root 用户安装依赖 (Alpine 基础镜像)
USER root

# 安装 python3 用于运行伪装 Web 服务
RUN apk add --no-cache python3

# 将启动脚本复制进容器
COPY entrypoint.sh /app/entrypoint.sh

# 赋予脚本执行权限
RUN chmod +x /app/entrypoint.sh

# 设置工作目录
WORKDIR /app

# 设置容器启动入口
ENTRYPOINT ["./entrypoint.sh"]
