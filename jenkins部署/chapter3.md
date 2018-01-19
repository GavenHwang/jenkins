# 项目配置

由于网络原因，我们的gitlab无法访问我的jenkins，所以放弃使用webhook方式来实时触发jenkins部署。替而代之的是每分钟检测一次gitlab的代码是否变更，如果变更就触发jenkins部署。

* 安装GitLab Plugin插件

在jenkins的 系统管理--&gt; 管理插件 下选择可选插件搜索GitLab Plugin安装即可

* 系统设置

在系统管理--&gt;系统设置下找到gitlab配置项：![](/assets/17.png)

Credentials点击add：API token 填写你的gitlab中的token：![](/assets/18.png)![](/assets/19.png)

然后点击Test Connection出现success表示成功.

* 权限设置

在 系统管理 --&gt; Configure Global Security下：![](/assets/20.png)

* 项目配置

新建一个自由风格的软件项目配置如下：![](/assets/21.png)![](/assets/22.png)![](/assets/23.png)![](/assets/24.png)![](/assets/25.png)

两个脚本源码如下：

1.sh用来构建镜像，并推送到镜像仓库

`#!/usr/bin/env bash`

`path=/var/lib/docker/dockerfile/1mabc_dockerfile_master`

`tag=latest`

`image=dockerhub.hand-china.com/rdc1mabc/1mabc`

`# 备份镜像`

`function backup_image(){`

`if [[ $(docker images ${image}:${tag} --format "{{.Repository}}") ]]`

`then`

``mkdir -p /var/lib/docker/backupImages/rdc1mabc/1mabc/${tag}/"`date '+%Y%m%d'`"``

``docker save ${image}:${tag} > /var/lib/docker/backupImages/rdc1mabc/1mabc/${tag}/"`date '+%Y%m%d'`"/1mabc:${tag}"`date '+%Y%m%d%H%M%S'`".tar``

``echo 'backup to /var/lib/docker/backupImages/rdc1mabc/1mabc/'${tag}'/'"`date '+%Y%m%d'`"'/1mabc:'${tag}"`date '+%Y%m%d%H%M%S'`"'.tar'``

`fi`

`}`

`# 删除同仓库名的镜像`

`function del_images(){`

`if [[ $(docker images ${image} --format "{{.Repository}}") ]]`

`then`

`docker rmi $(docker images ${image} --format "{{.Repository}}:{{.Tag}}")`

`fi`

`}`

`# 构建镜像`

`function build_image(){`

`docker images`

`docker build -t ${image}:${tag} ${path}`

`docker images`

`}`

`# 推送镜像`

`function push_image(){`

`docker push ${image}:${tag}`

`}`

`echo '*********************************************************************************************'`

`echo '*********** backup image... *****************************************************************'`

`echo '*********************************************************************************************'`

`backup_image`

`echo '*********************************************************************************************'`

`echo '*********** delete image... *****************************************************************'`

`echo '*********************************************************************************************'`

`del_images`

`echo '*********************************************************************************************'`

`echo '*********** build image... ******************************************************************'`

`echo '*********************************************************************************************'`

`build_image`

`echo '*********************************************************************************************'`

`echo '*********** push image... *******************************************************************'`

`echo '*********************************************************************************************'`

`push_image`

2.sh用来升级rancher中的应用

\#!/usr/bin/env bash

`name=saas`

`image=dockerhub.hand-china.com/rdc1mabc/1mabc:latest`

`dockerImage=docker:${image}`

`CATTLE_ACCESS_KEY=填写你要升级的rancher的ACCESS_KEY`

`CATTLE_SECRET_KEY=填写你要升级的rancher的SECRET_KEY`

`RANCHER_API_URL=http://192.168.11.184:8080/v2-beta/`

`environment=1a5`

`function get_serviceIds() {`

``str_serviceIds=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \``

`-X GET \`

`-H 'Accept: application/json' \`

`-H 'Content-Type: application/json' \`

``"${RANCHER_API_URL}/projects/${environment}/services?limit=-1&sort=name&name=${name}" | jq '.data[].id'` ``

`echo "serviceIds: "${str_serviceIds}`

`}`

`function upgrade_service() {`

``local data=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \``

`-X GET \`

`-H 'Accept: application/json' \`

`-H 'Content-Type: application/json' \`

``"${RANCHER_API_URL}/projects/${environment}/services/${1}/"` ``

``local inServiceStrategy=`echo ${data} | jq '.upgrade.inServiceStrategy'` ``

``local imageUuid=`echo ${inServiceStrategy} | jq '.launchConfig.imageUuid'` ``

`echo "imageUuid: "${imageUuid}`

`if [[ \"${dockerImage}\" == ${imageUuid} ]]`

`then`

`echo "inServiceStrategy "${inServiceStrategy}`

`echo "sending update ${serviceName} request"`

`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \`

`-X POST \`

`-H 'Accept: application/json' \`

`-H 'Content-Type: application/json' \`

`-d "{`

`\"inServiceStrategy\": ${inServiceStrategy}`

`}`

`}" \`

`"${RANCHER_API_URL}/projects/${environment}/services/${1}/?action=upgrade"`

`fi`

`}`

`function finish_upgrade() {`

`echo "waiting for ${serviceName} service to upgrade "`

`while true; do`

``local serviceState=`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \``

`-X GET \`

`-H 'Accept: application/json' \`

`-H 'Content-Type: application/json' \`

``"${RANCHER_API_URL}/projects/${environment}/services/${1}/" | jq '.state'` ``

`  
`

`case $serviceState in`

`"\"upgraded\"" )`

`echo "completing ${serviceName} service upgrade"`

`curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \`

`-X POST \`

`-H 'Accept: application/json' \`

`-H 'Content-Type: application/json' \`

`-d '{}' \`

`"${RANCHER_API_URL}/projects/${environment}/services/${1}/?action=finishupgrade"`

`break ;;`

`"\"upgrading\"" )`

`echo -n "."`

`sleep 3`

`continue ;;`

`*)`

`echo "unexpected upgrade state: $serviceState"`

`break;;`

`esac`

`done`

`}`

`function for_update(){`

`#将字符串转为数组`

`array_serviceIds=(${str_serviceIds// /})`

`for ((i=0;i<${#array_serviceIds[@]};i++)) do`

`id=${array_serviceIds[i]}`

`#去掉开头和结尾的双引号`

`id=${id#*\"}`

`id=${id%\"*}`

`echo ${id}`

`upgrade_service ${id};`

`finish_upgrade ${id};`

`done;`

`}`

`get_serviceIds`

`for_update`

