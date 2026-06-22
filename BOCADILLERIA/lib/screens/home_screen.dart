import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool isDesktop = w > 1000;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFEFBF4), // Fondo crema premium
      drawer: isDesktop ? null : _buildDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.8),
          ),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bocadillería",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -1,
                      ),
                    ),
                    Row(
                      children: [
                        _NavBarItem(title: "Inicio", isActive: true),
                        const SizedBox(width: 35),
                        _NavBarItem(title: "Bocadillos"),
                        const SizedBox(width: 35),
                        _NavBarItem(title: "Bebidas"),
                        const SizedBox(width: 35),
                        _NavBarItem(title: "Pedidos"),
                        const SizedBox(width: 35),
                        _NavBarItem(title: "Favoritos"),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                            side: const BorderSide(color: Color(0xFFF97316), width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showAuth(context, true),
                          child: Text("Iniciar Sesión", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showAuth(context, false),
                          child: Text("Registrarse", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bocadillería",
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.8,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 30, color: Color(0xFF1E293B)),
                      tooltip: "Menú",
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 30, vertical: 80),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TEXTO HERO
                  Expanded(
                    flex: 6,
                    child: FadeInLeft(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Los Mejores\nBocadillos de la\nCiudad",
                            style: GoogleFonts.outfit(
                              fontSize: isDesktop ? 85 : 48,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF232836),
                              height: 1,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Ingredientes frescos, sabor artesanal y hechos con amor.",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 60),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
                              elevation: 20,
                              // ignore: deprecated_member_use
                              shadowColor: const Color(0xFFF97316).withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                            onPressed: () => _showAuth(context, true),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Ver Carta", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward_rounded, size: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // IMAGEN HERO
                  if (isDesktop)
                    Expanded(
                      flex: 4,
                      child: FadeInRight(
                        duration: const Duration(milliseconds: 1000),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Mancha rosa/sombra suave de fondo
                            Positioned(
                              bottom: 20,
                              child: Container(
                                width: 300,
                                height: 50,
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: const Color(0xFFFCE4E4).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 40,
                                      offset: const Offset(0, 10),
                                    )
                                  ]
                                ),
                              ),
                            ),
                            // Imagen del bocadillo
                            Image.asset(
                              'assets/images/hero_bocadillo.png',
                              fit: BoxFit.contain,
                              height: 500,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 60),
                FadeInUp(
                  child: Image.asset(
                    'assets/images/hero_bocadillo.png',
                    fit: BoxFit.contain,
                    height: 300,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showAuth(BuildContext context, bool isLogin) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (_) => AuthDialog(initialIsLogin: isLogin),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera naranja con logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(color: Color(0xFFF97316)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bocadillería",
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Bienvenido",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Iniciar sesión
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    side: const BorderSide(color: Color(0xFFF97316), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAuth(context, true);
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text("Iniciar sesión", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
            // Registrarse
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAuth(context, false);
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text("Registrarse", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Inicia sesión para pedir tus bocadillos favoritos.",
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _NavBarItem({required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppTheme.primaryColor : const Color(0xFF475569),
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ]
      ],
    );
  }
}
