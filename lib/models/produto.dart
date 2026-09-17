/// Representa uma peça (produto) cadastrada no estoque da loja.
class Produto {
  /// Cria um novo [Produto] com todos os campos obrigatórios.
  Produto({
    required this.codigo,
    required this.nome,
    required this.categoria,
    required this.marca,
    required this.fornecedor,
    required this.tamanho,
    required this.cor,
    required this.custo,
    required this.valorVenda,
    required this.estoqueMinimo,
    required this.quantidadeAtual,
    required this.status,
  });

  /// Código numérico sequencial, gerado automaticamente.
  final String codigo;

  /// Nome da peça (ex: "Camiseta Farm").
  final String nome;

  /// Categoria da peça (ex: "Camiseta", "Calça").
  final String categoria;

  /// Marca da roupa em si.
  final String marca;

  /// Fornecedor de onde a peça veio.
  final String fornecedor;

  /// Tamanho da peça (ex: "P", "M", "G").
  final String tamanho;

  /// Cor da peça.
  final String cor;

  /// Valor de custo da peça.
  final double custo;

  /// Valor de venda ao cliente.
  final double valorVenda;

  /// Quantidade mínima antes de gerar alerta de estoque baixo.
  final int estoqueMinimo;

  /// Quantidade disponível atualmente.
  final int quantidadeAtual;

  /// Situação da peça (ex: "disponível", "vendido", "defeito").
  final String status;

  /// Converte este [Produto] para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'categoria': categoria,
      'marca': marca,
      'fornecedor': fornecedor,
      'tamanho': tamanho,
      'cor': cor,
      'custo': custo,
      'valor_venda': valorVenda,
      'estoque_minimo': estoqueMinimo,
      'quantidade_atual': quantidadeAtual,
      'status': status,
    };
  }
}
