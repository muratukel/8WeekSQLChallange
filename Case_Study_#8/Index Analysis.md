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

## 3.What is the average of the average composition for the top 10 interests for each month?
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
	month_year,
	round(avg(avg_composition),2)
from avg_composition 
where rank_number <= 10
group by 1
````
| month_year  | round |
|-------------|-------|
| "2018-07-01" | 6.04  |
| "2018-08-01" | 5.95  |
| "2018-09-01" | 6.90  |
| "2018-10-01" | 7.07  |
| "2018-11-01" | 6.62  |
| "2018-12-01" | 6.65  |
| "2019-01-01" | 6.40  |
| "2019-02-01" | 6.58  |
| "2019-03-01" | 6.17  |
| "2019-04-01" | 5.75  |
| "2019-05-01" | 3.54  |
| "2019-06-01" | 2.43  |
| "2019-07-01" | 2.77  |
| "2019-08-01" | 2.63  |

## 4.What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
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
), max_comp as 
(
select 
	month_year,
	max(avg_composition) as max_avg_comp
from avg_composition 
group by 1 
),rolling_avg as 
(
select 
	ac.month_year,
	ac.interest_name,
	max_avg_comp,
	round(avg(max_avg_comp)over(order by ac.month_year rows between 2 preceding and current row),2) as three_month_moving_avg
from avg_composition as ac
	left join max_comp as mc on mc.month_year=ac.month_year
	where avg_composition=max_avg_comp
)
,
month_1_lag as (
    select
        *,
        lag(interest_name) over (order by month_year) || ' : ' || lag(max_avg_comp) over (order by month_year) as one_month_ago
    from rolling_avg
),
month_2_lag as (
    select
        *,
        lag("one_month_ago") over (order by month_year) as two_month_ago
    from month_1_lag
)
select
    *
from month_2_lag
where month_year between '2018-09-01' and '2019-08-01'
order by month_year;
````
| month_year  | interest_name                   | max_avg_comp | three_month_moving_avg | one_month_ago                       | two_month_ago                        |
|-------------|---------------------------------|--------------|------------------------|-------------------------------------|-------------------------------------|
| "2018-09-01" | Work Comes First Travelers      | 8.26         | 7.61                   | Las Vegas Trip Planners : 7.21     | Las Vegas Trip Planners : 7.36     |
| "2018-10-01" | Work Comes First Travelers      | 9.14         | 8.20                   | Work Comes First Travelers : 8.26   | Las Vegas Trip Planners : 7.21     |
| "2018-11-01" | Work Comes First Travelers      | 8.28         | 8.56                   | Work Comes First Travelers : 9.14   | Work Comes First Travelers : 8.26   |
| "2018-12-01" | Work Comes First Travelers      | 8.31         | 8.58                   | Work Comes First Travelers : 8.28   | Work Comes First Travelers : 9.14   |
| "2019-01-01" | Work Comes First Travelers      | 7.66         | 8.08                   | Work Comes First Travelers : 8.31   | Work Comes First Travelers : 8.28   |
| "2019-02-01" | Work Comes First Travelers      | 7.66         | 7.88                   | Work Comes First Travelers : 7.66   | Work Comes First Travelers : 8.31   |
| "2019-03-01" | Alabama Trip Planners           | 6.54         | 7.29                   | Work Comes First Travelers : 7.66   | Work Comes First Travelers : 7.66   |
| "2019-04-01" | Solar Energy Researchers       | 6.28         | 6.83                   | Alabama Trip Planners : 6.54       | Work Comes First Travelers : 7.66   |
| "2019-05-01" | Readers of Honduran Content     | 4.41         | 5.74                   | Solar Energy Researchers : 6.28    | Alabama Trip Planners : 6.54       |
| "2019-06-01" | Las Vegas Trip Planners         | 2.77         | 4.49                   | Readers of Honduran Content : 4.41 | Solar Energy Researchers : 6.28    |
| "2019-07-01" | Las Vegas Trip Planners         | 2.82         | 3.33                   | Las Vegas Trip Planners : 2.77     | Readers of Honduran Content : 4.41 |
| "2019-08-01" | Cosmetics and Beauty Shoppers  | 2.73         | 2.77                   | Las Vegas Trip Planners : 2.82     | Las Vegas Trip Planners : 2.77     |

## 5.Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

When examining the provided output, it becomes apparent that the monthly highest average composition values exhibit variations across different months. These variations can stem from a range of underlying causes.

One possible driver for these changes is seasonal fluctuations. Demands within interest areas might experience a surge during holiday periods or special events, contributing to the observed differences.

Market trends and shifts in consumer preferences could also play a significant role. New products or services gaining popularity can influence the composition values positively, while older interest areas might experience a decline.

Increased competition or the implementation of competitive marketing strategies can lead to oscillations in the popularity of specific interest areas.

Furthermore, the evolving needs and changing preferences of the target audience can result in fluctuations in the monthly composition values.

It's important to note that anomalies could arise due to factors like incorrect data collection or calculation, adding another layer of complexity to the analysis.

The combination of these factors, interacting in various ways, contributes to the observed variations in the monthly highest average composition values.

While these fluctuations might not necessarily necessitate a complete overhaul of your business model, understanding the underlying reasons is paramount. It offers a deeper comprehension of your business and market dynamics, helping you maintain your competitive edge and make informed decisions.
