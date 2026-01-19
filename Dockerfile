# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换到 root (尝试获取最高权限)
USER root

# 3. 清空入口点 (防止冲突)
ENTRYPOINT []

# 4. 启动命令 (关键修改)
# 修改点 A: 将 index.html 写到 /tmp 目录 (那里肯定有权限)
# 修改点 B: 让 busybox httpd 从 /tmp 目录提供网页服务 (-h /tmp)
# 修改点 C: 使用绝对路径 /app/Cli 启动主程序 (不管当前在哪都能找到)
CMD ["/bin/sh", "-c", "echo 'Service Running' > /tmp/index.html && busybox httpd -f -p ${PORT:-8080} -h /tmp & /app/Cli start accept --token ${TM_TOKEN}"]
