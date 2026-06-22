import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../navigation/app_section.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/show_cart_sheet.dart';

class AppHeader extends StatelessWidget {
  final AppSection activeSection;
  final ValueChanged<AppSection> onNavigate;
  final VoidCallback? onOpenDrawer;

  const AppHeader({
    super.key,
    required this.activeSection,
    required this.onNavigate,
    this.onOpenDrawer,
  });

  static const double height = 90;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Material(
      color: Colors.white,
      elevation: 0,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onNavigate(AppSection.inicio),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bocadillería',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: isDesktop ? 32 : 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
              if (isDesktop)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: AppSection.values
                      .map(
                        (section) => _NavItem(
                          title: section.label,
                          active: activeSection == section,
                          onTap: () => onNavigate(section),
                        ),
                      )
                      .toList(),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDesktop) ...[
                    Text(
                      auth.user?.email ?? '',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => auth.signOut(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFF4ADE80)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                  _CartBadge(
                    cart: cart,
                    onPressed: () => showCartSheet(context),
                  ),
                  if (!isDesktop && onOpenDrawer != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 30, color: Color(0xFF1E293B)),
                      onPressed: onOpenDrawer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? const Color(0xFFF97316) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 2,
              color: active ? const Color(0xFFF97316) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final CartProvider cart;
  final VoidCallback onPressed;

  const _CartBadge({required this.cart, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
          ),
          if (cart.totalItems > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                child: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
