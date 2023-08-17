High Level Sales Analysis
  
## 1.What was the total quantity sold for all products?
	 Tüm ürünler için satılan toplam miktar ne kadardı?
	 
select 	
	pd.product_name,
	sum(qty) as total_quantity
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id 
group by 1	

## 2.What is the total generated revenue for all products before discounts?
	 İndirimlerden önce tüm ürünler için elde edilen toplam gelir nedir?
	 
select 
	pd.product_name,
	sum(s.price) * sum(s.qty) as total_revenue 
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1

## 3.What was the total discount amount for all products?
	 Tüm ürünler için toplam indirim tutarı ne kadardı?
	 
select 
	pd.product_name,
	sum(s.price * s.qty * s.discount/100) as total_discount
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1	 

Transaction Analysis

## 1.How many unique transactions were there?
	 Kaç tane benzersiz işlem vardı?
	 
select 
	count(distinct txn_id) as total_transactions 
from sales	

## 2.What is the average unique products purchased in each transaction?
	 Her işlemde satın alınan ortalama benzersiz ürün sayısı nedir?

with in_each_transaction as 
(
	select 
	txn_id,
	sum(qty) as unique_qty
from sales 
group by 1
)
select 
	round(avg(unique_qty),2) as avg_unique_qty
 from in_each_transaction

with in_each_transaction as 
(
	select 
	txn_id,
	count(distinct prod_id) as unique_prod
from sales 
group by 1
)
select 
	round(avg(unique_prod),2) as avg_unique_qty
 from in_each_transaction
 
## 3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?
	 İşlem başına gelir için 25., 50. ve 75. yüzdelik değerler nedir?

with txn_revenue_cte as 
(select 
	txn_id,
	sum(price*qty) as txn_revenue 
from sales 
group by 1 )
select 
	 PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY txn_revenue) AS q25_revenue,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY txn_revenue) AS q50_revenue,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY txn_revenue) AS q75_revenue
from txn_revenue_cte	

## 4.What is the average discount value per transaction?
	 İşlem başına ortalama indirim değeri nedir?

with discount_transaction as 
(
select 
	txn_id,
	sum(price*qty*discount/100) as value_discount
from sales 
	group by 1
)
select 
	round(avg(value_discount),2) as avg_discount_value
from discount_transaction

## 5.What is the percentage split of all transactions for members vs non-members?
	 Üyeler ve üye olmayanlar için tüm işlemlerin yüzde dağılımı nedir?

ROAD 1
with txn_transaction as 
(
select 
		member,
		count(distinct txn_id) as transactions 
from sales 
	group by 1
)
select 
	member,
	transactions,
	round((transactions*1.0/(select count(distinct txn_id) from sales)*1.0)*100,2) as ratio
from txn_transaction

ROAD 2

select 
	sum(case 
			when member='t' then 1 else 0 end)*100.0/count(*) as member,
	sum(case 
			when member='f' then 1 else 0 end)*100.0/count(*) as non_member
from sales


## 6.What is the average revenue for member transactions and non-member transactions?
	 Üye işlemleri ve üye olmayan işlemler için ortalama gelir nedir?
	 
with txn_transaction as 
(
select 
	txn_id,
	member,
	sum(price*qty) as revenue 
from sales 
	group by 1,2
)
select 
	member,
	round(avg(revenue),2) as total_revenue
from txn_transaction
	group by 1
 
Product Analysis

## 1.What are the top 3 products by total revenue before discount?
	 İndirim öncesi toplam gelire göre ilk 3 ürün hangileridir?
	 
select 
	pd.product_name,
	sum(s.price)*sum(s.qty) as total_revenue_before_discount
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1
order by 2 desc 
limit 3

## 2.What is the total quantity, revenue and discount for each segment?
	 Her bir segment için toplam miktar, gelir ve indirim nedir?

select 
	pd.segment_id ,
	pd.segment_name,
	sum(s.qty) as total_quantity,
	sum(s.price*s.qty) as total_revenue,
	sum(s.price*s.qty*(1-s.discount*0.01)) as total_revenue_with_discount,
	sum(s.price*s.qty*s.discount/100) as total_discount	
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2

## 3.What is the top selling product for each segment?
	 Her segment için en çok satan ürün nedir?

with top_selling_segment as 
(select 
	pd.segment_id,
	pd.segment_name,
	pd.product_name,
	sum(s.qty) as top_selling_product,
	rank() over (partition by segment_name order by sum(s.qty)desc) as rn
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2,3	)
select 
	segment_id,
	segment_name,
	product_name,
	top_selling_product
from top_selling_segment
	where rn=1
	

## 4.What is the total quantity, revenue and discount for each category?
	 Her bir kategori için toplam miktar, gelir ve indirim nedir?
	 
select 
	pd.category_id,
	pd.category_name,
	sum(s.qty) as total_quantity,
	sum(s.price*s.qty) as total_revenue,
	sum(s.price*s.qty*(1-s.discount*0.01)) as total_revenue_with_discount,
	sum(s.price*s.qty*s.discount/100) as total_discount	
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2

## 5.What is the top selling product for each category?
	 Her kategori için en çok satan ürün nedir?
	 
with top_selling_category as 
(select 
	pd.category_id,
	pd.category_name,
	pd.product_name,
	sum(s.qty) as top_selling_product,
	rank() over(partition by category_name order by sum(s.qty) desc) as rn 
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2,3)
select 
	category_id,
	category_name,
	product_name,
	top_selling_product
from top_selling_category
	where rn = 1
order by 4 desc 

## 6.What is the percentage split of revenue by product for each segment?
	 Her bir segment için gelirin ürüne göre yüzde dağılımı nedir?

select 
	pd.segment_name,
	pd.product_name,
	sum(s.price*s.qty) as for_each_segment_product_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,2) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2	

## 7.What is the percentage split of revenue by segment for each category?
	 Her bir kategori için gelirin segmentlere göre yüzde dağılımı nedir?
	 
select 
	pd.category_name,
	pd.segment_name,
	sum(s.price*s.qty) as for_category_segment_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,5) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2	

## 8.What is the percentage split of total revenue by category?
	 Toplam gelirin kategorilere göre yüzde dağılımı nedir?
	 
select 
	pd.category_name,
	sum(s.price*s.qty) as for_category_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,5) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1

## 9.What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
	
	 Her bir ürün için toplam işlem "penetrasyonu" nedir? 
	 (ipucu: penetrasyon = bir üründen en az 1 adet satın alınan işlem sayısının toplam işlem sayısına bölünmesi)

with transaction_penetration as 
(select 
	distinct s.txn_id,
	pd.product_name,
	sum(case when s.qty>=1 then 1 else 0 end) as penetration
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
	group by 1,2)
select 
	product_name,
	round((sum(penetration)*1.0/(select count(distinct txn_id) from sales)*1.0)*100,2)
from transaction_penetration
group by 1

## 10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
	  Tek bir işlemde herhangi 3 üründen en az 1 adedinin en yaygın kombinasyonu nedir?
	  
ROAD 1	

WITH transaction_combination AS (
    SELECT
        s.txn_id,
        s.prod_id,
        pd.product_name
    FROM
        sales s
    JOIN
        product_details pd ON s.prod_id = pd.product_id
)
SELECT
    tc1.product_name,
    tc2.product_name,
    tc3.product_name,
    COUNT(*) AS combination_count
FROM
    transaction_combination as tc1
INNER JOIN
    transaction_combination as tc2 ON tc2.txn_id = tc1.txn_id
INNER JOIN
    transaction_combination as tc3 ON tc3.txn_id = tc2.txn_id
WHERE
    tc1.prod_id < tc2.prod_id AND tc2.prod_id < tc3.prod_id
GROUP BY
    1,2,3
ORDER BY
    combination_count DESC	
LIMIT 1;


ROAD 2

SELECT 
	S1.PROD_ID,
	S2.PROD_ID,
	S3.PROD_ID,
	COUNT(*)
FROM 
	SALES S1
JOIN 
	SALES S2 ON S1.TXN_ID = S2.TXN_ID
JOIN
	SALES S3 ON S1.TXN_ID = S3.TXN_ID AND S2.TXN_ID = S3.TXN_ID
WHERE 
	S1.PROD_ID <> S2.PROD_ID AND S2.PROD_ID <> S3.PROD_ID AND S1.PROD_ID <> S3.PROD_ID
GROUP BY 
	1,2,3
ORDER BY 
	4 DESC;
	
Reporting Challenge

select 
	s.prod_id,
	pd.product_id,
	pd.category_name,
	pd.segment_name,
	sum(s.qty) as total_quantityi,
	sum(s.qty*s.price) as total_revenue_before_discount,
	sum(s.qty*s.price*(1-discount*0.01)) as total_revenue_with_discount,
	sum(s.qty*s.price*s.discount/100) as total_discount,
	count(distinct s.txn_id) as total_transactions,
	round(count(distinct s.txn_id)*1.0/(select count(distinct txn_id) from sales)*100,2) as penetration,
	round(sum(case 
			when s.member='t' then 1 else 0 end)*100.0/count(s.*),2) as member,
	round(sum(case 
			when s.member='f' then 1 else 0 end)*100.0/count(s.*),2) as non_member,
	round(avg(case
	   		when s.member='t' then (s.qty*s.price*(1-s.discount*0.01)) end),2)	as avg_revenue_member,	
	round(avg(case
	   		when s.member='f' then (s.qty*s.price*(1-s.discount*0.01)) end),2)	as avg_revenue_non_member
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
where extract(month from start_txn_time) in (1,2)	
	group by 1,2,3,4
		
Bonus Challenge

select * from product_hierarchy 
select * from product_prices

ROAD 1 

with product_details_two as 
(
select 
	ph.id as style_id,
	ph.level_text as style_name,
	ph1.id as segment_id,
	ph1.level_text as segment_name,
	ph1.parent_id as category_id,
	ph2.level_text as category_name
from product_hierarchy as ph
left join product_hierarchy as ph1
	on ph.parent_id=ph1.id
left join product_hierarchy as ph2
	on ph1.parent_id=ph2.id
where ph.id between 7 and 18 
)
select 
	pp.product_id,
	pp.price,
	concat(pdt.style_name,' ', pdt.segment_name, ' - ', pdt.category_name) as product_name,
	pdt.category_id,
	pdt.segment_id,
	pdt.style_id,
	pdt.category_name,
	pdt.segment_name,
	pdt.style_name
from product_details_two as pdt 
left join product_prices as pp 
	on pp.id=pdt.style_id
	
	
	
ROAD 2

with gender as
    (
select 
    id as gender_id, 
    level_text as category 
from product_hierarchy 
where level_name='Category'
    ),
seg as 
    (
select 
    parent_id as gender_id,
    id as seg_id, 
    level_text as Segment 
from product_hierarchy 
where level_name='Segment'
    ),
style as 
    (
select 
    parent_id as seg_id,
    id as style_id, 
    level_text as Style
from product_hierarchy 
where level_name='Style'
    ),
prod_final as
    (
select 
    g.gender_id as category_id,
    category as category_name,
    s.seg_id as segment_id,
    segment as segment_name,
    style_id,
    style as style_name
from gender as g 
left join seg as s 
on g.gender_id = s.gender_id
left join style st 
on s.seg_id = st.seg_id
     )
select 
    product_id, 
    price,
    concat(style_name,' ',segment_name,' - ',category_name) as product_name,
    category_id,
    segment_id,
    style_id,
    category_name,
    segment_name,
    style_name 
from  prod_final as pf 
left join product_prices as pp
on pf.style_id=pp.id	
	