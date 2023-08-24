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
## 5.Summarise the id values in the fresh_segments.interest_map by its total record count in this table
````sql
select 
	 distinct id,
	 interest_name,
	 count(*) as total_record_count 
from interest_map as im 
left join interest_metrics as i
	on i.interest_id=im.id
group by 1,2
order by 3 desc
````
| id |       interest_name        | total_record_count |
|----|---------------------------|-------------------|
| 4  | Luxury Retail Researchers |        14         |
| 5  | Brides & Wedding Planners |        14         |
| 6  |     Vacation Planners     |        14         |
| 12 |  Thrift Store Shoppers    |        14         |
| 15 |          NBA Fans         |        14         |
| 16 |         NCAA Fans         |        14         |
| 17 |         MLB Fans          |        14         |
| 18 |        Nascar Fans        |        14         |
| 20 |        Moviegoers         |        14         |
| 25 |          Doctors          |        14         |

## 6.What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments. interest_map except from the id column.
````sql
select 
	im.*,
	i.interest_name,
	i.interest_summary,
	i.created_at,
	i.last_modified
from interest_metrics as im
inner join interest_map as i 
	on i.id=im.interest_id 
where im.interest_id = 21246	
````

| _month | _year |  month_year  | interest_id | composition | index_value | ranking | percentile_ranking |       interest_name        |      interest_summary       |      created_at      |    last_modified    |
|--------|-------|--------------|-------------|-------------|-------------|---------|-------------------|---------------------------|-----------------------------|----------------------|---------------------|
|   7    | 2018  |  2018-07-01  |    21246    |     2.26    |     0.65    |   722   |       0.96        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   8    | 2018  |  2018-08-01  |    21246    |     2.13    |     0.59    |   765   |       0.26        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   9    | 2018  |  2018-09-01  |    21246    |     2.06    |     0.61    |   774   |       0.77        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   10   | 2018  |  2018-10-01  |    21246    |     1.74    |     0.58    |   855   |       0.23        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   11   | 2018  |  2018-11-01  |    21246    |     2.25    |     0.78    |   908   |       2.16        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   12   | 2018  |  2018-12-01  |    21246    |     1.97    |     0.7     |   983   |       1.21        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   1    | 2019  |  2019-01-01  |    21246    |     2.05    |     0.76    |   954   |       1.95        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   2    | 2019  |  2019-02-01  |    21246    |     1.84    |     0.68    |   1109  |       1.07        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   3    | 2019  |  2019-03-01  |    21246    |     1.75    |     0.67    |   1123  |       1.14        | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
|   4    | 2019  |  2019-04-01  |    21246    |     1.58    |     0.63    |   1092  |       0.64        | Readers of El Salvador
