import 'package:flutter/material.dart';
import '../data/servico_model.dart';
import '../data/servico_repository.dart';
import '../../garagem/data/veiculo_repository.dart';

class ServicosController extends ChangeNotifier {
  final _repo = ServicoRepository();
  final _veiculoRepo = VeiculoRepository();

  List<Servico> _servicos = [];
  double _totalGasto = 0;
  bool _loading = false;

  int? _filterAno;
  int? _filterMes;
  int? _filterDia;

  List<Servico> get servicos => _servicos;
  double get totalGasto => _totalGasto;
  bool get loading => _loading;
  int? get filterAno => _filterAno;
  int? get filterMes => _filterMes;
  int? get filterDia => _filterDia;

  Future<void> load(int veiculoId) async {
    _loading = true;
    notifyListeners();

    _servicos = await _repo.getByVeiculo(
      veiculoId,
      ano: _filterAno,
      mes: _filterMes,
      dia: _filterDia,
    );
    _totalGasto = await _repo.getTotalGasto(veiculoId);

    _loading = false;
    notifyListeners();
  }

  void setFilter({int? ano, int? mes, int? dia}) {
    _filterAno = ano;
    _filterMes = mes;
    _filterDia = dia;
    notifyListeners();
  }

  void clearFilter() {
    _filterAno = null;
    _filterMes = null;
    _filterDia = null;
    notifyListeners();
  }

  Future<void> save(Servico s, {bool updateOdometro = false}) async {
    if (s.id == null) {
      await _repo.insert(s);
    } else {
      await _repo.update(s);
    }
    if (updateOdometro) {
      await _veiculoRepo.updateOdometro(s.veiculoId, s.odometro);
    }
  }

  Future<void> delete(int id, int veiculoId) async {
    await _repo.delete(id);
    await load(veiculoId);
  }
}
