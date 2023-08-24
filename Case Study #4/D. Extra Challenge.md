## 🪙 Case Study #4 - Data Bank

## 💹 D. Extra Challenge

Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!


````sql
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
````
| customer_id |   txn_month   | data_required |
|-------------|---------------|---------------|
|     61      |  2020-03-01   |    143153.56  |
|     82      |  2020-01-01   |    136765.65  |
|     424     |  2020-02-01   |    111109.13  |
|     5       |  2020-03-01   |    109250.71  |
|     155     |  2020-03-01   |     99300.86  |
|     131     |  2020-01-01   |     98928.02  |
|     192     |  2020-02-01   |     98119.78  |
|     45      |  2020-01-01   |     97725.36  |
|     177     |  2020-03-01   |     96204.86  |
|     269     |  2020-01-01   |     96128.91  |

# The first 10 lines are shown.
