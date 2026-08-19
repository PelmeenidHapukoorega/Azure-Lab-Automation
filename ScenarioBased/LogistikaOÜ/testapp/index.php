<?php

$host = getenv('MySQL_Host');
$username = getenv('MySQL_Username');
$password = getenv('MySQL_Password');
$database = 'fleettrackerdb';

$conn = mysqli_connect($host, $username, $password, $database);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$createTable = "CREATE TABLE IF NOT EXISTS test_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

mysqli_query($conn, $createTable);

$insert = "INSERT INTO test_entries (message) VALUES ('Page loaded at " . date('Y-m-d H:i:s') . "')";
mysqli_query($conn, $insert);

$result = mysqli_query($conn, "SELECT * FROM test_entries ORDER BY id DESC LIMIT 10");

echo "<h1>LogistikaOU Fleet tracker: Test page</h1>";
echo "<h2>Recent entries:</h2>";
echo "<ul>";

while ($row = mysqli_fetch_assoc($result)) {
    echo "<li>" . htmlspecialchars($row['message']) . "</li>";
}

echo "</ul>";