/* =========================================
   FeedbackIQ — Application Logic
   js/app.js
   ========================================= */

/* ─── DATA STORE ─── */
let feedbacks = [
  {
    id: 1,
    name: 'Priya Desai',
    email: 'priya@college.edu',
    subject: 'Course Content Quality',
    message: 'The course material for Data Structures was incredibly well structured. Each module built logically on the previous one, making complex topics approachable and easy to follow.',
    rating: 5,
    status: 'completed'
  },
  {
    id: 2,
    name: 'Rahul Mehta',
    email: 'rahul.m@college.edu',
    subject: 'Faculty Teaching Methods',
    message: 'Professor Sharma needs to include more practical examples during lectures. The theoretical content is fine but lacks real-world application context for students.',
    rating: 2,
    status: 'pending'
  },
  {
    id: 3,
    name: 'Sneha Iyer',
    email: 'sneha.i@college.edu',
    subject: 'Campus Infrastructure',
    message: 'The Wi-Fi in the library blocks remains consistently weak during peak hours between 10am to 2pm, which makes online research very difficult.',
    rating: 3,
    status: 'pending'
  },
  {
    id: 4,
    name: 'Aryan Kapoor',
    email: 'aryan.k@college.edu',
    subject: 'Online Learning Platform',
    message: 'The new LMS portal is fast and easy to navigate. Assignment submission and grade tracking features are excellent additions to the system.',
    rating: 4,
    status: 'completed'
  }
];

let nextId = 5;
let selectedRating = 0;
let currentFilter = { status: 'all', subject: '', rating: '' };
let chipStatus = 'all';

/* ─── NAVIGATION ─── */
function showPage(id) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  if (id === 'admin') renderAdmin();
  if (id === 'home') updateHomeStats();
  window.scrollTo(0, 0);
}

/* ─── HOME STATS ─── */
function updateHomeStats() {
  document.getElementById('stat-total').textContent = feedbacks.length;
  document.getElementById('stat-pending').textContent = feedbacks.filter(f => f.status === 'pending').length;
  const avg = feedbacks.length
    ? (feedbacks.reduce((s, f) => s + f.rating, 0) / feedbacks.length).toFixed(1)
    : '—';
  document.getElementById('stat-rating').textContent = avg;
}

/* ─── RATING SELECTOR ─── */
function setRating(val) {
  selectedRating = val;
  document.querySelectorAll('.rating-btn').forEach(b => {
    b.classList.toggle('active', parseInt(b.dataset.val) === val);
  });
}

/* ─── FORM SUBMISSION ─── */
function submitFeedback() {
  const name    = document.getElementById('f-name').value.trim();
  const email   = document.getElementById('f-email').value.trim();
  const subject = document.getElementById('f-subject').value;
  const message = document.getElementById('f-message').value.trim();

  if (!name || !email || !subject || !message || !selectedRating) {
    showToast('Please fill in all required fields and select a rating.', 'error');
    return;
  }

  feedbacks.push({
    id: nextId++,
    name, email, subject, message,
    rating: selectedRating,
    status: 'pending'
  });

  document.getElementById('form-wrapper').style.display = 'none';
  document.getElementById('success-state').style.display = 'block';
}

function submitAnother() {
  document.getElementById('f-name').value    = '';
  document.getElementById('f-email').value   = '';
  document.getElementById('f-subject').value = '';
  document.getElementById('f-message').value = '';
  selectedRating = 0;
  document.querySelectorAll('.rating-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('form-wrapper').style.display  = 'block';
  document.getElementById('success-state').style.display = 'none';
}

/* ─── ADMIN RENDER ─── */
function renderAdmin() {
  updateDashboardStats();
  renderCards();
}

function updateDashboardStats() {
  const total   = feedbacks.length;
  const pending = feedbacks.filter(f => f.status === 'pending').length;
  const done    = feedbacks.filter(f => f.status === 'completed').length;
  const avg     = total
    ? (feedbacks.reduce((s, f) => s + f.rating, 0) / total).toFixed(1)
    : '—';
  document.getElementById('d-total').textContent   = total;
  document.getElementById('d-pending').textContent = pending;
  document.getElementById('d-done').textContent    = done;
  document.getElementById('d-rating').textContent  = avg;
}

/* ─── CHIP FILTER ─── */
function setChip(status) {
  chipStatus = status;
  ['all', 'pending', 'completed'].forEach(s => {
    document.getElementById('chip-' + s).classList.toggle('active', s === status);
  });
  renderCards();
}

/* ─── RENDER CARDS ─── */
function renderCards() {
  const search = (document.getElementById('admin-search')?.value || '').toLowerCase();

  const list = feedbacks.filter(f => {
    const matchStatus  = chipStatus === 'all' || f.status === chipStatus;
    const matchSearch  = !search || f.name.toLowerCase().includes(search) || f.subject.toLowerCase().includes(search);
    const matchSubject = !currentFilter.subject || f.subject === currentFilter.subject;
    const matchRating  = !currentFilter.rating || (
      currentFilter.rating === '5' ? f.rating === 5 : f.rating >= parseInt(currentFilter.rating)
    );
    return matchStatus && matchSearch && matchSubject && matchRating;
  });

  const grid = document.getElementById('cards-grid');

  if (!list.length) {
    grid.innerHTML = `
      <div class="card empty-state">
        <div class="empty-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
          </svg>
        </div>
        <h4>No feedback found</h4>
        <p>Try adjusting your filters or search query.</p>
      </div>`;
    return;
  }

  grid.innerHTML = list.map(f => cardHTML(f)).join('');
}

/* ─── STAR HTML ─── */
function starsHTML(r) {
  return [1, 2, 3, 4, 5].map(i =>
    `<svg class="star" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <polygon class="${i <= r ? 'star-filled' : 'star-empty'}"
        points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
    </svg>`
  ).join('');
}

/* ─── CARD HTML ─── */
function cardHTML(f) {
  const initials  = f.name.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase();
  const isPending = f.status === 'pending';
  return `
  <div class="card fb-card" id="card-${f.id}">
    <div class="fb-card-header">
      <div class="fb-avatar">${initials}</div>
      <div class="fb-name-wrap">
        <div class="fb-name">${f.name}</div>
        <div class="fb-email">${f.email}</div>
      </div>
      <span class="status-badge ${isPending ? 'status-pending' : 'status-completed'}">
        ${isPending ? 'Pending' : 'Completed'}
      </span>
    </div>
    <div class="fb-card-body">
      <div class="fb-subject">${f.subject}</div>
      <div class="fb-message">${f.message}</div>
    </div>
    <div class="fb-card-footer">
      <div class="rating-display">
        <div class="stars">${starsHTML(f.rating)}</div>
        <span class="rating-val">${f.rating}/5</span>
      </div>
      <div class="fb-actions">
        ${isPending
          ? `<button class="btn btn-sm btn-primary" onclick="markDone(${f.id})">Mark Done</button>`
          : `<button class="btn btn-sm btn-ghost" style="color:var(--status-done-text)">Resolved</button>`
        }
        <button class="btn btn-sm btn-danger" onclick="deleteFeedback(${f.id})">Delete</button>
      </div>
    </div>
  </div>`;
}

/* ─── ACTIONS ─── */
function markDone(id) {
  const f = feedbacks.find(x => x.id === id);
  if (f) {
    f.status = 'completed';
    renderAdmin();
    showToast('Marked as completed.', 'success');
  }
}

function deleteFeedback(id) {
  feedbacks = feedbacks.filter(x => x.id !== id);
  renderAdmin();
  showToast('Feedback deleted.', 'error');
}

/* ─── MODAL ─── */
function openModal()  { document.getElementById('filter-modal').classList.add('open'); }
function closeModal() { document.getElementById('filter-modal').classList.remove('open'); }
function closeModalOutside(e) {
  if (e.target === document.getElementById('filter-modal')) closeModal();
}
function applyFilter() {
  currentFilter.subject = document.getElementById('modal-subject').value;
  currentFilter.rating  = document.getElementById('modal-rating').value;
  closeModal();
  renderCards();
  showToast('Filters applied.', 'success');
}
function resetFilter() {
  currentFilter = { status: 'all', subject: '', rating: '' };
  document.getElementById('modal-subject').value = '';
  document.getElementById('modal-rating').value  = '';
  closeModal();
  renderCards();
}

/* ─── TOAST ─── */
function showToast(msg, type = 'success') {
  const wrap = document.getElementById('toast-wrap');
  const t    = document.createElement('div');
  t.className = `toast ${type}`;
  const icon = type === 'success'
    ? `<svg class="toast-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>`
    : `<svg class="toast-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>`;
  t.innerHTML = icon + msg;
  wrap.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}

/* ─── INIT ─── */
updateHomeStats();
