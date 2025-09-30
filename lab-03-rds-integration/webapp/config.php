<?php
// Configuración de la base de datos RDS
define('DB_HOST', '[RDS-ENDPOINT]'); // Reemplazar con el endpoint real de RDS
define('DB_NAME', 'lab3_rds');
define('DB_USER', 'admin');
define('DB_PASS', 'Lab123456*'); // Usar la contraseña configurada en RDS

date_default_timezone_set('America/Lima');

function conectarDB() {
    try {
        $pdo = new PDO(
            "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8",
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]
        );
        // Configurar zona horaria para esta conexión
        $pdo->exec("SET time_zone = '-05:00'");
        $pdo->exec("SET SESSION time_zone = '-05:00'");
        return $pdo;
    } catch (PDOException $e) {
        die("Error de conexión: " . $e->getMessage());
    }
}
?>