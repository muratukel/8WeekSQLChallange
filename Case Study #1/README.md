
### Case Study #1 - Danny's Diner 

![image](https://github.com/muratukel/8WeekSQLChallange/assets/136103635/937b628f-8862-4121-8472-b936dd5a1ca3)

**Introduction**

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

***

## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

* What is the total amount each customer spent at the restaurant?
* How many days has each customer visited the restaurant?
* What was the first item from the menu purchased by each customer?
* What is the most purchased item on the menu and how many times was it purchased by all customers?
* Which item was the most popular for each customer?
* Which item was purchased first by the customer after they became a member?
* Which item was purchased just before the customer became a member?
* What is the total items and amount spent for each member before they became a member?
* If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
* In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

### Bonus Questions

* Recreate the following table output using the available data:

![img4](https://github.com/mtahiraslan/8_week_sql_challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/images/bonus1.JPG?raw=true)
![img5](https://github.com/mtahiraslan/8_week_sql_challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/images/bonus2.JPG?raw=true)


**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT S.CUSTOMER_ID,
	SUM(PRICE) AS TOTAL_SPENT
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1;
````

**2.How many days has each customer visited the restaurant?**

````sql
SELECT CUSTOMER_ID,
	COUNT(DISTINCT ORDER_DATE) AS VISIT_COUNT
FROM SALES
GROUP BY 1;
````
**3.What was the first item from the menu purchased by each customer?**

````sql
SELECT DISTINCT S.CUSTOMER_ID,
	M.PRODUCT_NAME,
	S.ORDER_DATE
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
WHERE S.ORDER_DATE =
		(SELECT MIN(ORDER_DATE)
			FROM SALES)
ORDER BY S.ORDER_DATE;
````

**4.What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
  
SELECT M.PRODUCT_NAME,
	COUNT(S.*) AS TOTAL_ORDER
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1
ORDER BY TOTAL_ORDER DESC
LIMIT 1;
````

**5.Which item was the most popular for each customer?**

````sql

with customer_product_sales as 
(
	select 
		s.customer_id,
		m.product_name,
		count(s.product_id) as popular_order,
			rank() over (partition by s.customer_id order by count(s.product_id) desc ) as rank 
	from sales as s
 left join menu as m on m.product_id=s.product_id
group by 1,2
)	
select 
	customer_id,
   	product_name,
		popular_order
	from customer_product_sales 
 where rank=1;
````

**6.Which item was purchased first by the customer after they became a member?**

````sql

with table1 as(
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   menu.product_name,
	   rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_
from sales as s
left join members as m ON m.customer_id = s.customer_id
left join menu ON menu.product_id = s.product_id
where join_date is not null
and join_date <= order_date
	)
select *
from table1
where rank_ = 1

````
**7.Which item was purchased just before the customer became a member?**

````sql

with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   menu.product_name,
	   rank() over(partition by s.customer_id order by s.order_date desc) as rank_
from sales as s
left join members as m ON m.customer_id = s.customer_id
left join menu ON menu.product_id = s.product_id
where join_date is not null 
and join_date > order_date
			)
select * 
from table1
where rank_ = 1

````

**8.What is the total items and amount spent for each member before they became a member?**

````sql
with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   mm.product_name,
	   mm.price
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
where s.order_date < join_date 
)
select customer_id,
	   sum(price) as total_spend,
	   count(*) as count_product
from table1
group by 1

````

**9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

````sql
with table1 as 
(
select s.customer_id,
	   mm.product_name,
	   mm.price,
	   case when mm.product_name = 'sushi' then price*20 else price*10 end as customer_point,
	   case when mm.product_name = 'sushi' then price*2 else price*1 end as customer_spent
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
)
select 
customer_id,
sum(customer_point) as total_point,
sum(customer_spent) as customer_total_spent
from table1 
group by 1

````

**10.n the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

````sql
with table1 as (
select s.customer_id,
	   s.order_date,
	   m.join_date,
	   case
           when s.order_date < m.join_date + interval '1 week' then price*20
           when mm.product_name = 'sushi' then price*20 else price*10 end as total_point
from sales as s
left join members as m
ON m.customer_id = s.customer_id
left join menu as mm 
ON mm.product_id = s.product_id
where order_date >= join_date 
)
select customer_id,
	   sum(total_point) as total_point
from table1
where order_date between '2021-01-01' and '2021-01-31'
group by 1

````

