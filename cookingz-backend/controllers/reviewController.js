// cookingz-backend/controllers/reviewController.js
const pool = require('../db');

const reviewController = {
  // Fungsi untuk menambahkan ulasan baru ke sebuah resep
  addReview: async (req, res, next) => {
    const { id } = req.params; // ID resep dari URL
    const { user_id, rating, comment } = req.body; // Data ulasan dari body request

    if (!user_id || !rating || !comment) {
      return res.status(400).json({ message: 'User ID, rating, dan comment wajib diisi.' });
    }
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating harus antara 1 dan 5.' });
    }

    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();

      // 1. Masukkan ulasan baru ke tabel 'reviews'
      const [reviewResult] = await connection.query(
        'INSERT INTO reviews (recipe_id, user_id, rating, comment) VALUES (?, ?, ?, ?)',
        [id, user_id, rating, comment]
      );

      // 2. Perbarui average_rating dan comments_count di tabel 'recipes'
      // Hitung ulang rata-rata rating dan jumlah komentar untuk resep ini
      const [averageRatingResult] = await connection.query(
        'SELECT AVG(rating) AS avg_rating, COUNT(id) AS comment_count FROM reviews WHERE recipe_id = ?',
        [id]
      );

      const avgRating = averageRatingResult[0].avg_rating || 0;
      const commentCount = averageRatingResult[0].comment_count || 0;

      await connection.query(
        'UPDATE recipes SET average_rating = ?, comments_count = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [avgRating, commentCount, id]
      );

      await connection.commit();
      res.status(201).json({ message: 'Ulasan berhasil ditambahkan!', reviewId: reviewResult.insertId });

    } catch (error) {
      if (connection) {
        await connection.rollback();
      }
      console.error('Error adding review:', error);
      next(error); // Teruskan error ke middleware penanganan error global
    } finally {
      if (connection) {
        connection.release();
      }
    }
  },

  // Fungsi untuk menampilkan semua ulasan untuk resep tertentu
  getReviewsByRecipeId: async (req, res, next) => {
    const { id } = req.params; // ID resep dari URL

    try {
      // Ambil ulasan beserta informasi dasar pengguna yang memberikan ulasan
      const [reviews] = await pool.query(
        `SELECT r.id, r.user_id, u.username, u.full_name, u.profile_picture, r.rating, r.comment, r.created_at
         FROM reviews r
         JOIN users u ON r.user_id = u.id
         WHERE r.recipe_id = ?
         ORDER BY r.created_at DESC`, // Urutkan dari yang terbaru
        [id]
      );

      res.status(200).json(reviews);

    } catch (error) {
      console.error('Error getting reviews by recipe ID:', error);
      next(error); // Teruskan error ke middleware penanganan error global
    }
  }
};

module.exports = reviewController;