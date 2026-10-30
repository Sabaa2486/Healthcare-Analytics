create database hospital_analytics;

use hospital_analytics; 
select * 
from appointments_raw
limit 10; 

describe appointments_raw; 

-- Replace with your actual database name
USE your_database_name;


CREATE TABLE patients_clean LIKE patients_raw;

CREATE TABLE doctors_clean LIKE doctors_raw;

CREATE TABLE departments_clean LIKE departments_raw;

CREATE TABLE appointments_clean LIKE appointments_raw;


INSERT INTO patients_clean SELECT * FROM patients_raw;
INSERT INTO appointments_clean SELECT * FROM appointments_raw;
INSERT INTO doctors_clean SELECT * FROM doctors_raw;
INSERT INTO departments_clean SELECT * FROM departments_raw;

select * from patients_clean; 

UPDATE departments_clean
SET department_name = TRIM(department_name);

SET SQL_SAFE_UPDATES = 0;

UPDATE patients_clean
SET patient_name = TRIM(patient_name),
city = CASE WHEN city = 'N/A' THEN NULL 
ELSE TRIM(city) END;
    
UPDATE appointments_clean
SET diagnosis = 
CASE WHEN diagnosis = 'N/A' THEN NULL
 ELSE TRIM(diagnosis) END,
    appointment_status = 
    CASE WHEN appointment_status = 'No-show' THEN 'No-Show' 
    ELSE TRIM(appointment_status) END,
    payment_status = TRIM(payment_status);


UPDATE doctors_clean
SET doctor_name = TRIM(doctor_name),
    doctor_level = TRIM(doctor_level);

UPDATE appointments_clean 
SET appointment_date = STR_TO_DATE(appointment_date, '%d-%m-%Y')
WHERE appointment_date LIKE '__-__-____';

UPDATE patients_clean
SET registration_date = STR_TO_DATE(registration_date, '%d-%m-%Y')
WHERE registration_date LIKE '__-__-____';


SELECT COUNT(*) FROM appointments_clean; 
SELECT COUNT(*) FROM appointments_raw;

UPDATE appointments_clean
SET appointment_date = STR_TO_DATE(appointment_date, '%d-%m-%Y')
WHERE appointment_date LIKE '__-__-____';

UPDATE appointments_clean
SET appointment_date = STR_TO_DATE(appointment_date, '%Y-%m-%d')
WHERE appointment_date LIKE '____-__-__';

UPDATE appointments_clean
SET appointment_date = NULL
WHERE appointment_date NOT LIKE '____-__-__' OR appointment_date IS NULL;

ALTER TABLE appointments_clean MODIFY COLUMN appointment_date DATE;

UPDATE appointments_clean
SET waiting_time_minutes = NULL
WHERE waiting_time_minutes < 0;

UPDATE appointments_clean
SET consultation_fee = NULL 
WHERE consultation_fee < 0;


UPDATE appointments_clean
SET consultation_duration_minutes = NULL 
WHERE consultation_duration_minutes <= 0;

DELETE t1 FROM appointments_clean t1
INNER JOIN appointments_clean t2 
WHERE t1.appointment_id = t2.appointment_id 
  AND t1.patient_id = t2.patient_id
  AND t1.appointment_date = t2.appointment_date
  AND t1.appointment_time = t2.appointment_time
  AND t1.appointment_id > t2.appointment_id;
  
  SELECT COUNT(*) FROM appointments_clean;

SET SQL_SAFE_UPDATES = 1;

-- Compare Raw data vs Clean data ---
SELECT 'appointments_raw' AS table_name, COUNT(*) AS row_count 
FROM appointments_raw
UNION ALL
SELECT 'appointments_clean' AS table_name, COUNT(*) AS row_count 
FROM appointments_clean;


SELECT 'patients_raw' AS table_name, COUNT(*) AS row_count FROM 
patients_raw
UNION ALL
SELECT 'patients_clean' AS table_name, COUNT(*) AS row_count FROM 
patients_clean;

SELECT 'doctors_raw' AS table_name, COUNT(*) AS row_count 
FROM doctors_raw
UNION ALL
SELECT 'departments_raw' AS table_name, COUNT(*) AS row_count 
FROM departments_raw;

SELECT appointment_id, COUNT(*) AS duplicate_count
FROM appointments_raw
GROUP BY appointment_id
HAVING COUNT(*) > 1;

SELECT patient_id, patient_name, COUNT(*) AS duplicate_count
FROM patients_raw
GROUP BY patient_id, patient_name
HAVING COUNT(*) > 1;

SELECT DISTINCT * 
FROM appointments_raw;

SELECT DISTINCT * 
FROM patients_raw;

SELECT 
patient_id, 
COUNT(*) AS occurrence_count
FROM patients_raw
GROUP BY patient_id
HAVING COUNT(*) > 1;

SELECT 
doctor_id, 
COUNT(*) AS occurrence_count
FROM doctors_raw
GROUP BY doctor_id
HAVING COUNT(*) > 1;

SELECT 
department_id, 
COUNT(*) AS occurrence_count
FROM departments_raw
GROUP BY department_id
HAVING COUNT(*) > 1;

SELECT 
appointment_id, 
patient_id, 
diagnosis, 
appointment_date
FROM appointments_clean
WHERE patient_id NOT IN (
SELECT patient_id 
FROM patients_clean
);


SELECT 
MIN(appointment_date) AS earliest_date, 
MAX(appointment_date) AS latest_date
FROM appointments_clean;

SELECT 
appointment_status, 
COUNT(*) AS label_count
FROM appointments_clean
GROUP BY appointment_status;

SELECT appointment_id, appointment_date
FROM appointments_raw
WHERE LENGTH(appointment_date) != 10 
   OR appointment_date NOT LIKE '____-__-__';

SET SQL_SAFE_UPDATES = 0;

UPDATE appointments_raw
SET appointment_date = TRIM(appointment_date)
WHERE appointment_id = 1525;

UPDATE appointments_clean
SET appointment_date = '2025-09-21'
WHERE appointment_id = 1525;

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;


UPDATE appointments_clean
SET appointment_date = STR_TO_DATE(appointment_date, '%d-%m-%Y')
WHERE appointment_date LIKE '__-__-____';

UPDATE appointments_clean
SET appointment_date = '2025-09-21'
WHERE appointment_id = 1525;

UPDATE appointments_clean
SET waiting_time_minutes = 0
WHERE waiting_time_minutes < 0;

SELECT COUNT(*) AS orphan_patient_rows
FROM appointments_clean a
LEFT JOIN patients_clean p ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

SELECT COUNT(*) AS orphan_doctor_rows
FROM appointments_clean a
LEFT JOIN doctors_clean d ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL;

SELECT COUNT(*) AS negative_waiting_time_rows
FROM appointments_clean
WHERE waiting_time_minutes < 0;

SELECT COUNT(*) AS total_appointments
FROM appointments_clean;

SELECT COUNT(*) AS completed_appointments
FROM appointments_clean
WHERE appointment_status = 'Completed';

SELECT appointment_id, COUNT(*) AS check_duplicate_count
FROM appointments_raw
GROUP BY appointment_id
HAVING COUNT(*) > 1;

SELECT 
    SUM(CASE WHEN appointment_status = 'Completed' THEN 1 ELSE 0 END) AS completed_appointments,
    COUNT(*) AS total_appointments,
    (SUM(CASE WHEN appointment_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS completion_rate
FROM appointments_clean;

SELECT AVG(waiting_time_minutes) AS avg_waiting_time
FROM appointments_clean
WHERE waiting_time_minutes >= 0;

SELECT SUM(consultation_fee) AS completed_consultation_revenue
FROM appointments_clean
WHERE appointment_status = 'Completed';





