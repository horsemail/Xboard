#!/bin/bash

# 检查是否提供了参数
if [ $# -ne 3 ]; then
    echo "用法: $0 <域名> <端口> <密钥>"
    exit 1
fi

DOMAIN=$1
PORT=$2
KEY=$3

# 创建 nezha 目录
INSTALL_DIR=$(pwd)/nezha
mkdir -p $INSTALL_DIR

# 下载 nezha_agent
AGENT_URL="https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip"
AGENT_ZIP="$INSTALL_DIR/nezha-agent_linux_amd64.zip"

echo "正在下载 nezha_agent..."
curl -L $AGENT_URL -o $AGENT_ZIP

# 解压 nezha_agent
echo "正在解压 nezha_agent..."
unzip -o $AGENT_ZIP -d $INSTALL_DIR
chmod +x $INSTALL_DIR/nezha-agent

# 启动 nezha_agent
echo "正在启动 nezha_agent..."
$INSTALL_DIR/nezha-agent -s $DOMAIN:$PORT -p $KEY &

echo "哪吒探针已安装并运行！"