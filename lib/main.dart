import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';
import 'views/main_screen.dart';
import 'views/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const PokedexGachaApp());
}

class PokedexGachaApp extends StatelessWidget {
  const PokedexGachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada session aktif
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      // Arahkan ke MainScreen jika sudah login, LoginScreen jika belum
      home: session != null ? const MainScreen() : const LoginScreen(),
    );
  }
}
