import '../../../core/database/database_helper.dart';
import '../../garagem/data/veiculo_model.dart';
import '../../servicos/data/servico_model.dart';

class ProximoServico {
  final Servico servico;
  final Veiculo veiculo;
  final double kmRestante;

  const ProximoServico({
    required this.servico,
    required this.veiculo,
    required this.kmRestante,
  });

  ServiceStatusLevel get status {
    if (kmRestante <= 0) return ServiceStatusLevel.urgent;
    if (kmRestante <= 500) return ServiceStatusLevel.upcoming;
    return ServiceStatusLevel.good;
  }
}

enum ServiceStatusLevel { good, upcoming, urgent }

class DashboardRepository {
  final _db = DatabaseHelper.instance;

  Future<List<ProximoServico>> getProximosServicos({int? veiculoId}) async {
    final db = await _db.database;

    // Get last service per (veiculo, tipo_servico) that has km_proximo_servico set
    final rows = await db.rawQuery('''
      SELECT s.*,
             ts.descricao AS tipo_servico_descricao,
             e.nome       AS estabelecimento_nome,
             v.apelido    AS v_apelido,
             v.odometro_atual AS v_odometro_atual,
             v.placa      AS v_placa,
             v.tipo_combustivel_id AS v_tipo_combustivel_id,
             v.tanque_capacidade AS v_tanque_capacidade
      FROM servico s
      JOIN veiculo v ON v.id = s.veiculo_id
      LEFT JOIN tipo_servico ts ON ts.id = s.tipo_servico_id
      LEFT JOIN estabelecimento e ON e.id = s.estabelecimento_id
      WHERE s.km_proximo_servico IS NOT NULL
        ${veiculoId != null ? 'AND s.veiculo_id = ?' : ''}
      ORDER BY s.data_hora DESC
    ''', veiculoId != null ? [veiculoId] : []);

    // Deduplicate: keep only the most recent per (veiculo, tipo_servico)
    final seen = <String>{};
    final result = <ProximoServico>[];

    for (final row in rows) {
      final vId = row['veiculo_id'] as int;
      final tsId = row['tipo_servico_id']?.toString() ?? 'null';
      final key = '$vId-$tsId';
      if (seen.contains(key)) continue;
      seen.add(key);

      final veiculo = Veiculo(
        id: vId,
        apelido: row['v_apelido'] as String,
        odometroAtual: (row['v_odometro_atual'] as num).toDouble(),
        placa: row['v_placa'] as String?,
        tipoCombustivelId: row['v_tipo_combustivel_id'] as int?,
        tanqueCapacidade: row['v_tanque_capacidade'] != null
            ? (row['v_tanque_capacidade'] as num).toDouble()
            : null,
      );

      final servico = Servico.fromMap(Map.from(row));

      final kmAlvo = servico.odometro + servico.kmProximoServico!;
      final kmRestante = kmAlvo - veiculo.odometroAtual;

      result.add(ProximoServico(
        servico: servico,
        veiculo: veiculo,
        kmRestante: kmRestante,
      ));
    }

    // Sort: urgent first, then by kmRestante ascending
    result.sort((a, b) {
      if (a.status.index != b.status.index) {
        return b.status.index.compareTo(a.status.index);
      }
      return a.kmRestante.compareTo(b.kmRestante);
    });

    return result;
  }
}
