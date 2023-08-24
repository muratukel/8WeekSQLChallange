CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
----------------------------------------------------------------------  
  
--DATA CLEAN (customer_orders)

  CREATE TABLE customer_orders_clean AS
SELECT * 
FROM customer_orders

UPDATE customer_orders_clean
SET exclusions =
    (CASE 
        WHEN exclusions = '' OR exclusions LIKE '%null%'
            THEN NULL 
        ELSE exclusions END)
    , extras = 
    (CASE 
        WHEN extras = '' OR extras LIKE '%null%' OR extras is NULL
            THEN NULL
        ELSE extras END)
		
		
	drop table customer_orders	
	
	alter table customer_orders_clean rename to customer_orders
  
--DATA CLEAN (runner_orders)

	CREATE TABLE runner_orders_clean AS
SELECT *
FROM runner_orders	

UPDATE runner_orders_clean
SET pickup_time = 
    (CASE 
        WHEN pickup_time LIKE '%null%' THEN NULL
        ELSE pickup_time END)
    , distance = 
    (CASE
        WHEN distance LIKE '%null%'
            THEN NULL
        WHEN distance LIKE '%km'
            THEN TRIM(distance, 'km')
        ELSE distance END)
    , duration = 
    (CASE 
        WHEN duration LIKE '%null%'
            THEN NULL
        WHEN duration LIKE '%minutes%'
            THEN TRIM(duration, 'minutes')
        WHEN duration LIKE '%mins%'
            THEN TRIM(duration, 'mins')
        WHEN duration LIKE '%minute%'
            THEN TRIM(duration, 'minute')
        ELSE duration END)
    , cancellation =
        (CASE 
            WHEN cancellation LIKE '%null' OR cancellation = ''
                THEN NULL
            ELSE cancellation END)
			
	drop table runner_orders	
	
	alter table runner_orders_clean rename to runner_orders
	
	
ALTER TABLE runner_orders
ALTER COLUMN pickup_time TYPE timestamp USING pickup_time::timestamp without time zone, 
ALTER COLUMN distance TYPE numeric USING distance::numeric,
ALTER COLUMN duration TYPE integer USING duration::integer;
	
ALTER TABLE customer_orders
ALTER COLUMN exclusions TYPE numeric USING exclusions::numeric,
ALTER COLUMN extras TYPE numeric USING extras::numeric;
ALTER TABLE customer_orders
ALTER COLUMN exclusions TYPE numeric[] USING string_to_array(exclusions, ',')::numeric[],
ALTER COLUMN extras TYPE numeric[] USING string_to_array(extras, ',')::numeric[];

CREATE VIEW my_view AS
SELECT pizza_id,
       unnest(string_to_array(toppings, ', '))::numeric as toppings_id
FROM pizza_recipes

select * from my_view 

CREATE VIEW my_view2 AS
SELECT order_id,
       customer_id,
       pizza_id,
       unnest(string_to_array(exclusions,', '))::numeric as exclusions_id,
       unnest(string_to_array(extras,', '))::numeric as extras_id,
       order_time
FROM customer_orders

CREATE VIEW customer_orders_ AS
SELECT order_id,
       customer_id,
       pizza_id,
       exclusions_arr.exclusions_id,
       extras_arr.extras_id,
       order_time
FROM customer_orders
LEFT JOIN LATERAL (SELECT unnest(string_to_array(exclusions, ', '))::numeric AS exclusions_id) exclusions_arr ON true
LEFT JOIN LATERAL (SELECT unnest(string_to_array(extras, ', '))::numeric AS extras_id) extras_arr ON true;

select * from my_view2

select * from my_view2
     
  select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 
  
  
 --A. Pizza Metrics

--1-)Kaç pizza sipariş edildi?

select count(pizza_id) as total_order_pizza
	from customer_orders

--2-)Kaç adet benzersiz müşteri siparişi verildi?

select * from customer_orders 

select count(distinct order_id) as unique_customer_order
	from customer_orders

--3-)Her bir koşucu tarafından kaç başarılı sipariş teslim edildi?

select * from runner_orders 

select 
		runner_id , 
		count(order_id)
from runner_orders
where pickup_time is not null 
group by 1
order by 1


select 
		ro.runner_id,
		count(distinct co.order_id)
from runner_orders as ro 
left join customer_orders as co on co.order_id = ro.order_id
where ro.cancellation is null
group by 1
order by 1




--4-)Her pizza türünden kaç tane teslim edildi?

select * from customer_orders 

select * from pizza_names

select * from runner_orders

select 
		pn.pizza_name,
		count(co.order_id)
from pizza_names as pn
left join customer_orders as co on co.pizza_id = pn.pizza_id
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null
group by 1

--5-)Her müşteri kaç Vejetaryen ve Meatlovers sipariş etti?

select * from customer_orders 

select * from pizza_names

select 
		co.customer_id,
		pn.pizza_name,
		count(co.order_id) as pizza_count
from customer_orders as co 
left join pizza_names as pn on pn.pizza_id = co.pizza_id
group by 1,2
order by 1



--6-)Tek bir siparişte teslim edilen maksimum pizza sayısı neydi?

select * from customer_orders

select * from runner_orders


select 
		distinct co.order_id,
		co.customer_id,
		count(co.pizza_id) as max_pizza_count
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co. order_id
where ro.cancellation is null
group by 1,2
order by max_pizza_count desc
limit 1

--7-)Her bir müşteri için, teslim edilen pizzaların 
		--kaçında en az 1 değişiklik yapıldı ve kaçında değişiklik yapılmadı?
	
	
	select * from customer_orders

select * from runner_orders

select 
 co.customer_id,
count (case 
	when co.exclusions is not null or co.extras is not null then 1  end) as pizza_change,
	count (case 
	when co.exclusions is null and co.extras is null then 1  end) as no_pizza_change
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null
group by 1
order by 1
		
--8-)Hem istisnaları hem de ekstraları olan kaç pizza teslim edildi?

	select * from customer_orders

	select * from runner_orders

select 
		co.customer_id,
		co.order_id,
		count(co.pizza_id) pizza_count		
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null and co.exclusions is not null and co.extras is not null
group by 1,2

--9)Günün her saati için sipariş edilen pizzaların toplam hacmi neydi?

select * from customer_orders

	select * from runner_orders

----1.Query
select 
		count(pizza_id),
		extract(hour from order_time) as hour_day_time
	from customer_orders 
	group by 2
	order by 2

--2.Query
select 
		count(pizza_id),
		to_char(order_time,'hh24') as hour_day_time
	from customer_orders 
	group by 2
	order by 2	


--10-)Haftanın her günü için sipariş hacmi neydi? 

select 
	to_char(order_time,'Day') as day_week,
	count(order_id) as count_order
from customer_orders
group by 1
order by 1

--B. Runner and Customer Experience
--B. Koşucu ve Müşteri Deneyimi

--1-)How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
	--1-)Her 1 haftalık dönem için kaç koşucu kaydoldu? (yani hafta 2021-01-01'de başlar)
	
select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 	
  
  
select 
		count(runner_id) as runners_count,
		to_char(registration_date,'w') as week_period		
from runners  
group by 2
order by 2

--2-)What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--2-)Her bir koşucunun siparişi almak için Pizza Runner Genel Merkezi'ne varması dakika cinsinden ortalama ne kadar sürdü?

select * from runner_orders

select * from customer_orders 


with diff_order_pick as 
(select 
    runner_id,
    avg(extract(epoch from (ro.pickup_time - co.order_time))) as avg_diff_order_pick
    from runner_orders as ro
left join customer_orders as co on co.order_id = ro.order_id
group by 1 
)

select 
    runner_id,
    extract(minute from timestamp 'epoch' + avg_diff_order_pick * interval '1 second') as avg_minutes_diff_order_pick
from diff_order_pick
order by 1;


--3-)Is there any relationship between the number of pizzas and how long the order takes to prepare?
--3-)Pizza sayısı ile siparişin ne kadar sürede hazırlandığı arasında bir ilişki var mı?

	select * from customer_orders 
  
  	select * from runner_orders
  
  
  with orders as 
  
  (
	  select 
  			count(co.pizza_id) as pizza_count,
			age(ro.pickup_time::timestamp,co.order_time::timestamp) as ready_time
  from customer_orders as co 
  left join runner_orders as ro on ro.order_id = co.order_id
  where ro.cancellation is null
  group by 2
  
  )
   
  select 
  		pizza_count,
		avg(ready_time)
from orders 
	group by 1
	order by 1

--4-)What was the average distance travelled for each customer?
--4-)Her bir müşteri için kat edilen ortalama mesafe neydi?

select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 
  

select 
		co.customer_id,
		round(avg(ro.distance::numeric),2) as avg_travel_distance 
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co.order_id 
group by 1
order by 1

--5-)What was the difference between the longest and shortest delivery times for all orders?
--5-)Tüm siparişler için en uzun ve en kısa teslimat süreleri arasındaki fark neydi?

select 
		count(co.order_id) as total_orders,
		max(ro.pickup_time) as longest_delivered,
		min(ro.pickup_time) as shortest_delivered		
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id 
where ro.cancellation is null
group by 2


select 
		count(co.order_id) as total_orders,
		(max(ro.duration::numeric) - min(ro.duration::numeric ) )as longest_shortest_delivered		
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id 
where ro.cancellation is null


--6-)What was the average speed for each runner for each delivery and do you notice any trend for these values?
--6-)Her koşucu için her teslimatta ortalama hız ne kadardı ve bu değerlerde herhangi bir eğilim fark ettiniz mi?


  select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 
  
 --ortalam hız = yol / süre
 
select 
			
		distinct runner_id,order_id,
		round(avg(distance::numeric / (duration::numeric/60)),2) as avg_speed
			
from runner_orders 
		where cancellation is null	
group by 1,2
			
order by 2

--7-)What is the successful delivery percentage for each runner?
--7-)Her bir koşucu için başarılı teslimat yüzdesi nedir?

select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 
  
with suc_delivered as 
(
	select 
		runner_id,
		count(order_id)::numeric as succes_order			 
  from runner_orders 
  where cancellation is null 
group by 1
 order by 1
) 
  , total_delivered as 
  
 (
	 select runner_id,
  count(order_id)::numeric as total_order
	 from runner_orders
	 group by 1
	 order by 1
 ) 
  select 
  		sd.runner_id,
		round((sd.succes_order / td.total_order)*100,2) as succes_ratio 
		
	from suc_delivered as sd 
	left join total_delivered as td on td.runner_id = sd.runner_id 
	order by 1
 

--C. Ingredient Optimisation

--1-)What are the standard ingredients for each pizza?
--1-)Her pizza için standart malzemeler nelerdir?

select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 
  
 
with table1 as 
(
select 
    	unnest(string_to_array(toppings,','))::numeric as recipes_id,
    	pr.pizza_id,
    	pizza_name
from pizza_recipes as pr
left join pizza_names as pn ON pn.pizza_id = pr.pizza_id
)
select 	
		pizza_name,
        pt.topping_name
from table1 as t1
left join pizza_toppings as pt ON t1.recipes_id = pt.topping_id
order by pizza_id



--2-)What was the most commonly added extra?
--2-)En sık eklenen ekstra neydi?

	select * from customer_orders 
  
  select * from pizza_names
  
  select * from pizza_recipes
  
  select * from pizza_toppings
  
  select * from runner_orders
  
  select * from runners 

with extra as 
(
	select 
 		order_id,
		unnest(string_to_array(extras,','))::numeric as extra
from customer_orders 
where extras is not null
order by extra desc
	)

select 	
		pt.topping_name,
		count(extra) as count_use_extra 
from extra as e 
left join pizza_toppings as pt on pt.topping_id = e.extra 
group by 1
order by count_use_extra desc


--3-)What was the most common exclusion?
--3-)En yaygın dışlama neydi?


with exclusion as 
(select 
 		order_id,
		unnest(string_to_array(exclusions,','))::numeric as exclusions
from customer_orders 
where exclusions is not null
)

select 
		pt.topping_name,
		count(exclusions) as count_exclusion
from exclusion as e 
left join pizza_toppings as pt on pt.topping_id = e.exclusions
group by 1
order by count_exclusion desc


--4-)Generate an order item for each record in the customers_orders table in the format of one of the following:
	Meat Lovers
	Meat Lovers - Exclude Beef
	Meat Lovers - Extra Bacon
	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
--4-)customers_orders tablosundaki her kayıt için aşağıdakilerden biri biçiminde bir sipariş öğesi oluşturun:
	Et Severler
	Et Severler - Sığır eti hariç
	Et Severler - Ekstra Pastırma
	Et Severler - Peynir, Pastırma Hariç - Ekstra Mantar, Biber	
		


5--)Generate an alphabetically ordered comma separated ingredient list for each pizza order 
	--from the customer_orders table and add a 2x in front of any relevant ingredients
	--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"	
	
5--)customer_orders tablosundan her pizza siparişi için alfabetik olarak sıralanmış 
	--virgülle ayrılmış bir malzeme listesi oluşturun ve ilgili malzemelerin önüne 2x ekleyin
		--Örneğin: "Et Sevenler: 2xPastırma, Sığır eti, ... , Salam"	



		
6--)What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
6--)Teslim edilen tüm pizzalarda kullanılan her bir malzemenin en sık kullanılana göre sıralanmış toplam miktarı nedir?



##7. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
##7. Teslim edilen tüm pizzalarda kullanılan her bir malzemenin en sık kullanılana göre sıralanmış toplam miktarı nedir?



--D. Pricing and Ratings

1--)If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
1--)Eğer bir Et Severler pizzası 12$ ve Vejetaryen 10$ ise ve değişiklik için 
	--ücret alınmıyorsa - Pizza Runner teslimat ücreti olmadan şimdiye kadar ne kadar para kazanmıştır?

select * from customer_orders 
  
select * from pizza_names
  
select * from pizza_recipes
  
select * from pizza_toppings
  
select * from runner_orders
  
select * from runners 

select pizza_id,unnest(string_to_array(toppings, ','))::numeric from pizza_recipes

select unnest(string_to_array(extras, ','))::numeric as extrass from customer_orders

select unnest(string_to_array(exclusions, ','))::numeric as exclusionss from customer_orders


select 
		sum
		(case 
				when co.pizza_id = 1 then 12 else 10 end) as pr_prices
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null

2--)What if there was an additional $1 charge for any pizza extras?
	--Add cheese is $1 extra
2--)Pizza ekstraları için 1 dolar ek ücret alınsa nasıl olur?
	--Peynir eklemek ekstra 1 dolar	
	
with no_extras_price as
(select 
	sum (case
		when co.pizza_id = 1 then 12 else 10 end) as pr_prices
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null
)
, extras_price  as 

(select 
		sum(case 
			when co.extras_id = 4 then 2 else 1 end) ext_price 		
	from customer_orders_ as co
	join runner_orders as ro on ro.order_id = co.order_id
	where ro.cancellation is null)

	select
      concat(nep.pr_prices+ep.ext_price) as pizza_runner_revenue
from no_extras_price as nep, extras_price  as ep;


<<<<<<< HEAD

--?
with topping_revenue as 
(
    select *,
           length(extras) - length(replace(extras, ',', '')) + 1 as topping_count
    from customer_orders
    inner join pizza_names using (pizza_id)
    inner join runner_orders using (order_id)
    where cancellation is null
    order by order_id
),
pizza_revenue as 
(
select sum(case when pizza_id = 1 then 12 else 10 end) as pizza_revenue,
       sum(topping_count) as topping_revenue
from topping_revenue
)
select concat('$', topping_revenue + pizza_revenue) as total_revenue
from pizza_revenue;



=======
>>>>>>> 41a0ea0466c7c441af4e7c8d5a31a9474c159383
-3--)

create table runner_rating (
order_id int,
runner_rate int);

insert into runner_rating (order_id, runner_rate)
values
  (1,3),
  (2,5),
  (3,3),
  (4,1),
  (5,5),
  (7,3),
  (8,4),
  (10,3);
  
  select * from runner_rating
  
4--) 


select 
	co.customer_id,
	co.order_id,
	ro.runner_id,
	rr.runner_rate,
	co.order_time,
	ro.pickup_time,
	ro.pickup_time - co.order_time as time_between_order_and_pickup,
	ro.duration as delivert_duration,
	avg(ro.distance*60/ro.duration) avg_speed,
	count(co.pizza_id) as total_number_of_number
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id
left join runner_rating as rr on rr.order_id = co.order_id
where ro.cancellation is null 
group by 1,2,3,4,5,6,7,8
order by 1

5--)

with no_extras_price as 

(select co.order_id,
		sum
		(case 
				when co.pizza_id = 1 then 12 else 10 end) as pr_prices, 
			 sum(ro.distance) * 0.30 as runner_traveled_price
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null
 group by 1
 
 )
select 
round(sum(pr_prices-runner_traveled_price),2) as diff_revenue									
from no_extras_price
		
		

