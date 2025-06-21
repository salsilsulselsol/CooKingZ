// cookingz-backend/controllers/forgotPasswordController.js
const bcrypt = require('bcryptjs');
const pool = require('../db');
const nodemailer = require('nodemailer'); // Pastikan ini TIDAK DIKOMENTARI
const crypto = require('crypto'); // Diperlukan untuk generateOTP

// Fungsi untuk generate OTP (6 digit angka acak)
const generateOTP = () => {
    return crypto.randomInt(100000, 999999).toString();
};

// Simpan OTP sementara (PERINGATAN: TIDAK PERSISTEN. UNTUK PRODUKSI, GUNAKAN DATABASE/REDIS)
const otpStorage = new Map();

// Konfigurasi Nodemailer untuk Gmail
const transporter = nodemailer.createTransport({ // Pastikan BLOK INI TIDAK DIKOMENTARI
    service: 'gmail', // Menggunakan layanan Gmail
    auth: {
        user: process.env.GMAIL_USER,         // Alamat Gmail pengirim dari .env
        pass: process.env.GMAIL_APP_PASSWORD, // App password dari .env
    },
});

// Verifikasi konfigurasi email saat startup (opsional, tapi bagus untuk debug)
transporter.verify((error, success) => {
    if (error) {
        console.error('Error konfigurasi email Nodemailer:', error);
        // Dalam produksi, mungkin ingin exit process atau log error dengan serius
    } else {
        console.log('Server email (Nodemailer) siap untuk mengirim pesan.');
    }
});

// Controller untuk kirim OTP ke email
const sendOTP = async (req, res) => {
    try {
        const { email } = req.body; // Email yang dimasukkan pengguna di Flutter

        // Validasi input email
        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email harus diisi.'
            });
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: 'Format email tidak valid.'
            });
        }

        // Cek apakah email ada di database
        const checkEmailQuery = 'SELECT id FROM users WHERE email = ?';

        try {
            const [results] = await pool.query(checkEmailQuery, [email]);

            if (results.length === 0) {
                // Untuk keamanan, selalu berikan respons yang sama meskipun email tidak ditemukan.
                // Ini mencegah enumerasi email.
                return res.status(200).json({
                    success: true,
                    message: 'Jika email Anda terdaftar, kode OTP telah dikirim ke email Anda.'
                });
            }

            const otp = generateOTP();

            // Simpan OTP dengan email yang dimasukkan pengguna (kunci map adalah email pengguna)
            otpStorage.set(email, {
                otp: otp,
                expires: Date.now() + 5 * 60 * 1000 // OTP berlaku 5 menit
            });

            // Template email HTML yang lebih menarik
            const mailOptions = {
                from: {
                    name: 'Cookingz App',
                    address: process.env.GMAIL_USER // Email pengirim yang dikonfigurasi di .env
                },
                to: email, // <--- OTP DIKIRIM KE EMAIL PENGGUNA YANG MEMINTA
                subject: '🔒 Kode Verifikasi Reset Password - Cookingz',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; border-radius: 10px;">
                        <div style="background-color: #005D56; color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;">
                            <h1 style="margin: 0; font-size: 24px;">🍳 Cookingz</h1>
                            <p style="margin: 10px 0 0 0; font-size: 16px;">Reset Password</p>
                        </div>

                        <div style="background-color: white; padding: 30px; border-radius: 0 0 10px 10px;">
                            <h2 style="color: #005D56; margin-top: 0;">Kode Verifikasi OTP Anda</h2>
                            <p style="font-size: 16px; line-height: 1.5; color: #333;">
                                Halo! Kami menerima permintaan untuk reset password akun Cookingz Anda.
                            </p>

                            <div style="background-color: #f0f8f8; border: 2px dashed #005D56; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px;">
                                <p style="margin: 0; font-size: 14px; color: #666;">Kode OTP Anda:</p>
                                <h1 style="font-size: 32px; color: #005D56; margin: 10px 0; letter-spacing: 5px; font-weight: bold;">${otp}</h1>
                            </div>

                            <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
                                <p style="margin: 0; font-size: 14px; color: #856404;">
                                    ⚠️ <strong>Penting:</strong>
                                </p>
                                <ul style="margin: 10px 0 0 0; font-size: 14px; color: #856404;">
                                    <li>Kode ini berlaku selama <strong>5 menit</strong></li>
                                    <li>Jangan berikan kode ini kepada siapapun</li>
                                    <li>Jika Anda tidak meminta reset password, abaikan email ini</li>
                                </ul>
                            </div>

                            <p style="font-size: 14px; color: #666; text-align: center; margin-top: 30px;">
                                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
                            </p>
                        </div>

                        <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
                            <p>© 2025 Cookingz App. All rights reserved.</p>
                        </div>
                    </div>
                `
            };

            await transporter.sendMail(mailOptions);
            console.log(`OTP berhasil dikirim ke ${email}. Kode: ${otp}`);

            res.json({
                success: true,
                message: 'Kode OTP telah dikirim ke email Anda. Silakan periksa kotak masuk dan folder spam.'
            });

        } catch (err) {
            console.error('Database/Email error in sendOTP:', err);
            // Berikan pesan error generik ke frontend untuk keamanan
            res.status(500).json({
                success: false,
                message: 'Terjadi kesalahan server saat mengirim OTP. Pastikan konfigurasi email Anda benar.'
            });
        }
    } catch (error) {
        console.error('Error in sendOTP request:', error);
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan server.'
        });
    }
};

// Controller untuk verifikasi OTP
const verifyOTP = async (req, res) => {
    try {
        const { email, otp } = req.body; // Email yang dimasukkan pengguna di Flutter

        if (!email || !otp) {
            return res.status(400).json({
                success: false,
                message: 'Email dan OTP harus diisi.'
            });
        }

        // Validasi format OTP (harus 6 digit)
        if (!/^\d{6}$/.test(otp)) {
            return res.status(400).json({
                success: false,
                message: 'OTP harus berupa 6 digit angka.'
            });
        }

        // Cek OTP di storage (kunci adalah email pengguna)
        const storedOTPData = otpStorage.get(email);

        if (!storedOTPData) {
            return res.status(400).json({
                success: false,
                message: 'OTP tidak valid atau sudah expired. Silakan kirim ulang OTP.'
            });
        }

        // Cek apakah OTP expired
        if (Date.now() > storedOTPData.expires) {
            otpStorage.delete(email);
            return res.status(400).json({
                success: false,
                message: 'OTP sudah expired. Silakan kirim ulang OTP.'
            });
        }

        // Cek apakah OTP benar
        if (storedOTPData.otp !== otp) {
            return res.status(400).json({
                success: false,
                message: 'Kode OTP tidak valid. Silakan periksa kembali.'
            });
        }

        // OTP valid, generate token untuk reset password
        const resetToken = crypto.randomBytes(32).toString('hex');

        // Simpan reset token dengan waktu expire (15 menit)
        otpStorage.set(`reset_${email}`, { // Kunci Map ini adalah email pengguna
            token: resetToken,
            expires: Date.now() + 15 * 60 * 1000 // 15 menit
        });

        // Hapus OTP dari storage setelah verifikasi berhasil
        otpStorage.delete(email);

        res.json({
            success: true,
            message: 'Kode OTP berhasil diverifikasi. Silakan buat password baru.',
            resetToken: resetToken // Kirim resetToken ke frontend
        });

    } catch (error) {
        console.error('Error in verifyOTP:', error);
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan server saat verifikasi OTP.'
        });
    }
};

// Controller untuk reset password
const resetPassword = async (req, res) => {
    try {
        const { email, resetToken, newPassword, confirmPassword } = req.body; // 'email' di sini adalah email pengguna dari frontend

        if (!email || !resetToken || !newPassword || !confirmPassword) {
            return res.status(400).json({
                success: false,
                message: 'Semua field harus diisi.'
            });
        }

        if (newPassword !== confirmPassword) {
            return res.status(400).json({
                success: false,
                message: 'Password baru dan konfirmasi password tidak sama.'
            });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Password minimal 6 karakter.'
            });
        }

        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$/;
        if (!passwordRegex.test(newPassword)) {
            return res.status(400).json({
                success: false,
                message: 'Password harus mengandung minimal 1 huruf kecil, 1 huruf besar, dan 1 angka.'
            });
        }

        const storedTokenData = otpStorage.get(`reset_${email}`); // Mencari resetToken berdasarkan email pengguna

        if (!storedTokenData || storedTokenData.token !== resetToken) {
            return res.status(400).json({
                success: false,
                message: 'Token reset tidak valid atau sudah digunakan.'
            });
        }

        if (Date.now() > storedTokenData.expires) {
            otpStorage.delete(`reset_${email}`);
            return res.status(400).json({
                success: false,
                message: 'Token reset sudah expired. Silakan mulai proses reset password dari awal.'
            });
        }

        const saltRounds = 12; // Tingkatkan salt rounds untuk keamanan lebih baik
        const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

        try {
            // Update password di database untuk email pengguna
            const [updateResults] = await pool.query(
                'UPDATE users SET password_hash = ?, updated_at = NOW() WHERE email = ?',
                [hashedPassword, email]
            );

            if (updateResults.affectedRows === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'User tidak ditemukan.'
                });
            }

            otpStorage.delete(`reset_${email}`); // Hapus token reset untuk email pengguna

            // Kirim email konfirmasi password berhasil diubah (opsional, tapi bagus)
            const confirmationMailOptions = {
                from: {
                    name: 'Cookingz App',
                    address: process.env.GMAIL_USER // Pengirim email
                },
                to: email, // <--- KIRIM KONFIRMASI KE EMAIL PENGGUNA
                subject: '✅ Password Berhasil Diubah - Cookingz',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; border-radius: 10px;">
                        <div style="background-color: #28a745; color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;">
                            <h1 style="margin: 0; font-size: 24px;">🍳 Cookingz</h1>
                            <p style="margin: 10px 0 0 0; font-size: 16px;">Password Berhasil Diubah</p>
                        </div>

                        <div style="background-color: white; padding: 30px; border-radius: 0 0 10px 10px;">
                            <h2 style="color: #28a745; margin-top: 0;">✅ Berhasil!</h2>
                            <p style="font-size: 16px; line-height: 1.5; color: #333;">
                                Password akun Cookingz Anda telah berhasil diubah pada ${new Date().toLocaleString('id-ID')}.
                            </p>

                            <div style="background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; margin: 20px 0; border-radius: 8px;">
                                <p style="margin: 0; font-size: 14px; color: #155724;">
                                    Sekarang Anda dapat login dengan password baru Anda.
                                </p>
                            </div>

                            <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
                                <p style="margin: 0; font-size: 14px; color: #856404;">
                                    ⚠️ <strong>Catatan Keamanan:</strong>
                                </p>
                                <p style="margin: 10px 0 0 0; font-size: 14px; color: #856404;">
                                    Jika Anda tidak melakukan perubahan password ini, segera hubungi tim support kami.
                                </p>
                            </div>

                            <p style="font-size: 14px; color: #666; text-align: center; margin-top: 30px;">
                                Email ini dikirim secara otomatis, mohon tidak membalas email ini.
                            </p>
                        </div>

                        <div style="text-align: center; margin-top: 20px; font-size: 12px; color: #999;">
                            <p>© 2025 Cookingz App. All rights reserved.</p>
                        </div>
                    </div>
                `
            };

            // Kirim email konfirmasi (tidak menunggu hasil, karena ini hanya notifikasi)
            transporter.sendMail(confirmationMailOptions).catch(err => {
                console.error('Error sending confirmation email after reset:', err);
            });

            res.json({
                success: true,
                message: 'Password berhasil diubah. Silakan login dengan password baru Anda.'
            });

        } catch (err) {
            console.error('Database error during password reset:', err);
            res.status(500).json({
                success: false,
                message: 'Terjadi kesalahan server saat mengupdate password.'
            });
        }

    } catch (error) {
        console.error('Error in resetPassword request:', error);
        res.status(500).json({
            success: false,
            message: 'Terjadi kesalahan server.'
        });
    }
};

module.exports = {
    sendOTP,
    verifyOTP,
    resetPassword
};