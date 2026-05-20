SET NAMES utf8mb4;

-- CORE TABLES FIRST (no foreign key dependencies)
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/phone.csv'
INTO TABLE phone
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/human.csv'
INTO TABLE human
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/email.csv'
INTO TABLE email
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/staff.csv'
INTO TABLE staff
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@AMKA, @hire_date, @staff_type, @image_url, @im_description)
SET
AMKA = @AMKA,
hire_date = STR_TO_DATE(@hire_date, '%d/%m/%Y'),
staff_type = @staff_type,
image_url = @image_url,
im_description = @im_description;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/nurse.csv'
INTO TABLE nurse
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/triage.csv'
INTO TABLE triage
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@AMKA_patient, @admission_timestamp, @urgency, @AMKA_nurse, @state, @triage_discharge)
SET
AMKA_patient = @AMKA_patient,
admission_timestamp = STR_TO_DATE(@admission_timestamp, '%d/%m/%Y %H:%i'),
urgency = @urgency,
AMKA_nurse = @AMKA_nurse,
state = @state,
triage_discharge = IF(@triage_discharge = '' OR @triage_discharge IS NULL, NULL, STR_TO_DATE(@triage_discharge, '%d/%m/%Y %H:%i'));


LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/patient.csv'
INTO TABLE patient
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/familiar.csv'
INTO TABLE familiar
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/insurance_provider.csv'
INTO TABLE insurance_provider
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/patient_insurance.csv'
INTO TABLE patient_insurance
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- In order to load doctor who self-references
SET FOREIGN_KEY_CHECKS = 0;
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/doctor.csv'
INTO TABLE doctor
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AMKA, license_number, specialization, rank, @AMKA_supervisor)
SET AMKA_supervisor = NULLIF(@AMKA_supervisor, '');
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/administrator.csv'
INTO TABLE administrator
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- BUILDING / FLOOR / DEPARTMENT / BED / SHIFT
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/building.csv'
INTO TABLE building
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/floor.csv'
INTO TABLE floor
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/department.csv'
INTO TABLE department
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/staff_dep.csv'
INTO TABLE staff_dep
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/bed.csv'
INTO TABLE bed
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/shift.csv'
INTO TABLE shift
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(dep_name, shift_type, @dummy_date)
SET date = STR_TO_DATE(@dummy_date, '%d/%m/%Y');

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/staff_shift.csv'
INTO TABLE staff_shift
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AMKA, dep_name, shift_type, @dummy_date)
SET date = STR_TO_DATE(@dummy_date, '%d/%m/%Y');

-- SUBSTANCE / ALLERGY
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/substance.csv'
INTO TABLE substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/has_allergy.csv'
INTO TABLE has_allergy
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- DIAGNOSIS / DRG
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/DRG.csv'
INTO TABLE DRG
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/diagnosis.csv'
INTO TABLE diagnosis
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- HOSPITALIZATION
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/hospitalization.csv'
INTO TABLE hospitalization
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AMKA_patient, @adm_ts, @dis_ts, dep_name, bed_number, DRG_code, adm_code, disch_code, total_cost)
SET admission_timestamp = STR_TO_DATE(@adm_ts, '%d/%m/%Y %H:%i'),
    discharge_timestamp = STR_TO_DATE(@dis_ts, '%d/%m/%Y %H:%i');


-- MEDICAL PROCEDURES
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Medical_Actions_Catalog.csv'
INTO TABLE Medical_Actions_Catalog
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Operating_Room.csv'
INTO TABLE Operating_Room
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Medical_Procedure.csv'
INTO TABLE Medical_Procedure
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(proc_number, proc_code, proc_name, proc_category, @p_date, @s_slot, @e_slot, proc_duration, proc_cost, AMKA_performer, AMKA_patient, @adm_ts, OR_number)
SET proc_date = STR_TO_DATE(@p_date, '%d/%m/%Y'),
    start_slot = STR_TO_DATE(@s_slot, '%d/%m/%Y %H:%i'),
    end_slot = STR_TO_DATE(@e_slot, '%d/%m/%Y %H:%i'),
    admission_timestamp = STR_TO_DATE(@adm_ts, '%d/%m/%Y %H:%i');

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/assisted_by.csv'
INTO TABLE assisted_by
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- LAB TESTS
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Test_Catalog.csv'
INTO TABLE Test_Catalog
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Lab_Test.csv'
INTO TABLE Lab_Test
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(test_number, test_code, test_type, @t_date, test_result, test_cost, AMKA_patient, @adm_ts, AMKA_doctor)
SET test_date = STR_TO_DATE(@t_date, '%d/%m/%Y'),
    admission_timestamp = STR_TO_DATE(@adm_ts, '%d/%m/%Y %H:%i');

    
-- MEDICINE
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/Medicine.csv'
INTO TABLE Medicine
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/has_substance.csv'
INTO TABLE has_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/prescription.csv'
INTO TABLE prescription
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AMKA_doctor, AMKA_patient, medicine_name, date_of_start, date_of_end, dosage, frequency, @adm_ts)
SET admission_timestamp = STR_TO_DATE(@adm_ts, '%d/%m/%Y %H:%i');

-- REVIEW
LOAD DATA INFILE 'C:/xampp/htdocs/csv_imports/review.csv'
INTO TABLE review
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(AMKA_patient, @v_admission_timestamp, medical_care, nursing_care, cleanliness, food, overall_experience)
SET admission_timestamp = STR_TO_DATE(@v_admission_timestamp, '%e/%c/%Y %H:%i');