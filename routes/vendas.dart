import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final vendas = [
    {
      'id': 1,
      'data': '2026-09-16',
      'forma_pagamento': 'pix',
      'num_parcelas': null,
      'valor_total': 49.90,
      'itens': [
        {'produto_codigo': '0001', 'valor_unitario': 49.90},
      ],
    },
    {
      'id': 2,
      'data': '2026-09-16',
      'forma_pagamento': 'credito_parcelado',
      'num_parcelas': 3,
      'valor_total': 179.80,
      'itens': [
        {'produto_codigo': '0001', 'valor_unitario': 49.90},
        {'produto_codigo': '0003', 'valor_unitario': 129.90},
      ],
    },
  ];

  return Response.json(body: vendas);
}
