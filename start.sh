#!/bin/sh

# 打印一下，确认脚本开始运行
echo "Starting cli..."

# 检查 Token 是否存在
if [ -z "$TM_TOKEN" ]; then
    echo "Error: TM_TOKEN is missing!"
    exit 1
fi

# 启动 HTTP 服务器 (为了骗过部署平台的健康检查，防止被休眠)
# 监听 3000 端口，如果收到请求就返回 "OK"
# 这里的 nc (netcat) 就是你在 Dockerfile 里安装的那个工具
while true; do 
    echo -e "HTTP/1.1 200 OK\n\n I am alive!" | nc -l -p 3000 -q 1 > /dev/null 2>&1
done &

# 启动 TraffMonetizer 核心程序
# ./cli start accept --token <你的Token> --device-name <设备名>
# 这里的 "$TM_TOKEN" 会自动读取你在部署平台设置的环境变量
./cli start accept --token "$TM_TOKEN" --device-name "MyDevice"
