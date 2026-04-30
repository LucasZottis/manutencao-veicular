class Servico {
  final int? id;
  final int veiculoId;
  final int? tipoServicoId;
  final int? estabelecimentoId;
  final DateTime dataHora;
  final double odometro;
  final double valor;
  final String? descricao;
  final String? observacao;
  final double? kmProximoServico;

  // Joined fields (not stored)
  final String? tipoServicoDescricao;
  final String? estabelecimentoNome;

  const Servico({
    this.id,
    required this.veiculoId,
    this.tipoServicoId,
    this.estabelecimentoId,
    required this.dataHora,
    required this.odometro,
    required this.valor,
    this.descricao,
    this.observacao,
    this.kmProximoServico,
    this.tipoServicoDescricao,
    this.estabelecimentoNome,
  });

  factory Servico.fromMap(Map<String, dynamic> map) => Servico(
        id: map['id'] as int?,
        veiculoId: map['veiculo_id'] as int,
        tipoServicoId: map['tipo_servico_id'] as int?,
        estabelecimentoId: map['estabelecimento_id'] as int?,
        dataHora: DateTime.parse(map['data_hora'] as String),
        odometro: (map['odometro'] as num).toDouble(),
        valor: (map['valor'] as num).toDouble(),
        descricao: map['descricao'] as String?,
        observacao: map['observacao'] as String?,
        kmProximoServico: map['km_proximo_servico'] != null
            ? (map['km_proximo_servico'] as num).toDouble()
            : null,
        tipoServicoDescricao: map['tipo_servico_descricao'] as String?,
        estabelecimentoNome: map['estabelecimento_nome'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'veiculo_id': veiculoId,
        'tipo_servico_id': tipoServicoId,
        'estabelecimento_id': estabelecimentoId,
        'data_hora': dataHora.toIso8601String(),
        'odometro': odometro,
        'valor': valor,
        'descricao': descricao,
        'observacao': observacao,
        'km_proximo_servico': kmProximoServico,
      };

  String get label => tipoServicoDescricao ?? descricao ?? 'Serviço';
}
