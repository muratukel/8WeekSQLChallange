## 🍊 Case Study #8 - Fresh Segments
🔗 https://8weeksqlchallenge.com/case-study-8/
## Data Exploration and Cleansing 
## 1.Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
````sql
ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year || '-01', 'MM-YYYY-DD');
````
