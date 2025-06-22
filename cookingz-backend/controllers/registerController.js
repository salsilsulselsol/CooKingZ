// File: cookingz-backend/controllers/registerController.js
const db = require('../db');
const bcrypt = require('bcryptjs'); // Pastikan bcryptjs diimpor
const jwt = require('jsonwebtoken'); // Pastikan jsonwebtoken diimpor
require('dotenv').config(); // Untuk JWT_SECRET

// Fungsi Register User
exports.register = async (req, res) => {
    const { username, full_name, email, password } = req.body;
    
// Tampilkan nilai yang diterima
console.log('Debug Input:');
console.log('username:', username);
console.log('full_name:', full_name);
console.log('email:', email);
console.log('password:', password); // ❗ Hati-hati jangan log ini di produksi!
    // Validasi input
    if (!username || !full_name || !email || !password) {

        console.log('Debug: username, full_name, email, atau password tidak diisi.');

        return res.status(400).json({ status: 'error', message: 'Semua field wajib diisi.' });
    }

    try {
        // Cek apakah username atau email sudah terdaftar
        const [existingUsers] = await db.query('SELECT id FROM users WHERE username = ? OR email = ?', [username, email]);
        if (existingUsers.length > 0) {
            return res.status(409).json({ status: 'error', message: 'Username atau email sudah terdaftar.' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Simpan user baru ke database
        const [result] = await db.query(
            'INSERT INTO users (username, full_name, email, password_hash) VALUES (?, ?, ?, ?)',
            [username, full_name, email, hashedPassword]
        );

        res.status(201).json({ status: 'success', message: 'Registrasi berhasil!' });

    } catch (error) {
        console.error('Error saat registrasi:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat registrasi.' });
    }
};

// Fungsi Login User
exports.login = async (req, res) => {
    const { email, password } = req.body;
    console.log('--- START: Login Request Received ---');
    console.log('Request Body (Login):', { email, password });

    if (!email || !password) {
        console.log('Login gagal: Email dan password wajib diisi.');
        return res.status(400).json({ status: 'error', message: 'Email dan password wajib diisi.' });
    }

    try {
        // SELECT semua kolom yang mungkin diperlukan untuk objek 'user' di respons
        // Termasuk 'onboarding_completed' jika Anda akan menambahkannya ke DB nanti
        const [users] = await db.query('SELECT id, username, full_name, email, password_hash, cooking_level, bio, profile_picture FROM users WHERE email = ?', [email]); // <<< SELECT KOLOM LENGKAP UNTUK USER OBJECT

        if (users.length === 0) {
            console.log('Login gagal: Pengguna tidak ditemukan.');
            return res.status(401).json({ status: 'error', message: 'Email atau password salah.' });
        }

        const user = users[0];
        console.log('DEBUG: User found in DB:', { userId: user.id, username: user.username, email: user.email, cookingLevel: user.cooking_level, profile_picture: user.profile_picture });

        const passwordMatch = await bcrypt.compare(password, user.password_hash);
        console.log('DEBUG: Password match status:', passwordMatch);

        if (!passwordMatch) {
            console.log('Login gagal: Password salah.');
            return res.status(401).json({ status: 'error', message: 'Email atau password salah.' });
        }

        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            console.warn('WARNING: JWT_SECRET environment variable is not set. Using default secret. Please set it in your .env file for production!');
        }
        
        const token = jwt.sign(
            { userId: user.id, username: user.username }, 
            jwtSecret || 'supersecretjwtkey', 
            { expiresIn: '1h' } 
        );
        console.log('DEBUG: JWT token generated successfully.');

        console.log('--- END: Login Request Finished ---');
        res.status(200).json({
            status: 'success',
            message: 'Login berhasil!',
            token,
            userId: user.id, 
            username: user.username, 
            user: { // Objek user untuk disimpan di frontend, pastikan semua properti yang dikirim ada
                id: user.id,
                username: user.username,
                full_name: user.full_name,
                email: user.email,
                cooking_level: user.cooking_level,
                profile_picture: user.profile_picture, // Kolom ini ada di DB
                // Pastikan `onboarding_completed` tidak dikirim jika tidak ada di DB, atau tambahkan ke DB
                // onboardingCompleted: user.onboarding_completed ?? false // Hapus ini jika kolomnya tidak ada di DB Anda
            }
        });

    } catch (error) {
        console.error('Error saat login:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat login.', error: error.message });
    }
};