Data Exploration and Cleansing

##1.Update the fresh_segments.interest_metrics table by modifying the month_year 
	column to be a date data type with the start of the month
	
##1.month_year sütununu ayın başlangıcını içeren bir tarih veri türü olacak şekilde değiştirerek 
	fresh_segments.interest_metrics tablosunu güncelleyin
	

select * from interest_metrics

ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year || '-01', 'MM-YYYY-DD');

##2.What is count of records in the fresh_segments.interest_metrics for each month_year value 
	sorted in chronological order (earliest to latest) with the null values appearing first?
	
##2.fresh_segments.interest_metrics dosyasında kronolojik sıraya göre (en eskiden en yeniye) 
	sıralanmış her ay_yıl değeri için kayıt sayısı kaçtır ve null değerler önce görünür?	

select 
	month_year,
	count(*)
from interest_metrics
group by 1
order by 1 asc nulls first

##3.What do you think we should do with these null values in the fresh_segments.interest_metrics
##3.fresh_segments.interest_metrics dosyasındaki bu null değerlerle ne yapmamız gerektiğini düşünüyorsunuz?

Let s review some methods to deal with missing values:
	-Remove them
	-Infer them from available data points
	-Replace them with mean, mode or median of the columns
	
Thus, the most suitable approach in our case is to remove those NULL values as we are unable 
to speficy which date those records are assigned to and they wont be useful for us

DELETE FROM interest_metrics
WHERE month_year IS NULL

##4.How many interest_id values exist in the fresh_segments.interest_metrics table but not in 
	the fresh_segments.interest_map table? What about the other way around?
	
##4.fresh_segments.interest_metrics tablosunda olup da 
	fresh_segments.interest_map tablosunda olmayan kaç tane interest_id değeri var? Peki ya tam tersi?	
	
ALTER TABLE interest_metrics
ALTER COLUMN interest_id TYPE INTEGER USING interest_id::integer;
	

ROAD 1	

SELECT
	
    (SELECT COUNT(DISTINCT im.interest_id) 
     FROM interest_metrics AS im
     LEFT JOIN interest_map AS i ON im.interest_id = i.id
     WHERE i.id IS NULL) AS missing_in_metrics,

    (SELECT COUNT(DISTINCT i.id)
     FROM interest_map AS i
     LEFT JOIN interest_metrics AS im ON i.id = im.interest_id
     WHERE im.interest_id IS NULL) AS missing_in_map;

ROAD 2 

select 
	count(distinct i.interest_id) as interest_id_metrics,
	count(distinct im.id) as interest_id_map ,
	sum(case 
	   		when im.id is null then 1 end) as missing_in_metric,
	sum(case
	   		when i.interest_id is null then 1 end ) missing_in_map
from interest_metrics as i
full outer join interest_map as im
	on im.id=i.interest_id

ROAD 3

## with ile yazmak istedim belki daha iyi anlayabilirsiniz.
WITH MetricsMissing AS (
    SELECT COUNT(DISTINCT im.interest_id) AS missing_in_metrics
    FROM interest_metrics AS im
    LEFT JOIN interest_map AS i ON im.interest_id = i.id
    WHERE i.id IS NULL
),
MapMissing AS (
    SELECT COUNT(DISTINCT i.id) AS missing_in_map
    FROM interest_map AS i
    LEFT JOIN interest_metrics AS im ON i.id = im.interest_id
    WHERE im.interest_id IS NULL
)
SELECT MetricsMissing.missing_in_metrics, MapMissing.missing_in_map
FROM MetricsMissing, MapMissing

##5.Summarise the id values in the fresh_segments.interest_map by its total record count in this table
##5.fresh_segments.interest_mapteki id değerlerini bu tablodaki toplam kayıt sayısına göre özetleyin

select 
	 distinct id,
	 interest_name,
	 count(*) as total_record_count 
from interest_map as im 
left join interest_metrics as i
	on i.interest_id=im.id
group by 1,2
order by 3 desc 

##6.What sort of table join should we perform for our analysis and why? 
	Check your logic by checking the rows where interest_id = 21246 in your 
	joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.
	interest_map except from the id column.

##6.Analizimiz için ne tür bir tablo birleştirme gerçekleştirmeliyiz ve neden? Birleştirilmiş çıktınızda 
	interest_id = 21246 olan satırları kontrol ederek mantığınızı kontrol edin ve fresh_segments.interest_metricsteki 
	tüm sütunları ve id sütunu hariç fresh_segments.interest_mapteki tüm sütunları dahil edin.

select 
	im.*,
	i.interest_name,
	i.interest_summary,
	i.created_at,
	i.last_modified
from interest_metrics as im
inner join interest_map as i 
	on i.id=im.interest_id 
where im.interest_id = 21246	

##7.Are there any records in your joined table where the month_year value is before 
	the created_at value from the fresh_segments.interest_map table? 
	Do you think these values are valid and why?
	
##7.Birleştirilmiş tablonuzda, month_year değerinin 
	fresh_segments.interest_map tablosundaki created_at değerinden önce olduğu herhangi bir kayıt var mı? 
	Bu değerlerin geçerli olduğunu düşünüyor musunuz ve neden?	
	
select
	im.*,
	i.interest_name,
	i.interest_summary,
	i.created_at,
	i.last_modified
from interest_metrics as im
left join interest_map as i
	on i.id=im.interest_id
where im.month_year<i.created_at	

##!NOTE:month_year da ayın 1.günlerini ekledik bunun için created_at ayları içerisinde yer aldığı için dahil ederiz.yani month_year 
günlerinin created_at tarihinden büyük olduğu ihtimalleri de bulunmaktadır.
	
Interest Analysis

##1.Which interests have been present in all month_year dates in our dataset?
##1.Veri setimizdeki tüm ay_yıl tarihlerinde hangi ilgi alanları mevcuttu?

ROAD 1

select 
	i.interest_name	
from interest_metrics as im 
inner join interest_map as i
	on i.id=im.interest_id
group by 1
having count(distinct im.month_year) = (select count(distinct month_year) from interest_metrics)

ROAD 2

#burada kaç benzersiz interest_name ve month_year değerlerine bakıyorum with(cte) ile sorguyu bitiriyorum.
select 
	count(distinct interest_name) as total_interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id

with cte as (
	select 
	interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
) select 
		c.total_months,
		count(distinct interest_name) 
from cte as c 	
group by 1 
order by 2 desc 
limit 1


select 
	count(distinct interest_name) as total_interest_name,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
	
##2.Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months 
	- which total_months value passes the 90% cumulative percentage value?
		
##2.Aynı total_months hesaplamasını kullanarak - 14 aydan başlayarak tüm kayıtların kümülatif yüzdesini hesaplayın 
	- hangi total_months değeri %90 kümülatif yüzde değerini geçer?	
	
with cte_months as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
), cte_counts as (

select 
		total_months,
		count(distinct interest_id) as interest_counts 
from cte_months  	
group by 1 

) , cumulative_percent as (
select 
	total_months,
	interest_counts,
	sum(interest_counts) over(order by total_months desc) as cumulative_sum,
	round(sum(interest_counts) over(order by total_months desc)*1.0/(select sum(interest_counts) from cte_counts)*1.0*100,2) 
		as cumulative_percentage 
from cte_counts
) select 
	total_months,
	interest_counts,
	cumulative_sum,
	cumulative_percentage
from cumulative_percent
	where cumulative_percentage>90
	
##3.If we were to remove all interest_id values which are lower than the total_months value we found in the previous question 
	- how many total data points would we be removing?

##3.Önceki soruda bulduğumuz total_months değerinden daha düşük olan tüm interest_id değerlerini kaldıracak olsaydık 
	- toplam kaç veri noktasını kaldırmış olurduk?
	
with cte_months as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
)
select 
	sum(total_months) total_data_removing
from cte_months 
where total_months<6

##4.Does this decision make sense to remove these data points from a business perspective? 
	Use an example where there are all 14 months present to a removed interest example for your arguments 
	- think about what it means to have less months present from a segment perspective.
	
##4.İş perspektifinden bakıldığında bu veri noktalarını kaldırma kararı mantıklı mı? 
	Argümanlarınız için kaldırılmış bir faiz örneğinde 14 ayın tamamının mevcut olduğu bir örnek kullanın 
	- segment perspektifinden daha az ayın mevcut olmasının ne anlama geldiğini düşünün.
ROAD 1

with  removed_month_interest as (
	select 
	interest_id,
	count(distinct im.month_year) as total_months 
from interest_metrics as im 
left join interest_map as i
	on i.id=im.interest_id
group by 1
	having count(distinct im.month_year)<6
),removed_interest as 
(select 
 	month_year, 
 	count(*) as removed_interest
from interest_metrics
where interest_id in (select interest_id from removed_month_interest) 
group by month_year
),not_removed_interest as 
(
select 
 	month_year, 
 	count(*) as not_removed_interest
from interest_metrics
where interest_id not in (select interest_id from removed_month_interest) 
group by month_year
)
select 
	ri.month_year,
	ri.removed_interest,
	nri.not_removed_interest,
	round(removed_interest*1.0/(removed_interest+not_removed_interest)*1.0*100,2) as removed_rate
from removed_interest as ri
left join not_removed_interest as nri 
	on nri.month_year=ri.month_year
order by 1 asc

ROAD 2 

with month_counts as (
    select interest_id, count(distinct month_year) as month_count
    from interest_metrics
    group by 1
    having count(distinct month_year) < 6 
)
select 
    im.month_year,
    count(case 
		  	when im.interest_id in (select interest_id from month_counts) then 1 end) as removed_interest,
    count(case 
		  	when im.interest_id not in (select interest_id from month_counts) then 1 end) as present_interest,
    round(count(case when im.interest_id in (select interest_id from month_counts) then 1 end) * 100.0 /
          (count(case when im.interest_id in (select interest_id from month_counts) then 1 end) +
           count(case when im.interest_id not in (select interest_id from month_counts) then 1 end)), 2) as removed_prcnt
from interest_metrics im
group by 1
order by 1 asc


##5.After removing these interests - how many unique interests are there for each month?
##5.Bu ilgi alanlarını çıkardıktan sonra - her ay için kaç tane benzersiz ilgi alanı var?

with month_counts as 
(
select 
	interest_id,
	count(distinct month_year) as month_count
from interest_metrics 
group by 1
	having count(distinct month_year)<6
)
select 
		ime.month_year,
		count(case
			 		when ime.interest_id not in (select interest_id from month_counts) then 1 end) as not_removed_interest
from interest_metrics as ime
group by 1
order by 1 asc

Segment Analysis

##1.Using our filtered dataset by removing the interests with less than 6 months worth of data, 
	which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
	Only use the maximum composition value for each interest but you must keep the corresponding month_year

##1.Veri kümesini, 6 aydan az veriye sahip olan ilgi alanlarını çıkararak filtrelediğimizde, herhangi bir 'month_year' 
	için en büyük bileşim değerine sahip olan en üst 10 ve en düşük 10 ilgi alanını bulunuz. 
	Ancak her bir ilgi alanı için sadece en büyük bileşim değerini kullanmalısınız, ancak ilgili 'month_year' değerini korumalısınız.

-- burada bir output ile top10 ve bottom10 değerlerini göstermeye çalıştım.

with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition desc 
    limit 10 
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
    ma.interest_id,
    ma.month_year,
    ma.composition,
    mi.interest_id,
    mi.month_year,
    mi.composition
from max_composition as ma
full outer join  min_composition as mi
    on ma.interest_id = mi.interest_id


--top 10 

with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition desc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from max_composition as ma


--bottom 10 

with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from min_composition as ma


--union all ile alt alta gösterebiliriz.

with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
    
), max_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id in (select interest_id from not_removed_interest) 
    order by im.composition desc 
    limit 10 
), min_composition as (
    select 
        im.interest_id,
        im.month_year,
        im.composition
    from interest_metrics as im
    join not_removed_interest nri on im.interest_id = nri.interest_id
	where im.interest_id  in (select interest_id from not_removed_interest) 
    order by im.composition asc
    limit 10 
)
select 
  interest_id,
  month_year,
  composition
from max_composition as ma

union all

select 
  interest_id,
  month_year,
  composition
from min_composition as ma


--filtereli tablo oluşturmak.(ilerleyen sorularda lazım olabilir.Ya da filterelenmiş bir tablo isteyebilirsiniz.)
with table1 as
(
    select 
        interest_id, 
        interest_name,
        count(distinct month_year) as month_count
    from interest_metrics as im
    left join interest_map as inmap
    ON inmap.id = im.interest_id::integer
    group by 1,2
    having count(distinct month_year) < 6 
)
select 
    interest_name,
    im.*
into filtered_table
from interest_metrics as im 
left join interest_map as inmap
ON inmap.id = im.interest_id::integer
where im.interest_id not in (select interest_id from table1)

select * from filtered_table

##2.Which 5 interests had the lowest average ranking value?
##2.Hangi 5 ilgi alanı en düşük ortalama sıralama değerine sahipti?

ROAD 1

select 
	interest_id,
	interest_name,
	round(avg(ranking),2) as avg_ranking 
from filtered_table 
group by 1,2
order by 3 asc
limit 5

ROAD 2

with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
 )   
,filter_table as 
(
select 
	ime.month_year,
	ime.interest_id,
	ima.interest_name,
	ime.ranking
from interest_metrics as ime
	left join interest_map as ima on ima.id=ime.interest_id
where ime.interest_id  in (select interest_id from not_removed_interest)
)
select 
	interest_id,
	interest_name,
	round(avg(ranking),2) as avg_ranking
from filter_table 
group by 1,2
order by 3 asc
limit 5

##3.Which 5 interests had the largest standard deviation in their percentile_ranking value?
##3.Hangi 5 ilgi alanı yüzdelik_sıralama değerlerinde en büyük standart sapmaya sahipti?


with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
 )   
,filter_table as 
(
select 
	ime.month_year,
	ime.interest_id,
	ima.interest_name,
	ime.percentile_ranking
from interest_metrics as ime
	left join interest_map as ima on ima.id=ime.interest_id
where ime.interest_id  in (select interest_id from not_removed_interest)
)
select 
	interest_id,
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as std_dev_ranking
from filter_table 
group by 1,2
order by 3 desc 
limit 5

--oluşturduğumuz filtered_table ile de yapabiliriz.

select 
	interest_id,
	interest_name,
	round(stddev(percentile_ranking)::numeric,2) as std_dev_ranking
from filtered_table 
group by 1,2
order by 3 desc
limit 5

##4.For the 5 interests found in the previous question - 
	what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
	Can you describe what is happening for these 5 interests?
	
##4.Önceki soruda bulunan 5 ilgi alanı için, her bir ilgi alanının 
	minimum ve maksimum percentile_ranking değerleri ile ilgili year_month değerleri nedir? 
	5 ilgi alanı için neler oluyor, açıklayabilir misiniz?	
	
with not_removed_interest as 
(  select interest_id,count(distinct month_year) as month_count
        from interest_metrics
        group by 1
        having count(distinct month_year) >=6	
 )   
,filter_table as 
(
select 
	ime.month_year,
	ime.interest_id,
	ima.interest_name,
	ime.percentile_ranking
from interest_metrics as ime
	left join interest_map as ima on ima.id=ime.interest_id
where ime.interest_id  in (select interest_id from not_removed_interest)
),stdev as 
(select 
	interest_id,
	interest_name,
 	percentile_ranking,
	round(stddev(percentile_ranking)::numeric,2) as std_dev_ranking
from filter_table 
group by 1,2,3
order by 4 desc 
limit 5
),min_max_percentile as 
(
 select
	ft.interest_id, 
	ft.month_year,
	s.interest_name, 
	max(ft.percentile_ranking) as max_percentile,
	min(ft.percentile_ranking) as min_percentile
from  stdev as s 
inner join filter_table as ft
 	on ft.interest_id=s.interest_id
group by 1,2,3
),max_percentile as 
(
  select 
	mmp.interest_id, 
	s.interest_name,
	mmp.month_year as max_year, 
	max_percentile
 from  stdev as s 
inner join  min_max_percentile as mmp
 on mmp.interest_id=s.interest_id
 where  mmp.max_percentile = s.percentile_ranking
),min_percentile as 
(
select 
	mmp.interest_id, 
	s.interest_name,
	month_year as min_year, 
	min_percentile
from  stdev as s 
inner join  min_max_percentile as mmp
 on mmp.interest_id=s.interest_id
 where  mmp.min_percentile =s.percentile_ranking
)
select 
	mi.interest_id,
	mi.interest_name,
	min_year,
	min_percentile, 
	max_year, 
	max_percentile
from min_percentile as mi 
inner join max_percentile as ma 
	on mi.interest_id= ma.interest_id




--doğru yol bu şekilde.
with interests as
(
    select 
        interest_id, 
        f.interest_name,
        round(stddev(percentile_ranking)::numeric,2) as stdev_ranking
    from filtered_table f
    join interest_map as ma on
     f.interest_id::integer = ma.id
    group by 1,2
     order by 3 desc
    limit 5
),
percentiles as(
    select 
        i.interest_id, 
        f.interest_name, 
        max(percentile_ranking) as max_percentile,
        min(percentile_ranking) as min_percentile
    from filtered_table as f 
    left join interests as i
    on i.interest_id=f.interest_id
    group by 1,2
), 
max_per as (
    select 
        p.interest_id, 
        f.interest_name,
        month_year as max_year, 
        max_percentile
    from  filtered_table as f 
    left join percentiles as p
    on p.interest_id=f.interest_id
    where  max_percentile = percentile_ranking
),
min_per as ( 
    select 
        p.interest_id, 
        f.interest_name,
        month_year as min_year, 
        min_percentile
    from  filtered_table as f 
    left join percentiles as  p
    on p.interest_id=f.interest_id
    where  min_percentile = percentile_ranking
)
    select 
        mi.interest_id,
        mi.interest_name,
        min_year,
        min_percentile, 
        max_year, 
        max_percentile
    from min_per as mi 
    left join max_per as ma 
    on mi.interest_id= ma.interest_id


##5.How would you describe our customers in this segment based off their composition and ranking values? 
	What sort of products or services should we show to these customers and what should we avoid?
	
##5.Müşterilerimizi bu segment içerisinde, bileşim ve sıralama değerlerine dayalı olarak nasıl tanımlarsınız? 
	Bu müşterilere hangi tür ürün veya hizmetleri göstermeliyiz ve nelerden kaçınmalıyız?	


--Entertainment Industry Decision Makers: Eğlence Sektörü Karar Vericileri:

Sıralamada yüksek yüzdelik dilimde yer alıyorlar (86.15), bu nedenle nitelikli ve ilgili içeriklere yönlendirilmeliler.
Eğlence sektörünün sıralamada düşük yüzdelik dilimde olduğunda(11.23) büyük ihtimalle  eğlence sektörünün kaçması  
gerektiği sektörlerin ön planda olduğu zamanlar diyebiliriz. En yüksek olduklarına sıralama yüzdelerinde oldukça dikkat 
çekici bir hale geldiklerini söyleyebiliriz.En düşük oldukları sıralama yüzdeliklerinde halen nitelikli bir segment alanı 
olduklarını yani etkilerini gösterdiklerini söyleyebiliriz.

Gösterilmeli:Eğlence endüstrisi karar vericileri olarak, sektördeki yenilikler, liderler ve iş fırsatları hakkında 
içerikler sunulabilir.Bir komedi filminin veya spor karşılaşmasının eğlenceli yapım olabilmesi için 
ön koşul yapımın bireyler tarafından eğlendirici olarak görülebilmesidir.

Kaçınılmalı: Teknoloji veya finans konuları gibi sektörle ilgisi olmayan içerikler, düşük kaliteli veya sahte bilgilerden 
kaçınılmalıdır.


--Oregon Trip Planners: Oregon Seyahat Planlayıcıları:

2019-07-01 tarihinde düşük yüzdelik dilimde yer alıyorlar (2.2)yani farklı ilgi alanlarına sahip bir grup diyebiliriz. 
bu nedenle daha genel ve geniş kapsamlı içeriklere ilgi gösterebilirler.

Gösterilmeli: Oregon seyahat rehberleri, doğa gezileri için ekipman önerileri, bölgedeki etkinlikler ve festival bilgileri.

Kaçınılmalı: Başka bölgeler veya ülkelerle ilgili seyahat içerikleri, lüks seyahat veya yüksek bütçeli etkinlikler.

--Tampa and St Petersburg Trip Planners:
Bu segmente, bölgeye özgü gezi rehberleri, yerel etkinlik duyuruları ve konaklama önerileri sunmak etkili olabilir.

Gösterilmeli: Tampa ve St. Petersburg daki gezi rehberleri, yerel restoran ve kafe önerileri, yerel etkinlik duyuruları

Kaçınılmalı: Diğer bölgelerle ilgili seyahat içerikleri, soğuk veya kış odaklı etkinlikler.

--Techies:
Bu segment, teknoloji meraklılarını temsil ediyor.Yüksek yüzdelik dilimde yer alıyorlar (86.69), bu nedenle teknoloji odaklı 
içeriklere yönlendirilmeliler.

Gösterilmeli: Teknoloji trendleri, ürün incelemeleri, programlama rehberleri, yeni çıkan yazılımlar veya cihazlar hakkında içerikler.

Kaçınılmalı: Doğa sporları veya sanat gibi teknoloji dışı konular, düşük kaliteli veya eski teknoloji ile ilgili içerikler.

--Personalized Gift Shoppers:
Orta düzeyde yüzdelik dilimde yer alıyorlar (73.15), bu nedenle bu segmente yönelik özelleştirilmiş içerikler sunulabilir.
Kişiselleştirilmiş hediye fikirleri, özel ürün incelemeleri ve alışveriş ipuçları bu segmenti çekebilir.

Gösterilmeli: Kişiselleştirilmiş hediye fikirleri, özel ürün incelemeleri, hediye seçimi ipuçları.

Kaçınılmalı: Genel veya sıradan hediye fikirleri, kalitesiz veya yetersiz ürünlerle ilgili içerikler.

Index Analysis

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

##1.What is the top 10 interests by the average composition for each month?
##1.Her ay için ortalama bileşime göre ilk 10 ilgi alanı nedir?

with avg_composition as 
(
select
	month_year,
	interest_name,
		round((composition/index_value)::numeric, 2) as avg_composition,
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
)
select 
	*
from avg_composition 
	where rank_number <=10
	
##2.For all of these top 10 interests - which interest appears the most often?
##2.Tüm bu ilk 10 ilgi alanı için - en sık hangi ilgi alanı ortaya çıkıyor?

ROAD 1

with avg_composition as 
(
select
	month_year,
	interest_name,
	round((composition/index_value)::numeric, 2),
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
)
select 
	interest_name,
	count(interest_name) 
from avg_composition 
	where rank_number <=10
group by 1	
order by 2 desc

ROAD 2 

select 
    interest_name,
    count(interest_name) as interest_count
from (
    select
        ime.month_year,
        ima.interest_name,
        round((ime.composition / ime.index_value)::numeric, 2) as avg_composition,
        rank() over (partition by ime.month_year order by ime.composition / ime.index_value desc) as rank_number
    from interest_metrics as ime
    left join interest_map as ima on ima.id = ime.interest_id
) as subquery
where rank_number <= 10
group by interest_name
order by interest_count desc;

##3.What is the average of the average composition for the top 10 interests for each month?
##3.Her ay için ilk 10 ilgi alanı için ortalama bileşimin ortalaması nedir?


with avg_composition as 
(
select
	month_year,
	interest_name,
		round((composition/index_value)::numeric, 2) as avg_composition,
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
)
select 
	month_year,
	round(avg(avg_composition),2)
from avg_composition 
where rank_number <= 10
group by 1 	

##4.What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and 
	include the previous top ranking interests in the same output shown below.

##4.Eylül 2018'den Ağustos 2019'a kadar maksimum ortalama kompozisyon değerinin 3 aylık yuvarlanan ortalaması nedir ve 
	aşağıda gösterilen aynı çıktıya önceki en üst sıradaki ilgi alanlarını dahil edin.

with avg_composition as 
(
select
	month_year,
	interest_name,
		round((composition/index_value)::numeric, 2) as avg_composition,
	rank() over(partition by month_year order by composition/index_value desc) as rank_number
from interest_metrics as ime
left join interest_map as ima 
	on ima.id=ime.interest_id
), max_comp as 
(
select 
	month_year,
	max(avg_composition) as max_avg_comp
from avg_composition 
group by 1 
),rolling_avg as 
(
select 
	ac.month_year,
	ac.interest_name,
	max_avg_comp,
	round(avg(max_avg_comp)over(order by ac.month_year rows between 2 preceding and current row),2) as three_month_moving_avg
from avg_composition as ac
	left join max_comp as mc on mc.month_year=ac.month_year
	where avg_composition=max_avg_comp
)
,
month_1_lag as (
    select
        *,
        lag(interest_name) over (order by month_year) || ' : ' || lag(max_avg_comp) over (order by month_year) as one_month_ago
    from rolling_avg
),
month_2_lag as (
    select
        *,
        lag("one_month_ago") over (order by month_year) as two_month_ago
    from month_1_lag
)
select
    *
from month_2_lag
where month_year between '2018-09-01' and '2019-08-01'
order by month_year;
 
##5.Provide a possible reason why the max average composition might change from month to month? 
	Could it signal something is not quite right with the overall business model for Fresh Segments?	
	
-- Verilen çıktı incelendiğinde, aylık en yüksek ortalama bileşim değerlerinin aylar arasında değiştiği gözlemlenmektedir.
-- Bu değişikliklerin altında yatan olası nedenler çeşitlilik gösterebilir.
-- Mevsimsel dalgalanmalar, ilgi alanlarının taleplerini tatil dönemleri veya özel etkinlikler gibi faktörlere bağlı olarak artırabilir.
-- Pazar trendleri ve tüketici tercihlerinin değişmesi, yeni ürünlerin veya hizmetlerin popülaritesini artırabilirken, eski ilgi alanlarının geri planda kalmasına yol açabilir.
-- Rekabetin artması veya rekabetçi pazarlama stratejileri, ilgi alanlarının popülaritesinde dalgalanmalara neden olabilir.
-- Hedef kitlenin değişen ihtiyaçları ve tercihleri de aylık bileşim değerlerinde değişikliklere yol açabilir.
-- Ayrıca, hatalı veri toplama veya hesaplama, anormalliklere neden olabilir.
-- Bu faktörlerin kombinasyonu, aylık en yüksek ortalama bileşim değerlerinin farklılık göstermesine sebep olabilir.
-- Bu değişiklikler, iş modelini yeniden gözden geçirmeyi gerektirmese de, işinizi ve pazarınızı daha iyi anlamak ve rekabet avantajınızı korumak için bu değişikliklerin altındaki nedenleri anlamak son derece önemlidir.



/* Mevsimsel Değişimler: İlgi alanlarının popülaritesi mevsimsel olarak değişebilir. 
Örneğin, tatil dönemleri veya özel etkinlikler belirli ilgi alanlarının taleplerini artırabilir. 
Bu mevsimsel dalgalanmalar, aylık en yüksek ortalama bileşim değerlerinin farklılık göstermesine yol açabilir. */

/* Pazar Trendleri: Pazar trendleri ve tüketici tercihleri zamanla değişebilir. 
Yeni ürün veya hizmetlerin popülaritesi artabilirken, eski ilgi alanları geri planda kalabilir. 
Bu durum, aylık bileşim değerlerinde dalgalanmalar yaratabilir. */

/* Rekabet ve Reklam: Rakiplerinizin faaliyetleri veya reklam stratejileri, ilgi alanlarının popülaritesini etkileyebilir. 
Rekabetin artması veya agresif pazarlama kampanyaları, aylık bileşim değerlerinde değişikliklere neden olabilir. */

/* Hedef Kitlenin Değişimi: Hedef kitlenin ihtiyaçları ve tercihleri zaman içinde değişebilir. 
Bu, ilgi alanlarının taleplerinde dalgalanmalara yol açabilir. */

/* Hatalı Veri: Veri toplama veya hesaplama hataları, aylık bileşim değerlerinde anormalliklere yol açabilir. 
Bu durumda, aylık maksimum bileşim değerlerinin aniden değişmesi mümkündür. */

/* Bu nedenlerin herhangi biri veya birden fazlası, aylık en yüksek ortalama bileşim değerlerinin aydan aya değişmesine neden olabilir. 
Bu durum, iş modelini gözden geçirmeniz gerektiği anlamına gelmez, ancak işinizi ve pazarınızı daha iyi anlamak 
ve rekabet avantajınızı sürdürmek için bu değişikliklerin nedenlerini anlamak önemlidir. */



*Sezonluk Etkiler: 
İlgili sektör veya ilgi alanı, mevsimsel değişikliklere duyarlı olabilir. 
Örneğin, seyahat planlayıcılar yaz aylarında daha fazla aktifken kış aylarında daha düşük bir etkinlik gösterebilir. 
Bu mevsimsel dalgalanmalar, ilgi alanının doğasından kaynaklanıyor olabilir.

*Tatil Dönemleri: 
Tatiller, insanların alışveriş yapma, seyahat etme veya ilgi alanlarına daha fazla zaman ayırma eğilimini artırabilir. 
Tatil dönemlerinde talep artışı veya azalışı gözlenebilir. Özellikle belirli tatillerdeki artış veya azalışlar, bu değişikliğin nedenleri olabilir.

*Pazarlama Etkisi: 
Reklam kampanyaları, özel teklifler veya etkinlikler gibi pazarlama stratejileri, ilgi alanının talebinde dalgalanmalara neden olabilir. 
Yoğun pazarlama dönemlerinde ilgi artabilirken, kampanya sonrası düşebilir.

*Konkurens Etkiler: 
Pazardaki rekabet, müşterilerin ilgi alanlarını etkileyebilir. 
Yeni rakiplerin girmesi veya rekabetçi fiyatlamaların değişmesi, talep üzerinde etkili olabilir.

*Makroekonomik Faktörler: 
Ekonomik durum, insanların harcama alışkanlıklarını etkileyebilir. 
İstikrarlı ekonomik dönemlerde talep artabilirken, durgun dönemlerde azalabilir.

*Trend Değişiklikleri: 
İlgi alanı veya sektördeki trend değişiklikleri, insanların ilgi ve taleplerini etkileyebilir. 
Yeni ürünlerin veya hizmetlerin popülerleşmesi, bu değişikliklerin bir nedeni olabilir.