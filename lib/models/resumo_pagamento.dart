/// Representa o total vendido em uma forma de pagamento específica,
/// dentro de um relatório.
class ResumoPagamento {
  /// Cria um novo [ResumoPagamento].
  ResumoPagamento({
    required this.forma,
    required this.valor,
  });

  /// Cria um [ResumoPagamento] a partir de uma linha do banco.
  factory ResumoPagamento.fromRow(Map<String, dynamic> linha) {
    return ResumoPagamento(
      forma: linha['forma'] as String,
      valor: double.parse(linha['valor'].toString()),
    );
  }

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
