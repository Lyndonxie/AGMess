vmpt="50108" uuid="dadf0ebf-034a-49cf-9f46-5a48ef01ae60" argo="y" agn="" agk="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosb/main/argosb.sh)
cat /home/user/agsb/jh.txt
# 设置 Bot API token
BOT_TOKEN="8053333842:AAGuW87kKbZ5Enl3AfezSgwyb0txR-0iTis"
# 设置目标群组的 chat ID
CHAT_ID="-4918534407"
# 要发送的消息内容
MESSAGE= "test"

# 使用 curl 发送消息
curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
