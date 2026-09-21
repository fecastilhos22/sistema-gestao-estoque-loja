/// Representa um item vendido dentro de uma venda específica.
class ItemVenda {
  /// Cria um novo [ItemVenda].
  ItemVenda({
    required this.produtoCodigo,
    required this.valorUnitario,
  });

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
