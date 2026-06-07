# FeedbackIQ — Student Feedback Management System

A clean, modern web application for collecting and managing student feedback.

---

## Project Structure

```
feedback-system/
├── index.html          ← Main frontend (all 3 pages)
├── css/
│   └── style.css       ← All styles
├── js/
│   └── app.js          ← Frontend logic
├── db/
│   ├── schema.sql      ← Database tables (run first)
│   ├── seed.sql        ← Sample data (run second)
│   └── queries.sql     ← All 20 SQL query references
└── backend/
    └── api.php         ← PHP REST API (optional backend)
```

---

## Quick Start (Frontend Only)

1. Open `index.html` directly in any browser — no server needed.
2. The app runs entirely in-memory with sample data pre-loaded.

---

## Database Setup (MySQL)

```bash
# Step 1 — Create tables
mysql -u root -p < db/schema.sql

# Step 2 — Insert sample data
mysql -u root -p feedbackiq < db/seed.sql
```

---

## Backend Setup (PHP + MySQL)

1. Place the project folder inside your web server root (e.g. `htdocs/` or `www/`).
2. Edit `backend/api.php` — update `DB_USER` and `DB_PASS`.
3. Start Apache + MySQL (XAMPP / WAMP / LAMP).
4. Access: `http://localhost/feedback-system/`

### API Endpoints

| Method | URL                                      | Description            |
|--------|------------------------------------------|------------------------|
| GET    | `api.php?action=all`                     | All feedback entries   |
| GET    | `api.php?action=stats`                   | Dashboard statistics   |
| GET    | `api.php?action=filter&status=pending`   | Filter by status       |
| GET    | `api.php?action=search&q=priya`          | Search by name/subject |
| GET    | `api.php?action=get&id=1`                | Single entry by ID     |
| POST   | `api.php` `{ action:"submit", ... }`     | Submit new feedback    |
| POST   | `api.php` `{ action:"mark_done", id:1 }` | Mark as completed      |
| POST   | `api.php` `{ action:"delete", id:1 }`    | Delete entry           |

---

## Technologies Used

- **Frontend**: HTML5, CSS3 (custom, no framework), Vanilla JS
- **Fonts**: DM Sans + DM Serif Display (Google Fonts)
- **Database**: MySQL 5.7+ / MariaDB
- **Backend** (optional): PHP 7.4+, PDO

---

## Features

- 3-page SPA: Home → Feedback Form → Admin Dashboard
- Live stats on home page
- Two-column form with validation
- Admin dashboard with card grid
- Search + chip filter + modal filter
- Mark as Done / Delete with toast notifications
- Fully responsive (mobile-friendly)
