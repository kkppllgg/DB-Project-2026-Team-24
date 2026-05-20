<?php

include 'db_connection.php';
$conn = OpenCon();

$queries = [

   "1" => [
    "title" => "Q1: Συνολικά έσοδα του νοσοκομείου ανά τμήμα και ανά έτος, με ανάλυση ανά ΚΕΝ κωδικό και κατανομή νοσηλειών ανά ασφαλιστικό φορέα.",
    "sql" => "SELECT 
    COALESCE(CAST(summary.RawYear AS CHAR), 'All Years') AS Year,
    COALESCE(summary.dep_name, 'All Departments') AS dep_name,
    COALESCE(summary.DRG_code, 'All DRGs') AS DRG_code,
    COALESCE(summary.provider_name, 'All Providers') AS provider_name,
    summary.Expected_Cost AS 'Expected Cost',
    summary.Additional_Charge AS 'Additional Charge',
    summary.Income AS Income
FROM (
    SELECT 
        YEAR(h.discharge_timestamp) AS RawYear, 
        h.dep_name,
        h.DRG_code,
        i.provider_name,
        SUM(d.cost) AS Expected_Cost,
        SUM(h.total_cost - d.cost) AS Additional_Charge,
        SUM(h.total_cost) AS Income
    FROM hospitalization h 
    JOIN patient_insurance i ON h.AMKA_patient = i.AMKA
    JOIN DRG d ON d.DRG_code = h.DRG_code
    GROUP BY YEAR(h.discharge_timestamp), h.dep_name, h.DRG_code, i.provider_name
    WITH ROLLUP
) AS summary;
"
],

"2" => [
    "title" => "Q2: Για ειδικότητα Καρδιολόγου όλοι οι γιατροί που ανήκουν σε αυτήν, με ένδειξη αν είχαν εφημερία το τρέχον έτος και πόσες επεμβάσεις εκτέλεσαν ως κύριοι χειρουργοί.",
    "sql" => "SELECT 
d.AMKA AS AMKA, 
d.specialization AS specialization, 
CASE 
WHEN EXISTS (
SELECT AMKA from staff_shift sh
WHERE 
d.AMKA = sh.AMKA
AND sh.date >= '2026-01-01'
AND sh.date <= CURRENT_DATE
) THEN 'yes' ELSE 'no'
END AS had_night_shift_this_year, 
count(mp.proc_number) AS count_medical_procedures
FROM doctor d
LEFT JOIN medical_procedure mp
ON d.AMKA = mp.AMKA_performer
WHERE d.specialization = 'Καρδιολογία'
GROUP BY 
d.AMKA,
d.specialization;
"
],

"3" => [
    "title" => "Q3: Ασθενείς που έχουν νοσηλευτεί περισσότερες από 3 φορές στο ίδιο τμήμα, με το συνολικό κόστος νοσηλείας τους.",
    "sql" => "SELECT
	AMKA_patient,
	total_cost
FROM hospitalization
WHERE
	(AMKA_patient,dep_name) IN
(SELECT 
    AMKA_patient,
    dep_name
FROM hospitalization
GROUP BY AMKA_patient, dep_name
HAVING COUNT(*) > 3
ORDER BY AMKA_patient, dep_name);
"
],

"4" => [
    "title" => "Q4: Για γιατρό 11015032143 μέσος όρος αξιολογήσεων των ασθενών του  και η Συνολική εντύπωση νοσηλείας",
    "sql" => "SELECT AVG(r.medical_care) as avg_medical_care, AVG(r.overall_experience) AS avg_overall_experience
FROM ((
    SELECT DISTINCT AMKA_patient,admission_timestamp      FROM prescription
    WHERE AMKA_doctor = 11015032143) AS d
JOIN review AS r
    USING (AMKA_patient,admission_timestamp) );

"
],

"5" => [
    "title" => "Q5:  Νέοι ιατροί (ηλικία < 35 ετών) που έχουν εκτελέσει τις περισσότερες χειρουργικές επεμβάσεις ως κύριοι χειρουργοί.",
    "sql" => "SELECT 
    AMKA, 
    age, 
    count_medical_procedures 
FROM count_doctor_age_procedures
WHERE 
    count_medical_procedures = (
        SELECT MAX(count_medical_procedures)
        FROM count_doctor_age_procedures
);


"
],

"6" => [
    "title" => "Q6:  Για ασθενή 11015000070 το ιστορικό νοσηλειών του, οι αντίστοιχες διαγνώσεις (ICD-10), το συνολικό κόστος ανά νοσηλεία και ο μέσος όρος αξιολόγησής του",
    "sql" => "SELECT *
FROM
(
    SELECT 
        h.admission_timestamp,
        h.adm_code,
        h.disch_code,
        h.total_cost
    FROM hospitalization AS h
    WHERE h.AMKA_patient = 11015000070
) AS h
 NATURAL JOIN
(
    SELECT 
        r.admission_timestamp,
        (
            r.medical_care +
            r.nursing_care +
            r.cleanliness +
            r.food +
            r.overall_experience
        ) / 5 AS avg_rating
    FROM review AS r
    WHERE r.AMKA_patient = 11015000070
) AS r;

"
],

"7" => [
    "title" => "Q7: Για κάθε δραστική ουσία τον αριθμό ασθενών που έχουν δηλώσει αλλεργία και τον αριθμό φαρμάκων που την περιέχουν, ταξινομημένα κατά συνολικό αριθμό αλλεργικών ασθενών.",
    "sql" => "SELECT 
    s.substance_name AS substance, 
    count(DISTINCT ha.AMKA_patient) AS count_allergic_patients, 
    count(DISTINCT hs.medicine_name) AS count_medicine
FROM substance s
LEFT JOIN has_allergy ha
ON s.substance_name = ha.substance_name
LEFT JOIN has_substance hs
ON s.substance_name = hs.substance_name
GROUP BY s.substance_name
ORDER BY count_allergic_patients DESC;
"
],

"8" => [
    "title" => "Q8: Το προσωπικό που δεν έχει προγραμματισμένη εφημερία σε συγκεκριμένη ημερομηνία και τμήμα.",
    "sql" => "SELECT s.AMKA 
FROM staff s
LEFT JOIN staff_shift sh
ON 
    s.AMKA = sh.AMKA
    AND sh.dep_name = 'Cardiology' 
    AND sh.date = '2026-01-01'
WHERE sh.AMKA IS NULL;
"
],

"9" => [
    "title" => "Q9: Ποιοι ασθενείς νοσηλεύτηκαν τον ίδιο αριθμό ημερών σε διάστημα ενός έτους, με συνολική διάρκεια άνω των 15 ημερών",
    "sql" => "WITH bounded_hospitalizations AS (
	SELECT
    	AMKA_patient,
    	DATEDIFF(
        	LEAST(discharge_timestamp, '2025-12-31 23:59:59'),
        	GREATEST(admission_timestamp, '2025-01-01 00:00:00')
    	) AS duration_days
	FROM hospitalization
	WHERE admission_timestamp <= '2025-12-31 23:59:59'
  	AND (discharge_timestamp >= '2025-01-01 00:00:00' OR discharge_timestamp IS NULL)
)
SELECT
	AMKA_patient,
	duration_days
FROM bounded_hospitalizations
WHERE duration_days > 15
	  AND duration_days IN (
  	SELECT duration_days
  	FROM bounded_hospitalizations
  	GROUP BY duration_days
  	HAVING COUNT(DISTINCT AMKA_patient) > 1
  )
ORDER BY duration_days DESC, AMKA_patient ASC;
"
],

"10" => [
    "title" => "Q10: Τα top-3 ζεύγη δραστικών ουσιών που συνταγογραφήθηκαν ταυτόχρονα στον ίδιο ασθενή κατά την ίδια νοσηλεία, ταξινομημένα κατά συχνότητα εμφάνισης",
    "sql" => "SELECT
	s1.substance_name AS substance_1,
	s2.substance_name AS substance_2,
	COUNT(*) AS frequency
FROM prescription p1
JOIN has_substance s1
	ON p1.medicine_name = s1.medicine_name
JOIN prescription p2
	ON p1.AMKA_patient = p2.AMKA_patient
	AND p1.admission_timestamp = p2.admission_timestamp
JOIN has_substance s2
	ON p2.medicine_name = s2.medicine_name
WHERE s1.substance_name < s2.substance_name
GROUP BY s1.substance_name, s2.substance_name
ORDER BY frequency DESC
LIMIT 3;
"
],

"11" => [
    "title" => "Q11: Ιατροί που έχουν εκτελέσει τουλάχιστον 5 λιγότερες επεμβάσεις από τον ιατρό με τις περισσότερες επεμβάσεις στο τρέχον έτος",
    "sql" => "WITH doctors_rank AS (
        	SELECT
        	        	d.AMKA,
                    	count(mp.proc_number) AS count_procedures,
                    	MAX(count(mp.proc_number)) OVER () AS max_procedures
        	FROM doctor d
        	LEFT JOIN medical_procedure mp
        	ON
d.AMKA = mp.AMKA_performer
AND mp.proc_date >= '2026-01-01'
AND mp.proc_date <= CURRENT_DATE
        	GROUP BY d.AMKA
)
SELECT
        	AMKA,
        	count_procedures
FROM doctors_rank
WHERE count_procedures <= max_procedures - 5;

"
],

"12" => [
    "title" => "Q12:  Ο απαιτούμενος αριθμός προσωπικού ανά τμήμα και ανά βάρδια για  εβδομάδα 2026-01-01/08, με ανάλυση ανά υποκλάση προσωπικού",
    "sql" => "SELECT 
    ss.dep_name,
    ss.date,
    ss.shift_type,
    s.staff_type,
    CASE
        WHEN s.staff_type = 'doctor' THEN d.specialization
        WHEN s.staff_type = 'nurse' THEN n.rank
        WHEN s.staff_type = 'administrator' THEN a.duty
    END AS subclass_detail,
    COUNT(ss.AMKA) AS required_staff_count
FROM
    staff_shift ss 
LEFT JOIN 
    staff s ON ss.AMKA = s.AMKA 
LEFT JOIN 
    doctor d ON s.staff_type = 'doctor' AND ss.AMKA = d.AMKA
LEFT JOIN 
    nurse n ON s.staff_type = 'nurse' AND ss.AMKA = n.AMKA
LEFT JOIN 
    administrator a ON s.staff_type = 'administrator' AND ss.AMKA = a.AMKA
WHERE 
    ss.date BETWEEN '2026-01-01' AND '2026-01-08' 
GROUP BY 
    ss.dep_name,
    ss.date,
    ss.shift_type,
    s.staff_type,
    CASE
        WHEN s.staff_type = 'doctor' THEN d.specialization
        WHEN s.staff_type = 'nurse' THEN n.rank
        WHEN s.staff_type = 'administrator' THEN a.duty
    END
ORDER BY 
    ss.dep_name, 
    ss.date, 
    ss.shift_type;
"
],

"13" => [
    "title" => "Q13: Για κάθε ιατρό όλη την ιεραρχία εποπτείας του, από τον άμεσο επόπτη έως τον Διευθυντή, με ένδειξη του επιπέδου σε κάθε βαθμίδα.",
    "sql" => "WITH RECURSIVE chain AS (
    SELECT 
        AMKA AS start_AMKA,
        AMKA AS current_AMKA,
        rank,
        AMKA_supervisor,
        0 AS level
    FROM doctor

    UNION ALL

    SELECT 
        c.start_AMKA,
        d.AMKA,
        d.rank,
        d.AMKA_supervisor,
        c.level + 1
    FROM doctor d
    JOIN chain c
        ON d.AMKA = c.AMKA_supervisor
)
SELECT start_AMKA, rank, level, AMKA_supervisor
FROM chain
ORDER BY start_AMKA, level;
"
],

"14" => [
    "title" => "Q14: Ποιες κατηγορίες ICD-10 διαγνώσεων είχαν τον ίδιο αριθμό εισαγωγών σε δύο συνεχόμενα έτη, με τουλάχιστον 5 περιστατικά ανά έτος",
    "sql" => "WITH codes_per_year AS (
SELECT 
LEFT(adm_code, 1) AS ICD_category, 
YEAR(admission_timestamp) AS year, 
count(AMKA_patient) AS count 
FROM hospitalization
GROUP BY 
LEFT(adm_code, 1), 
YEAR(admission_timestamp)
HAVING count >= 5
)
SELECT DISTINCT cpy1.ICD_category
FROM codes_per_year cpy1
INNER JOIN codes_per_year cpy2
ON cpy1.ICD_category = cpy2.ICD_category
AND cpy1.count = cpy2.count
AND cpy2.year = cpy1.year + 1;
;"
],

"15" => [
    "title" => "Q15: Κατανομή των περιστατικών triage ανά επίπεδο επείγοντος, με μέσο χρόνο αναμονής ανά επίπεδο, ποσοστό περιστατικών που οδήγησαν σε νοσηλεία και κατανομή παραπομπών ανά τμήμα.",
    "sql" => "SELECT * 
FROM
(
    SELECT 
        urgency, 
        COUNT(*) AS distribution,
        AVG(TIMESTAMPDIFF(MINUTE, admission_timestamp, triage_discharge)) AS 'mean_wait',
AVG(state = 'inactive' )*100 AS 'hospitalization_percentage' 
    FROM triage
    GROUP BY urgency
) AS t1
JOIN 
(
    SELECT 
       t.urgency,
        h.dep_name,
        COUNT(*) AS dep_distr
    FROM (
        SELECT * 
        FROM triage
        WHERE state = 'inactive'
    ) AS t
    JOIN hospitalization AS h 
        ON t.AMKA_patient = h.AMKA_patient 
        AND t.admission_timestamp = h.admission_timestamp
    GROUP BY t.urgency, h.dep_name
) AS t2
ON t1.urgency = t2.urgency; 
"
]
];

$selected = $_GET['query'] ?? null;

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" href="css/styles-queries.css">

<title>Queries</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>

<body>
<a href="index.php">
    <div class="home-icon">
        <i style="font-size:30px" class="fa">&#xf015;</i>
    </div>
</a>
<div class="container table-font">

    <h1>Database Queries</h1>

    <form method="GET">

        <select name="query">

            <?php foreach($queries as $key => $query): ?>
                <option value="<?= $key ?>"
                    <?= ($selected == $key) ? 'selected' : '' ?>>
                    <?= $query['title'] ?>
                </option>
            <?php endforeach; ?>

        </select>

        <button type="submit">Run Query</button>

    </form>

    <?php

    if($selected && isset($queries[$selected])){

        $sql = $queries[$selected]['sql'];
        $result = mysqli_query($conn, $sql);

        if($result && mysqli_num_rows($result) > 0){

            echo "<div class='table-wrapper'>";
            echo "<table>";

       
            echo "<tr>";

            while($field = mysqli_fetch_field($result)){
                echo "<th>{$field->name}</th>";
            }


            echo "</tr>";

     
            while($row = mysqli_fetch_assoc($result)){

                echo "<tr>";

                foreach($row as $value){
                    echo "<td>$value</td>";
                }

                echo "</tr>";
            }

            echo "</table>";
            echo "</div>";

        } else {
            echo "<p>No results found.</p>";
        }
    }

    ?>

</div>

</body>
</html>