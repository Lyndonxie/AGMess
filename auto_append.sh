#!/usr/bin/env bash
# 文件名: auto_append.sh
# 描述: 随机从 ieltsWords.txt 读取一个有效单词（非空且不含 "Word List"），
#       将其追加到 README.md。脚本会记录已使用的行号，避免重复，
#       直到所有有效单词都被使用过一次后，将清空记录并重新开始。

set -euo pipefail

readonly WORDS_FILE="./ieltsWords.txt"
readonly USED_INDEX_FILE="./.used_line_indices"
readonly OUTPUT_FILE="./README.md"
readonly SLEEP_SECONDS=1

# --- 预处理和初始化 ---

# 检查词库文件是否存在
if [[ ! -f "$WORDS_FILE" ]]; then
    echo "错误: 词库文件未找到: $WORDS_FILE" >&2
    exit 1
fi

# 创建已用行号文件（如果它不存在）
touch "$USED_INDEX_FILE"

# 读取所有行到数组，并去掉可能的 Windows 回车符
mapfile -t lines < <(sed 's/\r$//' "$WORDS_FILE")

if [[ ${#lines[@]} -eq 0 ]]; then
    echo "错误: $WORDS_FILE 是空文件。" >&2
    exit 1
fi

# 一次性找出所有有效的行号 (1-based index)
declare -a all_valid_indices
for i in "${!lines[@]}"; do
    line_content="${lines[$i]}"
    # 使用 Bash 内建功能替换 sed 和 grep，性能更高
    # 1. 去除首尾空格
    shopt -s extglob
    trimmed_line="${line_content##*( )}"
    trimmed_line="${trimmed_line%%*( )}"
    shopt -u extglob
    
    # 2. 判断是否有效
    if [[ -n "$trimmed_line" && "${trimmed_line,,}" != *"word list"* ]]; then
        all_valid_indices+=($((i + 1)))
    fi
done

total_valid_lines=${#all_valid_indices[@]}
if [[ $total_valid_lines -eq 0 ]]; then
    echo "错误: 在 $WORDS_FILE 中没有找到任何有效单词行。" >&2
    exit 1
fi

echo "脚本启动: 找到 $total_valid_lines 个有效单词。"

# --- 主循环 ---

trap 'echo "脚本已终止。"; exit 0' INT TERM

while true; do
    # 读取已用行号到关联数组以便快速查找 O(1)
    declare -A used_indices_map
    while IFS= read -r used_line; do
        [[ -n "$used_line" ]] && used_indices_map["$used_line"]=1
    done < "$USED_INDEX_FILE"

    # 检查是否所有有效单词都已用完
    if [[ ${#used_indices_map[@]} -ge $total_valid_lines ]]; then
        echo "所有单词已使用完毕，重置进度..."
        # 清空已用文件和 map
        > "$USED_INDEX_FILE"
        used_indices_map=()
    fi

    # 从 all_valid_indices 中过滤掉 used_indices_map 中已存在的，得到候选列表
    declare -a candidates=()
    for index in "${all_valid_indices[@]}"; do
        if [[ ! -v used_indices_map[$index] ]]; then
            candidates+=("$index")
        fi
    done

    # 如果没有候选（理论上只在文件被外部修改时发生），则跳过本次循环
    if [[ ${#candidates[@]} -eq 0 ]]; then
        echo "警告: 未找到可用单词，可能是所有单词刚被用完。将在下一轮重置。" >&2
        sleep "$SLEEP_SECONDS"
        continue
    fi
    
    # 从候选数组中随机选择一个
    random_candidate_index=$((RANDOM % ${#candidates[@]}))
    selected_line_number="${candidates[$random_candidate_index]}"
    
    # 获取单词内容并去除首尾空格
    word_line="${lines[$selected_line_number-1]}"
    shopt -s extglob
    trimmed_word="${word_line##*( )}"
    trimmed_word="${trimmed_word%%*( )}"
    shopt -u extglob
    
    # 追加到输出文件和已用文件
    printf '%s\n' "$trimmed_word" >> "$OUTPUT_FILE"
    printf '%s\n' "$selected_line_number" >> "$USED_INDEX_FILE"
    
    echo "已写入 (行 $selected_line_number): '$trimmed_word'"
    
    # 等待
    sleep "$SLEEP_SECONDS"
done
