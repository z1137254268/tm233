FROM traffmonetizer/cli_v2:latest

# 1. 内存限制
ENV DOTNET_GCHeapHardLimit=60000000

# 2. 传递 Token (这里只是声明，具体值由平台注入)
ENV TM_TOKEN=$TM_TOKEN

# 3. 启动命令 - 关键修改！
# 使用 /bin/sh -c 显式调用，确保 $TM_TOKEN 能被解析
# 我们同时尝试调用 ./Cli 和 ./TraffMonetizer，因为不知道它到底叫啥
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["./Cli start accept --token $TM_TOKEN || ./TraffMonetizer start accept --token $TM_TOKEN"]
