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
import 'view/home/resep_schedule.dart';
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
import 'view/recipe/MyRecipePage.dart';

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
      initialRoute: '/komunitas',
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
        '/kategori': (context) => const SimplePageWrapper(CategoryPage()),
        '/sub-category': (context) => const SimplePageWrapper(SubCategoryPage()),

        // Komunitas
        '/komunitas': (context) => const SimplePageWrapper(KomunitasPage()),
        '/review': (context) => const SimplePageWrapper(ReviewPage()),

        // Home & Fitur
        '/beranda': (context) => const SimplePageWrapper(HomePage()),
        '/notif': (context) => SimplePageWrapper(NotificationPage()),
        '/penjadwalan': (context) => const SimplePageWrapper(PenjadwalanPage()),
        '/search': (context) => const SimplePageWrapper(SearchPopup()),
        '/filter': (context) => const SimplePageWrapper(FilterPopup()),
        '/pengguna-terbaik': (context) => const SimplePageWrapper(PenggunaTerbaik()),
        '/trending-resep': (context) => const SimplePageWrapper(TrandingResep()),
        '/hasil-pencarian': (context) => const SimplePageWrapper(HasilPencaharian()),

        // Profil
        '/profil-utama': (context) => const SimplePageWrapper(ProfilUtama()),
        '/bagikan-profil': (context) => const SimplePageWrapper(BagikanProfil()),
        '/edit-profil': (context) => const SimplePageWrapper(EditProfil()),
        '/mengikuti-pengikut': (context) => const SimplePageWrapper(MengikutiPengikut()),
        '/makanan-favorit': (context) => const SimplePageWrapper(MakananFavorit()),

        // Pengaturan
        '/pengaturan-utama': (context) => const SimplePageWrapper(PengaturanUtama()),
        '/pusat-bantuan': (context) => const SimplePageWrapper(PusatBantuan()),

        // Resep
        '/tambah-resep': (context) => const SimplePageWrapper(BuatResep()),
        '/edit-resep': (context) => const SimplePageWrapper(EditResep()),
        '/detail-resep': (context) => const SimplePageWrapper(RecipeDetailPage()),
        '/recipe': (context) => const SimplePageWrapper(ResepAndaPage()),

        // Default route
        '/resep-schedule': (context) => const SimplePageWrapper(PenjadwalanPage()),
      },
    );
  }
}

// Simple wrapper to display pages without the bottom navigation bar
class SimplePageWrapper extends StatelessWidget {
  final Widget child;
  const SimplePageWrapper(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
    );
  }
}