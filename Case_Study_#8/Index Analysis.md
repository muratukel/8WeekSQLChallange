## 📈 Index Analysis

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

## 1.What is the top 10 interests by the average composition for each month?
````sql
with avg_composition as 
(
select
	month_year,
	interest_name,
		round((composition/index_value)::numeric, 2) as avg_composition,
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
)
select 
	*
from avg_composition 
	where rank_number <=10
````
| month_year  | interest_name                       | avg_composition | rank_number |
|-------------|-------------------------------------|-----------------|-------------|
| "2018-07-01" | Las Vegas Trip Planners             | 7.36            | 1           |
| "2018-07-01" | Gym Equipment Owners                | 6.94            | 2           |
| "2018-07-01" | Cosmetics and Beauty Shoppers       | 6.78            | 3           |
| "2018-07-01" | Luxury Retail Shoppers              | 6.61            | 4           |
| "2018-07-01" | Furniture Shoppers                  | 6.51            | 5           |
| "2018-07-01" | Asian Food Enthusiasts              | 6.10            | 6           |
| "2018-07-01" | Recently Retired Individuals        | 5.72            | 7           |
| "2018-07-01" | Family Adventures Travelers         | 4.85            | 8           |
| "2018-07-01" | Work Comes First Travelers          | 4.80            | 9           |
| "2018-07-01" | HDTV Researchers                    | 4.71            | 10          |

# First 10 rows

## 2.For all of these top 10 interests - which interest appears the most often?
# ROAD 1
````sql
with avg_composition as 
(
select
	month_year,
	interest_name,
	round((composition/index_value)::numeric, 2),
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
)
select 
	interest_name,
	count(interest_name) 
from avg_composition 
	where rank_number <=10
group by 1	
order by 2 desc
````
| interest_name                                   | count |
|-------------------------------------------------|-------|
| Solar Energy Researchers                       | 10    |
| Luxury Bedding Shoppers                        | 10    |
| Alabama Trip Planners                          | 10    |
| Nursing and Physicians Assistant Journal Researchers | 9     |
| New Years Eve Party Ticket Purchasers          | 9     |
| Readers of Honduran Content                    | 9     |
| Teen Girl Clothing Shoppers                    | 8     |
| Work Comes First Travelers                     | 8     |
| Christmas Celebration Researchers              | 7     |
| Asian Food Enthusiasts                         | 5     |
| Furniture Shoppers                             | 5     |
| Recently Retired Individuals                   | 5     |
| Gym Equipment Owners                           | 5     |
| Cosmetics and Beauty Shoppers                  | 5     |
| Las Vegas Trip Planners                        | 5     |
| Luxury Retail Shoppers                         | 5     |
| PlayStation Enthusiasts                        | 4     |
| Readers of Catholic News                       | 4     |
| Medicare Researchers                          | 3     |
| Restaurant Supply Shoppers                     | 3     |
| Medicare Provider Researchers                  | 2     |
| Gamers                                         | 1     |
| HDTV Researchers                              | 1     |
| Chelsea Fans                                  | 1     |
| Medicare Price Shoppers                       | 1     |
| Family Adventures Travelers                    | 1     |
| Cruise Travel Intenders                        | 1     |
| Marijuana Legalization Advocates               | 1     |
| Luxury Boutique Hotel Researchers              | 1     |
| Video Gamers                                  | 1     |

# ROAD 2
````sql
select 
    interest_name,
    count(interest_name) as interest_count
from (
    select
        ime.month_year,
        ima.interest_name,
        round((ime.composition / ime.index_value)::numeric, 2) as avg_composition,
        rank() over (partition by ime.month_year order by ime.composition / ime.index_value desc) as rank_number
    from interest_metrics as ime
    left join interest_map as ima on ima.id = ime.interest_id
) as subquery
where rank_number <= 10
group by interest_name
order by interest_count desc;
````
