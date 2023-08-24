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
ROAD 2
# here I look at how many unique interest_name and month_year values I end the query with(cte).
````sql
select 
	count(distinct interest_name) as total_interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
````
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
