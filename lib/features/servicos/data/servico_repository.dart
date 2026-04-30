import '../../../core/database/database_helper.dart';
import 'servico_model.dart';

class ServicoRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Servico>> getByVeiculo(
    int veiculoId, {
    int? ano,
    int? mes,
    int? dia,
  }) async {
    final db = await _db.database;
    var where = 's.veiculo_id = ?';
    final args = <dynamic>[veiculoId];

    if (ano != null) {
      where += ' AND strftime(\'%Y\', s.data_hora) = ?';
      args.add(ano.toString().padLeft(4, '0'));
    }
    if (mes != null) {
      where += ' AND strftime(\'%m\', s.data_hora) = ?';
      args.add(mes.toString().padLeft(2, '0'));
    }
    if (dia != null) {
      where += ' AND strftime(\'%d\', s.data_hora) = ?';
      args.add(dia.toString().padLeft(2, '0'));
    }

    final rows = await db.rawQuery('''
      SELECT s.*,
             ts.descricao AS tipo_servico_descricao,
             e.nome       AS estabelecimento_nome
      FROM servico s
      LEFT JOIN tipo_servico ts ON ts.id = s.tipo_servico_id
      LEFT JOIN estabelecimento e ON e.id = s.estabelecimento_id
      WHERE $where
      ORDER BY s.data_hora DESC
    ''', args);

    return rows.map(Servico.fromMap).toList();
  }

  Future<List<Servico>> getWithNextService(int veiculoId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT s.*,
             ts.descricao AS tipo_servico_descricao,
             e.nome       AS estabelecimento_nome
      FROM servico s
      LEFT JOIN tipo_servico ts ON ts.id = s.tipo_servico_id
      LEFT JOIN estabelecimento e ON e.id = s.estabelecimento_id
      WHERE s.veiculo_id = ? AND s.km_proximo_servico IS NOT NULL
      ORDER BY s.data_hora DESC
    ''', [veiculoId]);
    return rows.map(Servico.fromMap).toList();
  }

  Future<double> getTotalGasto(int veiculoId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(valor), 0) AS total FROM servico WHERE veiculo_id = ?',
      [veiculoId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> insert(Servico s) async {
    final db = await _db.database;
    return db.insert('servico', s.toMap());
  }

  Future<void> update(Servico s) async {
    final db = await _db.database;
    await db.update('servico', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('servico', where: 'id = ?', whereArgs: [id]);
  }
}
