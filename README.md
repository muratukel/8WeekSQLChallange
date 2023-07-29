# 8WeekSQLChallange

CREATE TABLE sales (
  customer_id VARCHAR(1), 
  order_date DATE, 
  product_id INTEGER
);

INSERT INTO sales (
  customer_id, order_date, product_id
) 
VALUES 
  ('A', '2021-01-01', '1'), 
  ('A', '2021-01-01', '2'), 
  ('A', '2021-01-07', '2'), 
  ('A', '2021-01-10', '3'), 
  ('A', '2021-01-11', '3'), 
  ('A', '2021-01-11', '3'), 
  ('B', '2021-01-01', '2'), 
  ('B', '2021-01-02', '2'), 
  ('B', '2021-01-04', '1'), 
  ('B', '2021-01-11', '1'), 
  ('B', '2021-01-16', '3'), 
  ('B', '2021-02-01', '3'), 
  ('C', '2021-01-01', '3'), 
  ('C', '2021-01-01', '3'), 
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  product_id INTEGER, 
  product_name VARCHAR(5), 
  price INTEGER
);

INSERT INTO menu (product_id, product_name, price) 
VALUES 
  (1, 'sushi', 10), 
  (2, 'curry', 15), 
  (3, 'ramen', 12);


CREATE TABLE members (
  customer_id VARCHAR(1), 
  join_date DATE
);

INSERT INTO members (customer_id, join_date) 
VALUES 
  ('A', '2021-01-07'), 
  ('B', '2021-01-09');
  
  
  select * from members
  
  select * from menu
  
  select * from sales
  

--1 Her bir müşterinin restoranda harcadığı toplam tutar nedir?

SELECT S.CUSTOMER_ID,
	SUM(PRICE) AS TOTAL_SPENT
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1

--2 Her bir müşteri restoranı kaç gün ziyaret etmiştir?

SELECT CUSTOMER_ID,
	COUNT(DISTINCT ORDER_DATE) AS VISIT_COUNT
FROM SALES
GROUP BY 1

--3 Her bir müşteri tarafından menüden satın alınan ilk ürün neydi?

SELECT DISTINCT S.CUSTOMER_ID,
	M.PRODUCT_NAME,
	S.ORDER_DATE
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
WHERE S.ORDER_DATE =
		(SELECT MIN(ORDER_DATE)
			FROM SALES)
ORDER BY S.ORDER_DATE;

--4 Menüde en çok satın alınan ürün nedir ve tüm müşteriler tarafından kaç kez satın alınmıştır?

  
SELECT M.PRODUCT_NAME,
	COUNT(S.*) AS TOTAL_ORDER
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1
ORDER BY TOTAL_ORDER DESC
LIMIT 1

--5 Her bir müşteri için en popüler ürün hangisiydi?

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
 where rank=1
 
--6 Müşteri üye olduktan sonra ilk olarak hangi ürünü satın aldı?

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

--7 Müşteri üye olmadan hemen önce hangi ürünü satın aldı?

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

--8 Üye olmadan önce her bir üye için toplam ürün ve harcanan miktar nedir?


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


--9 Harcanan her 1 dolar 10 puana eşitse ve suşi 2 kat puan çarpanına sahipse - her müşterinin kaç puanı olur?


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

--10 Bir müşteri programa katıldıktan sonraki ilk hafta (katılım tarihleri de dahil olmak üzere) 
--sadece suşi değil, tüm ürünlerde 2 kat puan kazanır - A ve B müşterilerinin Ocak ayı sonunda kaç puanları vardır?

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


-- Bonus Question 1 :
WITH TABLE1 AS
	(SELECT S.CUSTOMER_ID,
			S.ORDER_DATE,
			M.JOIN_DATE,
			MM.PRODUCT_NAME,
			MM.PRICE,
			CASE
							WHEN S.ORDER_DATE >= M.JOIN_DATE THEN 'Y'
							ELSE 'N'
			END AS MEMBER
		FROM SALES AS S
		LEFT JOIN MEMBERS AS M ON M.CUSTOMER_ID = S.CUSTOMER_ID
		LEFT JOIN MENU AS MM ON MM.PRODUCT_ID = S.PRODUCT_ID)
SELECT CUSTOMER_ID,
	ORDER_DATE,
	JOIN_DATE,
	PRODUCT_NAME PRICE,
	MEMBER
FROM TABLE1

-- Bonus Question 2 :

WITH table1 AS (
SELECT s.customer_id,
	   s.order_date,
	   m.join_date,
	   mm.product_name,
	   mm.price,
	   CASE WHEN s.order_date >= m.join_date THEN 'Y' ELSE 'N' END AS member
FROM sales AS s
LEFT JOIN members AS m
	ON m.customer_id = s.customer_id
LEFT JOIN menu AS mm 
	ON mm.product_id = s.product_id
)
SELECT customer_id,
	   order_date,
	   join_date,
	   product_name,
	   price,
	   member,
	   CASE WHEN member = 'N' THEN NULL ELSE 
	   	  RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date) END AS ranking
FROM table1
