const pool = require('../db');
const path = require('path');
const fs = require('fs');

const categoryController = {
  // Fungsi pembantu untuk memformat URL gambar kategori/resep
  _formatImageUrl: (req, filename) => {
    // Jika filename kosong/null/spasi kosong, kembalikan string kosong
    if (!filename || (typeof filename === 'string' && filename.trim() === '')) {
      return '';
    }
    // Jika filename sudah berupa URL lengkap, kembalikan apa adanya
    if (typeof filename === 'string' && filename.startsWith('http')) {
      return filename;
    }
    // Jika hanya nama file, bangun URL lengkapnya
    const protocol = req.protocol || 'http';
    const host = req.headers.host;
    // Pastikan folder 'uploads' ada di root backend dan file gambarnya ada di sana
    return `${protocol}://${host}/uploads/${filename}`;
  },

  // Fungsi untuk mendapatkan semua kategori (GET /categories)
  getAllCategories: async (req, res, next) => {
    const query = 'SELECT id, name, description, image_url FROM categories';
    try {
      const [results] = await pool.query(query);
      const formattedCategories = results.map(category => ({
          id: category.id,
          name: category.name,
          description: category.description,
          image_url: categoryController._formatImageUrl(req, category.image_url)
      }));
      res.status(200).json(formattedCategories);
    } catch (err) {
      console.error('Error fetching categories:', err);
      next(err); // Teruskan error ke middleware penanganan error global
    }
  },

  // FUNGSI UNTUK MENDAPATKAN RESEP BERDASARKAN ID KATEGORI
  getRecipesByCategoryId: async (req, res, next) => {
    const { categoryId } = req.params;

    // QUERY BARU: Mengambil rata-rata rating dari tabel reviews
    const query = `
      SELECT
        r.id,
        r.title,
        r.description,
        r.image_url,
        r.cooking_time,
        r.price,
        r.favorites_count,
        -- Mengambil rata-rata rating dari tabel reviews
        -- Menggunakan LEFT JOIN agar resep tanpa review tetap muncul (rating akan NULL)
        AVG(rev.rating) AS average_rating
      FROM
        recipes r
      LEFT JOIN
        reviews rev ON r.id = rev.recipe_id
      WHERE
        r.category_id = ?
      GROUP BY
        r.id, r.title, r.description, r.image_url, r.cooking_time, r.price, r.favorites_count
      ORDER BY
        r.created_at DESC
    `;

    try {
      const [recipes] = await pool.query(query, [categoryId]);

      const formattedRecipes = recipes.map(recipe => ({
        id: recipe.id,
        name: recipe.title,
        description: recipe.description,
        image: categoryController._formatImageUrl(req, recipe.image_url),
        cookingTime: recipe.cooking_time,
        price: recipe.price != null ? String(recipe.price) : null,
        likes: recipe.favorites_count,
        rating: recipe.average_rating ? parseFloat(recipe.average_rating).toFixed(1) : null // Format rating ke 1 desimal atau null
      }));

      res.status(200).json(formattedRecipes);
    } catch (err) {
      console.error(`Error fetching recipes for category ${categoryId}:`, err);
      next(err);
    }
  }
};

module.exports = categoryController;