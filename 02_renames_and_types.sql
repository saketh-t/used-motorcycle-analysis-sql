-- 02_renames_and_types.sql
-- Purpose: Rename landing table/columns and convert to proper types while considering null spaces
-- Also convert kms to miles and rupees to USD

-- 1) Rename raw data table to more appropriate name
alter table raw_data rename to bike_listings;

-- 2) Shorten column names
alter table bike_listings rename column km_driven to kms;
alter table bike_listings rename column ex_showroom_price to price;

-- 4) Type conversions considering null spaces (trim -> null -> cast). Prices are numeric and others as shown.
alter table bike_listings
	alter column name type varchar(50),
	alter column selling_price type numeric using nullif(trim(selling_price::text), '')::numeric,
	alter column year type int using nullif(trim(year::text), '')::int,
	alter column seller_type type varchar(20),
	alter column owner type varchar(20),
	alter column kms type int using nullif(trim(kms::text), '')::int,
	alter column price type numeric using nullif(trim(price::text), '')::numeric;

-- 5) Add converted columns (miles and USD)
alter table bike_listings 
	add column miles numeric,
	add column selling_price_usd numeric,
	add column showroom_price_usd numeric;
	
-- 6) Update columns with converted rates for kms to miles and INR to USD
update bike_listings
set 
	miles = round(kms * 0.621371, 0),
	selling_price_usd  = round(selling_price / 88.00, 2),
	showroom_price_usd = round(price / 88.00, 2);

-- 7) Drop original km/INR columns so only miles/USD remains
alter table bike_listings
	drop column kms,
	drop column selling_price,
	drop column price;
	
--8) Shorten column names again 
alter table bike_listings rename column selling_price_usd to selling_usd;
alter table bike_listings rename column showroom_price_usd to showroom_usd;