## 🔍 Segment Analysis
## 1.Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
# ROAD 1
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition desc 
    limit 10 
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
    ma.interest_id,
    ma.month_year,
    ma.composition,
    mi.interest_id,
    mi.month_year,
    mi.composition
from max_composition as ma
full outer join  min_composition as mi
    on ma.interest_id = mi.interest_id
````
| interest_id | month_year | composition | interest_id-2 | month_year-2 | composition-2 |
|-------------|------------|-------------|---------------|--------------|---------------|
| 21057       | 2018-12-01 | 21.2        |               |              |               |
| 21057       | 2018-10-01 | 20.28       |               |              |               |
| 21057       | 2018-11-01 | 19.45       |               |              |               |
| 21057       | 2019-01-01 | 18.99       |               |              |               |
| 6284        | 2018-07-01 | 18.82       |               |              |               |
| 21057       | 2019-02-01 | 18.39       |               |              |               |
| 21057       | 2018-09-01 | 18.18       |               |              |               |
| 39          | 2018-07-01 | 17.44       |               |              |               |
| 77          | 2018-07-01 | 17.19       |               |              |               |
| 12133       | 2018-10-01 | 15.15       |               |              |               |
|             |            |             | 35742         | 2019-06-01   | 1.52          |
|             |            |             | 20768         | 2019-05-01   | 1.52          |
|             |            |             | 45524         | 2019-05-01   | 1.51          |
|             |            |             | 6314          | 2019-06-01   | 1.53          |
|             |            |             | 44449         | 2019-04-01   | 1.52          |
|             |            |             | 39336         | 2019-05-01   | 1.52          |
|             |            |             | 6127          | 2019-05-01   | 1.53          |
|             |            |             | 36877         | 2019-05-01   | 1.53          |
|             |            |             | 34083         | 2019-06-01   | 1.52          |
|             |            |             | 4918          | 2019-05-01   | 1.52          |

# ROAD 2
--top 10 
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition desc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from max_composition as ma
````
| interest_id | month_year  | composition |
|-------------|-------------|-------------|
| 21057       | "2018-12-01" | 21.2        |
| 21057       | "2018-10-01" | 20.28       |
| 21057       | "2018-11-01" | 19.45       |
| 21057       | "2019-01-01" | 18.99       |
| 6284        | "2018-07-01" | 18.82       |
| 21057       | "2019-02-01" | 18.39       |
| 21057       | "2018-09-01" | 18.18       |
| 39          | "2018-07-01" | 17.44       |
| 77          | "2018-07-01" | 17.19       |
| 12133       | "2018-10-01" | 15.15       |

--bottom 10 
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from min_composition as ma
````
| interest_id | month_year  | composition |
|-------------|-------------|-------------|
| 45524       | "2019-05-01" | 1.51        |
| 4918        | "2019-05-01" | 1.52        |
| 34083       | "2019-06-01" | 1.52        |
| 35742       | "2019-06-01" | 1.52        |
| 20768       | "2019-05-01" | 1.52        |
| 44449       | "2019-04-01" | 1.52        |
| 39336       | "2019-05-01" | 1.52        |
| 6314        | "2019-06-01" | 1.53        |
| 36877       | "2019-05-01" | 1.53        |
| 6127        | "2019-05-01" | 1.53        |
# ROAD 3
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition desc 
    limit 10 
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from max_composition as ma

union all

select 
  interest_id,
  month_year,
  composition
from min_composition as ma
````
| interest_id | month_year  | composition |
|-------------|-------------|-------------|
| 21057       | "2018-12-01" | 21.2        |
| 21057       | "2018-10-01" | 20.28       |
| 21057       | "2018-11-01" | 19.45       |
| 21057       | "2019-01-01" | 18.99       |
| 6284        | "2018-07-01" | 18.82       |
| 21057       | "2019-02-01" | 18.39       |
| 21057       | "2018-09-01" | 18.18       |
| 39          | "2018-07-01" | 17.44       |
| 77          | "2018-07-01" | 17.19       |
| 12133       | "2018-10-01" | 15.15       |
| 45524       | "2019-05-01" | 1.51        |
| 4918        | "2019-05-01" | 1.52        |
| 34083       | "2019-06-01" | 1.52        |
| 35742       | "2019-06-01" | 1.52        |
| 20768       | "2019-05-01" | 1.52        |
| 44449       | "2019-04-01" | 1.52        |
| 39336       | "2019-05-01" | 1.52        |
| 6314        | "2019-06-01" | 1.53        |
| 36877       | "2019-05-01" | 1.53        |
| 6127        | "2019-05-01" | 1.53        |


