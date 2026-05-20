<?php

include 'db_connection.php';
$conn = OpenCon();



$tablePrimaryKeys = [
    "phone" => ["phone_number"],
    "human" => ["AMKA"],
    "email" => ["AMKA", "email"],
    "staff" => ["AMKA"],
    "nurse" => ["AMKA"],
    "triage" => ["AMKA_patient", "admission_timestamp"],
    "patient" => ["AMKA"],
    "familiar" => ["AMKA_patient", "AMKA_familiar"],
    "insurance_provider" => ["provider_name"],
    "patient_insurance" => ["AMKA", "provider_name"],
    "doctor" => ["AMKA"],
    "administrator" => ["AMKA"],
    "building" => ["building_id"],
    "floor" => ["floor_number", "building_id"],
    "department" => ["dep_name"],
    "staff_dep" => ["AMKA", "dep_name"],
    "bed" => ["dep_name", "bed_number"],
    "shift" => ["dep_name", "shift_type", "date"],
    "staff_shift" => ["AMKA", "dep_name", "shift_type", "date"],
    "substance" => ["substance_name"],
    "has_allergy" => ["AMKA_patient", "substance_name"],
    "DRG" => ["DRG_code"],
    "diagnosis" => ["ICD_code"],
    "hospitalization" => ["AMKA_patient", "admission_timestamp"],
    "Medical_Actions_Catalog" => ["action_code"],
    "Operating_Room" => ["OR_number"],
    "Medical_Procedure" => ["proc_number"],
    "assisted_by" => ["proc_number", "AMKA_staff"],
    "Test_Catalog" => ["test_code"],
    "Lab_Test" => ["test_number"],
    "Medicine" => ["medicine_name"],
    "has_substance" => ["medicine_name", "substance_name"],
    "prescription" => [
        "AMKA_doctor",
        "AMKA_patient",
        "medicine_name",
        "date_of_start"
    ],
    "review" => ["AMKA_patient", "admission_timestamp"]
];


$tables = [];

$tables = array_keys($tablePrimaryKeys);
$selectedTable = $_GET['table'] ?? $tables[0];


if (isset($_POST['delete'])) {

    $table = $_POST['table'];

    if (isset($tablePrimaryKeys[$table])) {

        $conditions = [];

        foreach ($tablePrimaryKeys[$table] as $pk) {

            $value = mysqli_real_escape_string($conn, $_POST[$pk]);

            $conditions[] = "$pk = '$value'";
        }

        $whereClause = implode(" AND ", $conditions);

        $sql = "DELETE FROM `$table` WHERE $whereClause";

        mysqli_query($conn, $sql);
    }
}



if (isset($_POST['insert'])) {

    $table = $_POST['table'];

    $columnsRes = mysqli_query($conn, "SHOW COLUMNS FROM `$table`");

    $columns = [];
    $values = [];

    while ($col = mysqli_fetch_assoc($columnsRes)) {

        $field = $col['Field'];

        if (
            strpos($col['Extra'], 'auto_increment') !== false
        ) {
            continue;
        }

        if (isset($_POST[$field]) && $_POST[$field] !== '') {

            $columns[] = "`$field`";

            $value = mysqli_real_escape_string(
                $conn,
                $_POST[$field]
            );

            $values[] = "'$value'";
        }
    }

    if (!empty($columns)) {

        $sql = "
            INSERT INTO `$table`
            (" . implode(",", $columns) . ")
            VALUES
            (" . implode(",", $values) . ")
        ";

        mysqli_query($conn, $sql);
    }
}

?>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Database Admin Panel</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="css/styles-update.css">


</head>

<body>

<a href="index.php">
    <div class="home-icon">
        <i style="font-size:30px" class="fa">&#xf015;</i>
    </div>
</a>

<div class="container">

<h1>Η σελίδα του διαχειριστή</h1>
<h3>Η εισαγωγή γίνεται με τη σειρά που εμφανίζονται <br> οι σχέσεις για σεβασμό της αναφορικής ακεραιότητας</h3>



<form method="GET" class="top-bar">

    <select name="table">

        <?php foreach($tables as $table): ?>

            <option value="<?= $table ?>"
            <?= ($table == $selectedTable) ? 'selected' : '' ?>>

                <?= $table ?>

            </option>

        <?php endforeach; ?>

    </select>

    <button type="submit" class="run-btn">
        Απεικόνιση σχέσης
    </button>

</form>

<?php


$columnsRes = mysqli_query(
    $conn,
    "SHOW COLUMNS FROM `$selectedTable`"
);

?>

<div class="insert-form">

<h2>Εισαγωγή στο  <?= $selectedTable ?></h2>

<form method="POST">

<input type="hidden"
name="table"
value="<?= $selectedTable ?>">

<div class="form-grid">

<?php

while($column = mysqli_fetch_assoc($columnsRes)){

    $field = $column['Field'];

    if (
        strpos($column['Extra'], 'auto_increment') !== false
    ) {
        continue;
    }

    echo "
        <div>
            <label>$field</label><br>
            <input
                type='text'
                name='$field'
                placeholder='$field'
            >
        </div>
    ";
}

?>

</div>

<br>

<button
type="submit"
name="insert"
class="insert-btn">

Insert Row

</button>

</form>

</div>
<?php



$result = mysqli_query(
    $conn,
    "SELECT * FROM `$selectedTable`"
);

if($result && mysqli_num_rows($result) > 0){

    echo "<div class='table-wrapper'>";
    echo "<table>";

    echo "<tr>";



    while($field = mysqli_fetch_field($result)){

        if($field->name == 'image_url'){

            echo "<th>Image</th>";

            continue;
        }

        if($field->name == 'im_description'){
            continue;
        }

        echo "<th>{$field->name}</th>";
    }

    echo "<th>Actions</th>";

    echo "</tr>";

    

    while($row = mysqli_fetch_assoc($result)){

        echo "<tr>";

        foreach($row as $column => $value){



            if($column == 'image_url'){

                $img_url = $value;

                $img_desc = $row['im_description'] ?? '';

                echo "
                <td class='image-cell'>

                    <img
                    src='$img_url'
                    class='table-image'>

                    <div class='image-description'>
                        $img_desc
                    </div>

                </td>
                ";

                continue;
            }

            if($column == 'im_description'){
                continue;
            }

            echo "<td>$value</td>";
        }

      
        echo "<td>";

        echo "<form method='POST'>";

        echo "
        <input
        type='hidden'
        name='table'
        value='$selectedTable'>
        ";

        if(isset($tablePrimaryKeys[$selectedTable])){

            foreach($tablePrimaryKeys[$selectedTable] as $pk){

                $val = htmlspecialchars($row[$pk]);

                echo "
                <input
                type='hidden'
                name='$pk'
                value='$val'>
                ";
            }
        }

        echo "
        <button
        type='submit'
        name='delete'
        class='delete-btn'>

        Delete

        </button>
        ";

        echo "</form>";

        echo "</td>";

        echo "</tr>";
    }

    echo "</table>";
    echo "</div>";

} else {

    echo "<p>No records found.</p>";
}

?>

</div>

</body>
</html>