-- 03_constraints.sql
-- Purpose: Ensure data quality on the cleaned table.
-- Assusmes data has been converted from kms to miles and INR to USD from 02_renames_and_types.sql
-- and dropped original columns 

-- 1) Optional check data ranges 
-- Run to check ranges
-- select min(year) as min_year, max(year) as max_year from bike_listings;
-- select min(miles) as max_miles, max(miles) as max_miles from bike_listings;
-- select min(selling_usd) as min_sell, max(selling_usd) as max_sell from bike_listings;
-- select min(showroom_usd) as min_show, max(showroom_usd) as max_show from bike_listings;

-- 2) Data-quality constraints 
-- ++++++++++++++++++++++++++++++
-- Year must be valid: between 1900 and current year
alter table bike_listings 
	add constraint ck_year
	check (year is null or year between 1900 and extract(year from current_date)::int);
	
-- Miles must be non-negative and less than 100k as any greater is unrealistic for motorcycles
alter table bike_listings 
	add constraint ck_miles
	check (miles is null or (miles >= 0 and miles <= 100000));

-- Prices must be non-negative
alter table bike_listings
  add constraint ck_selling
  check (selling_usd is null or selling_usd >= 0);

alter table bike_listings
  add constraint ck_showroom
  check (showroom_usd is null or showroom_usd >= 0);

-- Showroom (new) must be >= than selling (used) price
-- Allow existing violations but can enforce on new writes
alter table bike_listings
	add constraint ck_show_vs_sell
	check (showroom_usd is null or selling_usd is null or showroom_usd >= selling_usd) not valid;

