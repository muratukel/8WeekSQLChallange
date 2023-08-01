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

Note: The above metrics are based on the type of business, its goals and 
depending on the field. Hence, the choice of metrics and their definitions, 
must be tailored to the specific business.

## 3.What are some key customer journeys or experiences that you would analyse further to improve customer retention?

🚩Account Creation and Onboarding Experience: A customer's experience of signing up and first login to the Foodie-Fi platform, 
how the customer experiences and evaluates the platform. Challenges in this process,

🚩Content Discovery and Recommendations: How customers discover content and recommendations as they navigate the platform
opportunities for analyzing impact, personalizing content recommendations and increasing customer loyalty
can offer.

🚩Customer Interaction and Feedback: Points of interaction with customers and customer feedback, 
It is important to understand customer satisfaction and needs. Surveys, feedback forms and customer 
to receive customer feedback through support interactions, identifying areas for improvement and potential issues 
can provide valuable insights for detection.

🚩Subscription Renewal Processes: Challenges customers face when renewing their subscriptions
or subscription renewal rates can be increased by examining the impact of incentives.

🚩Payment and Invoice Processing: Customers' experience with payment processes and invoice management, 
is critical for customer satisfaction. A simple and hassle-free payment process, 
can increase customer satisfaction.

🚩Customer Relations and Support: Customer support and relations processes, 
plays an important role in customers' interactions with the platform. 
Analyze how customer complaints, questions and issues are handled, 
important for improving the customer experience.

🚩Loyalty Programs and Incentives: The impact of loyalty programs and incentives offered by Foodie-Fi 
should be evaluated. The level and impact of customer participation in these programs, to increase loyalty 
can help identify strategies that can be used to improve the customer experience and increase customer retention.

These insights can help Foodie-Fi to improve the customer experience and increase customer retention. 
will help it identify the areas it needs to focus on. Retention strategies based on the results of the analysis
Based on this, it can aim to increase customer satisfaction and ensure long-term customer loyalty.

## 4.If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

🚩What is your reason for canceling your subscription?
🚩How satisfied were you with the content and services on Foodie-Fi?
🚩Did the price of your subscription influence your decision to cancel?
🚩How was your experience using the Foodie-Fi platform? Did you find it user-friendly?
🚩Did you encounter any technical issues while using Foodie-Fi? If yes, what kind of problems did you experience?
🚩Did you find the content recommendations you received relevant and personalized to your interests?
🚩Did you experience any problems with customer support during the course of your subscription?
🚩Would you consider subscribing to Foodie-Fi again in the future?
🚩How likely are you to recommend Foodie-Fi to a friend or family member?
🚩Is there anything different Foodie-Fi could have done to prevent your cancellation?

These questions will help you understand why customers cancel their subscriptions and what 
will provide valuable insights to evaluate their experience. Understanding customer feedback, 
It is an important step to improve Foodie-Fi's services and content and increase customer satisfaction.

## 5.What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

The Foodie-Fi team can use the following commercial tools to reduce customer churn rate, and this is 
can analyze ideas in a variety of ways to verify their effectiveness:

🚩Content Strategy Refinement: Analyze the selection of content to attract and retain customers. 
and improve its delivery. Conducting customer surveys, monitoring analysis and feedback 
evaluating notifications can help them identify content preferences and customer needs.

🚩Personalization and Recommendation Systems: Providing personalized content recommendations to customers,
can keep customers engaged. Customer engagement using machine learning algorithms 
They can offer personalized recommendations by analyzing their behavior and predicting their preferences.

🚩Flexible Pricing and Plan Options: Offering affordable subscription options and flexible 
pricing policies can encourage customer retention. Customer feedback 
pricing strategies by evaluating their notifications and conducting market analyses.

🚩Customer Service and Support: Providing excellent customer service can increase customer satisfaction
and strengthen customer loyalty. Quickly respond to customer complaints and feedback
and providing effective support to customers, they can gain trust.

🚩Retention Campaigns and Loyalty Programs: Provide customers with exclusive content, discounts or loyalty 
programs can increase customer loyalty. To measure the effectiveness of these campaigns, A/B 
tests and customer surveys to gather feedback.

To verify the effectiveness of these tools, the Foodie-Fi team uses A/B tests, customer surveys and 
tracking analytics. For example, personalized content recommendations to customers 
A/B tests to understand the impact on retention. Similarly, 
customer satisfaction by conducting customer surveys after implementing retention campaigns
and their level of engagement. These analyses can be used to continuously improve retention strategies.
will provide important information to improve and increase customer loyalty.

