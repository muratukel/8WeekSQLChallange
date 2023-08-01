## :atom: B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

```sql
select
     count(distinct customer_id) as total_customer 
from subscriptions;
```

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
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

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

