select * from customer_nodes 

select * from customer_transactions 

select * from regions 

--A. Customer Nodes Exploration

1.)How many unique nodes are there on the Data Bank system?
1.)Veri Bankası sisteminde kaç tane benzersiz düğüm vardır?

select 
	count(distinct node_id) node_count 
from customer_nodes		

2.)What is the number of nodes per region?
2.)Bölge başına düğüm sayısı nedir?

select 
		r.region_id,
		r.region_name,
		count(node_id) as node_count 
from customer_nodes as cn 
left join regions as r on r.region_id=cn.region_id
group by 1,2
order by 1 

3.)How many customers are allocated to each region?
3.)Her bölgeye kaç müşteri tahsis edilmiştir?

select 
		r.region_id,
		r.region_name,
		count(distinct customer_id) as customers_count
	from customer_nodes as cn 
left join regions as r on r.region_id=cn.region_id
group by 1,2 
order by 1 

4.)How many days on average are customers reallocated to a different node?
4.)Müşteriler ortalama kaç günde farklı bir düğüme yeniden tahsis ediliyor?

select * from customer_nodes 

select * from customer_transactions 

select * from regions 


select 
	round(avg(end_date-start_date),2) as avg_number 
from customer_nodes 
where end_date != '9999-12-31'

5.)What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
5.)Her bir bölge için aynı yeniden tahsis günleri metriği için medyan, 80. ve 95. yüzdelik dilimler nedir?

with date_diff as 

(
	select 
		cn.region_id,
	r.region_name,
	(end_date-start_date) as diff_date
 	from customer_nodes as cn
left join regions as r on r.region_id=cn.region_id	
	where cn.end_date != '9999-12-31'

) 
select 
	region_id,
	region_name,
	percentile_cont(0.5) within group (order by diff_date) as percentile_80,
	 percentile_cont(0.8) within group (order by diff_date) as percentile_80,
		percentile_cont(0.95) within group (order by diff_date) as percentile_95
from date_diff 
group by 1,2
order by 1 

--B. Customer Transactions

/*
1.)What is the unique count and total amount for each transaction type?
1.)Her bir işlem türü için benzersiz sayı ve toplam tutar nedir?
*/

select * from customer_nodes 

select * from customer_transactions 

select * from regions 


select 
	 txn_type , count(distinct customer_id) as unique_count ,
		sum(txn_amount) as total_amount 
	from customer_transactions 	
	group by 1
	order by 1
	
/*
2.)What is the average total historical deposit counts and amounts for all customers?
2.)Tüm müşteriler için ortalama toplam geçmiş mevduat sayıları ve tutarları nedir?
*/

with deposit as 
(	select  
	customer_id,
		txn_type,
			sum(txn_amount) as deposit_amount,
	count(txn_type) as deposit_count
	from customer_transactions
	where txn_type='deposit'
	group by 1,2
	order by 1
)
select txn_type ,
round(avg(deposit_count),2) as avg_deposit_count,
round(avg(deposit_amount),2) as avg_deposit_amount
from deposit 
group by 1

/*
3.)For each month - 
how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
3.)Her ay için - kaç
Data Bank müşterisi tek bir ay içinde 1 den fazla para yatırma ve 1 satın alma veya 1 para çekme işlemi gerçekleştiriyor?
*/

select * from customer_transactions 

with payment_type as 
(	
select 
		customer_id,
	to_char(txn_date,'Month') as for_each_month, 
		count(case when txn_type='deposit' then 1 end) as deposit_count,
		 count(case when txn_type='purchase' then 1 end) as purchase_count,
		  count(case when  txn_type='withdrawal' then 1 end ) as withdrawal_count
	from customer_transactions 
	group by 1,2	
)
select 
			count(distinct customer_id) as customer_count,
		for_each_month
	from payment_type 
		where deposit_count > 1 and (purchase_count > 0 or withdrawal_count > 0 )
		 group by 2 
		   order by 1 
		
/*		
4.)What is the closing balance for each customer at the end of the month?
4.)Ay sonunda her bir müşteri için kapanış bakiyesi nedir?
*/

with eom as 

(
select 
	customer_id,
		(date_trunc('month',txn_date)+interval '1 month - 1 day')::date as end_of_month,
		   sum(case when txn_type='deposit' then txn_amount else -1 * txn_amount end ) as total_amount
 from customer_transactions
	group by 1,2
)
select customer_id,
		 to_char("end_of_month",'Month') as month_name,
		    sum(total_amount) over(partition by customer_id order by end_of_month) as closing_balance
from eom

/*
5.)What is the percentage of customers who increase their closing balance by more than 5%?
5.)Kapanış bakiyesini %5'ten fazla artıran müşterilerin yüzdesi nedir?
*/
with table1 as 
(
select distinct customer_id,
       to_char(txn_date, 'MM') as months,
       sum(case 
           when txn_type = 'deposit' then txn_amount
                                     else -txn_amount end) as net_transaction_amount
from customer_transactions as ct
group by 1,2
order by 1
),
table2 as 
(
select customer_id,
       months,
       sum(net_transaction_amount) over (partition by customer_id order by months) as closing_balance
from table1
),
table3 as 
(
select customer_id,
       months,
       closing_balance
from table2
where closing_balance > 0
),
table4 as 
(
select customer_id,
       months,
       closing_balance,
       lag(closing_balance) over (partition by customer_id order by months) as prev_closing_balance
from table3
),
table5 as 
(
select customer_id,
       months,
       closing_balance,
       case
           when prev_closing_balance = 0 then null
           else (closing_balance - prev_closing_balance) / prev_closing_balance * 100
       end as percent_change
from table4
)
select round(count(customer_id) * 100.0 / (select count(customer_id) from table5),2) as percent_of_customers
from table5
where percent_change > 5


--C. Data Allocation Challenge

/*
1. running customer balance column that includes impact of each transaction
Steps:

Calculate the running balance for each customer based on the order of their transaction.

Adjust the 'txn_amount' to be negative for withdrawal and purchase transactions to reflect a negative balance.
*/


select 
	customer_id,
	txn_date,
	txn_type,
	txn_amount,
	sum(case when txn_type='deposit' then txn_amount
	   		when txn_type='withdrawal' then -txn_amount
	   			when txn_type='purchase' then -txn_amount
	   
	   else 0 end) over(partition by customer_id order by txn_date) as running_balance
	   	
from customer_transactions		


/*
2. customer balance at the end of each month
Steps:

Calculate the closing balance for each customer for each month

Adjust the 'txn_amount' to be negative for withdrawal and purchase transactions to reflect a negative balance
*/


select 
	customer_id,
	to_char("txn_date",'Month') as month,
	sum(case when txn_type='deposit' then txn_amount
	   		when txn_type='withdrawal' then -txn_amount
	   			when txn_type='purchase' then -txn_amount
	   
	   else 0 end) as closing_balance 	   	
from customer_transactions	
group by 1,2
order by 1 

/*
3. minimum, average and maximum values of the running balance for each customer
Steps:

Use a CTE to find the running balance of each customer based on the order of transaction

Then calculate the minimum, maximum, and average balance for each customer.
*/

with running_balance as 

(
select 
	customer_id,
	txn_date,
	txn_type,
	txn_amount,
	sum(case when txn_type='deposit' then txn_amount
	   		when txn_type='withdrawal' then -txn_amount
	   			when txn_type='purchase' then -txn_amount
	   
	   else 0 end) over(partition by customer_id order by txn_date) as running_balance
	   	
from customer_transactions	
)
select 
	customer_id,
		round(avg(running_balance),2) as avg_running_balance,
		min(running_balance) as min_running_balance,
		max(running_balance) as max_running_balance
	from running_balance 
	group by 1 
	
	
--option 1 :

WITH transaction_amt_cte AS
(
	SELECT customer_id,
	       txn_date,
	       extract (month from txn_date) AS txn_month,
	       txn_type,
	       CASE WHEN txn_type = 'deposit' THEN txn_amount 
		    ELSE -txn_amount 
	       END AS net_transaction_amt
	FROM customer_transactions
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_date,
	       txn_month,
	       net_transaction_amt,
	       SUM(net_transaction_amt) OVER(PARTITION BY customer_id, txn_month ORDER BY txn_date
	      		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_customer_balance
	FROM transaction_amt_cte
),

customer_end_month_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       MAX(running_customer_balance) AS month_end_balance
	FROM running_customer_balance_cte
	GROUP BY customer_id, txn_month
)

SELECT txn_month,
       SUM(month_end_balance) AS data_required_per_month
FROM customer_end_month_balance_cte
GROUP BY txn_month
ORDER BY data_required_per_month DESC
	
	

	
	
	
--option 2:

WITH transaction_amt_cte AS
(
	SELECT customer_id,
               EXTRACT (month FROM txn_date) AS txn_month,
	       SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
		        ELSE -txn_amount
		    END) AS net_transaction_amt
	FROM customer_transactions
	GROUP BY customer_id, EXTRACT (month FROM txn_date)
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       net_transaction_amt,
	       SUM(net_transaction_amt) OVER(PARTITION BY customer_id ORDER BY txn_month) AS running_customer_balance
	FROM transaction_amt_cte
),

avg_running_customer_balance AS
(
	SELECT customer_id,
	       AVG(running_customer_balance) AS avg_running_customer_balance
	FROM running_customer_balance_cte
	GROUP BY customer_id
)

SELECT txn_month,
       ROUND(SUM(avg_running_customer_balance), 0) AS data_required_per_month
FROM running_customer_balance_cte r
JOIN avg_running_customer_balance a
ON r.customer_id = a.customer_id
GROUP BY txn_month
ORDER BY data_required_per_month;



--option 3:


WITH transaction_amt_cte AS
(
	SELECT customer_id,
	       txn_date,
	       EXTRACT (month FROM txn_date) AS txn_month,
	       txn_type,
	       txn_amount,
	       CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END AS net_transaction_amt
	FROM customer_transactions
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       SUM(net_transaction_amt) OVER (PARTITION BY customer_id ORDER BY txn_month) AS running_customer_balance
	FROM transaction_amt_cte
)

SELECT txn_month,
       SUM(running_customer_balance) AS data_required_per_month
FROM running_customer_balance_cte
GROUP BY txn_month
ORDER BY data_required_per_month;


--D. Extra Challenge


WITH cte AS
(
 SELECT customer_id,
	       txn_date,
	       SUM(txn_amount) AS total_data,
	       TO_DATE (EXTRACT (YEAR FROM txn_date) || '-' || EXTRACT (MONTH FROM txn_date) || '-01', 'YYYY-MM-DD') AS month_start_date,
	       EXTRACT (DAY FROM AGE (txn_date, TO_DATE (EXTRACT (YEAR FROM txn_date) || '-' || EXTRACT (MONTH FROM txn_date) || '-01', 'YYYY-MM-DD'))) AS days_in_month,
	       CAST(SUM(txn_amount) AS DOUBLE PRECISION) * POWER((1 + 0.06/365), EXTRACT (DAY FROM AGE ('1900-01-01':: date, txn_date))) AS daily_interest_data
	FROM customer_transactions
	GROUP BY customer_id, txn_date
	ORDER BY customer_id
)

SELECT customer_id,
       TO_DATE (EXTRACT (YEAR FROM month_start_date) || '-' || EXTRACT (MONTH FROM month_start_date) || '-01', 'YYYY-MM-DD') AS txn_month,
     ROUND(SUM(daily_interest_data * days_in_month)::numeric, 2) AS data_required

FROM cte
GROUP BY customer_id, TO_DATE (EXTRACT (YEAR FROM month_start_date) || '-' || EXTRACT (MONTH FROM month_start_date) || '-01', 'YYYY-MM-DD')
ORDER BY data_required DESC;
