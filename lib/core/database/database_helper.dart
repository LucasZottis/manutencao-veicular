import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'controle_veicular.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tipo_combustivel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tipo_servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE estabelecimento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE veiculo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        apelido TEXT NOT NULL,
        odometro_atual REAL NOT NULL DEFAULT 0,
        tanque_capacidade REAL,
        placa TEXT,
        tipo_combustivel_id INTEGER REFERENCES tipo_combustivel(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        veiculo_id INTEGER NOT NULL REFERENCES veiculo(id),
        tipo_servico_id INTEGER REFERENCES tipo_servico(id),
        estabelecimento_id INTEGER REFERENCES estabelecimento(id),
        data_hora TEXT NOT NULL,
        odometro REAL NOT NULL,
        valor REAL NOT NULL,
        descricao TEXT,
        observacao TEXT,
        km_proximo_servico REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE abastecimento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        veiculo_id INTEGER NOT NULL REFERENCES veiculo(id),
        tipo_combustivel_id INTEGER REFERENCES tipo_combustivel(id),
        estabelecimento_id INTEGER REFERENCES estabelecimento(id),
        data_hora TEXT NOT NULL,
        valor_total REAL NOT NULL,
        total_litros REAL NOT NULL,
        valor_por_litro REAL,
        odometro REAL NOT NULL
      )
    ''');

    // Seed lookup data
    await db.insert('tipo_combustivel', {'descricao': 'Gasolina'});
    await db.insert('tipo_combustivel', {'descricao': 'Etanol'});
    await db.insert('tipo_combustivel', {'descricao': 'Flex'});
    await db.insert('tipo_combustivel', {'descricao': 'Diesel'});
    await db.insert('tipo_combustivel', {'descricao': 'GNV'});
    await db.insert('tipo_combustivel', {'descricao': 'Elétrico'});

    await db.insert('tipo_servico', {'descricao': 'Troca de Óleo'});
    await db.insert('tipo_servico', {'descricao': 'Revisão Geral'});
    await db.insert('tipo_servico', {'descricao': 'Troca de Pneus'});
    await db.insert('tipo_servico', {'descricao': 'Freios'});
    await db.insert('tipo_servico', {'descricao': 'Alinhamento e Balanceamento'});
    await db.insert('tipo_servico', {'descricao': 'Filtros'});
    await db.insert('tipo_servico', {'descricao': 'Suspensão'});
    await db.insert('tipo_servico', {'descricao': 'Elétrica'});
  }
}
