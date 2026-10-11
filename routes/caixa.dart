import 'package:dart_frog/dart_frog.dart';
import 'package:loja_estoque_api/models/caixa_dia.dart';
import 'package:loja_estoque_api/models/caixa_lancamento.dart';

Response onRequest(RequestContext context) {
  final caixaDia = CaixaDia(
    data: '2026-09-16',
    valorAbertura: 100,
    valorFechamentoEsperado: 349.80,
    valorFechamentoConferido: null,
    status: 'aberto',
    lancamentos: [
      CaixaLancamento(
        tipo: 'entrada',
        origem: 'venda',
        categoria: 'venda_pix',
        valor: 49.90,
        hora: '10:05',
      ),
      CaixaLancamento(
        tipo: 'entrada',
        origem: 'venda',
        categoria: 'venda_credito',
        valor: 179.80,
        hora: '14:22',
      ),
      CaixaLancamento(
        tipo: 'saida',
        origem: 'manual',
        categoria: 'aluguel',
        valor: 20,
        hora: '09:00',
      ),
    ],
  );

  return Response.json(body: caixaDia.toJson());
}
