<?php

include 'db_connection.php';
$conn = OpenCon();

$queries = [

   "1" => [
    "title" => "Explore doctors",
    "sql" => "SELECT * from staff where staff_type = 'doctor'  limit 20"
],
   "2" => [
    "title" => "Explore nurses",
    "sql" => "SELECT * from staff where staff_type = 'nurse'  limit 20"
],
   "3" => [
    "title" => "Explore administrators",
    "sql" => "SELECT * from staff where staff_type = 'administrator'  limit 20"
],
"4" => [
    "title" => "Explore departments",
    "sql" => "SELECT * from department  limit 20"
],
];

$selected = $_GET['query'] ?? null;

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" href="css/styles-queries.css">

<title>Explore</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>

<body>

<a href="index.php">
    <div class="home-icon">
        <i style="font-size:30px" class="fa">&#xf015;</i>
    </div>
</a>
<div class="container table-font">

    <h1>Explore Database</h1>

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
                    if($field->name == 'image_url'){
                        echo "<th>Image</th>";
                        break;
                    }
                echo "<th>{$field->name}</th>";
            }

           while($row = mysqli_fetch_assoc($result)){

    echo "<tr>";

    $values = array_values($row);
    $count = count($values);

    foreach($values as $index => $value){


        if($index == $count - 2){

            $img_url = $value;
            $img_desc = $values[$count - 1];

            echo "
            <td class='image-cell'>
                <img src='$img_url' class='doctor-image'>
                <div class='image-description'>
                    $img_desc
                </div>
            </td>
            ";

            break;
        }

        // skip last column because already used
        if($index == $count - 1){
            continue;
        }

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