
-- HEALTHCARE MAIN BUSINESS KPI METRICS
SELECT 
    COUNT(*) AS total_appointments_registered,
    SUM(CASE WHEN appointment_status = 'Completed' THEN 1 ELSE 0 END) AS successfully_completed_visits,
    SUM(CASE WHEN appointment_status = 'No-show' THEN 1 ELSE 0 END) AS no_show_loss_count
FROM appointments_clean;

SELECT ROUND((SUM(CASE WHEN appointment_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS completion_rate FROM appointments_clean;
SELECT SUM(consultation_fee) AS revenue FROM appointments_clean WHERE appointment_status = 'Completed';
SELECT ROUND(AVG(waiting_time_minutes), 2) AS avg_wait_time FROM appointments_clean;

-- TREND 
SELECT DATE_FORMAT(appointment_date, '%Y-%m') AS month, COUNT(*) AS volume 
FROM appointments_clean 
GROUP BY 1 ORDER BY month;

SELECT appointment_time, COUNT(*) AS slots 
FROM appointments_clean 
GROUP BY 1 ORDER BY slots DESC;


-- DEPARTMENT QUERIES
SELECT d.department_name, COUNT(*) AS volume, 
SUM(CASE WHEN a.appointment_status = 'Completed' THEN a.consultation_fee ELSE 0 END) AS revenue 
FROM appointments_clean a JOIN departments_clean d ON a.department_id = d.department_id 
GROUP BY 1 ORDER BY revenue DESC;

-- DOCTOR QUERIES
SELECT doc.doctor_name, COUNT(*) AS count, 
SUM(CASE WHEN a.appointment_status = 'Completed' THEN a.consultation_fee ELSE 0 END) AS rev 
FROM appointments_clean a JOIN doctors_clean doc ON a.doctor_id = doc.doctor_id 
GROUP BY 1 ORDER BY rev DESC LIMIT 10;

-- DIAGNOSIS QUERIES
SELECT diagnosis, COUNT(*) AS cases 
FROM appointments_clean 
GROUP BY 1 ORDER BY cases DESC;

-- Monthly Trend
-- Unable to solve this

-- Department scorecard
SELECT 
    d.department_name,
    COUNT(a.appointment_id) AS total_volume,
    SUM(CASE WHEN a.appointment_status = 'Completed' THEN 1 ELSE 0 END) AS completed_appointments,
    ROUND(AVG(CASE WHEN a.waiting_time_minutes < 0 THEN 0 ELSE a.waiting_time_minutes END), 2) AS avg_waiting_time_minutes,
    SUM(CASE WHEN a.appointment_status = 'Completed' THEN a.consultation_fee ELSE 0 END) AS total_revenue
FROM appointments_clean a
JOIN departments_clean d ON a.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_revenue DESC;

-- Doctor Performance 
SELECT 
    d.doctor_id,
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments,
    ROUND((SUM(CASE WHEN a.appointment_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(a.appointment_id)) * 100, 2) AS completion_rate_percentage,
    ROUND(AVG(CASE WHEN a.waiting_time_minutes < 0 THEN 0 ELSE a.waiting_time_minutes END), 1) AS avg_waiting_time_minutes
FROM appointments_clean a
JOIN doctors_clean d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.doctor_name
ORDER BY total_appointments DESC;

-- Appointment status mix
SELECT 
    appointment_status,
    COUNT(*) AS status_count,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM appointments_clean)) * 100, 2) AS status_percentage
FROM appointments_clean
GROUP BY appointment_status
ORDER BY status_count DESC;

-- Diagnosis mix
SELECT 
    diagnosis,
    COUNT(*) AS case_volume,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM appointments_clean)) * 100, 2) AS mix_percentage
FROM appointments_clean
WHERE diagnosis IS NOT NULL AND diagnosis != '' AND diagnosis != 'N/A'
GROUP BY diagnosis
ORDER BY case_volume DESC;

-- Payment status mix
SELECT 
    payment_status,
    COUNT(*) AS transaction_count,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM appointments_clean)) * 100, 2) AS mix_percentage
FROM appointments_clean
WHERE payment_status IS NOT NULL AND payment_status != '' AND payment_status != 'N/A'
GROUP BY payment_status
ORDER BY transaction_count DESC;

SET SQL_SAFE_UPDATES = 0;
