// server.js
const express = require('express');
const cors = require('cors');
const pool = require('./db'); // Pastikan db.js sudah berjalan dan terkoneksi
const registerRoutes = require('./routes/registerRoutes'); // Import rute registrasi (nama baru)

const app = express();

app.use(cors());
app.use(express.json());

// Gunakan rute registrasi
// Semua rute di registerRoutes akan diawali dengan '/register'
// Misalnya, rute '/' di registerRoutes.js akan menjadi '/register'
app.use('/register', registerRoutes);

// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});