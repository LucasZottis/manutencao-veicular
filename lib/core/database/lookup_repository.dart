import 'database_helper.dart';
import 'lookup_models.dart';

class LookupRepository {
  final _db = DatabaseHelper.instance;

  Future<List<TipoCombustivel>> getTiposCombustivel() async {
    final db = await _db.database;
    final rows = await db.query('tipo_combustivel', orderBy: 'descricao');
    return rows.map(TipoCombustivel.fromMap).toList();
  }

  Future<List<TipoServico>> getTiposServico() async {
    final db = await _db.database;
    final rows = await db.query('tipo_servico', orderBy: 'descricao');
    return rows.map(TipoServico.fromMap).toList();
  }

  Future<List<Estabelecimento>> getEstabelecimentos() async {
    final db = await _db.database;
    final rows = await db.query('estabelecimento', orderBy: 'nome');
    return rows.map(Estabelecimento.fromMap).toList();
  }

  Future<int> insertEstabelecimento(String nome) async {
    final db = await _db.database;
    return db.insert('estabelecimento', {'nome': nome});
  }
}
