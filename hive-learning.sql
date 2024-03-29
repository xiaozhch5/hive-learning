/***************************************
 * hive基本操作方法
 * warming:
 * Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. 
 * Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
 * hive-on-MR真的好慢啊（小声bb）
 * @author zhchxiao
 * @date 2019/7/13
 ***************************************/

-------------------------------------------------------------------------------------------
---------------------------------------数据库操作-------------------------------------------
-------------------------------------------------------------------------------------------

--新建一个数据库
create database if not exists db_user_info;

--给数据库添加描述信息
create database if not exists db_user_info comment 'hold all user info';

--选择数据库
use db_user_info;

--查看数据库列表
show databases;

--描述数据库
describe database db_user_info;

--删除数据库
drop database db_user_info;

-------------------------------------------------------------------------------------------
-----------------------------------------表操作---------------------------------------------
-------------------------------------------------------------------------------------------
/*
 * 在数据库中创建表的几种方式
 * create table
 * create table as select
 * create table like tablename1
 * 创建外部表
 * create external table
 * 外部表特性：当删除该表时候并不会删除掉这份数据，不过描述表的元数据信息会被删除掉
 * 创建分区表
 * 创建桶表
 */
 --创建普通表
create table if not exists userinfo
(userid int,
username string,
cityid int,
createtime date)
row format delimited fields terminated by '\t'
stored as textfile;

--创建分区表
---创建经销商操作日志表
---这个例子中，这个日志表以dt字段分区，dt是个虚拟的字段，
---dt下并不存储数据，而是用来分区的，实际数据存储时，
---dt字段值相同的数据存入同一个子目录中，插入数据或者导入数据时，
---同一天的数据dt字段赋值一样，这样就实现了数据按dt日期分区存储。
create table user_action_log
(
companyId INT comment   '公司ID',
userid INT comment   '销售ID',
originalstring STRING comment   'url', 
host STRING comment   'host',
absolutepath STRING comment   '绝对路径',
query STRING comment   '参数串',
refurl STRING comment   '来源url',
clientip STRING comment   '客户端Ip',
cookiemd5 STRING comment   'cookiemd5',
timestamp STRING comment   '访问时间戳'
)
partitioned by (dt string)
row format delimited fields terminated by ','
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

-------------------------------------------------------------------------------------------
-------------------------------------表中数据加载操作---------------------------------------
-------------------------------------------------------------------------------------------

--向hive中加载数据（在原始创建的表中加载数据，即userinfo表）
/*
 *新建一个userinfo.txt文件，文件内容如下(行内用'\t'分隔)
1	zhangsan	111	2019-04-11
2	lisi	112	2019-04-12
3	wangwu	113	2019-04-13
4	zhaoliu	113	2019-04-14
*/
---将本地文本文件内容批量加载带hive中，要求文本文件中的格式和hive表中的定义一致，
---包括字段个数、字段顺序、列分隔符都要一致
---local表示数据源文件在本地，如果数据源在hdfs上则去掉local，文件路径用'hdfs://namenode:9000/'表示
---overwrite表示如果hive中存在数据，则会覆盖掉原有的数据，如果省略则表示追加
load data local inpath '/home/vadmin/user_info_data.txt' overwrite into table userinfo;

--加载到分区表
load data local inpath '/home/vadmin/user_info_data.txt' overwrite into table userinfo partition (dt='2019-05-05');

--加载到分桶表
---数据载入临时表
load data local inpath '/home/vadmin/user_info_data.txt' overwrite into table userinfo;
---导入分桶表
---set hive.enforce.bucketing = true; 这个配置非常关键，为true就是设置为启用分桶。
set hive.enforce.bucketing = true;
insert overwrite table user_lead_info select * from userinfo;

--从hive导出数据
---去掉local可导出到hdfs
insert overwrite local directory '/home/vadmin/user_info.bak2019-5-5' select * from userinfo;

--插入数据到hive中
insert overwrite table user_leads select * from  user_leads_tmp;
---插入到指定分区中
insert overwrite table user_leads PARTITION (dt='2017-05-26') select * from user_leads_tmp;
---一次遍历多次插入
from user_action_log
insert overwrite table log1 select companyid,originalstring  where companyid='100006'
insert overwrite table log2 select companyid,originalstring  where companyid='10002'

--复制表
create table user_leads_bak
row format delimited fields terminated by '\t'
stored as textfile
as
select leads_id, user_id, '2016-08-22' as bakdate
from user_leads
where create_time<'2016-08-22';

--克隆表
---克隆表时会克隆源表的所有元数据信息，但是不会复制源表的数据。
create table user_leads_like like user_leads;

--备份表
export table user_action_log partition (dt='2016-08-19')
to '/user/hive/action_log.export'

--还原表
---将备份在HDFS上的文件，还原到user_action_log_like表中。
import table user_action_log_like from '/user/hive/action_log.export';

-------------------------------------------------------------------------------------------
----------------------------------------HQL语法--------------------------------------------
-------------------------------------------------------------------------------------------
--select查询
select * from user_leads;
select leads_id, user_id, create_time from user_leads;
select e.leads_id from user_leads e;

---函数列
---hive可以使用自带函数也可以使用自定义函数
select companyid, upper(host), UUID(32) from user_action_log;

---算数运算列
select companyid, userid, (companyid+userid) as sumint from user_action_log;

---限制返回条数
select * from user_action_log limit 100;

---case when then语句
select case companyid when 0 then '未登录' else companyid end from user_action_log;

---where筛选
---where后面接一个条件语句
select * from user_leads where create_time<'2016-08-22';

---group by分组

---子查询
---hive对子查询的支持有限，只允许在select from后面出现
select * from 
(select  userid, username from user_info i where i.userid='10595');

--hive join操作
---hive只支持等值连接，不支持不等值连接
---inner join
---left join
---right join
---full join
---left semi-join

--排序
---order by
---按照某一列排序，如果数据量大，会造成reduce执行相当漫长
select * from user_leads order by userid;

--sort by

--distribute by 和 sort by

--cluster by
