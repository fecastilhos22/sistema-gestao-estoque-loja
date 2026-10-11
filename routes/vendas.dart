import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/models/item_venda.dart';
import 'package:loja_estoque_api/models/venda.dart';

Response onRequest(RequestContext context) {
  final vendas = [
    Venda(
      id: 1,
      data: '2026-09-16',
      formaPagamento: 'pix',
      numParcelas: null,
      valorTotal: 49.90,
      itens: [
        ItemVenda(produtoCodigo: '0001', valorUnitario: 49.90),
      ],
    ),
    Venda(
      id: 2,
      data: '2026-09-16',
      formaPagamento: 'credito_parcelado',
      numParcelas: 3,
      valorTotal: 179.80,
      itens: [
        ItemVenda(produtoCodigo: '0001', valorUnitario: 49.90),
        ItemVenda(produtoCodigo: '0003', valorUnitario: 129.90),
      ],
    ),
  ];

  final vendasJson = vendas.map((venda) => venda.toJson()).toList();

  return Response.json(body: vendasJson);
}
