FROM traffmonetizer/cli_v2:latest

ENV TM_TOKEN=$TM_TOKEN

# 使用 while true 循环来保持容器不退出，即使主程序崩溃
# 这里的 start accept 是官方推荐的启动参数
CMD ["/bin/sh", "-c", "./TraffMonetizer start accept --token ${TM_TOKEN} || ./Cli start accept --token ${TM_TOKEN}"]
