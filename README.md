# 🏍️ Used Motorcycle Data Engineering & Analysis (SQL Project)

## 📌 Project Overview
This project uses **PostgreSQL** to clean, transform, and analyze a Kaggle dataset of **1,000+ used motorcycle listings**.  
The goal was to practice **data engineering** (schema design, type conversions, constraints, transformations) and **data analysis** (depreciation, brand value retention, anomaly detection).

---

## 🛠️ Skills Demonstrated

**Data Engineering**
- Designed a schema to load raw CSV into a staging table
- Renamed and casted columns into clean types
- Converted *kms → miles* and *INR → USD*
- Applied `CHECK` constraints to enforce data quality

**Data Analysis**
- Depreciation curves (year vs resale price)
- Showroom vs resale discounts (absolute and %)
- Mileage impact on resale value
- Brand-level value retention
- Residual value distribution & anomaly detection

---

## 📂 Project Structure

- `sql/` → all SQL scripts  
  - `01_create_raw_table.sql` → staging table for raw import  
  - `02_renames_and_types.sql` → column renames, type conversions, unit conversions  
  - `03_constraints.sql` → enforce data quality (plausible year, nonnegative values, showroom ≥ selling)  
  - `04_analysis_queries.sql` → insights (depreciation, brand retention, anomalies, etc.)

- `data/` → dataset information  
  - `README.md` → Kaggle dataset link + import notes  

- `README.md` → project overview (this file)

---

## 📊 Key Insights
- **Depreciation:** most bikes lose ~40–50% of value within 5 years  
- **Brands:** Royal Enfield retains the most value (~70% residual)  
- **Anomalies:** ~1% of listings show resale > showroom price (bad data)  
- **Mileage:** bikes under 12k miles resell for ~30% more on average  

---

## 🔗 Dataset
[Kaggle: Motorcycle Dataset by NehalBirla](https://www.kaggle.com/datasets/nehalbirla/motorcycle-dataset)
