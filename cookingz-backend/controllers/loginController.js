// cookingz-backend/controllers/loginController.js
const bcrypt = require('bcryptjs');
const pool = require('../db');
const jwt = require('jsonwebtoken');

const loginController = {
  login: async (req, res) => {
    const { email, password } = req.body;

    console.log('--- START: Login Request Received ---');
    console.log('Request Body (Login):', req.body);

    // Validasi input dasar
    if (!email || !password) {
      console.log('DEBUG: Validation Error - Email or password missing.');
      return res.status(400).json({ message: 'Email dan password harus diisi.' });
    }

    try {
      // Query sesuai dengan struktur database yang sebenarnya
      console.log(`DEBUG: Attempting to query user for email: "${email}"`);
      
      const [users] = await pool.query(
        'SELECT id, username, full_name, email, password_hash, bio, cooking_level FROM users WHERE email = ?',
        [email]
      );

      // Debug: Log hasil query dari database
      if (users.length > 0) {
        const userFound = users[0];
        console.log('DEBUG: User found in DB:', {
          userId: userFound.id,
          email: userFound.email,
          cookingLevel: userFound.cooking_level
        });
      } else {
        console.log(`DEBUG: No user found with email "${email}".`);
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      const user = users[0];

      // Verifikasi password
      console.log('DEBUG: Starting password verification with bcrypt.compare...');
      const isMatch = await bcrypt.compare(password, user.password_hash);
      console.log('DEBUG: Password match status:', isMatch);

      if (!isMatch) {
        console.log('DEBUG: Authentication Error - Invalid password for user.');
        return res.status(401).json({ message: 'Email atau password salah.' });
      }

      // Generate JWT Token
      console.log('DEBUG: Generating JWT token...');
      const jwtSecret = process.env.JWT_SECRET || 'your_jwt_secret_key';
      if (jwtSecret === 'your_jwt_secret_key') {
          console.warn('WARNING: JWT_SECRET environment variable is not set. Using default secret. Please set it in your .env file for production!');
      }
      const token = jwt.sign(
        { userId: user.id, email: user.email }, // Menggunakan user.id
        jwtSecret,
        { expiresIn: '1d' }
      );
      console.log('DEBUG: JWT token generated successfully.');

      // Kirim respons berhasil
      res.status(200).json({
        message: 'Login berhasil!',
        token: token,
        user: {
          userId: user.id,
          username: user.username,
          fullName: user.full_name,
          email: user.email,
          bio: user.bio,
          cookingLevel: user.cooking_level,
        },
      });

    } catch (error) {
      console.error('*** FATAL ERROR during login process:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat login.' });
    }
    console.log('--- END: Login Request Finished ---');
  },

  getProfile: async (req, res) => {
    console.log('--- START: Get Profile Request Received ---');

    if (!req.user || !req.user.userId) {
        console.log('DEBUG: Authorization Error - User ID not found in token.');
        return res.status(401).json({ message: 'Tidak terotorisasi. Token tidak valid atau hilang.' });
    }

    const userId = req.user.userId;
    console.log(`DEBUG: Fetching profile for userId from token: ${userId}`);

    try {
      // Query sesuai dengan struktur database yang sebenarnya
      const [users] = await pool.query(
        'SELECT id, username, full_name, email, bio, cooking_level FROM users WHERE id = ?',
        [userId]
      );

      if (users.length === 0) {
        console.log(`DEBUG: Profile Error - User (ID: ${userId}) not found in DB after token verification.`);
        return res.status(404).json({ message: 'Profil pengguna tidak ditemukan.' });
      }

      const userProfile = users[0];
      console.log('DEBUG: Profile Data retrieved from DB:', userProfile);

      res.status(200).json({
        message: 'Profil pengguna berhasil diambil.',
        user: {
          userId: userProfile.id,
          username: userProfile.username,
          fullName: userProfile.full_name,
          email: userProfile.email,
          bio: userProfile.bio,
          cookingLevel: userProfile.cooking_level
        },
      });
    } catch (error) {
      console.error('*** FATAL ERROR getting user profile:', error);
      res.status(500).json({ message: 'Terjadi kesalahan server saat mengambil profil.' });
    }
    console.log('--- END: Get Profile Request Finished ---');
  }
};

module.exports = loginController;