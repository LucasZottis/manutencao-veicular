class Veiculo {
  final int? id;
  final String apelido;
  final double odometroAtual;
  final double? tanqueCapacidade;
  final String? placa;
  final int? tipoCombustivelId;

  const Veiculo({
    this.id,
    required this.apelido,
    required this.odometroAtual,
    this.tanqueCapacidade,
    this.placa,
    this.tipoCombustivelId,
  });

  factory Veiculo.fromMap(Map<String, dynamic> map) => Veiculo(
        id: map['id'] as int?,
        apelido: map['apelido'] as String,
        odometroAtual: (map['odometro_atual'] as num).toDouble(),
        tanqueCapacidade: map['tanque_capacidade'] != null
            ? (map['tanque_capacidade'] as num).toDouble()
            : null,
        placa: map['placa'] as String?,
        tipoCombustivelId: map['tipo_combustivel_id'] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'apelido': apelido,
        'odometro_atual': odometroAtual,
        'tanque_capacidade': tanqueCapacidade,
        'placa': placa,
        'tipo_combustivel_id': tipoCombustivelId,
      };

  Veiculo copyWith({
    int? id,
    String? apelido,
    double? odometroAtual,
    double? tanqueCapacidade,
    String? placa,
    int? tipoCombustivelId,
  }) =>
      Veiculo(
        id: id ?? this.id,
        apelido: apelido ?? this.apelido,
        odometroAtual: odometroAtual ?? this.odometroAtual,
        tanqueCapacidade: tanqueCapacidade ?? this.tanqueCapacidade,
        placa: placa ?? this.placa,
        tipoCombustivelId: tipoCombustivelId ?? this.tipoCombustivelId,
      );
}
