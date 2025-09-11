# used-motorcycle-analysis-sql
Data engineering &amp; SQL analysis of 1k+ used motorcycle listings (Kaggle dataset) — depreciation, brand value retention, and anomaly detection.

# Used Motorcycle Data Engineering & Analysis (SQL Project)

## 📌 Project Overview
This project uses **PostgreSQL** to clean, transform, and analyze a Kaggle dataset of **1,000+ used motorcycle listings**.  
The goal was to practice **data engineering** (schema design, type conversions, constraints, transformations) and **data analysis** (value retention, depreciation, anomaly detection).

## 🛠️ Skills Demonstrated
- **Data Engineering**
  - Created raw staging tables and cleaned data into an analysis-ready schema
  - Converted kms → miles and INR → USD
  - Enforced data quality rules with `CHECK` constraints
- **Data Analysis**
  - Depreciation curves (year vs resale price)
  - Showroom vs resale discounts (absolute and %)
  - Mileage impact on price (bucketed analysis)
  - Brand-level value retention
  - Residual value distribution & anomaly detection (resale > showroom)

## 📂 Project Structure
- `01_create_raw_table.sql` → staging table for raw CSV import  
- `02_renames_and_types.sql` → column renames, type conversions, unit conversions  
- `03_constraints.sql` → data quality checks (year plausibility, nonnegative miles/prices)  
- `04_analysis_queries.sql` → insights (depreciation, discounts, anomalies, brand retention, etc.)

## 📊 Key Insights
- **Depreciation:** most bikes lose ~40–50% of value within 5 years  
- **Brands:** Royal Enfield retains the most value (~70% average residual)  
- **Anomalies:** ~1% of listings showed resale price higher than showroom price (bad data or inflated listings)  
- **Mileage:** bikes under 12k miles resell for ~30% more on average  

## 🔗 Dataset
[Kaggle: Motorcycle Dataset by NehalBirla](https://www.kaggle.com/datasets/nehalbirla/motorcycle-dataset)
