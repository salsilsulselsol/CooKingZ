// cookingz-backend/controllers/utilityController.js
const db = require('../db');

// --- Fungsi untuk Jadwal Makan (Meal Schedules) ---

// GET semua jadwal makan untuk user yang sedang login
exports.getMealSchedules = async (req, res) => {
    const userId = req.userId; // user_id didapatkan dari authenticateToken
    console.log(`>>> Controller getMealSchedules BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);
    try {
        const [rows] = await db.query(
            `SELECT 
                ms.id, 
                ms.user_id, 
                ms.recipe_id, 
                ms.meal_type, 
                ms.date,
                r.title as recipe_title, 
                r.image_url as recipe_image_url,
                r.cooking_time as recipe_cooking_time, -- Tambahkan ini jika FoodCardJadwal butuh waktu masak
                r.price as recipe_price -- Tambahkan ini jika FoodCardJadwal butuh harga
             FROM meal_schedules ms
             JOIN recipes r ON ms.recipe_id = r.id
             WHERE ms.user_id = ?
             ORDER BY ms.date ASC, ms.meal_type ASC`, // Urutkan berdasarkan tanggal dan jenis makan
            [userId]
        );
        console.log(`Fetched meal schedules count: ${rows.length}`);
        res.json({
            status: 'success',
            message: 'Jadwal makan berhasil diambil',
            data: rows
        });
    } catch (error) {
        console.error('Error in getMealSchedules:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil jadwal makan',
            error: error.message
        });
    }
};

// POST jadwal makan baru
exports.addMealSchedule = async (req, res) => {
    // ✅ Ambil user_id dari request body instead of JWT
    const { user_id, recipe_id, meal_type, date } = req.body;
    console.log(`>>> Controller addMealSchedule BERHASIL DICAPAI! untuk user_id: ${user_id}, recipe_id: ${recipe_id} <<<`);

    // ✅ Validasi semua field termasuk user_id
    if (!user_id || !recipe_id || !meal_type || !date) {
        return res.status(400).json({
            status: 'error',
            message: 'user_id, recipe_id, meal_type, dan date wajib diisi.'
        });
    }

    try {
        const [result] = await db.query(
            `INSERT INTO meal_schedules (user_id, recipe_id, meal_type, date) VALUES (?, ?, ?, ?)`,
            [user_id, recipe_id, meal_type, date] // ✅ Gunakan user_id dari body
        );
        console.log(`Meal schedule added. Insert ID: ${result.insertId}`);
        res.status(201).json({
            status: 'success',
            message: 'Jadwal makan berhasil ditambahkan',
            id: result.insertId
        });
    } catch (error) {
        console.error('Error in addMealSchedule:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal menambahkan jadwal makan',
            error: error.message
        });
    }
};

// DELETE jadwal makan berdasarkan ID
exports.deleteMealSchedule = async (req, res) => {
    const userId = req.userId;
    const { id } = req.params; // ID jadwal dari URL parameter
    console.log(`>>> Controller deleteMealSchedule BERHASIL DICAPAI! untuk user_id: ${userId}, schedule_id: ${id} <<<`);

    try {
        const [result] = await db.query(
            `DELETE FROM meal_schedules WHERE id = ? AND user_id = ?`,
            [id, userId] // Pastikan user hanya bisa menghapus jadwalnya sendiri
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'Jadwal makan tidak ditemukan atau Anda tidak memiliki izin untuk menghapusnya.'
            });
        }
        console.log(`Meal schedule deleted. ID: ${id}`);
        res.json({
            status: 'success',
            message: 'Jadwal makan berhasil dihapus'
        });
    } catch (error) {
        console.error('Error in deleteMealSchedule:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal menghapus jadwal makan',
            error: error.message
        });
    }
};

// --- Fungsi untuk Notifikasi ---

// GET semua notifikasi untuk user yang sedang login
exports.getNotifications = async (req, res) => {
    const userId = req.userId;
    console.log(`>>> Controller getNotifications BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);
    try {
        const [rows] = await db.query(
            `SELECT id, user_id, message, is_read, created_at
             FROM notifications
             WHERE user_id = ?
             ORDER BY created_at DESC`,
            [userId]
        );
        console.log(`Fetched notifications count: ${rows.length}`);
        res.json({
            status: 'success',
            message: 'Notifikasi berhasil diambil',
            data: rows
        });
    } catch (error) {
        console.error('Error in getNotifications:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil notifikasi',
            error: error.message
        });
    }
};

// PUT (update) notifikasi menjadi sudah dibaca berdasarkan ID
exports.markNotificationAsRead = async (req, res) => {
    const userId = req.userId;
    const { id } = req.params;
    console.log(`>>> Controller markNotificationAsRead BERHASIL DICAPAI! untuk user_id: ${userId}, notification_id: ${id} <<<`);

    try {
        const [result] = await db.query(
            `UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
            [id, userId] // Pastikan user hanya bisa mengubah status notifikasinya sendiri
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'Notifikasi tidak ditemukan atau Anda tidak memiliki izin untuk mengubahnya.'
            });
        }
        console.log(`Notification ID ${id} marked as read.`);
        res.json({
            status: 'success',
            message: 'Notifikasi berhasil ditandai sebagai sudah dibaca'
        });
    } catch (error) {
        console.error('Error in markNotificationAsRead:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal menandai notifikasi sebagai sudah dibaca',
            error: error.message
        });
    }
};