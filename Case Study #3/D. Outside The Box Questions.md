## :electron: D. Outside The Box Questions

The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

## 1.How would you calculate the rate of growth for Foodie-Fi?

## Let's calculate the growth rate based on the number of customers per month.

```sql
with month_customer as 
(select 
	date_trunc('month',start_date) as month ,
	plan_id,
	count(distinct customer_id) as customer_count
from subscriptions 
where start_date between '2020-01-01' and '2021-12-31' and plan_id not in (0,4)
group by 1,2)
select 
	m.month,
	m.plan_id,
	m.customer_count,
	lag(m.customer_count) over(partition by m.plan_id order by m.month) as previous_customers,
	round((m.customer_count-lag(m.customer_count) over(partition by m.plan_id 
       order by m.month)) / 
lag(m.customer_count) over(partition by m.plan_id order by m.month)*100,1) as growth_ratio
from month_customer as m
order by 1,2;
```
## Let me calculate the growth rate based on the sum of monthly plan fees.

```sql
with month_customer as 
(select 
	date_trunc('month',start_date) as month ,
	s.plan_id,
	sum( p.price) as sum_price
from subscriptions as s
 left join plans as p on p.plan_id=s.plan_id 
where start_date between '2020-01-01' and '2021-12-31' and s.plan_id not in (0,4)
group by 1,2)
select 
	m.month,
	m.plan_id,
	m.sum_price,
	lag(m.sum_price) over(partition by m.plan_id order by m.month) as previous_customers,
	round((m.sum_price-lag(m.sum_price) over(partition by m.plan_id 
       order by m.month)) / 
lag(m.sum_price) over(partition by m.plan_id order by m.month)*100,1) as growth_ratio
from month_customer as m
order by 1,2;
```
## Let's calculate the growth rate by years.

```sql
WITH customer_counts AS (
  SELECT COUNT(DISTINCT customer_id) AS current_customers, NULL AS previous_customers
  FROM subscriptions
  WHERE start_date >= '2021-01-01'
  UNION ALL
  SELECT NULL AS current_customers, COUNT(DISTINCT customer_id) AS previous_customers
  FROM subscriptions
  WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
)
SELECT ((COUNT(DISTINCT current_customers) - COUNT(DISTINCT previous_customers)) / 
		COUNT(DISTINCT previous_customers)) * 100 AS rate_of_growth
FROM customer_counts;
```
## 2.What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

🚩Monthly Recurring Revenue (MRR): This is an income that is paid continuously over a specified period of time. 
is the sum of revenue from products or services. 
It is an indicator of the regular revenue stream of the business and is the 
how often a subscriber pays.

🚩Subscriber Loyalty (Churn Rate): This is the number of subscribers who cancel their subscription in a given time period. 
shows the percentage of customers.
A high churn rate indicates a dissatisfaction with the product or service or 
may mean that needs are not met.

🚩Customer Acquisition Cost (CAC): This is the cost of acquiring a new customer. 
is the sum of marketing and sales costs. 
The CAC metric helps to evaluate the effectiveness of customer acquisition strategies.

🚩Customer Lifetime Value (CLV): This is the lifetime value of a customer to the business. 
shows the estimated total amount of revenue. 
Comparing CLV with CAC shows that customer relationships 
used to evaluate profitability.

🚩Plan Conversion Rates: This metric evaluates the number of users who switch between different subscription plans.
shows the percentage of customers. 
By monitoring this metric, management can identify the most popular plans and 
can identify plans that better fit their needs.

🚩Engagement Metrics: This is how customers interact with the product or service. 
metrics that show how often users use certain features. For example, how often users use certain features, 
metrics such as the level of interest in content or the response time of customer support requests are included in this category.

🚩Customer Satisfaction Score: This measures how satisfied customers are with the product or service. 
is a metric used to evaluate the customer experience. By sending surveys to customers 
or by receiving feedback.

🚩Conversion Rate: This metric is used to measure the conversion rate of something like a website or app. 
the desired action that takes place on the platform (e.g. purchase or registration) 
shows the percentage of the number of visitors who have realized their visit. This can be used for marketing and user 
used to evaluate experience optimization.

🚩Note: The above metrics are based on the type of business, its goals and 
depending on the field. Hence, the choice of metrics and their definitions, 
must be tailored to the specific business.
