// cookingz-backend/controllers/utilityController.js
const db = require('../db');

// --- Fungsi untuk Jadwal Makan (Meal Schedules) ---

exports.getMealSchedules = async (req, res) => {
    const requestedUserId = parseInt(req.params.id);

    console.log(`>>> Controller getMealSchedules BERHASIL DICAPAI! <<<`);
    console.log(`Requested User ID from URL: ${requestedUserId}`);

    try {
        const [rows] = await db.query(
            `SELECT
                ms.id,
                ms.user_id,
                ms.recipe_id,
                ms.date,

                r.title AS recipe_title,
                r.description AS recipe_description,
                r.cooking_time AS recipe_cooking_time,
                r.difficulty AS recipe_difficulty,
                r.price AS recipe_price,
                r.image_url AS recipe_image_url,
                r.video_url AS recipe_video_url,
                r.favorites_count AS recipe_favorites_count,

                AVG(rev.rating) AS recipe_rating

            FROM meal_schedules ms
            JOIN recipes r ON ms.recipe_id = r.id
            LEFT JOIN reviews rev ON r.id = rev.recipe_id

            WHERE ms.user_id = ?

            GROUP BY
                ms.id, ms.user_id, ms.recipe_id,
                ms.date,
                r.title, r.description, r.cooking_time, r.difficulty, r.price,
                r.image_url, r.video_url, r.favorites_count

            ORDER BY ms.date ASC`,
            [requestedUserId]
        );

        console.log(`Fetched meal schedules count: ${rows.length} for user_id: ${requestedUserId}`);
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
    // === PERUBAHAN DI SINI: Hapus 'meal_type' ===
    const { user_id, recipe_id, date } = req.body;
    console.log(`>>> Controller addMealSchedule BERHASIL DICAPAI! untuk user_id: ${user_id}, recipe_id: ${recipe_id} <<<`);

    // === PERUBAHAN DI SINI: Hapus validasi 'meal_type' ===
    if (!user_id || !recipe_id || !date) {
        return res.status(400).json({
            status: 'error',
            message: 'user_id, recipe_id, dan date wajib diisi.' // Pesan error diperbarui
        });
    }

    try {
        // === PERUBAHAN DI SINI: Hapus 'meal_type' dari query INSERT ===
        const [result] = await db.query(
            `INSERT INTO meal_schedules (user_id, recipe_id, date) VALUES (?, ?, ?)`,
            [user_id, recipe_id, date] // Array parameter diperbarui
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

// controllers/utilityController.js
exports.deleteMealSchedule = async (req, res) => {
  const { id, user_id } = req.params;
  console.log(`🔥 deleteMealSchedule HIT! id: ${id}, user_id: ${user_id}`);

  try {
    const [result] = await db.query(
      `DELETE FROM meal_schedules WHERE id = ? AND user_id = ?`,
      [id, user_id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Jadwal tidak ditemukan atau bukan milik Anda',
      });
    }

    res.json({
      status: 'success',
      message: 'Jadwal makan berhasil dihapus',
    });
  } catch (error) {
    console.error('❌ Error in deleteMealSchedule:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal menghapus jadwal makan',
      error: error.message,
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
            [id, userId]
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
