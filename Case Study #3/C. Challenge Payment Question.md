### :basecampy: C. Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

🔖monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
🔖upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
🔖upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
🔖once a customer churns they will no longer make payments

```sql
	with recursive cte as (
    select 
        s.customer_id,
        s.plan_id,
        p.plan_name,
        s.start_date,
        p.price,
        lead(start_date, 1) over (partition by s.customer_id order by s.start_date, s.plan_id) as lead_date
    from subscriptions as s
    left join plans as p on p.plan_id = s.plan_id
    where start_date between '2020-01-01' and '2020-12-31'
    and p.plan_name not in ('trial', 'churn')
),
cte1 as (
    select 	
        customer_id,
        plan_id,
        plan_name,
        start_date,
        coalesce(lead_date, '2020-12-31') as coalesce_date,
        price 
    from cte
),
cte2 as (
    select 
        customer_id,
        plan_id,
        plan_name,
        start_date,
        coalesce_date,
        price 
    from cte1 
    union all 
    select 
        customer_id,
        plan_id,
        plan_name,
        date(start_date + interval '1 Month') as start_date,
        coalesce_date,
        price 
    from cte2 
    where coalesce_date > date(start_date + interval '1 Month')
    and plan_name <> 'pro annual'
),
cte3 as (
    select *,
        lag(plan_id, 1) over (partition by customer_id order by start_date) as last_payment,
        lag(price, 1) over (partition by customer_id order by start_date) as last_amount,
        rank() over (partition by customer_id order by start_date) as payment_order
    from cte2
)
select 
    customer_id,
    plan_id,
    plan_name,
    start_date as payment_date,
    (case when plan_id in (2, 3) and last_payment = 1 
          then price - last_amount 
          else price 
     end) as amount,
     payment_order 
from cte3;
```
