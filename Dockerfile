FROM traffmonetizer/cli_v2:latest

ENV DOTNET_GCHeapHardLimit=60000000
ENV TM_TOKEN=$TM_TOKEN
ENV DOTNET_BundleExtractBaseDirectory=/tmp
ENV HOME=/tmp

# 不改 WORKDIR，防止找不到程序
# 而是通过环境变量引导它去 /tmp 写数据
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
