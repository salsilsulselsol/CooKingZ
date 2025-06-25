# CooKingZ - Aplikasi Resep berbasis Flutter

## Provis Tugas 4: Implementasi Backend dengan RESTful API

### Kelompok 25 - Kelas C1 2023
- Faisal Nur Qolbi (2311399)
- Muhammad Farhan (2309323)
- Muhammad Helmi Rahmadi (2311574)
- Sifa Imania Nurul Hidayah (2312084)
- Yazid Madarizel (2305328)

---

## 📱 Tentang Proyek
CooKingZ adalah aplikasi resep masakan berbahasa Indonesia yang dikembangkan menggunakan **Flutter** untuk frontend dan **RESTful API** untuk backend. Aplikasi ini memungkinkan pengguna untuk menjelajahi berbagai resep masakan, menyimpan resep favorit, berbagi resep, dan berinteraksi dengan komunitas pecinta masakan.

---

## ✨ Fitur Utama

### 🎯 **Autentikasi & Onboarding**
- Splash screen dan introduction
- Sistem login dan registrasi
- Kustomisasi preferensi masakan dan alergi
- Forgot password functionality

### 🏠 **Home & Discovery**
- Tampilan resep trending dan populer
- Kategori masakan (Sarapan, Makan Siang, Makan Malam, Vegan, dll)
- Sistem notifikasi dan penjadwalan
- Feed resep terpersonalisasi

### 🔍 **Pencarian & Filtrasi**
- Pencarian resep berdasarkan nama, bahan, atau kategori
- Filter advanced berdasarkan:
  - Waktu persiapan dan memasak
  - Tingkat kesulitan
  - Jenis diet (vegetarian, vegan, gluten-free)
  - Rating dan popularitas

### 📖 **Detail Resep**
- Informasi lengkap bahan dan langkah memasak
- Video tutorial dan gambar step-by-step
- Estimasi durasi dan tingkat kesulitan
- Informasi nutrisi dan kalori
- Sistem rating dan review

### 👥 **Komunitas & Sosial**
- Forum diskusi antar pengguna
- Berbagi dan review resep pribadi
- Sistem follow dan followers
- Komentar dan interaksi real-time

### 👤 **Profil & Personalisasi**
- Manajemen profil pengguna
- Koleksi resep favorit dan tersimpan
- Resep yang dibuat sendiri
- Pengaturan preferensi dan notifikasi

---

## 🛠 Teknologi yang Digunakan

### **Frontend (Mobile)**
- **Flutter** - Framework UI cross-platform
- **Dart** - Bahasa pemrograman
- **Provider/Riverpod** - State management
- **Dio** - HTTP client untuk API calls
- **Shared Preferences** - Local storage
- **Image Picker** - Upload gambar
- **Video Player** - Memutar video tutorial

### **Backend (API)**
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB/PostgreSQL** - Database
- **JWT** - Authentication
- **Multer** - File upload handling

---

## 🚀 Cara Menjalankan Aplikasi

### **Prerequisites**
- Flutter SDK (3.19.0+)
- Dart SDK (3.0.0+)
- Node.js (18.0+)
- MongoDB/PostgreSQL
- Android Studio/Xcode untuk emulator

### **Setup Backend**
```bash
# Clone repository
git clone [repository-url]
cd coo-kingz-backend

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env dengan konfigurasi database dan API keys

# Jalankan server
npm run dev
```

### **Setup Frontend**
```bash
# Masuk ke folder flutter
cd coo-kingz-flutter

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### **Environment Variables (Backend)**
```env
PORT=3000
DATABASE_URL=your_database_connection_string
JWT_SECRET=your_jwt_secret
```

---

## 📁 Struktur Proyek

```
CooKingZ/
├── backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── utils/
│   └── server.js
├── mobile/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   ├── providers/
│   │   └── utils/
│   ├── assets/
│   └── pubspec.yaml
└── README.md
```

---

## 🔌 API Endpoints

### **Authentication**
- `POST /api/auth/register` - Registrasi pengguna baru
- `POST /api/auth/login` - Login pengguna
- `POST /api/auth/forgot-password` - Reset password
- `GET /api/auth/profile` - Get user profile

### **Recipes**
- `GET /api/recipes` - Get semua resep dengan pagination
- `GET /api/recipes/:id` - Get detail resep
- `POST /api/recipes` - Buat resep baru
- `PUT /api/recipes/:id` - Update resep
- `DELETE /api/recipes/:id` - Hapus resep

### **Search & Filter**
- `GET /api/recipes/search` - Pencarian resep
- `GET /api/recipes/filter` - Filter resep berdasarkan kategori
- `GET /api/categories` - Get semua kategori

### **Social Features**
- `POST /api/recipes/:id/like` - Like/unlike resep
- `POST /api/recipes/:id/comments` - Tambah komentar
- `GET /api/recipes/:id/comments` - Get komentar resep
- `POST /api/users/:id/follow` - Follow/unfollow user

---

## 🎨 Screenshots & Demo

### Menu Navigasi Utama
Aplikasi menyediakan menu utama untuk memudahkan navigasi ke berbagai fitur:

1. **Onboarding Screens** - Pengenalan aplikasi
2. **Authentication** - Login dan registrasi
3. **Home Page** - Dashboard utama
4. **Recipe Discovery** - Jelajahi resep
5. **Recipe Detail** - Detail lengkap resep
6. **User Profile** - Profil dan pengaturan
7. **Community** - Forum dan interaksi sosial

---

## 📋 Persyaratan Sistem

### **Mobile**
- **Android**: 6.0+ (API level 23+)
- **iOS**: 12.0+
- **RAM**: Minimum 2GB
- **Storage**: 100MB ruang kosong

### **Development**
- **Flutter**: 3.19.0+
- **Dart**: 3.0.0+
- **Node.js**: 18.0+
- **Database**: MongoDB 5.0+ atau PostgreSQL 13+

---

## Dokumentasi

`Soon`

---

*Dibuat dengan ❤️ oleh Kelompok 25 - Kelas C1 2023*
