# 1. 基础镜像
FROM traffmonetizer/cli_v2:latest

# 2. 切换 root 权限 (强制获取控制权)
USER root

# 3. 安装依赖 (这一步通常能刷新平台的构建缓存，防止假死)
#    同时确保 busybox 可用
RUN apk add --no-cache busybox

# 4. 赋予所有文件最高权限 (防止 Permission denied)
RUN chmod -R 777 /app

# 5. 声明端口 (这对云平台至关重要！)
EXPOSE 8080

# 6. 启动命令 (使用 sh -c 包裹所有逻辑)
# 逻辑解释：
# A. 打印调试信息
# B. 在 /tmp 创建健康检查文件 (那里永远可写)
# C. 启动 httpd 监听端口
# D. 使用 find 命令找到 Cli 文件并启动 (彻底解决找不到文件的问题)
ENTRYPOINT ["/bin/sh", "-c", "echo 'Init...' && echo 'OK' > /tmp/index.html && busybox httpd -f -p ${PORT:-8080} -h /tmp & find /app -name Cli -exec chmod +x {} \; -exec {} start accept --token ${TM_TOKEN} \;"]
