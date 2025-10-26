#!/usr/bin/env bash
# 文件名: auto_append.sh
# 描述: 随机从 ieltsWords.txt 的第 X 行读取单词（行号从 1 开始），
#       如果该行为空或包含 "Word List" 则跳过并重新随机（不记录该行号）；
#       否则把该行追加到 README.md，并把 X 以 append 形式写入已用行号文件，
#       随机选择时避免出现已用行号，直到所有可用单词被用过一次后清空已用记录重新开始。
set -euo pipefail

WORDS_FILE="./ieltsWords.txt"
USED_INDEX_FILE="./.used_line_indices"   # 持久化保存已用的行号（1-based），每次写入 append
OUTPUT_FILE="./README.md"
SLEEP_SECONDS=1

# 检查词库文件
if [ ! -f "$WORDS_FILE" ]; then
    echo "错误: 词库文件未找到: $WORDS_FILE" >&2
    exit 1
fi

# 读取所有行（保留空行位置以便行号一致），并去掉可能的 Windows CR
mapfile -t lines < <(sed 's/\r$//' "$WORDS_FILE")

total_lines=${#lines[@]}
if [ "$total_lines" -eq 0 ]; then
    echo "错误: $WORDS_FILE 是空文件。" >&2
    exit 1
fi

# 如果 USED_INDEX_FILE 不存在，创建空文件（便于读取）
touch "$USED_INDEX_FILE"

trap 'echo "已终止."; exit 0' INT TERM

# 辅助：判断行是否为“可用单词”（非空且不含 "Word List"）
is_valid_line() {
    local s="$1"
    # 去首尾空白再判断
    s="$(printf '%s' "$s" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    if [ -z "$s" ]; then
        return 1
    fi
    # 包含 "Word List"（不区分大小写）则视为无效
    if printf '%s' "$s" | grep -qi 'word list'; then
        return 1
    fi
    return 0
}

# 读取已用行号到关联数组 used[]
read_used_indices() {
    unset used
    declare -gA used=()
    if [ -f "$USED_INDEX_FILE" ]; then
        while IFS= read -r ln || [ -n "$ln" ]; do
            # 忽略空行/非数字
            if printf '%s' "$ln" | grep -qE '^[0-9]+$'; then
                used["$ln"]=1
            fi
        done < "$USED_INDEX_FILE"
    fi
}

# 计算总的有效行数（文件中本身就是有效的，不受已用影响）
count_total_valid_lines() {
    local cnt=0
    for ((i=1;i<=total_lines;i++)); do
        if is_valid_line "${lines[i-1]}"; then
            cnt=$((cnt+1))
        fi
    done
    echo "$cnt"
}

# 从 candidates 数组中随机挑一个元素（返回到 global sel_index）
select_random_from_array() {
    local -n arr=$1
    if [ "${#arr[@]}" -eq 0 ]; then
        sel_index=""
        return 1
    fi
    local rnd=$((RANDOM % ${#arr[@]}))
    sel_index="${arr[$rnd]}"
    return 0
}

echo "脚本启动: WORDS_FILE=$WORDS_FILE, total_lines=$total_lines, USED_INDEX_FILE=$USED_INDEX_FILE"

# 主循环
while true; do
    # 读已用
    read_used_indices

    # 构造当前可选的（未使用且有效）行号列表
    candidates=()
    for ((i=1;i<=total_lines;i++)); do
        if [ -n "${used[$i]:-}" ]; then
            continue
        fi
        if is_valid_line "${lines[i-1]}"; then
            candidates+=("$i")
        fi
    done

    # 计算文件中总的有效行数（用于判断是否所有都已用完）
    total_valid="$(count_total_valid_lines)"
    if [ "$total_valid" -eq 0 ]; then
        echo "错误: $WORDS_FILE 中没有任何有效单词（全部为空或包含 'Word List'）。" >&2
        exit 1
    fi

    # 如果当前候选为空，说明所有有效行都已用完（或之前的 USED 文件包含了所有有效行），需要清空 USED 并重新计算
    if [ "${#candidates[@]}" -eq 0 ]; then
        echo "信息: 所有可用单词已被读取过一次，清空已用行号并重新开始循环。"
        rm -f "$USED_INDEX_FILE"
        touch "$USED_INDEX_FILE"
        read_used_indices
        # 重新构建候选
        candidates=()
        for ((i=1;i<=total_lines;i++)); do
            if [ -n "${used[$i]:-}" ]; then
                continue
            fi
            if is_valid_line "${lines[i-1]}"; then
                candidates+=("$i")
            fi
        done
    fi

    # 随机选一个候选行号
    select_random_from_array candidates
    if [ -z "${sel_index:-}" ]; then
        # 极少数情况下如果还是为空，短暂休眠后重试
        echo "警告: 未能选到候选行号，稍后重试..." >&2
        sleep 1
        continue
    fi

    # 取得对应的行内容并进行修剪
    raw_word="${lines[sel_index-1]}"
    word="$(printf '%s' "$raw_word" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    # 再次确认有效性（防止 race 或异常）
    if ! is_valid_line "$word"; then
        echo "注意: 随机选到的行 $sel_index 实际被判为无效，跳过（不记录为已用）" >&2
        # 从候选中移除该 sel_index，再循环一次（不记录为已用）
        # 简单方式：将候选列表中过滤 sel_index，然后 continue
        newc=()
        for v in "${candidates[@]}"; do
            [ "$v" -eq "$sel_index" ] && continue
            newc+=("$v")
        done
        candidates=("${newc[@]}")
        # 如果 candidates 为空，会在上层循环中被处理
        continue
    fi

    # 将行追加到 README（每次新起一行）
    printf '%s\n' "$word" >> "$OUTPUT_FILE"
    echo "已在 $OUTPUT_FILE 写入: (行 $sel_index) '$word'"

    # 把行号追加到已用文件（持久化），使用 append
    printf '%s\n' "$sel_index" >> "$USED_INDEX_FILE"

    # 睡眠
    sleep "$SLEEP_SECONDS"
done
