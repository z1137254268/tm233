FROM traffmonetizer/cli_v2:latest

# 1. 限制内存
ENV DOTNET_GCHeapHardLimit=60000000

# 2. 传递 Token
ENV TM_TOKEN=$TM_TOKEN

# 3. 【关键修改】设置临时目录变量
# 这会告诉 .NET 程序把临时文件解压到 /tmp，解决 Permission denied
ENV DOTNET_BundleExtractBaseDirectory=/tmp
ENV HOME=/tmp

# 4. 【关键修改】切换工作目录到 /tmp
# 这样程序生成的配置文件也会存到 /tmp
WORKDIR /tmp

# 5. 启动命令
# 假设官方镜像里的程序已经加入了 PATH (通常是这样)，所以直接运行 start
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
