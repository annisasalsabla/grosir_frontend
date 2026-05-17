import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/cashier/cashier_dashboard_screen.dart';
import 'theme/app_theme.dart';

class GrosirApp extends StatelessWidget {
  const GrosirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grosir Tiga Bersaudara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const SplashScreen();
          }

          if (authProvider.isAuthenticated) {
            final role = authProvider.user?.role;

            // Owner: mobile layout (bottom nav)
            // Admin & Cashier: tablet layout (navigation rail)

            if (role == 'owner') {
              return const OwnerDashboardScreen();
            } else if (role == 'administrator') {
              return const AdminDashboardScreen();
            } else {
              return const CashierDashboardScreen();
            }
          }

          return const LoginScreen();
        },
      ),
    );
  }
}