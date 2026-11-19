import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/caixa_dia.dart';
import 'package:loja_estoque_api/models/caixa_lancamento.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conexao = await abrirConexao();
  try {
    final dia = await conexao.execute('''
      SELECT * FROM caixa_dia
      WHERE data = (now() AT TIME ZONE 'America/Sao_Paulo')::date
    ''');
    if (dia.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'erro': 'Nenhum caixa aberto hoje'},
      );
    }
    final linhaDia = dia.first.toColumnMap();

    final linhas = await conexao.execute(
      Sql.named('''
        SELECT tipo, origem, categoria, valor,
          to_char(criado_em AT TIME ZONE 'America/Sao_Paulo', 'HH24:MI')
            AS hora
        FROM caixa_lancamentos
        WHERE caixa_dia_id = @id
        ORDER BY id
      '''),
      parameters: {'id': linhaDia['id']},
    );
    final lancamentos = linhas
        .map((l) => CaixaLancamento.fromRow(l.toColumnMap()))
        .toList();

    final caixa = CaixaDia.fromRow(linhaDia, lancamentos);
    return Response.json(body: caixa.toJson());
  } finally {
    await conexao.close();
  }
}
