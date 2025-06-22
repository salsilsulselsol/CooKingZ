// cookingz-backend/controllers/forgotPasswordController.js
const db = require('../db');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const nodemailer = require('nodemailer'); // Import nodemailer
require('dotenv').config(); // Untuk mengakses variabel lingkungan

// Fungsi pengiriman email yang sebenarnya
async function sendEmail(to, subject, text) {
    try {
        // Buat transporter Nodemailer menggunakan SMTP Gmail
        let transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER, // Alamat Gmail Anda
                pass: process.env.EMAIL_PASS  // Sandi aplikasi Gmail Anda
            }
        });

        // Kirim email
        let info = await transporter.sendMail({
            from: process.env.EMAIL_USER, // Pengirim (harus sama dengan user di auth)
            to: to,                     // Penerima
            subject: subject,           // Subjek email
            text: text,                 // Isi teks email
            // html: '<b>Hello world?</b>' // Anda juga bisa mengirim HTML
        });

        console.log("Pesan terkirim: %s", info.messageId);
        // Message sent: <b658f8ca-6299-44b4-a0bb-2a3d0eccloop@example.com>
        return true;
    } catch (error) {
        console.error("Error saat mengirim email:", error);
        return false;
    }
}

// ... (sisa kode sendOtp, verifyOtp, resetPassword tetap sama)
// ... (the rest of the sendOtp, verifyOtp, resetPassword code remains the same)

// Function to send OTP to user's email
// Fungsi untuk mengirim OTP ke email pengguna
exports.sendOtp = async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ status: 'error', message: 'Email wajib diisi.' });
    }

    try {
        // Cek apakah email terdaftar
        const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Email tidak terdaftar.' });
        }

        const otp = crypto.randomInt(100000, 999999).toString(); // Menghasilkan OTP 6 digit
        const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // OTP berlaku untuk 10 menit

        // Simpan OTP dan waktu kadaluarsa langsung di tabel users
        await db.query(
            'UPDATE users SET otp = ?, otp_expires_at = ? WHERE email = ?',
            [otp, otpExpiry, email]
        );

        // Panggil fungsi sendEmail yang sebenarnya
        const emailSent = await sendEmail(email, 'Kode Verifikasi Reset Kata Sandi Anda', `Kode OTP Anda adalah: ${otp}. Kode ini berlaku selama 10 menit.`);
        
        if (emailSent) {
            res.status(200).json({ status: 'success', message: 'Kode OTP telah dikirim ke email Anda.' });
        } else {
            res.status(500).json({ status: 'error', message: 'Gagal mengirim OTP ke email. Silakan coba lagi.' });
        }


    } catch (error) {
        console.error('Error saat mengirim OTP:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mengirim OTP.' });
    }
};


// Function to verify OTP
// Fungsi untuk memverifikasi OTP
exports.verifyOtp = async (req, res) => {
    const { email, otp } = req.body;

    if (!email || !otp) {
        return res.status(400).json({ status: 'error', message: 'Email dan OTP wajib diisi.' });
    }

    try {
        // Ambil OTP dan waktu kadaluarsa dari tabel users
        const [users] = await db.query('SELECT otp, otp_expires_at FROM users WHERE email = ?', [email]);

        if (users.length === 0 || !users[0].otp || !users[0].otp_expires_at) {
            return res.status(400).json({ status: 'error', message: 'Email atau OTP tidak valid.' });
        }

        const storedOtp = users[0].otp;
        const expiresAt = new Date(users[0].otp_expires_at);

        if (storedOtp === otp && expiresAt > new Date()) {
            // OTP valid, hapus OTP dari tabel users untuk mencegah penggunaan ulang
            await db.query('UPDATE users SET otp = NULL, otp_expires_at = NULL WHERE email = ?', [email]);
            res.status(200).json({ status: 'success', message: 'OTP berhasil diverifikasi.' });
        } else {
            res.status(400).json({ status: 'error', message: 'OTP tidak valid atau sudah kadaluarsa.' });
        }

    } catch (error) {
        console.error('Error saat verifikasi OTP:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat verifikasi OTP.' });
    }
};

// Function to reset password
// Fungsi untuk mereset kata sandi
exports.resetPassword = async (req, res) => {
    const { email, newPassword, confirmPassword } = req.body;

    if (!email || !newPassword || !confirmPassword) {
        return res.status(400).json({ status: 'error', message: 'Semua field wajib diisi.' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ status: 'error', message: 'Kata sandi baru dan konfirmasi kata sandi tidak cocok.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        const [result] = await db.query('UPDATE users SET password_hash = ? WHERE email = ?', [hashedPassword, email]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan.' });
        }

        res.status(200).json({ status: 'success', message: 'Kata sandi berhasil direset.' });

    } catch (error) {
        console.error('Error saat mereset kata sandi:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mereset kata sandi.' });
    }
};