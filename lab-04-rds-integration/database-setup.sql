-- Script para configurar la base de datos del Lab 4

CREATE DATABASE IF NOT EXISTS lab4_rds;
USE lab4_rds;

SET time_zone = '-05:00';

CREATE TABLE IF NOT EXISTS formulario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATETIME DEFAULT (NOW())
);

DESCRIBE formulario;