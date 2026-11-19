import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/produto_mais_vendido.dart';
import 'package:loja_estoque_api/models/relatorio.dart';
import 'package:loja_estoque_api/models/resumo_pagamento.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final informado = context.request.uri.queryParameters['periodo'];
  if (informado != null && !RegExp(r'^\d{4}-\d{2}$').hasMatch(informado)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'erro': 'Use o período no formato AAAA-MM, ex: 2026-11'},
    );
  }

  final conexao = await abrirConexao();
  try {
    final periodo = informado ?? await _mesAtual(conexao);
    final parametros = <String, Object?>{'periodo': periodo};

    final totais = await conexao.execute(
      Sql.named('''
        SELECT COALESCE(SUM(valor_total), 0) AS total
        FROM vendas
        WHERE to_char(data, 'YYYY-MM') = @periodo
      '''),
      parameters: parametros,
    );

    final lucros = await conexao.execute(
      Sql.named('''
        SELECT COALESCE(SUM(i.valor_unitario - p.custo), 0) AS lucro
        FROM itens_venda i
        JOIN vendas v ON v.id = i.venda_id
        JOIN produtos p ON p.id = i.produto_id
        WHERE to_char(v.data, 'YYYY-MM') = @periodo
      '''),
      parameters: parametros,
    );

    final formas = await conexao.execute(
      Sql.named('''
        SELECT forma_pagamento AS forma, SUM(valor_total) AS valor
        FROM vendas
        WHERE to_char(data, 'YYYY-MM') = @periodo
        GROUP BY forma_pagamento
        ORDER BY valor DESC
      '''),
      parameters: parametros,
    );

    final ranking = await conexao.execute(
      Sql.named('''
        SELECT p.nome, COUNT(*) AS quantidade
        FROM itens_venda i
        JOIN vendas v ON v.id = i.venda_id
        JOIN produtos p ON p.id = i.produto_id
        WHERE to_char(v.data, 'YYYY-MM') = @periodo
        GROUP BY p.nome
        ORDER BY quantidade DESC, p.nome
        LIMIT 5
      '''),
      parameters: parametros,
    );

    final relatorio = Relatorio(
      periodo: periodo,
      totalVendido: double.parse(totais.first.first.toString()),
      lucro: double.parse(lucros.first.first.toString()),
      porFormaPagamento: formas
          .map((l) => ResumoPagamento.fromRow(l.toColumnMap()))
          .toList(),
      pecasMaisVendidas: ranking
          .map((l) => ProdutoMaisVendido.fromRow(l.toColumnMap()))
          .toList(),
    );

    return Response.json(body: relatorio.toJson());
  } finally {
    await conexao.close();
  }
}

Future<String> _mesAtual(Connection conexao) async {
  final resultado = await conexao.execute(
    "SELECT to_char(now() AT TIME ZONE 'America/Sao_Paulo', 'YYYY-MM')",
  );
  return resultado.first.first! as String;
}
