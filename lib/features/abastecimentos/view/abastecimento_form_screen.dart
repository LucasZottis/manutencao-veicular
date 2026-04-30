import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/database/lookup_models.dart';
import '../../../core/database/lookup_repository.dart';
import '../../garagem/controller/garagem_controller.dart';
import '../../garagem/data/veiculo_model.dart';
import '../controller/abastecimentos_controller.dart';
import '../data/abastecimento_model.dart';
import '../data/abastecimento_repository.dart';

class AbastecimentoFormScreen extends StatefulWidget {
  final int veiculoId;
  final int? abastecimentoId;

  const AbastecimentoFormScreen({
    super.key,
    required this.veiculoId,
    this.abastecimentoId,
  });

  @override
  State<AbastecimentoFormScreen> createState() =>
      _AbastecimentoFormScreenState();
}

class _AbastecimentoFormScreenState extends State<AbastecimentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometroCtrl = TextEditingController();
  final _valorTotalCtrl = TextEditingController();
  final _litrosCtrl = TextEditingController();
  final _valorLitroCtrl = TextEditingController();

  List<Veiculo> _veiculos = [];
  List<TipoCombustivel> _tiposCombustivel = [];
  List<Estabelecimento> _estabelecimentos = [];

  int? _veiculoId;
  int? _tipoCombustivelId;
  int? _estabelecimentoId;
  DateTime _dataHora = DateTime.now();
  bool _atualizarOdometro = true;
  bool _loading = false;
  bool _initializing = true;
  Abastecimento? _editing;

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _veiculoId = widget.veiculoId;
    _init();
  }

  Future<void> _init() async {
    final repo = LookupRepository();
    final gCtrl = context.read<GaragemController>();

    await Future.wait([
      gCtrl.load(),
      repo.getTiposCombustivel().then((v) => _tiposCombustivel = v),
      repo.getEstabelecimentos().then((v) => _estabelecimentos = v),
    ]);

    _veiculos = gCtrl.veiculos;

    // Pre-select fuel type from vehicle
    final veiculo = await gCtrl.getById(widget.veiculoId);
    if (veiculo?.tipoCombustivelId != null) {
      _tipoCombustivelId = veiculo!.tipoCombustivelId;
    }
    if (veiculo != null) {
      _odometroCtrl.text = veiculo.odometroAtual.toStringAsFixed(0);
    }

    if (widget.abastecimentoId != null) {
      final list = await AbastecimentoRepository().getByVeiculo(widget.veiculoId);
      _editing =
          list.where((a) => a.id == widget.abastecimentoId).firstOrNull;
      if (_editing != null) {
        _veiculoId = _editing!.veiculoId;
        _tipoCombustivelId = _editing!.tipoCombustivelId;
        _estabelecimentoId = _editing!.estabelecimentoId;
        _dataHora = _editing!.dataHora;
        _odometroCtrl.text = _editing!.odometro.toStringAsFixed(0);
        _valorTotalCtrl.text = _editing!.valorTotal.toStringAsFixed(2);
        _litrosCtrl.text = _editing!.totalLitros.toStringAsFixed(2);
        _valorLitroCtrl.text =
            _editing!.valorPorLitro?.toStringAsFixed(3) ?? '';
      }
    }

    if (mounted) setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _odometroCtrl.dispose();
    _valorTotalCtrl.dispose();
    _litrosCtrl.dispose();
    _valorLitroCtrl.dispose();
    super.dispose();
  }

  void _recalcValorLitro() {
    final total = double.tryParse(_valorTotalCtrl.text.replaceAll(',', '.'));
    final litros = double.tryParse(_litrosCtrl.text.replaceAll(',', '.'));
    if (total != null && litros != null && litros > 0) {
      _valorLitroCtrl.text = (total / litros).toStringAsFixed(3);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataHora = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final odometro = double.tryParse(_odometroCtrl.text) ?? 0;
    final veiculo = await context.read<GaragemController>().getById(_veiculoId!);

    // Warn if combustivel type differs
    if (veiculo?.tipoCombustivelId != null &&
        _tipoCombustivelId != null &&
        veiculo!.tipoCombustivelId != _tipoCombustivelId) {
      final proceed = await _showCombustivelWarning();
      if (!proceed) return;
    }

    bool updateOdometro = _atualizarOdometro &&
        veiculo != null &&
        odometro > veiculo.odometroAtual;

    if (veiculo != null &&
        odometro > veiculo.odometroAtual &&
        !_atualizarOdometro) {
      updateOdometro = await _showOdometroSheet(odometro);
    }

    setState(() => _loading = true);

    final valorLitro =
        double.tryParse(_valorLitroCtrl.text.replaceAll(',', '.'));
    final valorTotal =
        double.tryParse(_valorTotalCtrl.text.replaceAll(',', '.')) ?? 0;
    final litros =
        double.tryParse(_litrosCtrl.text.replaceAll(',', '.')) ?? 0;

    final a = Abastecimento(
      id: _editing?.id,
      veiculoId: _veiculoId!,
      tipoCombustivelId: _tipoCombustivelId,
      estabelecimentoId: _estabelecimentoId,
      dataHora: _dataHora,
      valorTotal: valorTotal,
      totalLitros: litros,
      valorPorLitro: valorLitro,
      odometro: odometro,
    );

    await context
        .read<AbastecimentosController>()
        .save(a, updateOdometro: updateOdometro);

    if (mounted) context.pop();
  }

  Future<bool> _showCombustivelWarning() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tipo de combustível diferente'),
        content: const Text(
            'O combustível selecionado é diferente do tipo configurado no veículo. Deseja continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showOdometroSheet(double odometro) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atualizar hodômetro do veículo?',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'O hodômetro informado (${odometro.toInt()} km) é maior que o atual.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Não')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sim',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
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
          widget.abastecimentoId == null
              ? 'Novo abastecimento'
              : 'Editar Abastecimento',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FormCard(children: [
                      _fieldLabel('SELECIONAR VEÍCULO'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _veiculoId,
                        items: _veiculos
                            .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Row(children: [
                                    const Icon(Icons.directions_car_outlined,
                                        size: 18, color: kOnSurfaceVariant),
                                    const SizedBox(width: 8),
                                    Text(v.apelido),
                                  ]),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _veiculoId = v),
                        decoration: const InputDecoration(),
                        validator: (v) => v == null ? 'Obrigatório' : null,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _FormCard(children: [
                      _fieldLabel('DATA DO ABASTECIMENTO'),
                      const SizedBox(height: 8),
                      TextFormField(
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: kOnSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month_outlined,
                                color: kOnSurfaceVariant),
                            onPressed: _pickDate,
                          ),
                        ),
                        controller: TextEditingController(
                            text: _dateFmt.format(_dataHora)),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _FormCard(children: [
                      _fieldLabel('HODÔMETRO ATUAL (KM)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _odometroCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.speed_outlined,
                              size: 18, color: kOnSurfaceVariant),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Switch(
                            value: _atualizarOdometro,
                            onChanged: (v) =>
                                setState(() => _atualizarOdometro = v),
                            activeColor: kPrimary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'ATUALIZAR HODÔMETRO DO VEÍCULO',
                              style: TextStyle(
                                color: kOnSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FormCard(children: [
                            _fieldLabel('PREÇO POR LITRO'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _valorLitroCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.attach_money,
                                    size: 18, color: kOnSurfaceVariant),
                              ),
                              onChanged: (_) {
                                final litros = double.tryParse(
                                    _litrosCtrl.text.replaceAll(',', '.'));
                                final precoL = double.tryParse(
                                    _valorLitroCtrl.text.replaceAll(',', '.'));
                                if (litros != null && precoL != null) {
                                  _valorTotalCtrl.text =
                                      (litros * precoL).toStringAsFixed(2);
                                }
                              },
                            ),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FormCard(children: [
                            _fieldLabel('VALOR TOTAL'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _valorTotalCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                                    size: 18, color: kOnSurfaceVariant),
                              ),
                              onChanged: (_) => _recalcValorLitro(),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Obrigatório'
                                  : null,
                            ),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(children: [
                      _fieldLabel('TOTAL DE LITROS'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _litrosCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.water_drop_outlined,
                              size: 18, color: kOnSurfaceVariant),
                          suffixText: 'L',
                        ),
                        onChanged: (_) => _recalcValorLitro(),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    if (_tiposCombustivel.isNotEmpty)
                      _FormCard(children: [
                        _fieldLabel('TIPO DE COMBUSTÍVEL', optional: true),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _tipoCombustivelId,
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('Selecionar...',
                                    style:
                                        TextStyle(color: kOnSurfaceVariant))),
                            ..._tiposCombustivel.map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.descricao),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _tipoCombustivelId = v),
                          decoration: const InputDecoration(),
                        ),
                      ]),
                    const SizedBox(height: 12),
                    if (_estabelecimentos.isNotEmpty)
                      _FormCard(children: [
                        _fieldLabel('POSTO / ESTABELECIMENTO', optional: true),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _estabelecimentoId,
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('Selecionar...',
                                    style:
                                        TextStyle(color: kOnSurfaceVariant))),
                            ..._estabelecimentos.map((e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.nome),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _estabelecimentoId = v),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.local_gas_station,
                                size: 18, color: kOnSurfaceVariant),
                          ),
                        ),
                      ]),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'SALVAR REGISTRO',
                      icon: Icons.arrow_forward,
                      onPressed: _save,
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _fieldLabel(String label, {bool optional = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kOnSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        if (optional) ...[
          const Spacer(),
          const Text(
            '(OPCIONAL)',
            style: TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
