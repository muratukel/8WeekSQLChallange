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
When considering the scenarios involving customers' transitions and cancellations after the free trial period, we encounter different situations. Some customers have converted to a starter package by making monthly payments after starting with the free plan, while others have automatically switched to an annual pro plan. One
customer has transitioned to the basic plan after the 7-day free trial and subsequently canceled the membership. In another scenario, a customer remained on the basic plan for approximately three months after the free trial and then canceled their subscription. Another customer allowed automatic transition to the basic plan after the free trial but canceled their membership after two months in the new year. In the seventh scenario, a customer switched to the basic plan after the 7-day free trial and upgraded to the pro plan approximately three months later, seemingly enjoying the unlimited video experience. Finally, a customer automatically switched to the basic plan after the free trial and upgraded to the pro plan after two months in the basic plan.Considering these scenarios, it is evident that customers experience different membership transitions and cancellations.
