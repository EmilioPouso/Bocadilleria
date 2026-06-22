import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_customization_lines.dart';
import '../../widgets/product_network_image.dart';
import 'package:intl/intl.dart';

/// Ancho máximo tipo escritorio del panel admin; por debajo se usa layout compacto.
bool _adminIsCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 720;

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final compact = _adminIsCompact(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: compact ? _buildDrawer(context) : null,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UsersTab(),
                _ProductsTab(),
                _KitchenTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final compact = _adminIsCompact(context);
    final hPad = compact ? 14.0 : 40.0;
    final vPad = compact ? 14.0 : 20.0;
    final titleStyle = GoogleFonts.outfit(
      fontSize: compact ? 20 : 32,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF1E293B),
      height: 1.2,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      color: Colors.white,
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person_rounded, color: Color(0xFFF59E0B), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Panel de Administración",
                    style: titleStyle,
                    softWrap: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 30, color: Color(0xFF1E293B)),
                  tooltip: "Menú",
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.lock_person_rounded, color: Color(0xFFF59E0B), size: 40),
                      const SizedBox(width: 15),
                      Flexible(
                        child: Text(
                          "Panel de Administración",
                          style: titleStyle,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => authProvider.signOut(),
                  child: Text("Cerrar Sesión", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(color: Color(0xFFF59E0B)),
              child: Row(
                children: [
                  const Icon(Icons.lock_person_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Administración",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.email ?? "",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  authProvider.signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  "Cerrar sesión",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFFF59E0B),
              indicatorWeight: 3,
              labelColor: const Color(0xFFF59E0B),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: compact ? 14 : 16),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: compact ? 14 : 16),
              labelPadding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: compact ? 8 : 10),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_rounded, size: compact ? 18 : 20),
                      SizedBox(width: compact ? 6 : 8),
                      const Text("Usuarios"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fastfood_rounded, size: compact ? 18 : 20),
                      SizedBox(width: compact ? 6 : 8),
                      const Text("Productos"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_menu_rounded, size: compact ? 18 : 20),
                      SizedBox(width: compact ? 6 : 8),
                      const Text("Cocina"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _editRole(BuildContext context, Map<String, dynamic> user) async {
    final currentRole = (user['role'] ?? 'user').toString();
    final email = (user['email'] ?? 'sin email').toString();
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Rol de $email", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        children: [
          _roleOption(ctx, "Usuario", "user", currentRole, Icons.person_rounded, const Color(0xFF2563EB)),
          _roleOption(ctx, "Administrador", "admin", currentRole, Icons.shield_rounded, const Color(0xFFF59E0B)),
        ],
      ),
    );
    if (newRole != null && newRole != currentRole) {
      try {
        await _firebaseService.updateUserRole(user['id'], newRole);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Rol actualizado a $newRole"), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  Widget _roleOption(BuildContext ctx, String label, String value, String current, IconData icon, Color color) {
    final selected = value == current;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, value),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          if (selected) const Icon(Icons.check_rounded, color: Color(0xFF10B981)),
        ],
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, Map<String, dynamic> user) async {
    final email = (user['email'] ?? 'sin email').toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Eliminar usuario", style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text(
          "¿Seguro que quieres eliminar a $email?\n\nEsta acción borra sus datos de la base de datos (no la cuenta de Firebase Auth).",
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancelar", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Eliminar", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _firebaseService.deleteUser(user['id']);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Usuario eliminado"), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = _adminIsCompact(context);
    final pad = compact ? 16.0 : 40.0;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        final admins = users.where((u) => u['role'] == 'admin').length;
        final statsRow = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatCard(title: "Total usuarios", value: users.length.toString(), compact: true),
                  const SizedBox(height: 12),
                  _StatCard(title: "Administradores", value: admins.toString(), compact: true),
                  const SizedBox(height: 12),
                  _StatCard(title: "Usuarios regulares", value: (users.length - admins).toString(), compact: true),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _StatCard(title: "TOTAL DE USUARIOS", value: users.length.toString())),
                  const SizedBox(width: 20),
                  Expanded(child: _StatCard(title: "ADMINISTRADORES", value: admins.toString())),
                  const SizedBox(width: 20),
                  Expanded(child: _StatCard(title: "USUARIOS REGULARES", value: (users.length - admins).toString())),
                ],
              );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statsRow,
              SizedBox(height: compact ? 24 : 40),
              Container(
                padding: EdgeInsets.all(compact ? 16 : 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(5 / 255), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, color: Color(0xFF1E293B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Lista de Usuarios",
                            style: GoogleFonts.outfit(fontSize: compact ? 20 : 24, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 16 : 30),
                    if (!compact)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        color: const Color(0xFFF1F5F9),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: _TableHeader(text: "Usuario")),
                            Expanded(flex: 2, child: _TableHeader(text: "Rol")),
                            Expanded(child: _TableHeader(text: "Acciones")),
                          ],
                        ),
                      ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    else if (compact)
                      ...users.map((user) {
                        final email = user['email'] ?? 'Sin email';
                        final role = user['role'] ?? 'user';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          role == 'admin' ? 'Admin' : 'Usuario',
                                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB)),
                                        tooltip: "Editar rol",
                                        onPressed: () => _editRole(context, user),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                                        tooltip: "Eliminar",
                                        onPressed: () => _deleteUser(context, user),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(user['email'] ?? 'Sin email')),
                                Expanded(flex: 2, child: Text(user['role'] ?? 'user')),
                                Expanded(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: "Editar rol",
                                        onPressed: () => _editRole(context, user),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: "Eliminar",
                                        onPressed: () => _deleteUser(context, user),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    final compact = _adminIsCompact(context);
    final pad = compact ? 16.0 : 40.0;
    return StreamBuilder<List<Product>>(
      stream: _firebaseService.getProducts(),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        final nuevoBtn = SizedBox(
          width: compact ? double.infinity : null,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: () => _showForm(context),
            icon: const Icon(Icons.add),
            label: const Text("Nuevo producto"),
          ),
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatCard(
                title: compact ? "Total productos" : "TOTAL DE PRODUCTOS",
                value: products.length.toString(),
                compact: compact,
              ),
              SizedBox(height: compact ? 24 : 40),
              Container(
                padding: EdgeInsets.all(compact ? 16 : 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(5 / 255), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compact) ...[
                      Row(
                        children: [
                          const Icon(Icons.lunch_dining_rounded, color: Color(0xFF1E293B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Gestión de Productos",
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      nuevoBtn,
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lunch_dining_rounded, color: Color(0xFF1E293B)),
                              const SizedBox(width: 10),
                              Text("Gestión de Productos", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                            onPressed: () => _showForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Nuevo"),
                          ),
                        ],
                      ),
                    SizedBox(height: compact ? 16 : 30),
                    if (!compact)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        color: const Color(0xFFF1F5F9),
                        child: Row(
                          children: [
                            Expanded(child: _TableHeader(text: "Imagen")),
                            Expanded(flex: 2, child: _TableHeader(text: "Nombre")),
                            Expanded(child: _TableHeader(text: "Precio")),
                            Expanded(child: _TableHeader(text: "Acciones")),
                          ],
                        ),
                      ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    else if (compact)
                      ...products.map((product) {
                        return Padding(
                          key: ValueKey(product.id),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 96,
                                      height: 72,
                                      color: const Color(0xFFFFF7ED),
                                      child: ProductNetworkImage(
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${product.price.toStringAsFixed(2)}€",
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFFF59E0B)),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            TextButton.icon(
                                              onPressed: () => _showForm(context, product),
                                              icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFFF97316)),
                                              label: Text("Editar", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFFF97316))),
                                            ),
                                            TextButton.icon(
                                              onPressed: () => _firebaseService.deleteProduct(product.id),
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                              label: Text("Eliminar", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFFDC2626))),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Padding(
                            key: ValueKey(product.id),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      height: 64,
                                      width: 96,
                                      child: product.imageUrl.isNotEmpty
                                          ? ProductNetworkImage(
                                              imageUrl: product.imageUrl,
                                              fit: BoxFit.contain,
                                              errorWidget: const Icon(Icons.broken_image, color: Colors.grey),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Expanded(child: Text("${product.price.toStringAsFixed(2)}€")),
                                Expanded(
                                  child: Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showForm(context, product)),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firebaseService.deleteProduct(product.id)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, [Product? product]) {
    showDialog(context: context, builder: (context) => ProductFormDialog(product: product));
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  const ProductFormDialog({super.key, this.product});
  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _formScrollController = ScrollController();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _ingredientExtraControllers;
  late List<FocusNode> _ingredientFocusNodes;
  bool _saving = false;

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double? _parsePrice(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _addIngredient() {
    if (_saving) return;
    final controller = TextEditingController();
    final extraController = TextEditingController(text: "0");
    final focusNode = FocusNode();
    setState(() {
      _ingredientControllers.add(controller);
      _ingredientExtraControllers.add(extraController);
      _ingredientFocusNodes.add(focusNode);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_formScrollController.hasClients) {
        _formScrollController.animateTo(
          _formScrollController.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      focusNode.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? "");
    _descController = TextEditingController(text: widget.product?.description ?? "");
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? "");
    _imageController = TextEditingController(text: widget.product?.imageUrl ?? "");
    final initialIngredients = widget.product != null ? List<String>.from(widget.product!.ingredients) : <String>["pan"];
    _ingredientControllers = initialIngredients.map((ingredient) => TextEditingController(text: ingredient)).toList();
    _ingredientExtraControllers = initialIngredients
        .map(
          (ingredient) => TextEditingController(
            text: ((widget.product?.ingredientExtraPrices[ingredient] ?? 0)).toStringAsFixed(2),
          ),
        )
        .toList();
    _ingredientFocusNodes = initialIngredients.map((_) => FocusNode()).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _formScrollController.dispose();
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _ingredientExtraControllers) {
      controller.dispose();
    }
    for (final node in _ingredientFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 720;
    final dialogWidth = isCompact ? (screenWidth - 28).clamp(310.0, screenWidth).toDouble() : math.min(700.0, screenWidth - 80);
    final titleSize = isCompact ? 28.0 : 36.0;
    final sectionSize = isCompact ? 17.0 : 20.0;
    final fieldFontSize = isCompact ? 17.0 : 18.0;
    final ingredientFontSize = isCompact ? 16.0 : 17.0;
    final actionFontSize = isCompact ? 16.0 : 17.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        width: dialogWidth,
        color: const Color(0xFFE5E7EB),
        padding: EdgeInsets.fromLTRB(isCompact ? 12 : 16, isCompact ? 12 : 16, isCompact ? 12 : 16, isCompact ? 12 : 14),
        child: SingleChildScrollView(
          controller: _formScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product == null ? "Nuevo Producto" : "Editar Producto",
                style: GoogleFonts.outfit(fontSize: titleSize, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              SizedBox(height: isCompact ? 12 : 14),
              Text("Nombre del Producto", style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
              const SizedBox(height: 10),
              TextField(controller: _nameController, style: TextStyle(fontSize: fieldFontSize), decoration: _fieldDecoration("Nombre del producto")),
              const SizedBox(height: 12),
              Text("Descripción", style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
              const SizedBox(height: 10),
              TextField(
                controller: _descController,
                style: TextStyle(fontSize: fieldFontSize),
                maxLines: 3,
                decoration: _fieldDecoration("Descripción del producto"),
              ),
              const SizedBox(height: 12),
              Text("Precio (€)", style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                style: TextStyle(fontSize: fieldFontSize),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecoration("Precio"),
              ),
              const SizedBox(height: 12),
              Text("URL de Imagen", style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
              const SizedBox(height: 10),
              TextField(controller: _imageController, style: TextStyle(fontSize: fieldFontSize), decoration: _fieldDecoration("https://...")),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Ingredientes",
                      style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                    ),
                  ),
                  SizedBox(
                    width: isCompact ? 120 : 110,
                    child: Text(
                      "Extra",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: sectionSize, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                    ),
                  ),
                  const SizedBox(width: 54),
                ],
              ),
              const SizedBox(height: 6),
              ..._ingredientControllers.asMap().entries.map((entry) {
                final i = entry.key;
                return Padding(
                  key: ObjectKey(_ingredientControllers[i]),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              key: ValueKey(_ingredientControllers[i]),
                              controller: _ingredientControllers[i],
                              focusNode: _ingredientFocusNodes[i],
                              decoration: _fieldDecoration("Nombre del ingrediente"),
                              style: TextStyle(fontSize: ingredientFontSize),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _ingredientExtraControllers[i],
                                    enabled: !_saving && _ingredientControllers[i].text.trim().toLowerCase() != 'pan',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _fieldDecoration("Extra €"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 44,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: _saving
                                        ? null
                                        : () {
                                            setState(() {
                                              _ingredientControllers[i].dispose();
                                              _ingredientExtraControllers[i].dispose();
                                              _ingredientFocusNodes[i].dispose();
                                              _ingredientControllers.removeAt(i);
                                              _ingredientExtraControllers.removeAt(i);
                                              _ingredientFocusNodes.removeAt(i);
                                              if (_ingredientControllers.isEmpty) {
                                                _ingredientControllers.add(TextEditingController());
                                                _ingredientExtraControllers.add(TextEditingController(text: "0"));
                                                _ingredientFocusNodes.add(FocusNode());
                                              }
                                            });
                                          },
                                    child: const Icon(Icons.delete, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                key: ValueKey(_ingredientControllers[i]),
                                controller: _ingredientControllers[i],
                                focusNode: _ingredientFocusNodes[i],
                                decoration: _fieldDecoration("Nombre del ingrediente"),
                                style: TextStyle(fontSize: ingredientFontSize),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 110,
                              child: TextField(
                                controller: _ingredientExtraControllers[i],
                                enabled: !_saving && _ingredientControllers[i].text.trim().toLowerCase() != 'pan',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _fieldDecoration("Extra €"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 44,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _saving
                                    ? null
                                    : () {
                                        setState(() {
                                          _ingredientControllers[i].dispose();
                                          _ingredientExtraControllers[i].dispose();
                                          _ingredientFocusNodes[i].dispose();
                                          _ingredientControllers.removeAt(i);
                                          _ingredientExtraControllers.removeAt(i);
                                          _ingredientFocusNodes.removeAt(i);
                                          if (_ingredientControllers.isEmpty) {
                                            _ingredientControllers.add(TextEditingController());
                                            _ingredientExtraControllers.add(TextEditingController(text: "0"));
                                            _ingredientFocusNodes.add(FocusNode());
                                          }
                                        });
                                      },
                                child: const Icon(Icons.delete, size: 20),
                              ),
                            ),
                          ],
                        ),
                );
              }),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: _saving ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _saving ? null : _addIngredient,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Agregar Ingrediente",
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 15 : 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              isCompact
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(_saving ? "Guardando..." : "Guardar", style: GoogleFonts.outfit(fontSize: actionFontSize, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _saving ? null : () => Navigator.pop(context),
                            child: Text("Cancelar", style: GoogleFonts.outfit(fontSize: actionFontSize, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(_saving ? "Guardando..." : "Guardar", style: GoogleFonts.outfit(fontSize: actionFontSize, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _saving ? null : () => Navigator.pop(context),
                              child: Text("Cancelar", style: GoogleFonts.outfit(fontSize: actionFontSize, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Indica el nombre del producto', error: true);
      return;
    }

    final price = _parsePrice(_priceController.text);
    if (price == null || price < 0) {
      _showSnack('Indica un precio válido (ej. 2.5 o 2,5)', error: true);
      return;
    }

    final ingredients = <String>[];
    final ingredientExtraPrices = <String, double>{};
    for (var i = 0; i < _ingredientControllers.length; i++) {
      final text = _ingredientControllers[i].text.trim();
      if (text.isNotEmpty) {
        ingredients.add(text);
        final normalizedExtra = _ingredientExtraControllers[i].text.trim().replaceAll(',', '.');
        final extraValue = double.tryParse(normalizedExtra) ?? 0;
        if (extraValue > 0 && text.toLowerCase() != 'pan') {
          ingredientExtraPrices[text] = extraValue;
        }
      }
    }

    final category = widget.product?.category ?? 'bocadillos';
    final available = widget.product?.available ?? true;

    final data = <String, dynamic>{
      'name': name,
      'description': _descController.text.trim(),
      'price': price,
      'imageUrl': _imageController.text.trim(),
      'ingredients': ingredients,
      'ingredientExtraPrices': ingredientExtraPrices,
      'available': available,
      'category': category,
    };

    setState(() => _saving = true);
    try {
      if (widget.product != null) {
        await _firebaseService.updateProduct(widget.product!.id, data);
      } else {
        await _firebaseService.addProduct(Product.fromMap(data, ''));
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack('No se pudo guardar: $e', error: true);
      setState(() => _saving = false);
    }
  }
}

class _KitchenTab extends StatefulWidget {
  @override
  State<_KitchenTab> createState() => _KitchenTabState();
}

class _KitchenTabState extends State<_KitchenTab> {
  final FirebaseService _firebaseService = FirebaseService();
  String _lastUpdate = DateFormat('HH:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final compact = _adminIsCompact(context);
    final pad = compact ? 16.0 : 40.0;
    return StreamBuilder<List<Order>>(
      stream: _firebaseService.getAllOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        final pending = orders.where((o) => o.status == 'pendiente').length;
        final preparing = orders.where((o) => o.status == 'preparando').length;
        final completed = orders.where((o) => o.status == 'completado').length;

        final stats = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KitchenStatCard(title: "Pendientes", value: pending.toString(), color: Colors.orange, compact: true),
                  const SizedBox(height: 12),
                  _KitchenStatCard(title: "En preparación", value: preparing.toString(), color: Colors.blue, compact: true),
                  const SizedBox(height: 12),
                  _KitchenStatCard(title: "Completados", value: completed.toString(), color: Colors.green, compact: true),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _KitchenStatCard(title: "PENDIENTES", value: pending.toString(), color: Colors.orange)),
                  const SizedBox(width: 20),
                  Expanded(child: _KitchenStatCard(title: "EN PREPARACIÓN", value: preparing.toString(), color: Colors.blue)),
                  const SizedBox(width: 20),
                  Expanded(child: _KitchenStatCard(title: "COMPLETADOS", value: completed.toString(), color: Colors.green)),
                ],
              );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                      onPressed: () => setState(() => _lastUpdate = DateFormat('HH:mm').format(DateTime.now())),
                      icon: const Icon(Icons.sync_rounded),
                      label: const Text("Actualizar"),
                    ),
                    const SizedBox(height: 8),
                    Text("Última actualización: $_lastUpdate", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                  ],
                )
              else
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                      onPressed: () => setState(() => _lastUpdate = DateFormat('HH:mm').format(DateTime.now())),
                      icon: const Icon(Icons.sync_rounded),
                      label: const Text("Actualizar"),
                    ),
                    const SizedBox(width: 15),
                    Text("Última actualización: $_lastUpdate", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              SizedBox(height: compact ? 20 : 30),
              stats,
              SizedBox(height: compact ? 24 : 40),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(compact ? 16 : 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(5 / 255), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pedidos Activos", style: GoogleFonts.outfit(fontSize: compact ? 20 : 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: compact ? 16 : 30),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (orders.isEmpty)
                      const Center(child: Text("No hay pedidos"))
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardW = math.min(350.0, constraints.maxWidth);
                          return Wrap(
                            spacing: compact ? 12 : 20,
                            runSpacing: compact ? 12 : 20,
                            children: orders
                                .where((o) =>
                                    o.status == 'pendiente' ||
                                    o.status == 'preparando' ||
                                    o.status == 'completado')
                                .map(
                                  (order) => SizedBox(
                                    width: cardW,
                                    child: _OrderCard(key: ValueKey(order.id), order: order),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KitchenStatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final bool compact;
  const _KitchenStatCard({required this.title, required this.value, required this.color, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 5)),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: compact ? 32 : 40, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 13 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              height: 1.25,
            ),
            softWrap: true,
            maxLines: compact ? 2 : 3,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final FirebaseService _firebaseService = FirebaseService();

  _OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == 'pendiente' ? Colors.orange : (order.status == 'preparando' ? Colors.blue : Colors.green);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(13 / 255), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.userEmail.split('@')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(order.timestamp))),
            ],
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            final isDelivery = order.serviceType == 'domicilio';
            final detail = isDelivery
                ? (order.deliveryAddress.isEmpty ? 'sin dirección' : order.deliveryAddress)
                : (order.userEmail.isEmpty ? 'cliente' : order.userEmail.split('@')[0]);
            final label = isDelivery ? "Domicilio" : "Recoger aquí";
            final icon = isDelivery ? Icons.delivery_dining_rounded : Icons.store;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1E293B)),
                        children: [
                          TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: " "),
                          TextSpan(
                            text: "($detail)",
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (order.serviceType == 'domicilio' && order.deliveryComments.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Comentarios: ${order.deliveryComments}",
              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B), fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 15),
          ...order.items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lunch_dining, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  "${i.productName} x${i.quantity}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                              if (i.customizations.toLowerCase().contains('sin gluten')) ...[
                                const SizedBox(width: 6),
                                const _GlutenFreeBadge(),
                              ],
                            ],
                          ),
                          OrderCustomizationLines(
                            customizations: i.customizations,
                            ingredientExtraPrices: null,
                            lineStyle: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Total: ${order.totalPrice.toStringAsFixed(2)}€",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: statusColor, foregroundColor: Colors.white),
              onPressed: () {
                final next = order.status == 'pendiente'
                    ? 'preparando'
                    : (order.status == 'preparando' ? 'completado' : 'limpiado_cocina');
                _firebaseService.updateOrderStatus(order.id, next);
              },
              child: Text(order.status == 'pendiente' ? "Preparar" : (order.status == 'preparando' ? "Completar" : "Limpiar")),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final bool compact;
  const _StatCard({required this.title, required this.value, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 5)),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 13 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              height: 1.25,
            ),
            softWrap: true,
            maxLines: compact ? 2 : 3,
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: compact ? 32 : 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)));
  }
}

/// Indicador "sin gluten": espiga de trigo con tachón rojo.
class _GlutenFreeBadge extends StatelessWidget {
  const _GlutenFreeBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Pan sin gluten",
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(Icons.grass_rounded, size: 16, color: Color(0xFF92400E)),
            Icon(Icons.block_rounded, size: 18, color: Color(0xFFDC2626)),
          ],
        ),
      ),
    );
  }
}
