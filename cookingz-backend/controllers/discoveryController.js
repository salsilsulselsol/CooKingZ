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

// Controller untuk endpoint GET /home
exports.getHomeData = async (req, res) => {
    console.log('>>> Controller getHomeData BERHASIL DICAPAI! <<<');
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
        if (req.userId) { 
            userRecipes = await getUserRecipes(req.userId);
            console.log('Fetched user recipes count (for userId ' + req.userId + '):', userRecipes.length);
        } else {
            console.log('User not logged in. No user-specific recipes fetched.');
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
        console.log('<<< Response for /home sent successfully. >>>');
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
        limit = 20, 
        offset = 0  
    } = req.query; 

    let query = `
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
    const conditions = [];
    const params = [];

    if (keyword) {
        conditions.push(`(r.title LIKE ? OR r.description LIKE ?)`);
        params.push(`%${keyword}%`, `%${keyword}%`);
    }

    if (category_name) { 
        conditions.push(`c.name = ?`); 
        params.push(category_name);
    }

    if (difficulty) {
        conditions.push(`r.difficulty = ?`);
        params.push(difficulty);
    }

    if (min_rating) {
        conditions.push(`AVG(rev.rating) >= ?`);
        params.push(parseFloat(min_rating));
    }

    if (max_price) {
        conditions.push(`r.price <= ?`); 
        params.push(parseFloat(max_price));
    }

    query += `
        GROUP BY 
            r.id, r.title, r.description, r.image_url, u.username, u.profile_picture, 
            r.cooking_time, r.price, r.difficulty, r.favorites_count 
    `;

    if (conditions.length > 0) {
        query += ` HAVING ${conditions.join(' AND ')}`; 
    }
    
    query += ` ORDER BY r.created_at DESC`; 

    query += ` LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));

    console.log('DEBUG: Search SQL Query:', query);
    console.log('DEBUG: Search Query Params:', params);

    try {
        const [rows] = await db.query(query, params);
        console.log('DEBUG: Search results count:', rows.length);

        res.json({
            status: 'success',
            message: 'Hasil pencarian resep berhasil diambil',
            data: rows
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