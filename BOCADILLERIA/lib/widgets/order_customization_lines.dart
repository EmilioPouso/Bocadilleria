import 'package:flutter/material.dart';
import '../utils/order_customization_display.dart';

/// Lista de personalizaciones como en «Tu pedido»: ordenadas y con «  +X.XX€» en extras.
class OrderCustomizationLines extends StatelessWidget {
  final String customizations;
  final Map<String, double>? ingredientExtraPrices;
  final TextStyle lineStyle;

  const OrderCustomizationLines({
    super.key,
    required this.customizations,
    this.ingredientExtraPrices,
    this.lineStyle = const TextStyle(fontSize: 11, color: Color(0xFF757575), fontStyle: FontStyle.italic),
  });

  @override
  Widget build(BuildContext context) {
    final lines = OrderCustomizationDisplay.displayLines(customizations, ingredientExtraPrices);
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: lineStyle),
            ),
          )
          .toList(),
      ),
    );
  }
}
