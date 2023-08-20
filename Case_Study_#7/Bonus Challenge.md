## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎Bonus Challenge

Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!

# ROAD 1 
````sql
with product_details_two as 
(
select 
	ph.id as style_id,
	ph.level_text as style_name,
	ph1.id as segment_id,
	ph1.level_text as segment_name,
	ph1.parent_id as category_id,
	ph2.level_text as category_name
from product_hierarchy as ph
left join product_hierarchy as ph1
	on ph.parent_id=ph1.id
left join product_hierarchy as ph2
	on ph1.parent_id=ph2.id
where ph.id between 7 and 18 
)
select 
	pp.product_id,
	pp.price,
	concat(pdt.style_name,' ', pdt.segment_name, ' - ', pdt.category_name) as product_name,
	pdt.category_id,
	pdt.segment_id,
	pdt.style_id,
	pdt.category_name,
	pdt.segment_name,
	pdt.style_name
from product_details_two as pdt 
left join product_prices as pp 
	on pp.id=pdt.style_id
````
| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name       |
|------------|-------|----------------------------------|-------------|------------|----------|---------------|--------------|------------------|
| "c4a632"   | 13    | "Navy Oversized Jeans - Womens" | 1           | 3          | 7        | "Womens"      | "Jeans"      | "Navy Oversized" |
| "e83aa3"   | 32    | "Black Straight Jeans - Womens" | 1           | 3          | 8        | "Womens"      | "Jeans"      | "Black Straight" |
| "e31d39"   | 10    | "Cream Relaxed Jeans - Womens"  | 1           | 3          | 9        | "Womens"      | "Jeans"      | "Cream Relaxed"  |
| "d5e9a6"   | 23    | "Khaki Suit Jacket - Womens"    | 1           | 4          | 10       | "Womens"      | "Jacket"     | "Khaki Suit"     |
| "72f5d4"   | 19    | "Indigo Rain Jacket - Womens"   | 1           | 4          | 11       | "Womens"      | "Jacket"     | "Indigo Rain"    |
| "9ec847"   | 54    | "Grey Fashion Jacket - Womens"  | 1           | 4          | 12       | "Womens"      | "Jacket"     | "Grey Fashion"   |
| "5d267b"   | 40    | "White Tee Shirt - Mens"        | 2           | 5          | 13       | "Mens"        | "Shirt"      | "White Tee"      |
| "c8d436"   | 10    | "Teal Button Up Shirt - Mens"   | 2           | 5          | 14       | "Mens"        | "Shirt"      | "Teal Button Up" |
| "2a2353"   | 57    | "Blue Polo Shirt - Mens"        | 2           | 5          | 15       | "Mens"        | "Shirt"      | "Blue Polo"      |
| "f084eb"   | 36    | "Navy Solid Socks - Mens"       | 2           | 6          | 16       | "Mens"        | "Socks"      | "Navy Solid"     |
| "b9a74d"   | 17    | "White Striped Socks - Mens"    | 2           | 6          | 17       | "Mens"        | "Socks"      | "White Striped"  |
| "2feb6b"   | 29    | "Pink Fluro Polkadot Socks - Mens" | 2       | 6          | 18       | "Mens"        | "Socks"      | "Pink Fluro

# ROAD 2
````sql
with gender as
    (
select 
    id as gender_id, 
    level_text as category 
from product_hierarchy 
where level_name='Category'
    ),
seg as 
    (
select 
    parent_id as gender_id,
    id as seg_id, 
    level_text as Segment 
from product_hierarchy 
where level_name='Segment'
    ),
style as 
    (
select 
    parent_id as seg_id,
    id as style_id, 
    level_text as Style
from product_hierarchy 
where level_name='Style'
    ),
prod_final as
    (
select 
    g.gender_id as category_id,
    category as category_name,
    s.seg_id as segment_id,
    segment as segment_name,
    style_id,
    style as style_name
from gender as g 
left join seg as s 
on g.gender_id = s.gender_id
left join style st 
on s.seg_id = st.seg_id
     )
select 
    product_id, 
    price,
    concat(style_name,' ',segment_name,' - ',category_name) as product_name,
    category_id,
    segment_id,
    style_id,
    category_name,
    segment_name,
    style_name 
from  prod_final as pf 
left join product_prices as pp
on pf.style_id=pp.id	
````	
| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name       |
|------------|-------|----------------------------------|-------------|------------|----------|---------------|--------------|------------------|
| "c4a632"   | 13    | "Navy Oversized Jeans - Womens" | 1           | 3          | 7        | "Womens"      | "Jeans"      | "Navy Oversized" |
| "e83aa3"   | 32    | "Black Straight Jeans - Womens" | 1           | 3          | 8        | "Womens"      | "Jeans"      | "Black Straight" |
| "e31d39"   | 10    | "Cream Relaxed Jeans - Womens"  | 1           | 3          | 9        | "Womens"      | "Jeans"      | "Cream Relaxed"  |
| "d5e9a6"   | 23    | "Khaki Suit Jacket - Womens"    | 1           | 4          | 10       | "Womens"      | "Jacket"     | "Khaki Suit"     |
| "72f5d4"   | 19    | "Indigo Rain Jacket - Womens"   | 1           | 4          | 11       | "Womens"      | "Jacket"     | "Indigo Rain"    |
| "9ec847"   | 54    | "Grey Fashion Jacket - Womens"  | 1           | 4          | 12       | "Womens"      | "Jacket"     | "Grey Fashion"   |
| "5d267b"   | 40    | "White Tee Shirt - Mens"        | 2           | 5          | 13       | "Mens"        | "Shirt"      | "White Tee"      |
| "c8d436"   | 10    | "Teal Button Up Shirt - Mens"   | 2           | 5          | 14       | "Mens"        | "Shirt"      | "Teal Button Up" |
| "2a2353"   | 57    | "Blue Polo Shirt - Mens"        | 2           | 5          | 15       | "Mens"        | "Shirt"      | "Blue Polo"      |
| "f084eb"   | 36    | "Navy Solid Socks - Mens"       | 2           | 6          | 16       | "Mens"        | "Socks"      | "Navy Solid"     |
| "b9a74d"   | 17    | "White Striped Socks - Mens"    | 2           | 6          | 17       | "Mens"        | "Socks"      | "White Striped"  |
| "2feb6b"   | 29    | "Pink Fluro Polkadot Socks - Mens" | 2       | 6          | 18       | "Mens"        | "Socks"      | "Pink Fluro Polkadot" |
