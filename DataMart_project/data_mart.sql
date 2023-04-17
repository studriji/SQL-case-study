use case1;
select * from weekly_sales;


-- Data cleansing step

create table clean_weekly_sales as
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calender_year,
region,platform, 
case
when segment is null then 'Unknown'
else segment end as segment,
case 
when Right(segment,1) = '1' then 'Young Adults'
when Right(segment,1) = '2' then 'Middle Adults'
when Right(segment,1) in ('3','4') then 'Retires' 
else 'Unknown' end as age_band,
case 
when Left(segment,1) = 'C' then 'Couples'
when left(segment,1) = 'F' then 'Families'
else 'Unknown' end as demographic,
customer_type,transactions,sales,
round((sales/transactions),2) as avg_transactions
from weekly_sales;


-- Data Exploration

-- which week nimber are missing in dataset
-- there are 52 weeks
create table sequence
(x int auto_increment primary key);

insert into sequence values (),(),(),(),(),(),(),(),(),();
insert into sequence values (),(),(),(),(),(),(),(),(),();
insert into sequence values (),(),(),(),(),(),(),(),(),();
insert into sequence values (),(),(),(),(),(),(),(),(),();
insert into sequence values (),(),(),(),(),(),(),(),(),();

insert into sequence select x+50 from sequence;

create table seq_52  (select x from sequence limit 52);

select * from seq_52;

select x as week_day from seq_52 
where x not in (select week_number from clean_weekly_sales);

-- How many total transactions were there for each year in the dataset

select calender_year,sum(transactions) as total_transactions from clean_weekly_sales
group by calender_year;

-- what are the total sales for each region for each month

select region,month_number,sum(sales) from clean_weekly_sales
group by region,month_number;

-- What is the total count of transactions for each platform

select platform,count(transactions) from clean_weekly_sales
group by platform;

-- What is the percentage of sales for Retail vs Shopify for each month?

with temp as 
( select calender_year,month_number,platform,sum(sales) as monthly_sales
from clean_weekly_sales
group by month_number,calender_year,platform
)
select calender_year,month_number,
round(sum(case when platform = 'Retail' then monthly_sales else null end)*100/sum(monthly_sales),2) as retail_percent,
round(sum(case when platform = 'Shopify' then monthly_sales else null end)*100/sum(monthly_sales),2) as shopify_percent
from temp
group by month_number,calender_year;

-- What is the percentage of sales by demographic for each year in the dataset?

with ys as 
(select calender_year,demographic,sum(sales) as yearly_sales
 from clean_weekly_sales group by calender_year,demographic)
 
select *,
round(sum(case when demographic = 'Couples' then yearly_sales else null end)*100/sum(yearly_sales),2) as couples_percent,
round(sum(case when demographic = 'Families' then yearly_sales else null end)*100/sum(yearly_sales),2) as families_percent,
round(sum(case when demographic = 'Unknown' then yearly_sales else null end)*100/sum(yearly_sales),2) as unknown_percent
from ys
group by calender_year;

-- 2nd approach
select calender_year,demographic,sum(sales) as yearly_sales,
round(sum(sales)*100/sum(sum(sales)) over(partition by demographic),2)   as sales_percent
from clean_weekly_sales
group by calender_year,demographic
order by calender_year;




-- Which age_band and demographic values contribute the most to Retail sales?

select age_band,demographic, max(sales) from clean_weekly_sales
where plateform = 'Retail' 
group by age_band,demographic;
