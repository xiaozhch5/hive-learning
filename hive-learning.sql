/***************************************
 * hive基本操作方法
 * 
 * @author zhchxiao
 * @date 2019/7/13
 ***************************************/


--新建一个数据库
create database if not exists db_user_info;

--选择数据库
use db_user_info;

--查看数据库列表
show databases;

--描述数据库
describe database db_user_info;

/*
 * 在数据库中创建表的几种方式
 * create table
 * create table as select
 * create table like tablename1
 * 创建外部表
 * create external table
 * 创建分区表
 * 创建桶表
 */
create table if not exists userinfo
(userid int,
username string,
cityid int,
createtime date)
row format delimited fields terminated by '\t'
stored as textfile;

--显示数据库中的表
show tables;

--查看表简单定义
describe userinfo;

--查看表详细信息
describe formatted userinfo;

--修改表名
alter table userinfo rename to user_info;

--添加字段
alter table user_info add columns (provinceid int);

--修改字段
alter table user_info replace columns
(userid int,
username string,
cityid int,
joindata date,
provinceid int);

--删除表
drop table if exists user_info;


