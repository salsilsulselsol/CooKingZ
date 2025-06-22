// File: cookingz-backend/controllers/reviewController.js

const db = require('../db');

/**
 * @desc    Menambahkan ulasan baru untuk sebuah resep
 * @route   POST /reviews
 * @access  Public (user_id diambil dari body, TIDAK diamankan oleh JWT)
 */
exports.addReview = async (req, res) => {
    const { user_id, recipe_id, rating, comment } = req.body;

    // Validasi input
    if (!user_id || !recipe_id || !rating || !comment) {
        return res.status(400).json({ message: 'Semua kolom (user_id, recipe_id, rating, comment) harus diisi.' });
    }

    // Pastikan user_id dan recipe_id adalah angka. Rating adalah angka antara 1-5.
    if (typeof user_id !== 'number' || typeof recipe_id !== 'number' || typeof rating !== 'number' || rating < 1 || rating > 5) {
        return res.status(400).json({ message: 'user_id, recipe_id, dan rating harus berupa angka. Rating harus antara 1-5.' });
    }

    try {
        // Cek apakah resep ada
        const [recipeCheck] = await db.query('SELECT id FROM recipes WHERE id = ?', [recipe_id]);
        if (recipeCheck.length === 0) {
            return res.status(404).json({ message: 'Resep tidak ditemukan.' });
        }

        // Cek apakah pengguna ada
        const [userCheck] = await db.query('SELECT id FROM users WHERE id = ?', [user_id]);
        if (userCheck.length === 0) {
            return res.status(404).json({ message: 'Pengguna tidak ditemukan.' });
        }

        // Cek apakah pengguna sudah pernah memberikan ulasan untuk resep ini
        // Menggunakan 'reviews' sesuai skema database Anda
        const [existingReview] = await db.query('SELECT id FROM reviews WHERE user_id = ? AND recipe_id = ?', [user_id, recipe_id]);
        if (existingReview.length > 0) {
            return res.status(409).json({ message: 'Anda sudah mengulas resep ini sebelumnya.' });
        }

        // Masukkan ulasan baru
        // Menggunakan 'reviews' sesuai skema database Anda
        const insertReviewQuery = 'INSERT INTO reviews (user_id, recipe_id, rating, comment) VALUES (?, ?, ?, ?)';
        const [insertResult] = await db.query(insertReviewQuery, [user_id, recipe_id, rating, comment]);

        // Hitung ulang rata-rata rating dan jumlah ulasan untuk resep
        // Menggunakan 'reviews' sesuai skema database Anda
        const updateRecipeRatingQuery = `
            UPDATE recipes
            SET
                average_rating = (SELECT AVG(rating) FROM reviews WHERE recipe_id = ?),
                comments_count = (SELECT COUNT(id) FROM reviews WHERE recipe_id = ?)
            WHERE id = ?;
        `;
        await db.query(updateRecipeRatingQuery, [recipe_id, recipe_id, recipe_id]);

        res.status(201).json({
            message: 'Ulasan berhasil ditambahkan.',
            reviewId: insertResult.insertId,
        });

    } catch (error) {
        console.error('Error saat menambahkan ulasan:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};

/**
 * @desc    Mendapatkan semua ulasan untuk resep tertentu
 * @route   GET /reviews/:recipeId
 * @access  Public
 */
exports.getReviewsByRecipeId = async (req, res) => {
    const { recipeId } = req.params;

    if (!recipeId) {
        return res.status(400).json({ message: 'ID Resep tidak ditemukan.' });
    }

    try {
        // Menggunakan 'reviews' sesuai skema database Anda
        const query = `
            SELECT
                rr.id,
                rr.user_id,
                u.username,
                u.full_name,
                u.profile_picture,
                rr.rating,
                rr.comment,
                rr.created_at
            FROM reviews rr
            JOIN users u ON rr.user_id = u.id
            WHERE rr.recipe_id = ?
            ORDER BY rr.created_at DESC;
        `;
        const [reviews] = await db.query(query, [recipeId]);

        res.status(200).json(reviews);

    } catch (error) {
        console.error('Error saat mengambil ulasan:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};

/**
 * @desc    Menghapus ulasan tertentu
 * @route   DELETE /reviews/:reviewId
 * @access  Public (Siapapun bisa menghapus jika tahu reviewId & userId)
 */
exports.deleteReview = async (req, res) => {
    const { reviewId } = req.params;
    const { user_id } = req.body; // Mengambil user_id dari body untuk verifikasi (meskipun tidak aman)

    if (!reviewId) {
        return res.status(400).json({ message: 'ID Ulasan tidak ditemukan.' });
    }
    if (!user_id) {
        return res.status(400).json({ message: 'ID Pengguna diperlukan untuk menghapus ulasan.' });
    }

    try {
        // Cek kepemilikan ulasan (minimal)
        // Menggunakan 'reviews' sesuai skema database Anda
        const [reviewCheck] = await db.query('SELECT recipe_id FROM reviews WHERE id = ? AND user_id = ?', [reviewId, user_id]);
        if (reviewCheck.length === 0) {
            return res.status(403).json({ message: 'Anda tidak diizinkan menghapus ulasan ini atau ulasan tidak ditemukan.' });
        }

        const recipeId = reviewCheck[0].recipe_id;

        // Menghapus ulasan
        // Menggunakan 'reviews' sesuai skema database Anda
        const deleteQuery = 'DELETE FROM reviews WHERE id = ? AND user_id = ?';
        await db.query(deleteQuery, [reviewId, user_id]);

        // Hitung ulang rata-rata rating dan jumlah ulasan untuk resep
        // Menggunakan 'reviews' sesuai skema database Anda
        const updateRecipeRatingQuery = `
            UPDATE recipes
            SET
                average_rating = (SELECT AVG(rating) FROM reviews WHERE recipe_id = ?),
                comments_count = (SELECT COUNT(id) FROM reviews WHERE recipe_id = ?)
            WHERE id = ?;
        `;
        await db.query(updateRecipeRatingQuery, [recipeId, recipeId, recipeId]);

        res.status(200).json({ message: 'Ulasan berhasil dihapus.' });

    } catch (error) {
        console.error('Error saat menghapus ulasan:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};