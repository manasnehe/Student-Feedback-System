-- ==============================================
--  FeedbackIQ — SQL Queries Reference
--  File: db/queries.sql
--  Use these queries in your backend / testing
-- ==============================================

USE feedbackiq;

-- ──────────────────────────────────────────────
-- 1. INSERT — Submit new feedback
-- ──────────────────────────────────────────────
INSERT INTO feedback (name, email, subject, message, rating)
VALUES (?, ?, ?, ?, ?);
-- Parameters: (name, email, subject, message, rating)


-- ──────────────────────────────────────────────
-- 2. SELECT ALL — Get all feedback (latest first)
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
ORDER  BY created_at DESC;


-- ──────────────────────────────────────────────
-- 3. SELECT — Filter by status
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  status = ?          -- 'pending' or 'completed'
ORDER  BY created_at DESC;


-- ──────────────────────────────────────────────
-- 4. SELECT — Filter by subject
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  subject = ?
ORDER  BY created_at DESC;


-- ──────────────────────────────────────────────
-- 5. SELECT — Filter by minimum rating
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  rating >= ?
ORDER  BY rating DESC, created_at DESC;


-- ──────────────────────────────────────────────
-- 6. SELECT — Combined filter (status + subject + min rating)
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  (? = '' OR status  = ?)
  AND  (? = '' OR subject = ?)
  AND  (? = 0  OR rating >= ?)
ORDER  BY created_at DESC;


-- ──────────────────────────────────────────────
-- 7. SELECT — Full-text search (name or subject)
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  name    LIKE CONCAT('%', ?, '%')
    OR subject LIKE CONCAT('%', ?, '%')
ORDER  BY created_at DESC;


-- ──────────────────────────────────────────────
-- 8. UPDATE — Mark feedback as completed
-- ──────────────────────────────────────────────
UPDATE feedback
SET    status = 'completed', updated_at = CURRENT_TIMESTAMP
WHERE  id = ?;


-- ──────────────────────────────────────────────
-- 9. UPDATE — Change status (generic)
-- ──────────────────────────────────────────────
UPDATE feedback
SET    status = ?, updated_at = CURRENT_TIMESTAMP
WHERE  id = ?;
-- Parameters: (new_status, id)


-- ──────────────────────────────────────────────
-- 10. DELETE — Remove a feedback entry
-- ──────────────────────────────────────────────
DELETE FROM feedback
WHERE  id = ?;


-- ──────────────────────────────────────────────
-- 11. SELECT ONE — Get single feedback by ID
-- ──────────────────────────────────────────────
SELECT id, name, email, subject, message, rating, status, created_at
FROM   feedback
WHERE  id = ?;


-- ──────────────────────────────────────────────
-- 12. DASHBOARD STATS — Aggregate counts + avg rating
-- ──────────────────────────────────────────────
SELECT
  COUNT(*)                                         AS total_feedback,
  SUM(status = 'pending')                          AS total_pending,
  SUM(status = 'completed')                        AS total_completed,
  ROUND(AVG(rating), 1)                            AS avg_rating,
  MAX(created_at)                                  AS last_submission
FROM feedback;


-- ──────────────────────────────────────────────
-- 13. REPORT — Count feedback per subject
-- ──────────────────────────────────────────────
SELECT
  subject,
  COUNT(*)            AS count,
  ROUND(AVG(rating),1) AS avg_rating
FROM   feedback
GROUP  BY subject
ORDER  BY count DESC;


-- ──────────────────────────────────────────────
-- 14. REPORT — Monthly submission trend
-- ──────────────────────────────────────────────
SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS month,
  COUNT(*)                          AS submissions
FROM   feedback
GROUP  BY month
ORDER  BY month ASC;


-- ──────────────────────────────────────────────
-- 15. REPORT — Rating distribution
-- ──────────────────────────────────────────────
SELECT
  rating,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM feedback), 1) AS percentage
FROM   feedback
GROUP  BY rating
ORDER  BY rating;


-- ──────────────────────────────────────────────
-- 16. ADMIN — Verify admin login
-- ──────────────────────────────────────────────
SELECT id, username, email, password_hash, role, is_active
FROM   admin_users
WHERE  username = ? AND is_active = TRUE;


-- ──────────────────────────────────────────────
-- 17. ADMIN — Update last login timestamp
-- ──────────────────────────────────────────────
UPDATE admin_users
SET    last_login = CURRENT_TIMESTAMP
WHERE  id = ?;


-- ──────────────────────────────────────────────
-- 18. AUDIT — Insert activity log entry
-- ──────────────────────────────────────────────
INSERT INTO activity_log (admin_id, action, feedback_id, notes)
VALUES (?, ?, ?, ?);
-- Parameters: (admin_id, action, feedback_id, notes)


-- ──────────────────────────────────────────────
-- 19. AUDIT — View recent admin activity
-- ──────────────────────────────────────────────
SELECT
  al.id,
  au.username,
  al.action,
  al.feedback_id,
  al.notes,
  al.created_at
FROM   activity_log al
JOIN   admin_users  au ON al.admin_id = au.id
ORDER  BY al.created_at DESC
LIMIT  50;


-- ──────────────────────────────────────────────
-- 20. CLEANUP — Delete completed feedback older than 1 year
-- ──────────────────────────────────────────────
DELETE FROM feedback
WHERE  status = 'completed'
  AND  updated_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
