enum AppSection { inicio, bocadillos, bebidas, pedidos, favoritos }

extension AppSectionLabels on AppSection {
  String get label {
    switch (this) {
      case AppSection.inicio:
        return 'Inicio';
      case AppSection.bocadillos:
        return 'Bocadillos';
      case AppSection.bebidas:
        return 'Bebidas';
      case AppSection.pedidos:
        return 'Pedidos';
      case AppSection.favoritos:
        return 'Favoritos';
    }
  }

  static AppSection? fromLabel(String label) {
    for (final section in AppSection.values) {
      if (section.label == label) return section;
    }
    return null;
  }

  bool get isMenuSection =>
      this == AppSection.inicio ||
      this == AppSection.bocadillos ||
      this == AppSection.bebidas;

  String? get menuCategory {
    switch (this) {
      case AppSection.inicio:
        return null;
      case AppSection.bocadillos:
        return 'bocadillos';
      case AppSection.bebidas:
        return 'bebidas';
      default:
        return null;
    }
  }
}
