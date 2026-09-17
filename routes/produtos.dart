import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/models/produto.dart';

Response onRequest(RequestContext context) {
  final produtos = [
    Produto(
      codigo: '0001',

      nome: 'Camiseta Farm',
      categoria: 'Camiseta',
      marca: 'Farm',
      fornecedor: 'Distribuidora ABC',
      tamanho: 'M',
      cor: 'Azul',
      custo: 25,
      valorVenda: 49.90,
      estoqueMinimo: 3,
      quantidadeAtual: 12,
      status: 'disponivel',
    ),
    Produto(
      codigo: '0002',
      nome: 'Camiseta Farm',
      categoria: 'Camiseta',
      marca: 'Farm',
      fornecedor: 'Distribuidora ABC',
      tamanho: 'G',
      cor: 'Azul',
      custo: 25,
      valorVenda: 49.90,
      estoqueMinimo: 3,
      quantidadeAtual: 1,
      status: 'disponivel',
    ),
  ];

  final produtosJson = produtos.map((produto) => produto.toJson()).toList();

  return Response.json(body: produtosJson);
}
