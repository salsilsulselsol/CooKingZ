const pool = require('../db');

const categoryController = {
  // HAPUS FUNGSI _formatImageUrl

  // Fungsi untuk mendapatkan semua kategori (GET /categories)
  getAllCategories: async (req, res, next) => {
    const query = 'SELECT id, name, description, image_url FROM categories';
    try {
      const [results] = await pool.query(query);
      const formattedCategories = results.map(category => ({
        id: category.id,
        name: category.name,
        description: category.description,
        // UBAH: Kirim path relatif yang konsisten
        image_url: category.image_url ? `/uploads/${category.image_url}` : '' 
      }));
      res.status(200).json(formattedCategories);
    } catch (err) {
      console.error('Error fetching categories:', err);
      next(err);
    }
  },

  // FUNGSI UNTUK MENDAPATKAN RESEP BERDASARKAN ID KATEGORI
  getRecipesByCategoryId: async (req, res, next) => {
    const { categoryId } = req.params;
    const query = `
      SELECT
        r.id, r.title, r.description, r.image_url, r.cooking_time, 
        r.price, r.favorites_count, r.difficulty,
        AVG(rev.rating) AS average_rating
      FROM recipes r
      LEFT JOIN reviews rev ON r.id = rev.recipe_id
      WHERE r.category_id = ?
      GROUP BY r.id
      ORDER BY r.created_at DESC
    `;

    try {
      const [recipes] = await pool.query(query, [categoryId]);
      
      // UBAH: Seragamkan output JSON agar sesuai dengan model Food di Flutter
      const formattedRecipes = recipes.map(recipe => ({
        id: recipe.id,
        title: recipe.title, // Key: 'title'
        description: recipe.description,
        image_url: recipe.image_url, // Key: 'image_url' (sudah dalam format /uploads/...)
        cooking_time: recipe.cooking_time, // Key: 'cooking_time'
        price: recipe.price != null ? String(recipe.price) : null,
        total_reviews: recipe.favorites_count, // Key: 'total_reviews'
        avg_rating: recipe.average_rating ? parseFloat(recipe.average_rating) : null, // Key: 'avg_rating'
        difficulty: recipe.difficulty,
      }));

      res.status(200).json(formattedRecipes);
    } catch (err) {
      console.error(`Error fetching recipes for category ${categoryId}:`, err);
      next(err);
    }
  }
};

module.exports = categoryController;