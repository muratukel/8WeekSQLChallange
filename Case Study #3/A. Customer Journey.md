## ⚡ Case Study #3 - Foodie-Fi
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
| customer_id | plan_id | plan_name     | start_date |
|-------------|---------|---------------|------------|
| 1           | 1       | basic monthly | 2020-08-08 |
| 1           | 0       | trial         | 2020-08-01 |
| 2           | 3       | pro annual    | 2020-09-27 |
| 2           | 0       | trial         | 2020-09-20 |
| 3           | 1       | basic monthly | 2020-01-20 |
| 3           | 0       | trial         | 2020-01-13 |
| 4           | 0       | trial         | 2020-01-17 |
| 4           | 1       | basic monthly | 2020-01-24 |
| 4           | 4       | churn         | 2020-04-21 |
| 5           | 1       | basic monthly | 2020-08-10 |
| 5           | 0       | trial         | 2020-08-03 |
| 6           | 1       | basic monthly | 2020-12-30 |
| 6           | 0       | trial         | 2020-12-23 |
| 6           | 4       | churn         | 2021-02-26 |
| 7           | 0       | trial         | 2020-02-05 |
| 7           | 1       | basic monthly | 2020-02-12 |
| 7           | 2       | pro monthly   | 2020-05-22 |
| 8           | 1       | basic monthly | 2020-06-18 |
| 8           | 2       | pro monthly   | 2020-08-03 |
| 8           | 0       | trial         | 2020-06-11 |

--1st customer starts the starter package 1 week after starting the free plan per month has become a member by making a payment.
	
--2nd customer started the free plan and automatically switched to the annual pro plan.

--3rd customer automatically switched to basic after a 7-day free trial.

--4th customer after the free trial in a period of approximately 3 months canceled his membership by staying on the basic plan.

--5th customer automatically switched to basic plan after their free trial permitted.
	
--6th customer automatically switches to the basic plan after the free trial, but in the new year Cancels his/her membership after 2 months on the basic plan.

--7th customer switches to the basic plan after a 7-day free trial and stays on the basic plan for approximately 3 months then switched to the pro plan. The unlimited video experience seems to have worked well for the customer.
	
--8th customer automatically upgrades to the basic plan after the free trial and stays on the basic plan for 2 months switches to the pro plan after it stays.


When considering the scenarios involving customers' transitions and cancellations after the free trial period, we encounter different situations. Some customers have converted to a starter package by making monthly payments after starting with the free plan, while others have automatically switched to an annual pro plan. One
customer has transitioned to the basic plan after the 7-day free trial and subsequently canceled the membership. In another scenario, a customer remained on the basic plan for approximately three months after the free trial and then canceled their subscription. Another customer allowed automatic transition to the basic plan after the free trial but canceled their membership after two months in the new year. In the seventh scenario, a customer switched to the basic plan after the 7-day free trial and upgraded to the pro plan approximately three months later, seemingly enjoying the unlimited video experience. Finally, a customer automatically switched to the basic plan after the free trial and upgraded to the pro plan after two months in the basic plan.Considering these scenarios, it is evident that customers experience different membership transitions and cancellations.
