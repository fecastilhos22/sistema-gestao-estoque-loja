import 'package:loja_estoque_api/models/item_venda.dart';

/// Representa uma venda (comanda) realizada na loja.
class Venda {
  /// Cria uma nova [Venda].
  Venda({
    required this.id,
    required this.data,
    required this.formaPagamento,
    required this.numParcelas,
    required this.valorTotal,
    required this.itens,
  });

  /// Cria uma [Venda] a partir de uma linha do banco e dos itens dela.
  factory Venda.fromRow(Map<String, dynamic> linha, List<ItemVenda> itens) {
    return Venda(
      id: linha['id'] as int,
      data: linha['data'].toString().substring(0, 10),
      formaPagamento: linha['forma_pagamento'] as String,
      numParcelas: linha['num_parcelas'] as int?,
      valorTotal: double.parse(linha['valor_total'].toString()),
      itens: itens,
    );
  }

  /// Identificador da venda.
  final int id;

  /// Data em que a venda ocorreu.
  final String data;

  /// Forma de pagamento usada (ex: "pix", "credito_parcelado").
  final String formaPagamento;

  /// Número de parcelas, se for cartão parcelado. Nulo nos outros casos.
  final int? numParcelas;

  /// Valor total da venda.
  final double valorTotal;

  /// Itens (peças) vendidos nessa venda.
  final List<ItemVenda> itens;

  /// Converte para o formato JSON usado nas respostas da API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'forma_pagamento': formaPagamento,
      'num_parcelas': numParcelas,
      'valor_total': valorTotal,
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }
}
