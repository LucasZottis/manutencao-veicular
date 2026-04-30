class Abastecimento {
  final int? id;
  final int veiculoId;
  final int? tipoCombustivelId;
  final int? estabelecimentoId;
  final DateTime dataHora;
  final double valorTotal;
  final double totalLitros;
  final double? valorPorLitro;
  final double odometro;

  // Joined fields
  final String? tipoCombustivelDescricao;
  final String? estabelecimentoNome;

  const Abastecimento({
    this.id,
    required this.veiculoId,
    this.tipoCombustivelId,
    this.estabelecimentoId,
    required this.dataHora,
    required this.valorTotal,
    required this.totalLitros,
    this.valorPorLitro,
    required this.odometro,
    this.tipoCombustivelDescricao,
    this.estabelecimentoNome,
  });

  factory Abastecimento.fromMap(Map<String, dynamic> map) => Abastecimento(
        id: map['id'] as int?,
        veiculoId: map['veiculo_id'] as int,
        tipoCombustivelId: map['tipo_combustivel_id'] as int?,
        estabelecimentoId: map['estabelecimento_id'] as int?,
        dataHora: DateTime.parse(map['data_hora'] as String),
        valorTotal: (map['valor_total'] as num).toDouble(),
        totalLitros: (map['total_litros'] as num).toDouble(),
        valorPorLitro: map['valor_por_litro'] != null
            ? (map['valor_por_litro'] as num).toDouble()
            : null,
        odometro: (map['odometro'] as num).toDouble(),
        tipoCombustivelDescricao:
            map['tipo_combustivel_descricao'] as String?,
        estabelecimentoNome: map['estabelecimento_nome'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'veiculo_id': veiculoId,
        'tipo_combustivel_id': tipoCombustivelId,
        'estabelecimento_id': estabelecimentoId,
        'data_hora': dataHora.toIso8601String(),
        'valor_total': valorTotal,
        'total_litros': totalLitros,
        'valor_por_litro': valorPorLitro,
        'odometro': odometro,
      };
}
