import 'package:loja_estoque_api/models/caixa_lancamento.dart';

/// Representa o caixa de um dia específico da loja, com seus lançamentos.
class CaixaDia {
  /// Cria um novo [CaixaDia].
  CaixaDia({
    required this.data,
    required this.valorAbertura,
    required this.valorFechamentoEsperado,
    required this.valorFechamentoConferido,
    required this.status,
    required this.lancamentos,
  });

  /// Data do caixa (ex: "2026-09-16").
  final String data;

  /// Valor com que o caixa foi aberto.
  final double valorAbertura;

  /// Valor calculado que o caixa deveria ter ao fechar.
  final double valorFechamentoEsperado;

  /// Valor realmente contado ao fechar. Nulo enquanto o caixa está aberto.
  final double? valorFechamentoConferido;

  /// "aberto" ou "fechado".
  final String status;

  /// Todos os lançamentos (entradas e saídas) do dia.
  final List<CaixaLancamento> lancamentos;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'valor_abertura': valorAbertura,
      'valor_fechamento_esperado': valorFechamentoEsperado,
      'valor_fechamento_conferido': valorFechamentoConferido,
      'status': status,
      'lancamentos': lancamentos.map((l) => l.toJson()).toList(),
    };
  }
}
