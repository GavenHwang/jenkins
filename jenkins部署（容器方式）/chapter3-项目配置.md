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

脚本源码见脚本文件夹

