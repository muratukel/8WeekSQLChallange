	2.Digital Analysis

## 1.How many users are there?

select 
	count(distinct user_id) as total_users 
from users	

## 2.How many cookies does each user have on average?
	
with aeu as 
(select 
	user_id,
	count(cookie_id) as count_cookie
from users	
	group by 1)
	
select 	
	round(avg(count_cookie),2) avg_cookie_users
from aeu	

## 3.What is the unique number of visits by all users per month?

select 
	to_char("event_time",'MONTH') as users_per_month,
	count(distinct visit_id) as unique_visits 
from events 
group by 1

## 4.What is the number of events for each event type?
	Her bir etkinlik türü için etkinlik sayısı nedir?
	
select 	
	event_type as each_event_type,
	count(distinct visit_id) as number_of_events
from events 
	group by 1
	
## 5.What is the percentage of visits which have a purchase event?	
	Satın alma etkinliği olan ziyaretlerin yüzdesi nedir?

with total_purchase_type as 
(select 
		ei.event_name,
		count(distinct visit_id) as purchase_visit_count
	from events as e 
	left join event_identifier as ei on ei.event_type=e.event_type
	where ei.event_name='Purchase'
		group by 1)
select 
	event_name,
round(purchase_visit_count*1.0/(select count(distinct visit_id) from events )*1.0*100,2) as purchase_event_ratio
		  from total_purchase_type
		  
## 6.What is the percentage of visits which view the checkout page but do not have a purchase event?
	Ödeme sayfasını görüntüleyen ancak bir satın alma olayı gerçekleşmeyen ziyaretlerin yüzdesi nedir?

with checkout_purchase as 

(select 	
	count(e.visit_id) as checkout,
( select count(distinct visit_id) as purchase_visit_count
	from events as e 
	left join event_identifier as ei on ei.event_type=e.event_type
	where ei.event_name='Purchase') as purchase 
from events as e
	left join event_identifier as ei on ei.event_type=e.event_type
	where ei.event_name !='Purchase' and e.page_id=12 and e.event_type = 1	
)
select 
	round((purchase*1.0/checkout*1.0)*100,2) as checkout_purchase_ratio
	from checkout_purchase


1.yol

with checkout_purchase as 
(
    select 	
        count(e.visit_id) as checkout,
        ( select count(distinct visit_id) as purchase_visit_count
            from events as e 
            left join event_identifier as ei on ei.event_type=e.event_type
            where ei.event_name='Purchase') as purchase 
    from events as e
    left join event_identifier as ei on ei.event_type=e.event_type
    where ei.event_name !='Purchase' and e.page_id=12 and e.event_type = 1	
)
select 
    round((1-(purchase*1.0/checkout*1.0)) * 100, 2) as checkout_purchase_ratio
from checkout_purchase;
	
	
	
2.yol

with checkout_purchase as 
(
	select 
		distinct visit_id,
		sum(case
		   		when event_type = 1 and page_id = 12 then 1 else 0 end) as checkout,
		sum(case 
		   	when event_type = 3 then 1 else 0 end ) as purchase 
	from events 
		group by 1 	
)
select 
	round((100*(1-(sum(purchase)*1.0/sum(checkout)*1.0))),2)
	from checkout_purchase 
	
## 7.What are the top 3 pages by number of views?
	Görüntülenme sayısına göre ilk 3 sayfa hangileridir?
	
select 
	ph.page_name,
	count(visit_id) as visits 
	from events as e
	left join page_hierarchy as ph on ph.page_id=e.page_id
		group by 1 
		order by 2 desc 
		limit 3
		
## 8.What is the number of views and cart adds for each product category?
	Her bir ürün kategorisi için görüntülenme ve sepete eklenme sayısı nedir?
	
	select 
		ph.product_category,
		sum(case 
		   		when ei.event_name ='Page View' then 1 else 0 end) as page_views,
		sum(case 
				when ei.event_name ='Add to Cart' then 1 else 0 end) as add_to_cart
				from events as e 
		left join event_identifier as ei on ei.event_type = e.event_type
		left join page_hierarchy as ph on ph.page_id = e.page_id
		where ph.product_category is not null 
		group by 1
		
## 9.What are the top 3 products by purchases?
	Satın alımlara göre ilk 3 ürün hangileridir?
	
SELECT 
    ph.product_category,
    COUNT(*) AS purchase_count
FROM 
    events AS e 
LEFT JOIN 
    event_identifier AS ei ON ei.event_type = e.event_type
LEFT JOIN 
    page_hierarchy AS ph ON ph.page_id = e.page_id	
WHERE 
    ei.event_name = 'Purchase' AND ph.product_category IS NOT NULL
GROUP BY 
    ph.product_category
ORDER BY 
    purchase_count DESC
LIMIT 3;


	3. Product Funnel Analysis
	
## 1.

with product_wiew_added as 
(
select 
	distinct e.visit_id,
	ph.product_id,
	ph.product_category,
	ph.page_name,
		sum(case 
		   		when ei.event_name ='Page View' then 1 else 0 end) as page_views,
		sum(case 
				when ei.event_name ='Add to Cart' then 1 else 0 end) as add_to_cart
from events as e 
left join page_hierarchy as ph on ph.page_id = e.page_id
	left join event_identifier as ei on ei.event_type = e.event_type
where ph.product_id is not null 
group by 1,2,3,4
),
purchase as 
(
select 
		distinct visit_id
	from events e 
	left join event_identifier as ei on ei.event_type = e.event_type
		where ei.event_name ='Purchase' and e.visit_id is not null
),
table3 as 
(
select 
		distinct pwa.visit_id,
				 pwa.product_id,
				 pwa.product_category,
			     pwa.page_name,
				 pwa.page_views,
				 pwa.add_to_cart,
		case when p.visit_id is not null then 1 else 0 end as purchase
	from product_wiew_added as pwa 
	left join purchase as p on p.visit_id =pwa.visit_id
),
table4 as 
(
select 
	product_id,
	page_name,
	product_category,
	sum(page_views) as view ,
	sum(add_to_cart) as add_cart,
	sum(case
	   		when add_to_cart = 1 and purchase = 0 then 1 else 0 end) as abandon,
	sum(case
	   		when add_to_cart = 1 and purchase = 1 then 1 else 0 end) as purchased
from table3 
	group by 1,2,3 
)
select * from table4
	order by product_id
	


CREATE TABLE product_new AS

(with product_wiew_added as 
(
select 
	distinct e.visit_id,
	ph.product_id,
	ph.product_category,
	ph.page_name,
		sum(case 
		   		when ei.event_name ='Page View' then 1 else 0 end) as page_views,
		sum(case 
				when ei.event_name ='Add to Cart' then 1 else 0 end) as add_to_cart
from events as e 
left join page_hierarchy as ph on ph.page_id = e.page_id
	left join event_identifier as ei on ei.event_type = e.event_type
where ph.product_id is not null 
group by 1,2,3,4
),
purchase as 
(
select 
		distinct visit_id
	from events e 
	left join event_identifier as ei on ei.event_type = e.event_type
		where ei.event_name ='Purchase' and e.visit_id is not null
),
table3 as 
(
select 
		distinct pwa.visit_id,
				 pwa.product_id,
				 pwa.product_category,
			     pwa.page_name,
				 pwa.page_views,
				 pwa.add_to_cart,
		case when p.visit_id is not null then 1 else 0 end as purchase
	from product_wiew_added as pwa 
	left join purchase as p on p.visit_id =pwa.visit_id
),
table4 as 
(
select 
	product_category,
	sum(page_views) as view,
	sum(add_to_cart) as add_cart,
	sum(case
	   		when add_to_cart = 1 and purchase = 0 then 1 else 0 end) as abandon,
	sum(case
	   		when add_to_cart = 1 and purchase = 1 then 1 else 0 end) as purchased
from table3 
	group by 1
)
select * from table4
	
	)

select * from product_new	
	
## 1.Which product had the most views, cart adds and purchases?
		En çok görüntülenen, sepete eklenen ve satın alınan ürün hangisiydi?
		
select 
	*
from product_new	
	
## 2.Which product was most likely to be abandoned?	
	Hangi ürünün terk edilme olasılığı daha yüksekti?
	
select 
	product_category,
	round(case when product_category = 'Luxury' then abandon/add_cart 
		 	when product_category = 'Shellfish' then abandon/add_cart 
		 		when product_category = 'Fish' then abandon/add_cart else 0 end,3) as abandonment_rate
from product_new	

## 3.Which product had the highest view to purchase percentage?
		Hangi ürün en yüksek görüntüleme-satın alma yüzdesine sahipti?
		
select 
	product_category,
	round(purchased/view,3)*100
from product_new		

## 4.What is the average conversion rate from view to cart add?
	Görüntülemeden sepete eklemeye kadar ortalama dönüşüm oranı nedir?
	
--Conversion Rate (Dönüşüm Oranı) : Dönüşüm oranı, bir eylemin gerçekleştiği önceki bir eyleme göre yüzdesel olarak ifade edilen orandır. 
--Bu, bir hedefe ulaşanların sayısını başlangıç noktasındaki tüm katılımcıların sayısına bölerken hesaplanır.

--Cıktıya Göre ; Dönüşüm Oranı = Sepete Ekleme / Görüntüleme


-- Conversion Rate: The conversion rate is the percentage ratio expressed between a subsequent action occurring after a previous action. 
-- It's calculated by dividing the number of those who achieve a goal by the total number of participants at the starting point.

-- Based on the Output; Conversion Rate = Add to Cart / Views


-- Örnek:
-- Bir e-ticaret web sitesi düşünelim. Bu web sitesinde ürünleri görüntüleyen ziyaretçilerin bazıları ürünü sepete ekler ve daha sonra satın alır. 
-- Bu süreçteki dönüşüm oranı aşağıdaki şekilde hesaplanır:

--Görüntüleme sayısı: 10.000 ziyaretçi
--Sepete ekleme sayısı: 1.000 kişi
--Satın alma sayısı: 200 kişi

--Görüntülemeden sepete ekleme oranı: 1.000 / 10.000 = 0.1 (veya %10)
--Görüntülemeden satın alma oranı: 200 / 10.000 = 0.02 (veya %2)
--Sepete eklenenlerden satın alma oranı: 200 / 1.000 = 0.2 (veya %20)	



-- Ortalama Dönüşüm Oranı hesaplama:Ortalama Dönüşüm Oranı = (Toplam Satın Alım / Toplam Görüntüleme) * 100
-- Bu formülde, "Toplam Satın Alım" ürünleri satın alan kullanıcıların sayısını temsil ederken,
-- "Toplam Görüntüleme" ürünleri görüntüleyen toplam kullanıcı sayısını ifade eder.
-- Bu oran, genellikle yüzde olarak ifade edilir ve dönüşümün ne kadar etkili olduğunu anlamak için kullanılır.

-- Örnek hesaplama:
-- Toplam Satın Alım: 1404 + 2898 + 2115 = 6417
-- Toplam Görüntüleme: 3032 + 6204 + 4633 = 13869
-- Ortalama Dönüşüm Oranı = (6417 / 13869) * 100 ≈ 46.27%

-- Bu örnek veri seti için ortalama dönüşüm oranı yaklaşık %46.27'dir.
-- Bu oran, ürünlerin görüntülenmelerine kıyasla ne kadar etkili bir şekilde sepete eklenip satın alındığını gösterir.

select 
	round(avg(add_cart/view),2)*100
from product_new	

## 5.What is the average conversion rate from cart add to purchase?
	Sepete ekleme işleminden satın alma işlemine ortalama dönüşüm oranı nedir?
	
select 
	round(avg(purchased/add_cart),2)*100
from product_new		


## 3. Campaigns Analysis

select 
	u.user_id,
	e.visit_id,
	min(e.event_time) as visit_start_time,
	sum(case 
	   		when ei.event_name='Page View' then 1 else 0 end ) as page_views,
	sum(case 
	   		when ei.event_name='Add to Cart' then 1 else 0 end ) as cart_adds,	
	sum(case 
	   		when ei.event_name='Purchase' then 1 else 0 end ) as purchase,
	ci.campaign_name,		
	sum(case 
	   		when ei.event_name='Ad Impression' then 1 else 0 end ) as impression,
	sum(case 
	   		when ei.event_name='Ad Click' then 1 else 0 end ) as click,	
	string_agg(case 
			  	when ph.product_id is not null and ei.event_name='Add to Cart' then ph.page_name else null end,
			  ', ' order by e.sequence_number) as cart_products 	
from users as u
left join events as e 
	on e.cookie_id=u.cookie_id
left join event_identifier as ei 
	on ei.event_type=e.event_type
left join page_hierarchy as ph
	on ph.page_id=e.page_id
left join campaign_identifier as ci
	on e.event_time between ci.start_date and ci.end_date
		group by 1,2,7

1.Identifying users who have received impressions during each campaign period and 
	comparing each metric with other users who did not have an impression event

WITH impressions AS (
    SELECT
        u.user_id,
        e.visit_id,
        MIN(e.event_time) AS visit_start_time,
        SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
        SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
        STRING_AGG(CASE WHEN ph.product_id IS NOT NULL AND ei.event_name = 'Add to Cart' THEN ph.page_name ELSE NULL END, ', ' ORDER BY e.sequence_number) AS cart_products
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        page_hierarchy AS ph ON ph.page_id = e.page_id
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    GROUP BY
        u.user_id, e.visit_id, ci.campaign_name
)
SELECT
    i.user_id,
    i.campaign_name,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN 1 ELSE 0 END) AS non_impression_count,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.page_views ELSE 0 END) AS impression_page_views,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.page_views ELSE 0 END) AS non_impression_page_views,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.cart_adds ELSE 0 END) AS impression_cart_adds,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.cart_adds ELSE 0 END) AS non_impression_cart_adds,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.purchase ELSE 0 END) AS impression_purchase,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.purchase ELSE 0 END) AS non_impression_purchase
FROM
    impressions AS i
LEFT JOIN
    events AS e ON e.visit_id = i.visit_id
LEFT JOIN
    event_identifier AS ei ON ei.event_type = e.event_type
LEFT JOIN
    campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
GROUP BY
    i.user_id, i.campaign_name;


1.Identifying users who have received impressions during each campaign period and comparing each metric 
	with other users who did not have an impression event
	
WITH impressions AS (
    SELECT
        u.user_id,
        e.visit_id,
        MIN(e.event_time) AS visit_start_time,
        SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
        SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
        STRING_AGG(CASE WHEN ph.product_id IS NOT NULL AND ei.event_name = 'Add to Cart' THEN ph.page_name ELSE NULL END, ', ' ORDER BY e.sequence_number) AS cart_products
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        page_hierarchy AS ph ON ph.page_id = e.page_id
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    GROUP BY
        u.user_id, e.visit_id, ci.campaign_name
)
SELECT
    i.campaign_name,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN 1 ELSE 0 END) AS non_impression_count,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.page_views ELSE 0 END) AS impression_page_views,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.page_views ELSE 0 END) AS non_impression_page_views,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.cart_adds ELSE 0 END) AS impression_cart_adds,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.cart_adds ELSE 0 END) AS non_impression_cart_adds,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN i.purchase ELSE 0 END) AS impression_purchase,
    SUM(CASE WHEN ei.event_name <> 'Ad Impression' THEN i.purchase ELSE 0 END) AS non_impression_purchase
FROM
    impressions AS i
LEFT JOIN
    events AS e ON e.visit_id = i.visit_id
LEFT JOIN
    event_identifier AS ei ON ei.event_type = e.event_type
LEFT JOIN
    campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
GROUP BY
   i.campaign_name;
     
 2.Does clicking on an impression lead to higher purchase rates?
 WITH ClickImpressions AS (
    SELECT
        u.user_id,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click_count,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS clicked_purchase_count
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    WHERE
        ei.event_name IN ('Ad Impression', 'Ad Click', 'Purchase')
    GROUP BY
        u.user_id, ci.campaign_name
)
SELECT
	round(sum(clicked_purchase_count )* 1.0 / NULLIF(SUM(impression_count), 0),2) AS click_to_impression_rate,
    round(sum(clicked_purchase_count )* 1.0 / NULLIF(SUM(click_count), 0),2) AS click_to_purchase_rate
FROM
    ClickImpressions
	
3.	
Bir kampanya gösterimine tıklayan kullanıcıların satın alma oranı

WITH ImpressionUsers AS (
    SELECT
        u.user_id,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click_count,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    WHERE
        ei.event_name IN ('Ad Impression', 'Ad Click', 'Purchase')
    GROUP BY
        u.user_id, ci.campaign_name
)
SELECT
     round(sum(purchase_count)* 1.0 / NULLIF(SUM(impression_count), 0),2) AS click_to_purchase_rate
FROM
    ImpressionUsers
WHERE
    click_count = 0;


Bir kampanya gösterimine tıklamayan kullanıcıların satın alma oranı

WITH ImpressionUsers AS (
    SELECT
        u.user_id,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click_count,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    WHERE
        ei.event_name IN ('Ad Impression', 'Ad Click', 'Purchase')
    GROUP BY
        u.user_id, ci.campaign_name
)
SELECT
     round(sum(purchase_count)* 1.0 / NULLIF(SUM(impression_count), 0),2) AS click_to_purchase_rate
FROM
    ImpressionUsers
WHERE
    click_count > 0;


Peki ya onları sadece bir gösterim alan ancak tıklamayan kullanıcılarla karşılaştırırsak?

WITH ImpressionUsers AS (
    SELECT
        u.user_id,
        ci.campaign_name,
        SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression_count,
        SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click_count,
        SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM
        users AS u
    LEFT JOIN
        events AS e ON e.cookie_id = u.cookie_id
    LEFT JOIN
        event_identifier AS ei ON ei.event_type = e.event_type
    LEFT JOIN
        campaign_identifier AS ci ON e.event_time BETWEEN ci.start_date AND ci.end_date
    WHERE
        ei.event_name IN ('Ad Impression', 'Ad Click', 'Purchase')
    GROUP BY
        u.user_id, ci.campaign_name
)
SELECT
     round(sum(purchase_count)* 1.0 / NULLIF(SUM(impression_count), 0),2) AS click_to_purchase_rate
FROM
    ImpressionUsers
WHERE
    impression_count = 1 and click_count = 0 ;
	
	
4.What metrics can you use to quantify the success or failure of each campaign compared to eachother?	
	
-- Click-Through Rate (CTR): Refers to the percentage of users who clicked on campaign ads after receiving an impression. A high CTR can indicate how attractive the campaign is to its target audience. For example, for the "Half Off - Treat Your Shellf(ish)" campaign, CTR can help us determine how interested users are in the campaign.

-- Conversion Rate: Refers to how many users who clicked on the campaign's ads actually made a purchase. This metric shows how the campaign influenced the users who clicked through. A high conversion rate for a campaign with a low CTR may indicate that the target audience is genuinely interested in the campaign content.

-- Purchase Rate: Indicates how many users who received an impression or clicked through actually made a purchase. This metric shows the overall impact of the campaign. For example, the number of purchases made as a result of campaign impressions or clicks could be a metric for evaluating the performance of the "Half Off - Treat Your Shellf(ish)" campaign.

-- Uplift in Purchase Rate: Calculates the impact of the campaign on impression and click-through purchase rates by comparing the purchase rates of impression and click-through users. This metric can help us understand more clearly how the campaign is impacting its target audience.

-- Revenue Per User: Refers to the average revenue generated per user. It can be used to understand how much campaigns contribute to total revenue. A higher average revenue indicates that the campaign was successful.

-- These metrics are important tools for evaluating and comparing the success of campaigns. However, it is important to remember that each campaign has different goals and target audiences. The evaluation of success should be aligned with these metrics as well as the specific goals and business strategies of the campaigns.
	