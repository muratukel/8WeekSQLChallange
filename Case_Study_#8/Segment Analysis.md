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

## 2.Which 5 interests had the lowest average ranking value?
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
 )   
,filter_table as 
(
select 
	ime.month_year,
	ime.interest_id,
	ima.interest_name,
	ime.ranking
from interest_metrics as ime
	left join interest_map as ima on ima.id=ime.interest_id
where ime.interest_id  in (select interest_id from not_removed_interest)
)
select 
	interest_id,
	interest_name,
	round(avg(ranking),2) as avg_ranking
from filter_table 
group by 1,2
order by 3 asc
limit 5
````
| interest_id | interest_name                   | avg_ranking |
|-------------|---------------------------------|-------------|
| 41548       | Winter Apparel Shoppers         | 1.00        |
| 42203       | Fitness Activity Tracker Users  | 4.11        |
| 115         | Mens Shoe Shoppers              | 5.93        |
| 171         | Shoe Shoppers                   | 9.36        |
| 4           | Luxury Retail Researchers       | 11.86       |

## 3.Which 5 interests had the largest standard deviation in their percentile_ranking value?
````sql
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
 )   
,filter_table as 
(
select 
	ime.month_year,
	ime.interest_id,
	ima.interest_name,
	ime.percentile_ranking
from interest_metrics as ime
	left join interest_map as ima on ima.id=ime.interest_id
where ime.interest_id  in (select interest_id from not_removed_interest)
)
select 
	interest_id,
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as std_dev_ranking
from filter_table 
group by 1,2
order by 3 desc 
limit 5
````
| interest_id | interest_name                               | std_dev_ranking |
|-------------|---------------------------------------------|-----------------|
| 23          | Techies                                     | 30.18           |
| 20764       | Entertainment Industry Decision Makers      | 28.97           |
| 38992       | Oregon Trip Planners                        | 28.32           |
| 43546       | Personalized Gift Shoppers                  | 26.24           |
| 10839       | Tampa and St Petersburg Trip Planners       | 25.61           |

## 4.For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
````sql
with interests as
(
    select 
        interest_id, 
        f.interest_name,
        round(stddev(percentile_ranking)::numeric,2) as stdev_ranking
    from filtered_table f
    join interest_map as ma on
     f.interest_id::integer = ma.id
    group by 1,2
     order by 3 desc
    limit 5
),
percentiles as(
    select 
        i.interest_id, 
        f.interest_name, 
        max(percentile_ranking) as max_percentile,
        min(percentile_ranking) as min_percentile
    from filtered_table as f 
    left join interests as i
    on i.interest_id=f.interest_id
    group by 1,2
), 
max_per as (
    select 
        p.interest_id, 
        f.interest_name,
        month_year as max_year, 
        max_percentile
    from  filtered_table as f 
    left join percentiles as p
    on p.interest_id=f.interest_id
    where  max_percentile = percentile_ranking
),
min_per as ( 
    select 
        p.interest_id, 
        f.interest_name,
        month_year as min_year, 
        min_percentile
    from  filtered_table as f 
    left join percentiles as  p
    on p.interest_id=f.interest_id
    where  min_percentile = percentile_ranking
)
    select 
        mi.interest_id,
        mi.interest_name,
        min_year,
        min_percentile, 
        max_year, 
        max_percentile
    from min_per as mi 
    left join max_per as ma 
    on mi.interest_id= ma.interest_id
````
| interest_id | interest_name                           | min_year     | min_percentile | max_year      | max_percentile |
|-------------|-----------------------------------------|------------  |----------------|---------------|----------------|
| 20764       | Entertainment Industry Decision Makers  | "2019-08-01" | 11.23          | "2018-07-01"  | 86.15          |
| 38992       | Oregon Trip Planners                    | "2019-07-01" | 2.2            | "2018-11-01"  | 82.44          |
| 10839       | Tampa and St Petersburg Trip Planners   | "2019-03-01" | 4.84           | "2018-07-01"  | 75.03          |
| 23          | Techies                                 | "2019-08-01" | 7.92           | "2018-07-01"  | 86.69          |
| 43546       | Personalized Gift Shoppers              | "2019-06-01" | 5.7            | "2019-03-01"  | 73.15          |

## 5.How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

## Entertainment Industry Decision Makers: Eğlence Sektörü Karar Vericileri

Entertainment Industry Decision Makers are in the high percentile of rankings (86.15), thus they should be directed to relevant and quality content. When the entertainment industry ranks low (11.23), it's likely that other industries are prevailing at that time. They seem to shine when their rankings are at their highest percentages. Even at their lowest ranking percentiles, they still hold a significant segment, demonstrating their influence.

**Recommendations:**
As decision makers in the entertainment industry, content about industry innovations, leaders, and business opportunities can be presented. For a comedy movie or a sports event to be entertaining, a prerequisite is that individuals find the content amusing.

**Avoid:**
Content unrelated to the entertainment industry, such as technology or finance topics, should be avoided. Also, steer clear of low-quality or false information.

## Oregon Trip Planners: Oregon Seyahat Planlayıcıları

Oregon Trip Planners fall in the low percentile of rankings on July 1, 2019 (2.2), indicating a group with diverse interests. Hence, we can assume they are a group with broader and more general preferences.

**Recommendations:**
Content about Oregon travel guides, equipment recommendations for nature trips, information about local events and festivals could be of interest to them.

**Avoid:**
Content about travel to other regions or countries, luxury travel, or high-budget events should be avoided.

## Tampa and St. Petersburg Trip Planners

Providing this segment with region-specific travel guides, local event announcements, and lodging recommendations can be effective.

**Recommendations:**
Travel guides for Tampa and St. Petersburg, local restaurant and cafe recommendations, as well as announcements of local events could be showcased.

**Avoid:**
Content related to travel to other regions, cold or winter-focused activities should be avoided.

## Techies

This segment represents technology enthusiasts. They are in the high percentile of rankings (86.69), so they should be directed towards technology-focused content.

**Recommendations:**
Content about technology trends, product reviews, programming guides, and information about newly released software or devices could be highlighted.

**Avoid:**
Content unrelated to technology, such as outdoor sports or art, should be avoided. Also, steer clear of low-quality or outdated technology-related content.

## Personalized Gift Shoppers

This segment is in the mid-range percentile of rankings (73.15), so tailored content can be provided for this group. Personalized gift ideas, special product reviews, and shopping tips might attract this segment.

**Recommendations:**
Content about personalized gift ideas, unique product reviews, and tips for selecting gifts could be showcased.

**Avoid:**
General or ordinary gift ideas, content about low-quality or inadequate products should be avoided.
