FROM alpine:3.20
RUN apk add --no-cache ca-certificates curl unzip
WORKDIR /app
# 下载 Xray-core（linux-64）
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v25.9.3/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
# Railway 会注入 $PORT，Xray 监听该端口；TLS 由 Railway 边缘终止，Xray 内部用 security=none
CMD ["/app/start.sh"]
