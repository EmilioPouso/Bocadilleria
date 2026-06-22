import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Por favor, rellena todos los campos");
      return;
    }
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    try {
      bool success;
      if (isLogin) {
        success = await auth.signIn(email, password);
      } else {
        success = await auth.register(email, password);
      }
      
      if (!success && mounted) {
        _showError('Correo o contraseña incorrectos');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _signInWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();
    if (!success && mounted) {
      _showError("Error al iniciar sesión con Google");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: w > 800 ? _wide() : _mobile(),
      ),
    );
  }

  Widget _wide() {
    return Row(children: [
      Expanded(flex: 5, child: _heroPanelDesktop()),
      Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: _form()))),
    ]);
  }

  Widget _mobile() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FadeInDown(child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.elevatedShadow),
              child: const Icon(Icons.restaurant_menu, size: 50, color: Colors.white),
            )),
            const SizedBox(height: 20),
            FadeInDown(delay: const Duration(milliseconds: 200), child: const Text("Bocadillería Premium",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5))),
            const SizedBox(height: 8),
            FadeInDown(delay: const Duration(milliseconds: 300), child: Text("Los mejores bocadillos artesanales",
              // ignore: deprecated_member_use
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)))),
            const SizedBox(height: 40),
            _form(),
          ]),
        ),
      ),
    );
  }

  Widget _heroPanelDesktop() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Stack(children: [
        Positioned(top: -100, right: -100, child: Container(width: 300, height: 300,
          decoration: BoxDecoration(shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.1)))),
        Positioned(bottom: -50, left: -50, child: Container(width: 200, height: 200,
          decoration: BoxDecoration(shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.08)))),
        Center(child: Padding(padding: const EdgeInsets.all(60), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FadeInDown(child: Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.restaurant_menu, size: 60, color: Colors.white))),
          const SizedBox(height: 30),
          FadeInDown(delay: const Duration(milliseconds: 200), child: const Text("Bocadillería\nPremium",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1))),
          const SizedBox(height: 16),
          FadeInDown(delay: const Duration(milliseconds: 400), child: Text("Los mejores bocadillos artesanales\ncon ingredientes de primera calidad",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.9), height: 1.5))),
        ]))),
      ]),
    );
  }

  Widget _form() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.isLoading;
        return FadeInUp(delay: const Duration(milliseconds: 400), child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))
            ]),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isLogin ? "¡Bienvenido!" : "Crear cuenta", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor)),
            const SizedBox(height: 6),
            Text(isLogin ? "Inicia sesión para ver el menú" : "Regístrate para guardar tus pedidos", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 30),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400], size: 20))),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: _obscure,
              decoration: InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400], size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 24),
            SizedBox(height: 54, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: isLoading ? null : _submit,
              child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(isLogin ? "Iniciar sesión" : "Crear cuenta", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: Divider(color: Colors.grey[200])),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("o continúa con", style: TextStyle(color: Colors.grey[400], fontSize: 13))),
              Expanded(child: Divider(color: Colors.grey[200]))]),
            const SizedBox(height: 24),
            OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: Colors.grey[200]!, width: 1.5)),
              onPressed: isLoading ? null : _signInWithGoogle,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)), SizedBox(width: 12),
                Text("Continuar con Google", style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w600, fontSize: 15))])),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(isLogin ? "¿No tienes cuenta? " : "¿Ya tienes cuenta? ", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              GestureDetector(onTap: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Regístrate" : "Inicia sesión", style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 14)))]),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen())), 
              child: Text("Entrar como invitado →", style: TextStyle(color: Colors.grey[400], fontSize: 13))),
          ]),
        ));
      }
    );
  }
}
