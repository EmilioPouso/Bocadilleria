import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/app_section.dart';
import '../widgets/app_header.dart';
import '../widgets/product_network_image.dart';
import '../services/firebase_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../utils/show_cart_sheet.dart';
import 'favorites_screen.dart';
import 'orders_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  AppSection _section = AppSection.inicio;

  String? get _category => _section.menuCategory;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1000;
    final cols = w > 1200 ? 4 : w > 800 ? 3 : 2;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFEFBF4),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              activeSection: _section,
              onNavigate: (section) => setState(() => _section = section),
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _section.isMenuSection
                  ? _buildMenuBody(isDesktop, cols, cart)
                  : _buildSecondaryBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: !isDesktop && _section.isMenuSection && cart.totalItems > 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF97316),
              onPressed: () => showCartSheet(context),
              icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
              label: Text("${cart.totalPrice.toStringAsFixed(2)}€", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildSecondaryBody() {
    switch (_section) {
      case AppSection.pedidos:
        return const OrdersContent();
      case AppSection.favoritos:
        return const FavoritesContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMenuBody(bool isDesktop, int cols, CartProvider cart) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 16, 40, isDesktop ? 60 : 16, 24),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search, size: 24),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
          ),
        ),
        StreamBuilder<List<Product>>(
          stream: _firebaseService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
              );
            }
            final products = (snapshot.data ?? []).where((p) {
              final matchesCategory = _category == null || p.category == _category;
              final matchesSearch = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            if (_category == null) {
              final drinks = products.where((p) => p.category == 'bebidas').toList();
              final bocadillos = products.where((p) => p.category != 'bebidas').toList();

              if (products.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No hay productos disponibles')),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (drinks.isNotEmpty) ...[
                        _buildCategoryDividerContent('Bebidas'),
                        _buildProductGrid(
                          products: drinks,
                          cols: cols,
                          mainAxisExtent: _gridMainAxisExtent(cols, isDrink: true),
                          cart: cart,
                        ),
                      ],
                      if (drinks.isNotEmpty && bocadillos.isNotEmpty)
                        _buildCategoryDividerContent('Bocadillos'),
                      if (bocadillos.isNotEmpty)
                        _buildProductGrid(
                          products: bocadillos,
                          cols: cols,
                          mainAxisExtent: _gridMainAxisExtent(cols, isDrink: false),
                          cart: cart,
                          animationOffset: drinks.length,
                        ),
                    ],
                  ),
                ),
              );
            }

            return _buildProductGridSliver(
              products: products,
              cols: cols,
              mainAxisExtent: _gridMainAxisExtent(
                cols,
                isDrink: products.every((p) => p.category == 'bebidas'),
              ),
              isDesktop: isDesktop,
              cart: cart,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  double _gridMainAxisExtent(int cols, {required bool isDrink}) {
    if (cols == 2) return isDrink ? 400 : 480;
    if (cols == 3) return isDrink ? 380 : 450;
    return isDrink ? 360 : 430;
  }

  Widget _buildCategoryDividerContent(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildProductGrid({
    required List<Product> products,
    required int cols,
    required double mainAxisExtent,
    required CartProvider cart,
    int animationOffset = 0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisExtent: mainAxisExtent,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final p = products[i];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * (i + animationOffset)),
          child: _ProductCard(
            product: p,
            quantity: cart.getQuantity(p.id),
            onAdd: () => cart.addProduct(p),
          ),
        );
      },
    );
  }

  Widget _buildProductGridSliver({
    required List<Product> products,
    required int cols,
    required double mainAxisExtent,
    required bool isDesktop,
    required CartProvider cart,
    int animationOffset = 0,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisExtent: mainAxisExtent,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final p = products[i];
            return FadeInUp(
              delay: Duration(milliseconds: 50 * (i + animationOffset)),
              child: _ProductCard(
                product: p,
                quantity: cart.getQuantity(p.id),
                onAdd: () => cart.addProduct(p),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final categories = [
      {'icon': Icons.home_rounded, 'section': AppSection.inicio},
      {'icon': Icons.lunch_dining_rounded, 'section': AppSection.bocadillos},
      {'icon': Icons.local_drink_rounded, 'section': AppSection.bebidas},
      {'icon': Icons.receipt_long_rounded, 'section': AppSection.pedidos},
      {'icon': Icons.favorite_rounded, 'section': AppSection.favoritos},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(color: Color(0xFFF97316)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bocadillería',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    auth.user?.email ?? '',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...categories.map((item) {
              final section = item['section'] as AppSection;
              final icon = item['icon'] as IconData;
              final isActive = _section == section;
              return ListTile(
                leading: Icon(icon, color: isActive ? const Color(0xFFF97316) : const Color(0xFF475569)),
                title: Text(
                  section.label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? const Color(0xFFF97316) : const Color(0xFF1E293B),
                  ),
                ),
                tileColor: isActive ? const Color(0xFFFFF7ED) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _section = section);
                },
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF64748B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  auth.signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text('Cerrar sesión', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.quantity, required this.onAdd});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isFavorite = false;
  bool _loadingFav = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) return;
    try {
      final favKey = '${widget.product.id}_${0.hashCode}';
      final snapshot = await FirebaseService().db.child('favorites').child(auth.user!.uid).child(favKey).get();
      if (mounted) setState(() => _isFavorite = snapshot.exists);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final w = MediaQuery.of(context).size.width;
    final isCompact = w <= 800;
    final contentPadding = isCompact ? 12.0 : 16.0;
    final btnPadding = isCompact ? 9.0 : 12.0;
    final nameSize = isCompact ? 15.0 : 18.0;
    final descSize = isCompact ? 11.0 : 12.0;
    final priceSize = isCompact ? 19.0 : 22.0;

    return Container(
      clipBehavior: Clip.antiAlias,
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
            flex: isCompact ? 5 : 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: Container(
                      color: const Color(0xFFFFF7ED),
                      child: widget.product.imageUrl.isEmpty
                          ? const Center(
                              child: Icon(Icons.lunch_dining, size: 48, color: Colors.grey),
                            )
                          : ProductNetworkImage(
                              imageUrl: widget.product.imageUrl,
                              fit: BoxFit.contain,
                              placeholder: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ),
                              errorWidget: const Center(
                                child: Icon(Icons.lunch_dining, size: 48, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (!auth.isLoggedIn) return const SizedBox();
                      return GestureDetector(
                        onTap: _loadingFav ? null : () async {
                          setState(() => _loadingFav = true);
                          try {
                            final nowFav = await _firebaseService.toggleFavorite(auth.user!.uid, widget.product.id);
                            if (!mounted) return;
                            setState(() {
                              _isFavorite = nowFav;
                              _loadingFav = false;
                            });
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(nowFav ? "¡Añadido a favoritos! ❤️" : "Eliminado de favoritos"),
                                duration: const Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: nowFav ? const Color(0xFFF97316) : Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                width: 250,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _loadingFav = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Error: sin permisos. Comprueba las reglas de Firebase."),
                                backgroundColor: Colors.red.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                width: 320,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              // ignore: deprecated_member_use
                              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: _loadingFav
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF97316)))
                              : Icon(
                                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  size: 18,
                                  color: _isFavorite ? Colors.red : Colors.grey.shade500,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: nameSize, color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.description,
                  style: TextStyle(fontSize: descSize, color: Colors.grey.shade500),
                  maxLines: isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isCompact ? 8 : 12),
                Text("${widget.product.price.toStringAsFixed(2)}€", style: TextStyle(color: const Color(0xFFF97316), fontWeight: FontWeight.w900, fontSize: priceSize)),
                SizedBox(height: isCompact ? 10 : 16),
                if (widget.product.category != 'bebidas') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: EdgeInsets.symmetric(vertical: btnPadding),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showPersonalization(context, cart),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text("Personalizar", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: btnPadding),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: widget.onAdd,
                    child: const Text("Añadir al Pedido", style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonalization(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => _PersonalizationDialog(
        product: widget.product,
        onAdd: (customizations, extraPrice) {
          cart.addProduct(widget.product, customizations: customizations, customExtraPrice: extraPrice);
        },
      ),
    );
  }
}

class _PersonalizationDialog extends StatefulWidget {
  final Product product;
  final Function(String, double) onAdd;
  const _PersonalizationDialog({required this.product, required this.onAdd});
  @override
  State<_PersonalizationDialog> createState() => _PersonalizationDialogState();
}

class _PersonalizationDialogState extends State<_PersonalizationDialog> {
  final FirebaseService _firebaseService = FirebaseService();
  late Map<String, int> ingredientLevels;
  bool _panSinGluten = false;
  bool _isFavorite = false;
  bool _loadingFav = false;
  int _favCheckGen = 0;

  @override
  void initState() {
    super.initState();
    ingredientLevels = {for (var i in widget.product.ingredients) i: 1};
    _syncFavoriteState();
  }

  Future<void> _syncFavoriteState() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) return;
    final gen = ++_favCheckGen;
    try {
      final saved = await _firebaseService.isFavoriteSaved(
        auth.user!.uid,
        widget.product.id,
        customizations: _getCustomsString(),
      );
      if (mounted && gen == _favCheckGen) setState(() => _isFavorite = saved);
    } catch (_) {}
  }

  void _updateCustomization(VoidCallback update) {
    setState(update);
    _syncFavoriteState();
  }

  Future<void> _toggleFavorite(String userId) async {
    if (_loadingFav) return;
    setState(() => _loadingFav = true);
    try {
      final customs = _getCustomsString();
      final extraPrice = _getExtraPrice();
      final nowFav = await _firebaseService.toggleFavorite(
        userId,
        widget.product.id,
        customizations: customs,
        customExtraPrice: extraPrice,
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = nowFav;
        _loadingFav = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowFav
                ? (customs.isEmpty
                    ? '¡Añadido a favoritos! ❤️'
                    : '¡Personalización guardada en favoritos! ❤️')
                : 'Eliminado de favoritos',
          ),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: nowFav ? const Color(0xFFF97316) : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          width: 300,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingFav = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al guardar en favoritos'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getCustomsString() {
    String capitalizeWords(String value) {
      return value
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) => "${w[0].toUpperCase()}${w.substring(1).toLowerCase()}")
          .join(' ');
    }

    final customs = ingredientLevels.entries.where((e) => e.value != 1).map((e) {
      final ingredientName = capitalizeWords(e.key);
      if (e.value == 0) return "Sin $ingredientName";
      return "Extra de $ingredientName";
    }).join(", ");
    final customParts = <String>[];
    if (_panSinGluten) customParts.add("Pan sin gluten");
    if (customs.isNotEmpty) customParts.add(customs);
    return customParts.isEmpty ? "" : "Personalizado: ${customParts.join(", ")}";
  }

  double _getExtraPrice() {
    double total = 0;
    for (final entry in ingredientLevels.entries) {
      if (entry.value == 2) {
        total += widget.product.ingredientExtraPrices[entry.key] ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Personalizar", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (!auth.isLoggedIn) return const SizedBox();
                    return IconButton(
                      icon: _loadingFav
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF97316)),
                            )
                          : Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                              color: _isFavorite ? Colors.red : Colors.grey,
                            ),
                      tooltip: _isFavorite ? 'Quitar de favoritos' : 'Guardar personalización en favoritos',
                      onPressed: _loadingFav ? null : () => _toggleFavorite(auth.user!.uid),
                    );
                  },
                ),
              ],
            ),
            Text(widget.product.name, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.product.ingredients.map((ing) {
                  final isBread = ing.trim().toLowerCase() == 'pan';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(ing, style: const TextStyle(fontWeight: FontWeight.w500))),
                        if (isBread)
                          Row(
                            children: [
                              Checkbox(
                                value: _panSinGluten,
                                onChanged: (v) => _updateCustomization(() => _panSinGluten = v ?? false),
                                activeColor: const Color(0xFFF97316),
                              ),
                              const Text(
                                "Sin gluten",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        if (!isBread)
                          Row(
                            children: [0, 1, 2].map((level) {
                              final isSelected = ingredientLevels[ing] == level;
                              return GestureDetector(
                                onTap: () => _updateCustomization(() => ingredientLevels[ing] = level),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF97316) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(level == 0 ? "Sin" : (level == 1 ? "Normal" : "Doble"),
                                      style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  widget.onAdd(_getCustomsString(), _getExtraPrice());
                  Navigator.pop(context);
                },
                child: const Text("GUARDAR Y AÑADIR", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
