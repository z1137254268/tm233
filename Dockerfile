FROM traffmonetizer/cli_v2:latest

# 限制 .NET 堆内存为 ~60MB
ENV DOTNET_GCHeapHardLimit=60000000

# 传递 Token
ENV TM_TOKEN=$TM_TOKEN

# 保持原样，利用官方自带的启动逻辑
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
