FROM jenkins:latest

USER root
ARG DOCKER_GID=994
RUN set -x \
	## 清除基础镜像设置的源，切换成阿里云的jessie源
	&& echo '' > /etc/apt/sources.list.d/jessie-backports.list \
	&& echo "deb http://mirrors.aliyun.com/debian jessie main contrib non-free" > /etc/apt/sources.list \
	&& echo "deb http://mirrors.aliyun.com/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list \
	&& echo "deb http://mirrors.aliyun.com/debian-security jessie/updates main contrib non-free" >> /etc/apt/sources.list \
	#更新源并安装缺少的包
	&& apt-get update && apt-get install -y libltdl7 jq vim \
	&& rm -rf /var/lib/apt/lists/* \
	## 下载安装DockerCLI
	## && curl -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
	## && tar -zxvf docker-latest.tgz \
	## && cp docker/docker /usr/local/bin/ \
	## && rm -rf docker docker-latest.tgz \
	## 将jenkins用户加入到docker组里
	&& echo "docker:x:${DOCKER_GID}:jenkins" >> /etc/group \
USER jenkins
