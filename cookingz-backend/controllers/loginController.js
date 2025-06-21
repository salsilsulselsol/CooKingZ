// controllers/loginController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db'); // Import the database connection pool

// JWT Secret - dalam production, ini harus disimpan di environment variable
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-here';

const loginController = {
  login: async (req, res) => {
    const { email, password } = req.body;

    // Validasi input dasar
    if (!email || !password) {
      return res.status(400).json({ message: 'Email dan password harus diisi.' });
    }

    try {
      // Cari user berdasarkan email
      const [users] = await pool.query(
        'SELECT id, username, full_name, email, password_hash, bio, cooking_level FROM users WHERE email = ?',
        [email]
      );

      if (users.length === 0) {
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      const user = users[0];

      // Verifikasi password
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);
      
      if (!isPasswordValid) {
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      // Generate JWT token
      const token = jwt.sign(
        { 
          userId: user.id, 
          email: user.email,
          username: user.username 
        },
        JWT_SECRET,
        { expiresIn: '24h' } // Token berlaku selama 24 jam
      );

      // Response sukses (tidak mengembalikan password_hash)
      const userData = {
        id: user.id,
        username: user.username,
        fullName: user.full_name,
        email: user.email,
        bio: user.bio,
        cookingLevel: user.cooking_level
      };

      res.status(200).json({
        message: 'Login berhasil!',
        token: token,
        user: userData
      });

    } catch (error) {
      console.error('Error during login:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat login.' });
    }
  },

  // Method untuk verifikasi token (middleware untuk route yang memerlukan authentication)
  verifyToken: (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      req.user = decoded;
      next();
    } catch (error) {
      res.status(400).json({ message: 'Invalid token.' });
    }
  },

  // Method untuk mendapatkan profile user berdasarkan token
  getProfile: async (req, res) => {
    try {
      const userId = req.user.userId;

      const [users] = await pool.query(
        'SELECT id, username, full_name, email, bio, cooking_level FROM users WHERE id = ?',
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({ message: 'User tidak ditemukan.' });
      }

      const user = users[0];
      const userData = {
        id: user.id,
        username: user.username,
        fullName: user.full_name,
        email: user.email,
        bio: user.bio,
        cookingLevel: user.cooking_level
      };

      res.status(200).json({
        message: 'Profile berhasil diambil.',
        user: userData
      });

    } catch (error) {
      console.error('Error getting profile:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat mengambil profile.' });
    }
  }
};

module.exports = loginController;