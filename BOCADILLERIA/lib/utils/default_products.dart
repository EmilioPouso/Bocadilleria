// Datos por defecto de los 10 bocadillos clasicos de la bocadilleria.
// Las imagenes provienen de Wikimedia Commons (URLs estables y publicas).
//
// NOTA: los caracteres acentuados se escriben con escape Unicode (\u00xx)
// para evitar problemas de codificacion al guardar el archivo.
class DefaultProducts {
  static const String _aAcute = '\u00e1';
  static const String _eAcute = '\u00e9';
  static const String _iAcute = '\u00ed';
  static const String _oAcute = '\u00f3';
  static const String _uAcute = '\u00fa';
  static const String _enye = '\u00f1';

  static String get _jamon => 'jam${_oAcute}n';
  static String get _Jamon => 'Jam${_oAcute}n';
  static String get _iberico => '${_iAcute}b${_eAcute}rico';
  static String get _Iberico => '${_iAcute}b${_eAcute}rico'; // mismo caso, va al final de frase
  static String get _Espanola => 'Espa${_enye}ola';
  static String get _limon => 'lim${_oAcute}n';
  static String get _atun => 'at${_uAcute}n';
  static String get _Atun => 'At${_uAcute}n';
  static String get _Esparragos => 'Esp${_aAcute}rragos';
  static String get _esparragos => 'esp${_aAcute}rragos';
  static String get _clasico => 'cl${_aAcute}sico';
  static String get _rustico => 'r${_uAcute}stico';

  /// Lista de los 10 bocadillos por defecto.
  static List<Map<String, dynamic>> get bocadillos => [
        {
          'id': 'boc-jamon-serrano',
          'name': 'Bocadillo de $_Jamon Serrano',
          'description':
              '$_Jamon serrano curado con tomate natural rallado y un toque de aceite de oliva virgen extra.',
          'price': 4.50,
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg/960px-Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg',
          'category': 'bocadillos',
          'ingredients': ['pan', 'tomate', '$_jamon serrano', 'aceite de oliva'],
          'ingredientExtraPrices': {
            'tomate': 0.30,
            '$_jamon serrano': 1.50,
            'aceite de oliva': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-jamon-iberico',
          'name': 'Bocadillo de $_Jamon $_Iberico',
          'description':
              '$_Jamon $_iberico de bellota sobre pan con tomate y aceite de oliva virgen extra.',
          'price': 6.50,
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg/960px-Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg',
          'category': 'bocadillos',
          'ingredients': ['pan', 'tomate', '$_jamon $_iberico', 'aceite de oliva'],
          'ingredientExtraPrices': {
            'tomate': 0.30,
            '$_jamon $_iberico': 2.50,
            'aceite de oliva': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-tortilla-espanola',
          'name': 'Bocadillo de Tortilla $_Espanola',
          'description':
              'Tortilla de patata casera, jugosa por dentro, en pan crujiente.',
          'price': 4.00,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_tortilla_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', 'tortilla de patata', 'mahonesa'],
          'ingredientExtraPrices': {
            'tortilla de patata': 1.20,
            'mahonesa': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-calamares',
          'name': 'Bocadillo de Calamares',
          'description':
              'El $_clasico de Madrid: calamares rebozados crujientes con un toque de $_limon.',
          'price': 5.50,
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Bocata_de_calamares.jpg/960px-Bocata_de_calamares.jpg',
          'category': 'bocadillos',
          'ingredients': ['pan', 'calamares', _limon, 'mahonesa'],
          'ingredientExtraPrices': {
            'calamares': 1.80,
            _limon: 0.10,
            'mahonesa': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-chorizo',
          'name': 'Bocadillo de Chorizo y Queso',
          'description':
              'Chorizo y queso fundido en pan $_rustico recien hecho.',
          'price': 3.50,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_chorizo_queso_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', 'chorizo', 'queso'],
          'ingredientExtraPrices': {
            'chorizo': 0.80,
            'queso': 0.80,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-lomo-queso',
          'name': 'Bocadillo de Lomo y Queso',
          'description':
              'Lomo y queso fundido en pan crujiente.',
          'price': 5.00,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_lomo_queso_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', 'lomo', 'queso'],
          'ingredientExtraPrices': {
            'lomo': 1.50,
            'queso': 0.80,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-atun',
          'name': 'Bocadillo de $_Atun',
          'description': '$_Atun con mahonesa, tomate maduro y lechuga fresca.',
          'price': 3.80,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_atun_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', _atun, 'mahonesa', 'tomate', 'lechuga'],
          'ingredientExtraPrices': {
            _atun: 1.20,
            'mahonesa': 0.20,
            'tomate': 0.30,
            'lechuga': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-mixto',
          'name': 'Bocadillo Mixto',
          'description':
              'El de toda la vida: $_jamon cocido y queso fundido en pan tierno.',
          'price': 3.50,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_mixto_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', '$_jamon cocido', 'queso'],
          'ingredientExtraPrices': {
            '$_jamon cocido': 0.80,
            'queso': 0.80,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-bacon-queso-mahonesa',
          'name': 'Bocadillo de Bacon, Queso y Mahonesa',
          'description':
              'Bacon crujiente, queso fundido y mahonesa en pan recien hecho.',
          'price': 4.00,
          'imageUrl':
              'https://bocadilleria-a5c81.web.app/images/bocadillo_bacon_queso_mahonesa_sin_fondo.png',
          'category': 'bocadillos',
          'ingredients': ['pan', 'bacon', 'queso', 'mahonesa'],
          'ingredientExtraPrices': {
            'bacon': 1.00,
            'queso': 0.80,
            'mahonesa': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-ternasco',
          'name': 'Bocadillo de Ternasco',
          'description':
              'Ternasco asado con alioli suave y pimiento verde a la plancha.',
          'price': 6.00,
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Bocadillo_de_ternasco%2C_alioli_y_pimiento_verde.jpeg/960px-Bocadillo_de_ternasco%2C_alioli_y_pimiento_verde.jpeg',
          'category': 'bocadillos',
          'ingredients': ['pan', 'ternasco', 'alioli', 'pimiento verde'],
          'ingredientExtraPrices': {
            'ternasco': 2.00,
            'alioli': 0.30,
            'pimiento verde': 0.40,
          },
          'available': true,
          'glutenFreeBread': false,
        },
        {
          'id': 'boc-esparragos',
          'name': 'Bocadillo de $_Esparragos',
          'description':
              '$_Esparragos verdes a la plancha con un toque de mahonesa casera.',
          'price': 4.20,
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg/960px-Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg',
          'category': 'bocadillos',
          'ingredients': ['pan', _esparragos, 'mahonesa'],
          'ingredientExtraPrices': {
            _esparragos: 1.00,
            'mahonesa': 0.20,
          },
          'available': true,
          'glutenFreeBread': false,
        },
      ];

  /// Devuelve un mapa listo para `PUT` en `/products` de Realtime Database.
  /// La clave es el id del producto.
  static Map<String, Map<String, dynamic>> asMap() {
    final result = <String, Map<String, dynamic>>{};
    for (final p in bocadillos) {
      final id = p['id'] as String;
      final copy = Map<String, dynamic>.from(p);
      copy.remove('id');
      result[id] = copy;
    }
    return result;
  }
}
