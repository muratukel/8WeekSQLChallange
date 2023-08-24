## 🪙 Case Study #4 - Data Bank 

## 💹 A. Customer Nodes Exploration

## 1.How many unique nodes are there on the Data Bank system?

```sql
select 
	count(distinct node_id) node_count 
from customer_nodes	;
```
| node_count |
|------------|
|     5      |

## 2.What is the number of nodes per region?

```sql
select 
		r.region_id,
		r.region_name,
		count(node_id) as node_count 
from customer_nodes as cn 
left join regions as r on r.region_id=cn.region_id
group by 1,2
order by 1 ;
```
| region_id | region_name | node_count |
|-----------|-------------|------------|
|     1     |  Australia  |    770     |
|     2     |   America   |    735     |
|     3     |    Africa   |    714     |
|     4     |     Asia    |    665     |
|     5     |    Europe   |    616     |

## 3.How many customers are allocated to each region?

```sql
select 
		r.region_id,
		r.region_name,
		count(distinct customer_id) as customers_count
	from customer_nodes as cn 
left join regions as r on r.region_id=cn.region_id
group by 1,2 
order by 1  ;
```
| region_id | region_name | customers_count |
|-----------|-------------|-----------------|
|     1     |  Australia  |      110       |
|     2     |   America   |      105       |
|     3     |    Africa   |      102       |
|     4     |     Asia    |       95       |
|     5     |    Europe   |       88       |

## 4.How many days on average are customers reallocated to a different node?

```sql
select 
	round(avg(end_date-start_date),2) as avg_number 
from customer_nodes 
where end_date != '9999-12-31' ;
```
| avg_number |
|------------|
|   14.63    |

## 5.What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```sql
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
order by 1 ;
```
| region_id | region_name | percentile_80 | percentile_80-2 | percentile_95 |
|-----------|-------------|---------------|-----------------|---------------|
|     1     |  Australia  |      15       |       23        |      28       |
|     2     |   America   |      15       |       23        |      28       |
|     3     |    Africa   |      15       |       24        |      28       |
|     4     |     Asia    |      15       |       23        |      28       |
|     5     |    Europe   |      15       |       24        |      28       |


