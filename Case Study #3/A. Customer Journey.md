## 🎞️ A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

```sql
select 
	s.customer_id,
	p.plan_id,
	p.plan_name,
	s.start_date
from plans as p
left join subscriptions as s on s.plan_id = p.plan_id
order by s.customer_id
limit 20;
```
