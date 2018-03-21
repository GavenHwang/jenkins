#!/usr/bin/env bash
## 设置要升级的应用栈的名称，以及镜像名称
name=1mabc
image=dockerhub.hand-china.com/rdc1mabc/1mabc:huawei
dockerImage=docker:${image}
## 设置rancher的参数
CATTLE_ACCESS_KEY=*******************
CATTLE_SECRET_KEY=**********************************
RANCHER_API_URL=http://122.112.226.241:8080/v2-beta/
environment=1a5

## 获得rancher应用栈中所有符合条件的应用id
function get_serviceIds() {
    str_serviceIds=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
        -X GET \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        "${RANCHER_API_URL}/projects/${environment}/services?limit=-1&sort=name&name=${name}" | jq '.data[].id'`
	echo "*******************serviceIds: "${str_serviceIds}"*******************"
}
## 添加升级后台升级emabc_base参数
function add_parameters(){
	origin_command=${1}
	#echo ${origin_command}
	parameters=`expr "${origin_command}" : '.*\([-][d].*[-][u]\).*'`
	if [[ ${parameters} == "" ]]
	then
		param1=`expr "${origin_command}" : '.*\([1][m][a][b][c][-][s][e][r][v][e][r][-].*[.][c][o][n][f]\).*'`
		# 去掉.conf 后缀
		command1=${param1%.*}
		# 截取最后一个'-'后的字符串,并拼接升级参数
		command2=", \"-d\", \"${command1##*-}\", \"-u\", \"emabc_base,emabc_theme\" ]"
		upgrade_command=${origin_command/]/${command2}}
		echo "************** "${upgrade_command}" ****************"
	else
		upgrade_command=${origin_command}
		echo "************** "${upgrade_command}" ******************"
	fi
}
## 移除后台升级emabc_base的参数
function remove_parameters(){
	origin_command=${1}
	echo ${origin_command}
	parameters=`expr "${origin_command}" : '.*\([-][d].*[-][u]\).*'`
	if [[ ${parameters} != "" ]]
	then
		com1=${origin_command%%\"-d\"*}
		upgrade_command=${com1%,*}" ]"
		echo "************ "${upgrade_command}" ******************"
	else
		upgrade_command=${origin_command}
		echo "************ "${upgrade_command}" *******************"
	fi
}
## 升级应用
function upgrade_service() {
    local data=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
        -X GET \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        "${RANCHER_API_URL}/projects/${environment}/services/${1}/"`
	local inServiceStrategy=`echo ${data} | jq '.upgrade.inServiceStrategy'`
	command=`echo ${inServiceStrategy} | jq ".launchConfig.command"`
	local imageUuid=`echo ${inServiceStrategy} | jq '.launchConfig.imageUuid'`
	echo "****************serviceID: "${1}" & imageUuid: "${imageUuid}"****************"
	if [[ \"${dockerImage}\" == ${imageUuid} ]]
	then
		## 调用添加升级参数方法
		add_parameters "${command}";
		inServiceStrategy=`echo ${inServiceStrategy} | jq ".launchConfig.command=${upgrade_command}"`
		echo "inServiceStrategy "${inServiceStrategy}
		echo "sending update ${serviceName} request"
		curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
			-X POST \
			-H 'Accept: application/json' \
			-H 'Content-Type: application/json' \
			-d "{
			  \"inServiceStrategy\": ${inServiceStrategy}
			  }
			}" \
			"${RANCHER_API_URL}/projects/${environment}/services/${1}/?action=upgrade"
	fi
}
## 完成升级
function finish_upgrade() {
    echo "waiting for ${serviceName} service to upgrade "
  	while true; do
      local serviceState=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
          -X GET \
          -H 'Accept: application/json' \
          -H 'Content-Type: application/json' \
          "${RANCHER_API_URL}/projects/${environment}/services/${1}/" | jq '.state'`

      case $serviceState in
          "\"upgraded\"" )
              echo "completing ${serviceName} service upgrade"
              curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
                -X POST \
                -H 'Accept: application/json' \
                -H 'Content-Type: application/json' \
                -d '{}' \
                "${RANCHER_API_URL}/projects/${environment}/services/${1}/?action=finishupgrade"
              break ;;
          "\"upgrading\"" )
              echo -n "."
              sleep 3
              continue ;;
          *)
	          echo "unexpected upgrade state: $serviceState"
			  break;;
      esac
  	done
}
## 将获得的所有应用的id字符串转为数组，然后遍历升级
function for_update(){
	array_serviceIds=(${str_serviceIds// /})
	for ((i=0;i<${#array_serviceIds[@]};i++)) do
		id=${array_serviceIds[i]}
		#去掉开头和结尾的双引号
		id=${id#*\"}
		id=${id%\"*}
		#echo ${id}
		# 调用升级方法
		upgrade_service ${id};
		# 调用完成升级方法
		finish_upgrade ${id};
	done;
}
## 调用获得所有应用id的方法
get_serviceIds;
## 调用字符转数组并且遍历升级方法
for_update;
