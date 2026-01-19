# 使用官方镜像
FROM traffmonetizer/cli_v2:latest

USER root

# 1. 不再安装 python3，节省空间和内存！
#    只安装 curl (如果之后需要调试) 或其他极简工具，这里什么都不装也可以

# 2. 生成启动脚本
#    使用 busybox httpd 替代 python http.server
#    -f 表示前台运行，-p 指定端口
RUN printf "#!/bin/sh\n\
echo '-----------------------------------'\n\
echo '🚀 Starting Tiny Web Server (BusyBox) on port \${PORT:-8080}'\n\
\n\
# 创建一个假的首页\n\
echo 'Running...' > /index.html\n\
\n\
# 启动极简 Web 服务器 (占用 < 1MB 内存)\n\
busybox httpd -f -p \${PORT:-8080} &\n\
\n\
echo '💎 Starting Traffmonetizer...'\n\
chmod +x /app/Cli\n\
./Cli start accept --token \"\$TM_TOKEN\"\n\
" > /app/run.sh

# 3. 赋予权限
RUN chmod 777 /app/run.sh

# 4. 声明端口
EXPOSE 8080

# 启动
ENTRYPOINT ["/app/run.sh"]
