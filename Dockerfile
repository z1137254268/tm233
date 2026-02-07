FROM traffmonetizer/cli_v2:latest

# 什么都不改，就用它原生的启动方式
# 只传递 Token
ENV TM_TOKEN=$TM_TOKEN

# 官方镜像通常有个默认的 ENTRYPOINT，我们只需要传参
# 如果不知道 entrypoint 是啥，就传完整命令
CMD ["start", "accept", "--token", "${TM_TOKEN}"]
