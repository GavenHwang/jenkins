#!/usr/bin/env bash
path=/var/jenkins_home/1mabc/1mabc_dockerfile_hw
tag=huawei
image=dockerhub.hand-china.com/rdc1mabc/1mabc
# 备份镜像
function backup_image(){
	if [[ $(docker images ${image}:${tag} --format "{{.Repository}}") ]]
	then 
		mkdir -p /var/lib/docker/backupImages/rdc1mabc/1mabc/${tag}/"`date '+%Y%m%d'`"
		docker save ${image}:${tag} > /var/lib/docker/backupImages/rdc1mabc/1mabc/${tag}/"`date '+%Y%m%d'`"/1mabc:${tag}"`date '+%Y%m%d%H%M%S'`".tar
		echo 'backup to /var/lib/docker/backupImages/rdc1mabc/1mabc/'${tag}'/'"`date '+%Y%m%d'`"'/1mabc:'${tag}"`date '+%Y%m%d%H%M%S'`"'.tar'
	fi	
}
# 删除同仓库名的镜像
function del_images(){
	if [[ $(docker images ${image} --format "{{.Repository}}") ]]
	then
		docker rmi $(docker images ${image} --format "{{.Repository}}:{{.Tag}}")
	fi
}
# 构建镜像
function build_image(){
	docker images
	docker build -t ${image}:${tag} ${path}
	docker images
}
# 推送镜像
function push_image(){
	docker push ${image}:${tag}
}
#echo '************************************'
#echo '*********** backup image... ********'
#echo '************************************'
#backup_image
echo '************************************'
echo '*********** delete image... ********'
echo '************************************'
del_images
echo '************************************'
echo '*********** build image... *********'
echo '************************************'
build_image
echo '************************************'
echo '*********** push image... **********'
echo '************************************'
push_image
