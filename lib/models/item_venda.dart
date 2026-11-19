/// Representa um item vendido dentro de uma venda específica.
class ItemVenda {
  /// Cria um novo [ItemVenda].
  ItemVenda({
    required this.produtoCodigo,
    required this.valorUnitario,
  });

  /// Cria um [ItemVenda] a partir de uma linha do banco.
  factory ItemVenda.fromRow(Map<String, dynamic> linha) {
    return ItemVenda(
      produtoCodigo: linha['produto_codigo'] as String,
      valorUnitario: double.parse(linha['valor_unitario'].toString()),
    );
  }

  /// Código do produto vendido.
  final String produtoCodigo;

  /// Valor cobrado por essa peça naquela venda específica.
  final double valorUnitario;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'produto_codigo': produtoCodigo,
      'valor_unitario': valorUnitario,
    };
  }
}
