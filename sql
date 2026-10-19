-- CEK DUPLIKAT

-- Cek duplikat tabel departments
SELECT dept_id, COUNT(*) 
FROM departments 
GROUP BY dept_id 
HAVING COUNT(*) > 1;

-- Cek duplikat tabel employees
SELECT emp_id, COUNT(*) 
FROM employees 
GROUP BY emp_id 
HAVING COUNT(*) > 1;

-- Cek duplikat tabel attendance
SELECT record_id, COUNT(*) 
FROM attendance
GROUP BY record_id 
HAVING COUNT(*) > 1;

-- Cek duplikat tabel performance
SELECT review_id, COUNT(*) 
FROM performance 
GROUP BY review_id 
HAVING COUNT(*) > 1;

-- Cek duplikat tabel salary_history
SELECT record_id, COUNT(*) 
FROM salary_history 
GROUP BY record_id 
HAVING COUNT(*) > 1;


-- DATA QUALITY CHECK --
-- Deskripsi: Mengecek jumlah baris kosong (NULL)

-- Cek null tabel departments
SELECT 
    COUNT(*) AS total_baris,
	COUNT(*) - COUNT(dept_id) AS null_dept_id,
	COUNT(*) - COUNT(dept_name) AS null_dept_name,
	COUNT(*) - COUNT(division) AS null_division,
	COUNT(*) - COUNT(location) AS null_location,
	COUNT(*) - COUNT(head_emp_id) AS null_head_emp_id,
	COUNT(*) - COUNT(annual_budget_idr) AS null_annual_budget_idr
FROM departments;

-- Cek null tabel employees
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

--cek null tabel attedance
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

--cek null tabel performance
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


----cek null tabel salary_history
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


SELECT 
    COUNT(*) AS total_baris,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{4}-\d{2}-\d{2}$' THEN 1 END) AS format_yyyy_mm_dd,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{2}-\d{2}-\d{4}$' THEN 1 END) AS format_dd_mm_yyyy,
    COUNT(CASE WHEN effective_date::TEXT ~ '^\d{2}/\d{2}/\d{4}$' THEN 1 END) AS format_dd_slash_mm_yyyy
FROM salary_history;

-- Cleansing

-- String Formatting employees
SELECT 
    emp_id,
    -- Menghapus spasi di awal/akhir nama
    btrim(full_name) AS full_name_clean,
    -- Menghapus spasi dan mengubah email menjadi huruf kecil semua
    lower(btrim(email)) AS email_clean,
    -- Merapikan jabatan
    btrim("position") AS position_clean
FROM employees;

-- General Deduplication
WITH ranked_data AS (
    SELECT 
        *,
        row_number() OVER (
            PARTITION BY emp_id, effective_date, base_salary_idr, allowances_idr, total_idr, change_reason 
            ORDER BY record_id
        ) AS rn
    FROM salary_history
)
SELECT * 
FROM ranked_data 
WHERE rn = 1; -- Hanya ambil baris pertama yang unik, buang duplikatnya


-- cek duplikat salary_history
SELECT 
    emp_id, 
    effective_date, 
    base_salary_idr, 
    allowances_idr, 
    total_idr, 
    change_reason,
    COUNT(*) AS total_kemunculan
FROM salary_history
GROUP BY 
    emp_id, 
    effective_date, 
    base_salary_idr, 
    allowances_idr, 
    total_idr, 
    change_reason
HAVING COUNT(*) > 1; -- Menyaring hanya kombinasi data yang muncul lebih dari 1 kali


-- Deduplication
WITH ranked_salary AS (
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
    FROM salary_history
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
WHERE rn = 1; -- Filter only the first unique record (Post-Cleaning Dataset)


-- Analysis

-- Sebaran Status & Sinyal Awal Turnover
SELECT 
    status, 
    COUNT(*) AS total_karyawan,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS persentase
FROM employees
GROUP BY status
ORDER BY total_karyawan DESC;

-- Peta Headcount per Departemen & Kota
SELECT 
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS total_headcount,
    SUM(d.annual_budget_idr) AS total_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id AND e.status = 'active'
GROUP BY d.dept_name, d.location
ORDER BY total_headcount DESC;

-- Audit Kualitas Data & Tren Payroll
WITH calculated_salary AS (
    SELECT 
        change_reason,
        base_salary_idr::bigint AS base_salary_idr,
        -- Menghitung gaji periode sebelumnya per karyawan
        LAG(base_salary_idr::bigint) OVER (PARTITION BY emp_id ORDER BY effective_date, record_id) AS prev_base,
        -- Menandai jika ada penurunan gaji secara on-the-fly
        CASE 
            WHEN base_salary_idr::bigint < LAG(base_salary_idr::bigint) OVER (PARTITION BY emp_id ORDER BY effective_date, record_id) THEN 1 
            ELSE 0 
        END AS is_decrease
    FROM salary_history
)
SELECT 
    change_reason,
    COUNT(*) AS total_kejadian,
    SUM(is_decrease) AS jumlah_penurunan_gaji,
    ROUND(AVG(100.0 * (base_salary_idr::numeric / NULLIF(prev_base, 0) - 1)), 2) AS rata_rata_kenaikan_persen
FROM calculated_salary
GROUP BY change_reason
ORDER BY total_kejadian DESC;

-- Tren Skor Performance (2022–2024)
SELECT 
    review_period,
    ROUND(AVG(overall_score)::numeric, 2) AS avg_overall_score,
    ROUND(AVG(kpi_score)::numeric, 2) AS avg_kpi_score,
    ROUND(AVG(attitude_score)::numeric, 2) AS avg_attitude_score,
    COUNT(*) AS total_review
FROM performance
GROUP BY review_period
ORDER BY review_period;

-- Karakteristik & Sinyal Top Performer yang Keluar
SELECT 
    e.status,
    ROUND(AVG(p.overall_score)::numeric, 2) AS avg_performance_score,
    COUNT(DISTINCT e.emp_id) AS total_employee
FROM employees e
JOIN performance p ON e.emp_id = p.emp_id
WHERE p.review_period LIKE '2024%' -- Menangkap '2024-mid' dan '2024-annual' sekaligus
GROUP BY e.status;

-- Disiplin Absensi (Q4 2024)
SELECT 
    e.dept_id,
    COUNT(a.record_id) AS total_presensi,
    ROUND(AVG(NULLIF(btrim(a.work_hours::text), '')::numeric), 2) AS avg_work_hours,
    -- Menghitung kasus lupa check-out
    COUNT(*) FILTER (
        WHERE NULLIF(btrim(a.check_in::text), '') IS NOT NULL 
          AND NULLIF(btrim(a.check_out::text), '') IS NULL
    ) AS jumlah_missing_checkout,
    -- Menghitung kasus jam kerja > 12 jam
    COUNT(*) FILTER (
        WHERE NULLIF(btrim(a.work_hours::text), '')::numeric > 12
    ) AS jumlah_jam_ekstrem
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.date::date >= '2024-10-01' AND a.date::date <= '2024-12-31'
GROUP BY e.dept_id
ORDER BY total_presensi DESC;

-- Pay Equity & Salary Band per Jabatan/Level
WITH latest_salary AS (
    SELECT 
        emp_id,
        base_salary_idr::bigint AS base_salary,
        ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY effective_date DESC, record_id DESC) AS rn
    FROM salary_history
)
SELECT 
    e.position,
    COUNT(e.emp_id) AS total_karyawan,
    MIN(s.base_salary) AS min_salary,
    ROUND(AVG(s.base_salary), 0) AS avg_salary,
    MAX(s.base_salary) AS max_salary,
    -- Menghitung selisih/gap antara gaji tertinggi dan terendah pada jabatan yang sama
    MAX(s.base_salary) - MIN(s.base_salary) AS salary_gap
FROM employees e
JOIN latest_salary s ON e.emp_id = s.emp_id AND s.rn = 1
WHERE e.status = 'active'
GROUP BY e.position
ORDER BY avg_salary DESC;

SELECT COUNT(*) AS total_rows_pre_cleaning
FROM salary_history;

WITH ranked_data AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY emp_id, effective_date, base_salary_idr, allowances_idr, total_idr, change_reason 
            ORDER BY record_id
        ) AS rn
    FROM salary_history
)
SELECT COUNT(*) AS total_duplicate_rows
FROM ranked_data 
WHERE rn > 1; -- Mengambil hanya baris duplikat
