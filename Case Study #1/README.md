
### Case Study #1 - Danny's Diner 

![image](https://github.com/muratukel/8WeekSQLChallange/assets/136103635/937b628f-8862-4121-8472-b936dd5a1ca3)

### 📚 Table of Contents

- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT S.CUSTOMER_ID,
	SUM(PRICE) AS TOTAL_SPENT
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1
````
