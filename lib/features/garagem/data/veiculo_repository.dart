import '../../../core/database/database_helper.dart';
import 'veiculo_model.dart';

class VeiculoRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Veiculo>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('veiculo', orderBy: 'apelido');
    return rows.map(Veiculo.fromMap).toList();
  }

  Future<Veiculo?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('veiculo', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Veiculo.fromMap(rows.first);
  }

  Future<int> insert(Veiculo v) async {
    final db = await _db.database;
    return db.insert('veiculo', v.toMap());
  }

  Future<void> update(Veiculo v) async {
    final db = await _db.database;
    await db.update('veiculo', v.toMap(), where: 'id = ?', whereArgs: [v.id]);
  }

  Future<void> updateOdometro(int id, double odometro) async {
    final db = await _db.database;
    await db.update(
      'veiculo',
      {'odometro_atual': odometro},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('veiculo', where: 'id = ?', whereArgs: [id]);
  }
}
