// cookingz-backend/controllers/discoveryController.js
const db = require('../db'); 

// Fungsi untuk mendapatkan resep trending
async function getTrendingRecipes() {
    try {
        const [rows] = await db.query(
            `SELECT 
                r.id, 
                r.title, 
                r.image_url, 
                u.username, 
                u.profile_picture, 
                AVG(rev.rating) as avg_rating, 
                COUNT(rev.id) as total_reviews, 
                r.description, 
                r.cooking_time,
                r.price as price, 
                r.difficulty
             FROM recipes r
             LEFT JOIN reviews rev ON r.id = rev.recipe_id
             JOIN users u ON r.user_id = u.id
             GROUP BY 
                r.id, r.title, r.image_url, u.username, u.profile_picture, 
                r.description, r.cooking_time, r.price, r.difficulty 
             ORDER BY avg_rating DESC, total_reviews DESC
             LIMIT 10`
        );
        return rows;
    } catch (error) {
        console.error('Error fetching trending recipes:', error);
        throw error; 
    }
}

// Fungsi untuk mendapatkan pengguna terbaik
async function getBestUsers() {
    try {
        const [rows] = await db.query(
            `SELECT 
                u.id, 
                u.username, 
                u.profile_picture, 
                u.cooking_level, 
                COUNT(r.id) as total_recipes
             FROM users u
             LEFT JOIN recipes r ON u.id = r.user_id
             GROUP BY u.id, u.username, u.profile_picture, u.cooking_level
             ORDER BY 
                CASE u.cooking_level 
                    WHEN 'Mahir' THEN 3 
                    WHEN 'Menengah' THEN 2
                    WHEN 'Pemula' THEN 1
                    ELSE 0 
                END DESC, 
                total_recipes DESC
             LIMIT 5`
        );
        return rows;
    } catch (error) {
        console.error('Error fetching best users:', error);
        throw error;
    }
}

// FUNGSI UNTUK MENDAPATKAN RESEP TERBARU UNTUK SEMUA PENGGUNA
async function getLatestRecipes() {
    try {
        const [rows] = await db.query(
            `SELECT 
                r.id, 
                r.title, 
                r.image_url, 
                u.username, 
                u.profile_picture, 
                r.description, 
                r.cooking_time, -- <<< CORRECTED
                r.price as price, 
                r.difficulty
             FROM recipes r
             JOIN users u ON r.user_id = u.id
             ORDER BY r.created_at DESC
             LIMIT 50`
        );
        return rows;
    } catch (error) {
        console.error('Error fetching latest recipes:', error);
        throw error;
    }
}

// FUNGSI UNTUK MENDAPATKAN RESEP PENGGUNA YANG SEDANG LOGIN
async function getUserRecipes(userId) {
    if (!userId) {
        return [];
    }
    try {
        const [rows] = await db.query(
            `SELECT 
                r.id, 
                r.title, 
                r.image_url, 
                u.username, 
                u.profile_picture, 
                r.description, 
                r.cooking_time, -- <<< CORRECTED
                r.price as price, 
                r.difficulty
             FROM recipes r
             JOIN users u ON r.user_id = u.id
             WHERE r.user_id = ?
             ORDER BY r.created_at DESC
             LIMIT 10`,
            [userId]
        );
        return rows;
    } catch (error) {
        console.error('Error fetching user recipes:', error);
        throw error;
    }
}

// FUNGSI UNTUK MENDAPATKAN KATEGORI
async function getCategories() {
    try {
        const [rows] = await db.query(
            `SELECT id, name FROM categories` 
        );
        return rows;
    } catch (error) {
        console.error('Error fetching categories:', error);
        throw error;
    }
}

// Controller untuk endpoint GET /home/:id
exports.getHomeData = async (req, res) => {
    console.log('>>> Controller getHomeData BERHASIL DICAPAI! <<<');
    
    // Mengambil ID pengguna dari parameter URL
    const userIdFromParams = parseInt(req.params.id, 10); // Pastikan dikonversi ke integer
    console.log('User ID from URL parameter:', userIdFromParams);

    // Anda mungkin masih perlu req.userId jika Anda memiliki middleware otentikasi
    // yang menambahkan ID pengguna ke req.userId.
    // Jika tidak, Anda hanya perlu menggunakan userIdFromParams.
    // Untuk tujuan ini, kita akan gunakan userIdFromParams sebagai prioritas.
    const currentUserId = userIdFromParams;

    try {
        const trendingRecipes = await getTrendingRecipes();
        console.log('Fetched trending recipes count:', trendingRecipes.length);

        const bestUsers = await getBestUsers();
        console.log('Fetched best users count:', bestUsers.length);

        const latestRecipes = await getLatestRecipes();
        console.log('Fetched latest recipes count:', latestRecipes.length);

        const categories = await getCategories();
        console.log('Fetched categories count:', categories.length);

        let userRecipes = [];
        // Menggunakan currentUserId (dari parameter URL) untuk getUserRecipes
        if (currentUserId && currentUserId !== 0) { // Pastikan ID valid dan bukan 0 (jika 0 digunakan untuk guest)
            userRecipes = await getUserRecipes(currentUserId);
            console.log('Fetched user recipes count (for userId ' + currentUserId + '):', userRecipes.length);
        } else {
            console.log('User not logged in or invalid ID. No user-specific recipes fetched.');
        }

        res.json({
            status: 'success',
            message: 'Data beranda berhasil diambil',
            data: {
                trendingRecipes,
                bestUsers,
                latestRecipes,
                userRecipes, 
                categories
            }
        });
        console.log('<<< Response for /home/:id sent successfully. >>>');
    } catch (error) {
        console.error('!!! FINAL CATCH - Error in getHomeData controller:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil data beranda. Silakan coba lagi nanti.',
            error: error.message
        });
    }
};
// --- FUNGSI BARU UNTUK API SEMUA RESEP TRENDING (GET /home/trending-recipes) ---
exports.getAllTrendingRecipes = async (req, res) => {
    console.log('>>> Controller getAllTrendingRecipes BERHASIL DICAPAI! <<<');
    try {
        const [rows] = await db.query(
            `SELECT 
                r.id, r.title, r.image_url, u.username, u.profile_picture, 
                AVG(rev.rating) as avg_rating, COUNT(rev.id) as total_reviews, 
                r.description, r.cooking_time, r.price as price, r.difficulty
             FROM recipes r
             LEFT JOIN reviews rev ON r.id = rev.recipe_id
             JOIN users u ON r.user_id = u.id
             GROUP BY 
                r.id, r.title, r.image_url, u.username, u.profile_picture, 
                r.description, r.cooking_time, r.price, r.difficulty
             ORDER BY avg_rating DESC, total_reviews DESC
             LIMIT 50` // <<< LIMIT 50 untuk halaman TrendingResep
        );
        console.log(`Fetched all trending recipes count: ${rows.length}`);
        res.json({
            status: 'success',
            message: 'Semua resep trending berhasil diambil',
            data: rows
        });
    } catch (error) {
        console.error('Error fetching all trending recipes:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil semua resep trending',
            error: error.message
        });
    }
};


// --- FUNGSI UNTUK API PENCARIAN (GET /search) ---
exports.searchRecipes = async (req, res) => {
    console.log('>>> Controller searchRecipes BERHASIL DICAPAI! <<<');
    const { 
        keyword, 
        category_name, 
        difficulty, 
        min_rating, 
        max_price,
        max_time, // Pastikan max_time juga diterima
        allergens, // Asumsi ini juga diterima
        limit = 20, 
        offset = 0 
    } = req.query; 

    // Base SELECT statement
    let selectClause = `
        SELECT
            r.id,
            r.title,
            r.description,
            r.image_url,
            u.username,
            u.profile_picture,
            AVG(rev.rating) as avg_rating,
            COUNT(rev.id) as total_reviews,
            r.cooking_time,
            r.price as price,
            r.difficulty,
            r.favorites_count as likes
        FROM recipes r
        JOIN users u ON r.user_id = u.id
        LEFT JOIN reviews rev ON r.id = rev.recipe_id
    `;

    // Initialize WHERE and HAVING conditions arrays and params
    const whereConditions = []; 
    const havingConditions = []; 
    const queryParams = []; // Changed name to avoid conflict with req.query

    // --- Conditional JOIN for categories if category_name is provided ---
    // Note: If you join categories, ensure your recipe_categories table structure is correct.
    // Assuming 'recipe_categories' is a pivot table between 'recipes' and 'categories'
    let joinCategories = '';
    if (category_name) {
        joinCategories = ` JOIN recipe_categories rc ON r.id = rc.recipe_id JOIN categories c ON rc.category_id = c.id`;
        whereConditions.push(`c.name = ?`); // Filter by category name in WHERE
        queryParams.push(category_name);
    }
    
    // --- Add WHERE conditions ---
    if (keyword) {
        whereConditions.push(`(r.title LIKE ? OR r.description LIKE ?)`);
        queryParams.push(`%${keyword}%`, `%${keyword}%`);
    }

    if (difficulty) {
        whereConditions.push(`r.difficulty = ?`);
        queryParams.push(difficulty);
    }

    if (max_price) {
        whereConditions.push(`r.price <= ?`); 
        queryParams.push(parseFloat(max_price));
    }

    if (max_time) {
        whereConditions.push(`r.cooking_time <= ?`); // Assuming column is cooking_time
        queryParams.push(parseInt(max_time));
    }

    // --- Add JOIN for allergens if allergens are provided ---
    let joinAllergens = '';
    if (allergens) {
        // Assuming allergens is a comma-separated string from frontend (e.g., "gluten,nuts")
        // and you have a recipe_allergens pivot table and allergens table
        const allergenArray = allergens.split(',');
        if (allergenArray.length > 0) {
            joinAllergens = ` LEFT JOIN recipe_allergens ra ON r.id = ra.recipe_id LEFT JOIN allergens a ON ra.allergen_id = a.id`;
            // Conditions to exclude recipes that contain any of the listed allergens
            const allergenPlaceholders = allergenArray.map(() => '?').join(', ');
            whereConditions.push(`r.id NOT IN (
                SELECT ra_inner.recipe_id
                FROM recipe_allergens ra_inner
                JOIN allergens a_inner ON ra_inner.allergen_id = a_inner.id
                WHERE a_inner.name IN (${allergenPlaceholders})
            )`);
            queryParams.push(...allergenArray);
        }
    }


    // --- Construct the main part of the query ---
    let query = selectClause;
    query += joinCategories; // Add category join
    query += joinAllergens; // Add allergen join

    if (whereConditions.length > 0) {
        query += ` WHERE ${whereConditions.join(' AND ')}`; 
    }
    
    // --- GROUP BY Clause (always comes before HAVING) ---
    query += `
        GROUP BY 
            r.id, r.title, r.description, r.image_url, u.username, u.profile_picture, 
            r.cooking_time, r.price, r.difficulty, r.favorites_count 
    `;

    // --- Add HAVING conditions ---
    // min_rating needs to be in HAVING as it aggregates AVG(rev.rating)
    if (min_rating) {
        havingConditions.push(`AVG(rev.rating) >= ?`);
        queryParams.push(parseFloat(min_rating));
    }
    if (havingConditions.length > 0) {
        query += ` HAVING ${havingConditions.join(' AND ')}`; 
    }
    
    // --- ORDER BY, LIMIT, OFFSET ---
    query += ` ORDER BY r.created_at DESC`; 

    query += ` LIMIT ? OFFSET ?`;
    queryParams.push(parseInt(limit), parseInt(offset));

    console.log('DEBUG: Search SQL Query:', query);
    console.log('DEBUG: Search Query Params:', queryParams); // Log params

    try {
        const [rows] = await db.query(query, queryParams); // Use queryParams here
        console.log('DEBUG: Search results count:', rows.length);

        // --- PENTING: KEMBALIKAN HANYA LIST RESEP DI BAWAH KUNCI 'data' ---
        res.json({
            status: 'success',
            message: 'Hasil pencarian resep berhasil diambil',
            data: rows // <<< Ini adalah kunci perbaikan untuk Type Error di frontend
        });
        console.log('<<< Response for /search sent successfully. >>>');
    } catch (error) {
        console.error('!!! FINAL CATCH - Error in searchRecipes controller:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil hasil pencarian resep',
            error: error.message
        });
    }
};