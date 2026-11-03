# PT Adyaraksa - Executive HR Analytics & Workforce Governance

## 1. Business Understanding

### 1.1 Business Background
PT Adyaraksa requires a centralized HR monitoring system to efficiently manage its growing workforce across strategic hubs in Jakarta, Surabaya, and Bandung. As the organization expands, executive leadership needs real-time visibility into talent retention, performance trends, and payroll transparency to mitigate financial anomalies and compensation disparities.

### 1.2 Business Problem
The company faces key operational challenges, including an 18% overall employee turnover rate, 12 flagged payroll anomaly cases requiring immediate verification, and the need to address internal pay equity disparities while maintaining a balance between technical KPI execution and work culture discipline.

### 1.3 Key Business Questions
1. How is operational workforce capacity distributed across regional hubs and departments?
2. What is the overall employee turnover rate, and what are the primary drivers of employee departures?
3. What are the multi-year performance score trends (Overall Score, KPI, Attitude) from 2022 to 2024?
4. Is the compensation structure and salary banding for C-Level and senior leadership positions aligned with internal pay equity standards?
5. What are the distribution patterns and average percentage increases across different compensation adjustment types?

---

## 2. Data Source & Schema

The analysis is powered by PT Adyaraksa's relational HR database, managed in PostgreSQL and visualized through an interactive Power BI dashboard.

| Table Name | Description | Key Columns |
| :--- | :--- | :--- |
| **`departments`** | Contains structural data for 15 organizational departments, including division mapping, regional hub locations, department heads, and annual operating budgets. | `dept_id`, `dept_name`, `division`, `location`, `head_emp_id`, `annual_budget_idr` |
| **`employees`** | Stores comprehensive profile records for 500 employees, including demographics, job titles, hire dates, city locations, and employment status (`active`, `resigned`, `terminated`, `on_leave`). | `emp_id`, `full_name`, `email`, `dept_id`, `position`, `hire_date`, `status`, `manager_id` |
| **`salary_history`** | Contains 1,500 historical compensation adjustment records, capturing base salary, allowances, total compensation, and specific change reasons. | `record_id`, `emp_id`, `effective_date`, `base_salary_idr`, `allowances_idr`, `total_idr`, `change_reason` |
| **`attendance`** | Stores 3,000 daily attendance and work discipline logs, tracking check-in/out timestamps, total work hours, and attendance status. | `record_id`, `emp_id`, `date`, `check_in`, `check_out`, `work_hours`, `status` |
| **`performance`** | Contains 600 periodic employee performance evaluation logs, detailing overall scores, KPI scores, attitude scores, and qualitative review notes. | `review_id`, `emp_id`, `review_period`, `review_date`, `overall_score`, `kpi_score`, `attitude_score` |

---

## 3. Tech Stack & Workflow

* **Tech Stack**: PostgreSQL (Data Validation, Cleaning, & Exploratory Data Analysis), Power BI (Data Modeling, DAX Measures, & Interactive Visualization).
* **Workflow**:
  1. **Business Understanding**: Identifying executive goals, operational risks, and key HR metrics.
  2. **Data Cleansing & Preprocessing**: Auditing duplicates, handling missing values, standardizing dates, and validating financial records via SQL scripts.
  3. **Exploratory Data Analysis (EDA)**: Aggregating headcount, retention, performance metrics, and salary bands using PostgreSQL queries.
  4. **Data Modeling & Dashboard Design**: Establishing relational models in Power BI and creating DAX measures for executive metrics.
  5. **Insight Generation & Strategic Recommendations**: Translating analytics findings into actionable business strategies for executive decision-makers.

---

## 4. Data Cleaning

The Data Preparation and Validation phase focused on ensuring raw data integrity and structural reliability before executive reporting:

* **Duplicate Audit & Deduplication**: Conducted systematic primary key and multi-column duplicate checks across all core tables. On the `salary_history` dataset, 8 duplicate rows were identified and eliminated out of 1,500 initial records, resulting in 1,492 clean, unique records.
* **Date Format Standardization**: Standardized three heterogeneous date formats found in raw salary records (`YYYY-MM-DD`, `DD-MM-YYYY`, and `DD/MM/YYYY`) into a unified ISO format (`YYYY-MM-DD`) to enable precise chronological sorting and window function calculations.
* **Data Quality & Financial Integrity Validation**: Verified null value distributions across all datasets and validated financial columns (`base_salary_idr`, `allowances_idr`, `total_idr`) to eliminate negative values, zero entries, or missing compensation figures.

---

## 5. Key Findings

* **Workforce Distribution**: Operational headcount is centralized in Jakarta (256 employees), followed by Surabaya (81 employees) and Bandung (60 employees). Customer Success (41 employees) and Sales (37 employees) represent the largest functional departments in Jakarta.
* **Retention & Turnover Status**: Active employees comprise 80% (410 headcount) of the workforce. The organizational turnover rate stands at 18% (70 voluntary resignations and 20 involuntary terminations). In addition, 12 payroll anomaly records were flagged for verification.
* **Performance Trends (2022–2024)**: Overall organizational performance remained stable above baseline metrics (3.15–3.35). A strong cultural foundation is reflected in high Attitude Scores (3.45–3.65), while technical KPI scores experienced slight post-2022 calibration.
* **Pay Equity & Leadership Compensation**: Compensation bands for top leadership roles (CFO, Head of CS, Head of Legal, Sales Director, Head of Data) demonstrate clear minimum and maximum thresholds, reflecting sound internal pay equity without extreme baseline anomalies.
* **Payroll & Salary Change Drivers**: Analysis of 1,500 compensation events shows that adjustments are primarily driven by Annual Reviews and Corrections (9.05% average increase), followed by Promotions (8.64%) and Market Adjustments (8.36%).

---

## 6. Insights & Strategic Recommendations

* **Operational Budget & Regional Capacity Planning**: Evaluate cost efficiency between customer-facing teams and technical support functions. Establish structured resource allocation plans for the Surabaya and Bandung hubs to rebalance operational workloads from Jakarta.
* **Payroll Risk Mitigation & Retention Governance**: Execute immediate audits on the 12 flagged payroll anomaly cases to ensure zero salary disbursements to departed staff. Conduct comprehensive exit interviews to address root causes behind voluntary resignations.
* **KPI Alignment & Technical Capability Enablement**: Investigate operational bottlenecks in departments with declining KPI trends and deploy targeted technical training. Implement recognition schemes that reward high KPI achievement alongside consistent cultural attitude scores.
* **Salary Band Standardization & Market Benchmarking**: Formalize leadership salary bands into official HR guidelines to mitigate internal equity disputes and calibrate salary ranges against market benchmarks to retain top-performing talent.
* **Predictable OpEx Forecasting**: Utilize the benchmarked 8%–9% salary increase baseline for annual operating expense (OpEx) planning, maintaining predictable labor budget allocation while preventing cash flow overruns.
