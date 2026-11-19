import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/conexao_banco.dart';
import 'package:loja_estoque_api/models/produto.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _listar();
    case HttpMethod.post:
      return _cadastrar(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _listar() async {
  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      'SELECT * FROM produtos ORDER BY id',
    );
    final produtos = resultado
        .map((linha) => Produto.fromRow(linha.toColumnMap()))
        .toList();
    return Response.json(body: produtos.map((p) => p.toJson()).toList());
  } finally {
    await conexao.close();
  }
}

Future<Response> _cadastrar(RequestContext context) async {
  final corpo = await context.request.json() as Map<String, dynamic>;

  const obrigatorios = [
    'nome',
    'categoria',
    'marca',
    'fornecedor',
    'tamanho',
    'cor',
    'custo',
    'valor_venda',
  ];
  final faltando = obrigatorios.where((c) => corpo[c] == null).toList();
  if (faltando.isNotEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'erro': 'Campos obrigatórios faltando: ${faltando.join(', ')}'},
    );
  }

  final conexao = await abrirConexao();
  try {
    final resultado = await conexao.execute(
      Sql.named('''
        INSERT INTO produtos
          (nome, categoria, marca, fornecedor, tamanho, cor,
           custo, valor_venda, estoque_minimo, quantidade_atual)
        VALUES
          (@nome, @categoria, @marca, @fornecedor, @tamanho, @cor,
           CAST(CAST(@custo AS TEXT) AS NUMERIC),
           CAST(CAST(@valor_venda AS TEXT) AS NUMERIC),
           @estoque_minimo, @quantidade_atual)
        RETURNING *
      '''),
      parameters: {
        'nome': corpo['nome'],
        'categoria': corpo['categoria'],
        'marca': corpo['marca'],
        'fornecedor': corpo['fornecedor'],
        'tamanho': corpo['tamanho'],
        'cor': corpo['cor'],
        'custo': corpo['custo'].toString(),
        'valor_venda': corpo['valor_venda'].toString(),
        'estoque_minimo': corpo['estoque_minimo'] ?? 0,
        'quantidade_atual': corpo['quantidade_atual'] ?? 0,
      },
    );
    final produto = Produto.fromRow(resultado.first.toColumnMap());
    return Response.json(
      statusCode: HttpStatus.created,
      body: produto.toJson(),
    );
  } finally {
    await conexao.close();
  }
}
