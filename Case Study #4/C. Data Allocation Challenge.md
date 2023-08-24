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
| customer_id |   txn_date   |  txn_type   | txn_amount | running_balance |
|-------------|--------------|-------------|------------|-----------------|
|      1      |  2020-01-02  |   deposit   |    312     |      312        |
|      1      |  2020-03-05  |  purchase   |    612     |      -300       |
|      1      |  2020-03-17  |   deposit   |    324     |       24        |
|      1      |  2020-03-19  |  purchase   |    664     |      -640       |
|      2      |  2020-01-03  |   deposit   |    549     |      549        |
|      2      |  2020-03-24  |   deposit   |    61      |      610        |
|      3      |  2020-01-27  |   deposit   |    144     |      144        |
|      3      |  2020-02-22  |  purchase   |    965     |      -821       |
|      3      |  2020-03-05  | withdrawal  |    213     |     -1034       |
|      3      |  2020-03-19  | withdrawal  |    188     |     -1222       |

# The first 10 lines are shown.
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
| customer_id |  month   | closing_balance |
|-------------|----------|-----------------|
|      1      |   March  |      -952       |
|      1      |  January |      312        |
|      2      |   March  |       61        |
|      2      |  January |      549        |
|      3      |  January |      144        |
|      3      |   March  |      -401       |
|      3      | February |      -965       |
|      3      |   April  |      493        |
|      4      |   March  |      -193       |
|      4      |  January |      848        |

# The first 10 lines are shown.
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
| customer_id | avg_running_balance | min_running_balance | max_running_balance |
|-------------|--------------------|--------------------|--------------------|
|      1      |      -151.00       |        -640        |        312         |
|      2      |      579.50        |        549         |        610         |
|      3      |      -732.40       |       -1222        |        144         |
|      4      |      653.67        |        458         |        848         |
|      5      |      -135.45       |       -2413        |        1780        |
|      6      |      624.00        |        -552        |        2197        |
|      7      |      2268.69       |        887         |        3539        |
|      8      |      173.70        |       -1029        |        1363        |
|      9      |      1021.70       |        -91         |        2030        |
|     10      |      -2229.83      |       -5090        |        556         |

# The first 10 lines are shown.
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
| txn_month | data_required_per_month |
|-----------|-------------------------|
|     1     |         362688          |
|     3     |         147514          |
|     2     |         130592          |
|     4     |          53982          |

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
| txn_month | data_required_per_month |
|-----------|-------------------------|
|     2     |         -79372          |
|     3     |         -75818          |
|     1     |         -65492          |
|     4     |         -63347          |

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
| txn_month | data_required_per_month |
|-----------|-------------------------|
|     3     |       -1292510          |
|     4     |        -553878          |
|     2     |        -250274          |
|     1     |         100631          |
