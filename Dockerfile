# 直接基于官方镜像，不折腾文件移动了
FROM traffmonetizer/cli_v2:latest

# 1. 切换到用户 0 (强制 root 身份，虽然可能缺系统文件，但权限是有的)
# 如果这行报错，就删掉它，但通常加上比较保险
USER 0

# 2. 直接覆盖 ENTRYPOINT
# 我们用一段复杂的 shell 脚本来同时做两件事：
# A. 启动一个极简的 Python Web Server (监听 8080)
# B. 启动原本的 TraffMonetizer (尝试默认命令)
ENTRYPOINT ["/bin/sh", "-c", "python3 -m http.server 8080 & ./TraffMonetizer start accept --token $TM_TOKEN || ./Cli start accept --token $TM_TOKEN"]
