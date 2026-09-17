import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final caixaDia = {
    'data': '2026-09-16',
    'valor_abertura': 100.00,
    'valor_fechamento_esperado': 349.80,
    'valor_fechamento_conferido': null,
    'status': 'aberto',
    'lancamentos': [
      {
        'tipo': 'entrada',
        'origem': 'venda',
        'categoria': 'venda_pix',
        'valor': 49.90,
        'hora': '10:05',
      },
      {
        'tipo': 'entrada',
        'origem': 'venda',
        'categoria': 'venda_credito',
        'valor': 179.80,
        'hora': '14:22',
      },
      {
        'tipo': 'saida',
        'origem': 'manual',
        'categoria': 'aluguel',
        'valor': 20.00,
        'hora': '09:00',
      },
    ],
  };

  return Response.json(body: caixaDia);
}
