/// Catálogo de bocadillos por defecto que se carga desde el panel de admin.
/// Cada entrada es un mapa con los mismos campos que se usan en /products de
/// Firebase Realtime Database. Las imágenes son URLs reales de Wikimedia
/// Commons.
const List<Map<String, dynamic>> kDefaultProducts = [
  {
    'name': 'Bocadillo de Jamón Serrano',
    'description':
        'Jamón serrano curado con tomate natural rallado y un toque de aceite de oliva virgen extra.',
    'price': 4.50,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg/960px-Bocadillo_de_jam%C3%B3n_serrano_Mallorca.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'tomate', 'jamón serrano', 'aceite de oliva'],
    'ingredientExtraPrices': {
      'tomate': 0.30,
      'jamón serrano': 1.50,
      'aceite de oliva': 0.20,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo de Jamón Ibérico',
    'description':
        'Jamón ibérico de bellota sobre pan con tomate y aceite de oliva virgen extra.',
    'price': 6.50,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg/960px-Bocadillo_de_jam%C3%B3n_ib%C3%A9rico.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'tomate', 'jamón ibérico', 'aceite de oliva'],
    'ingredientExtraPrices': {
      'tomate': 0.30,
      'jamón ibérico': 2.50,
      'aceite de oliva': 0.20,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo de Tortilla Española',
    'description':
        'Tortilla de patata casera, jugosa por dentro, en pan crujiente.',
    'price': 4.00,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Bocadillo_de_tortilla_francesa%2C_pan_con_tomate_%28Espa%C3%B1a%29.jpg/960px-Bocadillo_de_tortilla_francesa%2C_pan_con_tomate_%28Espa%C3%B1a%29.jpg',
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
    'name': 'Bocadillo de Calamares',
    'description':
        'El clásico de Madrid: calamares rebozados crujientes con un toque de limón.',
    'price': 5.50,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Bocata_de_calamares.jpg/960px-Bocata_de_calamares.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'calamares', 'limón', 'mahonesa'],
    'ingredientExtraPrices': {
      'calamares': 1.80,
      'limón': 0.10,
      'mahonesa': 0.20,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo de Chorizo',
    'description':
        'Chorizo casero a la plancha con pan rústico recién hecho.',
    'price': 3.50,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Bocadillo_Chorizo_-_Madrid.JPG/960px-Bocadillo_Chorizo_-_Madrid.JPG',
    'category': 'bocadillos',
    'ingredients': ['pan', 'chorizo'],
    'ingredientExtraPrices': {
      'chorizo': 0.80,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo de Lomo con Queso',
    'description':
        'Lomo de cerdo adobado a la plancha con queso fundido y tomate.',
    'price': 5.00,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/3.-BOCADILLO-LOMO-Y-QUESO-min-scaled.jpg/960px-3.-BOCADILLO-LOMO-Y-QUESO-min-scaled.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'lomo', 'queso', 'tomate'],
    'ingredientExtraPrices': {
      'lomo': 1.50,
      'queso': 0.80,
      'tomate': 0.30,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo de Atún',
    'description': 'Atún con mahonesa, tomate maduro y lechuga fresca.',
    'price': 3.80,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Bocadillo_at%C3%BAn.JPG/960px-Bocadillo_at%C3%BAn.JPG',
    'category': 'bocadillos',
    'ingredients': ['pan', 'atún', 'mahonesa', 'tomate', 'lechuga'],
    'ingredientExtraPrices': {
      'atún': 1.20,
      'mahonesa': 0.20,
      'tomate': 0.30,
      'lechuga': 0.20,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
    'name': 'Bocadillo Mixto',
    'description':
        'El de toda la vida: jamón york y queso fundido en pan tierno.',
    'price': 3.50,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Bocadillo_Espa%C3%B1ol.jpg/960px-Bocadillo_Espa%C3%B1ol.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'jamón york', 'queso'],
    'ingredientExtraPrices': {
      'jamón york': 0.80,
      'queso': 0.80,
    },
    'available': true,
    'glutenFreeBread': false,
  },
  {
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
    'name': 'Bocadillo de Espárragos',
    'description':
        'Espárragos verdes a la plancha con un toque de mahonesa casera.',
    'price': 4.20,
    'imageUrl':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg/960px-Bocadillo_de_esp%C3%A1rragos_silvestres_%28Espa%C3%B1a%29.jpg',
    'category': 'bocadillos',
    'ingredients': ['pan', 'espárragos', 'mahonesa'],
    'ingredientExtraPrices': {
      'espárragos': 1.00,
      'mahonesa': 0.20,
    },
    'available': true,
    'glutenFreeBread': false,
  },
];
