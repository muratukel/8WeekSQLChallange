## 🍊 Case Study #8 - Fresh Segments
![Image](https://8weeksqlchallenge.com/images/case-study-designs/8.png)
🔗 https://8weeksqlchallenge.com/case-study-8/
## 🚮 Data Exploration and Cleansing 
## 1.Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
````sql
ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year || '-01', 'MM-YYYY-DD');
````
## 2.What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
````sql
select 
	month_year,
	count(*)
from interest_metrics
group by 1
order by 1 asc nulls first
````
