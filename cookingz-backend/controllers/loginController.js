const bcrypt = require('bcryptjs');
const pool = require('../db');
const jwt = require('jsonwebtoken');

const loginController = {
  login: async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email dan password harus diisi.' });
    }

    try {
      const [users] = await pool.query(
        `SELECT user_id, username, full_name, email, password_hash, bio, cooking_level, onboarding_completed 
         FROM users WHERE email = ?`,
        [email]
      );

      if (users.length === 0) {
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      const user = users[0];
      const isMatch = await bcrypt.compare(password, user.password_hash);

      if (!isMatch) {
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      const token = jwt.sign(
        { userId: user.user_id, email: user.email },
        process.env.JWT_SECRET || 'secret_key',
        { expiresIn: '1h' }
      );

      res.status(200).json({
        message: 'Login berhasil!',
        token,
        user: {
          userId: user.user_id,
          username: user.username || '',
          fullName: user.full_name || '',
          email: user.email || '',
          bio: user.bio || '',
          cookingLevel: user.cooking_level || '',
          onboardingCompleted: user.onboarding_completed === 1
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat login.' });
    }
  },

  getProfile: async (req, res) => {
    const userId = req.user.userId;

    try {
      const [users] = await pool.query(
        `SELECT user_id, username, full_name, email, bio, cooking_level, onboarding_completed 
         FROM users WHERE user_id = ?`,
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({ message: 'Profil tidak ditemukan.' });
      }

      const user = users[0];

      res.status(200).json({
        message: 'Profil berhasil diambil.',
        user: {
          userId: user.user_id,
          username: user.username || '',
          fullName: user.full_name || '',
          email: user.email || '',
          bio: user.bio || '',
          cookingLevel: user.cooking_level || '',
          onboardingCompleted: user.onboarding_completed === 1
        }
      });
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat mengambil profil.' });
    }
  }
};

module.exports = loginController;
