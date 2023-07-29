
### Case Study #1 - Danny's Diner 

![image](https://github.com/muratukel/8WeekSQLChallange/assets/136103635/937b628f-8862-4121-8472-b936dd5a1ca3)
***
##Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
***






**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT S.CUSTOMER_ID,
	SUM(PRICE) AS TOTAL_SPENT
FROM SALES AS S
LEFT JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
GROUP BY 1
````
