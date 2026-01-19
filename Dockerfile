# [...](asc_slot://start-slot-4)使用官方镜像
FROM traffmonetizer/cli_v2:latest

# [...](asc_slot://start-slot-6)必须使用 root 权限来安装 Python
USER root

# 1. [...](asc_slot://start-slot-8)安装 Python3 (用于 Web 伪装)
# 2. [...](asc_slot://start-slot-10)显式创建 /app 目录 (防止目录不存在报错)
RUN apk add --no-cache python3 && \
    mkdir -p /app

# 设置工作目录
WORKDIR /app

# 3. [...](asc_slot://start-slot-12)生成启动脚本 (使用 printf 更安全)
# 脚本逻辑：后台运行 Web 服务器保活 + 前台运行挖矿业务
RUN printf "#!/bin/sh\n\
echo '-----------------------------------'\n\
echo '🚀 Starting Fake Web Server on port \${PORT:-8080}'\n\
python3 -m http.server \${PORT:-8080} &\n\
echo '💎 Starting Traffmonetizer...'\n\
# 确保二进制文件可执行\n\
chmod +x /app/Cli\n\
./Cli start accept --token \"\$TM_TOKEN\"\n\
" > /app/run.sh

# 4. [...](asc_slot://start-slot-14)赋予脚本最高权限 (解决部分平台非 root 用户运行的问题)
RUN chmod 777 /app/run.sh

# 5. [...](asc_slot://start-slot-16)声明端口 (帮助云平台识别)
EXPOSE 8080

# 启动命令
ENTRYPOINT ["/app/run.sh"]
