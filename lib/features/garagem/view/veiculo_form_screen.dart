import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/database/lookup_models.dart';
import '../../../core/database/lookup_repository.dart';
import '../controller/garagem_controller.dart';
import '../data/veiculo_model.dart';

class VeiculoFormScreen extends StatefulWidget {
  final int? veiculoId;
  const VeiculoFormScreen({super.key, this.veiculoId});

  @override
  State<VeiculoFormScreen> createState() => _VeiculoFormScreenState();
}

class _VeiculoFormScreenState extends State<VeiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apelidoCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _odometroCtrl = TextEditingController(text: '0');
  final _tanqueCtrl = TextEditingController();

  List<TipoCombustivel> _tipos = [];
  int? _tipoCombustivelId;
  bool _loading = false;
  bool _initializing = true;
  Veiculo? _editing;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = LookupRepository();
    _tipos = await repo.getTiposCombustivel();

    if (widget.veiculoId != null) {
      _editing = await context.read<GaragemController>().getById(widget.veiculoId!);
      if (_editing != null) {
        _apelidoCtrl.text = _editing!.apelido;
        _placaCtrl.text = _editing!.placa ?? '';
        _odometroCtrl.text = _editing!.odometroAtual.toStringAsFixed(0);
        _tanqueCtrl.text = _editing!.tanqueCapacidade?.toStringAsFixed(0) ?? '';
        _tipoCombustivelId = _editing!.tipoCombustivelId;
      }
    }

    if (mounted) setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _apelidoCtrl.dispose();
    _placaCtrl.dispose();
    _odometroCtrl.dispose();
    _tanqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final v = Veiculo(
      id: _editing?.id,
      apelido: _apelidoCtrl.text.trim(),
      placa: _placaCtrl.text.trim().isEmpty ? null : _placaCtrl.text.trim(),
      odometroAtual: double.tryParse(_odometroCtrl.text) ?? 0,
      tanqueCapacidade: _tanqueCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_tanqueCtrl.text),
      tipoCombustivelId: _tipoCombustivelId,
    );

    await context.read<GaragemController>().save(v);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.veiculoId == null
              ? 'CADASTRAR VEÍCULO'
              : 'EDITAR VEÍCULO',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: kPrimary,
          ),
        ),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      icon: Icons.directions_car_outlined,
                      title: 'INFORMAÇÕES DO VEÍCULO',
                      children: [
                        AppInput(
                          label: 'Nome do Veículo',
                          hint: 'ex: Meu Carro',
                          controller: _apelidoCtrl,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 20),
                        AppInput(
                          label: 'Placa',
                          hint: 'ABC-1234',
                          optional: true,
                          controller: _placaCtrl,
                        ),
                        const SizedBox(height: 20),
                        AppInput(
                          label: 'Quilometragem Atual',
                          hint: '0',
                          controller: _odometroCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffix: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('KM',
                                style: TextStyle(
                                    color: kOnSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                          ),
                          prefix: const Icon(Icons.speed_outlined,
                              color: kOnSurfaceVariant, size: 20),
                        ),
                        const SizedBox(height: 20),
                        AppInput(
                          label: 'Capacidade do Tanque',
                          hint: '50',
                          optional: true,
                          controller: _tanqueCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffix: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('L',
                                style: TextStyle(
                                    color: kOnSurfaceVariant,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        if (_tipos.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          AppDropdown<int>(
                            label: 'Tipo de Combustível',
                            optional: true,
                            value: _tipoCombustivelId,
                            prefix: const Icon(Icons.local_gas_station_outlined,
                                color: kOnSurfaceVariant, size: 20),
                            items: [
                              const DropdownMenuItem(
                                  value: null,
                                  child: Text('Selecionar...',
                                      style:
                                          TextStyle(color: kOnSurfaceVariant))),
                              ..._tipos.map((t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text(t.descricao),
                                  )),
                            ],
                            onChanged: (v) =>
                                setState(() => _tipoCombustivelId = v),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: widget.veiculoId == null
                          ? 'Cadastrar Veículo'
                          : 'Salvar Alterações',
                      icon: Icons.chevron_right,
                      onPressed: _save,
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: kPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
