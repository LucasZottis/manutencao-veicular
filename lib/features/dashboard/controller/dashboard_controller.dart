import 'package:flutter/material.dart';
import '../data/dashboard_repository.dart';
import '../../garagem/data/veiculo_model.dart';
import '../../garagem/data/veiculo_repository.dart';

class DashboardController extends ChangeNotifier {
  final _repo = DashboardRepository();
  final _veiculoRepo = VeiculoRepository();

  List<ProximoServico> _proximos = [];
  List<Veiculo> _veiculos = [];
  int? _filtroVeiculoId;
  bool _loading = false;

  List<ProximoServico> get proximos => _proximos;
  List<Veiculo> get veiculos => _veiculos;
  int? get filtroVeiculoId => _filtroVeiculoId;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _veiculos = await _veiculoRepo.getAll();
    _proximos = await _repo.getProximosServicos(veiculoId: _filtroVeiculoId);

    _loading = false;
    notifyListeners();
  }

  void setFiltroVeiculo(int? id) {
    _filtroVeiculoId = id;
    load();
  }
}
