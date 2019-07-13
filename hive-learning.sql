--新建一个数据库
create database if not exists db_user_info;
--选择数据库
use db_user_info;
--查看数据库列表
show databases;
--描述数据库
describe database db_user_info;
--在数据库中创建表
create table if not exists userinfo
(userid int,
username string,
cityid int,
createtime date)
row format delimited fields terminated by '\t'
stored as textfile;
--显示数据库中的表
show tables;


