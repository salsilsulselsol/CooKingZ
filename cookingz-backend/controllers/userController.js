// File: cookingz-backend/controllers/userController.js

const db = require('../db');

// Fungsi untuk mendapatkan profil pengguna yang sedang login ('me')
exports.getMyProfile = async (req, res) => {
    // ID pengguna didapatkan dari middleware otentikasi JWT
    const userId = req.user.userId; 
    console.log(`>>> Controller getMyProfile BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);

    if (!userId) { // Seharusnya tidak terjadi jika authenticateToken berfungsi
        return res.status(401).json({ status: 'error', message: 'Akses ditolak. Tidak ada pengguna yang terautentikasi.' });
    }

    try {
        // 1. Ambil data dasar pengguna dari tabel 'users'
        const userQuery = 'SELECT id, username, full_name, email, cooking_level, bio, profile_picture FROM users WHERE id = ?';
        const [users] = await db.query(userQuery, [userId]);

        if (users.length === 0) {
            console.log(`Pengguna ID ${userId} tidak ditemukan untuk getMyProfile.`);
            return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan.' });
        }

        const userProfile = users[0];

        // 2. Hitung jumlah resep yang dimiliki pengguna
        const recipesCountQuery = 'SELECT COUNT(*) as recipe_count FROM recipes WHERE user_id = ?';
        const [recipeResult] = await db.query(recipesCountQuery, [userId]);
        userProfile.recipe_count = recipeResult[0].recipe_count;

        // 3. Hitung jumlah pengikut (followers)
        const followersCountQuery = 'SELECT COUNT(*) as followers_count FROM user_followers WHERE following_id = ?';
        const [followersResult] = await db.query(followersCountQuery, [userId]);
        userProfile.followers_count = followersResult[0].followers_count;

        // 4. Hitung jumlah yang diikuti (following)
        const followingCountQuery = 'SELECT COUNT(*) as following_count FROM user_followers WHERE follower_id = ?';
        const [followingResult] = await db.query(followingCountQuery, [userId]);
        userProfile.following_count = followingResult[0].following_count;
        
        console.log(`Profil untuk user ID ${userId} berhasil diambil.`);
        res.status(200).json({ status: 'success', message: 'Profil pengguna berhasil diambil.', data: userProfile });

    } catch (error) {
        console.error('Error saat mengambil profil (getMyProfile):', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mengambil profil.', error: error.message });
    }
};

// Fungsi BARU untuk mendapatkan semua resep milik seorang pengguna
exports.getUserRecipes = async (req, res) => {
    try {
        const userId = req.params.id;
        console.log(`>>> Controller getUserRecipes (PERBAIKAN) BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);

        // QUERY PERBAIKAN: Memastikan alias konsisten dengan food_model.dart (avg_rating, total_reviews)
        const query = `
            SELECT
                r.id,
                r.title,
                r.description,
                r.image_url,
                r.cooking_time,
                r.difficulty,
                r.price,
                COALESCE(r.favorites_count, 0) AS total_reviews,
                COALESCE(AVG(rev.rating), 0) AS avg_rating
            FROM
                recipes AS r
            LEFT JOIN
                reviews AS rev ON r.id = rev.recipe_id
            WHERE
                r.user_id = ?
            GROUP BY
                r.id
            ORDER BY
                r.created_at DESC;
        `;

        const [recipes] = await db.query(query, [userId]);
        
        console.log(`Resep untuk user ID ${userId} berhasil diambil. Jumlah: ${recipes.length}`);
        res.status(200).json({ status: 'success', message: 'Resep pengguna berhasil diambil.', data: recipes });

    } catch (error) {
        console.error('Error saat mengambil resep pengguna (PERBAIKAN):', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mengambil resep.', error: error.message });
    }
};

// Fungsi untuk mendapatkan resep favorit pengguna yang sedang login
exports.getMyFavoriteRecipes = async (req, res) => {
    const userId = req.user.userId;
    console.log(`>>> Controller getMyFavoriteRecipes (PERBAIKAN) BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);

    try {
        // QUERY PERBAIKAN: Mengambil data rating dan likes dengan benar, tidak di-hardcode.
        const query = `
            SELECT 
                r.id, 
                r.title, 
                r.description, 
                r.image_url, 
                r.cooking_time,
                r.difficulty,
                r.price,
                COALESCE(r.favorites_count, 0) AS total_reviews,
                COALESCE(AVG(rev.rating), 0) AS avg_rating
            FROM recipes AS r
            INNER JOIN recipe_favorites AS rf ON r.id = rf.recipe_id
            LEFT JOIN reviews AS rev ON r.id = rev.recipe_id
            WHERE rf.user_id = ?
            GROUP BY r.id
            ORDER BY rf.created_at DESC
        `;

        const [recipes] = await db.query(query, [userId]);
        
        console.log(`Resep favorit untuk user ID ${userId} berhasil diambil. Jumlah: ${recipes.length}`);
        res.status(200).json({ status: 'success', message: 'Resep favorit berhasil diambil.', data: recipes });

    } catch (error) {
        console.error('Error saat mengambil resep favorit (PERBAIKAN):', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mengambil resep favorit.', error: error.message });
    }
};

// Fungsi untuk mendapatkan profil pengguna berdasarkan ID (profil publik)
exports.getUserById = async (req, res) => {
    try {
        const userId = req.params.id; // ID profil yang sedang dilihat dari URL
        console.log(`>>> Controller getUserById BERHASIL DICAPAI! untuk user_id: ${userId} <<<`);

        const userQuery = 'SELECT id, username, full_name, email, cooking_level, bio, profile_picture FROM users WHERE id = ?';
        const [users] = await db.query(userQuery, [userId]);

        if (users.length === 0) {
            console.log(`Pengguna ID ${userId} tidak ditemukan untuk getUserById.`);
            return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan.' });
        }

        const userProfile = users[0];

        const recipesCountQuery = 'SELECT COUNT(*) as recipe_count FROM recipes WHERE user_id = ?';
        const [recipeResult] = await db.query(recipesCountQuery, [userId]);
        userProfile.recipe_count = recipeResult[0].recipe_count;

        const followersCountQuery = 'SELECT COUNT(*) as followers_count FROM user_followers WHERE following_id = ?';
        const [followersResult] = await db.query(followersCountQuery, [userId]);
        userProfile.followers_count = followersResult[0].followers_count;

        const followingCountQuery = 'SELECT COUNT(*) as following_count FROM user_followers WHERE follower_id = ?';
        const [followingResult] = await db.query(followingCountQuery, [userId]);
        userProfile.following_count = followingResult[0].following_count;
        
        console.log(`Profil publik user ID ${userId} berhasil diambil.`);
        res.status(200).json({ status: 'success', message: 'Profil pengguna berhasil diambil.', data: userProfile });

    } catch (error) {
        console.error(`Error saat mengambil profil untuk ID ${req.params.id} (getUserById):`, error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server saat mengambil profil.', error: error.message });
    }
};

// Fungsi untuk memperbarui profil pengguna yang sedang login
exports.updateMyProfile = async (req, res) => {
  const userId = req.user.userId;
  const { fullName, username, bio } = req.body;
  const fieldsToUpdate = {};

  console.log('[DEBUG-BACKEND] Menerima permintaan update untuk user ID:', userId);
  console.log('[DEBUG-BACKEND] Data yang diterima (body):', req.body);
  console.log('[DEBUG-BACKEND] File yang diterima:', req.file ? req.file.filename : 'Tidak ada file');

  if (fullName !== undefined) fieldsToUpdate.full_name = fullName;
  if (username !== undefined) fieldsToUpdate.username = username;
  if (bio !== undefined) fieldsToUpdate.bio = bio;

  if (req.file) {
    fieldsToUpdate.profile_picture = `/uploads/${req.file.filename}`;
  }

  if (Object.keys(fieldsToUpdate).length === 0) {
    console.log('[DEBUG-BACKEND] Tidak ada data untuk diupdate. Mengirim error 400.');
    return res.status(400).json({ status: 'error', message: 'Tidak ada data untuk diperbarui.' });
  }

  const setClause = Object.keys(fieldsToUpdate).map(key => `${key} = ?`).join(', ');
  const values = [...Object.values(fieldsToUpdate), userId];
  const query = `UPDATE users SET ${setClause} WHERE id = ?`;

  // --- Log untuk Query SQL ---
  console.log('=====================================================');
  console.log('[DEBUG-BACKEND] Query yang akan dieksekusi:', query);
  console.log('[DEBUG-BACKEND] Dengan nilai:', values);
  console.log('=====================================================');

  try {
    const [result] = await db.query(query, values);

    console.log('[DEBUG-BACKEND] Hasil dari database:', result);

    if (result.affectedRows === 0) {
      console.log('[DEBUG-BACKEND] Gagal: Tidak ada baris yang berubah. User ID mungkin tidak ditemukan.');
      return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan, update gagal.' });
    }
    
    console.log(`[DEBUG-BACKEND] Sukses: Profil user ID ${userId} berhasil diperbarui.`);
    
    // Ambil data terbaru untuk dikirim kembali
    const [updatedUsers] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    res.status(200).json({ 
      status: 'success', 
      message: 'Profil berhasil diperbarui!',
      data: updatedUsers[0]
    });

  } catch (error) {
    console.error('[DEBUG-BACKEND] Terjadi ERROR saat query database:', error);
    res.status(500).json({ 
        status: 'error', 
        message: 'Terjadi kesalahan pada server saat update profil.', 
        error: error.message 
    });
  }
};

// Fungsi untuk mengambil daftar FOLLOWING (yang di-follow oleh user :id)
exports.getFollowingList = async (req, res) => {
    try {
        const profileUserId = req.params.id; // ID profil yang sedang dilihat
        // PERBAIKAN: Cek dulu apakah req.user ada sebelum mengakses .userId
        const loggedInUserId = req.user ? req.user.userId : null;

        const query = `
            SELECT 
                u.id, u.username, u.full_name, u.profile_picture,
                CASE WHEN EXISTS (
                    SELECT 1 FROM user_followers 
                    WHERE follower_id = ? AND following_id = u.id
                ) THEN 1 ELSE 0 END AS isFollowedByMe
            FROM users u
            JOIN user_followers uf ON u.id = uf.following_id
            WHERE uf.follower_id = ?
        `;
        // Gunakan loggedInUserId (yang bisa null) dengan aman
        const [following] = await db.query(query, [loggedInUserId || 0, profileUserId]); 
        
        console.log(`Daftar following untuk user ID ${profileUserId} berhasil diambil. Jumlah: ${following.length}`);
        res.status(200).json({ status: 'success', message: 'Daftar diikuti berhasil diambil.', data: following });
    } catch (error) {
        console.error('Error saat mengambil daftar following:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server.', error: error.message });
    }
};

// Fungsi untuk mengambil daftar FOLLOWERS dari user :id
exports.getFollowersList = async (req, res) => {
    try {
        const profileUserId = req.params.id; // ID profil yang sedang dilihat
        // PERBAIKAN: Cek dulu apakah req.user ada sebelum mengakses .userId
        const loggedInUserId = req.user ? req.user.userId : null;

        const query = `
            SELECT 
                u.id, u.username, u.full_name, u.profile_picture,
                CASE WHEN EXISTS (
                    SELECT 1 FROM user_followers 
                    WHERE follower_id = ? AND following_id = u.id
                ) THEN 1 ELSE 0 END AS isFollowedByMe
            FROM users u
            JOIN user_followers uf ON u.id = uf.follower_id
            WHERE uf.following_id = ?
        `;
        // Gunakan loggedInUserId (yang bisa null) dengan aman
        const [followers] = await db.query(query, [loggedInUserId || 0, profileUserId]); 

        console.log(`Daftar followers untuk user ID ${profileUserId} berhasil diambil. Jumlah: ${followers.length}`);
        res.status(200).json({ status: 'success', message: 'Daftar pengikut berhasil diambil.', data: followers });
    } catch (error) {
        console.error('Error saat mengambil daftar followers:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server.', error: error.message });
    }
};

// Fungsi untuk follow seorang pengguna
exports.followUser = async (req, res) => {
    const loggedInUserId = req.user.userId; // ID pengguna yang login dari token
    const userToFollowId = parseInt(req.params.id); // ID pengguna yang akan di-follow

    if (!loggedInUserId) {
        return res.status(401).json({ status: 'error', message: 'Anda harus login untuk mengikuti pengguna.' });
    }

    if (loggedInUserId === userToFollowId) {
        return res.status(400).json({ status: 'error', message: 'Anda tidak bisa mengikuti diri sendiri.' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO user_followers (follower_id, following_id) VALUES (?, ?)',
            [loggedInUserId, userToFollowId]
        );
        console.log(`User ${loggedInUserId} sekarang mengikuti user ${userToFollowId}.`);
        res.status(200).json({ status: 'success', message: `Anda sekarang mengikuti pengguna dengan ID ${userToFollowId}` });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ status: 'error', message: 'Anda sudah mengikuti pengguna ini.' });
        }
        console.error('Error saat follow user:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server.', error: error.message });
    }
};

// Fungsi untuk unfollow seorang pengguna
exports.unfollowUser = async (req, res) => {
    const loggedInUserId = req.user.userId; // ID pengguna yang login dari token
    const userToUnfollowId = parseInt(req.params.id); // ID pengguna yang akan di-unfollow

    if (!loggedInUserId) {
        return res.status(401).json({ status: 'error', message: 'Anda harus login untuk berhenti mengikuti pengguna.' });
    }

    try {
        const [result] = await db.query(
            'DELETE FROM user_followers WHERE follower_id = ? AND following_id = ?',
            [loggedInUserId, userToUnfollowId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ status: 'error', message: 'Anda tidak sedang mengikuti pengguna ini, tidak ada yang di-unfollow.' });
        }
        console.log(`User ${loggedInUserId} berhenti mengikuti user ${userToUnfollowId}.`);
        res.status(200).json({ status: 'success', message: `Anda berhenti mengikuti pengguna dengan ID ${userToUnfollowId}` });
    } catch (error) {
        console.error('Error saat unfollow user:', error);
        res.status(500).json({ status: 'error', message: 'Terjadi kesalahan pada server.', error: error.message });
    }
};

// Fungsi untuk menghapus pengguna
exports.deleteUser = async (req, res) => {
    const userIdToDelete = parseInt(req.params.id); // ID user dari URL
    const authenticatedUserId = req.user.userId; // ID user dari token JWT

    console.log(`>>> Controller deleteUser BERHASIL DICAPAI! Menghapus ID: ${userIdToDelete}, oleh User ID: ${authenticatedUserId} <<<`);

    if (!authenticatedUserId) {
        return res.status(401).json({ status: 'error', message: 'Akses ditolak. Tidak ada pengguna yang terautentikasi.' });
    }

    // Pastikan user hanya bisa menghapus akunnya sendiri
    if (userIdToDelete !== authenticatedUserId) {
        console.warn(`User ${authenticatedUserId} mencoba menghapus akun user ${userIdToDelete} tanpa izin.`);
        return res.status(403).json({ status: 'error', message: 'Anda tidak memiliki izin untuk menghapus akun ini.' });
    }

    try {
        // Karena ada Foreign Key, penghapusan akan cascade jika FK diatur ON DELETE CASCADE
        // Jika tidak, Anda perlu menghapus entri terkait di tabel lain terlebih dahulu (misal: user_allergies, user_followers, dll.)
        const [result] = await db.query(
            `DELETE FROM users WHERE id = ?`,
            [userIdToDelete]
        );

        if (result.affectedRows === 0) {
            console.log(`User ${userIdToDelete} tidak ditemukan untuk dihapus.`);
            return res.status(404).json({ status: 'error', message: 'Akun tidak ditemukan.' });
        }
        
        console.log(`Akun user ID ${userIdToDelete} berhasil dihapus.`);
        res.json({
            status: 'success',
            message: 'Akun berhasil dihapus.'
        });
    } catch (error) {
        console.error('Error in deleteUser:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal menghapus akun.',
            error: error.message
        });
    }
};
// --- FUNGSI BARU UNTUK MENDAPATKAN SEMUA PENGGUNA TERBARU ---
exports.getAllLatestUsers = async (req, res) => {
    console.log('>>> Controller getAllLatestUsers BERHASIL DICAPAI! <<<');
    try {
        const [rows] = await db.query(
            `SELECT 
                id, username, full_name, email, cooking_level, bio, profile_picture, created_at
             FROM users
             ORDER BY created_at DESC
             LIMIT 50` // Batasi 50 pengguna terbaru seperti permintaan
        );
        console.log(`Fetched all latest users count: ${rows.length}`);
        res.json({
            status: 'success',
            message: 'Semua pengguna terbaru berhasil diambil',
            data: rows
        });
    } catch (error) {
        console.error('Error fetching all latest users:', error);
        res.status(500).json({
            status: 'error',
            message: 'Gagal mengambil semua pengguna terbaru',
            error: error.message
        });
    }
};

// Fungsi untuk mendapatkan pengguna terbaik berdasarkan rating
exports.getBestUsers = async (req, res) => {
  console.log('>>> Controller getBestUsers BERHASIL DICAPAI! <<<');

  try {
    const query = `
      SELECT
        u.id,
        u.username,
        u.full_name,
        u.email,
        u.cooking_level,
        u.bio,
        u.profile_picture,
        u.created_at,
        COALESCE(AVG(rv.rating), 0) AS average_rating,
        COUNT(r.id) AS recipe_count
      FROM users u
      LEFT JOIN recipes r ON u.id = r.user_id
      LEFT JOIN reviews rv ON r.id = rv.recipe_id
      GROUP BY u.id
      HAVING COUNT(r.id) > 0
      ORDER BY average_rating DESC, recipe_count DESC
      LIMIT 10
    `;

    const [bestUsers] = await db.query(query);

    console.log(`Fetched best users count: ${bestUsers.length}`);
    res.status(200).json({
      status: 'success',
      message: 'Pengguna terbaik berhasil diambil',
      data: bestUsers
    });
  } catch (error) {
    console.error('Error fetching best users:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil pengguna terbaik',
      error: error.message
    });
  }
};