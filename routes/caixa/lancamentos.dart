import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/caixa_lancamento.dart';
import 'package:postgres/postgres.dart';

Response _erro(int status, String mensagem) {
  return Response.json(statusCode: status, body: {'erro': mensagem});
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final corpo = await context.request.json() as Map<String, dynamic>;
  final tipo = corpo['tipo'];
  final categoria = corpo['categoria'];
  final valor = double.tryParse('${corpo['valor']}');

  if (tipo is! String || !['entrada', 'saida'].contains(tipo)) {
    return _erro(HttpStatus.badRequest, 'tipo deve ser entrada ou saida');
  }
  if (categoria is! String || categoria.trim().isEmpty) {
    return _erro(HttpStatus.badRequest, 'Informe a categoria');
  }
  if (valor == null || valor <= 0) {
    return _erro(HttpStatus.badRequest, 'valor deve ser maior que zero');
  }

  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      Sql.named('''
        INSERT INTO caixa_lancamentos
          (caixa_dia_id, tipo, origem, categoria, valor)
        SELECT id, CAST(@tipo AS TEXT), 'manual', CAST(@categoria AS TEXT),
               CAST(CAST(@valor AS TEXT) AS NUMERIC)
        FROM caixa_dia
        WHERE data = (now() AT TIME ZONE 'America/Sao_Paulo')::date
          AND status = 'aberto'
        RETURNING tipo, origem, categoria, valor,
          to_char(criado_em AT TIME ZONE 'America/Sao_Paulo', 'HH24:MI')
            AS hora
      '''),
      parameters: {
        'tipo': tipo,
        'categoria': categoria.trim(),
        'valor': valor.toStringAsFixed(2),
      },
    );
    if (resultado.isEmpty) {
      return _erro(HttpStatus.conflict, 'Abra o caixa de hoje antes de lançar');
    }
    final lancamento = CaixaLancamento.fromRow(resultado.first.toColumnMap());
    return Response.json(
      statusCode: HttpStatus.created,
      body: lancamento.toJson(),
    );
  } finally {
    await conexao.close();
  }
}
