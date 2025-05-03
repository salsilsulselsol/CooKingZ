import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
        '/kategori': (context) => const AppWithNavbar(CategoryPage()),
        '/sub-category': (context) => const AppWithNavbar(SubCategoryPage()),

        // Komunitas
        '/komunitas': (context) => const AppWithNavbar(KomunitasPage()),
        '/review': (context) => const AppWithNavbar(ReviewPage()),

        // Home & Fitur
        '/beranda': (context) => const AppWithNavbar(HomePage()),
        '/notif': (context) =>  AppWithNavbar(NotificationPage()),
        '/penjadwalan': (context) => const AppWithNavbar(PenjadwalanPage()),
        '/search': (context) => const AppWithNavbar(SearchPopup()),
        '/filter': (context) => const AppWithNavbar(FilterPopup()),
        '/pengguna-terbaik': (context) => const AppWithNavbar(PenggunaTerbaik()),
        '/trending-resep': (context) => const AppWithNavbar(TrandingResep()),
        '/hasil-pencarian': (context) => const AppWithNavbar(HasilPencaharian()),

        // Profil
        '/profil-utama': (context) => const AppWithNavbar(ProfilUtama()),
        '/bagikan-profil': (context) => const AppWithNavbar(BagikanProfil()),
        '/edit-profil': (context) => const AppWithNavbar(EditProfil()),
        '/mengikuti-pengikut': (context) => const AppWithNavbar(MengikutiPengikut()),
        '/makanan-favorit': (context) => const AppWithNavbar(MakananFavorit()),

        // Pengaturan
        '/pengaturan-utama': (context) => const AppWithNavbar(PengaturanUtama()),
        '/pusat-bantuan': (context) => const AppWithNavbar(PusatBantuan()),

        // Resep
        '/tambah-resep': (context) => const AppWithNavbar(BuatResep()),
        '/edit-resep': (context) => const AppWithNavbar(EditResep()),
        '/detail-resep': (context) => const AppWithNavbar(RecipeDetailPage()),
        '/resep-anda': (context) => const AppWithNavbar(ResepAndaPage()),

        // Default route
        '/resep-schedule': (context) => const AppWithNavbar(PenjadwalanPage()),
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