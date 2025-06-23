// File: cookingz-backend/controllers/reviewController.js

const db = require('../db');

/**
 * @desc    Menambahkan ulasan baru untuk sebuah resep
 * @route   POST /reviews
 * @access  Public (user_id diambil dari body, TIDAK diamankan oleh JWT)
 */
//exports.addReview = async (req, res) => {
//    const { user_id, recipe_id, rating, comment } = req.body;
//
//    // Validasi input
//    if (!user_id || !recipe_id || !rating || !comment) {
//        return res.status(400).json({ message: 'Semua kolom (user_id, recipe_id, rating, comment) harus diisi.' });
//    }
//
//    // Konversi ke number dan validasi (karena dari JSON biasanya string)
//    const userIdNum = parseInt(user_id);
//    const recipeIdNum = parseInt(recipe_id);
//    const ratingNum = parseInt(rating);
//
//    if (isNaN(userIdNum) || isNaN(recipeIdNum) || isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5) {
//        return res.status(400).json({ message: 'user_id, recipe_id, dan rating harus berupa angka. Rating harus antara 1-5.' });
//    }
//
//    try {
//        // Cek apakah resep ada
//        const [recipeCheck] = await db.query('SELECT id FROM recipes WHERE id = ?', [recipeIdNum]);
//        if (recipeCheck.length === 0) {
//            return res.status(404).json({ message: 'Resep tidak ditemukan.' });
//        }
//
//        // Cek apakah pengguna ada
//        const [userCheck] = await db.query('SELECT id FROM users WHERE id = ?', [userIdNum]);
//        if (userCheck.length === 0) {
//            return res.status(404).json({ message: 'Pengguna tidak ditemukan.' });
//        }
//
//        // Cek apakah pengguna sudah pernah memberikan ulasan untuk resep ini
//        const [existingReview] = await db.query('SELECT id FROM reviews WHERE user_id = ? AND recipe_id = ?', [userIdNum, recipeIdNum]);
//        if (existingReview.length > 0) {
//            return res.status(409).json({ message: 'Anda sudah mengulas resep ini sebelumnya.' });
//        }
//
//        // Masukkan ulasan baru
//        const insertReviewQuery = 'INSERT INTO reviews (user_id, recipe_id, rating, comment) VALUES (?, ?, ?, ?)';
//        const [insertResult] = await db.query(insertReviewQuery, [userIdNum, recipeIdNum, ratingNum, comment]);
//
//        // HAPUS bagian update recipe rating karena kolom tidak ada di tabel recipes
//
//        res.status(201).json({
//            message: 'Ulasan berhasil ditambahkan.',
//            reviewId: insertResult.insertId,
//        });
//
//    } catch (error) {
//        console.error('Error saat menambahkan ulasan:', error);
//        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
//    }
//};

//exports.addReview = async (req, res) => {
//    console.log('=== MULAI addReview ===');
//    const { user_id, recipe_id, rating, comment, parent_id = null } = req.body;
//    console.log('Input:', { user_id, recipe_id, rating, comment, parent_id });
//
//    if (!user_id || !recipe_id || !comment) {
//        console.log('❌ Validasi gagal: user_id, recipe_id, dan comment wajib.');
//        return;
//    }
//
//    if (parent_id === null && !rating) {
//        console.log('❌ Validasi gagal: Rating wajib untuk komentar utama.');
//        return;
//    }
//
//    const userIdNum = parseInt(user_id, 10);
//    const recipeIdNum = parseInt(recipe_id, 10);
//    const ratingNum = rating !== undefined && rating !== null ? parseInt(rating, 10) : null;
//    const parentIdNum = parent_id ? parseInt(parent_id, 10) : null;
//    console.log('Parsed Values:', { userIdNum, recipeIdNum, ratingNum, parentIdNum });
//
//    if (isNaN(userIdNum) || isNaN(recipeIdNum)) {
//        console.log('❌ user_id dan recipe_id harus angka.');
//        return;
//    }
//
//    if (ratingNum !== null && (isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5)) {
//        console.log('❌ Rating harus antara 1 sampai 5.');
//        return;
//    }
//
//    if (parentIdNum !== null && isNaN(parentIdNum)) {
//        console.log('❌ parent_id harus angka jika diisi.');
//        return;
//    }
//
//    try {
//        const [recipeCheck] = await db.query('SELECT id FROM recipes WHERE id = ?', [recipeIdNum]);
//        if (recipeCheck.length === 0) {
//            console.log('❌ Resep tidak ditemukan.');
//            return;
//        }
//
//        const [userCheck] = await db.query('SELECT id FROM users WHERE id = ?', [userIdNum]);
//        if (userCheck.length === 0) {
//            console.log('❌ Pengguna tidak ditemukan.');
//            return;
//        }
//
//        if (parentIdNum !== null) {
//            const [parentCheck] = await db.query('SELECT id FROM reviews WHERE id = ? AND recipe_id = ?', [parentIdNum, recipeIdNum]);
//            if (parentCheck.length === 0) {
//                console.log('❌ Komentar induk tidak valid atau bukan dari resep yang sama.');
//                return;
//            }
//        }
//
//        if (parentIdNum === null) {
//            const [existingReview] = await db.query(
//                'SELECT id FROM reviews WHERE user_id = ? AND recipe_id = ? AND parent_id IS NULL',
//                [userIdNum, recipeIdNum]
//            );
//            if (existingReview.length > 0) {
//                console.log('❌ Sudah ada komentar utama dari user ini.');
//                return;
//            }
//        }
//
//        const insertQuery = `
//            INSERT INTO reviews (user_id, recipe_id, parent_id, rating, comment)
//            VALUES (?, ?, ?, ?, ?);
//        `;
//        const [insertResult] = await db.query(insertQuery, [
//            userIdNum,
//            recipeIdNum,
//            parentIdNum,
//            ratingNum,
//            comment
//        ]);
//
//        console.log('✅ Komentar berhasil ditambahkan. ID:', insertResult.insertId);
//
//    } catch (error) {
//        console.error('🔥 ERROR saat insert komentar:', error);
//    }
//};

exports.addReview = async (req, res) => {
    console.log('=== MULAI addReview ===');
    const { user_id, recipe_id, rating, comment, parent_id = null } = req.body;
    console.log('Input:', { user_id, recipe_id, rating, comment, parent_id });

    // --- Validasi Input ---
    if (!user_id || !recipe_id || !comment) {
        console.log('❌ Validasi gagal: user_id, recipe_id, dan comment wajib.');
        // Berikan response error yang jelas
        return res.status(400).json({ message: 'User ID, Recipe ID, dan Komentar tidak boleh kosong.' });
    }

    if (parent_id === null && !rating) {
        console.log('❌ Validasi gagal: Rating wajib untuk komentar utama.');
        // Berikan response error yang jelas
        return res.status(400).json({ message: 'Rating wajib diisi untuk ulasan utama.' });
    }

    // --- Parsing dan Validasi Tipe Data ---
    const userIdNum = parseInt(user_id, 10);
    const recipeIdNum = parseInt(recipe_id, 10);
    const ratingNum = rating !== undefined && rating !== null ? parseInt(rating, 10) : null;
    const parentIdNum = parent_id ? parseInt(parent_id, 10) : null;

    if (isNaN(userIdNum) || isNaN(recipeIdNum)) {
        console.log('❌ user_id dan recipe_id harus angka.');
        return res.status(400).json({ message: 'User ID dan Recipe ID harus berupa angka.' });
    }

    if (ratingNum !== null && (isNaN(ratingNum) || ratingNum < 1 || ratingNum > 5)) {
        console.log('❌ Rating harus antara 1 sampai 5.');
        return res.status(400).json({ message: 'Rating harus berupa angka antara 1 dan 5.' });
    }

    if (parentIdNum !== null && isNaN(parentIdNum)) {
        console.log('❌ parent_id harus angka jika diisi.');
        return res.status(400).json({ message: 'Parent ID harus berupa angka.' });
    }

    try {
        // --- Pengecekan Eksistensi Data di DB ---
        const [recipeCheck] = await db.query('SELECT id FROM recipes WHERE id = ?', [recipeIdNum]);
        if (recipeCheck.length === 0) {
            console.log('❌ Resep tidak ditemukan.');
            return res.status(404).json({ message: 'Resep tidak ditemukan.' });
        }

        const [userCheck] = await db.query('SELECT id FROM users WHERE id = ?', [userIdNum]);
        if (userCheck.length === 0) {
            console.log('❌ Pengguna tidak ditemukan.');
            return res.status(404).json({ message: 'Pengguna tidak ditemukan.' });
        }

        if (parentIdNum !== null) {
            const [parentCheck] = await db.query('SELECT id FROM reviews WHERE id = ? AND recipe_id = ?', [parentIdNum, recipeIdNum]);
            if (parentCheck.length === 0) {
                console.log('❌ Komentar induk tidak valid.');
                return res.status(404).json({ message: 'Komentar induk yang dirujuk tidak ditemukan pada resep ini.' });
            }
        }

        // --- INI BAGIAN UTAMA PERBAIKAN ---
        if (parentIdNum === null) {
            const [existingReview] = await db.query(
                'SELECT id FROM reviews WHERE user_id = ? AND recipe_id = ? AND parent_id IS NULL',
                [userIdNum, recipeIdNum]
            );
            if (existingReview.length > 0) {
                console.log('❌ Konflik: Pengguna sudah memberikan ulasan utama.');
                // Ganti `return;` dengan response error yang spesifik
                return res.status(409).json({
                    message: 'Anda sudah pernah memberikan ulasan utama untuk resep ini.'
                });
            }
        }

        // --- Proses Insert ke Database ---
        const insertQuery = `
            INSERT INTO reviews (user_id, recipe_id, parent_id, rating, comment)
            VALUES (?, ?, ?, ?, ?);
        `;
        const [insertResult] = await db.query(insertQuery, [
            userIdNum,
            recipeIdNum,
            parentIdNum,
            ratingNum,
            comment
        ]);

        console.log('✅ Komentar berhasil ditambahkan. ID:', insertResult.insertId);
        // Kirim response sukses
        return res.status(201).json({
            message: 'Ulasan berhasil ditambahkan.',
            reviewId: insertResult.insertId
        });

    } catch (error) {
        console.error('🔥 ERROR saat insert komentar:', error);
        // Kirim response error server
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};

// Mendapatkan semua ulasan untuk resep tertentu

exports.getReviewsByRecipeId = async (req, res) => {
    const { recipeId } = req.params;

    if (!recipeId) {
        return res.status(400).json({ message: 'ID Resep tidak ditemukan.' });
    }

    try {
        const query = `
            SELECT
                r.id,
                r.user_id,
                r.parent_id, -- Kita ambil parent_id
                u.username,
                u.full_name,
                u.profile_picture,
                r.rating,
                r.comment,
                r.created_at
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.recipe_id = ?
            ORDER BY r.created_at ASC; -- Urutkan dari yang terlama agar pohon bisa dibangun dengan benar
        `;
        const [allComments] = await db.query(query, [recipeId]);

        // --- Logika untuk membangun struktur pohon (nested) ---
        const commentsMap = {};
        const rootComments = [];

        // Pertama, petakan semua komentar berdasarkan ID mereka untuk akses cepat
        allComments.forEach(comment => {
            commentsMap[comment.id] = { ...comment, replies: [] };
        });

        // Kedua, susun hirarkinya
        allComments.forEach(comment => {
            if (comment.parent_id !== null) {
                // Jika ini adalah balasan, temukan induknya dan tambahkan ke array 'replies'
                if (commentsMap[comment.parent_id]) {
                    commentsMap[comment.parent_id].replies.push(commentsMap[comment.id]);
                }
            } else {
                // Jika ini adalah komentar utama (root), tambahkan ke array root
                rootComments.push(commentsMap[comment.id]);
            }
        });

        // Balik urutan rootComments agar yang terbaru muncul di atas
        rootComments.reverse();

        res.status(200).json(rootComments);

    } catch (error) {
        console.error('Error saat mengambil ulasan:', error);
        return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
    }
};

// Menghapus ulasan tertentu

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