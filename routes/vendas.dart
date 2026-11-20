import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/item_venda.dart';
import 'package:loja_estoque_api/models/venda.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _listar();
    case HttpMethod.post:
      return _registrar(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Response _erro(int status, String mensagem) {
  return Response.json(statusCode: status, body: {'erro': mensagem});
}

Future<Response> _listar() async {
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

Future<Response> _registrar(RequestContext context) async {
  final corpo = await context.request.json() as Map<String, dynamic>;

  const formasValidas = [
    'dinheiro',
    'pix',
    'debito',
    'credito_vista',
    'credito_parcelado',
  ];
  final forma = corpo['forma_pagamento'];
  final itensPedido = corpo['itens'];
  final parcelas = corpo['num_parcelas'];

  if (forma is! String || !formasValidas.contains(forma)) {
    return _erro(HttpStatus.badRequest, 'forma_pagamento inválida');
  }
  if (itensPedido is! List || itensPedido.isEmpty) {
    return _erro(HttpStatus.badRequest, 'Informe ao menos um item');
  }
  if (forma == 'credito_parcelado' && (parcelas is! int || parcelas < 2)) {
    return _erro(HttpStatus.badRequest, 'Informe num_parcelas (2 ou mais)');
  }

  final codigos = <String>[];
  for (final item in itensPedido) {
    final codigo = item is Map<String, dynamic> ? item['produto_codigo'] : null;
    if (codigo is! String) {
      return _erro(
        HttpStatus.badRequest,
         'Cada item precisa de produto_codigo');
    }
    codigos.add(codigo);
  }

  final quantidades = <String, int>{};
  for (final codigo in codigos) {
    quantidades[codigo] = (quantidades[codigo] ?? 0) + 1;
  }
  final ordenados = quantidades.keys.toList()..sort();

  final conexao = await abrirConexao();
  try {
    return await conexao.runTx<Response>((tx) async {
      final caixa = await tx.execute('''
        SELECT id FROM caixa_dia
        WHERE data = (now() AT TIME ZONE 'America/Sao_Paulo')::date
          AND status = 'aberto'
      ''');
      if (caixa.isEmpty) {
        return _erro(
          HttpStatus.conflict,
           'Abra o caixa de hoje antes de vender');
      }
      final caixaId = caixa.first.first! as int;

      final produtos = <String, Map<String, dynamic>>{};
      for (final codigo in ordenados) {
        final resultado = await tx.execute(
          Sql.named('''
            SELECT id, valor_venda, quantidade_atual
            FROM produtos
            WHERE codigo = @codigo
            FOR UPDATE
          '''),
          parameters: {'codigo': codigo},
        );
        if (resultado.isEmpty) {
          return _erro(HttpStatus.notFound, 'Produto $codigo não encontrado');
        }
        final produto = resultado.first.toColumnMap();
        if ((produto['quantidade_atual'] as int) < quantidades[codigo]!) {
          return _erro(
            HttpStatus.conflict,
            'Estoque insuficiente para o produto $codigo',
          );
        }
        produtos[codigo] = produto;
      }

      var total = 0.0;
      for (final codigo in codigos) {
        total += double.parse(produtos[codigo]!['valor_venda'].toString());
      }
      final totalTexto = total.toStringAsFixed(2);

      final venda = await tx.execute(
        Sql.named('''
          INSERT INTO vendas (data, forma_pagamento, num_parcelas, valor_total)
          VALUES ((now() AT TIME ZONE 'America/Sao_Paulo')::date,
                  @forma, @parcelas, CAST(CAST(@total AS TEXT) AS NUMERIC))
          RETURNING id
        '''),
        parameters: {
          'forma': forma,
          'parcelas': forma == 'credito_parcelado' ? parcelas : null,
          'total': totalTexto,
        },
      );
      final vendaId = venda.first.first! as int;

      for (final codigo in codigos) {
        final produto = produtos[codigo]!;
        await tx.execute(
          Sql.named('''
            INSERT INTO itens_venda (venda_id, produto_id, valor_unitario)
            VALUES (@venda, @produto, CAST(CAST(@valor AS TEXT) AS NUMERIC))
          '''),
          parameters: {
            'venda': vendaId,
            'produto': produto['id'],
            'valor': produto['valor_venda'].toString(),
          },
        );
      }

      for (final codigo in ordenados) {
        await tx.execute(
          Sql.named('''
            UPDATE produtos
            SET quantidade_atual = quantidade_atual - @qtd
            WHERE id = @id
          '''),
          parameters: {
            'qtd': quantidades[codigo],
            'id': produtos[codigo]!['id'],
          },
        );
      }

      await tx.execute(
        Sql.named('''
          INSERT INTO caixa_lancamentos
            (caixa_dia_id, tipo, origem, categoria, valor)
          VALUES
            (@caixa, 'entrada', 'venda', @categoria,
             CAST(CAST(@valor AS TEXT) AS NUMERIC))
        '''),
        parameters: {
          'caixa': caixaId,
          'categoria': 'venda_$forma',
          'valor': totalTexto,
        },
      );

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'id': vendaId,
          'valor_total': double.parse(totalTexto),
          'itens': codigos.length,
        },
      );
    });
  } finally {
    await conexao.close();
  }
}
