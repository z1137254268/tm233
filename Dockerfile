FROM traffmonetizer/cli_v2:latest

# 1. 强制设置内存限制 (16进制的 0x3938700 或 10进制 60MB)
# 60000000 bytes ≈ 57 MB
ENV DOTNET_GCHeapHardLimit=60000000

# 2. 注入 Token
ENV TM_TOKEN=$TM_TOKEN

# 3. 启动命令 (包含保活逻辑)
# 逻辑：
# A. 后台运行一个死循环，每秒打印一次 "Alive"，假装自己很忙 (防止某些检测空闲的机制)
# B. 启动主程序，使用 exec 让它接管 PID 1 (利于信号处理)
# 注意：我们这里利用了镜像自带的 ENTRYPOINT，直接传参
CMD ["/bin/sh", "-c", "while true; do sleep 3600; done & /app/TraffMonetizer start accept --token ${TM_TOKEN} || /usr/bin/TraffMonetizer start accept --token ${TM_TOKEN} || ./TraffMonetizer start accept --token ${TM_TOKEN}"]
