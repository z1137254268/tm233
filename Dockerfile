FROM traffmonetizer/cli_v2:latest

ENV DOTNET_GCHeapHardLimit=60000000

# 覆盖默认入口，使用 Shell
ENTRYPOINT ["/bin/sh", "-c"]

# 启动脚本逻辑：
# 1. 打印调试信息
# 2. 查找名为 'TraffMonetizer' 或 'Cli' 的文件
# 3. 找到后直接运行
CMD ["echo '🔍 Searching for binary...' && \
      EXE=$(find /app /usr -name 'TraffMonetizer' -o -name 'Cli' -type f | head -n 1) && \
      if [ -z \"$EXE\" ]; then \
          echo '❌ Error: Binary not found!'; \
          find / -maxdepth 3; \
          exit 1; \
      else \
          echo \"✅ Found binary at: $EXE\"; \
          $EXE start accept --token $TM_TOKEN; \
      fi"]
