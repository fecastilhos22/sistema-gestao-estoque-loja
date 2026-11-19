import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/item_venda.dart';
import 'package:loja_estoque_api/models/venda.dart';

Future<Response> onRequest(RequestContext context) async {
  final conexao = await abrirConexao();
  try {
    final linhasVendas = await conexao.execute(
      'SELECT * FROM vendas ORDER BY id',
    );
    final linhasItens = await conexao.execute('''
      SELECT i.venda_id, p.codigo AS produto_codigo, i.valor_unitario
      FROM itens_venda i
      JOIN produtos p ON p.id = i.produto_id
      ORDER BY i.id
    ''');
    final itens = linhasItens.map((l) => l.toColumnMap()).toList();

    final vendas = linhasVendas.map((linha) {
      final mapa = linha.toColumnMap();
      final itensDaVenda = itens
          .where((item) => item['venda_id'] == mapa['id'])
          .map(ItemVenda.fromRow)
          .toList();
      return Venda.fromRow(mapa, itensDaVenda);
    }).toList();

    return Response.json(body: vendas.map((v) => v.toJson()).toList());
  } finally {
    await conexao.close();
  }
}
