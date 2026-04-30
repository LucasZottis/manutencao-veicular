import 'package:flutter/material.dart';
import '../data/abastecimento_model.dart';
import '../data/abastecimento_repository.dart';
import '../../garagem/data/veiculo_repository.dart';

class AbastecimentosController extends ChangeNotifier {
  final _repo = AbastecimentoRepository();
  final _veiculoRepo = VeiculoRepository();

  List<Abastecimento> _abastecimentos = [];
  double _totalGasto = 0;
  Abastecimento? _ultimo;
  double? _consumoMedio;
  bool _loading = false;

  List<Abastecimento> get abastecimentos => _abastecimentos;
  double get totalGasto => _totalGasto;
  Abastecimento? get ultimo => _ultimo;
  double? get consumoMedio => _consumoMedio;
  bool get loading => _loading;

  Future<void> load(int veiculoId) async {
    _loading = true;
    notifyListeners();

    _abastecimentos = await _repo.getByVeiculo(veiculoId);
    _totalGasto = await _repo.getTotalGasto(veiculoId);
    _ultimo = await _repo.getUltimo(veiculoId);
    _consumoMedio = await _repo.getConsumoMedio(veiculoId);

    _loading = false;
    notifyListeners();
  }

  Future<void> save(Abastecimento a, {bool updateOdometro = false}) async {
    if (a.id == null) {
      await _repo.insert(a);
    } else {
      await _repo.update(a);
    }
    if (updateOdometro) {
      await _veiculoRepo.updateOdometro(a.veiculoId, a.odometro);
    }
  }

  Future<void> delete(int id, int veiculoId) async {
    await _repo.delete(id);
    await load(veiculoId);
  }
}
