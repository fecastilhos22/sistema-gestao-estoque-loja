import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final produtos = [
    {
      'codigo': '0001',
      'nome': 'Camiseta Farm',
      'tamanho': 'M',
      'cor': 'Azul',
      'quantidade': 12,
      'valor_venda': 49.90,
    },
    {
      'codigo': '0002',
      'nome': 'Camiseta Farm',
      'tamanho': 'G',
      'cor': 'Azul',
      'quantidade': 1,
      'valor_venda': 49.90,
    },
  ];

  return Response.json(body: produtos);
}
