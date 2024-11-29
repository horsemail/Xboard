#!/bin/bash

# 检查是否提供了参数
if [ $# -ne 3 ]; then
    echo "用法: $0 <域名> <端口> <密钥>"
    exit 1
fi

DOMAIN=$1
PORT=$2
KEY=$3

# 下载链接
AGENT_URL="https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_freebsd_amd64.zip

# 创建安装目录
INSTALL_DIR=$(pwd)/nezha
mkdir -p $INSTALL_DIR

# 下载 nezha_agent
AGENT_ZIP="$INSTALL_DIR/nezha-agent.zip"
echo "正在下载 nezha_agent ($ARCH)..."
curl -L $AGENT_URL -o $AGENT_ZIP

# 解压 nezha_agent
echo "正在解压 nezha_agent..."
unzip -o $AGENT_ZIP -d $INSTALL_DIR
chmod +x $INSTALL_DIR/nezha-agent

# 启动 nezha_agent
echo "正在启动 nezha_agent..."
$INSTALL_DIR/nezha-agent -s $DOMAIN:$PORT -p $KEY &

if [ $? -eq 0 ]; then
    echo "哪吒探针已成功安装并运行！"
else
    echo "哪吒探针启动失败，请检查日志！"
fi
