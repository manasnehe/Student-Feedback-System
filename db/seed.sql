-- ==============================================
--  FeedbackIQ — Seed Data
--  File: db/seed.sql
--  Run AFTER schema.sql:
--       mysql -u root -p feedbackiq < db/seed.sql
-- ==============================================

USE feedbackiq;

-- Default admin user (password: Admin@123)
-- Hash generated with bcrypt, cost factor 12
INSERT INTO admin_users (username, email, password_hash, role) VALUES
('admin', 'admin@feedbackiq.edu',
 '$2b$12$KIXsample_bcrypt_hash_placeholder_replace_in_production',
 'superadmin');

-- Sample feedback entries
INSERT INTO feedback (name, email, subject, message, rating, status) VALUES
('Priya Desai',  'priya@college.edu',
 'Course Content Quality',
 'The course material for Data Structures was incredibly well structured. Each module built logically on the previous one, making complex topics approachable and easy to follow.',
 5, 'completed'),

('Rahul Mehta',  'rahul.m@college.edu',
 'Faculty Teaching Methods',
 'Professor Sharma needs to include more practical examples during lectures. The theoretical content is fine but lacks real-world application context for students.',
 2, 'pending'),

('Sneha Iyer',   'sneha.i@college.edu',
 'Campus Infrastructure',
 'The Wi-Fi in the library blocks remains consistently weak during peak hours between 10am to 2pm, which makes online research very difficult.',
 3, 'pending'),

('Aryan Kapoor', 'aryan.k@college.edu',
 'Online Learning Platform',
 'The new LMS portal is fast and easy to navigate. Assignment submission and grade tracking features are excellent additions to the system.',
 4, 'completed'),

('Meera Nair',   'meera.n@college.edu',
 'Library & Resources',
 'More recent editions of reference books should be added to the library. The current collection is outdated for post-graduate level research.',
 3, 'pending'),

('Karan Singh',  'karan.s@college.edu',
 'Administrative Services',
 'The fee receipt generation process online has improved a lot this semester. It used to take 3–4 days, now it is instant.',
 5, 'completed');
