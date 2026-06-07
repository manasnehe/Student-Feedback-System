-- =====================================================
--  FeedbackIQ — Complete Database Dump
--  File  : feedbackiq_database.sql
--  How to import on XAMPP:
--    1. Open http://localhost/phpmyadmin
--    2. Click "Import" tab
--    3. Choose this file → Click "Go"
--  OR via command line:
--    mysql -u root -p < feedbackiq_database.sql
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- ─────────────────────────────────────────────────
-- CREATE & SELECT DATABASE
-- ─────────────────────────────────────────────────
CREATE DATABASE IF NOT EXISTS `feedbackiq`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `feedbackiq`;

-- ─────────────────────────────────────────────────
-- TABLE: feedback
-- ─────────────────────────────────────────────────
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id`         INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(120)      NOT NULL,
  `email`      VARCHAR(180)      NOT NULL,
  `subject`    VARCHAR(100)      NOT NULL,
  `message`    TEXT              NOT NULL,
  `rating`     TINYINT UNSIGNED  NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `status`     ENUM('pending','completed') NOT NULL DEFAULT 'pending',
  `created_at` DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                 ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status`  (`status`),
  KEY `idx_rating`  (`rating`),
  KEY `idx_subject` (`subject`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────
-- TABLE: admin_users
-- ─────────────────────────────────────────────────
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `username`      VARCHAR(60)   NOT NULL,
  `email`         VARCHAR(180)  NOT NULL,
  `password_hash` VARCHAR(255)  NOT NULL,
  `role`          ENUM('admin','superadmin') NOT NULL DEFAULT 'admin',
  `is_active`     TINYINT(1)    NOT NULL DEFAULT 1,
  `last_login`    DATETIME      DEFAULT NULL,
  `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email`    (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────
-- TABLE: activity_log
-- ─────────────────────────────────────────────────
DROP TABLE IF EXISTS `activity_log`;
CREATE TABLE `activity_log` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `admin_id`    INT UNSIGNED  NOT NULL,
  `action`      VARCHAR(80)   NOT NULL,
  `feedback_id` INT UNSIGNED  DEFAULT NULL,
  `notes`       TEXT          DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_admin` (`admin_id`),
  CONSTRAINT `fk_admin` FOREIGN KEY (`admin_id`)
    REFERENCES `admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────
-- DATA: admin_users
-- Default login → username: admin  |  password: Admin@123
-- (bcrypt hash — verify in PHP with password_verify())
-- ─────────────────────────────────────────────────
INSERT INTO `admin_users` (`username`, `email`, `password_hash`, `role`, `is_active`) VALUES
('admin', 'admin@feedbackiq.edu',
 '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
 'superadmin', 1);

-- ─────────────────────────────────────────────────
-- DATA: feedback (6 sample entries)
-- ─────────────────────────────────────────────────
INSERT INTO `feedback` (`name`, `email`, `subject`, `message`, `rating`, `status`, `created_at`) VALUES
('Priya Desai',
 'priya@college.edu',
 'Course Content Quality',
 'The course material for Data Structures was incredibly well structured. Each module built logically on the previous one, making complex topics approachable and easy to follow.',
 5, 'completed', '2025-03-10 10:15:00'),

('Rahul Mehta',
 'rahul.m@college.edu',
 'Faculty Teaching Methods',
 'Professor Sharma needs to include more practical examples during lectures. The theoretical content is fine but lacks real-world application context for students.',
 2, 'pending', '2025-03-14 09:40:00'),

('Sneha Iyer',
 'sneha.i@college.edu',
 'Campus Infrastructure',
 'The Wi-Fi in the library blocks remains consistently weak during peak hours between 10am to 2pm, which makes online research very difficult.',
 3, 'pending', '2025-03-18 11:05:00'),

('Aryan Kapoor',
 'aryan.k@college.edu',
 'Online Learning Platform',
 'The new LMS portal is fast and easy to navigate. Assignment submission and grade tracking features are excellent additions to the system.',
 4, 'completed', '2025-03-22 14:30:00'),

('Meera Nair',
 'meera.n@college.edu',
 'Library & Resources',
 'More recent editions of reference books should be added to the library. The current collection is outdated for post-graduate level research.',
 3, 'pending', '2025-03-25 16:00:00'),

('Karan Singh',
 'karan.s@college.edu',
 'Administrative Services',
 'The fee receipt generation process online has improved a lot this semester. It used to take 3 to 4 days but now it is instant which saves a lot of time.',
 5, 'completed', '2025-04-01 08:20:00');

-- ─────────────────────────────────────────────────
-- USEFUL QUERIES (run manually in phpMyAdmin)
-- ─────────────────────────────────────────────────

-- View all feedback:
-- SELECT * FROM feedback ORDER BY created_at DESC;

-- Dashboard stats:
-- SELECT COUNT(*) AS total, SUM(status='pending') AS pending,
--        SUM(status='completed') AS completed, ROUND(AVG(rating),1) AS avg_rating
-- FROM feedback;

-- Filter pending:
-- SELECT * FROM feedback WHERE status = 'pending';

-- Filter by subject:
-- SELECT * FROM feedback WHERE subject = 'Campus Infrastructure';

-- Filter by minimum rating:
-- SELECT * FROM feedback WHERE rating >= 4;

-- Search by name:
-- SELECT * FROM feedback WHERE name LIKE '%Priya%';

-- Mark as completed:
-- UPDATE feedback SET status = 'completed' WHERE id = 2;

-- Delete a feedback:
-- DELETE FROM feedback WHERE id = 3;

-- Count per subject:
-- SELECT subject, COUNT(*) AS count, ROUND(AVG(rating),1) AS avg_rating
-- FROM feedback GROUP BY subject ORDER BY count DESC;

-- Rating distribution:
-- SELECT rating, COUNT(*) AS count FROM feedback GROUP BY rating ORDER BY rating;
