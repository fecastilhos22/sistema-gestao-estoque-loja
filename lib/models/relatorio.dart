import 'package:loja_estoque_api/models/produto_mais_vendido.dart';
import 'package:loja_estoque_api/models/resumo_pagamento.dart';

/// Representa o relatório calculado de vendas e lucro de um período.
class Relatorio {
  /// Cria um novo [Relatorio].
  Relatorio({
    required this.periodo,
    required this.totalVendido,
    required this.lucro,
    required this.porFormaPagamento,
    required this.pecasMaisVendidas,
  });

  /// Período de referência (ex: "2026-09").
  final String periodo;

  /// Total vendido no período.
  final double totalVendido;

  /// Lucro no período (venda menos custo).
  final double lucro;

  /// Totais separados por forma de pagamento.
  final List<ResumoPagamento> porFormaPagamento;

  /// Ranking das peças mais vendidas no período.
  final List<ProdutoMaisVendido> pecasMaisVendidas;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'periodo': periodo,
      'total_vendido': totalVendido,
      'lucro': lucro,
      'por_forma_pagamento': porFormaPagamento.map((r) => r.toJson()).toList(),
      'pecas_mais_vendidas': pecasMaisVendidas.map((p) => p.toJson()).toList(),
    };
  }
}
