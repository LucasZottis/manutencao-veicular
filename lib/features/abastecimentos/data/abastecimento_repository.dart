import '../../../core/database/database_helper.dart';
import 'abastecimento_model.dart';

class AbastecimentoRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Abastecimento>> getByVeiculo(int veiculoId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT a.*,
             tc.descricao AS tipo_combustivel_descricao,
             e.nome       AS estabelecimento_nome
      FROM abastecimento a
      LEFT JOIN tipo_combustivel tc ON tc.id = a.tipo_combustivel_id
      LEFT JOIN estabelecimento e ON e.id = a.estabelecimento_id
      WHERE a.veiculo_id = ?
      ORDER BY a.data_hora DESC
    ''', [veiculoId]);
    return rows.map(Abastecimento.fromMap).toList();
  }

  Future<double> getTotalGasto(int veiculoId) async {
    final db = await _db.database;
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(valor_total), 0) AS t FROM abastecimento WHERE veiculo_id = ?',
      [veiculoId],
    );
    return (r.first['t'] as num).toDouble();
  }

  Future<Abastecimento?> getUltimo(int veiculoId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT a.*,
             tc.descricao AS tipo_combustivel_descricao,
             e.nome       AS estabelecimento_nome
      FROM abastecimento a
      LEFT JOIN tipo_combustivel tc ON tc.id = a.tipo_combustivel_id
      LEFT JOIN estabelecimento e ON e.id = a.estabelecimento_id
      WHERE a.veiculo_id = ?
      ORDER BY a.data_hora DESC
      LIMIT 1
    ''', [veiculoId]);
    return rows.isEmpty ? null : Abastecimento.fromMap(rows.first);
  }

  Future<double?> getConsumoMedio(int veiculoId) async {
    final lista = await getByVeiculo(veiculoId);
    if (lista.length < 2) return null;

    double totalKm = 0;
    double totalLitros = 0;
    for (var i = 0; i < lista.length - 1; i++) {
      final km = lista[i].odometro - lista[i + 1].odometro;
      if (km > 0) {
        totalKm += km;
        totalLitros += lista[i].totalLitros;
      }
    }
    return totalLitros > 0 ? totalKm / totalLitros : null;
  }

  Future<int> insert(Abastecimento a) async {
    final db = await _db.database;
    return db.insert('abastecimento', a.toMap());
  }

  Future<void> update(Abastecimento a) async {
    final db = await _db.database;
    await db.update('abastecimento', a.toMap(),
        where: 'id = ?', whereArgs: [a.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('abastecimento', where: 'id = ?', whereArgs: [id]);
  }
}
