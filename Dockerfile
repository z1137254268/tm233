FROM traffmonetizer/cli_v2:latest

ENV DOTNET_GCHeapHardLimit=60000000

# 不要用 USER 0，也不要用 RUN
# 直接把所有逻辑写在一行 Shell 命令里
# 1. 打印调试信息
# 2. 尝试运行 ./Cli
# 3. 尝试运行 ./TraffMonetizer
ENTRYPOINT ["/bin/sh", "-c", "echo 'Running...' && ls -lh && (./Cli start accept --token $TM_TOKEN || ./TraffMonetizer start accept --token $TM_TOKEN || echo 'FATAL: Binary not found')"]
