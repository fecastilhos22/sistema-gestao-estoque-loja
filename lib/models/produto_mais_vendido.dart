/// Representa a posição de um produto no ranking de mais vendidos.
class ProdutoMaisVendido {
  /// Cria um novo [ProdutoMaisVendido].
  ProdutoMaisVendido({
    required this.nome,
    required this.quantidade,
  });

  /// Cria um [ProdutoMaisVendido] a partir de uma linha do banco.
  factory ProdutoMaisVendido.fromRow(Map<String, dynamic> linha) {
    return ProdutoMaisVendido(
      nome: linha['nome'] as String,
      quantidade: linha['quantidade'] as int,
    );
  }

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
