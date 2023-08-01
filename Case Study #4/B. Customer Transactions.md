## 🪙 Case Study #4 - Data Bank

## 💹 B. Customer Transactions

## 1.What is the unique count and total amount for each transaction type?

````sql
select 
	 txn_type , count(distinct customer_id) as unique_count ,
		sum(txn_amount) as total_amount 
	from customer_transactions 	
	group by 1
	order by 1
 ````
