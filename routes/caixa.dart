import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/caixa_dia.dart';
import 'package:loja_estoque_api/models/caixa_lancamento.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _consultar();
    case HttpMethod.post:
      return _abrir(context);
    case HttpMethod.patch:
      return _fechar(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Response _erro(int status, String mensagem) {
  return Response.json(statusCode: status, body: {'erro': mensagem});
}

double? _lerValor(Object? bruto) {
  if (bruto == null) return null;
  final valor = double.tryParse(bruto.toString());
  if (valor == null || valor < 0) return null;
  return valor;
}

Future<CaixaDia?> _buscarCaixaDeHoje(Connection conexao) async {
  final dia = await conexao.execute('''
    SELECT * FROM caixa_dia
    WHERE data = (now() AT TIME ZONE 'America/Sao_Paulo')::date
  ''');
  if (dia.isEmpty) return null;
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

  return CaixaDia.fromRow(linhaDia, lancamentos);
}

Future<Response> _consultar() async {
  final conexao = await abrirConexao();
  try {
    final caixa = await _buscarCaixaDeHoje(conexao);
    if (caixa == null) {
      return _erro(HttpStatus.notFound, 'Nenhum caixa aberto hoje');
    }
    return Response.json(body: caixa.toJson());
  } finally {
    await conexao.close();
  }
}

Future<Response> _abrir(RequestContext context) async {
  final corpo = await context.request.json() as Map<String, dynamic>;
  final valor = _lerValor(corpo['valor_abertura']);
  if (valor == null) {
    return _erro(HttpStatus.badRequest, 'Informe valor_abertura (0 ou mais)');
  }

  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      Sql.named('''
        INSERT INTO caixa_dia (data, valor_abertura)
        VALUES ((now() AT TIME ZONE 'America/Sao_Paulo')::date,
                CAST(CAST(@valor AS TEXT) AS NUMERIC))
        ON CONFLICT (data) DO NOTHING
        RETURNING id
      '''),
      parameters: {'valor': valor.toStringAsFixed(2)},
    );
    if (resultado.isEmpty) {
      return _erro(HttpStatus.conflict, 'O caixa de hoje já foi aberto');
    }
    final caixa = await _buscarCaixaDeHoje(conexao);
    return Response.json(
      statusCode: HttpStatus.created,
      body: caixa!.toJson(),
    );
  } finally {
    await conexao.close();
  }
}

Future<Response> _fechar(RequestContext context) async {
  final corpo = await context.request.json() as Map<String, dynamic>;
  final conferido = _lerValor(corpo['valor_conferido']);
  if (conferido == null) {
    return _erro(HttpStatus.badRequest, 'Informe valor_conferido (0 ou mais)');
  }

  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      Sql.named('''
        UPDATE caixa_dia
        SET valor_fechamento_conferido =
              CAST(CAST(@valor AS TEXT) AS NUMERIC),
            status = 'fechado'
        WHERE data = (now() AT TIME ZONE 'America/Sao_Paulo')::date
          AND status = 'aberto'
        RETURNING id
      '''),
      parameters: {'valor': conferido.toStringAsFixed(2)},
    );
    if (resultado.isEmpty) {
      return _erro(HttpStatus.conflict, 'Não há caixa aberto hoje');
    }
    final caixa = await _buscarCaixaDeHoje(conexao);
    final diferenca = conferido - caixa!.valorFechamentoEsperado;
    return Response.json(
      body: {
        'caixa': caixa.toJson(),
        'diferenca': double.parse(diferenca.toStringAsFixed(2)),
      },
    );
  } finally {
    await conexao.close();
  }
}
