# 修正镜像名称为 cli_v2
FROM traffmonetizer/cli_v2:latest AS source

FROM alpine:latest

# 安装依赖
RUN apk add --no-cache \
    netcat-openbsd \
    ca-certificates \
    gcompat \
    icu-libs

# 从新版镜像中复制程序
# 注意：新版可能把二进制文件改名了，或者路径变了
# 通常还是 /app/TraffMonetizer，如果这里报错，我们再调整路径
COPY --from=source /app/cli /app/cli

WORKDIR /app

COPY start.sh ./
RUN chmod +x start.sh

CMD ["./start.sh"]
