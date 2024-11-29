#!/bin/bash

  local workedir="${installpath}/nezha"
  if [ ! -e "${workedir}" ]; then
     mkdir -p "${workedir}"
  fi
   cd ${workedir}
   if [[ ! -e nezha-agent ]]; then
    echo "正在下载哪吒探针..."
    local url="https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_freebsd_amd64.zip"
    agentZip="nezha-agent.zip"
    if ! wget -qO "$agentZip" "$url"; then
        red "下载哪吒探针失败"
        return 1
    fi
    unzip $agentZip  > /dev/null 2>&1 
    chmod +x ./nezha-agent
    green "下载完毕"
  fi
  
  local config="nezha.json"
  local input="y"
  if [[ -e "$config" ]]; then
    echo "哪吒探针配置如下:"
    cat "$config"
    read -p "是否修改？ [y/n] [n]:" input
    input=${input:-n}
  fi
  
  if [[ "$input" == "y" ]]; then
    read -p "请输入哪吒面板的域名或ip:" nezha_domain
    read -p "请输入哪吒面板RPC端口(默认 5555):" nezha_port
    nezha_port=${nezha_port:-5555}
    read -p "请输入服务器密钥(从哪吒面板中获取):" nezha_pwd
    read -p "是否启用针对 gRPC 端口的 SSL/TLS加密 (--tls)，需要请按 [y]，默认是不需要，不理解用户可回车跳过: " tls
    tls=${tls:-"N"}
  else
    nezha_domain=$(jq -r ".nezha_domain" $config)
    nezha_port=$(jq -r ".nezha_port" $config)
    nezha_pwd=$(jq -r ".nezha_pwd" $config)
    tls=$(jq -r ".tls" $config)
  fi

  if [[ -z "$nezha_domain" || -z "$nezha_port" || -z "$nezha_pwd" ]]; then
      red "以上参数都不能为空！"
      return 1
  fi

    cat > $config <<EOF
    {
      "nezha_domain": "$nezha_domain",
      "nezha_port": "$nezha_port",
      "nezha_pwd": "$nezha_pwd",
      "tls": "$tls"
    }
EOF

  local args="--report-delay 4 --disable-auto-update --disable-force-update "
  if [[ "$tls" == "y" ]]; then
     args="${args} --tls "
  fi

  if checknezhaAgentAlive; then
      stopNeZhaAgent
  fi

  nohup ./nezha-agent ${args} -s "${nezha_domain}:${nezha_port}" -p "${nezha_pwd}" >/dev/null 2>&1 &
  green "哪吒探针成功启动!"
