# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root 权限
USER root

# 3. 设置工作目录
WORKDIR /app

# 4. 【核心关键】重置官方镜像的 ENTRYPOINT
# 官方镜像锁定了 ENTRYPOINT ["./Cli"]，这会导致我们无法运行 Web 服务
# 我们必须把它置空，才能使用下面的 CMD
ENTRYPOINT []

# 5. 【核心关键】使用 Shell 模式运行双进程
# 逻辑：
# A. 创建一个假的 index.html
# B. 后台运行 busybox httpd (超轻量 Web 服务)，监听 $PORT
# C. 前台运行 Cli (Traffmonetizer)，读取 $TM_TOKEN
CMD ["/bin/sh", "-c", "echo 'Service is Running' > index.html && busybox httpd -f -p ${PORT:-8080} & ./Cli start accept --token ${TM_TOKEN}"]
