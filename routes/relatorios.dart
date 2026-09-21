import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/models/produto_mais_vendido.dart';
import 'package:loja_estoque_api/models/relatorio.dart';
import 'package:loja_estoque_api/models/resumo_pagamento.dart';

Response onRequest(RequestContext context) {
  final relatorio = Relatorio(
    periodo: '2026-09',
    totalVendido: 6420,
    lucro: 2180,
    porFormaPagamento: [
      ResumoPagamento(forma: 'credito_parcelado', valor: 2890),
      ResumoPagamento(forma: 'pix', valor: 1980),
      ResumoPagamento(forma: 'dinheiro', valor: 1550),
    ],
    pecasMaisVendidas: [
      ProdutoMaisVendido(nome: 'Camiseta Farm', quantidade: 18),
      ProdutoMaisVendido(nome: 'Calça jeans', quantidade: 11),
      ProdutoMaisVendido(nome: 'Vestido floral', quantidade: 9),
    ],
  );

  return Response.json(body: relatorio.toJson());
}
