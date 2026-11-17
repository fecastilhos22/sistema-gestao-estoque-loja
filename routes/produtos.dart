import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/produto.dart';

Future<Response> onRequest(RequestContext context) async {
  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      'SELECT * FROM produtos ORDER BY id',
    );
    final produtos = resultado
        .map((linha) => Produto.fromRow(linha.toColumnMap()))
        .toList();
    final produtosJson = produtos.map((p) => p.toJson()).toList();
    return Response.json(body: produtosJson);
  } finally {
    await conexao.close();
  }
}
