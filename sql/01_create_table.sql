-- 01_create_table.sql
-- Purpose: Landing table in all text to safely import csv file via pgAdmin.
-- After running this, import BIKE DETAILS.csv into raw_data using pgAdmin.
-- Import settings -> Import (CSV), Header = ON, Delimiter = ',' , Quote = '"', Encoding = UTF8.

create table raw_data (
  name text,
  selling_price text,  
  year text,
  seller_type text,
  owner text,
  km_driven text,
  ex_showroom_price text
);


