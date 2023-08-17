## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎High Level Sales Analysis

## 1.What was the total quantity sold for all products?
````sql
select 	
	pd.product_name,
	sum(qty) as total_quantity
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id 
group by 1	
````
| Product Name                     | Total Quantity |
|----------------------------------|----------------|
| White Tee Shirt - Mens           | 3800           |
| Navy Solid Socks - Mens          | 3792           |
| Grey Fashion Jacket - Womens     | 3876           |
| Navy Oversized Jeans - Womens    | 3856           |
| Pink Fluro Polkadot Socks - Mens | 3770           |
| Khaki Suit Jacket - Womens       | 3752           |
| Black Straight Jeans - Womens    | 3786           |
| White Striped Socks - Mens       | 3655           |
| Blue Polo Shirt - Mens           | 3819           |
| Indigo Rain Jacket - Womens      | 3757           |
| Cream Relaxed Jeans - Womens     | 3707           |
| Teal Button Up Shirt - Mens      | 3646           |


## 2.What is the total generated revenue for all products before discounts?	
````sql	 
select 
	pd.product_name,
	sum(s.price*s.qty) as total_revenue 
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1
````
| Product Name                     | Total Revenue |
|----------------------------------|---------------|
| White Tee Shirt - Mens           | 152000        |
| Navy Solid Socks - Mens          | 136512        |
| Grey Fashion Jacket - Womens     | 209304        |
| Navy Oversized Jeans - Womens    | 50128         |
| Pink Fluro Polkadot Socks - Mens | 109330        |
| Khaki Suit Jacket - Womens       | 86296         |
| Black Straight Jeans - Womens    | 121152        |
| White Striped Socks - Mens       | 62135         |
| Blue Polo Shirt - Mens           | 217683        |
| Indigo Rain Jacket - Womens      | 71383         |
| Cream Relaxed Jeans - Womens     | 37070         |
| Teal Button Up Shirt - Mens      | 36460         |

## 3.What was the total discount amount for all products?
````sql 
select 
	pd.product_name,
	sum(s.price * s.qty * s.discount/100) as total_discount
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1	
````
| Product Name                     | Total Discount |
|----------------------------------|----------------|
| White Tee Shirt - Mens           | 17968          |
| Navy Solid Socks - Mens          | 16059          |
| Grey Fashion Jacket - Womens     | 24781          |
| Navy Oversized Jeans - Womens    | 5538           |
| Pink Fluro Polkadot Socks - Mens | 12344          |
| Khaki Suit Jacket - Womens       | 9660           |
| Black Straight Jeans - Womens    | 14156          |
| White Striped Socks - Mens       | 6877           |
| Blue Polo Shirt - Mens           | 26189          |
| Indigo Rain Jacket - Womens      | 8010           |
| Cream Relaxed Jeans - Womens     | 3979           |
| Teal Button Up Shirt - Mens      | 3925           |

