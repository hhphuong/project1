CREATE DATABASE IF NOT EXISTS project_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE project_db;

CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO products (name, description, price, quantity, active)
SELECT 'Mechanical Keyboard K8', 'Wireless mechanical keyboard with RGB backlight', 1850000.00, 25, TRUE
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mechanical Keyboard K8');

INSERT INTO products (name, description, price, quantity, active)
SELECT '27-inch 4K IPS Monitor', 'USB-C 65W power delivery monitor for developers', 7900000.00, 12, TRUE
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '27-inch 4K IPS Monitor');

INSERT INTO products (name, description, price, quantity, active)
SELECT 'Ergonomic Wireless Mouse', 'Silent click mouse with multi-device Bluetooth', 650000.00, 40, TRUE
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ergonomic Wireless Mouse');
