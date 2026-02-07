FROM traffmonetizer/cli_v2:latest

# 1. 限制内存 (这是你最想要的功能之一)
ENV DOTNET_GCHeapHardLimit=60000000

# 2. 传递 Token
ENV TM_TOKEN=$TM_TOKEN

# 3. 保持最原始的启动方式 (不要加 /bin/sh 之类的)
# 直接传参给官方镜像的默认入口
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
