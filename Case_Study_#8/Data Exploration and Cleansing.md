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
| month_year  | count |
|-------------|-------|
| 2018-07-01  |  729  |
| 2018-08-01  |  767  |
| 2018-09-01  |  780  |
| 2018-10-01  |  857  |
| 2018-11-01  |  928  |
| 2018-12-01  |  995  |
| 2019-01-01  |  973  |
| 2019-02-01  | 1121  |
| 2019-03-01  | 1136  |
| 2019-04-01  | 1099  |
| 2019-05-01  |  857  |
| 2019-06-01  |  824  |
| 2019-07-01  |  864  |
| 2019-08-01  | 1149  |

## 3.What do you think we should do with these null values in the fresh_segments.interest_metrics

Let's review some methods to deal with missing values:
- **Remove them:** You can simply eliminate the rows with missing values.
- **Infer them from available data points:** You can make educated guesses based on the data you have.
- **Replace them with mean, mode, or median of the columns:** You can use statistical measures to fill in the gaps.

Thus, the most suitable approach in our case is to **remove those NULL values**. This decision is based on the fact that we are unable to specify which date those records are assigned to, and as they won't provide any meaningful value for our analysis, eliminating them would be the best option. This approach would contribute to making our analyses more reliable.

````sql
DELETE FROM interest_metrics
WHERE month_year IS NULL
````
## 4.How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

````sql
ALTER TABLE interest_metrics
ALTER COLUMN interest_id TYPE INTEGER USING interest_id::integer;
````
ROAD 1
````sql
select
	
    (select count(distinct im.interest_id) 
     from interest_metrics as im
     left join interest_map as i on im.interest_id = i.id
     where i.id is null) as missing_in_metrics,

    (select count(distinct i.id)
     from interest_map as i
     left join interest_metrics as im on i.id = im.interest_id
     where im.interest_id is null) as missing_in_map;
````
ROAD 2
````sql
select 
	count(distinct i.interest_id) as interest_id_metrics,
	count(distinct im.id) as interest_id_map ,
	sum(case 
	   		when im.id is null then 1 end) as missing_in_metric,
	sum(case
	   		when i.interest_id is null then 1 end ) missing_in_map
from interest_metrics as i
full outer join interest_map as im
	on im.id=i.interest_id
````
ROAD 2
# I wanted to write with cte maybe you can understand better.
````sql
with metricsmissing as (
    select count(distinct im.interest_id) as missing_in_metrics
    from interest_metrics as im
    left join interest_map as i on im.interest_id = i.id
    where i.id is null
),
mapmissing as (
    select count(distinct i.id) as missing_in_map
    from interest_map as i
    left join interest_metrics as im on i.id = im.interest_id
    where im.interest_id is null
)
select metricsmissing.missing_in_metrics, mapmissing.missing_in_map
from metricsmissing, mapmissing;
````
