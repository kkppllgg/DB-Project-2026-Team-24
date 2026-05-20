CREATE TABLE phone (
    phone_number VARCHAR(15) PRIMARY KEY,
    phone_type VARCHAR(30) NOT NULL,
    CHECK (phone_type IN ('mobile','landline'))
);

CREATE TABLE human (
    AMKA BIGINT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    FOREIGN KEY (phone_number)
        REFERENCES phone(phone_number)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE email (
    AMKA BIGINT,
    email VARCHAR(50) NOT NULL,
    PRIMARY KEY (AMKA, email),
    FOREIGN KEY (AMKA)
        REFERENCES human(AMKA)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE staff (
    AMKA BIGINT PRIMARY KEY,
    hire_date DATE NOT NULL,
    staff_type VARCHAR(30) NOT NULL,
    image_url VARCHAR(300), 
    im_description VARCHAR(300),
    CHECK (staff_type IN ('doctor','administrator','nurse')),
    FOREIGN KEY (AMKA)
        REFERENCES human(AMKA)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- PATIENT MAY HAVE NULL VALUES
CREATE TABLE nurse (
    AMKA BIGINT PRIMARY KEY,
    rank VARCHAR(20) NOT NULL,
    FOREIGN KEY (AMKA)
        REFERENCES staff (AMKA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (rank IN ('assistant nurse','nurse','supervisor'))
);



CREATE TABLE triage (
    AMKA_patient BIGINT,
    admission_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    triage_discharge TIMESTAMP NULL,
    urgency INT(1) NOT NULL,
    AMKA_nurse BIGINT NOT NULL,
    state VARCHAR(20) NOT NULL DEFAULT 'active',

    PRIMARY KEY (AMKA_patient, admission_timestamp),

    CONSTRAINT fk_AMKA_nurse
    FOREIGN KEY (AMKA_nurse)
        REFERENCES nurse (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT urgency_values CHECK (urgency >= 1 AND urgency <= 5),
    CONSTRAINT state_values CHECK (state IN ('active', 'inactive'))
);



CREATE TABLE patient (
    AMKA BIGINT PRIMARY KEY,
    father_name VARCHAR(20),
    sex VARCHAR(20),
    weight FLOAT(5,2),
    height FLOAT(5,2),
    address VARCHAR(40),
    profession VARCHAR(30),
    citizenship VARCHAR(20),
    
    
    CONSTRAINT fk_patient_human 
    FOREIGN KEY (AMKA)
        REFERENCES human (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
        

    CONSTRAINT fk_patient_triage
    FOREIGN KEY (AMKA)
        REFERENCES triage (AMKA_patient)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE familiar (
    AMKA_patient BIGINT,
    AMKA_familiar BIGINT,
    PRIMARY KEY (AMKA_patient, AMKA_familiar),
    FOREIGN KEY (AMKA_patient)
        REFERENCES patient (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (AMKA_familiar)
        REFERENCES human (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
CREATE TABLE insurance_provider (
    provider_name VARCHAR(30) PRIMARY KEY
);


CREATE TABLE patient_insurance (
    AMKA BIGINT,
    provider_name VARCHAR(20),
    PRIMARY KEY (AMKA, provider_name),
    FOREIGN KEY (AMKA)
        REFERENCES patient (AMKA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (provider_name)
        REFERENCES insurance_provider (provider_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE doctor (
    AMKA BIGINT PRIMARY KEY,
    license_number BIGINT UNIQUE NOT NULL,
    specialization VARCHAR(20) NOT NULL,
    rank VARCHAR(20) NOT NULL,
    AMKA_supervisor BIGINT NULL,
    FOREIGN KEY (AMKA)
        REFERENCES staff (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (AMKA_supervisor)
        REFERENCES doctor (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (rank IN ('trainee','consultant B', 'consultant A', 'director')),
    CONSTRAINT trainee_supervisor
    CHECK (NOT(rank = 'trainee' AND AMKA_supervisor IS NULL))
);


CREATE TABLE administrator (
    AMKA BIGINT PRIMARY KEY,
    duty VARCHAR(20) NOT NULL,
    office VARCHAR(20) NOT NULL,
    FOREIGN KEY (AMKA)
        REFERENCES staff (AMKA)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE building (
    building_id INT(2) PRIMARY KEY
);

CREATE TABLE floor (
    floor_number INT(1),
    building_id INT(2),
    PRIMARY KEY (floor_number, building_id),
    FOREIGN KEY (building_id)
        REFERENCES building (building_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE department (
    dep_name VARCHAR(30) PRIMARY KEY,
    description VARCHAR(200) NULL,
    bed_count INT(4) DEFAULT 0,
    floor_number INT(1) NOT NULL,
    building_id INT(2) NOT NULL,
    AMKA_director BIGINT NOT NULL,
    image_url VARCHAR(300), 
    im_description VARCHAR(300),
    FOREIGN KEY (floor_number, building_id)
        REFERENCES floor (floor_number, building_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (AMKA_director)
        REFERENCES doctor (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE staff_dep (
    AMKA BIGINT,
    dep_name VARCHAR(30),
    PRIMARY KEY (AMKA, dep_name),
    FOREIGN KEY (AMKA)
        REFERENCES staff (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (dep_name)
        REFERENCES department (dep_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE bed (
    dep_name VARCHAR(30),
    bed_number INT,
    type VARCHAR(20),
    state VARCHAR(20),
    PRIMARY KEY (dep_name, bed_number),
    FOREIGN KEY (dep_name)
        REFERENCES department (dep_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (type IN ('ICU','single-bed','multi-bed')),
    CHECK (state IN ('free','occupied','under-maintenance'))
);

CREATE TABLE shift (
    dep_name VARCHAR(30),
    shift_type VARCHAR(20),
    date DATE,
    PRIMARY KEY (dep_name, shift_type, date),
    FOREIGN KEY (dep_name)
        REFERENCES department (dep_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (shift_type IN ('morning','noon','night'))
);

CREATE TABLE staff_shift (
    AMKA BIGINT,
    dep_name VARCHAR(30),
    shift_type VARCHAR(20),
    date DATE,
    PRIMARY KEY(AMKA, dep_name, shift_type, date),
    FOREIGN KEY (dep_name, shift_type, date)
        REFERENCES shift (dep_name, shift_type, date)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (AMKA)
        REFERENCES staff (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE substance (
    substance_name VARCHAR(260) NOT NULL,
    PRIMARY KEY (substance_name)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;


CREATE TABLE has_allergy (
    AMKA_patient BIGINT NOT NULL,
    substance_name VARCHAR(260) NOT NULL,

    PRIMARY KEY (AMKA_patient, substance_name),

    CONSTRAINT fk_allergy_patient
        FOREIGN KEY (AMKA_patient)
        REFERENCES patient (AMKA)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_allergy_substance
        FOREIGN KEY (substance_name)
        REFERENCES substance (substance_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;



CREATE TABLE DRG (
    DRG_code VARCHAR(6) PRIMARY KEY,
    description VARCHAR(500) NOT NULL,
    cost INT(6) NOT NULL,
    ALOS INT(3) NOT NULL,

    CONSTRAINT cost_gret_zero CHECK (cost >= 0),
    CONSTRAINT ALOS_gret_zero CHECK (ALOS >= 0)
);

CREATE TABLE diagnosis (
    ICD_code VARCHAR(7) PRIMARY KEY,
    title VARCHAR(200) NOT NULL
);

CREATE TABLE hospitalization (
    AMKA_patient BIGINT,
    admission_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    discharge_timestamp TIMESTAMP NULL,
    dep_name VARCHAR(30) NOT NULL,
    bed_number INT NOT NULL,
    DRG_code VARCHAR(6) NOT NULL,
    adm_code VARCHAR(7) NOT NULL,
    disch_code VARCHAR(7) NULL,
    total_cost DECIMAL(10,2) DEFAULT 0.00,

    PRIMARY KEY (AMKA_patient, admission_timestamp),

    CONSTRAINT fk_AMKA_adm
    FOREIGN KEY (AMKA_patient, admission_timestamp)
        REFERENCES triage (AMKA_patient, admission_timestamp)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_dep_bed
    FOREIGN KEY (dep_name, bed_number)
        REFERENCES bed (dep_name, bed_number)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_DRG_code
    FOREIGN KEY (DRG_code)
        REFERENCES DRG (DRG_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_adm_code
    FOREIGN KEY (adm_code)
        REFERENCES diagnosis (ICD_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_disch_code
    FOREIGN KEY (disch_code)
        REFERENCES diagnosis (ICD_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Medical_Actions_Catalog (
    action_code VARCHAR(15) PRIMARY KEY,
    action_name VARCHAR(3000) NOT NULL,
    category VARCHAR(60) NOT NULL,
    duration_min INT NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    CONSTRAINT check_category CHECK (category IN ('Supportive (Anesthesia)', 'Surgical', 'Diagnostic', 'Therapeutic'))
);


CREATE TABLE Operating_Room(
    OR_number INT(8) PRIMARY KEY,
    image_url VARCHAR(300),
    im_description VARCHAR(300)
);

CREATE TABLE Medical_Procedure(
    proc_number INT(11) PRIMARY KEY AUTO_INCREMENT,
    proc_code VARCHAR(20) NOT NULL,
    proc_name VARCHAR(3000) NOT NULL,
    proc_category VARCHAR(60) NOT NULL,
    proc_date DATE NOT NULL,
    start_slot DATETIME NOT NULL,
    end_slot DATETIME NOT NULL,
    proc_duration INT AS (TIMESTAMPDIFF(MINUTE, start_slot, end_slot)) STORED,
    proc_cost DECIMAL(10,2) DEFAULT 0.00,
    AMKA_performer BIGINT,
    AMKA_patient BIGINT,
    admission_timestamp TIMESTAMP,
    OR_number INT(8),

    FOREIGN KEY (AMKA_performer)
        REFERENCES doctor (AMKA)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (AMKA_patient, admission_timestamp)
        REFERENCES hospitalization(AMKA_patient, admission_timestamp)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (OR_number)
        REFERENCES Operating_Room(OR_number)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

     FOREIGN KEY (proc_code)
        REFERENCES medical_actions_catalog (action_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,


    CHECK (proc_category IN ('Supportive (Anesthesia)', 'Surgical', 'Diagnostic', 'Therapeutic')),
    CONSTRAINT timestamp_check CHECK (start_slot < end_slot)
);

CREATE TABLE assisted_by(
    proc_number INT(11),
    AMKA_staff BIGINT,
    PRIMARY KEY (proc_number, AMKA_staff),

    FOREIGN KEY (proc_number)
        REFERENCES Medical_Procedure(proc_number)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (AMKA_staff)
        REFERENCES staff(AMKA)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Test_Catalog (
        test_code VARCHAR(20) PRIMARY KEY,
        test_name VARCHAR(10000) NOT NULL,
        test_type VARCHAR(40) NOT NULL,
        test_cost DECIMAL(7,2) NOT NULL,
        CONSTRAINT check_test_type CHECK (test_type IN ('Imaging', 'Microbiology', 'Clinical'))
);
 
CREATE TABLE Lab_Test(
    test_number INT(11) PRIMARY KEY AUTO_INCREMENT,
    test_code VARCHAR(20) NOT NULL,
    test_type VARCHAR(40) NOT NULL,
    test_date DATE NOT NULL,
    test_result VARCHAR(250),
    test_cost DECIMAL(7,2) DEFAULT 0.00,
    AMKA_patient BIGINT,
    admission_timestamp TIMESTAMP,
    AMKA_doctor BIGINT,

    FOREIGN KEY (AMKA_patient, admission_timestamp)
        REFERENCES hospitalization(AMKA_patient, admission_timestamp)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (AMKA_doctor)
        REFERENCES doctor(AMKA)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (test_code)
        REFERENCES Test_Catalog(test_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


CREATE TABLE Medicine (
medicine_name VARCHAR(260) NOT NULL,
PRIMARY KEY (medicine_name)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin; 


CREATE TABLE has_substance (
    medicine_name VARCHAR(260) NOT NULL,
    substance_name VARCHAR(260) NOT NULL,

    PRIMARY KEY (medicine_name, substance_name),

    CONSTRAINT fk_medicine
        FOREIGN KEY (medicine_name)
        REFERENCES Medicine(medicine_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_substance
        FOREIGN KEY (substance_name)
        REFERENCES substance(substance_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;


CREATE TABLE prescription (
    AMKA_doctor BIGINT NOT NULL,
    AMKA_patient BIGINT NOT NULL,
    medicine_name VARCHAR(260) NOT NULL,
    date_of_start DATE NOT NULL,
    date_of_end DATE NOT NULL,
    dosage VARCHAR(20),
    frequency VARCHAR(50),
    admission_timestamp TIMESTAMP NOT NULL,

    PRIMARY KEY (
        AMKA_doctor,
        AMKA_patient,
        medicine_name,
        date_of_start
    ),

    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (AMKA_doctor)
        REFERENCES doctor(AMKA)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_prescription_hospitalization
        FOREIGN KEY (AMKA_patient, admission_timestamp)
        REFERENCES hospitalization(
            AMKA_patient,
            admission_timestamp
        )
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_prescription_medicine
        FOREIGN KEY (medicine_name)
        REFERENCES Medicine(medicine_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT date_check
        CHECK (date_of_start < date_of_end)
)
ENGINE=InnoDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;


CREATE TABLE review(
    AMKA_patient BIGINT,
    admission_timestamp TIMESTAMP,
    medical_care INT(1),
    nursing_care INT(1),
    cleanliness INT(1),
    food INT(1),
    overall_experience INT(1),

    PRIMARY KEY (AMKA_patient, admission_timestamp),

    FOREIGN KEY (AMKA_patient, admission_timestamp)
        REFERENCES hospitalization(AMKA_patient, admission_timestamp)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (medical_care >= 1 AND medical_care <= 5),
    CHECK (nursing_care >= 1 AND nursing_care <= 5),
    CHECK (cleanliness >= 1 AND cleanliness <= 5),
    CHECK (food >= 1 AND food <= 5),
    CHECK (overall_experience >= 1 AND overall_experience <= 5)
);




CREATE INDEX idx_staff_shift_concurrency ON staff_shift (date, shift_type);
CREATE INDEX idx_medical_procedure_rooms ON Medical_Procedure (start_slot, end_slot, OR_number);
CREATE INDEX idx_assisted_by_staff ON assisted_by (AMKA_staff, proc_number);
CREATE INDEX idx_has_substance_reverse ON has_substance (substance_name, medicine_name);
CREATE INDEX idx_hospitalization_discharge ON hospitalization (discharge_timestamp, dep_name, DRG_code);
CREATE INDEX idx_hospitalization_group_cost ON hospitalization (AMKA_patient, dep_name, total_cost); 
CREATE INDEX idx_doctor_specialization ON doctor (specialization, AMKA);
CREATE INDEX idx_human_age ON human (age, AMKA);


    CREATE OR REPLACE VIEW triage_queue AS
  SELECT t.AMKA_patient, t.admission_timestamp, t.urgency
  FROM triage t
  LEFT JOIN hospitalization h
	ON t.AMKA_patient = h.AMKA_patient AND t.admission_timestamp = h.admission_timestamp
	WHERE t.state = 'active'
	ORDER BY t.urgency, t.admission_timestamp;



CREATE OR REPLACE VIEW count_doctor_age_procedures AS
SELECT 
    d.AMKA AS AMKA, 
    h.age AS age, 
    count(mp.proc_number) AS count_medical_procedures
FROM doctor d 
INNER JOIN human h
ON d.AMKA = h.AMKA
LEFT JOIN medical_procedure mp
ON d.AMKA = mp.AMKA_performer
GROUP BY 
    d.AMKA, 
    h.age
HAVING age < 35;


DELIMITER $$
CREATE FUNCTION get_rank_value (rank_name VARCHAR(30))
	RETURNS INT
	DETERMINISTIC
BEGIN
	CASE rank_name
			WHEN 'trainee' THEN RETURN 1;
WHEN 'consultant B' THEN RETURN 2;
WHEN 'consultant A' THEN RETURN 3;
WHEN 'director' THEN RETURN 4;
ELSE RETURN 0;
END CASE;
	END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER supervisor_check_insert BEFORE INSERT ON doctor
	FOR EACH ROW
	BEGIN
DECLARE supervisor_rank VARCHAR(30);
		DECLARE doctor_rank VARCHAR(30);
DECLARE supervisor_rank_no INT;
		DECLARE doctor_rank_no  INT;
		IF NEW.AMKA_supervisor IS NOT NULL THEN
SELECT s.rank INTO supervisor_rank
		FROM doctor s
		WHERE s.AMKA =  NEW.AMKA_supervisor;

		SET doctor_rank =NEW.rank;
		IF supervisor_rank IS NOT NULL THEN
		SET supervisor_rank_no = get_rank_value(supervisor_rank);
		SET doctor_rank_no = get_rank_value(doctor_rank);

		IF supervisor_rank_no <= doctor_rank_no THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Supervisor must have higher rank';
END IF;
		END IF;
END IF;
		
	END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER supervisor_check_update BEFORE UPDATE ON doctor
	FOR EACH ROW
	BEGIN
		DECLARE supervisor_rank VARCHAR(30);
		DECLARE doctor_rank VARCHAR(30);
DECLARE supervisor_rank_no INT;
		DECLARE doctor_rank_no  INT;

IF NEW.AMKA_supervisor IS NOT NULL THEN

		SELECT s.rank INTO supervisor_rank
		FROM doctor s
		WHERE s.AMKA =  NEW.AMKA_supervisor;

		SET doctor_rank = OLD.rank;

		SET supervisor_rank_no = get_rank_value(supervisor_rank);
		SET doctor_rank_no = get_rank_value(doctor_rank);

		IF supervisor_rank_no <= doctor_rank_no THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Supervisor must have higher rank';
END IF;
END IF;
	END$$
DELIMITER ; 




drop trigger if exists staff_dep_cardinality;
drop trigger if exists staff_dep_cardinality_update;
DELIMITER $$
CREATE TRIGGER staff_dep_cardinality 
BEFORE INSERT ON staff_dep 
FOR EACH ROW
BEGIN
    DECLARE type VARCHAR(30);

    SELECT s.staff_type
    INTO type
    FROM staff AS s
    WHERE s.AMKA = NEW.AMKA;

  IF type IN ('nurse', 'supervisor') THEN
        IF EXISTS (
            SELECT 1
            FROM staff_dep
            WHERE AMKA = NEW.AMKA
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This type of staff can belong to only one department';
        END IF;
    END IF;


END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER staff_dep_cardinality_update
BEFORE UPDATE ON staff_dep
FOR EACH ROW
BEGIN
    DECLARE type VARCHAR(30);

    SELECT s.staff_type
    INTO type
    FROM staff AS s
    WHERE s.AMKA = NEW.AMKA;

    IF type IN ('nurse', 'supervisor') THEN
        IF EXISTS (
            SELECT 1
            FROM staff_dep
            WHERE AMKA = NEW.AMKA
              AND NOT (AMKA = OLD.AMKA AND dep_id = OLD.dep_name)
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This type of staff can belong to only one department';
        END IF;
    END IF;

END$$

DELIMITER ;



DROP PROCEDURE IF EXISTS shift_staff_insert;
DELIMITER $$
CREATE PROCEDURE shift_staff_insert(
    IN p_list VARCHAR(1100), 
    IN p_dep_name VARCHAR(30), 
    IN p_shift_type VARCHAR(20), 
    IN p_date DATE
)
BEGIN
    DECLARE v_token VARCHAR(30);
    DECLARE v_rest VARCHAR(1100);
    DECLARE doctor_count INT DEFAULT 0;
    DECLARE nurse_count INT DEFAULT 0;
    DECLARE administration_count INT DEFAULT 0;
    DECLARE trainee_count INT DEFAULT 0;
    DECLARE senior_count INT DEFAULT 0;


    CREATE TEMPORARY TABLE IF NOT EXISTS temp_numbers (
        AMKA BIGINT
    );

    TRUNCATE TABLE temp_numbers;

    SET v_rest = REPLACE(REPLACE(REPLACE(p_list, '\n', ''), '\r', ''), ' ', '');

    -- split comma separated list
    WHILE LENGTH(v_rest) > 0 DO
        IF LOCATE(',', v_rest) > 0 THEN
            SET v_token = SUBSTRING_INDEX(v_rest, ',', 1);
            SET v_rest = SUBSTRING(v_rest, LOCATE(',', v_rest) + 1);
        ELSE
            SET v_token = v_rest;
            SET v_rest = '';
        END IF;

   INSERT INTO temp_numbers(AMKA)
VALUES (CAST(TRIM(v_token) AS UNSIGNED));

    END WHILE;

    -- count staff types
    SELECT
        SUM(s.staff_type = 'doctor'),
        SUM(s.staff_type = 'nurse'),
        SUM(s.staff_type = 'administrator')
    INTO
        doctor_count,
        nurse_count,
        administration_count
    FROM temp_numbers t
    JOIN staff s ON t.AMKA = s.AMKA;

    -- validations
    IF doctor_count < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shift requires at least 3 doctors';
    END IF;

    IF nurse_count < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shift requires at least 6 nurses';
    END IF;

    IF administration_count < 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shift requires at least 2 administrators';
    END IF;

    -- count trainee and senior doctors
    SELECT
        SUM(d.rank = 'trainee'),
        SUM(d.rank IN ('consultant A', 'director'))
    INTO
        trainee_count,
        senior_count
    FROM temp_numbers t
    JOIN doctor d ON t.AMKA = d.AMKA;

    IF trainee_count > 0 AND senior_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shift with trainee requires consultant A or director';
    END IF;

INSERT INTO shift(dep_name, shift_type, date)
VALUES (p_dep_name, p_shift_type, p_date);



    INSERT INTO staff_shift (AMKA, dep_name, shift_type, date)
    SELECT t.AMKA, p_dep_name, p_shift_type, p_date
    FROM temp_numbers t;

    DROP TEMPORARY TABLE temp_numbers;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER shift_monthly_count
BEFORE INSERT ON staff_shift 
FOR EACH ROW
BEGIN
    DECLARE type_of_staff VARCHAR(30);
    DECLARE monthly_shift_count INT;

    -- Count shifts in the same month/year
    SELECT COUNT(*) INTO monthly_shift_count
    FROM staff_shift AS rel
    WHERE rel.AMKA = NEW.AMKA
      AND MONTH(rel.date) = MONTH(NEW.date)
      AND YEAR(rel.date) = YEAR(NEW.date);

    -- Get staff type
    SELECT staff_type INTO type_of_staff
    FROM staff
    WHERE staff.AMKA = NEW.AMKA;

    -- Check limits based on staff type
    IF (type_of_staff = 'doctor' AND monthly_shift_count >= 15) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maximum monthly shift count for doctors: 15';
    END IF;

    IF (type_of_staff = 'nurse' AND monthly_shift_count >= 20) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maximum monthly shift count for nurses: 20';
    END IF;

    IF (type_of_staff = 'administrator' AND monthly_shift_count >= 25) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maximum monthly shift count for administrators: 25';
    END IF;

END$$

DELIMITER ;




DELIMITER $$

CREATE TRIGGER shift_concurrency
BEFORE INSERT ON staff_shift
FOR EACH ROW
BEGIN
    DECLARE concurrent_shift_count INT DEFAULT 0;
    DECLARE night_streak_count INT DEFAULT 0;


    WITH nearby_shifts AS (
        SELECT shift_type, date
        FROM staff_shift s
        WHERE s.AMKA = NEW.AMKA
          AND (
                s.date = NEW.date
             OR s.date = DATE_ADD(NEW.date, INTERVAL 1 DAY)
             OR s.date = DATE_SUB(NEW.date, INTERVAL 1 DAY)
          )
    )
    SELECT
        SUM(
            (NEW.shift_type = 'morning' AND shift_type = 'night'
                AND date = DATE_SUB(NEW.date, INTERVAL 1 DAY))

         OR (NEW.shift_type = 'night' AND shift_type = 'morning'
                AND date = DATE_ADD(NEW.date, INTERVAL 1 DAY))

         OR (NEW.shift_type = 'noon'
                AND shift_type IN ('morning','night')
                AND date = NEW.date)

         OR (NEW.shift_type IN ('morning','night')
                AND shift_type = 'noon'
                AND date = NEW.date)
        )
    INTO concurrent_shift_count
    FROM nearby_shifts;

    IF concurrent_shift_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid concurrent shifts';
    END IF;


 

    WITH nights AS (
        SELECT date
        FROM staff_shift
        WHERE AMKA = NEW.AMKA
          AND shift_type = 'night'
          AND date BETWEEN DATE_SUB(NEW.date, INTERVAL 3 DAY)
                      AND DATE_ADD(NEW.date, INTERVAL 3 DAY)

        UNION ALL

        SELECT NEW.date
        WHERE NEW.shift_type = 'night'
    ),

    numbered AS (
        SELECT
            date,
            ROW_NUMBER() OVER (ORDER BY date) AS rn
        FROM nights
    ),

    grouped AS (
        SELECT
            date,
            DATE_SUB(date, INTERVAL rn DAY) AS grp
        FROM numbered
    )

    SELECT COUNT(*)
    INTO night_streak_count
    FROM (
        SELECT grp
        FROM grouped
        GROUP BY grp
        HAVING COUNT(*) >= 4
    ) AS t;

    IF night_streak_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot have 4 consecutive night shifts';
    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER insert_beds
AFTER INSERT ON bed
FOR EACH ROW
BEGIN 
    UPDATE department d
    SET d.bed_count = d.bed_count + 1
    WHERE d.dep_name = NEW.dep_name; 
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER delete_beds
AFTER DELETE ON bed
FOR EACH ROW
BEGIN 
    UPDATE department d
    SET d.bed_count = d.bed_count - 1
    WHERE d.dep_name = OLD.dep_name; 
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER update_beds
AFTER UPDATE ON bed
FOR EACH ROW
BEGIN
    IF OLD.dep_name <> NEW.dep_name THEN
        UPDATE department d
        SET d.bed_count = d.bed_count - 1
        WHERE d.dep_name = OLD.dep_name;
        UPDATE department d
        SET d.bed_count = d.bed_count + 1
        WHERE d.dep_name = NEW.dep_name;
    END IF;
END $$

DELIMITER ;


 
DROP PROCEDURE IF EXISTS calc_total_cost;
DELIMITER $$
CREATE PROCEDURE `calc_total_cost`(IN my_AMKA_patient BIGINT, IN my_admission_timestamp TIMESTAMP, OUT total_cost_result DECIMAL(10,2))
BEGIN
  DECLARE n_DRG_code VARCHAR(6);
  DECLARE n_cost INT(6);
  DECLARE n_ALOS INT(3);
  DECLARE n_discharge_timestamp TIMESTAMP;
  DECLARE days INT;
  DECLARE extra_charge_per_day INT DEFAULT 50;
 
  SELECT DRG_code, discharge_timestamp
  INTO n_DRG_code, n_discharge_timestamp  
  FROM hospitalization
  WHERE AMKA_patient = my_AMKA_patient AND admission_timestamp = my_admission_timestamp;
 
  SELECT cost, ALOS
  INTO n_cost, n_ALOS
  FROM DRG
  WHERE DRG_code=n_DRG_code;
 
  SET days = DATEDIFF(n_discharge_timestamp, my_admission_timestamp);
 
  IF (days > n_ALOS) THEN
	SET total_cost_result = n_cost + (days - n_ALOS) * extra_charge_per_day;
  ELSE
	SET total_cost_result = n_cost;
  END IF;
END$$
DELIMITER ;
 
 
 
DROP TRIGGER IF EXISTS auto_calc_cost;

DELIMITER $$
CREATE TRIGGER `auto_calc_cost` BEFORE UPDATE ON hospitalization FOR EACH ROW
BEGIN
  DECLARE local_cost DECIMAL(10,2);
  IF OLD.discharge_timestamp IS NULL AND NEW.discharge_timestamp IS NOT NULL THEN
    CALL calc_total_cost(NEW.AMKA_patient, NEW.admission_timestamp, local_cost);
    SET NEW.total_cost = local_cost;
  END IF;
END $$
DELIMITER ;


 
 
-- Patient being released process
-- discharge.timestamp: NULL to CURRENT_TIMESTAMP
-- If nothing changed (this update has happened before => patient has been already released), error.
 
DELIMITER $$
CREATE PROCEDURE release_procedure(IN my_AMKA_patient BIGINT, IN my_admission_timestamp TIMESTAMP)
BEGIN
  UPDATE hospitalization
  SET discharge_timestamp = CURRENT_TIMESTAMP
  WHERE AMKA_patient = my_AMKA_patient AND admission_timestamp = my_admission_timestamp AND discharge_timestamp IS NULL;
 
  IF ROW_COUNT() = 0 THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Either patient has already been released or patient does not exist';
  END IF;
END$$
DELIMITER ;

 

 
DELIMITER $$
CREATE TRIGGER `bed_occupied_after_admission` AFTER INSERT ON hospitalization FOR EACH ROW
BEGIN
  UPDATE bed
  SET state = 'occupied'
  WHERE bed_number = NEW.bed_number AND dep_name = NEW.dep_name;

END$$
DELIMITER ;
 
 

 
DELIMITER $$
CREATE TRIGGER `bed_free_after_discharge` AFTER UPDATE ON hospitalization FOR EACH ROW
BEGIN
  IF OLD.discharge_timestamp IS NULL AND NEW.discharge_timestamp IS NOT NULL THEN
	UPDATE bed
	SET state = 'free'
	WHERE bed_number = NEW.bed_number AND dep_name = NEW.dep_name;
  END IF; 
END$$
DELIMITER ;
 



DROP PROCEDURE IF EXISTS copy_medical_procedure_fields;
DELIMITER $$
CREATE PROCEDURE copy_medical_procedure_fields (
    IN p_proc_code VARCHAR(50),
    OUT p_proc_name VARCHAR(3000),
    OUT p_proc_category VARCHAR(60),
    OUT p_proc_cost DECIMAL(10,2)
)
BEGIN

   SELECT
       action_name,
       category,
       cost
   INTO
       p_proc_name,
       p_proc_category,
       p_proc_cost
   FROM Medical_Actions_Catalog
   WHERE action_code = p_proc_code;

END$$

DELIMITER ;





DROP PROCEDURE IF EXISTS copy_lab_test_fields;

DELIMITER $$

CREATE PROCEDURE copy_lab_test_fields (
    IN p_test_code VARCHAR(50),
    OUT p_test_type VARCHAR(40),
    OUT p_test_cost DECIMAL(7,2)
)
BEGIN

   SELECT
       test_type,
       test_cost
   INTO
       p_test_type,
       p_test_cost
   FROM Test_Catalog
   WHERE test_code = p_test_code;


END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER operation_room_insert
BEFORE INSERT ON Medical_Procedure
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE OR_number = NEW.OR_number AND (NOT (NEW.start_slot>=end_slot OR NEW.end_slot<=start_slot))
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'There is already an operation at that time and place.';
    END IF;
END$$

CREATE TRIGGER operation_room_update
BEFORE UPDATE ON Medical_Procedure
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE OR_number = NEW.OR_number AND (NOT (NEW.start_slot>=end_slot OR NEW.end_slot<=start_slot)) AND proc_number != NEW.proc_number
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'There is already an operation at that time and place.';
    END IF;
END$$
DELIMITER ;





DELIMITER $$

CREATE TRIGGER doctor_operation_insert
BEFORE INSERT ON Medical_Procedure
FOR EACH ROW
BEGIN
    -- Check if doctor is performing another overlapping operation as main surgeon
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE AMKA_performer = NEW.AMKA_performer 
          AND NEW.start_slot < end_slot 
          AND NEW.end_slot > start_slot
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The doctor already operates in another operation as main surgeon.';
    END IF;
    
    -- Check if doctor is assisting in another overlapping operation
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure mp
        JOIN assisted_by ab ON mp.proc_number = ab.proc_number
        WHERE ab.AMKA_staff = NEW.AMKA_performer
          AND NEW.start_slot < mp.end_slot 
          AND NEW.end_slot > mp.start_slot
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The doctor is already assisting in another operation at this time.';
    END IF;
END$$

CREATE TRIGGER doctor_operation_update
BEFORE UPDATE ON Medical_Procedure
FOR EACH ROW
BEGIN
    -- Check if doctor is performing another overlapping operation as main surgeon
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE AMKA_performer = NEW.AMKA_performer 
          AND NEW.start_slot < end_slot 
          AND NEW.end_slot > start_slot
          AND proc_number != NEW.proc_number
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The doctor already operates in another operation as main surgeon.';
    END IF;
    
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure mp
        JOIN assisted_by ab ON mp.proc_number = ab.proc_number
        WHERE ab.AMKA_staff = NEW.AMKA_performer
          AND NEW.start_slot < mp.end_slot 
          AND NEW.end_slot > mp.start_slot
          AND mp.proc_number != NEW.proc_number
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The doctor is already assisting in another operation at this time.';
    END IF;
END$$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER assistant_operation_insert
BEFORE INSERT ON assisted_by
FOR EACH ROW
BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;

    -- Get the operation times
    SELECT start_slot, end_slot INTO v_start, v_end 
    FROM Medical_Procedure 
    WHERE proc_number = NEW.proc_number;

    -- Check if staff is assisting in another overlapping operation
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure mp
        JOIN assisted_by ab ON mp.proc_number = ab.proc_number
        WHERE ab.AMKA_staff = NEW.AMKA_staff 
          AND v_start < mp.end_slot 
          AND v_end > mp.start_slot
          AND mp.proc_number != NEW.proc_number
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Assignment cancelled: This staff member is already assisting in another operation at this time.';
    END IF;
    
    -- Check if staff is performing as main surgeon in another overlapping operation
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE AMKA_performer = NEW.AMKA_staff 
          AND v_start < end_slot 
          AND v_end > start_slot
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Assignment cancelled: This staff member is already performing as main surgeon in another operation at this time.';
    END IF;
END$$

CREATE TRIGGER assistant_operation_update
BEFORE UPDATE ON assisted_by
FOR EACH ROW
BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;

    -- Get the operation times
    SELECT start_slot, end_slot INTO v_start, v_end 
    FROM Medical_Procedure 
    WHERE proc_number = NEW.proc_number;

    -- Check if staff is assisting in another overlapping operation
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure mp
        JOIN assisted_by ab ON mp.proc_number = ab.proc_number
        WHERE ab.AMKA_staff = NEW.AMKA_staff 
          AND v_start < mp.end_slot 
          AND v_end > mp.start_slot
          AND ab.proc_number != NEW.proc_number
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Update cancelled: This staff member is already assisting in another operation at this time.';
    END IF;
    
    -- Check if staff is performing as main surgeon in another overlapping operation
    IF EXISTS (
        SELECT 1 
        FROM Medical_Procedure 
        WHERE AMKA_performer = NEW.AMKA_staff 
          AND v_start < end_slot 
          AND v_end > start_slot
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Update cancelled: This staff member is already performing as main surgeon in another operation at this time.';
    END IF;
END$$


DELIMITER ;



DELIMITER $$

CREATE TRIGGER allergy_patient_insert
BEFORE INSERT ON prescription
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM has_allergy ha
        JOIN has_substance hs
            ON ha.substance_name = hs.substance_name
        WHERE ha.AMKA_patient = NEW.AMKA_patient
          AND hs.medicine_name = NEW.medicine_name
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The patient is allergic to an active substance of this medicine';
    END IF;
END$$


CREATE TRIGGER allergy_patient_update
BEFORE UPDATE ON prescription
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM has_allergy ha
        JOIN has_substance hs
            ON ha.substance_name = hs.substance_name
        WHERE ha.AMKA_patient = NEW.AMKA_patient
          AND hs.medicine_name = NEW.medicine_name
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The patient is allergic to an active substance of this medicine';
    END IF;
END$$

DELIMITER ;







DELIMITER $$

CREATE TRIGGER review_discharged
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE discharge_exists TIMESTAMP;
    
  
    SELECT discharge_timestamp INTO discharge_exists
    FROM hospitalization
    WHERE AMKA_patient = NEW.AMKA_patient 
      AND admission_timestamp = NEW.admission_timestamp;
    
  
    IF discharge_exists IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot add review: Patient has not been discharged yet';
    END IF;
END$$

DELIMITER ;






