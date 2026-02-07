# 使用那个诡异的官方镜像
FROM traffmonetizer/cli_v2:latest

# 这里的 ENTRYPOINT 会覆盖官方的启动命令
# 我们用 ls -R / 打印所有文件，看看它把程序藏哪了
ENTRYPOINT ["ls", "-R", "/app", "/usr/bin", "/usr/local/bin"]
