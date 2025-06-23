// File: controllers/notificationController.js

// PASTIHAN PATH INI SUDAH BENAR SESUAI DENGAN LOKASI db.js Anda.
const pool = require('../db'); // <<< Ini sudah benar, mengimpor sebagai 'pool'

// --- FUNGSI UNTUK MENGAMBIL NOTIFIKASI PENGGUNA (GET /notifications/:userId) ---
exports.getUserNotifications = async (req, res) => {
    console.log('>>> Controller getUserNotifications BERHASIL DICAPAI! <<<');
    const userId = req.params.userId; // Ambil userId dari parameter URL (misal dari /notifications/123)
    const { limit = 20, offset = 0 } = req.query; // Untuk pagination (opsional, default 20 item, mulai dari 0)

    if (!userId) {
        console.error('!!! ERROR: User ID tidak ditemukan di parameter rute.');
        return res.status(400).json({
            status: 'error',
            message: 'User ID diperlukan untuk mengambil notifikasi.'
        });
    }

    try {
        const query = `
            SELECT
                id,
                user_id,
                title,      -- Asumsi kolom 'title' ada di tabel notifikasi Anda
                message,
                is_read,
                created_at
            FROM notifications
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT ? OFFSET ?;
        `;
        // KESALAHAN SEBELUMNYA DI SINI: MASIH 'db.query'
        // SEHARUSNYA: 'pool.query' karena Anda mengimpornya sebagai 'pool'
        const [rows] = await pool.query(query, [userId, parseInt(limit), parseInt(offset)]); // <<< PERBAIKAN PENTING DI BARIS INI

        console.log(`DEBUG: Notifikasi untuk User ID ${userId} ditemukan: ${rows.length} baris.`);
        // console.log('DEBUG: Data notifikasi:', rows); // Uncomment jika ingin melihat data notifikasi di log

        res.json({
            status: 'success',
            message: 'Notifikasi berhasil diambil',
            data: rows // Mengembalikan list notifikasi langsung
        });
        console.log('<<< Response for getUserNotifications sent successfully. >>>');

    } catch (error) {
        // PERHATIAN: Di sini juga, error message yang dikembalikan harus konsisten.
        // Jika errornya dari `pool.query` (seperti ReferenceError ini),
        // maka `error.message` akan berisi detailnya.
        console.error('!!! FINAL CATCH - Error in getUserNotifications controller:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil notifikasi. Silakan coba lagi nanti.',
            error: error.message // Mengembalikan detail error dari backend ke frontend
        });
    }
};

// --- CATATAN: Metode lain seperti markNotificationAsRead (PUT) belum disertakan ---