<?php

$host = getenv('MySQL_Host');
$username = getenv('MySQL_Username');
$password = getenv('MySQL_Password');
$database = 'fleettrackerdb';
$appInsightsKey = getenv('AppInsights_InstrumentationKey');

$telemetryPayload = json_encode([
    "name" => "Microsoft.ApplicationInsights.Event",
    "time" => date('c'),
    "iKey" => $appInsightsKey,
    "data" => [
        "baseType" => "EventData",
        "baseData" => [
            "ver" => 2,
            "name" => "PageLoaded",
            "properties" => [
                "page" => "index"
            ]
        ]
    ]
]);

$ch = curl_init('https://dc.services.visualstudio.com/v2/track');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $telemetryPayload);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);


echo "<!-- AppInsights response code: $httpCode, body: $response -->";

$conn = mysqli_init();
mysqli_ssl_set($conn, NULL, NULL, "/var/www/html/azure-mysql-ca-bundle.pem", NULL, NULL);
mysqli_real_connect($conn, $host, $username, $password, $database, 3306, NULL, MYSQLI_CLIENT_SSL);

if  (mysqli_connect_errno()) {
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