#!/usr/bin/env bash
# 文件名: auto_append.sh
# 描述: 每隔30秒在 README.md 最后写入从 ./ieltsWords.txt 随机抽取的一行。
#       抽取过程中不重复，直到文本文件中的所有行被用完后才会重新打乱并开始重复。
set -euo pipefail

WORDS_FILE="./ieltsWords.txt"
REMAIN_FILE="./.remaining_ielts_words"
OUTPUT_FILE="./README.md"
SLEEP_SECONDS=10

# 检查词库文件
if [ ! -f "$WORDS_FILE" ]; then
    echo "错误: 词库文件未找到: $WORDS_FILE" >&2
    exit 1
fi

# 读取所有非空行到数组 words 中
mapfile -t words < <(grep -v '^[[:space:]]*$' "$WORDS_FILE" || true)
if [ "${#words[@]}" -eq 0 ]; then
    echo "错误: $WORDS_FILE 中没有可用的行。" >&2
    exit 1
fi

# 当剩余文件不存在或为空时，生成一个打乱后的剩余列表
refill_remaining() {
    remaining=("${words[@]}")
    # Fisher-Yates 洗牌
    for ((i=${#remaining[@]}-1; i>0; i--)); do
        j=$((RANDOM % (i + 1)))
        tmp="${remaining[i]}"
        remaining[i]="${remaining[j]}"
        remaining[j]="$tmp"
    done
    printf "%s\n" "${remaining[@]}" > "${REMAIN_FILE}.tmp"
    mv "${REMAIN_FILE}.tmp" "$REMAIN_FILE"
}

if [ ! -s "$REMAIN_FILE" ]; then
    refill_remaining
fi

trap 'echo "已终止."; exit 0' INT TERM

# 主循环：每隔 $SLEEP_SECONDS 秒取出一个词追加到 README.md
while true; do
    mapfile -t remaining < "$REMAIN_FILE"

    if [ "${#remaining[@]}" -eq 0 ]; then
        refill_remaining
        mapfile -t remaining < "$REMAIN_FILE"
    fi

    # 取第一项并从剩余列表中删除
    word="${remaining[0]}"
    remaining=("${remaining[@]:1}")

    # 原子更新剩余文件
    printf "%s\n" "${remaining[@]}" > "${REMAIN_FILE}.tmp" && mv "${REMAIN_FILE}.tmp" "$REMAIN_FILE"

    # 追加到 README.md（每次新起一行）
    printf '%s\n' "$word" >> "$OUTPUT_FILE"
    echo "已在 $OUTPUT_FILE 写入: '$word'"

    sleep "$SLEEP_SECONDS"
done
