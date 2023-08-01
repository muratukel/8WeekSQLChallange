## 🪙 Case Study #4 - Data Bank

## 💹 C. Data Allocation Challenge

## 1.running customer balance column that includes the impact each transaction

````sql
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
````

## 2.customer balance at the end of each month

````sql
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
````

## 3.minimum, average and maximum values of the running balance for each customer

````sql
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
````

## option 1 :

````sql
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
````

## option 2:

````sql
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
````
## option 3:

````sql
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
````

