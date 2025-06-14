// File: cookingz-backend/controllers/favoriteController.js

const db = require('../db');

/**
 * @desc    Menambah atau menghapus resep dari favorit pengguna.
 * @route   POST /recipes/:id/favorite
 * @access  Private (akan menggunakan middleware otentikasi nantinya)
 */
exports.toggleFavorite = async (req, res) => {
    // TODO: Ganti baris ini dengan `const userId = req.user.id;` setelah otentikasi siap.
    // Untuk sekarang, kita akan hardcode user ID 1 untuk pengujian.
    const userId = 1;

    const { id: recipeId } = req.params; // Mengambil recipeId dari URL params

    if (!userId) {
        return res.status(401).json({ message: 'Akses ditolak. Tidak ada pengguna yang terautentikasi.' });
    }

    if (!recipeId) {
        return res.status(400).json({ message: 'ID Resep tidak ditemukan.' });
    }

    try {
        // Cek apakah resep sudah ada di favorit pengguna
        const checkQuery = 'SELECT * FROM recipe_favorites WHERE user_id = ? AND recipe_id = ?';
        const [existingFavorite] = await db.query(checkQuery, [userId, recipeId]);

        if (existingFavorite.length > 0) {
            // Jika sudah ada, berarti pengguna ingin menghapus dari favorit (UNFAVORITE)
            const deleteQuery = 'DELETE FROM recipe_favorites WHERE user_id = ? AND recipe_id = ?';
            await db.query(deleteQuery, [userId, recipeId]);

            // Kurangi favorites_count di tabel recipes
            const updateRecipeCountQuery = 'UPDATE recipes SET favorites_count = GREATEST(0, favorites_count - 1) WHERE id = ?';
            await db.query(updateRecipeCountQuery, [recipeId]);

            return res.status(200).json({ message: 'Resep berhasil dihapus dari favorit.', isFavorited: false });
        } else {
            // Jika belum ada, berarti pengguna ingin menambah ke favorit (FAVORITE)
            const insertQuery = 'INSERT INTO recipe_favorites (user_id, recipe_id) VALUES (?, ?)';
            await db.query(insertQuery, [userId, recipeId]);

            // Tambah favorites_count di tabel recipes
            const updateRecipeCountQuery = 'UPDATE recipes SET favorites_count = favorites_count + 1 WHERE id = ?';
            await db.query(updateRecipeCountQuery, [recipeId]);

            return res.status(201).json({ message: 'Resep berhasil ditambahkan ke favorit.', isFavorited: true });
        }
    } catch (error) {
        console.error('Error saat mengubah status favorit:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};

/**
 * @desc    Mengecek status favorit resep tertentu untuk pengguna yang sedang login.
 * @route   GET /recipes/:id/favorite-status
 * @access  Private (akan menggunakan middleware otentikasi nantinya)
 */
exports.checkFavoriteStatus = async (req, res) => {
    // TODO: Ganti baris ini dengan `const userId = req.user.id;` setelah otentikasi siap.
    // Untuk sekarang, kita akan hardcode user ID 1 untuk pengujian.
    const userId = 1;

    const { id: recipeId } = req.params;

    if (!userId) {
        return res.status(401).json({ message: 'Akses ditolak. Tidak ada pengguna yang terautentikasi.' });
    }

    if (!recipeId) {
        return res.status(400).json({ message: 'ID Resep tidak ditemukan.' });
    }

    try {
        const query = 'SELECT * FROM recipe_favorites WHERE user_id = ? AND recipe_id = ?';
        const [result] = await db.query(query, [userId, recipeId]);

        return res.status(200).json({ isFavorited: result.length > 0 });
    } catch (error) {
        console.error('Error saat mengecek status favorit:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};