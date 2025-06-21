import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Onboarding
import 'view/onboarding/introduction_screen.dart';
import 'view/onboarding/level_preference_allergy.dart';

// Auth
import 'view/auth/login_page.dart';
import 'view/auth/register_page.dart';
import 'view/auth/forgot_password.dart';

// Kategori
import 'view/kategori/category_page.dart';
import 'view/kategori/sub_category_page.dart';

// Community
import 'view/community/community_page.dart';
import 'view/community/review_page.dart';

// Home
import 'view/home/home_page.dart';
import 'view/home/notification_page.dart';
import 'view/home/penjadwalan_page.dart';
import 'view/home/popup_search.dart';
import 'view/home/popup_filter.dart';
import 'view/home/pengguna_terbaik.dart';
import 'view/home/resep_trending.dart';
import 'view/home/hasil_pencarian.dart';

// Profile - Profil
import 'view/profile/profil/profil_utama.dart';
import 'view/profile/profil/bagikan_profil.dart';
import 'view/profile/profil/edit_profil.dart';
import 'view/profile/profil/mengikuti_pengikut.dart';
import 'view/profile/profil/makanan_favorit.dart';
import 'view/profile/profil/tambah_resep.dart';
import 'view/profile/profil/edit_resep.dart';

// Profile - Pengaturan
import 'view/profile/Pengaturan/pengaturan_utama.dart';
import 'view/profile/Pengaturan/pengaturan_notifikasi.dart';
import 'view/profile/Pengaturan/pusat_bantuan.dart';

// Recipe
import 'view/recipe/resep_detail_page.dart';
import 'view/recipe/resep_anda_page.dart';

// Menu (utamanya jika halaman utama ada di file ini)
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF206153),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF206153)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // Onboarding & Auth
        '/': (context) => const HomeScreen(),
        '/boardinga': (context) => const OnboardingA(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/cooking': (context) => const CookingLevelPage(),
        '/allergy': (context) => const AllergyQuestionnairePage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),

        // Kategori
        '/kategori': (context) => const CategoryPage(),
        // '/sub-category': (context) => const AppWithNavbar(SubCategoryPage()),

        // Komunitas
        '/komunitas': (context) => const AppWithNavbar(KomunitasPage()),
        '/review': (context) => const ReviewPage(),

        // Home & Fitur
        '/beranda': (context) => const HomePage(),
        '/notif': (context) =>  AppWithNavbar(NotificationPage()),
        '/penjadwalan': (context) => const AppWithNavbar(PenjadwalanPage()),
        '/search': (context) => const AppWithNavbar(SearchPopup()),
        '/filter': (context) => const AppWithNavbar(FilterPopup()),
        '/pengguna-terbaik': (context) => const PenggunaTerbaik(),
        '/trending-resep': (context) => const AppWithNavbar(ResepTrending()),
       
        // Profil
        '/profil-utama': (context) => const AppWithNavbar(ProfilUtama()),
        '/bagikan-profil': (context) => const AppWithNavbar(BagikanProfil()),
        '/edit-profil': (context) => const AppWithNavbar(EditProfil()),
        '/pengikut-mengikuti': (context) => const AppWithNavbar(MengikutiPengikut()),
        '/makanan-favorit': (context) => const AppWithNavbar(MakananFavorit()),

        // Pengaturan
        '/pengaturan-utama': (context) => const AppWithNavbar(PengaturanUtama()),
        '/pengaturan-notifikasi': (context) => const AppWithNavbar(NotificationSettingsScreen()),
        '/pusat-bantuan': (context) => const AppWithNavbar(PusatBantuan()),

        // Resep
        '/tambah-resep': (context) => const BuatResep(),
        // '/edit-resep': (context) => const EditResep(),
        // '/detail-resep': (context) => const RecipeDetailPage(),
        '/resep-anda': (context) => const AppWithNavbar(ResepAndaPage()),

        // Default route
        '/resep-schedule': (context) => const AppWithNavbar(PenjadwalanPage()),
      },

      onGenerateRoute: (settings) {
        // Jika nama rute kosong, tidak perlu diproses di sini
        if (settings.name == null) {
          return null;
        }

        // Parse URI untuk menangani path segments (misal: #/edit-resep/123 atau #/detail-resep/123)
        final uri = Uri.parse(settings.name!);

        // CASE 1: Rute '/edit-resep' dipanggil dengan path parameter (misal: /edit-resep/123)
        // Ini berguna jika Anda mengetik langsung di browser atau menggunakan deep linking
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'edit-resep') {
          if (uri.pathSegments.length == 2) { // Memastikan ada ID setelah '/edit-resep/'
            final String? idString = uri.pathSegments[1];
            final int? recipeId = int.tryParse(idString ?? '');
            if (recipeId != null) {
              return MaterialPageRoute(
                builder: (context) => AppWithNavbar(EditResep(recipeId: recipeId)),
                settings: settings, // Penting: Teruskan settings untuk kompatibilitas navigasi
              );
            }
          }
          // Jika ID tidak valid atau format path salah (misal: /edit-resep/abc atau /edit-resep/)
          return MaterialPageRoute(builder: (context) => const Text('Error: ID Resep tidak valid atau tidak ditemukan di URL. Format yang benar: /edit-resep/ID_RESEP'));
        }

        // --- Perbaikan untuk /detail-resep ---
        // CASE 2: Rute '/detail-resep' dipanggil dengan path parameter (misal: /detail-resep/123)
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'detail-resep') {
          if (uri.pathSegments.length == 2) { // Memastikan ada ID setelah '/detail-resep/'
            final String? idString = uri.pathSegments[1];
            final int? recipeId = int.tryParse(idString ?? '');
            if (recipeId != null) {
              return MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeId: recipeId), // Teruskan recipeId
                settings: settings,
              );
            }
          }
          // Jika ID tidak valid atau format path salah
          return MaterialPageRoute(builder: (context) => const Text('Error: ID Resep wajib diberikan untuk halaman /detail-resep. Format yang benar: /detail-resep/ID_RESEP'));
        }
        // --- Akhir perbaikan untuk /detail-resep ---


        // CASE 3: Rute '/edit-resep' dipanggil dengan arguments (dari Navigator.pushNamed)
        // Contoh: Navigator.pushNamed(context, '/edit-resep', arguments: 123);
        // Ini adalah cara umum untuk navigasi internal antar halaman Flutter
        if (settings.name == '/edit-resep') {
          final args = settings.arguments;
          if (args is int) { // Memastikan argumen yang diteruskan adalah integer (recipeId)
            return MaterialPageRoute(
              builder: (context) => AppWithNavbar(EditResep(recipeId: args)),
              settings: settings,
            );
          } else {
            // Ini menangkap kasus error yang Anda alami: Navigator.pushNamed('/edit-resep') tanpa argumen
            // atau dengan argumen yang tidak valid (bukan int).
            return MaterialPageRoute(builder: (context) => const Text('Error: ID Resep wajib diberikan untuk halaman /edit-resep. Navigasi: Navigator.pushNamed(context, "/edit-resep", arguments: yourRecipeId);'));
          }
        }

        // --- Penanganan untuk /detail-resep ketika dipanggil dengan arguments (dari Navigator.pushNamed) ---
        if (settings.name == '/detail-resep') {
          final args = settings.arguments;
          if (args is int) {
            return MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipeId: args), // Teruskan recipeId
              settings: settings,
            );
          } else {
            return MaterialPageRoute(builder: (context) => const Text('Error: ID Resep wajib diberikan untuk halaman /detail-resep. Navigasi: Navigator.pushNamed(context, "/detail-resep", arguments: yourRecipeId);'));
          }
        }
        // --- Akhir penanganan untuk /detail-resep dengan arguments ---
         if (settings.name == '/hasil-pencarian') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
           
            return MaterialPageRoute(
              builder: (context) {
                 print("✅ Navigating to HasilPencaharian with args: $args");
                return HasilPencaharian(initialSearchParams: args);
              },
              settings: settings,
            );
          } else {
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(child: Text('Error: Parameter tidak valid.')),
                  ),
            );
          }
        }

        // Untuk rute lain yang tidak ditangani secara eksplisit di onGenerateRoute,
        // kembalikan null agar MaterialApp mencari di 'routes' map.
        return null;
      },

    );
  }

}




class AppWithNavbar extends StatefulWidget {
  final Widget child;
  const AppWithNavbar(this.child, {super.key});

  @override
  AppWithNavbarState createState() => AppWithNavbarState();
}

class AppWithNavbarState extends State<AppWithNavbar> {
  // Map each navigation item to its corresponding route
  final Map<int, String> _navRoutes = {
    0: '/beranda',           // Home
    1: '/komunitas',         // Community/Chat
    2: '/kategori',          // Categories/Layers
    3: '/profil-utama',      // Profile
  };

  int getSelectedIndex() {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Check which navigation section the current route belongs to
    if (currentRoute != null) {
      // Home section routes
      if (currentRoute == '/beranda' || 
          currentRoute == '/notif' || 
          currentRoute == '/pengguna-terbaik' ||
          currentRoute == '/trending-resep' ||
          currentRoute == '/hasil-pencarian') {
        return 0;
      }
      
      // Community section routes
      else if (currentRoute == '/komunitas' || 
               currentRoute == '/review') {
        return 1;
      }
      
      // Categories section routes
      else if (currentRoute == '/kategori' || 
               currentRoute == '/sub-category' ||
               currentRoute == '/detail-resep' ||
               currentRoute == '/penjadwalan' ||
               currentRoute == '/recipe') {
        return 2;
      }
      
      // Profile section routes
      else if (currentRoute == '/profil-utama' || 
               currentRoute == '/edit-profil' ||
               currentRoute == '/bagikan-profil' ||
               currentRoute == '/mengikuti-pengikut' ||
               currentRoute == '/makanan-favorit' ||
               currentRoute == '/tambah-resep' ||
               currentRoute == '/edit-resep' ||
               currentRoute == '/pengaturan-utama' ||
               currentRoute == '/pengaturan-notifikasi' ||
               currentRoute == '/pusat-bantuan') {
        return 3;
      }
    }
    
    return 0; // Default to home if route not found
  }

  void _onItemTapped(int index) {
    String targetRoute = _navRoutes[index] ?? '/beranda';
    
    // Only navigate if we're not already on a page in this section
    if (getSelectedIndex() != index) {
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = getSelectedIndex();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: widget.child,
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF7ECBCD),    // Solid color at bottom
              Color(0x807ECBCD),    // Semi-transparent in middle
              Color(0x007ECBCD),    // Fully transparent at top
            ],
            stops: [0.0, 0.5, 1.0], 
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          child: Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF006257),  // Dark teal color
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, selectedIndex),
                _buildNavItem(1, Icons.chat_bubble_outline, selectedIndex),
                _buildNavItem(2, Icons.layers_outlined, selectedIndex),
                _buildNavItem(3, Icons.person_outline, selectedIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, int selectedIndex) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon, 
              size: 28, 
              color: Colors.white
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 3,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
