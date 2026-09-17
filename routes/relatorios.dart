import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final relatorio = {
    'periodo': '2026-09',
    'total_vendido': 6420.00,
    'lucro': 2180.00,
    'por_forma_pagamento': [
      {'forma': 'credito_parcelado', 'valor': 2890.00},
      {'forma': 'pix', 'valor': 1980.00},
      {'forma': 'dinheiro', 'valor': 1550.00},
    ],
    'pecas_mais_vendidas': [
      {'nome': 'Camiseta Farm', 'quantidade': 18},
      {'nome': 'Calça jeans', 'quantidade': 11},
      {'nome': 'Vestido floral', 'quantidade': 9},
    ],
  };

  return Response.json(body: relatorio);
}
