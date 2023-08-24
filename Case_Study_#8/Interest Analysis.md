## 📊 Interest Analysis
## 1.Which interests have been present in all month_year dates in our dataset?
ROAD 1
````sql
select 
	i.interest_name	
from interest_metrics as im 
inner join interest_map as i
	on i.id=im.interest_id
group by 1
having count(distinct im.month_year) = (select count(distinct month_year) from interest_metrics)
````
|                        interest_name                        |
|------------------------------------------------------------|
| Accounting & CPA Continuing Education Researchers          |
| Affordable Hotel Bookers                                   |
| Aftermarket Accessories Shoppers                           |
| Alabama Trip Planners                                      |
| Alaskan Cruise Planners                                    |
| Alzheimer and Dementia Researchers                         |
| Anesthesiologists                                          |
| Apartment Furniture Shoppers                               |
| Apartment Hunters                                          |
| Apple Fans                                                 |

the first 10 lines.

ROAD 2
#❗here I look at how many unique interest_name and month_year values I end the query with(cte).
````sql
select 
	count(distinct interest_name) as total_interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
````
| total_interest_name                               | total_months |
|---------------------------------------------------|--------------|
| 1201                                              | 14           |

````sql
with cte as (
	select 
	interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
) select 
		c.total_months,
		count(distinct interest_name) 
from cte as c 	
group by 1 
order by 2 desc 
limit 1
````
| total_months | count |
|--------------|-------|
|     14       |  480  |

## 2.Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
````sql
with cte_months as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
), cte_counts as (

select 
		total_months,
		count(distinct interest_id) as interest_counts 
from cte_months  	
group by 1 

) , cumulative_percent as (
select 
	total_months,
	interest_counts,
	sum(interest_counts) over(order by total_months desc) as cumulative_sum,
	round(sum(interest_counts) over(order by total_months desc)*1.0/(select sum(interest_counts) from cte_counts)*1.0*100,2) 
		as cumulative_percentage 
from cte_counts
) select 
	total_months,
	interest_counts,
	cumulative_sum,
	cumulative_percentage
from cumulative_percent
	where cumulative_percentage>90
````
| total_months | interest_counts | cumulative_sum | cumulative_percentage |
|--------------|-----------------|----------------|-----------------------|
|      6       |       33        |      1092      |         90.85         |
|      5       |       38        |      1130      |         94.01         |
|      4       |       32        |      1162      |         96.67         |
|      3       |       15        |      1177      |         97.92         |
|      2       |       12        |      1189      |         98.92         |
|      1       |       13        |      1202      |         100.00        |
	
## 3.If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
````sql
with cte_months as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
)
select 
	sum(total_months) total_data_removing
from cte_months 
where total_months<6
````
| total_data_removing |
|--------------------|
|        400         |

## 4.Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
ROAD 1
````sql
with  removed_month_interest as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
	having count(distinct im.month_year)<6
),removed_interest as 
(select 
 	month_year, 
 	count(*) as removed_interest
from interest_metrics
where interest_id in (select interest_id from removed_month_interest) 
group by month_year
),not_removed_interest as 
(
select 
 	month_year, 
 	count(*) as not_removed_interest
from interest_metrics
where interest_id not in (select interest_id from removed_month_interest) 
group by month_year
)
select 
	ri.month_year,
	ri.removed_interest,
	nri.not_removed_interest,
	round(removed_interest*1.0/(removed_interest+not_removed_interest)*1.0*100,2) as removed_rate
from removed_interest as ri
left join not_removed_interest as nri 
	on nri.month_year=ri.month_year
order by 1 asc
````
|   month_year   | removed_interest | not_removed_interest | removed_rate |
|----------------|------------------|----------------------|--------------|
|  2018-07-01    |        20        |         709          |     2.74     |
|  2018-08-01    |        15        |         752          |     1.96     |
|  2018-09-01    |        6         |         774          |     0.77     |
|  2018-10-01    |        4         |         853          |     0.47     |
|  2018-11-01    |        3         |         925          |     0.32     |
|  2018-12-01    |        9         |         986          |     0.90     |
|  2019-01-01    |        7         |         966          |     0.72     |
|  2019-02-01    |        49        |        1072          |     4.37     |
|  2019-03-01    |        58        |        1078          |     5.11     |
|  2019-04-01    |        64        |        1035          |     5.82     |
|  2019-05-01    |        30        |         827          |     3.50     |
|  2019-06-01    |        20        |         804          |     2.43     |
|  2019-07-01    |        28        |         836          |     3.24     |
|  2019-08-01    |        87        |        1062          |     7.57     |
ROAD 2 
````sql
with month_counts as (
    select interest_id, count(distinct month_year) as month_count
    from interest_metrics
    group by 1
    having count(distinct month_year) < 6 
)
select 
    im.month_year,
    count(case 
		  	when im.interest_id in (select interest_id from month_counts) then 1 end) as removed_interest,
    count(case 
		  	when im.interest_id not in (select interest_id from month_counts) then 1 end) as present_interest,
    round(count(case when im.interest_id in (select interest_id from month_counts) then 1 end) * 100.0 /
          (count(case when im.interest_id in (select interest_id from month_counts) then 1 end) +
           count(case when im.interest_id not in (select interest_id from month_counts) then 1 end)), 2) as removed_prcnt
from interest_metrics im
group by 1
order by 1 asc
````
|   month_year   | removed_interest | not_removed_interest | removed_rate |
|----------------|------------------|----------------------|--------------|
|  2018-07-01    |        20        |         709          |     2.74     |
|  2018-08-01    |        15        |         752          |     1.96     |
|  2018-09-01    |        6         |         774          |     0.77     |
|  2018-10-01    |        4         |         853          |     0.47     |
|  2018-11-01    |        3         |         925          |     0.32     |
|  2018-12-01    |        9         |         986          |     0.90     |
|  2019-01-01    |        7         |         966          |     0.72     |
|  2019-02-01    |        49        |        1072          |     4.37     |
|  2019-03-01    |        58        |        1078          |     5.11     |
|  2019-04-01    |        64        |        1035          |     5.82     |
|  2019-05-01    |        30        |         827          |     3.50     |
|  2019-06-01    |        20        |         804          |     2.43     |
|  2019-07-01    |        28        |         836          |     3.24     |
|  2019-08-01    |        87        |        1062          |     7.57     |
## 5.After removing these interests - how many unique interests are there for each month?
````sql
with month_counts as 
(
select 
	interest_id,
	count(distinct month_year) as month_count
from interest_metrics 
group by 1
	having count(distinct month_year)<6
)
select 
 	ime.month_year,
	count(case
	  	when ime.interest_id not in (select interest_id from month_counts) then 1 end) as not_removed_interest
from interest_metrics as ime
group by 1
order by 1 asc
````
|   month_year   | not_removed_interest |
|----------------|----------------------|
|  2018-07-01    |         709          |
|  2018-08-01    |         752          |
|  2018-09-01    |         774          |
|  2018-10-01    |         853          |
|  2018-11-01    |         925          |
|  2018-12-01    |         986          |
|  2019-01-01    |         966          |
|  2019-02-01    |        1072          |
|  2019-03-01    |        1078          |
|  2019-04-01    |        1035          |
|  2019-05-01    |         827          |
|  2019-06-01    |         804          |
|  2019-07-01    |         836          |
|  2019-08-01    |        1062          |
