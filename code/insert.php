<?php
include_once 'db_connection.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/styles-insert.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>Διαδικασίες</title>
</head>
<body>

<a href="index.php">
    <div class="home-icon">
        <i style="font-size:30px" class="fa">&#xf015;</i>
    </div>
</a>

<div class="container table-font">
    <h1>Εισαγωγή Βάρδιας</h1>
    <h4>Επίδειξη:</h4>
    <h6>11015009598,11015097886,11015012325,11015079227,11015091597,11015085274,11015005752,11015027863,11015056000,11015068774,11015072046,11015086610</h6>
    <h6>Cardiology</h6>
    <h6>noon</h6>
    <h6>2026-06-09</h6>
    <form class="form-container" method="POST" action="">
        <input type="text" name="amka_list" placeholder="AMKAs (comma-separated)" required>
        <input type="text" name="dep_name" placeholder="Department" required>
        <input type="text" name="shift_type" placeholder="Shift Type" required>
        <input type="text" name="shift_date" placeholder="Shift Date" required>
        <button type="submit" name="submit_shift">Submit</button>
    </form>
</div>

<div class="container table-font">
    <h1>Εξιτήριο ασθενή</h1>
    <h4>11015057394, 2026-03-05 15:16:00 for demonstration</h4>
    <form class="form-container" method="POST" action="">
        <input type="text" name="amka_patient" placeholder="AMKA patient" required>
        <input type="text" name="admission_date" placeholder="Admission timestamp" required>
        <button type="submit" name="submit_release">Submit</button>
    </form>
</div>

<div class="container table-font">
    <h1>Πληροφορίες για Ιατρική Πράξη</h1>
    <h4>A400095 για επίδειξη</h4>
    <form class="form-container" method="POST" action="">
        <input type="text" name="proc_code" placeholder="Procedure Code" required>
        <button type="submit" name="submit_proc">Submit</button>
    </form>
</div>

<div class="container table-font">
    <h1>Πληροφορίες για Εργαστηριακή Εξέταση</h1>
    <h4>B300111 για επίδειξη</h4>
    <form class="form-container" method="POST" action="">
        <input type="text" name="test_code" placeholder="Lab Test Code" required>
        <button type="submit" name="submit_test">Submit</button>
    </form>
</div>


<div class="container table-font">
    <h1>Επόμενοι ασθενείς triage προς εξυπηρέτηση</h1>
    <form class="form-container" method="POST" action="">
        <input type="text" name="number" placeholder="Next n patients" required>
        <button type="submit" name="submit_triage">Submit</button>
    </form>
</div>

<?php

if(isset($_POST['submit_shift'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    $amka_list = trim($_POST['amka_list']);
    $amka_list = preg_replace('/\s+/', '', $amka_list);
    
    // Φιλτράρισμα και αφαίρεση διπλότυπων AMKA στην PHP
    $amka_array = explode(',', $amka_list);
    $unique_amka = array_unique($amka_array);
    $amka_list = implode(',', $unique_amka);

    $dep_name = $_POST['dep_name'];
    $shift_type = $_POST['shift_type'];
    $shift_date = $_POST['shift_date'];

    $stmt = $conn->prepare("CALL shift_staff_insert(?, ?, ?, ?)");
    $stmt->bind_param("ssss", $amka_list, $dep_name, $shift_type, $shift_date);
    
    if ($stmt->execute()) {
        echo "<div class='container'><p style='color:green;'>Success! Staff shifts inserted.</p></div>";
    } else {
        echo "<div class='container'><p style='color:red;'>Error: " . $stmt->error . "</p></div>";
    }
    
    $stmt->close();
    $conn->close();
}


if(isset($_POST['submit_release'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    $amka_patient = $_POST['amka_patient'];
    $admission_date = $_POST['admission_date'];

    $stmt = $conn->prepare("CALL release_procedure(?, ?)");
    $stmt->bind_param("ss", $amka_patient, $admission_date);
    
    if ($stmt->execute()) {
        echo "<div class='container'><p style='color:green;'>Success! Patient released!</p></div>";
    } else {
        echo "<div class='container'><p style='color:red;'>Error: " . $stmt->error . "</p></div>";
    }
    
    $stmt->close();
    $conn->close();
}


if(isset($_POST['submit_proc'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $proc_code = $_POST["proc_code"];
    $sql = "CALL copy_medical_procedure_fields(?, @p_proc_name, @p_proc_category, @p_proc_cost)";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $proc_code);

    if($stmt->execute()){
        $stmt->close();
        
        $result = $conn->query("SELECT @p_proc_name, @p_proc_category, @p_proc_cost");
        $row = $result->fetch_row();

        echo "<div class='container table-font'>";
        echo "<strong>Procedure Name:</strong> " . $row[0] . "<br>";
        echo "<strong>Category:</strong> " . $row[1] . "<br>";
        echo "<strong>Cost:</strong> $" . $row[2] . "<br>";
        echo "</div>";
    } else {
        echo "<div class='container'><p style='color:red;'>Error: " . $stmt->error . "</p></div>";
    }
    $conn->close();
}


if(isset($_POST['submit_test'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $test_code = $_POST["test_code"];
    $sql = "CALL copy_lab_test_fields(?, @t_type, @t_cost)";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $test_code);

    if($stmt->execute()){
        $stmt->close();

        $result = $conn->query("SELECT @t_type, @t_cost");
        $row = $result->fetch_row();

        echo "<div class='container table-font'>";
        echo "<strong>Test Type:</strong> " . $row[0] . "<br>";
        echo "<strong>Test Cost:</strong> $" . $row[1] . "<br>";
        echo "</div>";
    } else {
        echo "<div class='container'><p style='color:red;'>Error: " . $stmt->error . "</p></div>";
    }
    $conn->close();
}
if(isset($_POST['submit_triage'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $number = $_POST["number"];
    $sql = "SELECT * FROM triage_queue LIMIT ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $number);  
    $stmt->execute();
    $result = $stmt->get_result();  

    if(isset($_POST['submit_triage'])){
    $conn = OpenCon();
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $number = $_POST["number"];
    $sql = "SELECT * FROM triage_queue LIMIT ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $number);
    $stmt->execute();
    $result = $stmt->get_result();

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
    
    $stmt->close();
    $conn->close();

    }
}

?>

</body>
</html>