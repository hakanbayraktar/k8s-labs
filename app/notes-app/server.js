const express = require('express');
const mysql = require('mysql2/promise');
const os = require('os');

const port = Number(process.env.PORT || 8080);
const title = process.env.APP_TITLE || 'Not Defteri';
const pod = process.env.POD_NAME || os.hostname();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'mysql',
  port: Number(process.env.DB_PORT || 3306),
  database: process.env.DB_NAME || 'notesdb',
  user: process.env.DB_USER || 'notes',
  password: process.env.DB_PASSWORD || '',
  connectionLimit: 5,
  connectTimeout: 3000,
});

let schemaReady = false;
async function ensureSchema() {
  if (schemaReady) return;
  await pool.query(`CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    text VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)`);
  schemaReady = true;
}

const app = express();
app.use(express.json());

// Liveness: surec ayakta mi? Veritabanina bakmaz.
app.get('/healthz', (_req, res) => res.json({ status: 'UP', pod }));

// Readiness: trafik alabilir miyim? Veritabanina ulasamiyorsa 503 doner.
app.get('/ready', async (_req, res) => {
  try {
    await ensureSchema();
    await pool.query('SELECT 1');
    res.json({ status: 'READY', db: 'connected', pod });
  } catch (err) {
    res.status(503).json({ status: 'NOT_READY', db: 'unreachable', error: err.code || err.message, pod });
  }
});

app.get('/api/notes', async (_req, res) => {
  try {
    await ensureSchema();
    const [rows] = await pool.query('SELECT id, text FROM notes ORDER BY id');
    res.json(rows);
  } catch (err) {
    res.status(503).json({ error: 'veritabani erisilemiyor', detail: err.code || err.message });
  }
});

app.post('/api/notes', async (req, res) => {
  const text = String((req.body && req.body.text) || '').trim();
  if (!text) return res.status(400).json({ error: 'text alani gerekli' });
  try {
    await ensureSchema();
    const [result] = await pool.query('INSERT INTO notes (text) VALUES (?)', [text.slice(0, 200)]);
    res.status(201).json({ id: result.insertId, text, pod });
  } catch (err) {
    res.status(503).json({ error: 'veritabani erisilemiyor', detail: err.code || err.message });
  }
});

app.get('/', async (_req, res) => {
  let items = '<li>veritabani erisilemiyor</li>';
  try {
    await ensureSchema();
    const [rows] = await pool.query('SELECT id, text FROM notes ORDER BY id');
    items = rows.map((r) => `<li>${String(r.text).replace(/[<>&]/g, '')}</li>`).join('') || '<li>henuz not yok</li>';
  } catch (_err) { /* sayfa yine de acilir */ }
  res.type('html').send(`<!doctype html><html><head><meta charset="utf-8"><title>${title}</title></head>
<body><h1>${title}</h1><ul>${items}</ul><p>Cevap veren Pod: ${pod}</p></body></html>`);
});

const server = app.listen(port, '0.0.0.0', () => console.log(`notes-app ${pod} :${port}`));
process.on('SIGTERM', () => {
  console.log('SIGTERM alindi, kapaniyor');
  server.close(() => pool.end().finally(() => process.exit(0)));
  setTimeout(() => process.exit(0), 5000).unref();
});
