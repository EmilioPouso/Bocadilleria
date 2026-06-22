import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../navigation/app_section.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/order_customization_lines.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBF4),
      body: Column(
        children: [
          AppHeader(
            activeSection: AppSection.pedidos,
            onNavigate: (section) => _navigateFromLegacy(context, section),
          ),
          const Expanded(child: OrdersContent()),
        ],
      ),
    );
  }

  static void _navigateFromLegacy(BuildContext context, AppSection section) {
    if (section == AppSection.pedidos) return;
    Navigator.pop(context);
  }
}

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    if (!auth.isLoggedIn) {
      return const Center(child: Text('Debes iniciar sesión para ver tus pedidos'));
    }

    final firebaseService = FirebaseService();

    return StreamBuilder<List<Order>>(
        stream: firebaseService.getUserOrders(auth.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar tus pedidos. Inténtalo de nuevo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                ),
              ),
            );
          }

          final orders = [
            ...(snapshot.data ?? []).where(
              (o) => o.status != 'archivado' && o.status != 'archived',
            ),
          ]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "Aún no tienes pedidos",
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Cuando hagas uno, aparecerá aquí con su estado.",
                    style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(isDesktop ? 60 : 16, 24, isDesktop ? 60 : 16, 28),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderTile(key: ValueKey(order.id), order: order);
            },
          );
        },
      );
  }
}

class _OrderTile extends StatefulWidget {
  final Order order;
  const _OrderTile({super.key, required this.order});

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  late final Future<Map<String, Map<String, double>>> _extrasFuture;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _extrasFuture = FirebaseService().getIngredientExtraPricesByProductIds(
      widget.order.items.map((e) => e.productId).toSet(),
    );
  }

  Order get order => widget.order;

  bool get _canCloseOrder =>
      order.status == 'completado' ||
      order.status == 'completed' ||
      order.status == 'limpiado_cocina';

  Color _statusColor(String status) {
    switch (status) {
      case 'pendiente':
      case 'pending':
        return Colors.orange;
      case 'preparando':
      case 'preparing':
        return Colors.blue;
      case 'completado':
      case 'completed':
      case 'limpiado_cocina':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pendiente':
      case 'pending':
        return 'Pendiente';
      case 'preparando':
      case 'preparing':
        return 'En preparación';
      case 'completado':
      case 'completed':
      case 'limpiado_cocina':
        return 'Completado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(order.timestamp),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pedido #${order.id.substring(0, 6)}",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusText(order.status),
                      style: TextStyle(fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ),
                  if (_canCloseOrder) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _closing
                          ? null
                          : () async {
                              setState(() => _closing = true);
                              try {
                                await FirebaseService().updateOrderStatus(order.id, 'archivado');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pedido eliminado de tu lista'),
                                    duration: Duration(milliseconds: 1200),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                setState(() => _closing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('No se pudo quitar el pedido. Inténtalo de nuevo.'),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: _closing
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF475569)),
                              )
                            : const Icon(Icons.close_rounded, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(formattedDate, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          FutureBuilder<Map<String, Map<String, double>>>(
            future: _extrasFuture,
            builder: (context, snapshot) {
              final extrasByProductId = snapshot.data ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items.map((i) {
                  final lineTotal = i.unitPrice * i.quantity;
                  return Padding(
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
                                Text(
                                  "${i.productName} x${i.quantity}",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                OrderCustomizationLines(
                                  customizations: i.customizations,
                                  ingredientExtraPrices: extrasByProductId[i.productId],
                                  lineStyle: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: const Color(0xFF757575),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${lineTotal.toStringAsFixed(2)}€",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Total: ${order.totalPrice.toStringAsFixed(2)}€",
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF97316), fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
