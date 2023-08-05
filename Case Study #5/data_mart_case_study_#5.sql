select * from weekly_sales 

--1. Data Cleansing Steps

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE  TABLE clean_weekly_sales AS (
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region, 
  platform, 
  segment,
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM weekly_sales
);

select * from clean_weekly_sales

--2. Data Exploration

## 1.What day of the week is used for each week_date value?


select 
		distinct(to_char("week_date",'DAY')) as week_date_day
	from clean_weekly_sales
	
	
## 2.What range of week numbers are missing from the dataset?

select 
	distinct week_number 
 from clean_weekly_sales
	order by 1 asc
	
## Missing numbers : 1-12 and 37-52	

## 3.How many total transactions were there for each year in the dataset?

select 
	sum(transactions) as total_trancastions,
	calendar_year as for_each_year
from clean_weekly_sales
group by 2
order by 2 

## 4.What is the total sales for each region for each month?

select 
	region as for_each_region,
	month_number as for_each_month,
	to_char("week_date", 'MONTH') as month_name,
	sum(sales) as total_sales	
from clean_weekly_sales
group by 1,2,3
order by 1

## 5.What is the total count of transactions for each platform

select * from clean_weekly_sales

select 
	platform as for_each_platform,
	sum(transactions) as total_trancastions
from clean_weekly_sales
group by 1
order by 1

## 6.What is the percentage of sales for Retail vs Shopify for each month?

with for_each_month_platform_sales as 
(
	select 
		calendar_year,
		month_number,
		sum( case 
				when platform='Retail' then sales end ) as retail_sales,
	sum(case 
	   		when platform='Shopify' then sales end ) shopify_sales,
	sum(sales) as total_sales
	from clean_weekly_sales 
	group by 1,2
	order by 1,2 
)
select 
	calendar_year,
	month_number,
	round(retail_sales*1.0/total_sales*1.0*100,2) as retail_ratio,
	round(shopify_sales*1.0/total_sales*1.0*100,2) as shopify_ratio
from for_each_month_platform_sales

## 7.What is the percentage of sales by demographic for each year in the dataset?

with for_each_year_demographic_sales as 
(
	select 
		calendar_year,
		sum(case 
				when demographic='Couples' then sales end ) as couples_sales,	
		sum(case 
	   			when demographic='Families' then sales end ) families_sales,	
		sum(case 
	   			when demographic='unknown' then sales end ) unkown_sales,		
		sum(sales) as total_sales
	
	from clean_weekly_sales 
		group by 1
			order by 1
)
select 
	calendar_year,
	round(couples_sales*1.0/total_sales*1.0*100,2) as couples_ratio,
	round(families_sales*1.0/total_sales*1.0*100,2) as families_ratio,
	round(unkown_sales*1.0/total_sales*1.0*100,2) as unkown_ratio
from for_each_year_demographic_sales

## 8.Which age_band and demographic values contribute the most to Retail sales?

select * from clean_weekly_sales 


select 	
	platform,
	age_band,
	demographic,
	sum(sales) as retail_sales,
 sum(sales)*1.0/(	select sum(sales) from clean_weekly_sales 
				 where platform = 'Retail')*1.0*100
from clean_weekly_sales 
	where platform = 'Retail'
	group by 1,2,3


## 9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify?
		If not - how would you calculate it instead?
		
SELECT 
	PLATFORM,
	CALENDAR_YEAR,
	AVG_TRANSACTION,
	SUM(SALES) / SUM(TRANSACTIONS) AS AVG_T
FROM CLEAN_WEEKLY_SALES
GROUP BY 1,2,
	3
	
## ! We cannot use it. Again, we need to divide total sales by the total number of transactions.	

--3. Before & After Analysis

## 1.What is the total sales for the 4 weeks before and after 2020-06-15? 
	What is the growth or reduction rate in actual values and percentage of sales?

select 
	distinct week_number
from clean_weekly_sales 
	where week_date = '2020-06-15'
	
## 2020-06-15 week = 25
## 4 before weeks 21 to 24 
## 4 after week 25 to 28 

-- with case when solution

with week_sales as 
(
	select 
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 21 and 28 ) and (calendar_year = '2020')
	group by 1,2
), before_after_changes as 
(
	select 
		sum(case
		   		when week_number between 21 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 28 then total_sales end) as after_sales
	from week_sales 
)
select 
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 	


-- with window functions solution 

with week_sales as 
(
	select 
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 21 and 28 ) and (calendar_year = '2020')
	group by 1,2
), lag_lead_sales as 
(
	select 
		week_date,
		week_number,
		total_sales,
		lag(total_sales, 4) over (order by week_number) as before_sales,
		lead(total_sales, 4) over (order by week_number) as after_sales
	from week_sales 
)
,total_lag_lead as 
( select 
		sum(before_sales) as before_changes_sales,
 		sum(after_sales) as after_changes_sales
 	from lag_lead_sales 
	)
select 	
	after_changes_sales - before_changes_sales as diff_week_sales,
	round((after_changes_sales - before_changes_sales)*1.0/before_changes_sales*1.0*100,2) as growth_percentage
from total_lag_lead;

## 2.What about the entire 12 weeks before and after?

with week_sales as 
(
	select 
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2
), lag_lead_sales as 
(
	select 
		week_date,
		week_number,
		total_sales,
		lag(total_sales, 12) over (order by week_number) as before_sales,
		lead(total_sales, 12) over (order by week_number) as after_sales
	from week_sales 
)
,total_lag_lead as 
( select 
		sum(before_sales) as before_changes_sales,
 		sum(after_sales) as after_changes_sales
 	from lag_lead_sales 
	)
select 	
	after_changes_sales - before_changes_sales as diff_week_sales,
	round((after_changes_sales - before_changes_sales)*1.0/before_changes_sales*1.0*100,2) as growth_percentage
from total_lag_lead

## 3.How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

## 4 week before-afer 
with week_sales as 
(
	select 
		calendar_year,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where week_number between 21 and 28 
	group by 1,2
), before_after_changes as 
(
	select 
	calendar_year,
		sum(case
		   		when week_number between 21 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 28 then total_sales end) as after_sales
	from week_sales 
		group by 1
)
select 
	calendar_year,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 	

## 12 week before-afer 
with week_sales as 
(
	select 
		calendar_year,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where week_number between 13 and 37
	group by 1,2
), before_after_changes as 
(
	select 
	calendar_year,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
		group by 1
)
select 
	calendar_year,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 

## 4.Bonus Question
select * from clean_weekly_sales

## for region 

with week_sales as 
(
	select 
	region,
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2,3
), before_after_changes as 
(
	select 
	region,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
	group by 1
)
select 
region,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 	


## for platform

with week_sales as 
(
	select 
	platform,
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2,3
), before_after_changes as 
(
	select 
	platform,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
	group by 1
)
select 
platform,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 	


## for age_band

with week_sales as 
(
	select 
	age_band,
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2,3
), before_after_changes as 
(
	select 
	age_band,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
	group by 1
)
select 
age_band,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 


## for demographic

with week_sales as 
(
	select 
	demographic,
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2,3
), before_after_changes as 
(
	select 
	demographic,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
	group by 1
)
select 
demographic,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 

## for customer_type

with week_sales as 
(
	select 
	customer_type,
		week_date,
		week_number,
		sum(sales) as total_sales
	from clean_weekly_sales 
		where (week_number between 13 and 37 ) and (calendar_year = '2020')
	group by 1,2,3
), before_after_changes as 
(
	select 
	customer_type,
		sum(case
		   		when week_number between 13 and 24 then total_sales end) as before_sales,
		sum(case
		   		when week_number between 25 and 37 then total_sales end) as after_sales
	from week_sales 
	group by 1
)
select 
customer_type,
	after_sales - before_sales as diff_week_sales,
	round((after_sales - before_sales)*1.0/before_sales*1.0*100,2) as growth_percentage
from before_after_changes 