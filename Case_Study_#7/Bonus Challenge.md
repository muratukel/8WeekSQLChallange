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
