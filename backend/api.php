<?php
// ==============================================
//  FeedbackIQ — PHP Backend API
//  File: backend/api.php
//  Requires: PHP 7.4+, MySQL, PDO extension
//
//  Endpoints:
//    GET    api.php?action=all
//    GET    api.php?action=stats
//    GET    api.php?action=filter&status=pending&subject=...&rating=3
//    GET    api.php?action=search&q=priya
//    GET    api.php?action=get&id=1
//    POST   api.php  { action:"submit", name, email, subject, message, rating }
//    POST   api.php  { action:"mark_done", id }
//    POST   api.php  { action:"delete", id }
// ==============================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

// ── DB CONFIG ─────────────────────────────────
define('DB_HOST', 'localhost');
define('DB_NAME', 'feedbackiq');
define('DB_USER', 'root');          // change in production
define('DB_PASS', '');              // change in production
define('DB_CHARSET', 'utf8mb4');

// ── PDO CONNECTION ────────────────────────────
function getDB(): PDO {
  static $pdo = null;
  if ($pdo) return $pdo;
  $dsn = sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
  $pdo = new PDO($dsn, DB_USER, DB_PASS, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
  ]);
  return $pdo;
}

// ── HELPERS ───────────────────────────────────
function respond(array $data, int $code = 200): void {
  http_response_code($code);
  echo json_encode($data);
  exit;
}

function error(string $msg, int $code = 400): void {
  respond(['success' => false, 'error' => $msg], $code);
}

function sanitize(string $val): string {
  return htmlspecialchars(trim($val), ENT_QUOTES, 'UTF-8');
}

// ── ROUTE ─────────────────────────────────────
$method = $_SERVER['REQUEST_METHOD'];
$action = $method === 'GET'
  ? ($_GET['action'] ?? '')
  : (json_decode(file_get_contents('php://input'), true)['action'] ?? '');

try {
  match ($action) {
    'all'       => getAllFeedback(),
    'stats'     => getStats(),
    'filter'    => filterFeedback(),
    'search'    => searchFeedback(),
    'get'       => getOne(),
    'submit'    => submitFeedback(),
    'mark_done' => markDone(),
    'delete'    => deleteFeedback(),
    default     => error('Unknown action', 404),
  };
} catch (PDOException $e) {
  error('Database error: ' . $e->getMessage(), 500);
}

// ══════════════════════════════════════════════
//  GET HANDLERS
// ══════════════════════════════════════════════

function getAllFeedback(): void {
  $stmt = getDB()->query(
    'SELECT id, name, email, subject, message, rating, status, created_at
     FROM feedback ORDER BY created_at DESC'
  );
  respond(['success' => true, 'data' => $stmt->fetchAll()]);
}

function getStats(): void {
  $row = getDB()->query(
    'SELECT
       COUNT(*)                      AS total,
       SUM(status = "pending")       AS pending,
       SUM(status = "completed")     AS completed,
       ROUND(AVG(rating), 1)         AS avg_rating
     FROM feedback'
  )->fetch();
  respond(['success' => true, 'data' => $row]);
}

function filterFeedback(): void {
  $status  = $_GET['status']  ?? '';
  $subject = $_GET['subject'] ?? '';
  $rating  = intval($_GET['rating'] ?? 0);

  $stmt = getDB()->prepare(
    'SELECT id, name, email, subject, message, rating, status, created_at
     FROM   feedback
     WHERE  (? = "" OR status  = ?)
       AND  (? = "" OR subject = ?)
       AND  (? = 0  OR rating >= ?)
     ORDER  BY created_at DESC'
  );
  $stmt->execute([$status, $status, $subject, $subject, $rating, $rating]);
  respond(['success' => true, 'data' => $stmt->fetchAll()]);
}

function searchFeedback(): void {
  $q = '%' . ($_GET['q'] ?? '') . '%';
  $stmt = getDB()->prepare(
    'SELECT id, name, email, subject, message, rating, status, created_at
     FROM   feedback
     WHERE  name LIKE ? OR subject LIKE ?
     ORDER  BY created_at DESC'
  );
  $stmt->execute([$q, $q]);
  respond(['success' => true, 'data' => $stmt->fetchAll()]);
}

function getOne(): void {
  $id = intval($_GET['id'] ?? 0);
  if (!$id) error('Invalid ID');
  $stmt = getDB()->prepare(
    'SELECT * FROM feedback WHERE id = ?'
  );
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row) error('Not found', 404);
  respond(['success' => true, 'data' => $row]);
}

// ══════════════════════════════════════════════
//  POST HANDLERS
// ══════════════════════════════════════════════

function submitFeedback(): void {
  $body = json_decode(file_get_contents('php://input'), true);

  $name    = sanitize($body['name']    ?? '');
  $email   = filter_var($body['email'] ?? '', FILTER_SANITIZE_EMAIL);
  $subject = sanitize($body['subject'] ?? '');
  $message = sanitize($body['message'] ?? '');
  $rating  = intval($body['rating']    ?? 0);

  if (!$name || !$email || !$subject || !$message)
    error('All fields are required.');
  if (!filter_var($email, FILTER_VALIDATE_EMAIL))
    error('Invalid email address.');
  if ($rating < 1 || $rating > 5)
    error('Rating must be between 1 and 5.');

  $stmt = getDB()->prepare(
    'INSERT INTO feedback (name, email, subject, message, rating)
     VALUES (?, ?, ?, ?, ?)'
  );
  $stmt->execute([$name, $email, $subject, $message, $rating]);

  respond([
    'success' => true,
    'message' => 'Feedback submitted successfully.',
    'id'      => (int) getDB()->lastInsertId()
  ], 201);
}

function markDone(): void {
  $body = json_decode(file_get_contents('php://input'), true);
  $id   = intval($body['id'] ?? 0);
  if (!$id) error('Invalid ID');

  $stmt = getDB()->prepare(
    'UPDATE feedback SET status = "completed", updated_at = NOW() WHERE id = ?'
  );
  $stmt->execute([$id]);

  if (!$stmt->rowCount()) error('Feedback not found', 404);
  respond(['success' => true, 'message' => 'Marked as completed.']);
}

function deleteFeedback(): void {
  $body = json_decode(file_get_contents('php://input'), true);
  $id   = intval($body['id'] ?? 0);
  if (!$id) error('Invalid ID');

  $stmt = getDB()->prepare('DELETE FROM feedback WHERE id = ?');
  $stmt->execute([$id]);

  if (!$stmt->rowCount()) error('Feedback not found', 404);
  respond(['success' => true, 'message' => 'Feedback deleted.']);
}
