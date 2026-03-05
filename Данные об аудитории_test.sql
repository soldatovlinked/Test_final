/*create database test_final;

create table users(
date DATE,
user_id varchar(50),
view_adverts INT
);

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\test_download.csv"
into table users
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;
show variables like 'secure_file_priv';*/

SELECT * FROM test_final.users;

# 1)_______________________________________
select
	 date_format(date, '%Y-%m-01') as month
    ,count(distinct user_id) as mau
from users
group by date_format(date, '%Y-%m-01');


# 2)_______________________________________
with every_day_users as (
select
    user_id
from users 
group by user_id
having count(distinct date) = (select count(distinct date) from users)
)
select
	count(*) as dau
from every_day_users;

# Нет юзеров которые заходили в приложение каждый день за данный период.
# Поэтому посчитаю среднее DAU 

with daily_users as (
select
	 date(date) as day
    ,count(distinct user_id) as dau
from users
group by date(date)
)
select 
	avg(dau) as dau
from daily_users;


# 3)_______________________________________

with first_enter as (
select
	  distinct user_id as first_day_users
     ,date
from users
where date = '2023-11-01'
),
second_day as (
select
	 count(distinct u.user_id) as two_days_active_users
from users u
join first_enter fe
	on fe.first_day_users = u.user_id
where u.date = date_add(fe.date, interval 1 day)
)
select
	max(sd.two_days_active_users) * 100.0 / count(fe.first_day_users) as retention_rate
from first_enter fe
cross join second_day sd;

select
	count(distinct u2.user_id) * 100.0 / 
    count(distinct u1.user_id) as retention_rate
from users u1
left join users u2
	on u1.user_id = u2.user_id
	and u2.date = '2023-11-02'
where u1.date = '2023-11-01';


# 5)_______________________________________

select
	count(distinct case when view_adverts > 0 then user_id end) * 100.0 /
    count(distinct user_id) as user_coversion_rate
from users;

# 6)_______________________________________

select
	sum(view_adverts) / count(distinct user_id) as avg_view_adverts
from users
where date between '2023-11-01' and '2023-11-30';

