-- ==============================================
--  FeedbackIQ — MySQL Database Schema
--  File: db/schema.sql
--  Run: mysql -u root -p < db/schema.sql
-- ==============================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS feedbackiq
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE feedbackiq;

-- ----------------------------------------------
-- TABLE: feedback
-- Stores all student feedback submissions
-- ----------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
  id          INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  name        VARCHAR(120)      NOT NULL,
  email       VARCHAR(180)      NOT NULL,
  subject     VARCHAR(100)      NOT NULL,
  message     TEXT              NOT NULL,
  rating      TINYINT UNSIGNED  NOT NULL CHECK (rating BETWEEN 1 AND 5),
  status      ENUM('pending','completed') NOT NULL DEFAULT 'pending',
  created_at  DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_status     (status),
  INDEX idx_rating     (rating),
  INDEX idx_subject    (subject),
  INDEX idx_created    (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------
-- TABLE: admin_users
-- Stores admin login credentials
-- ----------------------------------------------
CREATE TABLE IF NOT EXISTS admin_users (
  id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  username     VARCHAR(60)   NOT NULL UNIQUE,
  email        VARCHAR(180)  NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,           -- bcrypt hash
  role         ENUM('admin','superadmin') NOT NULL DEFAULT 'admin',
  is_active    BOOLEAN       NOT NULL DEFAULT TRUE,
  last_login   DATETIME,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------
-- TABLE: activity_log
-- Tracks admin actions (audit trail)
-- ----------------------------------------------
CREATE TABLE IF NOT EXISTS activity_log (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  admin_id    INT UNSIGNED  NOT NULL,
  action      VARCHAR(80)   NOT NULL,       -- e.g. 'mark_completed', 'delete'
  feedback_id INT UNSIGNED,
  notes       TEXT,
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (admin_id) REFERENCES admin_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
