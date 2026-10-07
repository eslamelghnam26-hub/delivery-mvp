-- ============================================================
-- Delivery MVP - On-Demand Services - Database Schema
-- MariaDB / MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS delivery_mvp
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE delivery_mvp;

-- ---------------------------------------------
-- USERS: customer / provider / admin
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(160) NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer','provider','admin') NOT NULL DEFAULT 'customer',
  lang ENUM('ar','en') NOT NULL DEFAULT 'ar',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_users_role (role)
) ENGINE=InnoDB;

-- Provider profile extension
CREATE TABLE IF NOT EXISTS provider_profiles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  service_id BIGINT UNSIGNED NULL,
  bio VARCHAR(500) NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 5.00,
  jobs_count INT UNSIGNED NOT NULL DEFAULT 0,
  is_online TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------
-- SERVICES
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS services (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name_ar VARCHAR(120) NOT NULL,
  name_en VARCHAR(120) NOT NULL,
  icon VARCHAR(60) DEFAULT 'misc',
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------
-- ORDERS
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_no VARCHAR(16) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NOT NULL,
  provider_id BIGINT UNSIGNED NULL,
  service_id BIGINT UNSIGNED NOT NULL,
  lat DECIMAL(10,7) NOT NULL,
  lng DECIMAL(10,7) NOT NULL,
  address VARCHAR(255) NULL,
  description TEXT NULL,
  status ENUM('pending','accepted','on_the_way','in_service','completed','rejected','canceled')
    NOT NULL DEFAULT 'pending',
  customer_rating TINYINT NULL,
  provider_rating TINYINT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  CONSTRAINT fk_ord_customer FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ord_provider FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_ord_service FOREIGN KEY (service_id) REFERENCES services(id),
  KEY idx_orders_status (status),
  KEY idx_orders_provider (provider_id),
  KEY idx_orders_customer (customer_id)
) ENGINE=InnoDB;

-- ---------------------------------------------
-- LIVE LOCATIONS (provider tracking)
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS locations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  lat DECIMAL(10,7) NOT NULL,
  lng DECIMAL(10,7) NOT NULL,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_loc_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_loc_user_time (user_id, recorded_at)
) ENGINE=InnoDB;

-- ---------------------------------------------
-- NOTIFICATIONS
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NULL,
  ref_type VARCHAR(30) NULL,
  ref_id BIGINT UNSIGNED NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_notif_user_read (user_id, is_read)
) ENGINE=InnoDB;

-- ---------------------------------------------
-- API TOKENS (simple bearer auth)
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS api_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_token_expires (expires_at)
) ENGINE=InnoDB;

-- ---------------------------------------------
-- SEED DATA
-- ---------------------------------------------
INSERT INTO services (name_ar, name_en, icon) VALUES
  ('سباكة','Plumbing','plumbing'),
  ('كهرباء','Electrical','electrical'),
  ('تنظيف','Cleaning','cleaning'),
  ('توصيل','Delivery','delivery'),
  ('صيانة منزلية','Home Repair','repair');

-- admin / demo users
-- password: 123456 (hashed bcrypt)
INSERT INTO users (name, phone, password_hash, role) VALUES
  ('Admin','01000000000','$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFxHBCSFpz8qWvcMo3DO9cAqKXVd0LNa','admin'),
  ('Mohamed Customer','01011111111','$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFxHBCSFpz8qWvcMo3DO9cAqKXVd0LNa','customer'),
  ('Ahmed Plumber','01022222222','$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFxHBCSFpz8qWvcMo3DO9cAqKXVd0LNa','provider');