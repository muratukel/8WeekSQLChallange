## :atom: B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

```sql
select
     count(distinct customer_id) as total_customer 
from subscriptions;
```
| total_customer |
|---------------|
|     1000      |

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
select 
		to_char(start_date,'MM') as month_distribution,
		count(s.customer_id) as customer_trial
from subscriptions as s 
left join plans as p on p.plan_id = s.plan_id
where p.plan_name = 'trial'
group by month_distribution
order by month_distribution asc;
```
| month_distribution | customer_trial |
|-------------------|----------------|
|        "01"       |       88       |
|        "02"       |       68       |
|        "03"       |       94       |
|        "04"       |       81       |
|        "05"       |       88       |
|        "06"       |       79       |
|        "07"       |       89       |
|        "08"       |       88       |
|        "09"       |       87       |
|        "10"       |       79       |
|        "11"       |       75       |
|        "12"       |       84       |

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

```sql
select 
		p.plan_name,
		count(distinct s.customer_id)
from subscriptions as s
left join plans as p on  p.plan_id = s.plan_id
where s.start_date >'2020-12-31'
group by p.plan_name;
```
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
with total_customers_and_churned as 
(
	select 		 
				count(distinct customer_id) as total_customers,
	(select count(plan_id) as total_churned 
	from subscriptions 
	where plan_id = 4) as churned_customers	
	from subscriptions
)
select 
	total_customers,
		churned_customers,
		round(100*churned_customers*1.0/total_customers*1.0,1) as customer_churned_ratio 
	from total_customers_and_churned;
```
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
with ranking as 
(
	select 
			*,
			rank() over (partition by customer_id order by plan_id) as rank 
	from subscriptions 	
)
select 
	count(case 
		 	when p.plan_name='churn' and r.rank=2 then 1 end) as churn_count,
	count(distinct r.customer_id) as total_customers,
	round(count(case 
		 	when p.plan_name='churn' and r.rank=2 then 1 end)*1.0
		  /count(distinct r.customer_id) *1.0,3) as ratio_churn 
	from ranking as r
	left join plans as p on p.plan_id = r.plan_id;
```
### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
with rank_number_trial as 
(
	select 
			*,
			rank() over(partition by customer_id order by plan_id) as rn 
from subscriptions 
)
select 
		rnt.plan_id,
		p.plan_name,
		count(rnt.plan_id),
	round(count(rnt.plan_id)*1.0  /
		 (select count(plan_id) from rank_number_trial where rn=2)*1.0*100,2) as ratio 
from rank_number_trial as rnt 
left join plans as p on p.plan_id =rnt.plan_id
where rnt.rn=2 
group by 1,2 
order by 1;
```
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
with ranking as 
(
select 
	*,
	rank() over(partition by customer_id order by start_date desc) as rn 
	from subscriptions 
	where start_date <= '2020-12-31'
	
)
select 
	p.plan_name,
	count(r.plan_id) as customer_count ,
	round(count(r.plan_id)*1.0/(select count(distinct customer_id) from ranking )*1.0*100,2)	
from ranking as r 
	left join plans as p on p.plan_id=r.plan_id 
	where r.rn=1 
	group by 1 
	order by 2 desc	;
```

### 8. How many customers have upgraded to an annual plan in 2020?


```sql
select 
     	count(distinct customer_id) as customer_count
from subscriptions
	where plan_id = 3 and 
		start_date between '2020-01-01' and '2020-12-31';
```

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

````sql
with annual_customer as 
(
	select 
		customer_id,
		min(start_date) as first_date_annual
	from subscriptions 
		where plan_id = 3 
	group by 1 
), trial_customer as 
(
	select 
		customer_id,
		min(start_date) as first_date_trial
	from subscriptions 
		where plan_id = 0 
	group by 1 
) 
select 		
	round(avg((first_date_annual-first_date_trial)),0)
		from annual_customer as ac 
		left join trial_customer as tc on tc.customer_id=ac.customer_id ;
````

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
WITH annual_customer AS 
(
	SELECT 
		customer_id,
		MIN(start_date) AS first_date_annual
	FROM subscriptions 
		WHERE plan_id=3 
	GROUP BY 1 
	
), trial_customer AS 
(
	SELECT 
		customer_id,
		MIN(start_date) AS first_date_trial
	FROM subscriptions 
		WHERE plan_id=0
	GROUP BY 1 
) 
	SELECT 	
	COUNT(ac.customer_id) AS customer_count,
			ROUND(AVG((first_date_annual-first_date_trial)), 0) AS avg_days_to_annual,
			ROUND((first_date_annual-first_date_trial) / 30) AS period
		FROM annual_customer AS ac 
		LEFT JOIN trial_customer AS tc ON tc.customer_id = ac.customer_id 
		GROUP BY period
		ORDER BY customer_count DESC;
```
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
with pm as 
(select 
	 customer_id,
 start_date as first_date_pm
from subscriptions
	where plan_id = 2 and 
		start_date between '2020-01-01' and '2020-12-31'
)		
, bm as 
	
	(select 
		customer_id,
	 start_date as first_date_bm
from subscriptions
	where plan_id = 1 and 
		start_date between '2020-01-01' and '2020-12-31'
)
select count(*) as customer_count from pm 
left join bm on bm.customer_id=pm.customer_id
where pm.first_date_pm - bm.first_date_bm < 0
;
```

