# 📊 PT Adyaraksa HR Analytics & Strategic Workforce Dashboard

[![Power BI](https://img.shields.io/badge/Power_BI-F2C94C?style=for-the-badge&logo=powerbi&logoColor=black)](#)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](#)
[![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=sql&logoColor=white)](#)
[![Data Analytics](https://img.shields.io/badge/Data_Analytics-0078D4?style=for-the-badge)](#)

---

## 📌 Project Overview
This project aims to transform raw Human Resources (HR) data at PT Adyaraksa into strategic, measurable, and dashboard-ready business insights. By combining **PostgreSQL**-based data cleansing and transformation with interactive visualizations in **Power BI**, this project empowers executives and HR Managers to:

- **Optimize Talent Allocation:** Map headcount and demographic distribution proportionally across locations.
- **Mitigate Turnover Risk:** Detect early signals of employee departure, particularly among top performers.
- **Maintain Operational & Financial Health:** Ensure internal pay equity, validate payroll increase history, and monitor daily work discipline.

---

## 🛠️ Tech Stack & Tools
- **Database Engine:** PostgreSQL (ETL, Data Cleansing, & Data Auditing)
- **Business Intelligence:** Power BI (Data Modeling, DAX Measures, & Interactive Dashboarding)
- **Data Transformation:** Power Query & SQL

---

## 🧹 Data Cleaning & Transformation

### 1. Data Cleaning Process
1. 🗄️ **Data Source Integration:** Connecting the PostgreSQL database and establishing structured table relationships.
2. 🔍 **Deduplication & Missing Values:** Detecting and eliminating duplicate records within the salary transaction table.
3. ✍️ **Text Standardization & Trimming:** Standardizing email formats and job positions using `BTRIM` and `LOWER` functions.
4. 📊 **Numerical Format Validation:** Ensuring salary, allowance, and total compensation data are precise and calculable.

### 2. Cleaning Results & Impact
- 🎯 **100% Data Integrity:** Successfully eliminated 8 duplicate records, removing the risk of financial double-counting.
- 💰 **Accurate Financial Metrics:** Ensured total payroll expenditures and allowances reflect the company's true financial baseline.
- 🧼 **Standardized Text Attributes:** Normalized names, emails, and job roles by eliminating leading/trailing spaces and inconsistent casing.
- ⚡ **Optimized Data Model:** Delivered a clean, validated dataset ready for seamless integration into the Power BI data model.
