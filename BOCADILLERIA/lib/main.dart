import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bocadillería Premium',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Solo intentamos cargar los bocadillos por defecto una vez por sesion.
  static bool _seedAttempted = false;

  void _maybeSeedDefaultProducts(AuthProvider authProvider) {
    if (_seedAttempted) return;
    if (!authProvider.isLoggedIn) return;
    _seedAttempted = true;
    // Fire-and-forget: si el usuario no tiene permisos (no es admin),
    // se ignora silenciosamente. Si los tiene, se cargan los 10 bocadillos.
    FirebaseService().seedDefaultProductsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Mientras Firebase se inicializa o verifica la sesión, mostramos un loading
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    _maybeSeedDefaultProducts(authProvider);

    // Si el usuario está logueado, verificamos su rol.
    if (authProvider.isLoggedIn) {
      if (authProvider.isAdmin) {
        return const AdminPanelScreen();
      }
      return const MenuScreen();
    } else {
      return const HomeScreen();
    }
  }
}
