// controllers/registerController.js
const bcrypt = require('bcryptjs');
const pool = require('../db'); // Import the database connection pool

const registerController = {
  register: async (req, res) => {
    const {
      username,
      fullName,
      email,
      password,
      confirmPassword,
      bio,
      cookingLevel
    } = req.body;

    // Validasi input dasar
    if (!username || !fullName || !email || !password || !confirmPassword || !bio || !cookingLevel) {
      return res.status(400).json({ message: 'Semua field harus diisi.' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Password dan konfirmasi password tidak cocok.' });
    }

    try {
      // Cek apakah email sudah terdaftar
      const [existingEmail] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
      if (existingEmail.length > 0) {
        return res.status(409).json({ message: 'Email sudah terdaftar. Silakan gunakan email lain.' });
      }

      // Cek apakah username sudah terdaftar
      const [existingUsername] = await pool.query('SELECT id FROM users WHERE username = ?', [username]);
      if (existingUsername.length > 0) {
        return res.status(409).json({ message: 'Username sudah terdaftar. Silakan gunakan username lain.' });
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);

      const [insertResult] = await pool.query(
        'INSERT INTO users (username, full_name, email, password_hash, bio, cooking_level) VALUES (?, ?, ?, ?, ?, ?)',
        [username, fullName, email, passwordHash, bio, cookingLevel]
      );

      res.status(201).json({ message: 'Registrasi berhasil!', userId: insertResult.insertId });

    } catch (error) {
      console.error('Error during registration:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat registrasi.' });
    }
  }
};

module.exports = registerController;