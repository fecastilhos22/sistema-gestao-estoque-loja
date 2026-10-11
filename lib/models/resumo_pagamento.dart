/// Representa o total vendido em uma forma de pagamento específica,
/// dentro de um relatório.
class ResumoPagamento {
  /// Cria um novo [ResumoPagamento].
  ResumoPagamento({
    required this.forma,
    required this.valor,
  });

  /// Forma de pagamento (ex: "pix", "dinheiro").
  final String forma;

  /// Total vendido nessa forma de pagamento, no período do relatório.
  final double valor;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'forma': forma,
      'valor': valor,
    };
  }
}
