-- 04_analysis_queries.sql

-- +++++++++++++++++++++++++
-- Section A) Data Profile
-- +++++++++++++++++++++++++

-- A1) Data Overview
select 
	--Total values
	count(*) as rows, 
	
	-- Missing values 
	count(*) - count(selling_usd) as missing_selling,
	count(*) - count(showroom_usd) as missing_showroom,
	
	-- Year and mileage ranges
	min(year) as min_year, max(year) as max_year,
	min(miles) as min_miles, max(miles) as max_miles,
	
	-- Selling price average and median
	round(avg(selling_usd),2) as avg_selling, 
	percentile_cont(0.5) within group (order by selling_usd) as median_selling,
	
	-- Showroom price average and median
	round(avg(showroom_usd),2) as avg_showroom, 
	percentile_cont(0.5) within group (order by showroom_usd) as median_showroom
	
from bike_listings;

-- A2) Data Quality Flags: count abnormalities
select 
	-- Price should not be negative
	sum((selling_usd is not null and selling_usd <=0)::int) as negative_selling_usd,
	sum((showroom_usd is not null and showroom_usd <=0)::int) as negative_showroom_usd,

	-- Year cannot be in future
	sum((year is not null and year > extract(year from current_date))::int) as future_years,

	-- Miles cannot be less than 0 or extreme (>= 100k)
	sum((miles is not null and miles < 0)::int) as negative_miles,
	sum((miles is not null and miles > 100000)::int) as extreme_miles,

	-- Showroom should not be less than selling (potential data issue/irregular case)
	sum((showroom_usd is not null and selling_usd is not null and showroom_usd < selling_usd)::int) as showroom_less_than_selling,

	-- Missing values 
	sum ((selling_usd is null)::int) as missing_selling_usd,
	sum ((showroom_usd is null)::int) as missing_showroom_usd,
	sum ((year is null)::int) as missing_year,
	sum ((miles is null)::int) as missing_miles
from bike_listings;

-- +++++++++++++++++++++++++
-- Section B) Core Insights 
-- +++++++++++++++++++++++++

-- B1) Depreciation Curve by Year 
-- Purpose: Average and median USD resale by manufacture year
-- Inputs/Filters: year; selling_usd not null; num_listings >= 10 per year
-- Output: year, num_listings, avg_selling_usd, median_selling_usd

select 
	year, 
	count(*) as num_listings, 
	round(avg(selling_usd),2)  as avg_selling_usd,
	percentile_cont(0.5) within group (order by selling_usd) as median_selling_usd
from bike_listings
where year is not null and selling_usd is not null
group by year
having count(*) >= 10 --avoid tiny samples
order by year desc;

-- B2) Used vs Showroom Discount by Year
-- Purpose: How much cheaper used bikes are vs showroom prices
-- Inputs/Filters: num_listings with both prices listed; showroom_usd > 0; num_listings >=10 per year
-- Output: year, num_listings, avg_selling_usd, median_selling_usd

select 
	year,
	count(*) as num_listings,
	round(avg(showroom_usd - selling_usd), 2) as avg_discount_value,
	--100.0 used for floating math, zero division avoided with showroom_usd > 0
	round(avg(100.0 * (showroom_usd - selling_usd) / showroom_usd ), 2) as avg_discount_pct,
	percentile_cont(0.5) within group (order by 100.0 * (showroom_usd - selling_usd) / showroom_usd) as median_discount_pct
from bike_listings 
where selling_usd is not null 
	and showroom_usd is not null 
	and showroom_usd > 0
group by year
having count(*) >= 10
order by year desc;

-- B3) Mileage Impact on Resale Value
-- Purpose: Compare average selling_usd across multiple mileage ranges
-- Inputs: miles; selling_usd; no other filters
-- Output: mileage_bucket, num_listings, avg_selling_usd; sorted with bucket order via subquery

select 
	mileage_bucket,
	count(*) as num_listings, 
	round(avg(selling_usd), 2) as avg_selling_usd
from
(select 
	selling_usd,
	case
		when miles is null then 'Unknown'
		when miles < 12000 then 'Low (<12k)'
		when miles < 30000 then 'Med (12-30k)'
		when miles < 50000 then 'High (30-50k)'
		else 'Very High (>50k)'
	end as mileage_bucket
from bike_listings
where selling_usd is not null
) as buckets
group by mileage_bucket
order by 
	case mileage_bucket
		when 'Low (<12k)' then 1
		when 'Med (12-30k)' then 2
		when 'High (30-50k)' then 3
		when 'Very High (>50k)' then 4
		when 'Unknown' then 5
	end;

-- B4) Depreciation by Number of Owners
-- Purpose: Calculate how much resale value (USD) declines as number of owners increase
-- Inputs/Filters: owner; selling_usd; showroom_usd; exclude nulls and showroom <= 0; 
-- Output: num_owners; num_listings, avg_selling_usd, avg_showroom_usd, avg_depreciation_pct, median_depreciation_pct

select 
	case 
		when owner like '1%' then 1
		when owner like '2%' then 2
		when owner like '3%' then 3
		when owner like '4%' then 4
	end as num_owners,
	count(*) as num_listings,
	round(avg(selling_usd),2) as avg_selling_usd,
	round(avg(showroom_usd),2) as avg_showroom_usd,
	round(avg(100.0 * (showroom_usd - selling_usd) / showroom_usd),2 ) as avg_depreciation_pct,
	percentile_cont(0.5) within group (order by 100.0 * (showroom_usd - selling_usd) / showroom_usd) as median_depreciation_pct
from bike_listings
where selling_usd is not null
	and showroom_usd is not null
	and showroom_usd > 0
group by num_owners
having count(*) >= 10
order by num_owners;

-- +++++++++++++++++++++++++++++++++++++++
-- Section C) Advanced Business Insights 
-- +++++++++++++++++++++++++++++++++++++++

-- C1) Brand Extraction and Value Retention
-- Purpose: Derive brand from listing and compare how each brand retains its resale value
-- Inputs/Filters: name split into first token; selling_usd and showroom_usd must be not not null; exclude small brands (num_listings<10)
-- Output: brand, num_listings, avg_selling_usd; avg_showroom_usd; avg_residual_value_pct\

select 
	split_part(name, ' ', 1) as brand,  
	count(*) as num_listings, 
	round(avg(selling_usd), 2) as avg_selling_usd,
	round(avg(showroom_usd), 2) as avg_showroom_usd,
	round(avg(selling_usd / nullif(showroom_usd, 0) * 100.0), 2) as avg_residual_value_pct
from bike_listings
where selling_usd is not null
	and showroom_usd is not null
	and showroom_usd > 0
group by brand
having count(*) >= 10
order by avg_residual_value_pct desc;

-- C2) Age x Mileage Matrix Effect on Resale Value
-- Pupose: Analyze joint effect of motorcycle age and mileage on resale effect. 
-- Buckets age are relative to dataset's latest year (2020)
-- Inputs/Filters: year; miles; selling_usd; num_listings >= 10; exclude null year and selling_usd
-- Output: avg_selling_usd, age_bucket, mileage_bucket, num_listings

select
	round(avg(selling_usd), 2) as avg_selling_usd,
	case 
		when age_years <= 3 then '0-3 years'
		when age_years <= 7 then '4-7 years'
		when age_years <= 12 then '8-12 years'
		when age_years > 13 then '13+ years'
		else 'Unknown Age'
	end as age_bucket,
	case
		when miles is null then 'Unknown Mileage'
		when miles < 12000 then 'Low (<12k)'
		when miles < 30000 then 'Med (12-30k)'
		when miles < 50000 then 'High (30-50k)'
		else 'Very High (>50k)'
	end as mileage_bucket,
	count(*) as num_listings
from 
	(select 
		(2020 - year) as age_years,
		miles,
		selling_usd 
	from bike_listings
	where year is not null
		and selling_usd is not null
	)
group by age_bucket, mileage_bucket
having count(*) >= 10
order by avg_selling_usd desc;






