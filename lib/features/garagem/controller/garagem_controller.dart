import 'package:flutter/material.dart';
import '../data/veiculo_model.dart';
import '../data/veiculo_repository.dart';

class GaragemController extends ChangeNotifier {
  final _repo = VeiculoRepository();

  List<Veiculo> _veiculos = [];
  bool _loading = false;

  List<Veiculo> get veiculos => _veiculos;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _veiculos = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(Veiculo v) async {
    if (v.id == null) {
      await _repo.insert(v);
    } else {
      await _repo.update(v);
    }
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<Veiculo?> getById(int id) => _repo.getById(id);
}
