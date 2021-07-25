#!/bin/bash

clear
echo "本脚本仅适用于Ubuntu20.04"
#安装Nginx
InstallNginx(){
echo "正在更新源..."
apt update >/dev/null 2>&1
echo "更新完成!"
echo "正在安装依赖"
apt install gcc libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev  wget -y >/dev/null 2>&1
echo "安装完成!"
cd /usr/local
mkdir nginx
cd nginx

echo "正在从http://nginx.org下载nginx-1.21.1.tar.gz"
wget http://nginx.org/download/nginx-1.21.1.tar.gz >/dev/null 2>&1
echo "下载完成!"

echo "正在解压nginx-1.21.1.tar.gz"
tar -zxvf nginx-1.21.1.tar.gz >/dev/null 2>&1

echo "解压完成"
cd nginx-1.21.1 

echo "正在创建nginx用户组"
groupadd nginx
useradd nginx -g nginx -s /sbin/nologin -M
echo "创建nginx用户组完成"


echo "正在预编译nginx"
`./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-http_gzip_static_module` >/dev/null 2>&1 
echo "预编译nginx完成"

echo "正在编译安装nginx"
make >/dev/null 2>&1
make install >/dev/null 2>&1
echo "编译安装nginx完成"

echo "增加执行权限"
chmod +x /usr/local/nginx/sbin/nginx
echo "增加执行权限完成"
echo "在/bin目录下软链接nginx"
ln -s /usr/local/nginx/sbin/nginx /bin/nginx

echo "创建服务文件"
echo "[Unit]
Description=nginx - high performance web server

After=network.target remote-fs.target nss-lookup.target

[Service]

Type=forking

ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

ExecReload=/usr/local/nginx/sbin/nginx -s reload

ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]

WantedBy=multi-user.target

" > /usr/lib/systemd/system/nginx.service

echo "启动nginx"
systemctl start nginx.service >/dev/null 2>&1
echo "开机启动nginx.service"
systemctl enable nginx.service >/dev/null 2>&1
echo "将网站根目录软连接到家目录下"
ln -s /usr/local/nginx/html ~/www
ln -s /usr/local/nginx/conf ~/nginx_conf
}
InstallMysql(){
echo "正在更新源..."
apt update >/dev/null 2>&1
echo "更新完成!"
echo "正在安装依赖"

#安装依赖
apt install numactl libaio-dev openssl -y >/dev/null 2>&1

 
echo "安装完成!"
echo "正在解压mysql安装包"
xz -d ./mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz >/dev/null 2>&1

tar -xvf ./mysql-8.0.17-linux-glibc2.12-x86_64.tar >/dev/null 2>&1
echo "解压完成!"


mv mysql-8.0.17-linux-glibc2.12-x86_64 /usr/local/mysql

echo "添加用户组"
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
echo "添加成功"
cd /usr/local/mysql

mkdir mysql-files
chown mysql:mysql mysql-files
chmod 750 mysql-files
echo "=============================================================================="
echo "初始化mysql"
bin/mysqld --initialize --user=mysql
echo "初始化完成"
echo "=============================================================================="


bin/mysql_ssl_rsa_setup


cp support-files/mysql.server /etc/init.d/mysql.server

bin/mysqld_safe --user=mysql &
ln -s /usr/local/mysql ~/mysql
#登录到mysql命令     ~/mysql/bin/mysql -uroot -p

}
Installphp(){
echo "正在更新源..."
apt update >/dev/null 2>&1
echo "更新完成!"


}

MysqlConfig(){
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '密码' PASSWORD EXPIRE NEVER;    #修改root的密码与加密方式
use mysql;   #切换到mysql库
update user set host='%' where user = 'root';   #更改可以登录的IP为任意IP
flush privileges;    #刷新权限
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '密码'; #再次更改root用户密码，使其可以在任意IP访问
flush privileges;    #刷新权限
"


}



#菜单
menu(){
clear
echo "本脚本仅适用于Ubuntu20.04"
echo "1.安装Nginx"
echo "2.安装Mysql"
echo "3.安装php"
echo "4.一键安装LNMP"
echo "5.mysql修改密码语句"
echo "0.退出"
echo -n "请选择以上的选项:";read number
if [ ${number} == "1" ];then
	echo "安装Nginx"
	InstallNginx
	echo -n "安装完成!按任意键继续...";read
	menu
elif [ ${number} == "2" ];then
	echo "安装Mysql"
	InstallMysql
elif [ ${number} == "3" ];then
	echo "安装php"
	echo -n "安装完成!按任意键继续...";read
	menu
elif [ ${number} == "4" ];then
	echo "一键安装LNMP"
	echo -n "安装完成!按任意键继续...";read
elif [ ${number} == "5" ];then
	echo "mysql修改密码语句"
	MysqlConfig
elif [ ${number} == "0" ];then
	echo "退出"
	exit
else
	echo "输入不合法!"
	echo -n "按任意键继续...";read
	menu
fi
}
menu
