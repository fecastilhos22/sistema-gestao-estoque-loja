/// Representa um único lançamento (entrada ou saída) dentro do caixa do dia.
class CaixaLancamento {
  /// Cria um novo [CaixaLancamento].
  CaixaLancamento({
    required this.tipo,
    required this.origem,
    required this.categoria,
    required this.valor,
    required this.hora,
  });

  /// "entrada" ou "saida".
  final String tipo;

  /// De onde veio: "venda" ou "manual".
  final String origem;

  /// Categoria do lançamento (ex: "venda_pix", "aluguel").
  final String categoria;

  /// Valor do lançamento.
  final double valor;

  /// Horário em que ocorreu.
  final String hora;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'origem': origem,
      'categoria': categoria,
      'valor': valor,
      'hora': hora,
    };
  }
}
