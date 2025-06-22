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
      // Pastikan 'uploads' ada di path, dan ini sesuai dengan cara Anda menyimpan file
      // path.join(__dirname, '..', url) akan menghasilkan path seperti:
      // /path/to/cookingz-backend/uploads/namafile.jpg
      const filePath = path.join(__dirname, '..', url);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`File deleted from storage: ${filePath}`);
      } else {
        console.log(`Warning: File to delete not found at path: ${filePath}`);
      }
    }
  },

  // Fungsi untuk menambah resep baru (CREATE)
  addRecipe: async (req, res, next) => {
    console.log('\n--- DEBUG: Entering addRecipe ---');
    const {
      userId,
      categoryId,
      title,
      description,
      estimatedTime,
      price,
      difficulty,
      tools,
      ingredients,
      instructions
    } = req.body;

    const imageFile = req.files && req.files['image'] ? req.files['image'][0] : null;
    const videoFile = req.files && req.files['video'] ? req.files['video'][0] : null;

    console.log('=== addRecipe Request Body ===');
    console.log(req.body);
    console.log('=== addRecipe Request Files ===');
    console.log(req.files);
    console.log('--------------------');

    console.log(`DEBUG: Received userId: ${userId} (Type: ${typeof userId})`);
    console.log(`DEBUG: Received categoryId: ${categoryId} (Type: ${typeof categoryId})`);

    // Validasi gambar (wajib)
    if (!imageFile) {
        recipeController._deleteUploadedFiles(imageFile, videoFile); // Seharusnya tidak ada file untuk dihapus di sini
        console.log('DEBUG: Validation failed - No image file uploaded.');
        return res.status(400).json({ message: 'Gambar resep wajib diunggah.' });
    }

    // Validasi input dasar lainnya
    if (!userId || !categoryId || !title || !description || !estimatedTime || !price || !difficulty || !tools || !ingredients || !instructions) {
      recipeController._deleteUploadedFiles(imageFile, videoFile);
      console.log('DEBUG: Validation failed - Missing one or more text fields.');
      console.log(`Missing fields: userId: ${!userId}, categoryId: ${!categoryId}, title: ${!title}, description: ${!description}, estimatedTime: ${!estimatedTime}, price: ${!price}, difficulty: ${!difficulty}, tools: ${!tools}, ingredients: ${!ingredients}, instructions: ${!instructions}`);
      return res.status(400).json({ message: 'Semua field resep (teks) harus diisi.' });
    }

    // Konversi estimatedTime dari string ke menit (integer)
    let cookingTimeMinutes;
    try {
        cookingTimeMinutes = parseInt(estimatedTime, 10);
        if (isNaN(cookingTimeMinutes)) {
            recipeController._deleteUploadedFiles(imageFile, videoFile);
            console.log(`DEBUG: Validation failed - estimatedTime is not a number: ${estimatedTime}`);
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
            console.log(`DEBUG: Validation failed - price is not a number: ${price}`);
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
        console.log('DEBUG: JSON fields parsed successfully.');
        console.log('DEBUG: parsedTools:', parsedTools);
        console.log('DEBUG: parsedIngredients:', parsedIngredients);
        console.log('DEBUG: parsedInstructions:', parsedInstructions);
    } catch (e) {
        console.error('Error parsing JSON fields (tools, ingredients, instructions):', e);
        recipeController._deleteUploadedFiles(imageFile, videoFile);
        return res.status(400).json({ message: 'Format data alat, bahan, atau instruksi tidak valid.' });
    }

    // Buat URL untuk gambar dan video yang akan disimpan di DB
    const imageUrl = `/uploads/${imageFile.filename}`;
    const videoUrl = videoFile ? `/uploads/${videoFile.filename}` : null;
    console.log(`DEBUG: imageUrl: ${imageUrl}, videoUrl: ${videoUrl}`);

    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();
      console.log('DEBUG: Database transaction started.');

      // Debugger: Log nilai yang akan dimasukkan ke query INSERT utama
      console.log(`DEBUG: Inserting Recipe: userId=${parseInt(userId)}, categoryId=${parseInt(categoryId)}, title=${title}, description=${description}, cookingTimeMinutes=${cookingTimeMinutes}, difficulty=${difficulty}, parsedPrice=${parsedPrice}, imageUrl=${imageUrl}, videoUrl=${videoUrl}`);

      // 1. Masukkan data resep utama ke tabel 'recipes'
      const [insertResult] = await connection.query( // <-- PERBAIKAN: Menggunakan insertResult sebagai nama variabel untuk kejelasan
        'INSERT INTO recipes (user_id, category_id, title, description, cooking_time, difficulty, price, image_url, video_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [parseInt(userId), parseInt(categoryId), title, description, cookingTimeMinutes, difficulty, parsedPrice, imageUrl, videoUrl]
      );
      // DEBUGGER SANGAT PENTING: Perhatikan struktur insertResult di konsol backend Anda
      console.log('DEBUG: Result of recipe insert query (insertResult):', insertResult);

      // Pastikan insertResult adalah objek yang memiliki properti insertId
      // MySQL2 pool.query() biasanya mengembalikan [rows, fields] atau [results, metadata]
      // Untuk INSERT, `results` adalah objek OkPacket yang berisi `insertId`.
      // Jika `insertResult` adalah array, maka `insertResult[0]` yang akan berisi `insertId`.
      // Berdasarkan konvensi mysql2, `const [insertResult]` sudah mengurai objek OkPacket.
      // Jadi, `insertResult.insertId` seharusnya sudah benar jika query berhasil.
      // Jika masih error, periksa lagi output `insertResult` di konsol backend.
      const recipeId = insertResult.insertId; // <-- BARIS KUNCI: pastikan ini adalah objek yang benar
      console.log('DEBUG: Inserted recipeId:', recipeId);

      // 2. Masukkan atau dapatkan ID alat-alat dan hubungkan ke recipe_tools
      for (const toolName of parsedTools) {
        console.log(`DEBUG: Processing tool: ${toolName}`);
        if (!toolName || typeof toolName !== 'string' || toolName.trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty toolName: ${toolName}`);
            continue;
        }
        let toolId;
        const [existingTool] = await connection.query('SELECT id FROM tools WHERE name = ?', [toolName.trim()]);
        if (existingTool.length > 0) {
          toolId = existingTool[0].id;
          console.log(`DEBUG: Found existing tool ID: ${toolId} for ${toolName}`);
        } else {
          const [newToolResult] = await connection.query('INSERT INTO tools (name) VALUES (?)', [toolName.trim()]);
          toolId = newToolResult.insertId;
          console.log(`DEBUG: Inserted new tool ID: ${toolId} for ${toolName}`);
        }
        await connection.query('INSERT INTO recipe_tools (recipe_id, tool_id) VALUES (?, ?)', [recipeId, toolId]);
        console.log(`DEBUG: Connected recipe ${recipeId} with tool ${toolId}`);
      }

      // 3. Masukkan atau dapatkan ID bahan-bahan dan hubungkan ke recipe_ingredients
      for (const ingredient of parsedIngredients) {
        const { quantity, unit, name } = ingredient;
        console.log(`DEBUG: Processing ingredient: ${name}, Qty: ${quantity}, Unit: ${unit}`);
        if (!name || !quantity || !unit || typeof name !== 'string' || typeof quantity !== 'string' || typeof unit !== 'string' || name.trim() === '' || quantity.trim() === '' || unit.trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty ingredient:`, ingredient);
            continue;
        }

        let ingredientId;
        const [existingIngredient] = await connection.query('SELECT id FROM ingredients WHERE name = ?', [name.trim()]);
        if (existingIngredient.length > 0) {
          ingredientId = existingIngredient[0].id;
          console.log(`DEBUG: Found existing ingredient ID: ${ingredientId} for ${name}`);
        } else {
          // Asumsi allergy_id adalah NULL jika tidak ada info alergi dari frontend
          const [newIngredientResult] = await connection.query('INSERT INTO ingredients (name, allergy_id) VALUES (?, ?)', [name.trim(), null]);
          ingredientId = newIngredientResult.insertId;
          console.log(`DEBUG: Inserted new ingredient ID: ${ingredientId} for ${name}`);
        }
        await connection.query('INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES (?, ?, ?, ?)', [recipeId, ingredientId, quantity.trim(), unit.trim()]);
        console.log(`DEBUG: Connected recipe ${recipeId} with ingredient ${ingredientId}`);
      }

      // 4. Masukkan instruksi ke tabel 'recipe_steps'
      for (let i = 0; i < parsedInstructions.length; i++) {
        console.log(`DEBUG: Processing instruction step ${i + 1}: ${parsedInstructions[i]}`);
        if (!parsedInstructions[i] || typeof parsedInstructions[i] !== 'string' || parsedInstructions[i].trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty instruction: ${parsedInstructions[i]}`);
            continue;
        }
        await connection.query('INSERT INTO recipe_steps (recipe_id, step_number, description) VALUES (?, ?, ?)', [recipeId, i + 1, parsedInstructions[i].trim()]);
        console.log(`DEBUG: Inserted instruction for recipe ${recipeId}, step ${i + 1}`);
      }

      await connection.commit();
      console.log('DEBUG: Database transaction committed successfully.');
      res.status(201).json({ message: 'Resep berhasil ditambahkan!', recipeId: recipeId });

    } catch (error) {
      if (connection) {
        await connection.rollback();
        console.log('DEBUG: Database transaction rolled back due to error.');
      }
      recipeController._deleteUploadedFiles(imageFile, videoFile);
      console.error('Error during adding recipe:', error); // Ini akan mencetak stack trace penuh ke konsol server
      console.log('--- DEBUG: Exiting addRecipe with error ---');
      next(error); // Teruskan error ke middleware penanganan error global di server.js
    } finally {
      if (connection) {
        connection.release();
        console.log('DEBUG: Database connection released.');
      }
    }
    console.log('--- DEBUG: Function addRecipe finished ---');
  },

  // Fungsi untuk mendapatkan detail resep berdasarkan ID (READ)
// Fungsi untuk mendapatkan detail resep berdasarkan ID (READ)
getRecipeById: async (req, res, next) => {
    const { id } = req.params;
    console.log(`\n--- DEBUG: Entering getRecipeById for ID: ${id} ---`);
    try {
        const [recipes] = await pool.query(
            `SELECT
                r.*,
                u.username,
                u.full_name,
                u.profile_picture,
                (SELECT COUNT(*) FROM recipe_favorites WHERE recipe_id = r.id) AS favorites_count,
                (SELECT COUNT(*) FROM reviews WHERE recipe_id = r.id) AS comments_count,
                (SELECT AVG(rating) FROM reviews WHERE recipe_id = r.id) AS average_rating
             FROM
                recipes r
             JOIN
                users u ON r.user_id = u.id
             WHERE
                r.id = ?`,
            [id]
        );

        console.log('DEBUG: Recipe query result:', recipes);
        if (recipes.length === 0) {
            console.log('DEBUG: Recipe not found for ID:', id);
            return res.status(404).json({ message: 'Resep tidak ditemukan.' });
        }
        const recipe = recipes[0];

        const [tools] = await pool.query(
            'SELECT t.name FROM recipe_tools rt JOIN tools t ON rt.tool_id = t.id WHERE rt.recipe_id = ?',
            [id]
        );
        console.log('DEBUG: Tools query result:', tools);

        const [ingredients] = await pool.query(
            'SELECT ri.quantity, ri.unit, i.name FROM recipe_ingredients ri JOIN ingredients i ON ri.ingredient_id = i.id WHERE ri.recipe_id = ? ORDER BY i.name',
            [id]
        );
        console.log('DEBUG: Ingredients query result:', ingredients);

        const [steps] = await pool.query(
            'SELECT rs.step_number, rs.description FROM recipe_steps rs WHERE rs.recipe_id = ? ORDER BY rs.step_number',
            [id]
        );
        console.log('DEBUG: Instructions query result:', steps);

        res.status(200).json({
            ...recipe,
            tools: tools.map(t => t.name),
            ingredients: ingredients,
            instructions: steps.map(s => s.description)
        });
        console.log('--- DEBUG: Exiting getRecipeById successfully ---');

    } catch (error) {
        console.error('Error getting recipe by ID:', error);
        console.log('--- DEBUG: Exiting getRecipeById with error ---');
        next(error);
    }
},

  // Fungsi untuk memperbarui resep (UPDATE)
  updateRecipe: async (req, res, next) => {
    const { id } = req.params;
    console.log(`\n--- DEBUG: Entering updateRecipe for ID: ${id} ---`);
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

    console.log('=== updateRecipe Request Body ===');
    console.log(req.body);
    console.log('=== updateRecipe Request Files ===');
    console.log(req.files);
    console.log('--------------------');
    console.log(`DEBUG: image_url_unchanged: ${image_url_unchanged}, video_url_unchanged: ${video_url_unchanged}`);
    console.log(`DEBUG: newImageFile exists: ${!!newImageFile}, newVideoFile exists: ${!!newVideoFile}`);


    // Validasi gambar (wajib) - jika tidak ada gambar baru dan gambar lama dihapus
    if (!newImageFile && image_url_unchanged === 'false') {
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        console.log('DEBUG: Validation failed - No new image and old image explicitly removed.');
        return res.status(400).json({ message: 'Gambar resep wajib ada. Anda tidak bisa menghapusnya tanpa mengganti.' });
    }

    // Konversi estimatedTime dari string ke menit (integer)
    let cookingTimeMinutes;
    try {
        cookingTimeMinutes = parseInt(estimatedTime, 10);
        if (isNaN(cookingTimeMinutes)) {
            recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
            console.log(`DEBUG: Validation failed - estimatedTime is not a number: ${estimatedTime}`);
            return res.status(400).json({ message: 'Estimasi waktu harus berupa angka (menit).' });
        }
    } catch (e) {
        console.error('Error parsing estimatedTime:', e);
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        return res.status(400).json({ message: 'Terjadi kesalahan saat mengurai estimasi waktu.' });
    }

    // Konversi harga menjadi integer
    let parsedPrice;
    try {
        parsedPrice = parseInt(price, 10);
        if (isNaN(parsedPrice)) {
            recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
            console.log(`DEBUG: Validation failed - price is not a number: ${price}`);
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
        console.log('DEBUG: JSON fields parsed successfully for update.');
        console.log('DEBUG: parsedTools (update):', parsedTools);
        console.log('DEBUG: parsedIngredients (update):', parsedIngredients);
        console.log('DEBUG: parsedInstructions (update):', parsedInstructions);
    } catch (e) {
        console.error('Error parsing JSON fields (tools, ingredients, instructions) for update:', e);
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        return res.status(400).json({ message: 'Format data alat, bahan, atau instruksi tidak valid.' });
    }

    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();
      console.log('DEBUG: Database transaction started for update.');

      // Dapatkan URL gambar/video lama sebelum update
      const [oldRecipeData] = await connection.query('SELECT image_url, video_url FROM recipes WHERE id = ?', [id]);
      const oldImageUrl = oldRecipeData[0] ? oldRecipeData[0].image_url : null;
      const oldVideoUrl = oldRecipeData[0] ? oldRecipeData[0].video_url : null;
      console.log(`DEBUG: Old image_url: ${oldImageUrl}, Old video_url: ${oldVideoUrl}`);

      // Tentukan URL gambar dan video baru untuk disimpan di DB
      let currentImageUrl = oldImageUrl;
      if (newImageFile) {
        currentImageUrl = `/uploads/${newImageFile.filename}`;
        console.log(`DEBUG: New image uploaded. currentImageUrl: ${currentImageUrl}`);
      } else if (image_url_unchanged === 'false') {
        currentImageUrl = 'default_recipe_image.png'; // Set ke default jika dihapus tanpa pengganti
        console.log(`DEBUG: Old image explicitly removed. currentImageUrl set to default: ${currentImageUrl}`);
      } else {
        console.log(`DEBUG: Image unchanged. currentImageUrl: ${currentImageUrl}`);
      }

      let currentVideoUrl = oldVideoUrl;
      if (newVideoFile) {
        currentVideoUrl = `/uploads/${newVideoFile.filename}`;
        console.log(`DEBUG: New video uploaded. currentVideoUrl: ${currentVideoUrl}`);
      } else if (video_url_unchanged === 'false') {
        currentVideoUrl = null;
        console.log(`DEBUG: Old video explicitly removed. currentVideoUrl set to null.`);
      } else {
        console.log(`DEBUG: Video unchanged. currentVideoUrl: ${currentVideoUrl}`);
      }

      // Debugger: Log nilai yang akan dimasukkan ke query UPDATE utama
      console.log(`DEBUG: Updating Recipe with: categoryId=${parseInt(categoryId)}, title=${title}, description=${description}, cookingTimeMinutes=${cookingTimeMinutes}, difficulty=${difficulty}, parsedPrice=${parsedPrice}, currentImageUrl=${currentImageUrl}, currentVideoUrl=${currentVideoUrl} for ID=${id}`);

      // 1. Perbarui data resep utama di tabel 'recipes'
      const [updateRecipeResult] = await connection.query(
        'UPDATE recipes SET category_id = ?, title = ?, description = ?, cooking_time = ?, difficulty = ?, price = ?, image_url = ?, video_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [parseInt(categoryId), title, description, cookingTimeMinutes, difficulty, parsedPrice, currentImageUrl, currentVideoUrl, id]
      );

      console.log('DEBUG: Result of recipe update query:', updateRecipeResult);
      if (updateRecipeResult.affectedRows === 0) {
        await connection.rollback();
        recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
        console.log('DEBUG: Update failed - Recipe not found or no changes made.');
        return res.status(404).json({ message: 'Resep tidak ditemukan untuk diperbarui.' });
      }

      // Hapus file fisik lama dari server jika diganti atau dihapus
      if (newImageFile && oldImageUrl && oldImageUrl !== 'default_recipe_image.png') {
        recipeController._deleteFileByUrl(oldImageUrl);
        console.log(`DEBUG: Old image deleted due to new upload: ${oldImageUrl}`);
      }
      if (newVideoFile && oldVideoUrl) {
        recipeController._deleteFileByUrl(oldVideoUrl);
        console.log(`DEBUG: Old video deleted due to new upload: ${oldVideoUrl}`);
      }
      if (image_url_unchanged === 'false' && !newImageFile && oldImageUrl && oldImageUrl !== 'default_recipe_image.png') {
        recipeController._deleteFileByUrl(oldImageUrl);
        console.log(`DEBUG: Old image deleted as requested by frontend: ${oldImageUrl}`);
      }
      if (video_url_unchanged === 'false' && !newVideoFile && oldVideoUrl) {
        recipeController._deleteFileByUrl(oldVideoUrl);
        console.log(`DEBUG: Old video deleted as requested by frontend: ${oldVideoUrl}`);
      }

      // 2. Hapus alat-alat lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_tools WHERE recipe_id = ?', [id]);
      console.log(`DEBUG: Deleted old tools for recipe ID: ${id}`);
      for (const toolName of parsedTools) {
        if (!toolName || typeof toolName !== 'string' || toolName.trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty toolName during update: ${toolName}`);
            continue;
        }
        let toolId;
        const [existingTool] = await connection.query('SELECT id FROM tools WHERE name = ?', [toolName.trim()]);
        if (existingTool.length > 0) {
          toolId = existingTool[0].id;
        } else {
          const [newToolResult] = await connection.query('INSERT INTO tools (name) VALUES (?)', [toolName.trim()]);
          toolId = newToolResult.insertId;
        }
        await connection.query('INSERT INTO recipe_tools (recipe_id, tool_id) VALUES (?, ?)', [id, toolId]);
        console.log(`DEBUG: Re-inserted tool ID: ${toolId} for recipe ${id}`);
      }

      // 3. Hapus bahan-bahan lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_ingredients WHERE recipe_id = ?', [id]);
      console.log(`DEBUG: Deleted old ingredients for recipe ID: ${id}`);
      for (const ingredient of parsedIngredients) {
        const { quantity, unit, name } = ingredient;
        if (!name || !quantity || !unit || typeof name !== 'string' || typeof quantity !== 'string' || typeof unit !== 'string' || name.trim() === '' || quantity.trim() === '' || unit.trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty ingredient during update:`, ingredient);
            continue;
        }

        let ingredientId;
        const [existingIngredient] = await connection.query('SELECT id FROM ingredients WHERE name = ?', [name.trim()]);
        if (existingIngredient.length > 0) {
          ingredientId = existingIngredient[0].id;
        } else {
          const [newIngredientResult] = await connection.query('INSERT INTO ingredients (name, allergy_id) VALUES (?, ?)', [name.trim(), null]);
          ingredientId = newIngredientResult.insertId;
        }
        await connection.query('INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES (?, ?, ?, ?)', [id, ingredientId, quantity.trim(), unit.trim()]);
        console.log(`DEBUG: Re-inserted ingredient ID: ${ingredientId} for recipe ${id}`);
      }

      // 4. Hapus instruksi lama dan masukkan yang baru
      await connection.query('DELETE FROM recipe_steps WHERE recipe_id = ?', [id]);
      console.log(`DEBUG: Deleted old instructions for recipe ID: ${id}`);
      for (let i = 0; i < parsedInstructions.length; i++) {
        if (!parsedInstructions[i] || typeof parsedInstructions[i] !== 'string' || parsedInstructions[i].trim() === '') {
            console.log(`DEBUG: Skipping invalid/empty instruction during update: ${parsedInstructions[i]}`);
            continue;
        }
        await connection.query('INSERT INTO recipe_steps (recipe_id, step_number, description) VALUES (?, ?, ?)', [id, i + 1, parsedInstructions[i].trim()]);
        console.log(`DEBUG: Re-inserted instruction step ${i + 1} for recipe ${id}`);
      }

      await connection.commit();
      console.log('DEBUG: Database transaction committed successfully for update.');
      res.status(200).json({ message: 'Resep berhasil diperbarui!' });

    } catch (error) {
      if (connection) {
        await connection.rollback();
        console.log('DEBUG: Database transaction rolled back for update due to error.');
      }
      recipeController._deleteUploadedFiles(newImageFile, newVideoFile);
      console.error('Error during updating recipe:', error);
      console.log('--- DEBUG: Exiting updateRecipe with error ---');
      next(error);
    } finally {
      if (connection) {
        connection.release();
        console.log('DEBUG: Database connection released for update.');
      }
    }
    console.log('--- DEBUG: Function updateRecipe finished ---');
  },

    // Fungsi untuk mendapatkan semua resep dengan sorting (READ ALL)
    getAllRecipes: async (req, res, next) => {
        console.log('\n--- DEBUG: Entering getAllRecipes ---');
        // Ambil parameter sort dari query string, defaultnya 'newest'
        const { sort = 'newest' } = req.query;
        console.log(`DEBUG: Sorting parameter: ${sort}`);

        let orderByClause = '';

        // Tentukan klausa ORDER BY berdasarkan parameter sort
        switch (sort) {
            case 'trending':
                // Logika trending bisa lebih kompleks, misalnya berdasarkan likes dalam 7 hari terakhir.
                // Untuk sekarang, kita urutkan berdasarkan jumlah favorit terbanyak.
                orderByClause = 'ORDER BY favorites_count DESC';
                break;
            case 'oldest':
                orderByClause = 'ORDER BY r.created_at ASC';
                break;
            case 'newest':
            default:
                orderByClause = 'ORDER BY r.created_at DESC';
                break;
        }
        console.log(`DEBUG: Using ORDER BY clause: ${orderByClause}`);

        try {
            const query = `
                SELECT
                    r.id,
                    r.title,
                    r.description,
                    r.image_url,
                    r.created_at,
                    u.username,
                    u.profile_picture,
                    (SELECT COUNT(*) FROM recipe_favorites WHERE recipe_id = r.id) AS favorites_count,
                    (SELECT COUNT(*) FROM reviews WHERE recipe_id = r.id) AS comments_count
                FROM
                    recipes r
                JOIN
                    users u ON r.user_id = u.id
                ${orderByClause}
            `;

            const [recipes] = await pool.query(query);

            console.log(`DEBUG: Found ${recipes.length} recipes.`);
            res.status(200).json(recipes);
            console.log('--- DEBUG: Exiting getAllRecipes successfully ---');

        } catch (error) {
            console.error('Error getting all recipes:', error);
            console.log('--- DEBUG: Exiting getAllRecipes with error ---');
            next(error);
        }
    },


  // Fungsi untuk menghapus resep (DELETE)
  deleteRecipe: async (req, res, next) => {
    const { id } = req.params;
    console.log(`\n--- DEBUG: Entering deleteRecipe for ID: ${id} ---`);
    let connection;
    try {
      connection = await pool.getConnection();
      await connection.beginTransaction();
      console.log('DEBUG: Database transaction started for delete.');

      const [recipeFiles] = await connection.query('SELECT image_url, video_url FROM recipes WHERE id = ?', [id]);
      const recipe = recipeFiles.length > 0 ? recipeFiles[0] : null;
      console.log('DEBUG: Recipe files to delete:', recipe);

      await connection.query('DELETE FROM recipe_tools WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM recipe_ingredients WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM recipe_steps WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM meal_schedules WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM reviews WHERE recipe_id = ?', [id]);
      await connection.query('DELETE FROM recipe_favorites WHERE recipe_id = ?', [id]);
      console.log(`DEBUG: Related data for recipe ID ${id} deleted.`);

      const [deleteResult] = await connection.query('DELETE FROM recipes WHERE id = ?', [id]);
      console.log('DEBUG: Result of main recipe delete query:', deleteResult);

      if (deleteResult.affectedRows === 0) {
        await connection.rollback();
        console.log('DEBUG: Delete failed - Recipe not found.');
        return res.status(404).json({ message: 'Resep tidak ditemukan untuk dihapus.' });
      }

      await connection.commit();
      console.log('DEBUG: Database transaction committed successfully for delete.');

      if (recipe) {
        recipeController._deleteFileByUrl(recipe.image_url);
        recipeController._deleteFileByUrl(recipe.video_url);
        console.log('DEBUG: Physical files deleted from storage.');
      }

      res.status(204).send(); // 204 No Content untuk penghapusan berhasil
      console.log('--- DEBUG: Exiting deleteRecipe successfully ---');

    } catch (error) {
      if (connection) {
        await connection.rollback();
        console.log('DEBUG: Database transaction rolled back for delete due to error.');
      }
      console.error('Error during deleting recipe:', error);
      console.log('--- DEBUG: Exiting deleteRecipe with error ---');
      next(error);
    } finally {
      if (connection) {
        connection.release();
        console.log('DEBUG: Database connection released for delete.');
      }
    }
  }
};

module.exports = recipeController;