import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/app_section.dart';
import '../widgets/app_header.dart';
import '../widgets/product_network_image.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../utils/order_customization_display.dart';
import '../widgets/order_customization_lines.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBF4),
      body: Column(
        children: [
          AppHeader(
            activeSection: AppSection.favoritos,
            onNavigate: (section) => _navigateFromLegacy(context, section),
          ),
          const Expanded(child: FavoritesContent()),
        ],
      ),
    );
  }

  static void _navigateFromLegacy(BuildContext context, AppSection section) {
    if (section == AppSection.favoritos) return;
    Navigator.pop(context);
  }
}

class FavoritesContent extends StatelessWidget {
  const FavoritesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final firebaseService = FirebaseService();
    final cart = Provider.of<CartProvider>(context);
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1000;

    if (!auth.isLoggedIn) {
      return const Center(child: Text('Debes iniciar sesión para ver tus favoritos'));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 16, 40, isDesktop ? 60 : 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus Favoritos',
                  style: GoogleFonts.outfit(
                    fontSize: isDesktop ? 48 : 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tus combinaciones preferidas listas para pedir',
                  style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: firebaseService.getFavorites(auth.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
              );
            }

            final favoritesData = snapshot.data ?? [];
            if (favoritesData.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no tienes favoritos',
                        style: GoogleFonts.outfit(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }

            void showRemoveSnack(BuildContext ctx) {
              ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Text('Eliminado de favoritos'),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  width: 250,
                ),
              );
            }

            final cols = isDesktop ? (w > 1200 ? 4 : 3) : 2;
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 12),
              sliver: FutureBuilder<List<_FavoriteEntry>>(
                future: Future.wait(
                  favoritesData.map((fav) async {
                    final product = await firebaseService.getProduct(fav['productId']);
                    if (product == null) {
                      final key = fav['_favKey'] as String? ?? '';
                      if (key.isNotEmpty) {
                        await firebaseService.removeFavoriteByKey(auth.user!.uid, key);
                      }
                    }
                    return _FavoriteEntry(
                      product: product,
                      customizations: fav['customizations'] ?? '',
                      customExtraPrice: (fav['customExtraPrice'] as num?)?.toDouble(),
                    );
                  }),
                ).then((list) => list.where((e) => e.product != null).toList()),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
                      ),
                    );
                  }
                  final entries = snap.data!;
                  if (entries.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Aún no tienes favoritos',
                          style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: isDesktop ? 24 : 12,
                      mainAxisSpacing: isDesktop ? 24 : 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final e = entries[i];
                        final p = e.product!;
                        final customs = e.customizations;
                        final extraPrice = e.customExtraPrice ??
                            OrderCustomizationDisplay.totalExtraPrice(customs, p.ingredientExtraPrices);
                        final unitPrice = p.price + extraPrice;
                        return _FavoriteProductCard(
                          product: p,
                          customizations: customs,
                          unitPrice: unitPrice,
                          quantity: cart.getQuantity(p.id),
                          onAdd: () => cart.addProduct(
                            p,
                            customizations: customs,
                            customExtraPrice: extraPrice,
                          ),
                          onRemove: () {
                            firebaseService.toggleFavorite(
                              auth.user!.uid,
                              p.id,
                              customizations: customs,
                              customExtraPrice: extraPrice,
                            );
                            showRemoveSnack(context);
                          },
                        );
                      },
                      childCount: entries.length,
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _FavoriteEntry {
  final Product? product;
  final String customizations;
  final double? customExtraPrice;
  const _FavoriteEntry({
    required this.product,
    required this.customizations,
    this.customExtraPrice,
  });
}

class _FavoriteProductCard extends StatelessWidget {
  final Product product;
  final String customizations;
  final double unitPrice;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _FavoriteProductCard({
    required this.product,
    required this.customizations,
    required this.unitPrice,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(5 / 255), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: product.imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.lunch_dining, size: 48, color: Colors.grey)),
                        )
                      : ProductNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.favorite_rounded, size: 20, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customizations.isNotEmpty)
                  OrderCustomizationLines(
                    customizations: customizations,
                    ingredientExtraPrices: product.ingredientExtraPrices,
                    lineStyle: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${unitPrice.toStringAsFixed(2)}€',
                  style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: onAdd,
                    child: const Text('Pedir de Nuevo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
