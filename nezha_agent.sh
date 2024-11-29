#!/bin/bash

# 检查是否提供了参数
if [ $# -ne 3 ]; then
    echo "用法: $0 <域名> <端口> <密钥>"
    exit 1
fi

# 获取命令行参数
nezha_domain=$1
nezha_port=$2
nezha_pwd=$3
tls="n"  # 默认不启用 TLS，如果需要可以手动启用

# 安装路径
installpath=$(pwd)
workedir="${installpath}/nezha"

# 创建工作目录
if [ ! -e "${workedir}" ]; then
    mkdir -p "${workedir}"
fi
cd "${workedir}"

# 下载哪吒探针
if [[ ! -e nezha-agent ]]; then
    echo "正在下载哪吒探针..."
    url="https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_freebsd_amd64.zip"  # 修改为适合系统架构的 URL
    agentZip="nezha-agent.zip"
    if ! wget -qO "$agentZip" "$url"; then
        echo -e "\033[31m下载哪吒探针失败\033[0m"  # 红色提示
        exit 1
    fi
    unzip $agentZip >/dev/null 2>&1
    chmod +x ./nezha-agent
    echo -e "\033[32m下载完毕\033[0m"  # 绿色提示
fi

# 配置文件生成
config="nezha.json"
cat > $config <<EOF
{
  "nezha_domain": "$nezha_domain",
  "nezha_port": "$nezha_port",
  "nezha_pwd": "$nezha_pwd",
  "tls": "$tls"
}
EOF

# 参数拼接
args="--report-delay 4 --disable-auto-update --disable-force-update"
if [[ "$tls" == "y" ]]; then
    args="${args} --tls"
fi

# 检查探针是否已运行，若运行则停止
checknezhaAgentAlive() {
    pgrep -f "nezha-agent" >/dev/null 2>&1
}

stopNeZhaAgent() {
    pkill -f "nezha-agent" >/dev/null 2>&1
}

if checknezhaAgentAlive; then
    stopNeZhaAgent
fi

# 启动哪吒探针
nohup ./nezha-agent ${args} -s "${nezha_domain}:${nezha_port}" -p "${nezha_pwd}" >/dev/null 2>&1 &
if [[ $? -eq 0 ]]; then
    echo -e "\033[32m哪吒探针成功启动!\033[0m"
else
    echo -e "\033[31m哪吒探针启动失败，请检查日志！\033[0m"
    exit 1
fi
