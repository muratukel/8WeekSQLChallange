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
	
