#!/bin/bash
# 文件名: auto_append.sh
# 描述: 每隔30秒在readme.md最后写入'test'

FILE="README.md"

while true; do
    # 使用 vim 命令行模式编辑文件
    vim -E -s $FILE <<-EOF
        " 跳转到文件末尾
        \$

        " 在最后一行下添加一行
        put =\"test\"

        " 保存并退出
        wq
EOF

    echo "已在 $FILE 写入 'test'"
    # 暂停30秒
    sleep 30
done
