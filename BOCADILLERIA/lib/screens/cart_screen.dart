import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/order_customization_lines.dart';

/// Coste fijo del servicio a domicilio.
const double kHomeDeliveryFee = 2.0;

class CartScreen extends StatefulWidget {
  /// Devuelve también el coste de envío para que la pantalla padre lo sume al total guardado.
  final Future<void> Function(
    String serviceType, {
    String? address,
    String? comments,
    double deliveryFee,
  }) onOrder;

  const CartScreen({super.key, required this.onOrder});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _homeDelivery = false;
  String? _deliveryAddress;
  String? _deliveryComments;

  Future<String?> _askServiceType(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Cómo quieres el pedido?"),
        content: const Text("Selecciona una opción"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'domicilio'),
            child: const Text("Servicio a domicilio"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'recoger_aqui'),
            child: const Text("Recoger aquí"),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmHomeServiceCost(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        title: const Text("Servicio a domicilio"),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Color(0xFF374151), fontSize: 16, height: 1.35),
              children: [
                TextSpan(text: "Recuerda que el servicio a domicilio tiene un coste extra de "),
                TextSpan(
                  text: "2€",
                  style: TextStyle(
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                TextSpan(text: ".\n¿Desea continuar?"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Sí, continuar", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<Map<String, String>?> _askDeliveryDetails(BuildContext context) async {
    final addressController = TextEditingController();
    final commentsController = TextEditingController();
    String? errorText;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Datos de entrega"),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Dirección *",
                    hintText: "Calle, número, piso...",
                    errorText: errorText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Comentarios",
                    hintText: "Indicaciones para la entrega (opcional)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();
                if (address.isEmpty) {
                  setStateDialog(() => errorText = "La dirección es obligatoria");
                  return;
                }
                Navigator.pop(context, {
                  'address': address,
                  'comments': commentsController.text.trim(),
                });
              },
              child: const Text("Continuar"),
            ),
          ],
        ),
      ),
    );

    addressController.dispose();
    commentsController.dispose();
    return result;
  }

  double get _deliveryFee => _homeDelivery ? kHomeDeliveryFee : 0;

  Future<void> _configureHomeDelivery() async {
    final confirm = await _confirmHomeServiceCost(context);
    if (!confirm) return;
    if (!mounted) return;
    final data = await _askDeliveryDetails(context);
    if (data == null) return;
    setState(() {
      _homeDelivery = true;
      _deliveryAddress = data['address'];
      _deliveryComments = data['comments'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final cart = Provider.of<CartProvider>(context);
    final items = cart.cartItems;
    final total = cart.totalPrice + _deliveryFee;
    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        )),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.shopping_bag_rounded, color: AppTheme.primaryColor, size: 22)),
            const SizedBox(width: 12),
            const Expanded(child: Text("Tu Pedido", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor))),
            if (items.isNotEmpty) TextButton(onPressed: () { cart.clear(); },
              child: const Text("Vaciar", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))),
            IconButton(icon: const Icon(Icons.close_rounded, size: 22), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        const Divider(height: 1),
        // Items
        items.isEmpty
          ? Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text("Tu carrito está vacío", style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text("Añade productos desde el menú", style: TextStyle(color: Colors.grey[350], fontSize: 13)),
            ])))
          : Expanded(child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final p = item.product;
                final qty = item.quantity;
                final itemKey = "${p.id}${item.customizations}${item.customExtraPrice.toStringAsFixed(2)}";
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    // Icono categoría
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.lunch_dining, color: AppTheme.primaryColor, size: 24)),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.secondaryColor)),
                      OrderCustomizationLines(
                        customizations: item.customizations,
                        ingredientExtraPrices: p.ingredientExtraPrices,
                        lineStyle: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ])),
                    // Controles cantidad
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        _QtyBtn(icon: Icons.remove, onTap: () => cart.removeProduct(itemKey)),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                        _QtyBtn(icon: Icons.add, onTap: () => cart.addProduct(p, customizations: item.customizations, customExtraPrice: item.customExtraPrice)),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Text("${item.totalPrice.toStringAsFixed(2)}€",
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryColor)),
                  ]),
                );
              },
            )),
        // Footer
        if (items.isNotEmpty) Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            // ignore: deprecated_member_use
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(top: false, child: Column(children: [
            if (_homeDelivery) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Subtotal", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                Text("${cart.totalPrice.toStringAsFixed(2)}€", style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                  child: Row(children: [
                    Text("Servicio a domicilio", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() {
                        _homeDelivery = false;
                        _deliveryAddress = null;
                        _deliveryComments = null;
                      }),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.close_rounded, size: 14, color: Colors.grey[500]),
                      ),
                    ),
                  ]),
                ),
                Text("${kHomeDeliveryFee.toStringAsFixed(2)}€", style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
            ],
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
              Text("${total.toStringAsFixed(2)}€", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.secondaryColor)),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                // Si ya tenemos domicilio configurado, lanzamos directamente la orden.
                if (_homeDelivery) {
                  await widget.onOrder(
                    'domicilio',
                    address: _deliveryAddress,
                    comments: _deliveryComments,
                    deliveryFee: _deliveryFee,
                  );
                  return;
                }
                final selected = await _askServiceType(context);
                if (selected == null) return;
                if (selected == 'domicilio') {
                  await _configureHomeDelivery();
                  return; // Mostramos la línea en el carrito y dejamos que el usuario revise antes de confirmar.
                }
                await widget.onOrder(selected);
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  _homeDelivery ? "Realizar Pedido" : "Confirmar Pedido",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ]),
            )),
          ])),
        ),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16, color: AppTheme.secondaryColor)),
    );
  }
}
