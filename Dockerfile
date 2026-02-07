FROM traffmonetizer/cli_v2:latest

ENV DOTNET_GCHeapHardLimit=60000000

# 1. 切换到 root (如果镜像允许)
USER 0

# 2. 生成启动脚本 /start.sh
# 我们用 printf 来避免特殊字符问题
# 逻辑：尝试运行 ./Cli 或 ./TraffMonetizer
# 并且加上了详细的调试信息
RUN printf "#!/bin/sh\n\
echo 'Running start script...'\n\
echo 'Current User: \$(whoami)'\n\
echo 'Files in current dir:'\n\
ls -lh\n\
\n\
if [ -f \"./Cli\" ]; then\n\
    echo 'Found ./Cli, starting...'\n\
    ./Cli start accept --token \$TM_TOKEN\n\
elif [ -f \"./TraffMonetizer\" ]; then\n\
    echo 'Found ./TraffMonetizer, starting...'\n\
    ./TraffMonetizer start accept --token \$TM_TOKEN\n\
else\n\
    echo 'Binary not found in current dir. Searching / ...'\n\
    find / -name 'Cli' -o -name 'TraffMonetizer' 2>/dev/null\n\
fi\n" > /start.sh && chmod +x /start.sh

# 3. 设置入口
ENTRYPOINT ["/bin/sh", "/start.sh"]
