-- ==========================================
-- 1. DATA VALIDATION: DUPLICATE RECORD AUDIT
-- ==========================================

-- [Audit] Primary Key Duplicate Validation: Departments Table
SELECT dept_id, COUNT(*) 
FROM departments 
GROUP BY dept_id 
HAVING COUNT(*) > 1;

-- [Audit] Primary Key Duplicate Validation: Employees Table
SELECT emp_id, COUNT(*) 
FROM employees 
GROUP BY emp_id 
HAVING COUNT(*) > 1;

-- [Audit] Primary Key Duplicate Validation: Attendance Table
SELECT record_id, COUNT(*) 
FROM attendance
GROUP BY record_id 
HAVING COUNT(*) > 1;

-- [Audit] Primary Key Duplicate Validation: Performance Table
SELECT review_id, COUNT(*) 
FROM performance 
GROUP BY review_id 
HAVING COUNT(*) > 1;

-- [Audit] Primary Key Duplicate Validation: Salary History Table
SELECT record_id, COUNT(*) 
FROM salary_history 
GROUP BY record_id 
HAVING COUNT(*) > 1;


-- ==========================================
-- 2. DATA QUALITY: MISSING VALUE ASSESSMENT
-- ==========================================

-- [Data Quality] Missing Value Audit: Departments Table
SELECT 
    COUNT(*) AS total_baris,
	COUNT(*) - COUNT(dept_id) AS null_dept_id,
	COUNT(*) - COUNT(dept_name) AS null_dept_name,
	COUNT(*) - COUNT(division) AS null_division,
	COUNT(*) - COUNT(location) AS null_location,
	COUNT(*) - COUNT(head_emp_id) AS null_head_emp_id,
	COUNT(*) - COUNT(annual_budget_idr) AS null_annual_budget_idr
FROM departments;

-- [Data Quality] Missing Value Audit: Employees Table
SELECT 
    COUNT(*) AS total_baris,
	COUNT(*) - COUNT(full_name) AS null_full_name,
	COUNT(*) - COUNT(email) AS null_email,
    COUNT(*) - COUNT(dept_id) AS null_dept_id,
	COUNT(*) - COUNT(position) AS null_position,
	COUNT(*) - COUNT(hire_date) AS null_hire_date,
	COUNT(*) - COUNT(birth_date) AS null_birth_date,
	COUNT(*) - COUNT(gender) AS null_gender,
	COUNT(*) - COUNT(marital_status) AS null_marital_status,
	COUNT(*) - COUNT(education) AS null_education,
	COUNT(*) - COUNT(city) AS null_city,
	COUNT(*) - COUNT(status) AS null_status,
    COUNT(*) - COUNT(manager_id) AS null_manager_id
FROM employees;

-- [Data Quality] Missing Value Audit: Attendance Table
SELECT 
    COUNT(*) AS total_baris,
    COUNT(*) - COUNT(record_id) AS null_record_id,
    COUNT(*) - COUNT(emp_id) AS null_emp_id,
    COUNT(*) - COUNT(date) AS null_date,
    COUNT(*) - COUNT(check_in) AS null_check_in,
    COUNT(*) - COUNT(check_out) AS null_check_out,
    COUNT(*) - COUNT(work_hours) AS null_work_hours,
    COUNT(*) - COUNT(status) AS null_status
FROM attendance;

-- [Data Quality] Missing Value Audit: Performance Table
SELECT 
    COUNT(*) AS total_baris,
    COUNT(*) - COUNT(review_id) AS null_review_id,
    COUNT(*) - COUNT(emp_id) AS null_emp_id,
    COUNT(*) - COUNT(review_period) AS null_review_period,
    COUNT(*) - COUNT(review_date) AS null_review_date,
    COUNT(*) - COUNT(overall_score) AS null_overall_score,
    COUNT(*) - COUNT(reviewer_id) AS null_reviewer_id,
    COUNT(*) - COUNT(kpi_score) AS null_kpi_score,
    COUNT(*) - COUNT(attitude_score) AS null_attitude_score,
    COUNT(*) - COUNT(notes) AS null_notes
FROM performance;

-- [Data Quality] Missing Value Audit: Salary History Table
SELECT 
    COUNT(*) AS total_baris,
    COUNT(*) - COUNT(record_id) AS null_record_id,
    COUNT(*) - COUNT(emp_id) AS null_emp_id,
    COUNT(*) - COUNT(effective_date) AS null_effective_date,
    COUNT(*) - COUNT(base_salary_idr) AS null_base_salary_idr,
    COUNT(*) - COUNT(allowances_idr) AS null_allowances_idr,
    COUNT(*) - COUNT(total_idr) AS null_total_idr,
    COUNT(*) - COUNT(change_reason) AS null_change_reason
FROM salary_history;

-- [Data Quality] Date Format Heterogeneity Audit: Salary History Table
SELECT 
    COUNT(*) AS total_baris,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN 1 END) AS format_yyyy_mm_dd,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN 1 END) AS format_dd_mm_yyyy,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN 1 END) AS format_dd_slash_mm_yyyy
FROM salary_history;


-- ==========================================
-- 3. DATA TRANSFORMATION & CLEANSING
-- ==========================================

-- [Data Cleansing] String Normalization & Whitespace Removal: Employees Table
SELECT 
    emp_id,
    btrim(full_name) AS full_name_clean,
    lower(btrim(email)) AS email_clean,
    btrim("position") AS position_clean
FROM employees;

-- [Data Cleansing] Standardized Date Parsing & Multi-Column Deduplication: Salary History Table
WITH parsed_date_salary AS (
    SELECT 
        record_id,
        emp_id,
        CASE 
            WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' 
                THEN effective_date::DATE
            WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' 
                THEN TO_DATE(effective_date::TEXT, 'DD-MM-YYYY')
            WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' 
                THEN TO_DATE(effective_date::TEXT, 'DD/MM/YYYY')
            ELSE NULL 
        END AS effective_date,
        base_salary_idr,
        allowances_idr,
        total_idr,
        change_reason
    FROM salary_history
),
ranked_salary AS (
    SELECT 
        record_id,
        emp_id,
        effective_date,
        base_salary_idr,
        allowances_idr,
        total_idr,
        change_reason,
        ROW_NUMBER() OVER (
            PARTITION BY 
                emp_id, 
                effective_date, 
                base_salary_idr, 
                allowances_idr, 
                total_idr, 
                change_reason 
            ORDER BY record_id ASC
        ) AS rn
    FROM parsed_date_salary
)
SELECT 
    record_id,
    emp_id,
    effective_date,
    base_salary_idr,
    allowances_idr,
    total_idr,
    change_reason
FROM ranked_salary
WHERE rn = 1;


-- ==========================================
-- 4. HR & PAYROLL ANALYTICS & BUSINESS METRICS
-- ==========================================

-- [HR Analytics] Workforce Status Distribution & Initial Turnover Risk Assessment
SELECT 
    status, 
    COUNT(*) AS total_karyawan,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS persentase
FROM employees
GROUP BY status
ORDER BY total_karyawan DESC;

-- [HR Analytics] Departmental Headcount & Allocated Budget Mapping
SELECT 
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS total_headcount,
    SUM(d.annual_budget_idr) AS total_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id AND e.status = 'active'
GROUP BY d.dept_name, d.location
ORDER BY total_headcount DESC;

-- [Payroll Analytics] Historical Salary Trend & Compensation Change Analysis
WITH parsed_date_salary AS (
    SELECT 
        emp_id,
        record_id,
        change_reason,
        base_salary_idr::bigint AS base_salary_idr,
        CASE 
            WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN effective_date::DATE
            WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD-MM-YYYY')
            WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD/MM/YYYY')
            ELSE NULL 
        END AS effective_date
    FROM salary_history
),
calculated_salary AS (
    SELECT 
        change_reason,
        base_salary_idr,
        LAG(base_salary_idr) OVER (PARTITION BY emp_id ORDER BY effective_date, record_id) AS prev_base,
        CASE 
            WHEN base_salary_idr < LAG(base_salary_idr) OVER (PARTITION BY emp_id ORDER BY effective_date, record_id) THEN 1 
            ELSE 0 
        END AS is_decrease
    FROM parsed_date_salary
)
SELECT 
    change_reason,
    COUNT(*) AS total_kejadian,
    SUM(is_decrease) AS jumlah_penurunan_gaji,
    ROUND(AVG(100.0 * (base_salary_idr::numeric / NULLIF(prev_base, 0) - 1)), 2) AS rata_rata_kenaikan_persen
FROM calculated_salary
GROUP BY change_reason
ORDER BY total_kejadian DESC;

-- [Performance Analytics] Multi-Year Performance Score Trends (2022-2024)
SELECT 
    review_period,
    ROUND(AVG(overall_score)::numeric, 2) AS avg_overall_score,
    ROUND(AVG(kpi_score)::numeric, 2) AS avg_kpi_score,
    ROUND(AVG(attitude_score)::numeric, 2) AS avg_attitude_score,
    COUNT(*) AS total_review
FROM performance
GROUP BY review_period
ORDER BY review_period;

-- [HR Analytics] Top Performer Attrition & Performance Score Correlation Analysis
SELECT 
    e.status,
    ROUND(AVG(p.overall_score)::numeric, 2) AS avg_performance_score,
    COUNT(DISTINCT e.emp_id) AS total_employee
FROM employees e
JOIN performance p ON e.emp_id = p.emp_id
WHERE p.review_period LIKE '2024%' 
GROUP BY e.status;

-- [Operations Analytics] Q4 2024 Attendance Discipline & Exception Monitoring
SELECT 
    e.dept_id,
    COUNT(a.record_id) AS total_presensi,
    ROUND(AVG(NULLIF(btrim(a.work_hours::text), '')::numeric), 2) AS avg_work_hours,
    COUNT(*) FILTER (
        WHERE NULLIF(btrim(a.check_in::text), '') IS NOT NULL 
          AND NULLIF(btrim(a.check_out::text), '') IS NULL
    ) AS jumlah_missing_checkout,
    COUNT(*) FILTER (
        WHERE NULLIF(btrim(a.work_hours::text), '')::numeric > 12
    ) AS jumlah_jam_ekstrem
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.date::date >= '2024-10-01' AND a.date::date <= '2024-12-31'
GROUP BY e.dept_id
ORDER BY total_presensi DESC;

-- [Compensation Analytics] Pay Equity & Salary Band Distribution by Job Position
WITH parsed_date_salary AS (
    SELECT 
        emp_id,
        record_id,
        base_salary_idr::bigint AS base_salary,
        CASE 
            WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN effective_date::DATE
            WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD-MM-YYYY')
            WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD/MM/YYYY')
            ELSE NULL 
        END AS effective_date
    FROM salary_history
),
latest_salary AS (
    SELECT 
        emp_id,
        base_salary,
        ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY effective_date DESC, record_id DESC) AS rn
    FROM parsed_date_salary
)
SELECT 
    e.position,
    COUNT(e.emp_id) AS total_karyawan,
    MIN(s.base_salary) AS min_salary,
    ROUND(AVG(s.base_salary), 0) AS avg_salary,
    MAX(s.base_salary) AS max_salary,
    MAX(s.base_salary) - MIN(s.base_salary) AS salary_gap
FROM employees e
JOIN latest_salary s ON e.emp_id = s.emp_id AND s.rn = 1
WHERE e.status = 'active'
GROUP BY e.position
ORDER BY avg_salary DESC;

-- [Payroll Audit] Automated Anomaly Detection (Negative/Zero Salary, Decreases, Spikes)
WITH parsed_date_salary AS (
    SELECT 
        emp_id,
        record_id,
        change_reason,
        base_salary_idr::bigint AS base_salary_idr,
        CASE 
            WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN effective_date::DATE
            WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD-MM-YYYY')
            WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD/MM/YYYY')
            ELSE NULL 
        END AS effective_date
    FROM salary_history
),
salary_with_lag AS (
    SELECT 
        emp_id,
        record_id,
        change_reason,
        base_salary_idr,
        effective_date,
        LAG(base_salary_idr) OVER (PARTITION BY emp_id ORDER BY effective_date, record_id) AS prev_base_salary
    FROM parsed_date_salary
),
flagged_anomalies AS (
    SELECT 
        emp_id,
        record_id,
        change_reason,
        base_salary_idr,
        prev_base_salary,
        CASE 
            WHEN base_salary_idr <= 0 THEN 'Gaji Nol atau Negatif'
            WHEN base_salary_idr < prev_base_salary THEN 'Penurunan Gaji (Salary Decrease)'
            WHEN base_salary_idr > (prev_base_salary * 2.0) THEN 'Lonjakan Gaji Ekstrem (>100%)'
            ELSE 'Normal'
        END AS anomaly_type
    FROM salary_with_lag
)
SELECT 
    anomaly_type,
    COUNT(*) AS total_anomali_count
FROM flagged_anomalies
WHERE anomaly_type != 'Normal'
GROUP BY anomaly_type
ORDER BY total_anomali_count DESC;

-- [Data Quality] Pre-Cleaning Total Volume Check: Salary History Table
SELECT COUNT(*) AS total_rows_pre_cleaning
FROM salary_history;

-- [Data Quality] Post-Transformation Duplicate Volume Count: Salary History Table
WITH parsed_date_salary AS (
    SELECT 
        emp_id,
        record_id,
        base_salary_idr,
        allowances_idr,
        total_idr,
        change_reason,
        CASE 
            WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN effective_date::DATE
            WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD-MM-YYYY')
            WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(effective_date::TEXT, 'DD/MM/YYYY')
            ELSE NULL 
        END AS effective_date
    FROM salary_history
),
ranked_data AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY emp_id, effective_date, base_salary_idr, allowances_idr, total_idr, change_reason 
            ORDER BY record_id
        ) AS rn
    FROM parsed_date_salary
)
SELECT COUNT(*) AS total_duplicate_rows
FROM ranked_data 
WHERE rn > 1;
