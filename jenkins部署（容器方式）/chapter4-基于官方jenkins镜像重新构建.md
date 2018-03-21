## 基于官方jenkins镜像重新构建

为了让脚本能直接在容器中执行，而不是远程连接宿主服务器再执行，需要基于官方的jenkins镜像稍作修改。

Dockerfile文件内容如下：

###### `FROM jenkins:latest`

###### ``

###### `USER root`

###### `ARG DOCKER_GID=994`

###### `RUN set -x \`

###### `	## 清除基础镜像设置的源，切换成阿里云的jessie源`

###### `	&& echo '' > /etc/apt/sources.list.d/jessie-backports.list \`

###### `	&& echo "deb http://mirrors.aliyun.com/debian jessie main contrib non-free" > /etc/apt/sources.list \`

###### `	&& echo "deb http://mirrors.aliyun.com/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list \`

###### `	&& echo "deb http://mirrors.aliyun.com/debian-security jessie/updates main contrib non-free" >> /etc/apt/sources.list \`

###### `	#更新源并安装缺少的包`

###### `	&& apt-get update && apt-get install -y libltdl7 jq vim \`

###### `	&& rm -rf /var/lib/apt/lists/* \`

###### `	## 下载安装DockerCLI`

###### `	## && curl -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \`

###### `	## && tar -zxvf docker-latest.tgz \`

###### `	## && cp docker/docker /usr/local/bin/ \`

###### `	## && rm -rf docker docker-latest.tgz \`

###### `	## 将jenkins用户加入到docker组里`

###### `	&& echo "docker:x:${DOCKER_GID}:jenkins" >> /etc/group \`

###### `USER jenkins`

另外jenkins容器的时区与本地时区也不一致，需做如下修改：  
![](/assets/26.png)



