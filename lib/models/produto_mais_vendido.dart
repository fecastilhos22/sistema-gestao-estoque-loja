/// Representa a posição de um produto no ranking de mais vendidos.
class ProdutoMaisVendido {
  /// Cria um novo [ProdutoMaisVendido].
  ProdutoMaisVendido({
    required this.nome,
    required this.quantidade,
  });

  /// Nome do produto.
  final String nome;

  /// Quantidade vendida no período do relatório.
  final int quantidade;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidade': quantidade,
    };
  }
}
