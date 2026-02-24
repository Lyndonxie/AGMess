#!/bin/bash

npm install uuid

# 使用 Node.js 脚本生成 UUID 并赋值给环境变量
export UUID=$(node -e "const { v4: uuidv4 } = require('uuid'); console.log(uuidv4());")

# 调试输出：确认 UUID 已生成
echo "Generated UUID: $UUID"

# --- 哪吒探针配置 ---
export NEZHA_SERVER=""          # 哪吒面板域名。v1 填写形式：nezha.xxx.com:8008；v0 填写形式：nezha.xxx.com
export NEZHA_PORT=""            # v1 哪吒不要填写这个。v0 哪吒 agent 端口，端口为 {443, 8443, 2096, 2087, 2083, 2053} 之一时开启 TLS
export NEZHA_KEY=""             # v1 哪吒的 NZ_CLIENT_SECRET 或 v0 哪吒 agent 密钥

# --- Argo 隧道配置 ---
#!/bin/bash

npm install uuid

# 使用 Node.js 脚本生成 UUID 并赋值给环境变量
#export UUID=$(node -e "const { v4: uuidv4 } = require('uuid'); console.log(uuidv4());")
export UUID="649e3c6f-0254-4616-ab26-9d77c9719052"
# 调试输出：确认 UUID 已生成
echo "Generated UUID: $UUID"

# --- 哪吒探针配置 ---
export NEZHA_SERVER=""          # 哪吒面板域名。v1 填写形式：nezha.xxx.com:8008；v0 填写形式：nezha.xxx.com
export NEZHA_PORT=""            # v1 哪吒不要填写这个。v0 哪吒 agent 端口，端口为 {443, 8443, 2096, 2087, 2083, 2053} 之一时开启 TLS
export NEZHA_KEY=""             # v1 哪吒的 NZ_CLIENT_SECRET 或 v0 哪吒 agent 密钥

# --- Argo 隧道配置 ---
export ARGO_DOMAIN="bloomberg.f.b.2.0.9.1.0.0.0.7.4.0.1.0.0.2.ip6.arpa"           # Argo 域名，留空即启用临时隧道
export ARGO_AUTH="eyJhIjoiYWExZDM1MDYzNGQ1MDA2OGJkMGZkZDIxNjA3MGZhZTUiLCJ0IjoiYWYyNTliYWQtNGFhNC00ZGFhLWI3ODMtMGU0ODMyNWE0YzI3IiwicyI6IlpHSTVaV1k0T0dJdE1XSm1ZeTAwT1dZM0xUbGpOR1l0T1dVNU5UY3dNakE0T0dGaiJ9"             # Argo Token 或 json，留空即启用临时隧道

# --- 其他配置 ---
export NAME="idx-bloomberg"               # 节点名称
export CFIP="usa.visa.com" # 优选 IP 或优选域名
export CFPORT=443               # 优选 IP 或优选域名对应端口
export CHAT_ID="-4918534407"               # Telegram Chat ID
export BOT_TOKEN="8053333842:AAGuW87kKbZ5Enl3AfezSgwyb0txR-0iTis"             # Telegram Bot Token。需要同时填写 Chat ID 才会推送节点到 Telegram
export UPLOAD_URL=              # 节点自动推送到订阅器，需要填写部署 merge-sub 项目后的首页地址，例如：https://merge.eooce.ggff.net

# --- 执行主部署脚本 ---
# 这会下载并执行远程的 sb.sh 脚本，并使用上面设置的环境变量
bash <(curl -Ls https://raw.githubusercontent.com/leotse28/AGMess/refs/heads/main/sb.sh)
curl ifconfig.me
chmod +x README.md
chmod +x auto_append.sh
./auto_append.sh

