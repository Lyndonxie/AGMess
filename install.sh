#!/bin/bash

npm install uuid

# 使用 Node.js 脚本生成 UUID 并赋值给环境变量
#export UUID=$(node -e "const { v4: uuidv4 } = require('uuid'); console.log(uuidv4());")
export UUID="dadf0ebf-034a-49cf-9f46-5a48ef01ae60"
# 调试输出：确认 UUID 已生成
echo "Generated UUID: $UUID"

# --- 哪吒探针配置 ---
export NEZHA_SERVER=""          # 哪吒面板域名。v1 填写形式：nezha.xxx.com:8008；v0 填写形式：nezha.xxx.com
export NEZHA_PORT=""            # v1 哪吒不要填写这个。v0 哪吒 agent 端口，端口为 {443, 8443, 2096, 2087, 2083, 2053} 之一时开启 TLS
export NEZHA_KEY=""             # v1 哪吒的 NZ_CLIENT_SECRET 或 v0 哪吒 agent 密钥

# --- Argo 隧道配置 ---
export ARGO_DOMAIN="lx.xielioukom.x10.mx"           # Argo 域名，留空即启用临时隧道
export ARGO_AUTH="eyJhIjoiYWExZDM1MDYzNGQ1MDA2OGJkMGZkZDIxNjA3MGZhZTUiLCJ0IjoiYjRiNjZjODktNzg1Yy00NDg5LWE4NDUtNDFhMzY2NjA1ZDk1IiwicyI6Ik16QXpNbVl5WkRndFkyWmxOeTAwTXpoaExXSTVPVEl0TXpKalpHRm1OMk5oWkdGaSJ9"             # Argo Token 或 json，留空即启用临时隧道

# --- 其他配置 ---
export NAME="idx"               # 节点名称
export CFIP="www.visa.com.hk" # 优选 IP 或优选域名
export CFPORT=443               # 优选 IP 或优选域名对应端口
export CHAT_ID="-4918534407"               # Telegram Chat ID
export BOT_TOKEN="8053333842:AAGuW87kKbZ5Enl3AfezSgwyb0txR-0iTis"             # Telegram Bot Token。需要同时填写 Chat ID 才会推送节点到 Telegram
export UPLOAD_URL=              # 节点自动推送到订阅器，需要填写部署 merge-sub 项目后的首页地址，例如：https://merge.eooce.ggff.net

# --- 执行主部署脚本 ---
# 这会下载并执行远程的 sb.sh 脚本，并使用上面设置的环境变量
bash <(curl -Ls https://main.ssss.nyc.mn/sb.sh)
