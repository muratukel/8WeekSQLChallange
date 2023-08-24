## 🪙 Case Study #4 - Data Bank

## 💹 B. Customer Transactions

## 1.What is the unique count and total amount for each transaction type?

````sql
select 
	 txn_type , count(distinct customer_id) as unique_count ,
		sum(txn_amount) as total_amount 
	from customer_transactions 	
	group by 1
	order by 1;
 ````
| txn_type   | unique_count | total_amount |
|------------|--------------|--------------|
| deposit    |     500      |   1359168    |
| purchase   |     448      |   806537     |
| withdrawal |     439      |   793003     |

## 2.What is the average total historical deposit counts and amounts for all customers?

````sql
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
group by 1;
 ````
| txn_type | avg_deposit_count | avg_deposit_amount |
|----------|-------------------|--------------------|
| deposit  |       5.34        |      2718.34       |

## 3.For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

````sql
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
		   order by 1 ;
 ````
| customer_count | for_each_month |
|----------------|----------------|
|      70        |    April       |
|     168        |   January      |
|     181        |   February     |
|     192        |     March      |

## 4.What is the closing balance for each customer at the end of the month?

````sql
with eom as 
(
select 
	customer_id,
	(date_trunc('month',txn_date)+interval '1 month - 1 day')::date as end_of_month,
	sum(case when txn_type='deposit' then txn_amount else -1 * txn_amount end ) as total_amount
 from customer_transactions
	group by 1,2
)
select
	customer_id,
	 to_char("end_of_month",'Month') as month_name,
	    sum(total_amount) over(partition by customer_id order by end_of_month) as closing_balance
from eom;
 ````
| customer_id | month_name | closing_balance |
|-------------|------------|-----------------|
|      1      |   January  |      312        |
|      1      |    March   |     -640        |
|      2      |   January  |      549        |
|      2      |    March   |      610        |
|      3      |   January  |      144        |
|      3      |  February  |     -821        |
|      3      |    March   |     -1222       |
|      3      |    April   |     -729        |
|      4      |   January  |      848        |
|      4      |    March   |      655        |


# The first 10 lines are shown.

## 5.What is the percentage of customers who increase their closing balance by more than 5%?

````sql
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
 ````
| percent_of_customers |
|----------------------|
|        31.80         |

