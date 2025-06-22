// cookingz-backend/controllers/forgotPasswordController.js
const db = require('../db');
const bcrypt = require('bcryptjs');
const crypto = require('crypto'); // Digunakan untuk membuat OTP
const nodemailer = require('nodemailer'); // Import nodemailer
require('dotenv').config(); // Untuk mengakses variabel lingkungan

// Fungsi pengiriman email yang sebenarnya menggunakan Nodemailer
async function sendEmail(to, subject, text) {
    try {
        // Buat transporter Nodemailer menggunakan SMTP Gmail
        // Pastikan EMAIL_USER dan EMAIL_PASS diatur di file .env Anda
        let transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER, // Alamat Gmail Anda
                pass: process.env.EMAIL_PASS  // Sandi aplikasi Gmail Anda yang dihasilkan Google
            },
            // Opsi keamanan tambahan jika diperlukan (misalnya, untuk lingkungan yang lebih ketat)
            // tls: {
            //     rejectUnauthorized: false // Izinkan sertifikat self-signed atau yang tidak valid (untuk debug, jangan di produksi)
            // } 
        });

        // Kirim email
        let info = await transporter.sendMail({
            from: process.env.EMAIL_USER, // Pengirim (sebaiknya sama dengan user di auth)
            to: to,                     // Penerima
            subject: subject,           // Subjek email
            text: text,                 // Isi teks email
            // Anda juga bisa mengirim konten HTML:
            // html: '<p>Kode OTP Anda adalah: <b>' + text + '</b></p>'
        });

        console.log("Pesan email terkirim: %s", info.messageId);
        return true; // Mengembalikan true jika pengiriman berhasil
    } catch (error) {
        console.error("Error saat mengirim email:", error);
        // Penting: Jangan mengembalikan 'true' di sini jika ada kesalahan,
        // agar frontend mendapatkan notifikasi yang benar.
        return false; // Mengembalikan false jika pengiriman gagal
    }
}

// Function to send OTP to user's email
// Fungsi untuk mengirim OTP ke email pengguna
exports.sendOtp = async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ status: 'error', message: 'Email wajib diisi.' });
    }

    try {
        // Cek apakah email terdaftar di database
        const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Email tidak terdaftar.' });
        }

        const otp = crypto.randomInt(100000, 999999).toString(); // Menghasilkan OTP 6 digit
        // --- PERUBAHAN DI SINI: OTP berlaku untuk 5 menit ---
        const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // OTP berlaku untuk 5 menit (5 * 60 * 1000 milidetik)
        // --- END PERUBAHAN ---

        // Simpan OTP dan waktu kadaluarsa langsung di tabel users
        // Ini akan menimpa OTP sebelumnya jika ada, memungkinkan pengiriman ulang.
        await db.query(
            'UPDATE users SET otp = ?, otp_expires_at = ? WHERE email = ?',
            [otp, otpExpiry, email]
        );

        // --- PERUBAHAN DI SINI: Pesan email menunjukkan 5 menit ---
        const emailSent = await sendEmail(email, 'Kode Verifikasi Reset Kata Sandi Anda', `Kode OTP Anda adalah: ${otp}. Kode ini berlaku selama 5 menit.`);
        // --- END PERUBAHAN ---
        
        if (emailSent) {
            res.status(200).json({ status: 'success', message: 'Kode OTP telah dikirim ke email Anda.' });
        } else {
            // Jika sendEmail mengembalikan false, berikan pesan kesalahan yang sesuai ke frontend
            res.status(500).json({ status: 'error', message: 'Gagal mengirim OTP ke email. Silakan periksa pengaturan email atau coba lagi.' });
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
        const [users] = await db.query('SELECT otp, otp_expires_at FROM users WHERE email = ?', [email]);

        if (users.length === 0 || !users[0].otp || !users[0].otp_expires_at) {
            return res.status(400).json({ status: 'error', message: 'Email atau OTP tidak valid.' });
        }

        const storedOtp = users[0].otp;
        const expiresAt = new Date(users[0].otp_expires_at);

        if (storedOtp === otp && expiresAt > new Date()) {
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