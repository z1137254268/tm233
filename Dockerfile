FROM traffmonetizer/cli_v2:latest

# 1. 内存限制 (你要的功能)
ENV DOTNET_GCHeapHardLimit=60000000

# 2. Token
ENV TM_TOKEN=$TM_TOKEN

# 3. 【核心】把所有 .NET 可能用到的临时目录都指到 /tmp
# 这样它绝对不会再去 /app 或 /home 下面写文件了
ENV DOTNET_BundleExtractBaseDirectory=/tmp/bundle
ENV DOTNET_CLI_HOME=/tmp
ENV HOME=/tmp
ENV APPDATA=/tmp
ENV XDG_CONFIG_HOME=/tmp

# 4. 切换工作目录 (虽然构建时没权限，但运行时通常可以)
WORKDIR /tmp

# 5. 启动命令
# 直接调用 start，利用官方镜像的 ENTRYPOINT
# 所有的环境变量已经在上面设置好了，程序启动时会自动读取
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
