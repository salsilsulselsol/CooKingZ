// cookingz-backend/controllers/recipeController.js
const pool = require('../db');
const path = require('path');
const fs = require('fs');

const recipeController = {
  // Fungsi pembantu untuk menghapus file yang diunggah dari server (misalnya jika validasi gagal)
  _deleteUploadedFiles: (imageFile, videoFile) => {
    if (imageFile && fs.existsSync(imageFile.path)) {
      fs.unlinkSync(imageFile.path);
      console.log(`Deleted temporary uploaded file: ${imageFile.path}`);
    }
    if (videoFile && fs.existsSync(videoFile.path)) {
      fs.unlinkSync(videoFile.path);
      console.log(`Deleted temporary uploaded file: ${videoFile.path}`);
    }
  },

  // Fungsi pembantu untuk menghapus file dari URL database (digunakan saat DELETE/UPDATE)
  _deleteFileByUrl: (url) => {
    // Hanya hapus jika URL bukan URL default atau kosong
    if (url && url !== 'default_recipe_image.png') {
      const filePath = path.join(__dirname, '..', url); // Path absolut dari URL relatif
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`File deleted from storage: ${filePath}`);
      }
    }
  },

  // Fungsi untuk menambah resep baru (CREATE)
  addRecipe: async (req, res, next) => { // Tambahkan 'next' untuk meneruskan error ke global handler
    // Data teks dari req.body (dikirim sebagai string JSON dari FormData)
    // Multer akan secara otomatis mem-parse field teks ke req.body
    const {
      userId,
      categoryId,
      title,
      description,
      estimatedTime, // String: "1 Jam, 30 Menit" atau "30 Menit"
      price,         // String: "25000"
      difficulty,
      tools,         // Ini akan menjadi string JSON: '["Wajan", "Spatula"]'
      ingredients,   // Ini akan menjadi string JSON: '[{"quantity":"100", "unit":"gram", "name":"Tepung"}]'
      instructions   // Ini akan menjadi string JSON: '["Langkah 1", "Langkah 2"]'
    } = req.body;

    // File yang diunggah dari req.files (disediakan oleh Multer)
    const imageFile = req.files && req.files['image'] ? req.files['image'][0] : null;
    const videoFile = req.files && req.files['video'] ? req.files['video'][0] : null;

    // Log untuk debugging: Apa yang diterima backend
    console.log('=== addRecipe Request Body ===');
    console.log(req.body);
    console.log('=== addRecipe Request Files ===');
    console.log(req.files);
    console.log('--------------------');

    // Validasi gambar (wajib)
    if (!imageFile) {
        recipeController._deleteUploadedFiles(imageFile, videoFile);
        return res.status(400).json({ message: 'Gambar resep wajib diunggah.' });
    }

    // Validasi input dasar lainnya
    if (!userId || !categoryId || !title || !description || !estimatedTime || !price || !difficulty || !tools || !ingredients || !instructions) {
      recipeController._deleteUploadedFiles(imageFile, videoFile);
      return res.status(400).json({ message: 'Semua field resep (teks) harus diisi.' });
    }

    // Konversi estimatedTime dari string ke menit (integer)
    let cookingTimeMinutes;
    try {
        cookingTimeMinutes = parseInt(estimatedTime, 10);
        if (isNaN(cookingTimeMinutes)) {
            recipeController._deleteUploadedFiles(imageFile, videoFile);
            return res.status(400).json({ message: 'Estimasi waktu harus berupa angka (menit).' });
        }
    } catch (e) {
        console.error('Error parsing estimatedTime:', e);
        recipeController._deleteUploadedFiles(imageFile, videoFile);
        return res.status(400).json({ message: 'Terjadi kesalahan saat mengurai estimasi waktu.' });
    }

    // Konversi harga menjadi integer
    let parsedPrice;
    try {
        parsedPrice = parseInt(price, 10);
        if (isNaN(parsedPrice)) {
            recipeController._deleteUploadedFiles(imageFile, videoFile);
            return res.status(400).json({ message: 'Harga harus berupa angka.' });
        }
    } catch (e) {
        console.error('Error parsing price:', e);
        recipeController._deleteUploadedFiles(imageFile, videoFile);
        return res.status(400).json({ message: 'Terjadi kesalahan saat mengurai harga.' });
    }

    // Parse string JSON fields kembali ke objek/array JavaScript
    let parsedTools, parsedIngredients, parsedInstructions;
    try {
        parsedTools = JSON.parse(tools);
        parsedIngredients = JSON.parse(ingredients);
        parsedInstructions = JSON.parse(instructions);
    } catch (e) {
        console.error('Error parsing JSON fields (tools, ingredients, instructions):', e);
        recipeController._deleteUploadedFiles(imageFile, videoFile);
        return res.status(400).json({ message: 'Format data alat, bahan, atau instruksi tidak valid.' });
    }

    // Buat URL untuk gambar dan video yang akan disimpan di DB
    // URL ini akan relatif terhadap base URL server (misalnya: http://localhost:3000/uploads/...)
    const imageUrl = `/uploads/${imageFile.filename}`;
    const videoUrl = videoFile ? `/uploads/${videoFile.filename}` : null;

    let connection;
    try {
      connection = await pool.getConnection(); // Dapatkan koneksi dari pool
      await connection.beginTransaction(); // Mulai transaksi untuk memastikan atomicity

      // 1. Masukkan data resep utama ke tabel 'recipes'
      const [recipeResult] = await connection.query(
        'INSERT INTO recipes (user_id, category_id, title, description, cooking_time, difficulty, price, image_url, video_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [parseInt(userId), parseInt(categoryId), title, description, cookingTimeMinutes, difficulty, parsedPrice, imageUrl, videoUrl]
      );
      const recipeId = recipeResult.insertId;

      // 2. Masukkan atau dapatkan ID alat-alat dan hubungkan ke recipe_tools
      for (const toolName of parsedTools) {
        if (!toolName || typeof toolName !== 'string') continue; // Skip jika nama alat kosong atau bukan string
        let toolId;
        const [existingTool] = await connection.query('SELECT id FROM tools WHERE name = ?', [toolName]);
        if (existingTool.length > 0) {
          toolId = existingTool[0].id;
        } else {
          const [newToolResult] = await connection.query('INSERT INTO tools (name) VALUES (?)', [toolName]);
          toolId = newToolResult.insertId;
        }
        await connection.query('INSERT INTO recipe_tools (recipe_id, tool_id) VALUES (?, ?)', [recipeId, toolId]);
      }

      // 3. Masukkan atau dapatkan ID bahan-bahan dan hubungkan ke recipe_ingredients
      for (const ingredient of parsedIngredients) {
        const { quantity, unit, name } = ingredient;
        if (!name || !quantity || !unit || typeof name !== 'string' || typeof quantity !== 'string' || typeof unit !== 'string') continue;

        let ingredientId;
        const [existingIngredient] = await connection.query('SELECT id FROM ingredients WHERE name = ?', [name]);
        if (existingIngredient.length > 0) {
          ingredientId = existingIngredient[0].id;
        } else {
          // Asumsi allergy_id adalah NULL jika tidak ada info alergi dari frontend
          const [newIngredientResult] = await connection.query('INSERT INTO ingredients (name, allergy_id) VALUES (?, ?)', [name, null]);
          ingredientId = newIngredientResult.insertId;
        }
        await connection.query('INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES (?, ?, ?, ?)', [recipeId, ingredientId, quantity, unit]);
      }

      // 4. Masukkan instruksi ke tabel 'recipe_steps'
      for (let i = 0; i < parsedInstructions.length; i++) {
        if (!parsedInstructions[i] || typeof parsedInstructions[i] !== 'string') continue;
        await connection.query('INSERT INTO recipe_steps (recipe_id, step_number, description) VALUES (?, ?, ?)', [recipeId, i + 1, parsedInstructions[i]]);
      }

      await connection.commit(); // Commit transaksi jika semua berhasil
      res.status(201).json({ message: 'Resep berhasil ditambahkan!', recipeId: recipeId });

    } catch (error) {
      if (connection) {
        await connection.rollback(); // Rollback transaksi jika ada kesalahan
      }
      recipeController._deleteUploadedFiles(imageFile, videoFile); // Hapus file yang sudah diunggah jika ada kesalahan database
      console.error('Error during adding recipe:', error);
      // Teruskan error ke middleware penanganan error global
      next(error); // Penting: gunakan next(error) di sini
    } finally {
      if (connection) {
        connection.release(); // Pastikan koneksi dilepaskan kembali ke pool
      }
    }
  },

  // Fungsi untuk mendapatkan detail resep berdasarkan ID (READ)
  getRecipeById: async (req, res, next) => {
    const { id } = req.params;
    try {
      const [recipes] = await pool.query('SELECT * FROM recipes WHERE id = ?', [id]);
      if (recipes.length === 0) {
        return res.status(404).json({ message: 'Resep tidak ditemukan.' });
      }
      const recipe = recipes[0];

      // Ambil alat-alat yang terkait dengan resep
      const [tools] = await pool.query(
        'SELECT t.name FROM recipe_tools rt JOIN tools t ON rt.tool_id = t.id WHERE rt.recipe_id = ?',
        [id]
      );
      // Ambil bahan-bahan yang terkait dengan resep
      const [ingredients] = await pool.query(
        'SELECT ri.quantity, ri.unit, i.name FROM recipe_ingredients ri JOIN ingredients i ON ri.ingredient_id = i.id WHERE ri.recipe_id = ? ORDER BY i.name',
        [id]
      );
      // Ambil langkah-langkah instruksi yang terkait dengan resep
      const [steps] = await pool.query(
        'SELECT rs.step_number, rs.description FROM recipe_steps rs WHERE rs.recipe_id = ? ORDER BY rs.step_number',
        [id]
      );

      res.status(200).json({
        ...recipe,
        tools: tools.map(t => t.name), // Kembalikan hanya nama alat
        ingredients: ingredients,     // Kembalikan objek bahan lengkap
        instructions: steps.map(s => s.description) // Kembalikan hanya deskripsi langkah
      });

    } catch (error) {
      console.error('Error getting recipe by ID:', error);
      next(error); // Teruskan error ke middleware penanganan error global
    }
  },

  // Fungsi untuk memperbarui resep (UPDATE)
  updateRecipe: async (req, res, next) => {
    const { id } = req.params;
    const {
      categoryId,
      title,
      description,
      estimatedTime,
      price,
      difficulty,
      tools,
      ingredients,
      instructions,
      // Field ini menandakan apakah gambar/video lama dipertahankan/dihapus/diganti
      // 'true' jika file lama tidak berubah, 'false' jika dihapus/diganti
      // Ini dikirim oleh Flutter sebagai bagian dari FormData
      image_url_unchanged,
      video_url_unchanged
    } = req.body;

    const newImageFile = req.files && req.files['image'] ? req.files['image'][0] : null;
    const newVideoFile = req.files && req.files['video'] ? req.files['video'][0] : null;

    // Validasi gambar (wajib) - jika tidak ada gambar baru dan gambar lama dihapus
    if (!newImageFile && image_url_unchanged === 'false') {
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        return res.status(400).json({ message: 'Gambar resep wajib ada. Anda tidak bisa menghapusnya tanpa mengganti.' });
    }

    // Konversi estimatedTime dari string ke menit (integer)
    let cookingTimeMinutes; // Deklarasi variabel
        try {
            cookingTimeMinutes = parseInt(estimatedTime, 10);
            if (isNaN(cookingTimeMinutes)) {
                // HARUS menggunakan variabel yang benar: newImageFile, newVideoFile
                recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
                return res.status(400).json({ message: 'Estimasi waktu harus berupa angka (menit).' });
            }
        } catch (e) {
            console.error('Error parsing estimatedTime:', e);
            // HARUS menggunakan variabel yang benar: newImageFile, newVideoFile
            recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
            return res.status(400).json({ message: 'Terjadi kesalahan saat mengurai estimasi waktu.' });
        }

    // Konversi harga menjadi integer
    let parsedPrice;
    try {
        parsedPrice = parseInt(price, 10);
        if (isNaN(parsedPrice)) {
            recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
            return res.status(400).json({ message: 'Harga harus berupa angka.' });
        }
    } catch (e) {
        console.error('Error parsing price:', e);
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        return res.status(400).json({ message: 'Terjadi kesalahan saat mengurai harga.' });
    }

    // Parse string JSON fields kembali ke objek/array JavaScript
    let parsedTools, parsedIngredients, parsedInstructions;
    try {
        parsedTools = JSON.parse(tools);
        parsedIngredients = JSON.parse(ingredients);
        parsedInstructions = JSON.parse(instructions);
    } catch (e) {
        console.error('Error parsing JSON fields (tools, ingredients, instructions):', e);
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        return res.status(400).json({ message: 'Format data alat, bahan, atau instruksi tidak valid.' });
    }

    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();

      // Dapatkan URL gambar/video lama sebelum update
      const [oldRecipeData] = await connection.query('SELECT image_url, video_url FROM recipes WHERE id = ?', [id]);
      const oldImageUrl = oldRecipeData[0] ? oldRecipeData[0].image_url : null;
      const oldVideoUrl = oldRecipeData[0] ? oldRecipeData[0].video_url : null;

      // Tentukan URL gambar dan video baru untuk disimpan di DB
      let currentImageUrl = oldImageUrl;
      if (newImageFile) { // Jika ada gambar baru diunggah
        currentImageUrl = `/uploads/${newImageFile.filename}`;
      } else if (image_url_unchanged === 'false') { // Jika frontend secara eksplisit minta hapus gambar lama
        currentImageUrl = 'default_recipe_image.png'; // Set ke default jika dihapus tanpa pengganti
      }

      let currentVideoUrl = oldVideoUrl;
      if (newVideoFile) { // Jika ada video baru diunggah
        currentVideoUrl = `/uploads/${newVideoFile.filename}`;
      } else if (video_url_unchanged === 'false') { // Jika frontend secara eksplisit minta hapus video lama
        currentVideoUrl = null;
      }

      // 1. Perbarui data resep utama di tabel 'recipes'
      const [updateRecipeResult] = await connection.query(
        'UPDATE recipes SET category_id = ?, title = ?, description = ?, cooking_time = ?, difficulty = ?, price = ?, image_url = ?, video_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [parseInt(categoryId), title, description, cookingTimeMinutes, difficulty, parsedPrice, currentImageUrl, currentVideoUrl, id]
      );

      if (updateRecipeResult.affectedRows === 0) {
        await connection.rollback();
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile); // Hapus file baru jika update resep utama gagal
        return res.status(404).json({ message: 'Resep tidak ditemukan untuk diperbarui.' });
      }

      // Hapus file fisik lama dari server jika diganti atau dihapus
      // Hanya hapus jika ada file baru diunggah (diganti) DAN URL lama bukan default
      if (newImageFile && oldImageUrl && oldImageUrl !== 'default_recipe_image.png') {
        recipeController._deleteFileByUrl(oldImageUrl);
      }
      if (newVideoFile && oldVideoUrl) {
        recipeController._deleteFileByUrl(oldVideoUrl);
      }
      // Hapus jika frontend secara eksplisit meminta penghapusan tanpa pengganti
      if (image_url_unchanged === 'false' && !newImageFile && oldImageUrl && oldImageUrl !== 'default_recipe_image.png') {
        recipeController._deleteFileByUrl(oldImageUrl);
      }
      if (video_url_unchanged === 'false' && !newVideoFile && oldVideoUrl) {
        recipeController._deleteFileByUrl(oldVideoUrl);
      }

      // 2. Hapus alat-alat lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_tools WHERE recipe_id = ?', [id]);
      for (const toolName of parsedTools) {
        if (!toolName || typeof toolName !== 'string') continue;
        let toolId;
        const [existingTool] = await connection.query('SELECT id FROM tools WHERE name = ?', [toolName]);
        if (existingTool.length > 0) {
          toolId = existingTool[0].id;
        } else {
          const [newToolResult] = await connection.query('INSERT INTO tools (name) VALUES (?)', [toolName]);
          toolId = newToolResult.insertId;
        }
        await connection.query('INSERT INTO recipe_tools (recipe_id, tool_id) VALUES (?, ?)', [id, toolId]);
      }

      // 3. Hapus bahan-bahan lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_ingredients WHERE recipe_id = ?', [id]);
      for (const ingredient of parsedIngredients) {
        const { quantity, unit, name } = ingredient;
        if (!name || !quantity || !unit || typeof name !== 'string' || typeof quantity !== 'string' || typeof unit !== 'string') continue;

        let ingredientId;
        const [existingIngredient] = await connection.query('SELECT id FROM ingredients WHERE name = ?', [name]);
        if (existingIngredient.length > 0) {
          ingredientId = existingIngredient[0].id;
        } else {
          const [newIngredientResult] = await connection.query('INSERT INTO ingredients (name, allergy_id) VALUES (?, ?)', [name, null]);
          ingredientId = newIngredientResult.insertId;
        }
        await connection.query('INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES (?, ?, ?, ?)', [id, ingredientId, quantity, unit]);
      }

      // 4. Hapus instruksi lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_steps WHERE recipe_id = ?', [id]);
      for (let i = 0; i < parsedInstructions.length; i++) {
        if (!parsedInstructions[i] || typeof parsedInstructions[i] !== 'string') continue;
        await connection.query('INSERT INTO recipe_steps (recipe_id, step_number, description) VALUES (?, ?, ?)', [id, i + 1, parsedInstructions[i]]);
      }

      await connection.commit();
      res.status(200).json({ message: 'Resep berhasil diperbarui!' });

    } catch (error) {
      if (connection) {
        await connection.rollback();
      }
      recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
      console.error('Error during updating recipe:', error);
      next(error); // Teruskan error ke middleware penanganan error global
    } finally {
      if (connection) {
        connection.release();
      }
    }
  },

  // Fungsi untuk menghapus resep (DELETE)
  deleteRecipe: async (req, res, next) => {
    const { id } = req.params;
    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();

      // Dapatkan URL gambar/video dari resep yang akan dihapus
      const [recipeFiles] = await connection.query('SELECT image_url, video_url FROM recipes WHERE id = ?', [id]);
      const recipe = recipeFiles.length > 0 ? recipeFiles[0] : null;

      // Hapus data dari tabel terkait terlebih dahulu (karena foreign key constraints)
      await connection.query('DELETE FROM recipe_tools WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM recipe_ingredients WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM recipe_steps WHERE recipe_id = ?', [id]);
      // Juga hapus dari tabel yang memiliki FK ke recipes
      await connection.query('DELETE FROM meal_schedules WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM reviews WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM user_favorites WHERE recipe_id = ?', [id]);


      // Kemudian hapus dari tabel recipes utama
      const [deleteResult] = await connection.query('DELETE FROM recipes WHERE id = ?', [id]);

      if (deleteResult.affectedRows === 0) {
        await connection.rollback();
        return res.status(404).json({ message: 'Resep tidak ditemukan untuk dihapus.' });
      }

      await connection.commit();

      // Hapus file fisik dari server setelah berhasil dihapus dari DB
      if (recipe) {
        recipeController._deleteFileByUrl(recipe.image_url);
        recipeController._deleteFileByUrl(recipe.video_url);
      }

      res.status(204).send(); // 204 No Content untuk penghapusan berhasil

    } catch (error) {
      if (connection) {
        await connection.rollback();
      }
      console.error('Error during deleting recipe:', error);
      next(error); // Teruskan error ke middleware penanganan error global
    } finally {
      if (connection) {
        connection.release();
      }
    }
  }
};

module.exports = recipeController;