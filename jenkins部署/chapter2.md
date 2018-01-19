# 使用容器方式启动jenkins

* 安装docker：

`curl https://releases.rancher.com/install-docker/17.06.sh | sh`

* 安装docker-compose：

`yum install docker-compose`

* 配置docker-compose.yml文件：

`version: '2'`

`services:`

`  db:`

`    image: mysql:5.7`

`    ports: `

`      - "3306:3306"`

`    volumes: `

`      - rancher_db_data:/var/lib/mysql`

`    environment:`

`      - MYSQL_DATABASE=rancherdb`

`      - MYSQL_USER=rancher777`

`      - MYSQL_PASSWORD=rancher777`

`      - MYSQL_ROOT_PASSWORD=root777`

`    restart: always`

`  rancher:`

`    image: rancher/server:stable`

`    ports:`

`      - "8080:8080"`

`    environment:`

`      - CATTLE_DB_CATTLE_MYSQL_HOST=db`

`      - CATTLE_DB_CATTLE_MYSQL_PORT=3306`

`      - CATTLE_DB_CATTLE_MYSQL_NAME=rancherdb`

`      - CATTLE_DB_CATTLE_USERNAME=rancher777`

`      - CATTLE_DB_CATTLE_PASSWORD=rancher777`

`    restart: always`

`    depends_on:`

`      - db`

`volumes:`

`  rancher_db_data:`

* 启动rancher：

`docker-compose up -d`

浏览器访问: http://yourIp + 8080

* 第一次启动rancher要配置本地账户、添加账号API Key：：

![](E:/systems/YoudaoNote/huangleilei1215@163.com/78f40a49727d4e9f91579b71ab3f7a64/clipboard.png)![](E:/systems/YoudaoNote/huangleilei1215@163.com/971f0c3edc4a4304b597dc1abbe3a2ae/clipboard.png)![](E:/systems/YoudaoNote/huangleilei1215@163.com/cdecdf8ba9684deeb152aa1c5142d3cf/clipboard.png)

![](E:/systems/YoudaoNote/huangleilei1215@163.com/d3e332db8ce54e49978dff6e30ab2681/clipboard.png)![](E:/systems/YoudaoNote/huangleilei1215@163.com/2ddfb005fccd496f96af9dc360bf6bdd/clipboard.png)

账号API Key 一定要保存下来，只显示一次！！！

* 添加主机

![](E:/systems/YoudaoNote/huangleilei1215@163.com/8b965c73ba394cdaa3900eabd90e7c63/clipboard.png)![](E:/systems/YoudaoNote/huangleilei1215@163.com/5f08d7bf4d70436f9b72cd03895b9fa7/clipboard.png)![](E:/systems/YoudaoNote/huangleilei1215@163.com/a7bd9d4bc33b4756914337ba6a37a592/clipboard.png)

把生成的注册脚本到需要添加的主机上执行，之后在主机页面就可以看到添加的主机了。

* 添加jenkins应用栈：![](/assets/import.png)

添加服务：

![](/assets/02.png)![](/assets/03.png)

* 进入jenkins主页

浏览器访问http://yourIp + 8888

首次进入jenkins会提示密码位置，按照提示进入jenkins应用，点击执行命令行查看密码后输入即可进入jenkins 



