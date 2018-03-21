# 使用容器方式启动jenkins

* 安装docker：

`curl https://releases.rancher.com/install-docker/17.06.sh | sh`

* 安装docker-compose：

`yum install docker-compose`

* 配置docker-compose.yml文件：

`version: '2'`

`services:`

`db:`

`image: mysql:5.7`

`ports:`

`- "3306:3306"`

`volumes:`

`- rancher_db_data:/var/lib/mysql`

`environment:`

`- MYSQL_DATABASE=rancherdb`

`- MYSQL_USER=rancher777`

`- MYSQL_PASSWORD=rancher777`

`- MYSQL_ROOT_PASSWORD=root777`

`restart: always`

`rancher:`

`image: rancher/server:stable`

`ports:`

`- "8080:8080"`

`environment:`

`- CATTLE_DB_CATTLE_MYSQL_HOST=db`

`- CATTLE_DB_CATTLE_MYSQL_PORT=3306`

`- CATTLE_DB_CATTLE_MYSQL_NAME=rancherdb`

`- CATTLE_DB_CATTLE_USERNAME=rancher777`

`- CATTLE_DB_CATTLE_PASSWORD=rancher777`

`restart: always`

`depends_on:`

`- db`

`volumes:`

`rancher_db_data:`

* 启动rancher\(在docker-compose.yml文件目录下执行下面的命令\)：

`docker-compose up -d`

浏览器访问: [http:// + ](http://yourIp)你的IP + :8080

* 第一次启动rancher要配置本地账户、添加账号API Key：：![](/assets/01.png)![](/assets/02.png)![](/assets/03.png)![](/assets/04.png)![](/assets/05.png)

       账号API Key 一定要保存下来，只显示一次！！！

* 添加主机![](/assets/06.png)![](/assets/07.png)![](/assets/08.png)

把生成的注册脚本到需要添加的主机上执行，之后在主机页面就可以看到添加的主机了。

* 添加jenkins应用栈：![](/assets/09.png)![](/assets/10.png)

在该应用栈添加服务：![](/assets/11.png)![](/assets/12.png)![](/assets/13.png)

* 进入jenkins主页

浏览器访问[http://](http://yourIp)+ 你的IP + :8888

首次进入jenkins会提示密码位置，按照提示进入jenkins容器，点击执行命令行查看密码后输入即可进入jenkins![](/assets/14.png)![](/assets/15.png)![](/assets/16.png)

