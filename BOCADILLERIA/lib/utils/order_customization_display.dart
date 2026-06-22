/// Normaliza y muestra líneas de personalización igual que en el carrito del usuario.
class OrderCustomizationDisplay {
  OrderCustomizationDisplay._();

  static String capitalizeWords(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => "${w[0].toUpperCase()}${w.substring(1).toLowerCase()}")
        .join(' ');
  }

  static String normalizeLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return '';
    if (line.toLowerCase() == 'pan sin gluten') return 'Pan sin gluten';

    final legacyMatch = RegExp(r'^(.*?)\s*\((Sin|Doble)\)$', caseSensitive: false).firstMatch(line);
    if (legacyMatch != null) {
      final ingredient = capitalizeWords(legacyMatch.group(1) ?? '');
      final mode = (legacyMatch.group(2) ?? '').toLowerCase();
      return mode == 'sin' ? 'Sin $ingredient' : 'Extra de $ingredient';
    }

    if (line.toLowerCase().startsWith('sin ')) {
      return 'Sin ${capitalizeWords(line.substring(4))}';
    }
    if (line.toLowerCase().startsWith('extra de ')) {
      return 'Extra de ${capitalizeWords(line.substring(9))}';
    }
    return capitalizeWords(line);
  }

  static int _rank(String line) {
    final normalized = line.toLowerCase();
    if (normalized.contains('sin gluten')) return 0;
    if (normalized.startsWith('sin ')) return 1;
    if (normalized.startsWith('extra de ')) return 2;
    return 3;
  }

  /// Líneas ordenadas sin sufijo de precio (sin prefijo "Personalizado:").
  static List<String> sortedLines(String rawCustomizations) {
    final customizationText = rawCustomizations
        .replaceFirst(RegExp(r'^Personalizado:\s*', caseSensitive: false), '')
        .trim();
    if (customizationText.isEmpty) return [];

    final lines = customizationText
        .split(',')
        .map((s) => normalizeLine(s))
        .where((s) => s.isNotEmpty)
        .toList()
      ..sort((a, b) {
        final byRank = _rank(a).compareTo(_rank(b));
        if (byRank != 0) return byRank;
        return a.compareTo(b);
      });
    return lines;
  }

  static double extraPriceForLine(String line, Map<String, double> ingredientExtraPrices) {
    final normalized = line.trim().toLowerCase();
    if (!normalized.startsWith('extra de ')) return 0;
    final ingredientName = line.substring(9).trim();
    for (final entry in ingredientExtraPrices.entries) {
      if (entry.key.trim().toLowerCase() == ingredientName.toLowerCase()) {
        return entry.value;
      }
    }
    return 0;
  }

  /// Texto final por línea (con espacio antes de +precio si aplica).
  static String displayLine(String line, Map<String, double>? ingredientExtraPrices) {
    if (ingredientExtraPrices == null || ingredientExtraPrices.isEmpty) return line;
    final extra = extraPriceForLine(line, ingredientExtraPrices);
    return extra > 0 ? '$line  +${extra.toStringAsFixed(2)}€' : line;
  }

  static List<String> displayLines(String rawCustomizations, Map<String, double>? ingredientExtraPrices) {
    return sortedLines(rawCustomizations).map((l) => displayLine(l, ingredientExtraPrices)).toList();
  }

  static double totalExtraPrice(String rawCustomizations, Map<String, double> ingredientExtraPrices) {
    return sortedLines(rawCustomizations).fold(
      0.0,
      (sum, line) => sum + extraPriceForLine(line, ingredientExtraPrices),
    );
  }
}
